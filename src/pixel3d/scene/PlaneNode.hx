package pixel3d.scene;
import flash.Vector;
import pixel3d.mesh.MeshBuffer;
import flash.geom.Vector3D;
import pixel3d.math.AABBox;
import pixel3d.math.Vertex;
import pixel3d.material.Material;
import pixel3d.mesh.Mesh;
import pixel3d.mesh.MeshBuffer;
class PlaneNode extends MeshNode
{
	public function new(width : Float = 100, height : Float = 100, segsW : Int = 2, segsH : Int = 2)
	{
		super();
		var mesh:Mesh = new Mesh();
		mesh.addMeshBuffer(build(width, height, segsW, segsH));
		mesh.recalculateBoundingBox();
		this.setMesh(mesh);
	}

	public function build(width : Float, height : Float, segsW : Int, segsH : Int) : MeshBuffer
	{
		var meshBuffer:MeshBuffer = new MeshBuffer();
		if (segsW <1) segsW = 1;
		if (segsH <1) segsH = 1;
		var perH : Float = height / segsH;
		var perW : Float = width / segsW;
		var wid2 : Float = width * 0.5;
		var hei2 : Float = height * 0.5;
		var vertices : Vector<Vertex>= meshBuffer.getVertices();
		var indices : Vector<Int>= meshBuffer.getIndices();
		vertices.length = 0;
		for (i in 0...(segsH + 1))
		{
			for (j in 0...(segsW + 1))
			{
				var vertex : Vertex = new Vertex();
				vertex.x = j * perW - wid2;
				vertex.y = i * perH - hei2;
				vertex.z = 0.;
				vertex.u = j / segsW;
				vertex.v = i / segsH;
				vertices.push(vertex);
			}
		}
		// indices
		indices.length = 0;
		var segsW1 : Int = segsW + 1;
		for (i in 0...segsH)
		{
			for (j in 0...segsW)
			{
				indices.push(i * segsW1 + j);
				indices.push(i * segsW1 + j + 1);
				indices.push((i + 1) * segsW1 + j + 1);
				indices.push(i * segsW1 + j);
				indices.push((i + 1) * segsW1 + j + 1);
				indices.push((i + 1) * segsW1 + j);
			}
		}
		meshBuffer.recalculateBoundingBox();
		return meshBuffer;
	}
}
