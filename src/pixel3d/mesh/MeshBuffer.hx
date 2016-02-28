package pixel3d.mesh;
import flash.Vector;
import pixel3d.material.Material;
import pixel3d.math.AABBox;
import pixel3d.math.Vertex;
class MeshBuffer
{
	public var material : Material;
	public var vertices : Vector<Vertex>;
	public var indices : Vector<Int>;
	public var boundingBox : AABBox;
	
	public function new()
	{
		vertices = new Vector<Vertex>();
		indices = new Vector<Int>();
		boundingBox = new AABBox();
		material = new Material();
	}
	
	public inline function getIndices() : Vector<Int>
	{
		return indices;
	}
	
	public inline function setIndices(indices : Vector<Int>) : Void
	{
		this.indices = indices;
	}
	
	public inline function getVertices() : Vector<Vertex>
	{
		return vertices;
	}
	
	public function recalculateBoundingBox():Void
	{
		var len:Int = vertices.length;
		if (len > 0)
		{
			boundingBox.resetVertex(vertices[0]);
			for (i in 1...len)
			{
				boundingBox.addInternalVertex(vertices[i]);
			}
		}
		else
		{
			boundingBox.reset(0.0, 0.0, 0.0);
		}
	}
	
	public inline function setVertices(vertices : Vector<Vertex>) : Void
	{
		this.vertices = vertices;
		recalculateBoundingBox();
	}
	
	public inline function getIndexCount() : Int
	{
		return indices.length;
	}
	
	public inline function getVertexCount() : Int
	{
		return vertices.length;
	}
	
	public inline function getBoundingBox() : AABBox
	{
		return boundingBox;
	}
	
	public inline function setBoundingBox(box:AABBox):Void
	{
		this.boundingBox = box;
	}

	public inline function getMaterial() : Material
	{
		return material;
	}
	
	public inline function setMaterial(mat : Material) : Void
	{
		if(mat != null)
		{
			this.material = mat;
		}
	}
	
	public inline function getVertex(i : Int) : Vertex
	{
		return vertices[i];
	}

	public function clone() : MeshBuffer
	{
		var buffer : MeshBuffer = new MeshBuffer();
		
		buffer.material = material.clone();
		buffer.indices = indices.concat();
		
		var len : Int = vertices.length;
		for(i in 0...len)
		{
			buffer.vertices[i] = vertices[i].clone();
		}
		
		buffer.boundingBox.copy(boundingBox);
		
		return buffer;
	}
}
