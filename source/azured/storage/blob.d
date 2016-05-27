module azured.storage.blob;

import azured.storage.client;
import azured.storage.security;

public enum AzureBlobType
{
	Block,
	Append,
	Page,
}

public final class AzureStorageBlobClient : AzureStorageClient
{
	this(string account, string sharedKey)
	{
		super(account, sharedKey);
	}

	this(string account, ubyte[] sharedKey)
	{
		super(account, sharedKey);
	}
}

public void putBlob(AzureStorageBlobClient client, string container, string path, ubyte[] data)
{
	KeyVaultSecret ns;
	requestHTTP(format("https://%s.blob.core.windows.net/%s/%s", client.Account, container, path),
		(scope req) {
			req.method = HTTPMethod.PUT;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			req.contentType = "application/octet-stream"
			req.bodyWriter.write(data)
			client.writeRequiredHeaders(req, AzureBlobType.Block, container ~ "/" ~ path);
		},
		(scope res) {
			if(res.statusCode != 201)
				throw new Exception("Unable to upload blob.");
		}
	);
	return ns;
}

public ubyte[] getBlob(AzureStorageBlobClient client, string container, string path)
{
	KeyVaultSecret ns;
	requestHTTP(format("https://%s.blob.core.windows.net/%s/%s", client.Account, container, path),
		(scope req) {
			req.method = HTTPMethod.GET;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			client.writeRequiredHeaders(req, AzureBlobType.Block, container ~ "/" ~ path);
		},
		(scope res) {
			if(res.statusCode != 200)
				throw new Exception("Unable to upload blob.");
		}
	);
	return ns;
}
