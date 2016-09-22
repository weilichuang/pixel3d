package pixel3d.mesh.skin;
import flash.geom.Vector3D;
import flash.Vector;
import pixel3d.math.Color;
import pixel3d.math.Matrix4;
import pixel3d.math.Quaternion;

class Joint
{
	/**
	 * The name of this joint
	 */
	public var name : String;
	/**
	 * Local matrix of this joint
	 */
	public var localMatrix : Matrix4;
	/**
	 * List of child joints
	 */
	public var children : Vector<Joint>;
	/**
	 * List of attached meshes
	 */
	public var attachedMeshes : Vector<Int>;
	/**
	 * Animation keys causing translation change
	 */
	public var positionKeys : Vector<PositionKey>;
	/**
	 * Animation keys causing scale change
	 */
	public var scaleKeys : Vector<ScaleKey>;
	/**
	 * Animation keys causing rotation change
	 */
	public var rotationKeys : Vector<RotationKey>;
	/**
	 * Skin weights
	 */
	public var weights : Vector<Weight>;

	/**
	 * Unnecessary for loaders, will be overwritten on finalize
	 */
	public var globalMatrix : Matrix4;
	public var globalAnimatedMatrix : Matrix4;
	public var localAnimatedMatrix : Matrix4;
	public var curPosition : Vector3D;
	public var curScale : Vector3D;
	public var curRotation : Quaternion;

	public var globalInversedMatrix : Matrix4;//the x format pre-calculates this

	public var globalSkinningSpace : Bool;

	public var localAnimatedMatrix_Animated:Bool;

	public var positionHint : Int;
	public var scaleHint : Int;
	public var rotationHint : Int;

	public var color : Color;

	//public var numChildren : Int;
	//public var numMesh : Int;
	//public var numPostionKey : Int;
	//public var numScaleKey : Int;
	//public var numRotationKey : Int;
	//public var numWeight : Int;

	public var useAnimationFrom:Joint;

	public function new()
	{
		name = "";

		localMatrix = new Matrix4();
		globalInversedMatrix = new Matrix4();
		globalMatrix = new Matrix4();
		globalAnimatedMatrix = new Matrix4();
		localAnimatedMatrix = new Matrix4();

		curPosition = new Vector3D();
		curScale = new Vector3D();
		curRotation = new Quaternion();

		localAnimatedMatrix_Animated = false;
		globalSkinningSpace = false;

		children = new Vector<Joint>();

		attachedMeshes = new Vector<Int>();

		positionKeys = new Vector<PositionKey>();

		scaleKeys = new Vector<ScaleKey>();

		rotationKeys = new Vector<RotationKey>();

		weights = new Vector<Weight>();

		color = new Color();

		positionHint = - 1;
		scaleHint = - 1;
		rotationHint = - 1;

		//numChildren = 0;
		//numMesh = 0;
		//numPostionKey = 0;
		//numScaleKey = 0;
		//numRotationKey = 0;
		//numWeight = 0;
	}

	/**
	* 更新所有数组的长度，避免每次查找长度
	* 每次更改相关数组的长度后，都需要调用这个
	*/
	//public function refresh() : Void
	//{
	//numChildren = children.length;
	//numMesh = attachedMeshes.length;
	//numPostionKey = positionKeys.length;
	//numScaleKey = scaleKeys.length;
	//numRotationKey = rotationKeys.length;
	//numWeight = weights.length;
	//}

	public function toString() : String
	{
		return name;
	}
}
