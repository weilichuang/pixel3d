package pixel3d.math;
import flash.geom.Rectangle;
class Vector2i
{
	public var width : Int;
	public var height : Int;
	public function new(width : Int = 0, height : Int = 0)
	{
		this.width = width;
		this.height = height;
	}
	public inline function toRect() : Rectangle
	{
		return new Rectangle(0, 0, width, height);
	}
	public function toString() : String
	{
		return "[Dimension(" + width + "," + height + ")";
	}
	public inline function clone() : Vector2i
	{
		return new Vector2i(width, height);
	}
	public inline function copy(other : Vector2i) : Void
	{
		this.width = other.width;
		this.height = other.height;
	}
}
