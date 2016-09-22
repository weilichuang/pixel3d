package pixel3d.math;
@:final class Color
{
	public var a : Float ;
	public var r : Float ;
	public var g : Float ;
	public var b : Float ;

	public var color(get, set) : UInt;

	public function new(r : Float = 0, g : Float = 0, b : Float = 0, a : Float = 255)
	{
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}

	public inline function setRGBA(r : Float, g : Float, b : Float, a : Float) : Void
	{
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}

	public inline function setPercent(pr : Float, pg : Float, pb : Float, pa : Float) : Void
	{
		this.r = MathUtil.clamp(pr, 0, 255);
		this.g = MathUtil.clamp(pg, 0, 255);
		this.b = MathUtil.clamp(pb, 0, 255);
		this.a = MathUtil.clamp(pa, 0, 255);
	}

	private inline function get_color() : UInt
	{
		return (Std.int(a) <<24 | Std.int(r) <<16 | Std.int(g) <<8 | Std.int(b));
	}

	private inline function set_color(color : UInt) : UInt
	{
		a = color>> 24 & 0xFF ;
		r = color>> 16 & 0xFF ;
		g = color>> 8 & 0xFF ;
		b = color & 0xFF ;
		return color;
	}

	public inline function clone() : Color
	{
		return new Color(r, g, b, a);
	}

	public inline function getLuminance() : Float
	{
		return 0.3 * r + 0.59 * g + 0.11 * b;
	}

	public inline function getAverage() : Float
	{
		return (r + g + b ) * 0.333;
	}

	public inline function copy(other : Color) : Void
	{
		r = other.r;
		g = other.g;
		b = other.b;
		a = other.a;
	}

	public inline function getInterpolated(other : Color, d : Float) : Color
	{
		if (d <0) d = 0;
		if (d> 1) d = 1;
		var inv : Float = 1 - d;
		var c : Color = new Color();
		c.a =(a * d + inv * other.a);
		c.r =(r * d + inv * other.r);
		c.g =(g * d + inv * other.g);
		c.b =(b * d + inv * other.b);
		return c;
	}

	public function toString() : String
	{
		return untyped "[Color(" + color.toString(16) + "," + r + "," + g + "," + b + "," + a + ")]";
	}
}
