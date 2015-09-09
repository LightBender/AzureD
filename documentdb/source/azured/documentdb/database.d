module azured.documentdb.database;

import vibe.d;

public class DatabaseList
{
	private string _rid;
	public @property @name("_rid") string RID() { return _rid; }
	public @property @name("_rid") string RID(string value) { return _rid = value; }

	private int _count;
	public @property @name("_count") int Count() { return _count; }
	public @property @name("_count") int Count(int value) { return _count = value; }

	private Database[] _databases;
	public @property @name("Databases") Database[] Databases() { return _databases; }
	public @property @name("Databases") Database[] CoDatabasesunt(Database[] value) { return _databases = value; }
}

public class Database
{
	private string _id;
	public @property @name("_id") string ID() { return _id; }
	public @property @name("_id") string ID(string value) { return _id = value; }

	private string _rid;
	public @property @name("_rid") string RID() { return _rid; }
	public @property @name("_rid") string RID(string value) { return _rid = value; }

	private ulong _ts;
	public @property @name("_ts") ulong Timestamp() { return _ts; }
	public @property @name("_ts") ulong Timestamp(ulong value) { return _ts = value; }

	private string _self;
	public @property @name("_self") string Self() { return _self; }
	public @property @name("_self") string Self(string value) { return _self = value; }

	private string _etag;
	public @property @name("_etag") string ETag() { return _etag; }
	public @property @name("_etag") string ETag(string value) { return _etag = value; }

	private string _colls;
	public @property @name("_colls") string Colletions() { return _colls; }
	public @property @name("_colls") string Colletions(string value) { return _colls = value; }

	private string _users;
	public @property @name("_users") string Users() { return _users; }
	public @property @name("_users") string Users(string value) { return _users = value; }
}

public DatabaseList listDatabases()
{
	return null;
}