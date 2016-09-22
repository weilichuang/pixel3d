package pixel3d.utils;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.system.ApplicationDomain;
import flash.display.DisplayObject;
import flash.Lib;
import flash.utils.ByteArray;
class Reflection
{
	public static inline function createDisplayObject(fullClassName : String, domain : ApplicationDomain = null) : DisplayObject
	{
		return Lib.as(createInstance(fullClassName, domain), DisplayObject);
	}

	public static inline function createSprite(fullClassName : String, domain : ApplicationDomain = null) : Sprite
	{
		return Lib.as(createInstance(fullClassName, domain), Sprite);
	}

	public static inline function createMovieClip(fullClassName : String, domain : ApplicationDomain = null) : MovieClip
	{
		return Lib.as(createInstance(fullClassName, domain), MovieClip);
	}

	public static inline function createByteArray(fullClassName : String, domain : ApplicationDomain = null) : ByteArray
	{
		return Lib.as(createInstance(fullClassName, domain), ByteArray);
	}

	public static inline function createInstance(fullClassName : String, domain : ApplicationDomain = null) : Dynamic
	{
		var assetClass = getClass(fullClassName, domain);
		if (assetClass != null)
		{
			return untyped __new__(assetClass);
		}
		else
		{
			return null;
		}
	}

	public static inline function getClass(fullClassName : String, domain : ApplicationDomain = null) : Dynamic
	{
		if (domain == null)
		{
			domain = ApplicationDomain.currentDomain;
		}
		var assetClass = untyped __as__(domain.getDefinition(fullClassName), Class);
		return assetClass;
	}

	public static inline function getFullClassName(o : Dynamic) : String
	{
		return untyped __global__["flash.utils.getQualifiedClassName"](o);
	}

	public static inline function getClassName(o : Dynamic) : String
	{
		var name : String = getFullClassName(o);
		var lastI : Int = name.lastIndexOf("::");
		if (lastI>= 0)
		{
			name = name.substr(lastI + 2);
		}
		return name;
	}

	public static inline function getPackageName(o : Dynamic) : String
	{
		var name : String = getFullClassName(o);
		var lastI : Int = name.lastIndexOf(".");
		if (lastI>= 0)
		{
			return untyped name.substring(0, lastI);
		}
		else
		{
			return "";
		}
	}
}
