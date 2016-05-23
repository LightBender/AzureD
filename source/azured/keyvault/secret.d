module azured.keyvault.secret;

import azured.keyvault.client;
import std.datetime;
import std.format;
import vibe.d;

public struct KeyVaultAttributes
{
	public @name("enabled") bool enabled = true;
}

public struct KeyVaultSecret
{
	public @name("value") string value;
	public @name("contentType") string contentType;
	public @name("id") string id;
	public @name("attributes") KeyVaultAttributes attributes;
	public @name("tags") string[string] tags;
}

public KeyVaultSecret createSecret(KeyVaultClient client, string name, KeyVaultSecret secret)
{
	KeyVaultSecret ns;
	requestHTTP(format("https://%s.vault.azure.net/secrets/%s?api-version=%s", client.vaultName, name, KeyVaultApiVersion),
		(scope req) {
			req.method = HTTPMethod.PUT;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			Json jObj = serializeToJson!KeyVaultSecret(secret);
			jObj.remove("id");
			req.writeJsonBody(jObj);
			client.writeAuthHeader(req);
		},
		(scope res) {
			if(res.statusCode == 200)
				deserializeJson!KeyVaultSecret(ns, res.readJson());
			else
				throw new Exception("Unable to create secret.");
		}
	);
	return ns;
}