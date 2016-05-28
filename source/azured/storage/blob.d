module azured.storage.blob;

import std.array;
import std.conv;
import std.format;
import std.string;
import std.stdio;
import vibe.d;

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
	requestHTTP(format("https://%s.blob.core.windows.net/%s/%s", client.Account, container, path),
		(scope req) {
			req.method = HTTPMethod.PUT;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			req.contentType = "application/octet-stream";
			req.bodyWriter.write(data);
			client.writeRequiredHeaders(req, AzureBlobType.Block, container ~ "/" ~ path);
		},
		(scope res) {
			if(res.statusCode != 201)
				throw new Exception("Unable to upload blob.");
		}
	);
}

public ubyte[] getBlob(AzureStorageBlobClient client, string container, string path)
{
	ubyte[] blob;
	blob.reserve(262144);
	requestHTTP(format("https://%s.blob.core.windows.net/%s/%s", client.Account, container, path),
		(scope req) {
			req.method = HTTPMethod.GET;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			client.writeRequiredHeaders(req, AzureBlobType.Block, container ~ "/" ~ path);
		},
		(scope res) {
			if(res.statusCode != 200)
				throw new Exception("Unable to upload blob.");
			res.readRawBody((scope reader)
			{
				while(!reader.empty)
				{
					if(reader.leastSize == 0)
						sleep(10.msecs);
					ubyte[] temp = new ubyte[cast(uint)reader.leastSize];
					reader.read(temp);
					blob ~= temp;
				}
			});
		}
	);
	return blob;
}
