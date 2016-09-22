package pixel3d.mesh.skin;
import pixel3d.math.Quaternion;
/**
 * Animation keyframe which describes a new rotation
 */
class RotationKey
{
	public var frame : Int;

	public var rotation : Quaternion;

	public function new()
	{
		frame = 0;
		rotation = new Quaternion();
	}

	public function clone() : RotationKey
	{
		var key : RotationKey = new RotationKey();
		key.rotation.copy(rotation);
		key.frame = frame;
		return key;
	}
}
