package pixel3d.scene.octree;
import flash.Vector;

class OctreeIndexChunk
{
	public var indices : Vector<Int>;//Array of int, each an index into a vertex list
	public var materialId :Int;//material index that indices are linked to
	public function new()
	{
		indices = new Vector<Int>();
		materialId = - 1;
	}
}
