module azured.documentdb.utils;

import azured.documentdb.connection;
import azured.documentdb.security;
import std.datetime;
import vibe.inet.message;
import vibe.http.client;

public void writeRequiredHeaders(HTTPClientRequest req, AzureDocumentDBConnection conn, string verb, string resourceType, string resourceId)
{
	//Write required headers
	SysTime reqTime = Clock.currTime().toUTC();
	req.headers.addField("Authorization", getAuthorizationToken(conn, verb, resourceType, resourceId, reqTime));
	req.headers.addField("x-ms-date", toRFC822DateTimeString(reqTime));
}