package pixel3d.utils;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.IBitmapDrawable;
import flash.geom.Matrix;
import flash.Lib;
class BitmapDataUtil
{
	/**
	* 对source执行缩放
	*/
	public static inline function scale(image : BitmapData, value : Float, transparent : Bool, backgroundColor : UInt) : BitmapData
	{
		var w : Int = Std.int(image.width * value);
		var h : Int = Std.int(image.height * value);
		if (w <1) w = 1;
		if (h <1) h = 1;
		var data : BitmapData = new BitmapData(w, h, transparent, backgroundColor);
		var matrix : Matrix = new Matrix();
		matrix.a = value;
		matrix.b = 0;
		matrix.c = 0;
		matrix.d = value;
		data.draw(image, matrix, null, null, null, true);
		matrix = null;
		return data;
	}

	public static function getBitmapData(target:IBitmapDrawable, transparent:Bool=true, backgroundColor : UInt=0x0):BitmapData
	{
		if (target == null ) return null;
		var image:BitmapData = null;
		if (Std.is(target, BitmapData))
		{
			image = Lib.as(target, BitmapData).clone();
		}
		else
		{
			var display : DisplayObject = Lib.as(target, DisplayObject);
			image = new BitmapData(Std.int(display.width), Std.int(display.height), transparent, backgroundColor);
			image.draw(display, null, null, null, null, true);
			display = null;
		}
		return image;
	}
}
