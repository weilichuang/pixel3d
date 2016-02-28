package pixel3d.mesh.skin;
import flash.geom.Vector3D;
class ScaleKey
{
	public var frame : Int;
	public var scale : Vector3D;
	public function new()
	{
		frame = 0;
		scale = new Vector3D(1,1,1);
	}
	public function clone() : ScaleKey
	{
		var key : ScaleKey = new ScaleKey();
		key.scale = scale.clone();
		key.frame = frame;
		return key;
	}
}
