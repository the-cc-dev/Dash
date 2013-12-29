/**
 * Defines the static class Config, which handles all configuration options.
 */
module utility.config;
import utility.filepath;

import math.vector;
import core.dgame : GameState;
import graphics.graphics : GraphicsAdapter;
import utility.filepath, utility.output : Verbosity;

import yaml;

import std.array, std.conv, std.string, std.path;

/**
 * Static class which handles the configuration options and YAML interactions.
 */
static class Config
{
static:
public:
	/**
	 * Initialize the configuration settings.
	 */
	void initialize()
	{
		constructor = new Constructor;
		constructor.addConstructorScalar( "!Vector2", &constructVector2 );
		constructor.addConstructorMapping( "!Vector2-Map", &constructVector2 );
		constructor.addConstructorScalar( "!Vector3", &constructVector3 );
		constructor.addConstructorMapping( "!Vector3-Map", &constructVector2 );
		constructor.addConstructorScalar( "!GameState", &constructEnum!GameState );
		constructor.addConstructorScalar( "!Adapter", &constructEnum!GraphicsAdapter );
		constructor.addConstructorScalar( "!Verbosity", &constructEnum!Verbosity );

		config = loadYaml( FilePath.Resources.Config );
	}

	/**
	 * Load a yaml file with the engine-specific mappings.
	 */
	Node loadYaml( string path )
	{
		auto loader = Loader( path );
		loader.constructor = constructor;
		return loader.load();
	}

	/**
	 * Get the element, cast to the given type, at the given path.
	 */
	T get( T )( string path )
	{
		Node current;
		string left;
		string right = path;

		for( current = config; right.length; )
		{
			uint split = right.indexOf( '.' );
			if( split == -1 )
			{
				current = current[ right ];
				right = "";
				break;
			}
			else
			{
				left = right[ 0..split ];
				right = right[ split + 1..$ ];
				current = current[ left ];
			}
		}

		return current.as!T;
	}

	/**
	 * Get element as a file path.
	 */
	string getPath( string path )
	{
		return buildNormalizedPath( FilePath.ResourceHome, get!string( path ) );
	}

private:
	Node config;
	Constructor constructor;
}

Vector!2 constructVector2( ref Node node )
{
	auto result = new Vector!2;

	if( node.isMapping )
	{
		result.values[ 0 ] = node[ "x" ].as!float;
		result.values[ 1 ] = node[ "y" ].as!float;
	}
	else if( node.isScalar )
	{
		string[] vals = node.as!string.split();

		if( vals.length != 2 )
		{
			throw new Exception( "Invalid number of values: " ~ node.as!string );
		}

		result.x = vals[ 0 ].to!float;
		result.y = vals[ 1 ].to!float;
	}

	return result;
}

Vector!3 constructVector3( ref Node node )
{
	auto result = new Vector!3;

	if( node.isMapping )
	{
		result.values[ 0 ] = node[ "x" ].as!float;
		result.values[ 1 ] = node[ "y" ].as!float;
		result.values[ 2 ] = node[ "z" ].as!float;
	}
	else if( node.isScalar )
	{
		string[] vals = node.as!string.split();

		if( vals.length != 3 )
		{
			throw new Exception( "Invalid number of values: " ~ node.as!string );
		}

		result.x = vals[ 0 ].to!float;
		result.y = vals[ 1 ].to!float;
		result.z = vals[ 2 ].to!float;
	}

	return result;
}

T constructEnum( T )( ref Node node ) if( is( T == enum ) )
{
	if( node.isScalar )
	{
		return node.as!string.to!T;
	}
	else
	{
		throw new Exception( "Enum must be represented as a scalar." );
	}
}
