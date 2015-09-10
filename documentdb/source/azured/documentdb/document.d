module azured.documentdb.document;

import azured.documentdb.connection;
import azured.documentdb.utils;
import std.format;
import vibe.d;

public abstract class DocumentList(T:Document)
{
	private string _rid;
	public @safe @property @name("_rid") string RID() { return _rid; }
	public @safe @property @name("_rid") string RID(string value) { return _rid = value; }
	
	private int _count;
	public @safe @property @name("_count") int Count() { return _count; }
	public @safe @property @name("_count") int Count(int value) { return _count = value; }

	private T[] _documents;
	public @safe @property @name("Documents") T[] Documents() { return _documents; }
	public @safe @property @name("Documents") T[] Documents(T[] value) { return _documents = value; }
}

public abstract class Document
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
	
	private string _attachments;
	public @safe @property @name("_attachments") string Attachments() { return _attachments; }
	public @safe @property @name("_attachments") string Attachments(string value) { return _attachments = value; }
}

public T createDocument(T:Document)(AzureDocumentDBConnection conn, string DatabaseRID, string CollectionRID, T doc)
{
	T db = null;
	requestHTTP(format("https://%s.documents.azure.com/dbs/%s/colls/%s", conn.Account, DatabaseRID, CollectionRID),
		(scope req) {
			req.method = HTTPMethod.POST;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			Json jObj = serializeJson!T(doc);
			jObj.remove("_rid");
			jObj.remove("_ts");
			jObj.remove("_self");
			jObj.remove("_etag");
			jObj.remove("_attachments");
			req.writeJsonBody(jObj);
			writeRequiredHeaders(req, conn, "POST", "docs", "");
		},
		(scope res) {
			deserializeJson!T(db, res.readJson());
		}
		);
	return db;
}

public T updateDocument(T:Document)(AzureDocumentDBConnection conn, string DatabaseRID, string CollectionRID, T doc)
{
	T db = null;
	requestHTTP(format("https://%s.documents.azure.com/dbs/%s/colls/%s/docs/%s", conn.Account, DatabaseRID, CollectionRID, doc.ID),
		(scope req) {
			req.method = HTTPMethod.PUT;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			Json jObj = serializeJson!T(doc);
			jObj.remove("_rid");
			jObj.remove("_ts");
			jObj.remove("_self");
			jObj.remove("_etag");
			jObj.remove("_attachments");
			req.writeJsonBody(jObj);
			writeRequiredHeaders(req, conn, "PUT", "docs", "");
		},
		(scope res) {
			deserializeJson!T(db, res.readJson());
		}
		);
	return db;
}

public T listDocuments(U, T:DocumentList!U)(AzureDocumentDBConnection conn, string DatabaseRID, string CollectionRID)
{
	T dbl = null;
	requestHTTP(format("https://%s.documents.azure.com/dbs/%s/colls/%s", conn.Account, DatabaseRID, CollectionRID),
		(scope req) {
			req.method = HTTPMethod.GET;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			writeRequiredHeaders(req, conn, "GET", "docs", "");
		},
		(scope res) {
			deserializeJson!T(dbl, res.readJson());
		}
	);
	return dbl;
}

public T getDocument(T:Document)(AzureDocumentDBConnection conn, string DatabaseRID, string CollectionRID, string RID)
{
	T db = null;
	requestHTTP(format("https://%s.documents.azure.com/dbs/%s/colls/%s/docs/%s", conn.Account, DatabaseRID, CollectionRID, RID),
		(scope req) {
			req.method = HTTPMethod.GET;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			writeRequiredHeaders(req, conn, "GET", "docs", RID);
		},
		(scope res) {
			deserializeJson!T(db, res.readJson());
		}
	);
	return db;
}

public void deleteDocument(AzureDocumentDBConnection conn, string DatabaseRID, string CollectionRID, string RID)
{
	requestHTTP(format("https://%s.documents.azure.com/dbs/%s/colls/%s/docs/%s", conn.Account, DatabaseRID, CollectionRID, RID),
		(scope req) {
			req.method = HTTPMethod.DELETE;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			writeRequiredHeaders(req, conn, "DELETE", "docs", RID);
		}
	);
}