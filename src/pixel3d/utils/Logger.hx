package pixel3d.utils;
import flash.Lib;
import haxe.Log;
class Logger
{
	public static inline var INFORMATION : Int = 0;
	public static inline var WARNING : Int = 1;
	public static inline var ERROR : Int = 2;
	private static var level : Int = INFORMATION;
	public static function getLogLevel() : Int
	{
		return level;
	}
	public static function setLogLevel(lev : Int) : Void
	{
		if (lev <0 || lev> 2)
		{
			return;
		}
		level = lev;
	}
	public static function log(message : Dynamic, lv : Int = 0) : Void
	{
		if (lv <level)
		{
			return;
		}
		Lib.trace(message);
	}
}
