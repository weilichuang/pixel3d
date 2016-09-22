package pixel3d.scene;
import flash.Lib;
import pixel3d.mesh.MeshBuffer;
import pixel3d.mesh.Mesh;
import pixel3d.primitives.CubeObject;

class CubeNode extends MeshNode
{
	private var cube:CubeObject;
	public function new(width : Float, height : Float, depth : Float)
	{
		super(null, true);

		var mesh:Mesh = new Mesh();
		cube = new CubeObject(width, height, depth);
		mesh.addMeshBuffer(cube);
		mesh.recalculateBoundingBox();
		this.setMesh(mesh);
	}

	public function getCube():CubeObject
	{
		return cube;
	}
}
