package pixel3d.math;
import flash.geom.Vector3D;
@:final class Vertex
{
	//position
	public var x : Float;
	public var y : Float;
	public var z : Float;
	//normal
	public var nx : Float;
	public var ny : Float;
	public var nz : Float;
	//color
	public var r : Float;
	public var g : Float;
	public var b : Float;
	public var a : Float;
	//uv
	public var u : Float;
	public var v : Float;
	
	//uv 2(maybe lightMap or others)
	public var u2 : Float;
	public var v2 : Float;
	public var z2 : Float;
	
	//public var tangent:Vector3D;
	//public var binormal:Vector3D;
	
	public var color(get, set) : UInt;
	public var position(get, set) : Vector3D;
	public var normal(get, set) : Vector3D;
	public var uv(get, set) : Vector2f;
	
	public function new(x : Float = 0, y : Float = 0, z : Float = 0, 
	                     nx : Float = 0, ny : Float = 0, nz : Float = 0, 
	                     c : UInt = 0x555555, u : Float = 0, v : Float = 0)
	{
		this.x = x;
		this.y = y;
		this.z = z;
		this.nx = nx;
		this.ny = ny;
		this.nz = nz;
		this.u = u;
		this.v = v;
		this.color = c;
	}
	
	public inline function setXYZ(x : Float, y : Float, z : Float) : Void
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	private inline function get_position() : Vector3D
	{
		return new Vector3D(x, y, z);
	}
	
	private inline function set_position(v : Vector3D) : Vector3D
	{
		x = v.x;
		y = v.y;
		z = v.z;
		return v;
	}
	
	private inline function get_normal() : Vector3D
	{
		return new Vector3D(nx, ny, nz);
	}
	
	private inline function set_normal(v : Vector3D) : Vector3D
	{
		nx = v.x;
		ny = v.y;
		nz = v.z;
		return v;
	}
	
	private inline function get_uv() : Vector2f
	{
		return new Vector2f(u, v);
	}
	
	private inline function set_uv(tc : Vector2f) : Vector2f
	{
		u = tc.x;
		v = tc.y;
		return tc;
	}
	
	private inline function get_color() : UInt
	{
		return(Std.int(a) <<24 | Std.int(r) <<16 | Std.int(g) <<8 | Std.int(b));
	}
	
	private inline function set_color(c : UInt) : UInt
	{
		a =(c>> 24) & 0xFF;
		r =(c>> 16) & 0xFF;
		g =(c>> 8) & 0xFF;
		b = c & 0xFF;
		return c;
	}
	
	public inline function normalize() : Void
	{
		var sq : Float = nx * nx + ny * ny + nz * nz;
		if(sq <MathUtil.ROUNDING_ERROR ) sq = 0 else sq = MathUtil.invSqrt(sq);
		nx *= sq;
		ny *= sq;
		nz *= sq;
	}
	
	public inline function getQuadraticInterpolated(v2 : Vertex, v3 : Vertex, d : Float) : Vertex
	{
		// this*(1-d)*(1-d) + 2 * v2 *(1-d) + v3 * d * d;
		var inv : Float = 1.0 - d;
		var mul0 : Float = inv * inv;
		var mul1 : Float = 2.0 * d * inv;
		var mul2 : Float = d * d;
		
		var vertex:Vertex = new Vertex();
		vertex.x = this.x * mul0 + v2.x * mul1 + v3.x * mul2;
		vertex.y = this.y * mul0 + v2.y * mul1 + v3.y * mul2;
		vertex.z = this.z * mul0 + v2.z * mul1 + v3.z * mul2;
		vertex.nx = this.nx * mul0 + v2.nx * mul1 + v3.nx * mul2;
		vertex.ny = this.ny * mul0 + v2.ny * mul1 + v3.ny * mul2;
		vertex.nz = this.nz * mul0 + v2.nz * mul1 + v3.nz * mul2;
		vertex.a = MathUtil.clamp(this.a * mul0 + v2.a * mul1 + v3.a * mul2, 0, 255);
		vertex.r = MathUtil.clamp(this.r * mul0 + v2.r * mul1 + v3.r * mul2, 0, 255);
		vertex.g = MathUtil.clamp(this.g * mul0 + v2.g * mul1 + v3.g * mul2, 0, 255);
		vertex.b = MathUtil.clamp(this.b * mul0 + v2.b * mul1 + v3.b * mul2, 0, 255);
		vertex.u = this.u * mul0 + v2.u * mul1 + v3.u * mul2;
		vertex.v = this.v * mul0 + v2.v * mul1 + v3.v * mul2;
		vertex.u2 = this.u2 * mul0 + v2.u2 * mul1 + v3.u2 * mul2;
		vertex.v2 = this.v2 * mul0 + v2.v2 * mul1 + v3.v2 * mul2;
		return vertex;
	}
	
	public inline function copy(c : Vertex) : Void
	{
		x = c.x;
		y = c.y;
		z = c.z;
		nx = c.nx;
		ny = c.ny;
		nz = c.nz;
		a = c.a;
		r = c.r;
		g = c.g;
		b = c.b;
		u = c.u;
		v = c.v;
		u2 = c.u2;
		v2 = c.v2;
		z2 = c.z2;
	}
	
	public inline function clone() : Vertex
	{
		var vertex : Vertex = new Vertex();
		vertex.copy(this);
		return vertex;
	}
	
	public function toString() : String
	{
		return "Vertex(" + x + ',' + y + ',' + z + ',r=' + r + ',g=' + g + ',b=' + b + ',u=' + u + ',v=' + v + ')';
	}
	
	public inline function equals(other : Vertex) : Bool
	{
		return MathUtil.equals(x, other.x) && 
		       MathUtil.equals(y, other.y) && 
			   MathUtil.equals(z, other.z) && 
			   MathUtil.equals(u, other.u) && 
			   MathUtil.equals(v, other.v);
	}
}
