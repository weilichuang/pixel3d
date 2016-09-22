package pixel3d.material;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.Lib;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.Vector;
import flash.display.BitmapData;
import flash.display.IBitmapDrawable;
import flash.geom.Matrix;
import pixel3d.math.Vector2i;
import pixel3d.math.MathUtil;
import pixel3d.utils.Logger;

class LoadingTexture implements ITexture
{
	private var name : String;
	private var vector : Vector<UInt>;
	private var dimension : Vector2i;
	private var vectorCount : Int;
	private var path : String;
	private var loader : Loader;
	private var bitmapData:BitmapData;

	public function new(path : String = "")
	{
		this.name = path;
		dimension = new Vector2i();
		vectorCount = 0;
		loadFile(path);
	}

	public function loadFile(path : String) : Void
	{
		if (path == null || path == "") return;
		this.path = path;

		#if debug
		Logger.log("---" + path + " load Start---");
		#end

		loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, __loadComplete, false, 0, true);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, __loadFail, false, 0, true);
		loader.load(new URLRequest(path));
	}

	private function __loadComplete(e : Event) : Void
	{
		#if debug
		Logger.log("---" + path + " load Complete---");
		#end

		var bitmapData : BitmapData = Lib.as(loader.content, Bitmap).bitmapData;
		vector = bitmapData.getVector(bitmapData.rect);
		dimension.width = Std.int(bitmapData.rect.width);
		dimension.height = Std.int(bitmapData.rect.height);
		vectorCount = 1;
		bitmapData.dispose();
		bitmapData = null;

		loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, __loadComplete);
		loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, __loadFail);
		loader.unload();
		loader = null;
	}

	private function __loadFail(e : Event) : Void
	{
		#if debug
		Logger.log("---" + path + " load Failed---");
		#end

		vectorCount = 0;
		loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, __loadComplete);
		loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, __loadFail);
		loader.unload();
		loader = null;
	}

	public function loadBytes(byte:ByteArray):Void
	{
		loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, __loadComplete);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, __loadFail);
		loader.loadBytes(byte);
	}

	public inline function getVector() : Vector<UInt>
	{
		return vector;
	}

	public function getBitmapData():BitmapData
	{
		if (dimension.width < 1 || dimension.height < 1) return null;
		if (bitmapData == null)
		{
			bitmapData = new BitmapData(getWidth(), getHeight(), true, 0x0);
			bitmapData.setVector(bitmapData.rect, getVector());
		}
		return bitmapData;
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
		if (vector != null) vector.length = 0;
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
