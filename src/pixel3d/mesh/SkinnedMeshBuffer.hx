package pixel3d.mesh;
import pixel3d.material.Material;
import pixel3d.math.AABBox;
import pixel3d.math.Matrix4;
import pixel3d.math.Vertex;
import pixel3d.mesh.MeshBuffer;
import flash.Vector;
class SkinnedMeshBuffer extends MeshBuffer
{
	public var transformation : Matrix4;
	public function new()
	{
		super();
		transformation = new Matrix4();
	}

	override public function clone() : MeshBuffer
	{
		var buffer : SkinnedMeshBuffer = new SkinnedMeshBuffer();
		buffer.material = material.clone();
		buffer.indices = indices.concat();
		var len : Int = vertices.length;
		for(i in 0...len)
		{
			buffer.vertices[i].copy(vertices[i]);
		}
		buffer.boundingBox.copy(boundingBox);
		buffer.transformation.copy(transformation);
		return buffer;
	}
}
