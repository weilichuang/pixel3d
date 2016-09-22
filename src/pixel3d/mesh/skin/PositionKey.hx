package pixel3d.mesh.skin;
import flash.geom.Vector3D;
/**
 * Animation keyframe which describes a new position
 */
class PositionKey
{
	/**
	 *
	 */
	public var frame : Int;
	/**
	 *
	 */
	public var position : Vector3D;

	public function new()
	{
		frame = 0;
		position = new Vector3D();
	}

	public function clone() : PositionKey
	{
		var key : PositionKey = new PositionKey();
		key.position = position.clone();
		key.frame = frame;
		return key;
	}
}
