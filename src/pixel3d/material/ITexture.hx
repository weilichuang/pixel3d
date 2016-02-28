package pixel3d.material;

import flash.display.BitmapData;
import flash.Vector;
import pixel3d.math.Vector2i;

interface ITexture
{
	function getBitmapData():BitmapData;
	function getVector() : Vector<UInt>;
	function getWidth() : Int;
	function getHeight() : Int;
	function getDimension() : Vector2i;
	function getVectorCount() : Int;
	function clear() : Void;
	function hasTexture() : Bool;
	function getName():String;
	function setName(name:String):Void;
}
