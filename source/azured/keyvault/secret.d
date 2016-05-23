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

public KeyVaultSecret setSecret(KeyVaultClient client, string name, KeyVaultSecret secret)
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
			else if(res.statusCode == 401)
			{
				client.authorize(res.headers.get("WWW-Authenticate"));
				ns = setSecret(client, name, secret);
			}
			else
				throw new Exception("Unable to create secret.");
		}
	);
	return ns;
}

public KeyVaultSecret setSecret(KeyVaultClient client, string name, string secret)
{
	KeyVaultSecret ns;
	ns.value = secret;
	ns.contentType = "text/plain";
	requestHTTP(format("https://%s.vault.azure.net/secrets/%s?api-version=%s", client.vaultName, name, KeyVaultApiVersion),
		(scope req) {
			req.method = HTTPMethod.PUT;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			Json jObj = serializeToJson!KeyVaultSecret(ns);
			jObj.remove("id");
			req.writeJsonBody(jObj);
			client.writeAuthHeader(req);
		},
		(scope res) {
			if(res.statusCode == 200)
				deserializeJson!KeyVaultSecret(ns, res.readJson());
			else if(res.statusCode == 401)
			{
				client.authorize(res.headers.get("WWW-Authenticate"));
				ns = setSecret(client, name, secret);
			}
			else
				throw new Exception("Unable to create secret.");
		}
	);
	return ns;
}

public KeyVaultSecret getSecret(KeyVaultClient client, string name, string secretVersion = null)
{
	KeyVaultSecret ns;
	string reqUri = (secretVersion is null ? format("https://%s.vault.azure.net/secrets/%s?api-version=%s", client.vaultName, name, KeyVaultApiVersion) : format("https://%s.vault.azure.net/secrets/%s/%s?api-version=%s", client.vaultName, name, secretVersion, KeyVaultApiVersion));
	requestHTTP(reqUri,
		(scope req) {
			req.method = HTTPMethod.GET;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			client.writeAuthHeader(req);
		},
		(scope res) {
			if(res.statusCode == 200)
				deserializeJson!KeyVaultSecret(ns, res.readJson());
			else if(res.statusCode == 401)
			{
				client.authorize(res.headers.get("WWW-Authenticate"));
				ns = getSecret(client, name, secretVersion);
			}
			else
				throw new Exception("Unable to get secret.");
		}
	);
	return ns;
}

public KeyVaultSecret updateSecret(KeyVaultClient client, string name, KeyVaultSecret secret)
{
	KeyVaultSecret ns;
	requestHTTP(format("https://%s.vault.azure.net/secrets/%s?api-version=%s", client.vaultName, name, KeyVaultApiVersion),
		(scope req) {
			req.method = HTTPMethod.PATCH;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			Json jObj = serializeToJson!KeyVaultSecret(secret);
			jObj.remove("id");
			jObj.remove("value");
			req.writeJsonBody(jObj);
			client.writeAuthHeader(req);
		},
		(scope res) {
			if(res.statusCode == 200)
				deserializeJson!KeyVaultSecret(ns, res.readJson());
			else if(res.statusCode == 401)
			{
				client.authorize(res.headers.get("WWW-Authenticate"));
				ns = updateSecret(client, name, secret);
			}
			else
				throw new Exception("Unable to get secret.");
		}
	);
	return ns;
}

public KeyVaultSecret deleteSecret(KeyVaultClient client, string name)
{
	KeyVaultSecret ns;
	requestHTTP(format("https://%s.vault.azure.net/secrets/%s?api-version=%s", client.vaultName, name, KeyVaultApiVersion),
		(scope req) {
			req.method = HTTPMethod.DELETE;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			client.writeAuthHeader(req);
		},
		(scope res) {
			if(res.statusCode == 200)
				deserializeJson!KeyVaultSecret(ns, res.readJson());
			else if(res.statusCode == 401)
			{
				client.authorize(res.headers.get("WWW-Authenticate"));
				ns = deleteSecret(client, name);
			}
			else
				throw new Exception("Unable to get secret.");
		}
	);
	return ns;
}
