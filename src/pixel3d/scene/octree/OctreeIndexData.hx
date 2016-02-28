package pixel3d.scene.octree;
import flash.Vector;
class OctreeIndexData
{
	public var indices : Vector<Int>;//Array of int, each an index into a vertex list
	public var size : Int;
	public var maxSize : Int;//total amount of indices
	public function new()
	{
		indices = new Vector<Int>();
		size = 0;
		maxSize = 0;
	}
}
