module azured.documentdb.connection;

import std.base64;

public class AzureDocumentDBConnection
{
	private string _account;
	public @safe @property string Account() { return _account; }
	public @safe @property string Account(string value) { return _account = value; }

	private string _key;
	public @safe @property string Key() { return _key; }

	this(string account, string key)
	{
		_account = account;
		_key = key;
	}

	this(string account, ubyte[] key)
	{
		_account = account;
		_key = Base64.encode(key);
	}
}
