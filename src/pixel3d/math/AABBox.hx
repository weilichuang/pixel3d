package pixel3d.math;
import flash.geom.Vector3D;
import flash.Vector;
class AABBox
{
	public var minX : Float;
	public var minY : Float;
	public var minZ : Float;
	public var maxX : Float;
	public var maxY : Float;
	public var maxZ : Float;
	public function new(min : Vector3D = null, max : Vector3D = null)
	{
		if(min == null || max == null)
		{
			minX = 0.;
			minY = 0.;
			minZ = 0.;
			maxX = 0.;
			maxY = 0.;
			maxZ = 0.;
		} 
		else
		{
			minX = min.x;
			minY = min.y;
			minZ = min.z;
			maxX = max.x;
			maxY = max.y;
			maxZ = max.z;
		}
	}
	public inline function makeIdentity() : Void
	{
		minX = 0.;
		minY = 0.;
		minZ = 0.;
		maxX = 0.;
		maxY = 0.;
		maxZ = 0.;
	}
	public inline function reset(x : Float, y : Float, z : Float) : Void
	{
		minX = x;
		minY = y;
		minZ = z;
		maxX = x;
		maxY = y;
		maxZ = z;
	}
	public inline function resetVector(v : Vector3D) : Void
	{
		minX = v.x;
		minY = v.y;
		minZ = v.z;
		maxX = v.x;
		maxY = v.y;
		maxZ = v.z;
	}
	public inline function resetVertex(v : Vertex) : Void
	{
		minX = v.x;
		minY = v.y;
		minZ = v.z;
		maxX = v.x;
		maxY = v.y;
		maxZ = v.z;
	}
	public inline function resetAABBox(box : AABBox) : Void
	{
		minX = box.minX;
		minY = box.minY;
		minZ = box.minZ;
		maxX = box.maxX;
		maxY = box.maxY;
		maxZ = box.maxZ;
	}
	public inline function copy(other : AABBox) : Void
	{
		minX = other.minX;
		minY = other.minY;
		minZ = other.minZ;
		maxX = other.maxX;
		maxY = other.maxY;
		maxZ = other.maxZ;
	}
	public inline function equals(other : AABBox) : Bool
	{
		return(minX == other.minX && minY == other.minY && minZ == other.minZ &&
		maxX == other.maxX && maxY == other.maxY && maxZ == other.maxZ);
	}
	
	public inline function addInternalVector(point : Vector3D) : Void
	{
		addInternalXYZ(point.x, point.y, point.z);
	}
	
	public inline function addInternalVertex(point : Vertex) : Void
	{
		addInternalXYZ(point.x, point.y, point.z);
	}
	
	public inline function addInternalXYZ(x : Float, y : Float, z : Float) : Void
	{
		if(x> maxX) maxX = x;
		if(y> maxY) maxY = y;
		if(z> maxZ) maxZ = z;
		if(x <minX) minX = x;
		if(y <minY) minY = y;
		if(z <minZ) minZ = z;
	}
	
	public inline function addInternalAABBox(box : AABBox) : Void
	{
		addInternalXYZ(box.maxX, box.maxY, box.maxZ);
		addInternalXYZ(box.minX, box.minY, box.minZ);
	}
	
	public inline function isPointInside(point : Vector3D) : Bool
	{
		return(point.x>= minX && point.x <= maxX && point.y>= minY &&
		point.y <= maxY && point.z>= minZ && point.z <= maxZ);
	}
	
	public inline function isPointTotalInside(point : Vector3D) : Bool
	{
		return(point.x> minX && point.x <maxX && point.y> minY &&
		point.y <maxY && point.z> minZ && point.z <maxZ);
	}
	
	public inline function isVertexInside(point : Vertex) : Bool
	{
		return(point.x>= minX && point.x <= maxX && point.y>= minY &&
		point.y <= maxY && point.z>= minZ && point.z <= maxZ);
	}
	
	public inline function isVertexTotalInside(point : Vertex) : Bool
	{
		return(point.x> minX && point.x <maxX && point.y> minY &&
		point.y <maxY && point.z> minZ && point.z <maxZ);
	}
	
	/**
	* Tests if the box intersects with a line
	* @param linemiddle Center of the line.
	* @param linevect Vector of the line.
	* @param halflength Half length of the line.
	* @return True if there is an intersection, else false.
	*/
	public inline function intersectsWithLine(linemiddle : Vector3D, linevect : Vector3D, halflength : Float) : Bool
	{
		var e : Vector3D = getExtent();
		e.scaleBy(0.5);
		var t : Vector3D = getCenter().subtract(linemiddle);
		if((MathUtil.abs(t.x)> e.x + halflength * MathUtil.abs(linevect.x)) ||
		(MathUtil.abs(t.y)> e.y + halflength * MathUtil.abs(linevect.y)) ||
		(MathUtil.abs(t.z)> e.z + halflength * MathUtil.abs(linevect.z)))
		{
			return false;
		} else
		{
			var r : Float = e.y * Math.abs(linevect.z) + e.z * Math.abs(linevect.y);
			if(MathUtil.abs(t.y * linevect.z - t.z * linevect.y)> r) return false;
			r = e.x * MathUtil.abs(linevect.z) + e.z * MathUtil.abs(linevect.x);
			if(MathUtil.abs(t.z * linevect.x - t.x * linevect.z)> r) return false;
			r = e.x * MathUtil.abs(linevect.y) + e.y * MathUtil.abs(linevect.x);
			if(MathUtil.abs(t.x * linevect.y - t.y * linevect.x)> r) return false;
			return true;
		}
	}
	
	public inline function intersectsWithBox(box : AABBox) : Bool
	{
		return(minX <= box.maxX && minY <= box.maxY && minZ <= box.maxZ &&
		        maxX>= box.minX && maxY>= box.minY && maxZ>= box.minZ);
	}
	
	public inline function isFullInside(box : AABBox) : Bool
	{
		return(minX>= box.minX && minY>= box.minY && minZ>= box.minZ &&
		maxX <= box.maxX && maxY <= box.maxY && maxZ <= box.maxZ);
	}
	
	/**
	* Classifies a relation with a plane.
	* @param plane Plane to classify relation to.
	* @return Returns IS_FRONT if the box is in front of the plane,
	* IS_BACK if the box is behind the plane, and
	* IS_CLIPPED if it is on both sides of the plane.
	*/
	public inline function classifyPlaneRelation(plane : Plane3D) : Int
	{
		var nearPoint : Vector3D = new Vector3D(maxX, maxY, maxZ);
		var farPoint : Vector3D = new Vector3D(minX, minY, minZ);
		if(plane.normal.x> 0)
		{
			nearPoint.x = minX;
			farPoint.x = maxX;
		}
		if(plane.normal.y> 0)
		{
			nearPoint.y = minY;
			farPoint.y = maxY;
		}
		if(plane.normal.z> 0)
		{
			nearPoint.z = minZ;
			farPoint.z = maxZ;
		}
		if(plane.normal.dotProduct(nearPoint) + plane.d> 0)
		{
			return Plane3D.IS_FRONT;
		} else if(plane.normal.dotProduct(farPoint) + plane.d> 0)
		{
			return Plane3D.IS_CLIPPED;
		} else
		{
			return Plane3D.IS_BACK;
		}
	}
	
	
	public inline function getCenter() : Vector3D
	{
		var center : Vector3D = new Vector3D();
		center.x =(maxX + minX) * 0.5;
		center.y =(maxY + minY) * 0.5;
		center.z =(maxZ + minZ) * 0.5;
		return center;
	}
	
	public inline function getExtent() : Vector3D
	{
		var extent : Vector3D = new Vector3D();
		extent.x =(maxX - minX) * 0.5;
		extent.y =(maxY - minY) * 0.5;
		extent.z =(maxZ - minZ) * 0.5;
		return extent;
	}
	
	
	public inline function getEdges() : Vector<Vector3D>
	{
		var _edges : Vector<Vector3D>= new Vector<Vector3D>(8, true);
		for(i in 0...8)
		{
			_edges[i] = new Vector3D();
		}
		var centerX : Float =(maxX + minX) * 0.5;
		var centerY : Float =(maxY + minY) * 0.5;
		var centerZ : Float =(maxZ + minZ) * 0.5;
		var diagX : Float = centerX - maxX;
		var diagY : Float = centerY - maxY;
		var diagZ : Float = centerZ - maxZ;
		var v : Vector3D = _edges[0];
		v.x = centerX + diagX;
		v.y = centerY + diagY;
		v.z = centerZ + diagZ;
		v = _edges[1];
		v.x = centerX + diagX;
		v.y = centerY - diagY;
		v.z = centerZ + diagZ;
		v = _edges[2];
		v.x = centerX + diagX;
		v.y = centerY + diagY;
		v.z = centerZ - diagZ;
		v = _edges[3];
		v.x = centerX + diagX;
		v.y = centerY - diagY;
		v.z = centerZ - diagZ;
		v = _edges[4];
		v.x = centerX - diagX;
		v.y = centerY + diagY;
		v.z = centerZ + diagZ;
		v = _edges[5];
		v.x = centerX - diagX;
		v.y = centerY - diagY;
		v.z = centerZ + diagZ;
		v = _edges[6];
		v.x = centerX - diagX;
		v.y = centerY + diagY;
		v.z = centerZ - diagZ;
		v = _edges[7];
		v.x = centerX - diagX;
		v.y = centerY - diagY;
		v.z = centerZ - diagZ;
		return _edges;
	}
	
	
	public inline function isEmpty() : Bool
	{
		var dX : Float = maxX - minX;
		var dY : Float = maxY - minY;
		var dZ : Float = maxZ - minZ;
		if(dX <0) dX = - dX;
		if(dY <0) dY = - dY;
		if(dZ <0) dZ = - dZ;
		return(dX <MathUtil.ROUNDING_ERROR && dY <MathUtil.ROUNDING_ERROR && dZ <MathUtil.ROUNDING_ERROR);
	}
	
	
	// Get the volume enclosed by the box in cubed units
	public inline function getVolume() : Float
	{
		var e : Vector3D = getExtent();
		return e.x * e.y * e.z;
	}
	
	
	// Get the surface area of the box in squared units
	public inline function getArea() : Float
	{
		var e : Vector3D = getExtent();
		return 2 *(e.x * e.y + e.x * e.z + e.y * e.z);
	}
	
	public inline function repair() : Void
	{
		var t : Float;
		if(minX> maxX)
		{
			t = minX;
			minX = maxX;
			maxX = t;
		}
		if(minY> maxY)
		{
			t = minY;
			minY = maxY;
			maxY = t;
		}
		if(minZ> maxZ)
		{
			t = minZ;
			minZ = maxZ;
			maxZ = t;
		}
	}
	
	public inline function interpolate(a : AABBox, b : AABBox, div : Float) : Void
	{
		var inv : Float = 1.0 - div;
		minX = a.minX * div + b.minX * inv;
		minY = a.minY * div + b.minY * inv;
		minZ = a.minZ * div + b.minZ * inv;
		maxX = a.maxX * div + b.maxX * inv;
		maxY = a.maxY * div + b.maxY * inv;
		maxZ = a.maxZ * div + b.maxZ * inv;
		repair();
	}
	
	public inline function getInterpolated(other : AABBox, div : Float) : AABBox
	{
		var box : AABBox = new AABBox();
		var inv : Float = 1.0 - div;
		box.minX = other.minX * inv + minX * div;
		box.minY = other.minY * inv + minY * div;
		box.minZ = other.minZ * inv + minZ * div;
		box.maxX = other.maxX * inv + maxX * div;
		box.maxY = other.maxY * inv + maxY * div;
		box.maxZ = other.maxZ * inv + maxZ * div;
		box.repair();
		return box;
	}
	
	public inline function clone() : AABBox
	{
		return new AABBox(new Vector3D(minX, minY, minZ) , new Vector3D(maxX, maxY, maxZ));
	}
	
	public function toString() : String
	{
		var s : String = new String("AABBox :");
		s +=("min=" + Std.int(minX * 1000) / 1000) + ",\t" +(Std.int(minY * 1000) / 1000) + ",\t" +(Std.int(minZ * 1000) / 1000) + "\n";
		s +=("max=" + Std.int(maxX * 1000) / 1000) + ",\t" +(Std.int(maxY * 1000) / 1000) + ",\t" +(Std.int(maxZ * 1000) / 1000) + "\n";
		return s;
	}
}
