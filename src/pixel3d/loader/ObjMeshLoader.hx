package pixel3d.loader;
import flash.Lib;
import flash.utils.Endian;
import haxe.Log;
import pixel3d.events.MeshEvent;
import pixel3d.math.Vector2f;
import flash.geom.Vector3D;
import pixel3d.material.Material;
import pixel3d.mesh.IMesh;
import pixel3d.mesh.Mesh;
import pixel3d.mesh.MeshBuffer;
import pixel3d.math.Vertex;
import pixel3d.math.Color;
import pixel3d.math.MathUtil;
import pixel3d.utils.Logger;
import flash.Vector;
import flash.utils.ByteArray;
class ObjMeshLoader extends MeshLoader
{
	public function new(type:Int=0)
	{
		super(type);
	}
	
	override public function loadBytes(data:ByteArray, type:Int):Void
	{
		var mesh:IMesh = null;
		switch(type)
		{
			case 0: 
			{
				mesh = createStaticMesh(data);
			}
		}
		dispatchEvent(new MeshEvent(MeshEvent.COMPLETE, mesh));
	}
	
	private var  materials:Vector<ObjMtl>;
	public function createStaticMesh(file : ByteArray) : IMesh
	{
		if(file == null) return null;
		// create the mesh
		var mesh:Mesh = new Mesh();
		
		materials = new Vector<ObjMtl>();
		var groups:Vector<ObjGroup> = new Vector<ObjGroup>();
		var vertexs : Vector<Vector3D>= new Vector<Vector3D>();
		var tCoords : Vector<Vector2f>= new Vector<Vector2f>();
		var normals : Vector<Vector3D>= new Vector<Vector3D>();
		
		var currentGroup : ObjGroup = null;
		
		// create default material
		var currMtl : ObjMtl = new ObjMtl();
		materials.push(currMtl);
		file.endian = Endian.LITTLE_ENDIAN;
		file.position = 0;
		var content : String = file.readUTFBytes(file.length);
		var lines : Array <String>= content.split("\n");
		if(lines.length <3) return null;
		var len : Int = lines.length;
		for(i in 0...len)
		{
			var word : String = lines[i];
			switch(word.charAt(0))
			{
				case '#' : // comment
				{
				}
				case 'm' : // mtllib(material)
				{
				}
				case 'v' : // v, vn, vt
				{
					switch(word.charAt(1)) // switch second character
					{
						case ' ' : //v 2.298996 194.233002 0.000000 // vertex
						{
							var arr : Array <String>= word.substr(1, word.length).split(" ");
							vertexs.push(new Vector3D(Std.parseFloat(arr[1]) , Std.parseFloat(arr[2]) , Std.parseFloat(arr[3])));
						}
						case 'n' : //vn 0.918556 0.176784 0.353556 // normal
						{
							var arr : Array <String>= word.substr(2, word.length).split(" ");
							normals.push(new Vector3D(Std.parseFloat(arr[1]) , Std.parseFloat(arr[2]) , Std.parseFloat(arr[3])));
						}
						case 't' : //vt 0.834640 0.691170 // texcoord
						{
							var arr : Array <String>= word.substr(2, word.length).split(" ");
							var ux : Float = MathUtil.clamp(Std.parseFloat(arr[1]) , 0.0, 1.0);
							var uy : Float = MathUtil.clamp(1 - Std.parseFloat(arr[2]) , 0.0, 1.0);
							tCoords.push(new Vector2f(ux, uy));
						}
					}
				}
				case 'g' : //g mesh02
				{
					currentGroup = findOrAddGroup(groups,word.substr(2, word.length));
				}
				case 'u' : // usemtl or usemap
				{
					switch(word.substr(0, 6))
					{
						case 'usemtl' : //usemtl  -- default --
						{
							var arr : Array<String>= word.substr(8, word.length).split(" ");
							currMtl = findMtl(materials,arr[1]);
							if(currMtl == null)
							{
								// make new material
								currMtl = newMtl(arr[1]);
							}
						}
						case 'usemap' :
						{
							//TODO 找个新的obj格式，这个obj没有usemap
						}
					}
				}
				case 'f' : //f 8/1/1 2/2/2 1/3/3  // pos/tcoords/normal index
				{
					// face , we only support 3 vertex
					// get vertices for current buffer
					var vertices : Vector<Vertex>= currMtl.meshBuffer.getVertices();
					var indices : Vector<Int>= currMtl.meshBuffer.getIndices();
					var vertexCount : Int = vertices.length;
					var arr : Array<String>= word.substr(2, word.length).split(" ");
					for(i in 0...3)
					{
						var arr1 : Array <String>= arr[i].split("/");
						var vertex : Vertex = new Vertex();
						vertex.x = vertexs[Std.parseInt(arr1[0]) - 1].x;
						vertex.y = vertexs[Std.parseInt(arr1[0]) - 1].y;
						vertex.z = vertexs[Std.parseInt(arr1[0]) - 1].z;
						vertex.u = tCoords[Std.parseInt(arr1[1]) - 1].x;
						vertex.v = tCoords[Std.parseInt(arr1[1]) - 1].y;
						vertex.nx = normals[Std.parseInt(arr1[2]) - 1].x;
						vertex.ny = normals[Std.parseInt(arr1[2]) - 1].y;
						vertex.nz = normals[Std.parseInt(arr1[2]) - 1].z;
						vertices.push(vertex);
					}
					indices.push(vertexCount);
					indices.push(vertexCount + 1);
					indices.push(vertexCount + 2);
				}
			}
		}
		
		len = materials.length;
		for(m in 0...len)
		{
			var buffer : MeshBuffer = materials[m].meshBuffer;
			if(buffer.getVertexCount()> 0 && buffer.getIndexCount()> 0)
			{
				buffer.recalculateBoundingBox();
				mesh.addMeshBuffer(buffer);
			}
		}
		
		mesh.recalculateBoundingBox();
		
		//clean up
		materials = null;
		vertexs = null;
		normals = null;
		tCoords = null;
		
		return mesh;
	}
	
	private function findMtl(materials:Vector<ObjMtl>,matName : String) : ObjMtl
	{
		var len : Int = materials.length;
		for(i in 0...len)
		{
			var mat : ObjMtl = materials[i];
			if(mat.name == matName)
			{
				return mat;
			}
		}
		return null;
	}
	
	private function newMtl(matName : String) : ObjMtl
	{
		var mat : ObjMtl = new ObjMtl();
		mat.setName(matName);
		materials.push(mat);
		return mat;
	}
	
	private function findGroup(groups:Vector<ObjGroup>,groupName : String) : ObjGroup
	{
		var len : Int = groups.length;
		for(i in 0...len)
		{
			var group : ObjGroup = groups[i];
			if(group.name == groupName)
			{
				return group;
			}
		}
		return null;
	}
	
	private function findOrAddGroup(groups:Vector<ObjGroup>,groupName : String) : ObjGroup
	{
		var group : ObjGroup = findGroup(groups,groupName);
		if(group != null)
		{
			// group found, return it
			return group;
		}
		// group not found, create a new group
		group = new ObjGroup();
		group.name = groupName;
		groups.push(group);
		return group;
	}
}
class ObjGroup
{
	public var name : String;
	public function new()
	{
		name = "";
	}
}
class ObjMtl
{
	public var meshBuffer : MeshBuffer;
	public var name : String;
	public function new()
	{
		name = '';
		meshBuffer = new MeshBuffer();
	}
	public function setName(s : String) : Void
	{
		name = s;
		meshBuffer.getMaterial().name = s;
	}
}
