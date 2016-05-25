module azured.keyvault.client;

import std.array;
import std.conv;
import std.format;
import std.string;
import std.stdio;
import vibe.d;

public enum string KeyVaultApiVersion = "2015-06-01";

private struct authToken
{
	public @name("token_type") string tokenType;
	public @name("expires_in") int expiresIn;
	public @name("expires_on") long expiresOn;
	public @name("not_before") long notBefore;
	public @name("resource") string resource;
	public @name("access_token") string accessToken;

	public this(Json json)
	{
		tokenType = json["token_type"].get!string;
		expiresIn = to!int(json["expires_in"].get!string);
		expiresOn = to!long(json["expires_on"].get!string);
		notBefore = to!long(json["not_before"].get!string);
		resource = json["resource"].get!string;
		accessToken = json["access_token"].get!string;
	}
}

public final class KeyVaultClient
{
	private immutable string _vaultName;
	package @safe @property final string vaultName() { return _vaultName; }
	private immutable string _appId;
	private immutable string _secretKey;
	private string _authorization;
	private string _resource;

	private shared authToken _currentToken;
	package @safe @property final string token()
	{
		if(_currentToken.accessToken is null || _currentToken.accessToken == "")
			authorize(_authorization, _resource);
		return _currentToken.accessToken;
	}

    public @trusted this(string vaultName, string appId, string secretKey)
    {
		_vaultName = vaultName;
		_appId = appId;
		_secretKey = secretKey;

		//Send a request for a the purpose of getting a challenge.
		string reqUri = format("https://%s.vault.azure.net/secrets?api-version=%s", vaultName,  KeyVaultApiVersion);
		requestHTTP(reqUri,
			(scope req) {
				req.method = HTTPMethod.GET;
				req.httpVersion = HTTPVersion.HTTP_1_1;
			},
			(scope res) {
				if(res is null)
					throw new Exception(format("No response received to authentication request for KeyVault: %s", vaultName));
				else if(res.statusCode == 401)
				{
					string challenge = res.headers.get("WWW-Authenticate");
					challenge = challenge[7..$];
					auto cl = split(challenge, ",");
					_authorization = strip(cl[0])[15..$-1];
					_resource = strip(cl[1])[10..$-1];
					authorize(_authorization, _resource);
				}
				else
					throw new Exception(format("Unable to authenticate with KeyVault: %s", vaultName));
			 }
		);
    }

	package @safe void authorize(string challenge)
	{
		string cstr = challenge[7..$];
		auto cl = split(cstr, ",");
		string auth = strip(cl[0])[15..$-1];
		string resource = strip(cl[1])[10..$-1];
		if(auth == _authorization && resource == _resource)
			authorize(_authorization, _resource);
		else
			throw new Exception("Authorization or Resource mismatch.");
	}

	private @trusted void authorize(string authorization, string resource, string authScope = null)
	{
		authToken at;
		requestHTTP(format("%s/oauth2/token?api-version=1.0", authorization),
			(scope req) {
				req.method = HTTPMethod.GET;
				req.httpVersion = HTTPVersion.HTTP_1_1;
				req.writeBody(cast(ubyte[])format("grant_type=client_credentials&resource=%s&client_id=%s&client_secret=%s", resource, _appId, _secretKey));
			},
			(scope res) {
				if(res.statusCode == 200)
					at = authToken(res.readJson());
				else
					throw new Exception("Unable to authenticate with Azure Active Directory using the supplied credentials");
			}
		);
		_currentToken = at;
	}

	package @safe final void writeAuthHeader(HTTPRequest req)
	{
		req.headers.addField("Authorization", "Bearer " ~ token);
	}
}