package pixel3d.mesh;
import flash.Vector;
import pixel3d.material.ITexture;
import pixel3d.math.AABBox;
import pixel3d.mesh.IMesh;
import pixel3d.mesh.MeshBuffer;
class AnimatedMesh implements IAnimatedMesh
{
	public var boundingBox : AABBox;
	public var meshes : Vector<IMesh>;
	public var type : Int ;
	public var name : String;
	public function new()
	{
		name = "";
		boundingBox = new AABBox();
		meshes = new Vector<IMesh>();
		type = 0;
	}

	public function getFrameCount() : Int
	{
		return meshes.length;
	}

	public function getMesh(frame : Int, detailLevel : Int = 255, startFrameLoop : Int = - 1, endFrameLoop : Int = - 1) : IMesh
	{
		return meshes[frame];
	}

	public function addMesh(mesh : IMesh) : Void
	{
		if (mesh != null)
		{
			meshes.push(mesh);
		}
	}

	public function recalculateBoundingBox() : Void
	{
		var len : Int = meshes.length;
		if (len> 0)
		{
			boundingBox.resetAABBox(meshes[0].getBoundingBox());
			for (i in 1...len)
			{
				boundingBox.addInternalAABBox(meshes[i].getBoundingBox());
			}
		}
	}
	public function setBoundingBox(box : AABBox) : Void
	{
		boundingBox = box;
	}
	public function getBoundingBox() : AABBox
	{
		return boundingBox;
	}

	public function setMaterialFlag(flag : Int, value : Bool) : Void
	{
	}

	public function setMaterialTexture(texture : ITexture, layer : Int = 1) : Void
	{

	}

	public function getMeshType() : Int
	{
		return type;
	}
	public function getMeshBuffer(i : Int) : MeshBuffer
	{
		return null;
	}
	public function getMeshBuffers() : Vector<MeshBuffer>
	{
		return null;
	}
	public function getMeshBufferCount() : Int
	{
		return 0;
	}
	public function toString() : String
	{
		return name;
	}
}
