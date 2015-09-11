module azured.documentdb.database;

import azured.documentdb.base;
import azured.documentdb.connection;
import azured.documentdb.utils;
import std.format;
import vibe.d;

public class DatabaseList : DocDBListBase
{
	private Database[] _databases;
	public @safe @property @name("Databases") Database[] Databases() { return _databases; }
	public @safe @property @name("Databases") Database[] Databases(Database[] value) { return _databases = value; }
}

public class Database : DocDBBase
{
	private string _colls;
	public @safe @property @name("_colls") string Collections() { return _colls; }
	public @safe @property @name("_colls") string Collections(string value) { return _colls = value; }

	private string _users;
	public @safe @property @name("_users") string Users() { return _users; }
	public @safe @property @name("_users") string Users(string value) { return _users = value; }
}

public Database createDatabase(AzureDocumentDBConnection conn, string ID)
{
	Database db = null;
	requestHTTP(format("https://%s.documents.azure.com/dbs", conn.Account),
		(scope req) {
			req.method = HTTPMethod.POST;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			req.writeJsonBody(["id" : ID]);
			writeRequiredHeaders(req, conn, "POST", "dbs", "");
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
			writeRequiredHeaders(req, conn, "GET", "dbs", "");
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
			writeRequiredHeaders(req, conn, "GET", "dbs", RID);
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
			writeRequiredHeaders(req, conn, "DELETE", "dbs", RID);
		}
	);
}