module azured.documentdb.base;

import vibe.data.serialization;

public abstract class DocDBListBase
{
	private string _rid;
	public @safe @property @name("_rid") string RID() { return _rid; }
	public @safe @property @name("_rid") string RID(string value) { return _rid = value; }
	
	private int _count;
	public @safe @property @name("_count") int Count() { return _count; }
	public @safe @property @name("_count") int Count(int value) { return _count = value; }
}

public abstract class DocDBBase
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
}