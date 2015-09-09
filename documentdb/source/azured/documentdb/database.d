module azured.documentdb.database;

import azured.documentdb.connection;
import std.format;
import vibe.d;

public class DatabaseList
{
	private string _rid;
	public @safe @property @name("_rid") string RID() { return _rid; }
	public @safe @property @name("_rid") string RID(string value) { return _rid = value; }

	private int _count;
	public @safe @property @name("_count") int Count() { return _count; }
	public @safe @property @name("_count") int Count(int value) { return _count = value; }

	private Database[] _databases;
	public @safe @property @name("Databases") Database[] Databases() { return _databases; }
	public @safe @property @name("Databases") Database[] Databases(Database[] value) { return _databases = value; }
}

public class Database
{
	private string _id;
	public @safe @property @name("id") string ID() { return _id; }
	public @safe @property @name("id") string ID(string value) { return _id = value; }

	private string _rid;
	public @safe @property @name("_rid") string RID() { return _rid; }
	public @safe @property @name("_rid") string RID(string value) { return _rid = value; }

	private ulong _ts;
	public @safe @property @name("_ts") ulong Timestamp() { return _ts; }
	public @safe @property @name("_ts") ulong Timestamp(ulong value) { return _ts = value; }

	private string _self;
	public @safe @property @name("_self") string Self() { return _self; }
	public @safe @property @name("_self") string Self(string value) { return _self = value; }

	private string _etag;
	public @safe @property @name("_etag") string ETag() { return _etag; }
	public @safe @property @name("_etag") string ETag(string value) { return _etag = value; }

	private string _colls;
	public @safe @property @name("_colls") string Collections() { return _colls; }
	public @safe @property @name("_colls") string Collections(string value) { return _colls = value; }

	private string _users;
	public @safe @property @name("_users") string Users() { return _users; }
	public @safe @property @name("_users") string Users(string value) { return _users = value; }
}

public Database createDatabases(AzureDocumentDBConnection conn, string ID)
{
	Database db = null;
	requestHTTP(format("https://%s.documents.azure.com/dbs", conn.Account),
		(scope req) {
			req.method = HTTPMethod.POST;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			req.writeJsonBody(["id" : ID]);
		},
		(scope res) {
			deserializeJson!Database(db, res.readJson());
		}
		);
	return db;
}

public DatabaseList listDatabases(AzureDocumentDBConnection conn)
{
	DatabaseList dbl = null;
	requestHTTP(format("https://%s.documents.azure.com/dbs", conn.Account),
		(scope req) {
			req.method = HTTPMethod.GET;
			req.httpVersion = HTTPVersion.HTTP_1_1;
		},
		(scope res) {
			deserializeJson!DatabaseList(dbl, res.readJson());
		}
		);
	return dbl;
}

public Database getDatabase(AzureDocumentDBConnection conn, string RID)
{
	Database db = null;
	requestHTTP(format("https://%s.documents.azure.com/dbs/%s", conn.Account, RID),
		(scope req) {
			req.method = HTTPMethod.GET;
			req.httpVersion = HTTPVersion.HTTP_1_1;
		},
		(scope res) {
			deserializeJson!Database(db, res.readJson());
		}
		);
	return db;
}

public void deleteDatabase(AzureDocumentDBConnection conn, string RID)
{
	requestHTTP(format("https://%s.documents.azure.com/dbs/%s", conn.Account, RID),
		(scope req) {
			req.method = HTTPMethod.DELETE;
			req.httpVersion = HTTPVersion.HTTP_1_1;
		}
	);
}