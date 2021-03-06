﻿package pixel3d.math;
@:final class Vector2f
{
	public static inline function distance(v0 : Vector2f, v1 : Vector2f) : Float
	{
		var vx : Float = v0.x - v1.x;
		var vy : Float = v0.y - v1.y;
		return MathUtil.sqrt(vx * vx + vy * vy );
	}

	public static inline function distanceSquared(v0 : Vector2f, v1 : Vector2f) : Float
	{
		var vx : Float = v0.x - v1.x;
		var vy : Float = v0.y - v1.y;
		return (vx * vx + vy * vy );
	}

	public var x : Float;
	public var y : Float;

	public function new(x : Float = 0.0, y : Float = 0.0)
	{
		this.x = x;
		this.y = y;
	}

	public inline function setTo(x : Float, y : Float) : Void
	{
		this.x = x;
		this.y = y;
	}

	public inline function subtract(other : Vector2f) : Vector2f
	{
		return new Vector2f(x - other.x, y - other.y);
	}

	public inline function add(other : Vector2f) : Vector2f
	{
		return new Vector2f(x + other.x, y + other.y);
	}

	public inline function decrementBy(other : Vector2f) : Void
	{
		x -= other.x;
		y -= other.y;
	}

	public inline function incrementBy(other : Vector2f) : Void
	{
		x += other.x;
		y += other.y;
	}

	public inline function negate() : Void
	{
		x = - x;
		y = - y;
	}

	public inline function equals(other : Vector2f) : Bool
	{
		return MathUtil.equals(x,other.x) && MathUtil.equals(y,other.y);
	}

	public inline function scale(s : Float) : Vector2f
	{
		return new Vector2f(s * x, s * y);
	}

	public inline function scaleBy(s : Float) : Void
	{
		x *= s;
		y *= s;
	}

	/**
	 * Normalizes the vector.
	 * In case of the 0 vector the result is still 0, otherwise
	 * the length of the vector will be 1.
	 * @return Reference to this vector after normalization.
	 */
	public inline function normalize() : Vector2f
	{
		var sq : Float = MathUtil.invSqrt(getLengthSquared());
		x *= sq;
		y *= sq;
		return this;
	}

	public inline function dotProduct(other : Vector2f) : Float
	{
		return (x * other.x + y * other.y );
	}

	public inline function getLength() : Float
	{
		return MathUtil.sqrt(x * x + y * y );
	}

	public inline function setLength(newlength : Float) : Void
	{
		normalize();
		scale(newlength);
	}

	public inline function getLengthSquared() : Float
	{
		return (x * x + y * y );
	}

	public inline function getDistanceFrom(other : Vector2f) : Float
	{
		var vx : Float = x - other.x;
		var vy : Float = y - other.y;
		return MathUtil.sqrt(vx * vx + vy * vy );
	}

	public inline function getDistanceFromSquared(other : Vector2f) : Float
	{
		var vx : Float = x - other.x;
		var vy : Float = y - other.y;
		return (vx * vx + vy * vy );
	}

	/**
	 * rotates the point anticlockwise around a center by an amount of degrees.
	 * @param degrees Amount of degrees to rotate by, anticlockwise.
	 * @param center Rotation center.
	 * @return This vector after transformation.
	 */
	public inline function rotateBy(degrees : Float, center : Vector2f) : Void
	{
		degrees *= MathUtil.DEGTORAD;
		var cs : Float = Math.cos(degrees);
		var sn : Float = Math.sin(degrees);
		x -= center.x;
		y -= center.y;
		setTo((x * cs - y * sn),(x * sn + y * cs));
		x += center.x;
		y += center.y;
	}

	/**
	 * Calculates the angle of this vector in degrees in the trigonometric sense.
	 * 0 is to the left(9 o'clock), values increase clockwise.
	 * This method has been suggested by Pr3t3nd3r.
	 * @return Returns a value between 0 and 360.
	 */
	public function getAngleTrig() : Float
	{
		if (x == 0)
			return y <0 ? 270 : 90;
		else if (y == 0)
			return x <0 ? 180 : 0;
		if (y> 0)
			if (x> 0)
				return Math.atan(y / x) * MathUtil.RADTODEG;
			else
				return 180.0 - Math.atan(y / - x) * MathUtil.RADTODEG;
		else if (x> 0)
			return 360.0 - Math.atan( - y / x) * MathUtil.RADTODEG;
		else
			return 180.0 + Math.atan( - y / - x) * MathUtil.RADTODEG;
	}

	/**
	 * Calculates the angle of this vector in degrees in the counter trigonometric sense.
	 * 0 is to the right(3 o'clock), values increase counter-clockwise.
	 * @return Returns a value between 0 and 360.
	 */
	public function getAngle() : Float
	{
		if (y == 0) // corrected thanks to a suggestion by Jox
			return x <0 ? 180 : 0;
		else if (x == 0)
			return y < 0 ? 90 : 270;

		var tmp : Float = y / getLength();
		tmp = Math.atan(MathUtil.sqrt(1 - tmp * tmp) / tmp) * MathUtil.RADTODEG;
		if (x > 0 && y > 0)
			return tmp + 270;
		else if (x > 0 && y < 0)
			return tmp + 90;
		else if (x < 0 && y < 0)
			return 90 - tmp;
		else if (x <0 && y> 0)
			return 270 - tmp;
		return tmp;
	}

	/**
	 * Calculates the angle between this vector and another one in degree.
	 * @param b Other vector to test with.
	 * @return Returns a value between 0 and 90.
	 */
	public function getAngleWith(b : Vector2f) : Float
	{
		var tmp : Float = x * b.x + y * b.y;
		if (tmp == 0.0) return 90.0;
		tmp = tmp * MathUtil.invSqrt((x * x + y * y) * (b.x * b.x + b.y * b.y));
		if (tmp <0.0) tmp = - tmp;
		return Math.atan(MathUtil.sqrt(1 - tmp * tmp) / tmp) * MathUtil.RADTODEG;
	}

	/**
	 * Returns if this vector interpreted as a point is on a line between two other points.
	 * It is assumed that the point is on the line.
	 * @param begin Beginning vector to compare between.
	 * @param end Ending vector to compare between.
	 * @return True if this vector is between begin and end, false if not.
	 */
	public inline function isBetweenPoints(begin : Vector2f, end : Vector2f) : Bool
	{
		if (begin.x != end.x)
		{
			return ((begin.x <= x && x <= end.x) || (begin.x >= x && x >= end.x));
		}
		else
		{
			return ((begin.y <= y && y <= end.y) || (begin.y >= y && y >= end.y));
		}
	}

	/**
	 * Creates an interpolated vector between this vector and another vector.
	 * @param other The other vector to interpolate with.
	 * @param d Interpolation value between 0.0f(all the other vector) and 1.0f(all this vector).
	 * Note that this is the opposite direction of interpolation to getInterpolated_quadratic()
	 * @return An interpolated vector.  This vector is not modified.
	 */
	public inline function getInterpolated(other : Vector2f, d : Float) : Vector2f
	{
		var inv : Float = 1.0 - d;
		return new Vector2f((other.x * inv + x * d), (other.y * inv + y * d));
	}

	/** Creates a quadratically interpolated vector between this and two other vectors.
	 * @param v2 Second vector to interpolate with.
	 * @param v3 Third vector to interpolate with(maximum at 1.0f)
	 * @param d Interpolation value between 0.0f(all this vector) and 1.0f(all the 3rd vector).
	 *          Note that this is the opposite direction of interpolation to getInterpolated() and interpolate()
	 * @return An interpolated vector. This vector is not modified.
	 */
	public inline function getQuadraticInterpolated(v2 : Vector2f, v3 : Vector2f, d : Float) : Vector2f
	{
		// this*(1-d)*(1-d) + 2 * v2 *(1-d) + v3 * d * d;
		var inv : Float = 1.0 - d;
		var mul0 : Float = inv * inv;
		var mul1 : Float = 2.0 * d * inv;
		var mul2 : Float = d * d;
		return new Vector2f((x * mul0 + v2.x * mul1 + v3.x * mul2),
		(y * mul0 + v2.y * mul1 + v3.y * mul2));
	}

	/**
	 * Sets this vector to the linearly interpolated vector between a and b.
	 * @param a first vector to interpolate with, maximum at 1.0f
	 * @param b second vector to interpolate with, maximum at 0.0f
	 * @param d Interpolation value between 0.0f(all vector b) and 1.0f(all vector a)
	 * Note that this is the opposite direction of interpolation to getInterpolated_quadratic()
	 */
	public inline function interpolate(a : Vector2f, b : Vector2f, d : Float) : Void
	{
		x = b.x +(a.x - b.x ) * d ;
		y = b.y +(a.y - b.y ) * d ;
	}

	public inline function copy(other:Vector2f):Void
	{
		this.x = other.x;
		this.y = other.y;
	}

	public inline function clone():Vector2f
	{
		return new Vector2f(x, y);
	}

	public function toString() : String
	{
		return "[Vector2D(" + x + "," + y + ")]";
	}
}
