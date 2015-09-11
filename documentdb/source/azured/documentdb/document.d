module azured.documentdb.document;

import azured.documentdb.base;
import azured.documentdb.connection;
import azured.documentdb.utils;
import std.format;
import vibe.d;

public abstract class DocumentList(T:Document) : DocDBListBase
{
	private T[] _documents;
	public @safe @property @name("Documents") T[] Documents() { return _documents; }
	public @safe @property @name("Documents") T[] Documents(T[] value) { return _documents = value; }
}

public abstract class Document : DocDBBase
{
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
	requestHTTP(format("https://%s.documents.azure.com/dbs/%s/colls/%s/docs/%s", conn.Account, DatabaseRID, CollectionRID, doc.RID),
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
