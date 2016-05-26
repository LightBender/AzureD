module azured.storage.security;

import std.base64;
import std.conv;
import std.datetime;
import std.digest.hmac;
import std.digest.sha;
import std.format;
import std.string : representation;
import std.uni;

import vibe.inet.message;
import vibe.textfilter.urlencode;
import vibe.http.client;

import azured.storage.client;

private string getGenericAuthorizationToken(AzureStorageClient conn, HTTPClientRequest req, string path, string comp, SysTime time)
{
	string cmd5 =  req.headers.get("Content-MD5");
	string ct = req.contentType;
	string ctp = "; " ~ req.contentTypeParameters;
	string crs = "/" ~ conn.Account ~ "/" ~ path;
	if(comp !is null || comp != "") crs ~= "?comp=" ~ comp;
	string chd = "x-ms-date:" ~ toRFC822DateTimeString(time) ~ "\nx-ms-version:" ~ StorageApiVersion;

	string sigstr = format("%s\n%s\n%s\n%s\n%s\n%s",
		to!string(req.method).toUpper(),
		cmd5 is null ? "" : cmd5,
		req.contentTypeParameters is null || "" ? "" : ct ~ ctp,
		toRFC822DateTimeString(time),
		chd,
		crs
	);
	auto hmac = HMAC!SHA256(conn.SharedKey);
	hmac.put(sigstr.representation);
	return urlEncode(format("SharedKeyLite %s:%s", conn.Account, Base64.encode(hmac.finish())));
}

public void writeGenericRequiredHeaders(AzureStorageClient conn, HTTPClientRequest req, string path, string comp = null)
{
	//Write required headers
	SysTime reqTime = Clock.currTime().toUTC();
	req.headers.addField("Authorization", getGenericAuthorizationToken(conn, req, path, comp, reqTime));
	req.headers.addField("x-ms-date", toRFC822DateTimeString(reqTime));
	req.headers.addField("x-ms-version", StorageApiVersion);
}

private string getTableAuthorizationToken(AzureStorageClient conn, string path, string comp, SysTime time)
{
	string crs = "/" ~ conn.Account ~ "/" ~ path;
	if(comp !is null || comp != "") crs ~= "?comp=" ~ comp;
	string chd = "x-ms-date:" ~ toRFC822DateTimeString(time) ~ "\nx-ms-version:" ~ StorageApiVersion;

	string sigstr = format("%s\n%s\n%s",
		toRFC822DateTimeString(time),
		chd,
		crs
	);
	auto hmac = HMAC!SHA256(conn.SharedKey);
	hmac.put(sigstr.representation);
	return urlEncode(format("SharedKeyLite %s:%s", conn.Account, Base64.encode(hmac.finish())));
}

public void writeTableRequiredHeaders(AzureStorageClient conn, HTTPClientRequest req, string path, string comp = null)
{
	//Write required headers
	SysTime reqTime = Clock.currTime().toUTC();
	req.headers.addField("Authorization", getTableAuthorizationToken(conn, path, comp, reqTime));
	req.headers.addField("x-ms-date", toRFC822DateTimeString(reqTime));
	req.headers.addField("x-ms-version", StorageApiVersion);
}