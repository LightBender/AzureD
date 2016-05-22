module azured.documentdb.collection;

import azured.documentdb.base;
import azured.documentdb.connection;
import azured.documentdb.utils;
import std.format;
import vibe.d;

public enum CollectionIndexingMode
{
	Consistent,
	Lazy,
}

public enum CollectionIndexType
{
	Hash,
	Range,
}

public class CollectionList : DocDBListBase
{
	private Collection[] _collections;
	public @safe @property @name("DocumentCollections") Collection[] Collections() { return _collections; }
	public @safe @property @name("DocumentCollections") Collection[] Collections(Collection[] value) { return _collections = value; }
}

public class Collection : DocDBBase
{
	private string _docs;
	public @safe @property @name("_docs") string Docs() { return _docs; }
	public @safe @property @name("_docs") string Docs(string value) { return _docs = value; }

	private string _sprocs;
	public @safe @property @name("_sprocs") string StoredProcedures() { return _sprocs; }
	public @safe @property @name("_sprocs") string StoredProcedures(string value) { return _sprocs = value; }

	private string _triggers;
	public @safe @property @name("_triggers") string Triggers() { return _triggers; }
	public @safe @property @name("_triggers") string Triggers(string value) { return _triggers = value; }

	private string _udfs;
	public @safe @property @name("_udfs") string UserDefinedFunctions() { return _udfs; }
	public @safe @property @name("_udfs") string UserDefinedFunctions(string value) { return _udfs = value; }

	private string _conflicts;
	public @safe @property @name("_conflicts") string Conflicts() { return _conflicts; }
	public @safe @property @name("_conflicts") string Conflicts(string value) { return _conflicts = value; }

	private CollectionIndexingPolicy _indexingPolicy;
	public @safe @property @name("indexingPolicy") CollectionIndexingPolicy IndexingPolicy() { return _indexingPolicy; }
	public @safe @property @name("indexingPolicy") CollectionIndexingPolicy IndexingPolicy(CollectionIndexingPolicy value) { return _indexingPolicy = value; }
}

public class CollectionIndexingPolicy
{
	private bool _automatic;
	public @safe @property @name("automatic") bool Automatic() { return _automatic; }
	public @safe @property @name("automatic") bool Automatic(bool value) { return _automatic = value; }

	private CollectionIndexingMode _mode;
	public @safe @property @name("indexingMode") @byName CollectionIndexingMode Mode() { return _mode; }
	public @safe @property @name("indexingMode") @byName CollectionIndexingMode Mode(CollectionIndexingMode value) { return _mode = value; }

	private CollectionIndexIncludedPath[] _includedPaths;
	public @safe @property @name("IncludedPaths") CollectionIndexIncludedPath[] IncludedPaths() { return _includedPaths; }
	public @safe @property @name("IncludedPaths") CollectionIndexIncludedPath[] IncludedPaths(CollectionIndexIncludedPath[] value) { return _includedPaths = value; }

	private CollectionIndexExcludedPath[] _excludedPaths;
	public @safe @property @name("ExcludedPaths") CollectionIndexExcludedPath[] ExcludedPaths() { return _excludedPaths; }
	public @safe @property @name("ExcludedPaths") CollectionIndexExcludedPath[] ExcludedPaths(CollectionIndexExcludedPath[] value) { return _excludedPaths = value; }
}

public class CollectionIndexIncludedPath
{
	private CollectionIndexType _type;
	public @safe @property @name("indexType") @byName CollectionIndexType Mode() { return _type; }
	public @safe @property @name("indexType") @byName CollectionIndexType Mode(CollectionIndexType value) { return _type = value; }
	
	private short _numericPrecision;
	public @safe @property @name("NumericPrecision") short NumericPrecision() { return _numericPrecision; }
	public @safe @property @name("NumericPrecision") short NumericPrecision(short value) { return _numericPrecision = value; }
	
	private short _stringPrecision;
	public @safe @property @name("StringPrecision") short StringPrecision() { return _stringPrecision; }
	public @safe @property @name("StringPrecision") short StringPrecision(short value) { return _stringPrecision = value; }
	
	private string _path;
	public @safe @property @name("Path") string Path() { return _path; }
	public @safe @property @name("Path") string Path(string value) { return _path = value; }
}

public class CollectionIndexExcludedPath
{
	private string _path;
	public @safe @property @name("Path") string Path() { return _path; }
	public @safe @property @name("Path") string Path(string value) { return _path = value; }
}

public Collection createCollection(AzureDocumentDBConnection conn, string DatabaseRID, string ID)
{
	Collection db = null;
	requestHTTP(format("https://%s.documents.azure.com/dbs/%s/colls", conn.Account, DatabaseRID),
		(scope req) {
			req.method = HTTPMethod.POST;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			req.writeJsonBody(["id" : ID]);
			writeRequiredHeaders(req, conn, "POST", "colls", "");
		},
		(scope res) {
			deserializeJson!Collection(db, res.readJson());
		}
	);
	return db;
}

public CollectionList listCollections(AzureDocumentDBConnection conn, string DatabaseRID)
{
	CollectionList dbl = null;
	requestHTTP(format("https://%s.documents.azure.com/dbs/%s/colls", conn.Account, DatabaseRID),
		(scope req) {
			req.method = HTTPMethod.GET;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			writeRequiredHeaders(req, conn, "GET", "colls", "");
		},
		(scope res) {
			deserializeJson!CollectionList(dbl, res.readJson());
		}
	);
	return dbl;
}

public Collection getCollection(AzureDocumentDBConnection conn, string DatabaseRID, string RID)
{
	Collection db = null;
	requestHTTP(format("https://%s.documents.azure.com/dbs/%s/colls/%s", conn.Account, DatabaseRID, RID),
		(scope req) {
			req.method = HTTPMethod.GET;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			writeRequiredHeaders(req, conn, "GET", "colls", RID);
		},
		(scope res) {
			deserializeJson!Collection(db, res.readJson());
		}
	);
	return db;
}

public void deleteCollection(AzureDocumentDBConnection conn, string DatabaseRID, string RID)
{
	requestHTTP(format("https://%s.documents.azure.com/dbs/%s/colls/%s", conn.Account, DatabaseRID, RID),
		(scope req) {
			req.method = HTTPMethod.DELETE;
			req.httpVersion = HTTPVersion.HTTP_1_1;
			writeRequiredHeaders(req, conn, "DELETE", "colls", RID);
		}
	);
}