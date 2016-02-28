package pixel3d.loader;
import flash.display.Loader;
import flash.errors.Error;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.Lib;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.Endian;
import pixel3d.events.MeshErrorEvent;
import pixel3d.events.MeshEvent;
import pixel3d.events.MeshProgressEvent;
import pixel3d.mesh.IMesh;
import pixel3d.mesh.IAnimatedMesh;
import pixel3d.mesh.SkinnedMesh;
import flash.net.URLLoaderDataFormat;

class MeshLoader extends EventDispatcher
{
	public static inline var STATIC_MESH:Int = 0;
	public static inline var KEYFRAME_MESH:Int = 1;
	public static inline var SKINNED_MESH:Int = 2;
	
	private var loader:URLLoader;
	private var type:Int;
	public function new(type:Int)
	{
		super();
		this.type = type;
		loader = new URLLoader();
		loader.dataFormat = URLLoaderDataFormat.BINARY;
	}
	
	public function addListener():Void
	{
		loader.addEventListener(Event.COMPLETE, __loadComplete);
		loader.addEventListener(IOErrorEvent.IO_ERROR, __loadError);
		loader.addEventListener(ProgressEvent.PROGRESS, __loadProgress);
		loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, __loadError);
	}
	
	public function removeListener():Void
	{
		loader.removeEventListener(Event.COMPLETE, __loadComplete);
		loader.removeEventListener(IOErrorEvent.IO_ERROR, __loadError);
		loader.removeEventListener(ProgressEvent.PROGRESS, __loadProgress);
		loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, __loadError);
	}
	
	public function load(url:String):Void
	{
		addListener();
		loader.load(new URLRequest(url));
	}
	
	private function __loadComplete(e:Event):Void
	{
		removeListener();
		var data:ByteArray = Lib.as(loader.data, ByteArray);
		if(data == null)
		{
			dispatchEvent(new MeshErrorEvent(MeshErrorEvent.ERROR, "load failed"));
			return;
		}
		
		data.endian = Endian.LITTLE_ENDIAN;
		data.position = 0;
		loadBytes(data, type);
	}
	
	private function __loadProgress(e:Event):Void
	{
		dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, "load progress"));
	}
	
	private function __loadError(e:Event=null):Void
	{
		removeListener();
		dispatchEvent(new MeshErrorEvent(MeshErrorEvent.ERROR, "load failed"));
	}
	
	/**
	 * 根据data,和type来生成不同类型的IMesh，并且发出一个事件
	 * @param	data
	 * @param	type
	 */
	public function loadBytes(data:ByteArray, type:Int):Void
	{
		//override this
		throw new Error("Not implemented");
	}
}
