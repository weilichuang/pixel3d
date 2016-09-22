package pixel3d.scene.octree;
import flash.Vector;
import pixel3d.math.Vertex;

class OctreeMeshChunk
{
	public var vertices : Vector<Vertex>;
	public var indices : Vector<Int>;//each an index into a vertex list
	public var materialId : Int;//material index that indices are linked to

	public function new()
	{
		materialId = - 1;
		vertices = new Vector<Vertex>();
		indices = new Vector<Int>();
	}
}
