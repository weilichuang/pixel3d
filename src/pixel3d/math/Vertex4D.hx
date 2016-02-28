package pixel3d.math;
@:final class Vertex4D
{
	//position
	public var x : Float ;
	public var y : Float ;
	public var z : Float ;
	public var w : Float ;
	//color
	public var r : Float ;
	public var g : Float ;
	public var b : Float ;
	public var a : Float;
	//uv
	public var u : Float ;
	public var v : Float ;
	
	//可能用于光照图，环境贴图等等
	public var u2 : Float;
	public var v2 : Float;
	public var z2 : Float;
	
	//phong
	public var nx : Float;
	public var ny : Float;
	public var nz : Float;
	
	public var iy:Int;
	public function new()
	{
		x = 0.;
		y = 0.;
		z = 0.;
		w = 0.;
		u = 0.;
		v = 0.;
		r = 0.;
		g = 0.;
		b = 0.;
		a = 255.;
		nx = 0.;
		ny = 0.;
		nz = 0.;
	}
	public inline function copy(c : Vertex4D) : Void
	{
		x = c.x;
		y = c.y;
		z = c.z;
		r = c.r;
		g = c.g;
		b = c.b;
		u = c.u;
		v = c.v;
		nx = c.nx;
		ny = c.ny;
		nz = c.nz;
	}
	public inline function interpolate(vx0 : Vertex4D, vx1 : Vertex4D, t : Float, hasTexture1:Bool = true, hasTexture2:Bool = false) : Void
	{
		x = vx1.x +(vx0.x - vx1.x) * t ;
		y = vx1.y +(vx0.y - vx1.y) * t ;
		z = vx1.z +(vx0.z - vx1.z) * t ;
		w = vx1.w +(vx0.w - vx1.w) * t ;
		r = vx1.r +(vx0.r - vx1.r) * t ;
		g = vx1.g +(vx0.g - vx1.g) * t ;
		b = vx1.b +(vx0.b - vx1.b) * t ;
		if(hasTexture1)
		{
			u = vx1.u +(vx0.u - vx1.u) * t ;
			v = vx1.v +(vx0.v - vx1.v) * t ;
		}
		if(hasTexture2)
		{
			u2 = vx1.u2 +(vx0.u2 - vx1.u2) * t ;
			v2 = vx1.v2 +(vx0.v2 - vx1.v2) * t ;
		}
		/*
		if(false)
		{
		nx = v1.nx +(v0.nx - v1.nx) * t ;
		ny = v1.ny +(v0.ny - v1.ny) * t ;
		nz = v1.nz +(v0.nz - v1.nz) * t ;
		}
		*/
	}
	public inline function interpolateXYZW(v0 : Vertex4D, v1 : Vertex4D, t : Float) : Void
	{
		x = v1.x +(v0.x - v1.x) * t ;
		y = v1.y +(v0.y - v1.y) * t ;
		z = v1.z +(v0.z - v1.z) * t ;
		w = v1.w +(v0.w - v1.w) * t ;
	}
	public inline function getColor() : UInt
	{
		return Std.int(r) <<16 | Std.int(g) <<8 | Std.int(b);
	}
}
