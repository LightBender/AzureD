module azured.documentdb.connection;

import std.base64;

public class AzureDocumentDBConnection
{
	private string _account;
	public @safe @property string Account() { return _account; }
	public @safe @property string Account(string value) { return _account = value; }

	private string _masterKey;
	public @safe @property string MasterKey() { return _masterKey; }

	private string _resourceKey;
	public @safe @property string ResourceKey() { return _resourceKey; }

	this(string account, string resourceKey, string masterKey = null)
	{
		_account = account;
		_masterKey = masterKey;
		_resourceKey = resourceKey;
	}

	this(string account, ubyte[] resourceKey, ubyte[] masterKey = null)
	{
		_account = account;
		_masterKey = Base64.encode(masterKey);
		_resourceKey = Base64.encode(resourceKey);
	}
}
