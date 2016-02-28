package pixel3d.material;
import flash.display.IBitmapDrawable;
import flash.display.MovieClip;
import flash.errors.InvalidSWFError;
import flash.media.Video;
import flash.utils.ByteArray;
import flash.Lib;
import haxe.ds.StringMap;

/**
 * 动态加载的贴图管理器
 */
class TextureManager 
{
    private var textureHash:StringMap<ITexture>;
	
	public function new() 
	{
		textureHash = new StringMap<ITexture>();
	}
	
	public function removeTexture(name:String):Bool 
	{
		return textureHash.remove(name);
	}
	
	public function addTextureByPath(path:String,name:String):ITexture 
	{
        if(path == null || name == null) return null;
		var texture:ITexture = new LoadingTexture(path);
		textureHash.set(name, texture);
		return texture;
	}
	
	public function addTextureByByteArray(byte:ByteArray,name:String):ITexture 
	{
		if(byte == null || name == null) return null;
		var texture:LoadingTexture = new LoadingTexture();
		texture.loadBytes(byte);
		textureHash.set(name, texture);
		return texture;
	}
	
	public function addTexture(drawable : IBitmapDrawable,name:String):Texture
	{
		if(drawable == null || name == null) return null;
		var texture:Texture = new Texture(drawable);
		textureHash.set(name, texture);
		return texture;
	}
	
	public function addMovieClipTexture(mc : MovieClip,name:String):MovieClipTexture
	{
		if(mc == null || name == null) return null;
		var texture:MovieClipTexture = new MovieClipTexture(mc);
		textureHash.set(name, texture);
		return texture;
	}
	
	public function addVideoTexture(video:Video,name:String):VideoTexture
	{
		if(video == null || name == null) return null;
		var texture:VideoTexture = new VideoTexture(video);
		textureHash.set(name, texture);
		return texture;
	}
	
	public function getTexture(str:String):ITexture
	{
		return textureHash.get(str);
	}
	
	public function exists(str:String):Bool 
	{
		return textureHash.exists(str);
	}
}