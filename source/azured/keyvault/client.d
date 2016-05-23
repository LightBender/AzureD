module azured.keyvault.client;

import std.format;
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
}

public class KeyVaultClient
{
	private immutable string _vaultName;
	package @safe @property final string vaultName() { return _vaultName; }
    private immutable string _tenantName;
	private immutable string _appId;
	private immutable string _secretKey;

	private shared authToken _currentToken;
	package @safe @property final string token()
	{
		if(_currentToken.accessToken is null || _currentToken.accessToken == "")
			authorize();
		return _currentToken.accessToken;
	}

    public @safe this(string vaultName, string tenantName, string appId, string secretKey)
    {
		_vaultName = vaultName;
		_tenantName = tenantName;
		_appId = appId;
		_secretKey = secretKey;
    }

	package @trusted final void authorize()
	{
		authToken at;
		requestHTTP(format("https://login.microsoftonline.com/%s.onmicrosoft.com/oauth2/token?api-version=1.0", _tenantName),
			(scope req) {
				req.method = HTTPMethod.GET;
				req.httpVersion = HTTPVersion.HTTP_1_1;
				req.writeBody(cast(ubyte[])format("grant_type=client_credentials&resource=https://graph.windows.net&client_id=%s&client_secret=%s", _appId, _secretKey));
			},
			(scope res) {
				if(res.statusCode == 200)
					deserializeJson!authToken(at, res.readJson());
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