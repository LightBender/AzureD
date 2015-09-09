module azured.documentdb.connection;

public class AzureDocumentDBConnection
{
	private string _account;
	public @safe @property string Account() { return _account; }
	public @safe @property string Account(string value) { return _account = value; }

	this(string account)
	{
		_account = account;
	}
}
