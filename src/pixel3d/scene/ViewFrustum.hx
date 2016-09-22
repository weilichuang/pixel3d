package pixel3d.scene;
import flash.geom.Vector3D;
import pixel3d.math.AABBox;
import pixel3d.math.Matrix4;
import pixel3d.math.Plane3D;
import pixel3d.math.MathUtil;
import flash.Vector;
class ViewFrustum
{
	public var cameraPosition : Vector3D;
	private var farPlane : Plane3D;
	private var nearPlane : Plane3D;
	private var leftPlane : Plane3D;
	private var rightPlane : Plane3D;
	private var topPlane : Plane3D;
	private var bottomPlane : Plane3D;
	private var boundingBox : AABBox;
	private var _farLeftUpVector : Vector3D;
	private var _farLeftDownVector : Vector3D;
	private var _farRightUpVector : Vector3D;
	private var _farRightDownVector : Vector3D;
	private var _planes : Vector<Plane3D>;
	public function new(matrix : Matrix4 = null)
	{
		// camera position
		cameraPosition = new Vector3D();
		// create planes
		leftPlane = new Plane3D();
		rightPlane = new Plane3D();
		topPlane = new Plane3D();
		bottomPlane = new Plane3D();
		farPlane = new Plane3D();
		nearPlane = new Plane3D();
		_planes = new flash.Vector<Plane3D>(6, true);
		_planes[0] = leftPlane;
		_planes[1] = rightPlane;
		_planes[2] = topPlane;
		_planes[3] = bottomPlane;
		_planes[4] = farPlane;
		_planes[5] = nearPlane;
		boundingBox = new AABBox();
		_farLeftUpVector = new Vector3D();
		_farLeftDownVector = new Vector3D();
		_farRightUpVector = new Vector3D();
		_farRightDownVector = new Vector3D();
		// create the planes from a matrix
		setFrom(matrix);
	}
	public inline function getPlanes() : Vector<Plane3D>
	{
		return _planes;
	}
	public inline function recalculateBoundingBox() : Void
	{
		boundingBox.resetVector(cameraPosition);
		boundingBox.addInternalVector(getFarLeftUp());
		boundingBox.addInternalVector(getFarRightUp());
		boundingBox.addInternalVector(getFarLeftDown());
		boundingBox.addInternalVector(getFarRightDown());
	}
	public inline function getBoundingBox() : AABBox
	{
		return boundingBox;
	}
	public inline function transform(matrix : Matrix4) : Void
	{
		if (matrix != null)
		{
			matrix.transformPlane(leftPlane);
			matrix.transformPlane(rightPlane);
			matrix.transformPlane(topPlane);
			matrix.transformPlane(bottomPlane);
			matrix.transformPlane(nearPlane);
			matrix.transformPlane(farPlane);
			matrix.transformVector(cameraPosition);
			recalculateBoundingBox();
		}
	}
	public inline function getFarLeftUp() : Vector3D
	{
		farPlane.getIntersectionWithPlanes(topPlane, leftPlane, _farLeftUpVector);
		return _farLeftUpVector;
	}
	public inline function getFarLeftDown() : Vector3D
	{
		farPlane.getIntersectionWithPlanes(bottomPlane, leftPlane, _farLeftDownVector);
		return _farLeftDownVector;
	}
	public inline function getFarRightUp() : Vector3D
	{
		farPlane.getIntersectionWithPlanes(topPlane, rightPlane, _farRightUpVector);
		return _farRightUpVector;
	}
	public inline function getFarRightDown() : Vector3D
	{
		farPlane.getIntersectionWithPlanes(bottomPlane, rightPlane, _farRightDownVector);
		return _farRightDownVector;
	}
	public inline function setFrom(mat : Matrix4) : Void
	{
		if (mat != null )
		{
			// left clipping plane
			leftPlane.normal.x = -(mat.m14 + mat.m11);
			leftPlane.normal.y = -(mat.m24 + mat.m21);
			leftPlane.normal.z = -(mat.m34 + mat.m31);
			leftPlane.d = -(mat.m44 + mat.m41);
			var len : Float = MathUtil.invSqrt(leftPlane.normal.lengthSquared);
			leftPlane.normal.scaleBy(len);
			leftPlane.d *= len;
			// right clipping plane
			rightPlane.normal.x = -(mat.m14 - mat.m11);
			rightPlane.normal.y = -(mat.m24 - mat.m21);
			rightPlane.normal.z = -(mat.m34 - mat.m31);
			rightPlane.d = -(mat.m44 - mat.m41);
			len = MathUtil.invSqrt(rightPlane.normal.lengthSquared);
			rightPlane.normal.scaleBy(len);
			rightPlane.d *= len;
			// top clipping plane
			topPlane.normal.x = -(mat.m14 - mat.m12);
			topPlane.normal.y = -(mat.m24 - mat.m22);
			topPlane.normal.z = -(mat.m34 - mat.m32);
			topPlane.d = -(mat.m44 - mat.m42);
			len = MathUtil.invSqrt(topPlane.normal.lengthSquared);
			topPlane.normal.scaleBy(len);
			topPlane.d *= len;
			// bottom clipping plane
			bottomPlane.normal.x = -(mat.m14 + mat.m12);
			bottomPlane.normal.y = -(mat.m24 + mat.m22);
			bottomPlane.normal.z = -(mat.m34 + mat.m32);
			bottomPlane.d = -(mat.m44 + mat.m42);
			len = MathUtil.invSqrt(bottomPlane.normal.lengthSquared);
			bottomPlane.normal.scaleBy(len);
			bottomPlane.d *= len;
			// far clipping plane
			farPlane.normal.x = -(mat.m14 - mat.m13);
			farPlane.normal.y = -(mat.m24 - mat.m23);
			farPlane.normal.z = -(mat.m34 - mat.m33);
			farPlane.d = -(mat.m44 - mat.m43);
			len = MathUtil.invSqrt(farPlane.normal.lengthSquared);
			farPlane.normal.scaleBy(len);
			farPlane.d *= len;
			// near clipping plane
			nearPlane.normal.x = - mat.m13;
			nearPlane.normal.y = - mat.m23;
			nearPlane.normal.z = - mat.m33;
			nearPlane.d = - mat.m43;
			len = MathUtil.invSqrt(nearPlane.normal.lengthSquared);
			nearPlane.normal.scaleBy(len);
			nearPlane.d *= len;
			// make bounding box
			recalculateBoundingBox();
		}
	}
}
