package pixel3d.math;
import flash.geom.Vector3D;

class Vector3DUtil 
{
	/**
	*  Calculate this triangle's weight for each of its three vertices
	*  start by calculating the lengths of its sides
	* @param	v1
	* @param	v2
	* @param	v3
	* @return
	*/
	public static inline function getAngleWeight(v1 : Vector3D, v2 : Vector3D, v3 : Vector3D) : Vector3D
	{
		var asqrt : Float = Vector3D.distance(v2, v3);
		var a : Float = asqrt * asqrt;
		var bsqrt : Float = Vector3D.distance(v1, v3);
		var b : Float = bsqrt * bsqrt;
		var csqrt : Float = Vector3D.distance(v1, v2);
		var c : Float = csqrt * csqrt;
		// use them to find the angle at each vertex
		return new Vector3D(Math.cos((b + c - a) /(2. * bsqrt * csqrt)) ,
		                    Math.cos(( - b + c + a) /(2. * asqrt * csqrt)) ,
		                    Math.cos((b - c + a) /(2. * bsqrt * asqrt)));
	}
	
	/**
	* Returns if this vector interpreted as a point is on a line between two other points.
	* It is assumed that the point is on the line.
	* @param begin Beginning vector to compare between.
	* @param end Ending vector to compare between.
	* @return True if this vector is between begin and end, false if not.
	*/
	public static inline function isBetweenPoints(value:Vector3D,begin : Vector3D, end : Vector3D) : Bool
	{
		var f : Float = Vector3D.distance(begin, end);
		return Vector3D.distance(value, begin) <= f && Vector3D.distance(value, end) <= f;
	}
	
	/**
	* Get the rotations that would make a(0,0,1) direction vector point in the same direction as this direction vector.
	* Thanks to Arras on the Irrlicht forums for this method.  This utility method is very useful for
	* orienting scene nodes towards specific targets.  For example, if this vector represents the difference
	* between two scene nodes, then applying the result of getHorizontalAngle() to one scene node will point
	* it at the other one.
	* Example code:
	* Where target and seeker are of type SceneNode
	* var toTarget:Vector3D=(target.getAbsolutePosition() - seeker.getAbsolutePosition());
	* var requiredRotation:Vector3D = toTarget.getHorizontalAngle();
	* seeker.setRotation(requiredRotation);
	* @return A rotation vector containing the X(pitch) and Y(raw) rotations(in degrees) that when applied to a
	* +Z(e.g. 0, 0, 1) direction vector would make it point in the same direction as this vector. The Z(roll) rotation
	* is always 0, since two Euler rotations are sufficient to point in any given direction.
	*/
	public static inline function getHorizontalAngle(value:Vector3D) : Vector3D
	{
		var angle : Vector3D = new Vector3D();
		
		angle.y = Math.atan2(value.x, value.z) * MathUtil.RADTODEG;
		
		if (angle.y < 0.0) angle.y += 360.;
		if (angle.y >= 360.) angle.y -= 360.;
		
		var z1 : Float = Math.sqrt(value.x * value.x + value.z * value.z);
		angle.x = Math.atan2(z1, value.y) * MathUtil.RADTODEG - 90.0;
		
		if (angle.x < 0.0) angle.x += 360;
		if (angle.x >= 360) angle.x -= 360;
		return angle;
	}
	
	/**
	*  Creates an interpolated vector between this vector and another vector.
	* @param other The other vector to interpolate with.
	* @param d Interpolation value between 0.0f(all the other vector) and 1.0f(all this vector).
	* Note that this is the opposite direction of interpolation to getInterpolated_quadratic()
	* @return An interpolated vector.  This vector is not modified.
	*/
	public static inline function getInterpolated(v1 : Vector3D,v2 : Vector3D, d : Float) : Vector3D
	{
		var inv : Float = 1.0 - d;
		return new Vector3D((v2.x * inv + v1.x * d) , (v2.y * inv + v1.y * d) , (v2.z * inv + v1.z * d));
	}
	
	/**
	* Creates a quadratically interpolated vector between this and two other vectors.
	* @param v2 Second vector to interpolate with.
	* @param v3 Third vector to interpolate with(maximum at 1.0f)
	* @param d Interpolation value between 0.0f(all this vector) and 1.0f(all the 3rd vector).
	* Note that this is the opposite direction of interpolation to getInterpolated() and interpolate()
	* @return An interpolated vector. This vector is not modified.
	*/
	public static inline function getQuadraticInterpolated(v1:Vector3D,v2 : Vector3D, v3 : Vector3D, d : Float) : Vector3D
	{
		// this*(1-d)*(1-d) + 2 * v2 *(1-d) + v3 * d * d;
		var inv : Float = 1.0 - d;
		var mul0 : Float = inv * inv;
		var mul1 : Float = 2.0 * d * inv;
		var mul2 : Float = d * d;
		return new Vector3D((v1.x * mul0 + v2.x * mul1 + v3.x * mul2),
		                    (v1.y * mul0 + v2.y * mul1 + v3.y * mul2) ,
		                    (v1.z * mul0 + v2.z * mul1 + v3.z * mul2));
	}
	
	/**
	* Sets this vector to the linearly interpolated vector between a and b.
	* @param a first vector to interpolate with, maximum at 1.0f
	* @param b second vector to interpolate with, maximum at 0.0f
	* @param d Interpolation value between 0.0f(all vector b) and 1.0f(all vector a)
	* Note that this is the opposite direction of interpolation to getInterpolated_quadratic()
	*/
	public static inline function interpolate(a : Vector3D, b : Vector3D, d : Float,out:Vector3D) : Void
	{
		out.x = (b.x + (a.x - b.x ) * d );
		out.y = (b.y + (a.y - b.y ) * d );
		out.z = (b.z + (a.z - b.z ) * d );
	}
	
	/**
	* Builds a direction vector from(this) rotation vector.
	* This vector is assumed to be a rotation vector composed of 3 Euler angle rotations, in degrees.
	* The implementation performs the same calculations as using a matrix to do the rotation.
	* @param forwards  The direction representing "forwards" which will be rotated by this vector.
	* If you do not provide a direction, then the +Z axis(0, 0, 1) will be assumed to be forwards.
	* @return A direction vector calculated by rotating the forwards direction by the 3 Euler angles
	*(in degrees) represented by this vector.
	*/
	public static inline function rotationToDirection(forwards : Vector3D = null) : Vector3D
	{
		if(forwards == null)
		{
			forwards = new Vector3D(0, 0, 1); 
		}
		var sin = Math.sin;
		var cos = Math.cos;
		var cr : Float = cos(MathUtil.DEGTORAD * forwards.x );
		var sr : Float = sin(MathUtil.DEGTORAD * forwards.x );
		var cp : Float = cos(MathUtil.DEGTORAD * forwards.y );
		var sp : Float = sin(MathUtil.DEGTORAD * forwards.y );
		var cy : Float = cos(MathUtil.DEGTORAD * forwards.z );
		var sy : Float = sin(MathUtil.DEGTORAD * forwards.z );
		var srsp : Float = sr * sp;
		var crsp : Float = cr * sp;
		return new Vector3D((forwards.x *(cp * cy) + forwards.y *(srsp * cy - cr * sy) + forwards.z *(crsp * cy + sr * sy)) ,
		                    (forwards.x *(cp * sy) + forwards.y *(srsp * sy + cr * cy) + forwards.z *(crsp * sy - sr * cy)) ,
		                    (forwards.x *( - sp) + forwards.y *(sr * cp) + forwards.z *(cr * cp))); 
	}
}