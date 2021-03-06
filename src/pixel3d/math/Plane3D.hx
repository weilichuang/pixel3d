﻿package pixel3d.math;
import flash.geom.Vector3D;
class Plane3D
{
	public static inline var IS_FRONT : Int = 0;
	public static inline var IS_BACK : Int = 1;
	public static inline var IS_PLANAR : Int = 2;
	public static inline var IS_SPANNING : Int = 3;
	public static inline var IS_CLIPPED : Int = 4;

	public var normal : Vector3D;

	public var d : Float ;

	public function new(n : Vector3D = null, d : Float = 0.)
	{
		this.normal = (n == null) ? new Vector3D() : n;
		this.d = d;
	}

	public inline function setPlane2(point : Vector3D, n : Vector3D) : Void
	{
		normal = n.clone();
		normal.normalize();
		recalculateD(point);
	}

	public inline function setPlane(normal : Vector3D, d : Float) : Void
	{
		this.normal = normal;
		this.d = d;
	}

	public inline function setPlane3(p1 : Vector3D, p2 : Vector3D, p3 : Vector3D) : Void
	{
		var sp0 : Vector3D = p2.subtract(p1);
		var sp1 : Vector3D = p3.subtract(p1);
		normal = sp0.crossProduct(sp1);
		normal.normalize();
		recalculateD(p1);
	}

	/**
	 * 直线的参数方程为p=p0+v*t;//p0(x0,y0,z0)为直线的点,v(vx,vy,vz)为直线的方向
	 * 平面的通用方程a*x+b*y+c*z+d=0;//假设平面的法向量为normal(a,b,c)
	 * 把直线带入平面方程中：
	 * a*(x0+vx*t)+b*(y0+vy*t)+c*(z0+vz*t)+d=0
	 * t=-(a*x0+b*y0+c*z0+d)/(a*vx+b*vy+c*vz);
	 * 即t=-(normal.dot(p0)+d)/normal.dot(v);
	 * 再带入直线的参数方程即可求得交点：
	 * x=x0+vx*t;
	 * y=y0+vy*t;
	 * z=z0+vz*t;
	 * @param lineVect: Vector of the line to intersect with.直线的向量
	 * @param linePoint: Point of the line to intersect with.直线上的一个点
	 * @param outIntersection: Place to store the intersection point, if there is one.交点，如果存在的话
	 * @return Returns true if there was an intersection, false if there was not.如果交点存在，返回true
	 */
	public inline function getIntersectionWithLine(linePoint : Vector3D, lineVect : Vector3D, outIntersection : Vector3D) : Bool
	{
		var t2 : Float = normal.dotProduct(lineVect);
		//两个向量垂直，说明直线与平面平行或者被包含
		if (t2 == 0)
		{
			return false;
		}
		else
		{
			var t : Float = -(normal.dotProduct(linePoint) + d) / t2;
			outIntersection.x = linePoint.x +(lineVect.x * t);
			outIntersection.y = linePoint.y +(lineVect.y * t);
			outIntersection.z = linePoint.z +(lineVect.z * t);
			return true;
		}
	}

	/**
	* Returns where on a line between two points an intersection with this plane happened.
	* @param	point1: Point1 of the line to intersect with.
	* @param	point2: Point2 of the line to intersect with.
	* @return Returns where on a line between two points an intersection with this plane happened.
	* For example, 0.5 is returned if the intersection happened exectly in the middle of the two points.
	*/
	public inline function getKnownIntersectionWithLine(point1 : Vector3D, point2 : Vector3D) : Float
	{
		var vect : Vector3D = point2.subtract(point1);
		var t2 : Float = normal.dotProduct(vect);
		return -((normal.dotProduct(point1) + d) / t2);
	}

	/**
	 * 判断平面与点的关系
	 * @param	point
	 * @return
	 */
	public inline function classifyPointRelation(point : Vector3D) : Int
	{
		var t : Float = normal.dotProduct(point) + d;
		if (t < - MathUtil.ROUNDING_ERROR)
		{
			return IS_BACK;
		}
		else if (t > MathUtil.ROUNDING_ERROR)
		{
			return IS_FRONT;
		}
		else
		{
			return IS_PLANAR;
		}
	}

	// Recalculates the distance from origin by applying
	// a new member point to the plane.
	public inline function recalculateD(mPoint : Vector3D) : Void
	{
		d = -normal.dotProduct(mPoint);
	}

	public inline function getMemberPoint() : Vector3D
	{
		var v:Vector3D = normal.clone();
		v.scaleBy( -d);
		return v;
	}

	// Tests if there is a intersection between this plane and another 是否与其它平面相交
	// @return Returns true if there is a intersection.
	public inline function existsInterSection(other : Plane3D) : Bool
	{
		return other.normal.crossProduct(normal).lengthSquared > MathUtil.ROUNDING_ERROR;
	}

	/**
	 * Intersects this plane with another.
	 * @other
	 * @outLinePoint  相交直线上的一个点
	 * @outLineVect 相交直线的向量
	 * @return Returns true if there is a intersection, false if not.
	 */
	public inline function getIntersectionWithPlane(other : Plane3D, outLinePoint : Vector3D, outLineVect : Vector3D) : Bool
	{
		// get lengths
		var fn00 : Float = normal.length;
		var fn01 : Float = normal.dotProduct(other.normal);
		var fn11 : Float = other.normal.length;
		var det : Float =(fn00 * fn11) -(fn01 * fn01);
		// check det
		det = MathUtil.abs(det);
		if (det <MathUtil.ROUNDING_ERROR)
		{
			return false;
		}
		else
		{
			det = 1.0 / det;
			var fc0 : Float =((fn11 * - d) +(fn01 * other.d)) * det;
			var fc1 : Float =((fn00 * - other.d) +(fn01 * d)) * det;
			outLineVect.x =(normal.y * other.normal.z) -(normal.z * other.normal.y);
			outLineVect.y =(normal.z * other.normal.x) -(normal.x * other.normal.z);
			outLineVect.z =(normal.x * other.normal.y) -(normal.y * other.normal.x);
			outLinePoint.x =(normal.x * fc0) +(other.normal.x * fc1);
			outLinePoint.y =(normal.y * fc0) +(other.normal.y * fc1);
			outLinePoint.z =(normal.z * fc0) +(other.normal.z * fc1);
			// return that we found an intersection
			return true;
		}
	}

	//计算3个平面的交点.
	private static var _linePoint : Vector3D = new Vector3D();
	private static var _lineVect : Vector3D = new Vector3D();
	public inline function getIntersectionWithPlanes(o1 : Plane3D, o2 : Plane3D, outPoint : Vector3D) : Bool
	{
		if (getIntersectionWithPlane(o1, _linePoint, _lineVect))
		{
			return o2.getIntersectionWithLine(_linePoint, _lineVect, outPoint);
		}
		else
		{
			return false;
		}
	}

	public inline function isFrontFacing(lookDirection : Vector3D) : Bool
	{
		return normal.dotProduct(lookDirection) <= 0.0;
	}

	// Returns the distance to a point.  Note that this only
	// works if the normal is Normalized.
	public inline function getDistanceToPoint(point : Vector3D) : Float
	{
		return normal.x * point.x + normal.y * point.y + normal.z * point.z + d;
	}
}
