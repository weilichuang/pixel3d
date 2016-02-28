package pixel3d.mesh;
import pixel3d.mesh.IMesh;
import pixel3d.mesh.IMesh;
import pixel3d.mesh.IMesh;
import pixel3d.mesh.IMesh;
import pixel3d.mesh.IMesh;
import pixel3d.mesh.IMesh;
import pixel3d.mesh.IMesh;
import pixel3d.mesh.IMesh;
import flash.Vector;
import pixel3d.material.ITexture;
import pixel3d.material.Texture;
import pixel3d.math.AABBox;

class Mesh implements IMesh
{
	public var buffers : Vector<MeshBuffer>;
	public var boundingBox : AABBox;
	
	public function new()
	{
		buffers = new Vector<MeshBuffer>();
		boundingBox = new AABBox();
	}
	
	public function getMeshBufferCount() : Int
	{
		return buffers.length;
	}
	
	public function getMeshBuffer(i : Int) : MeshBuffer
	{
		var len:Int = buffers.length;
		if(i <0 || i>= len) return null;
		return buffers[i];
	}
	
	public function getMeshBuffers() : Vector<MeshBuffer>
	{
		return buffers;
	}
	
	public function removeMeshBuffer(buffer : MeshBuffer) : MeshBuffer
	{
		var idx : Int = buffers.indexOf(buffer);
		if(idx != - 1)
		{
			buffers.splice(idx, 1);
			return buffer;
		} 
		else
		{
			return null;
		}
	}
	
	public function removeMeshBufferByIndex(i : Int) : MeshBuffer
	{
		var len:Int = buffers.length;
		if(i <0 || i>= len) return null;
		return buffers.splice(i, 1)[0];
	}
	

	public function getBoundingBox() : AABBox
	{
		return boundingBox;
	}
	
	public function setBoundingBox(box:AABBox):Void
	{
		this.boundingBox = box;
	}
	
	public function recalculateBoundingBox() : Void
	{
		var len : Int = buffers.length;
		if (len > 0)
		{
			boundingBox.resetAABBox(buffers[0].getBoundingBox());
			for(i in 1...len)
			{
				boundingBox.addInternalAABBox(buffers[i].getBoundingBox());
			}
		}
		else
		{
			boundingBox.reset(0, 0, 0);
		}
	}
	
	public function setMaterialFlag(flag : Int, value : Bool) : Void
	{
		var len : Int = buffers.length;
		for(i in 0...len)
		{
			buffers[i].getMaterial().setFlag(flag, value);
		}
	}
	
	public function setMaterialTexture(texture : ITexture, layer : Int = 1) : Void
	{
		if (layer <1 || layer> 2) return;
		var len : Int = buffers.length;
		for(i in 0...len)
		{
			buffers[i].getMaterial().setTexture(texture, layer);
		}
	}
	
	public function addMeshBuffer(buf : MeshBuffer) : Void
	{
		if(buf != null)
		{
			buffers.push(buf);
		}
	}
	
	public function appendMesh(m : IMesh) : Void
	{
		var len : Int = m.getMeshBufferCount();
		for(i in 0...len)
		{
			buffers.push(m.getMeshBuffer(i));
		}
	}
}
