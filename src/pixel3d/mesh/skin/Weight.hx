package pixel3d.mesh.skin;
import flash.geom.Vector3D;

/**
 * A vertex weight
 */
class Weight
{
	/**
	 * Index of the mesh buffer
	 */
	public var bufferID : Int;
	/**
	 * Index of the vertex
	 */
	public var vertexID : Int;
	/**
	 * Weight Strength/Percentage (0-1)
	 */
	public var strength : Float;

	public var moved : Bool;
	public var pos : Vector3D;
	public var normal : Vector3D;
	public function new()
	{
		pos = new Vector3D();
		normal = new Vector3D();
		moved = false;
		strength = 0.0;
	}
}
