module azured.storage.client;

import std.base64;

public enum string StorageApiVersion = "2015-04-05";

public abstract class AzureStorageClient
{
	private string _account;
	public @safe @property string Account() nothrow { return _account; }
	public @safe @property string Account(string value) nothrow { return _account = value; }

	private ubyte[] _sharedKey;
	public @safe @property ubyte[] SharedKey() nothrow { return _sharedKey; }

	this(string account, string sharedKey)
	{
		_account = account;
		_sharedKey = Base64.decode(sharedKey);
	}

	this(string account, ubyte[] sharedKey)
	{
		_account = account;
		_sharedKey = sharedKey;
	}
}