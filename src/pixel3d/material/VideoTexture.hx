package pixel3d.material;
import flash.display.DisplayObject;
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

class VideoTexture implements ITexture
{
	private var name : String;
	private var vector : Vector<UInt>;
	private var dimension : Vector2i;
	private var vectorCount : Int;
	private var video : Video;
	private var bitmapData : BitmapData;

	public function new(video : Video)
	{
		dimension = new Vector2i();
		vectorCount = 0;
		bitmapData = null;
		name = "";
		setVideo(video);
	}
	public function setVideo(video : Video) : Void
	{
		if(video == null)
		{
			vectorCount = 0;
			return;
		}
		this.video = video;
		dimension.width = Std.int(video.width);
		dimension.height = Std.int(video.height);
		name = video.name;
		if(bitmapData != null) bitmapData.dispose();
		bitmapData = new BitmapData(dimension.width, dimension.height, true, 0x0);
		update();
	}
	public function getVideo() : Video
	{
		return video;
	}
	//有可能会有安全问题
	public function update() : Void
	{
		try
		{
			bitmapData.draw(video, null, null, null, null, true);
			vector = bitmapData.getVector(bitmapData.rect);
			vectorCount = 1;
		}catch(e : Error)
		{
			vectorCount = 0;
		}
	}
	
	public function getBitmapData():BitmapData
	{
		return bitmapData;
	}
	
	public inline function getVector() : Vector<UInt>
	{
		return vector;
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
