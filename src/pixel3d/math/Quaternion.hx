package pixel3d.math;
import flash.geom.Vector3D;
@:final class Quaternion
{
	public var x : Float;
	public var y : Float;
	public var z : Float;
	public var w : Float;

	public function new(x : Float = 0., y : Float = 0., z : Float = 0., w : Float = 1.)
	{
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	public inline function makeIdentity() : Void
	{
		w = 1.;
		x = 0.;
		y = 0.;
		z = 0.;
	}

	public inline function add(other : Quaternion) : Quaternion
	{
		var tmp : Quaternion = new Quaternion();
		tmp.x = x + other.x;
		tmp.y = y + other.y;
		tmp.z = z + other.z;
		tmp.w = w + other.w;
		return tmp;
	}

	public inline function copy(other : Quaternion) : Void
	{
		x = other.x;
		y = other.y;
		z = other.z;
		w = other.w;
	}

	public inline function clone() : Quaternion
	{
		return new Quaternion(x, y, z, w);
	}

	public inline function incrementBy(other : Quaternion) : Void
	{
		x += other.x;
		y += other.y;
		z += other.z;
		w += other.w;
	}

	public inline function scale(s : Float) : Quaternion
	{
		var tmp : Quaternion = new Quaternion();
		tmp.x = x * s;
		tmp.y = y * s;
		tmp.z = z * s;
		tmp.w = w * s;
		return tmp;
	}

	public inline function scaleBy(s : Float) : Void
	{
		x *= s;
		y *= s;
		z *= s;
		w *= s;
	}

	public inline function multiply(other : Quaternion) : Quaternion
	{
		var tmp : Quaternion = new Quaternion();
		tmp.w =(other.w * w) -(other.x * x) -(other.y * y) -(other.z * z);
		tmp.x =(other.w * x) +(other.x * w) +(other.y * z) -(other.z * y);
		tmp.y =(other.w * y) +(other.y * w) +(other.z * x) -(other.x * z);
		tmp.z =(other.w * z) +(other.z * w) +(other.x * y) -(other.y * x);
		return tmp;
	}

	public inline function multiplyBy(other : Quaternion) : Void
	{
		var tw : Float =(other.w * w) -(other.x * x) -(other.y * y) -(other.z * z);
		var tx : Float =(other.w * x) +(other.x * w) +(other.y * z) -(other.z * y);
		var ty : Float =(other.w * y) +(other.y * w) +(other.z * x) -(other.x * z);
		var tz : Float =(other.w * z) +(other.z * w) +(other.x * y) -(other.y * x);
		x = tx;
		y = ty;
		z = tz;
		w = tw;
	}

	public inline function setMatrix(m : Matrix4) : Void
	{
		var diag = m.m11 + m.m22 + m.m33 + 1;
		if (diag> 0.0 )
		{
			var invScale : Float = MathUtil.invSqrt(diag) * 0.5;
			// get invScale from diagonal
			x =(m.m32 - m.m23) * invScale;
			y =(m.m13 - m.m31) * invScale;
			z =(m.m21 - m.m12) * invScale;
			w = 0.25 / invScale;
		}
		else
		{
			if (m.m11 > m.m22 && m.m11 > m.m33)
			{
				// 1st element of diag is greatest value
				// find scale according to 1st element, and double it
				var invScale : Float = MathUtil.invSqrt(1 + m.m11 - m.m22 - m.m33) * 0.5;
				x = 0.25 / invScale;
				y =(m.m12 + m.m21) * invScale;
				z =(m.m31 + m.m13) * invScale;
				w =(m.m32 - m.m23) * invScale;
			}
			else if (m.m22 > m.m33)
			{
				// 2nd element of diag is greatest value
				// find scale according to 2nd element, and double it
				var invScale : Float = MathUtil.invSqrt(1 + m.m22 - m.m11 - m.m33) * 0.5;
				x =(m.m12 + m.m21) * invScale;
				y = 0.25 / invScale;
				z =(m.m23 + m.m32) * invScale;
				w =(m.m13 - m.m31) * invScale;
			}
			else
			{
				// 3rd element of diag is greatest value
				// find scale according to 3rd element, and double it
				var invScale : Float = MathUtil.invSqrt(1 + m.m33 - m.m11 - m.m22) * 0.5;
				x =(m.m13 + m.m31) * invScale;
				y =(m.m23 + m.m32) * invScale;
				z = 0.25 / invScale;
				w =(m.m21 - m.m12) * invScale;
			}
		}
		normalize();
	}

	public inline function getMatrix(matrix : Matrix4 = null) : Matrix4
	{
		if (matrix == null)
		{
			matrix = new Matrix4();
		}

		matrix.m11 = 1.0 - 2.0 * y * y - 2.0 * z * z;
		matrix.m12 = 2.0 * x * y - 2.0 * z * w;
		matrix.m13 = 2.0 * x * z + 2.0 * y * w;
		matrix.m14 = 0.0;

		matrix.m21 = 2.0 * x * y + 2.0 * z * w;
		matrix.m22 = 1.0 - 2.0 * x * x - 2.0 * z * z;
		matrix.m23 = 2.0 * z * y - 2.0 * x * w;
		matrix.m24 = 0.0;

		matrix.m31 = 2.0 * x * z - 2.0 * y * w;
		matrix.m32 = 2.0 * z * y + 2.0 * x * w;
		matrix.m33 = 1.0 - 2.0 * x * x - 2.0 * y * y;
		matrix.m34 = 0.0;

		matrix.m41 = 0.;
		matrix.m42 = 0.;
		matrix.m43 = 0.;
		matrix.m44 = 1.;
		return matrix;
	}

	public inline function inverse() : Void
	{
		x = - x;
		y = - y;
		z = - z;
	}

	public inline function setAngle(vec : Vector3D) : Void
	{
		var sin = Math.sin;
		var cos = Math.cos;
		var angle : Float;
		angle = vec.x * 0.5;
		var sr : Float = sin(angle);
		var cr : Float = cos(angle);
		angle = vec.y * 0.5;
		var sp : Float = sin(angle);
		var cp : Float = cos(angle);
		angle = vec.z * 0.5;
		var sy : Float = sin(angle);
		var cy : Float = cos(angle);
		var cpcy : Float = cp * cy;
		var spcy : Float = sp * cy;
		var cpsy : Float = cp * sy;
		var spsy : Float = sp * sy;
		x =(sr * cpcy - cr * spsy);
		y =(cr * spcy + sr * cpsy);
		z =(cr * cpsy - sr * spcy);
		w =(cr * cpcy + sr * spsy);
		normalize();
	}

	public inline function normalize() : Void
	{
		var n : Float = x * x + y * y + z * z + w * w;
		var inv : Float = MathUtil.invSqrt(n);
		x *= inv;
		y *= inv;
		z *= inv;
		w *= inv;
	}

	public inline function set(x : Float, y : Float, z : Float, w : Float) : Void
	{
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	// set this quaternion to the result of the interpolation between two quaternions
	public inline function slerp(q1 : Quaternion, q2 : Quaternion, time : Float) : Void
	{
		var q1x : Float;
		var q1y : Float;
		var q1z : Float;
		var q1w : Float;
		var q2x : Float;
		var q2y : Float;
		var q2z : Float;
		var q2w : Float;
		var angle : Float = q1.dotProduct(q2);
		if (angle <0.0)
		{
			q1x = - q1.x;
			q1y = - q1.y;
			q1z = - q1.z;
			q1w = - q1.w;
			angle = - angle;
		}
		else
		{
			q1x = q1.x;
			q1y = q1.y;
			q1z = q1.z;
			q1w = q1.w;
		}

		var scale : Float;
		var invscale : Float;

		if ((angle + 1.0)> 0.05)
		{
			if ((1.0 - angle)>= 0.05) // spherical interpolation
			{
				var theta : Float = Math.acos(angle);
				var invsintheta : Float = 1 / Math.sin(theta);
				scale = Math.sin(theta *(1.0 - time)) * invsintheta;
				invscale = Math.sin(theta * time) * invsintheta;
			}
			else   // linear interploation
			{
				scale = 1.0 - time;
				invscale = time;
			}
			q2x = q2.x;
			q2y = q2.y;
			q2z = q2.z;
			q2w = q2.w;
		}
		else
		{
			q2x = - q1y;
			q2y = q1x;
			q2z = - q1w;
			q2w = q1z;
			scale = Math.sin(MathUtil.PI *(0.5 - time));
			invscale = Math.sin(MathUtil.PI * time);
		}
		x = q1x * scale + q2x * invscale;
		y = q1y * scale + q2y * invscale;
		z = q1z * scale + q2z * invscale;
		w = q1w * scale + q2w * invscale;
	}

	// axis must be unit length
	// angle in radians
	public inline function fromAngleAxis(angle : Float, axis : Vector3D) : Void
	{
		var fHalfAngle : Float = 0.5 * angle;
		var fSin : Float = Math.sin(fHalfAngle);
		w = Math.cos(fHalfAngle);
		x = fSin * axis.x;
		y = fSin * axis.y;
		z = fSin * axis.z;
	}

	public inline function toAngleAxis(angle : Float, axis : Vector3D) : Void
	{
		var scale : Float = Math.sqrt(x * x + y * y + z * z);
		if (scale <MathUtil.ROUNDING_ERROR || w> 1.0 || w <- 1.0)
		{
			angle = 0.0;
			axis.x = 0.0;
			axis.y = 1.0;
			axis.z = 0.0;
		}
		else
		{
			var invscale : Float = 1 / scale;
			angle = 2.0 * Math.cos(w);
			axis.x = x * invscale;
			axis.y = y * invscale;
			axis.z = z * invscale;
		}
	}

	public inline function toEuler(euler : Vector3D) : Void
	{
		var sqw : Float = w * w;
		var sqx : Float = x * x;
		var sqy : Float = y * y;
		var sqz : Float = z * z;
		// heading = rotation about z-axis
		euler.z =(Math.atan2(2.0 *(x * y + z * w),(sqx - sqy - sqz + sqw)));
		// bank = rotation about x-axis
		euler.x =(Math.atan2(2.0 *(y * z + x * w),( - sqx - sqy + sqz + sqw)));
		// attitude = rotation about y-axis
		euler.y = Math.sin(MathUtil.clamp( - 2.0 *(x * z - y * w), - 1.0, 1.0));
	}

	public inline function dotProduct(v2 : Quaternion) : Float
	{
		return (x * v2.x + y * v2.y + z * v2.z + w * v2.w);
	}

	public inline function rotationFromTo(from : Vector3D, to : Vector3D) : Quaternion
	{
		// Based on Stan Melax's article in Game Programming Gems
		// Copy, since cannot modify local
		var v0 : Vector3D = from.clone();
		var v1 : Vector3D = to.clone();
		v0.normalize();
		v1.normalize();
		var d : Float = v0.dotProduct(v1);
		if (d>= 1.0) // If dot == 1, vectors are the same

		{
			makeIdentity();
			v0 = null;
			v1 = null;
			return this;
		}
		else
		{
			var invs : Float = MathUtil.invSqrt((1 + d) * 2);
			var c : Vector3D = v0.crossProduct(v1);
			c.scaleBy(invs);
			x = c.x;
			y = c.y;
			z = c.z;
			w = 0.5 / invs;
			v0 = null;
			v1 = null;
			c = null;
			return this;
		}
	}

	public inline function equals(other : Quaternion) : Bool
	{
		return MathUtil.equals(x, other.x) && MathUtil.equals(y, other.y) && MathUtil.equals(z, other.z) && MathUtil.equals(w, other.w);
	}

	public function toString() : String
	{
		return "[Quaternion(" + Std.int(x*1000)/1000 + "," + Std.int(y*1000)/1000 + "," + Std.int(z*1000)/1000 + "," + Std.int(w*1000)/1000 +")]";
	}
}
