module azured.documentdb.permission;

import azured.documentdb.base;
import azured.documentdb.connection;
import azured.documentdb.utils;
import std.format;
import vibe.d;

public enum PermissionMode
{
	All,
	Read,
}

public class PermissionList : DocDBListBase
{
	private Permission[] _users;
	public @safe @property @name("Permissions") Permission[] Permissions() { return _users; }
	public @safe @property @name("Permissions") Permission[] Permissions(Permission[] value) { return _users = value; }
}

public class Permission : DocDBBase
{
	private string _resource;
	public @safe @property @name("resource") string Resource() { return _resource; }
	public @safe @property @name("resource") string Resource(string value) { return _resource = value; }

	private string _token;
	public @safe @property @name("_token") string Token() { return _token; }
	public @safe @property @name("_token") string Token(string value) { return _token = value; }

	private PermissionMode _permissionMode;
	public @safe @property @name("permissionMode") @byName PermissionMode Token() { return _permissionMode; }
	public @safe @property @name("permissionMode") @byName PermissionMode Token(PermissionMode value) { return _permissionMode = value; }
}

public Permission createPermission(AzureDocumentDBConnection conn, string DatabaseRID, string UserID, Permission perms)
{
	Permission db = null;
	requestHTTP(format("https://%s.documents.azure.com/dbs/%s/users/%s/permissions", conn.Account, DatabaseRID, UserID),
		(scope req) {
			req.method = HTTPMethod.POST;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			Json jObj = serializeToJson!Permission(perms);
			jObj.remove("_rid");
			jObj.remove("_ts");
			jObj.remove("_self");
			jObj.remove("_etag");
			jObj.remove("_token");
			req.writeJsonBody(jObj);
			writeRequiredHeaders(req, conn, "POST", "permissions", "");
		},
		(scope res) {
			deserializeJson!Permission(db, res.readJson());
		}
	);
	return db;
}

public Permission updatePermission(AzureDocumentDBConnection conn, string DatabaseRID, string UserID, Permission perms)
{
	Permission db = null;
	requestHTTP(format("https://%s.documents.azure.com/dbs/%s/users/%s/permissions/%s", conn.Account, DatabaseRID, UserID, perms.RID),
		(scope req) {
			req.method = HTTPMethod.PUT;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			Json jObj = serializeToJson!Permission(perms);
			jObj.remove("_rid");
			jObj.remove("_ts");
			jObj.remove("_self");
			jObj.remove("_etag");
			jObj.remove("_token");
			req.writeJsonBody(jObj);
			writeRequiredHeaders(req, conn, "PUT", "permissions", perms.RID);
		},
		(scope res) {
			deserializeJson!Permission(db, res.readJson());
		}
	);
	return db;
}

public PermissionList listPermissions(AzureDocumentDBConnection conn, string DatabaseRID, string UserID)
{
	PermissionList dbl = null;
	requestHTTP(format("https://%s.documents.azure.com/dbs/%s/users/%s/permissions", conn.Account, DatabaseRID, UserID),
		(scope req) {
			req.method = HTTPMethod.GET;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			writeRequiredHeaders(req, conn, "GET", "permissions", "");
		},
		(scope res) {
			deserializeJson!PermissionList(dbl, res.readJson());
		}
	);
	return dbl;
}

public Permission getPermission(AzureDocumentDBConnection conn, string DatabaseRID, string UserID, string RID)
{
	Permission db = null;
	requestHTTP(format("https://%s.documents.azure.com/dbs/%s/users/%s/permissions/%s", conn.Account, DatabaseRID, UserID, RID),
		(scope req) {
			req.method = HTTPMethod.GET;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			writeRequiredHeaders(req, conn, "GET", "permissions", RID);
		},
		(scope res) {
			deserializeJson!Permission(db, res.readJson());
		}
	);
	return db;
}

public void deletePermission(AzureDocumentDBConnection conn, string DatabaseRID, string UserID, string RID)
{
	requestHTTP(format("https://%s.documents.azure.com/dbs/%s/users/%s/permissions/%s", conn.Account, DatabaseRID, UserID, RID),
		(scope req) {
			req.method = HTTPMethod.DELETE;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			writeRequiredHeaders(req, conn, "DELETE", "permissions", RID);
		}
	);
}
