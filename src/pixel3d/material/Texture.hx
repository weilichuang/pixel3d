package pixel3d.material;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.IBitmapDrawable;
import flash.Lib;
import flash.Vector;
import pixel3d.math.Vector2i;
class Texture implements ITexture
{
	private var name : String;
	private var vector : Vector<UInt>;
	private var dimension : Vector2i;
	private var vectorCount : Int;
	public function new(drawable : IBitmapDrawable = null)
	{
		name = "";
		dimension = new Vector2i();
		vectorCount = 0;
		setDrawable(drawable);
	}
	
	public function setDrawable(drawable : IBitmapDrawable) : Void
	{
		if(drawable != null)
		{
			clear();
			var image : BitmapData;
			if(Std.is(drawable, BitmapData))
			{
				image = Lib.as(drawable, BitmapData).clone();
			} else
			{
				var display : DisplayObject = Lib.as(drawable, DisplayObject);
				image = new BitmapData(Std.int(display.width) , Std.int(display.height) , true, 0x0);
				image.draw(display, null, null, null, null, true);
				display = null;
			}
			vector = image.getVector(image.rect);
			dimension.width = image.width;
			dimension.height = image.height;
			vectorCount = 1;
		}
	}
	
	public function getVector() : Vector<UInt>
	{
		return vector;
	}
	
	public function getBitmapData():BitmapData
	{
		var bitmapData:BitmapData = new BitmapData(getWidth(), getHeight(), true, 0x0);
		bitmapData.setVector(bitmapData.rect, getVector());
		return bitmapData;
	}
	
	public function setVector(vec:flash.Vector<UInt>,width:Int,height:Int):Void
	{
		this.vector = vec;
		this.dimension.width = width;
		this.dimension.height = height;
		this.vectorCount = 1;
	}
	
	public inline function getWidth() : Int
	{
		return dimension.width;
	}
	
	public inline function getHeight() : Int
	{
		return dimension.height;
	}
	
	public inline function getDimension() : Vector2i
	{
		return dimension;
	}
	
	public inline function getVectorCount() : Int
	{
		return vectorCount;
	}
	
	public inline function hasTexture() : Bool
	{
		return vectorCount> 0;
	}
	
	public function clear() : Void
	{
		if(vector != null) vector.length = 0;
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
