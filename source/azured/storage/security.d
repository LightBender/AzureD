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
import azured.storage.blob;

private string getAuthorizationToken(AzureStorageBlobClient conn, HTTPClientRequest req, AzureBlobType blobType, string path, string comp, SysTime time)
{
	string cmd5 =  req.headers.get("Content-MD5");
	string ct = req.contentType;
	string ctp = "; " ~ req.contentTypeParameters;
	string crs = format("/%s/%s", conn.Account, path);
	if(comp !is null && comp != "") crs ~= "?comp=" ~ comp;
	string chd = format("x-ms-blob-type:%sBlob\nx-ms-date:%s\nx-ms-version:%s", toRFC822DateTimeString(time), StorageApiVersion, to!string(blobType));

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

public void writeRequiredHeaders(AzureStorageBlobClient conn, HTTPClientRequest req, AzureBlobType blobType, string path, string comp = null)
{
	//Write required headers
	SysTime reqTime = Clock.currTime().toUTC();
	req.headers.addField("Authorization", getAuthorizationToken(conn, req, blobType, path, comp, reqTime));
	req.headers.addField("x-ms-date", toRFC822DateTimeString(reqTime));
	req.headers.addField("x-ms-version", StorageApiVersion);
	req.headers.addField("x-ms-blob-type", to!string(blobType) ~ "Blob");
}

private string getTableAuthorizationToken(AzureStorageClient conn, string path, string comp, SysTime time)
{
	string crs = format("/%s/%s", conn.Account, path);
	if(comp !is null && comp != "") crs ~= "?comp=" ~ comp;
	string chd = format("x-ms-date:%s\nx-ms-version:%s", toRFC822DateTimeString(time), StorageApiVersion);

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