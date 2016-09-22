package pixel3d.material;
import flash.display.DisplayObject;
import flash.display.StageQuality;
import flash.Lib;
import flash.Vector;
import flash.display.BitmapData;
import flash.display.IBitmapDrawable;
import flash.geom.Matrix;
import pixel3d.math.Vector2i;
import pixel3d.math.MathUtil;
import pixel3d.utils.BitmapDataUtil;
class MipMapLevel
{
	public static inline var MML_1 : Int = 1;
	public static inline var MML_2 : Int = 2;
	public static inline var MML_4 : Int = 4;
	public static inline var MML_8 : Int = 8;
	public static inline var MML_16 : Int = 16;
	public static inline var MML_32 : Int = 32;
	public static inline var MML_64 : Int = 64;
	public static inline var MML_128 : Int = 128;
	public static inline var MML_256 : Int = 256;
	public static inline var MML_512 : Int = 512;
}

class MipMapTexture implements ITexture
{
	private var name : String;
	private var vectors : Vector<Vector<UInt>>;
	private var dimensions : Vector<Vector2i>;
	// 对应每一个Vector数组的长和宽
	private var vectorCount : Int;
	private var useMipMap : Bool;
	private var level : Int;

	/**
	* 要想重新生成新的MipMap必须重新调用setDrawable()
	* @param	?drawable IBitmapDrawable if drawable is BitmapData,it`s transparent must be true;
	* @param	?useMipMap
	* @param	?level when useMipMap true,this active
	*/
	public function new(drawable : IBitmapDrawable = null, useMipMap : Bool = false, level : Int = 32)
	{
		name = "";
		vectors = new Vector<Vector<UInt>>();
		dimensions = new Vector<Vector2i>();
		vectorCount = 0;
		this.useMipMap = useMipMap;
		this.level =(level <1) ? 1 : level;
		setDrawable(drawable);
	}

	public function setDrawable(drawable : IBitmapDrawable) : Void
	{
		if (drawable != null)
		{
			clear();
			var image : BitmapData;
			if (Std.is(drawable, BitmapData))
			{
				image = Lib.as(drawable, BitmapData).clone();
			}
			else
			{
				var display : DisplayObject = Lib.as(drawable, DisplayObject);
				//check display size
				var width : Int =(display.width <1) ? 1 : Std.int(display.width);
				var height : Int =(display.height <1) ? 1 : Std.int(display.height);
				image = new BitmapData(width, height, true, 0x0);
				image.draw(display, null, null, null, null, true);
				display = null;
			}
			vectors[0] = image.getVector(image.rect);
			dimensions[0] = new Vector2i(image.width, image.height);
			vectorCount = 1;
			if (useMipMap)
			{
				generateMipMaps(image);
			}
			image.dispose();
		}
		else
		{
			vectorCount = 0;
		}
	}

	public function getBitmapData():BitmapData
	{
		return null;
	}

	public inline function hasTexture() : Bool
	{
		return vectorCount> 0;
	}

	public inline function getVector() : Vector<UInt>
	{
		//i = MathUtil.clampInt(i, 0, vectorCount - 1);
		return vectors[0];
	}

	public inline function getWidth() : Int
	{
		//i = MathUtil.clampInt(i, 0, vectorCount - 1);
		return dimensions[0].width;
	}

	public inline function getHeight() : Int
	{
		//i = MathUtil.clampInt(i, 0, vectorCount - 1);
		return dimensions[0].height;
	}

	public inline function getDimension() : Vector2i
	{
		//i = MathUtil.clampInt(i, 0, vectorCount - 1);
		return dimensions[0];
	}

	public inline function getVectorCount() : Int
	{
		return vectorCount;
	}

	/**
	* level 最小等级图片的大小
	*/
	private function generateMipMaps(image : BitmapData) : Void
	{
		var min : Int = MathUtil.minInt(image.width, image.height);
		var i : Int = Std.int(min>> 1);
		while (i>= level)
		{
			var data : BitmapData = BitmapDataUtil.scale(image, 1 / MathUtil.pow(2, vectorCount), true, 0x0);
			vectors[vectorCount] = data.getVector(data.rect);
			dimensions[vectorCount] = new Vector2i(data.width, data.height);
			data.dispose();
			data = null;
			vectorCount ++;
			i>>= 1;
		}
	}

	public function clear() : Void
	{
		for (i in 0...vectorCount)
		{
			vectors[i].length = 0;
			vectors[i] = null;
		}
		vectors.length = 0;
		vectorCount = 0;
	}

	public function toString() : String
	{
		return name;
	}

	public function getName():String
	{
		return name;
	}

	public function setName(name:String):Void
	{
		this.name = name;
	}
}
