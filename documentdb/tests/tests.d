import std.stdio;
import std.format;
import vibe.d;
//This appears to be the only import that real matters
import azured.documentdb;
import azured.documentdb.utils;
//import core.exception;

void main()
{
	writeln("Edit source/app.d to start your project.");
	writeln("Let's run some tests!!!");
	authenticationTest();
}

void authenticationTest()
{
	try {
		assert((1+2) == 2);
	}	
	catch (AssertError eX)
	{
		writeln("catch: ", eX.msg);
	}
}

/* unittest {

	assert((1+1) == 2);	
	assert((1+1) == 3);
} 
*/
