import std.stdio;
import std.format;
import vibe.d;
//This appears to be the only import that real matters
import azured.documentdb;
import azured.documentdb.utils;

void main()
{
	writeln("Edit source/app.d to start your project.");
	writeln("Let's run some tests!!!");
}

unittest {

	assert((1+1) == 2);	
	assert((1+1) == 3);
}