package pixel3d.material;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.StageQuality;
import flash.errors.Error;
import flash.errors.IOError;
import flash.Lib;
import flash.media.Camera;
import flash.media.Video;
import flash.net.NetStream;
import flash.Vector;
import flash.display.BitmapData;
import flash.display.IBitmapDrawable;
import flash.geom.Matrix;
import pixel3d.math.Vector2i;
import pixel3d.math.MathUtil;

//这个需要重新设计考虑。
class MovieClipTexture implements ITexture
{
	private var name : String;
	private var vector : Vector<UInt>;
	private var dimension : Vector2i;
	private var vectorCount : Int;
	private var mc : MovieClip;
	private var bitmapData : BitmapData;
	/**
	*/
	public function new(mc : MovieClip)
	{
		dimension = new Vector2i();
		vectorCount = 0;
		bitmapData = null;
		name = "";
		setMovieClip(mc);
	}
	public function setMovieClip(mc : MovieClip) : Void
	{
		if(mc == null)
		{
			vectorCount = 0;
			return;
		}
		this.mc = mc;
		dimension.width = Std.int(mc.width);
		dimension.height = Std.int(mc.height);
		name = mc.name;
		vectorCount = 1;
		if(bitmapData != null) bitmapData.dispose();
		bitmapData = new BitmapData(dimension.width, dimension.height, true, 0x0);
		update();
	}
	//当更改mc大小时，请刷新或者重新setMovieClip
	public function refresh() : Void
	{
		dimension.width = Std.int(mc.width);
		dimension.height = Std.int(mc.height);
		name = mc.name;
		if(bitmapData != null) bitmapData.dispose();
		bitmapData = new BitmapData(dimension.width, dimension.height, true, 0x0);
		update();
	}
	public function getMovieClip() : MovieClip
	{
		return mc;
	}
	public function update() : Void
	{
		bitmapData.draw(mc, null, null, null, null, true);
		vector = bitmapData.getVector(bitmapData.rect);
	}
	public function getBitmapData():BitmapData
	{
		return bitmapData;
	}
	public function getVector() : Vector<UInt>
	{
		return vector;
	}
	public function getWidth() : Int
	{
		return dimension.width;
	}
	public function getHeight() : Int
	{
		return dimension.height;
	}
	public function getDimension() : Vector2i
	{
		return dimension;
	}
	public function getVectorCount() : Int
	{
		return vectorCount;
	}
	public function hasTexture() : Bool
	{
		return vectorCount> 0;
	}
	public function clear() : Void
	{
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
