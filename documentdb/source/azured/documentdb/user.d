module azured.documentdb.user;

import azured.documentdb.base;
import azured.documentdb.connection;
import azured.documentdb.utils;
import std.format;
import vibe.d;

public class UserList : DocDBListBase
{
	private User[] _users;
	public @safe @property @name("Users") User[] Users() { return _users; }
	public @safe @property @name("Users") User[] Users(User[] value) { return _users = value; }
}

public class User : DocDBBase
{
	private string _permissions;
	public @safe @property @name("_permissions") string Permissions() { return _permissions; }
	public @safe @property @name("_permissions") string Permissions(string value) { return _permissions = value; }
}

public User createUser(AzureDocumentDBConnection conn, string DatabaseRID, string ID)
{
	User db = null;
	requestHTTP(format("https://%s.documents.azure.com/dbs/%s/users", conn.Account, DatabaseRID),
		(scope req) {
			req.method = HTTPMethod.POST;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			req.writeJsonBody(["id" : ID]);
			writeRequiredHeaders(req, conn, "POST", "users", "");
		},
		(scope res) {
			deserializeJson!User(db, res.readJson());
		}
	);
	return db;
}

public User updateUser(AzureDocumentDBConnection conn, string DatabaseRID, User user)
{
	User db = null;
	requestHTTP(format("https://%s.documents.azure.com/dbs/%s/users/%s", conn.Account, DatabaseRID, user.RID),
		(scope req) {
			req.method = HTTPMethod.PUT;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			req.writeJsonBody(["id" : user.ID]);
			writeRequiredHeaders(req, conn, "PUT", "users", user.RID);
		},
		(scope res) {
			deserializeJson!User(db, res.readJson());
		}
	);
	return db;
}

public UserList listUsers(AzureDocumentDBConnection conn, string DatabaseRID)
{
	UserList dbl = null;
	requestHTTP(format("https://%s.documents.azure.com/dbs/%s/users", conn.Account, DatabaseRID),
		(scope req) {
			req.method = HTTPMethod.GET;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			writeRequiredHeaders(req, conn, "GET", "users", "");
		},
		(scope res) {
			deserializeJson!UserList(dbl, res.readJson());
		}
	);
	return dbl;
}

public User getUser(AzureDocumentDBConnection conn, string DatabaseRID, string RID)
{
	User db = null;
	requestHTTP(format("https://%s.documents.azure.com/dbs/%s/users/%s", conn.Account, DatabaseRID, RID),
		(scope req) {
			req.method = HTTPMethod.GET;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			writeRequiredHeaders(req, conn, "GET", "users", RID);
		},
		(scope res) {
			deserializeJson!User(db, res.readJson());
		}
	);
	return db;
}

public void deleteUser(AzureDocumentDBConnection conn, string DatabaseRID, string RID)
{
	requestHTTP(format("https://%s.documents.azure.com/dbs/%s/users/%s", conn.Account, DatabaseRID, RID),
		(scope req) {
			req.method = HTTPMethod.DELETE;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			writeRequiredHeaders(req, conn, "DELETE", "users", RID);
		}
	);
}

unittest {
	
	import std.stdio;

	try 
	{
		assert((2+2) == 5);
	}
	catch (Exception eX)
	{
		writeln("catch %s", eX.msg);
	}
	finally {

		writeln("All tests completed.");
	}

}