package pixel3d.loader.bsp;
import flash.utils.ByteArray;
import flash.Vector;
import pixel3d.mesh.MeshBuffer;
import pixel3d.mesh.MeshBuffer;
/**
* A Quake3 face
* Because a face may protrude out of the leaf, the same face may be in multiple leaves
*/
class BSPFace
{
	public static var POLYGON_FACE  :Int = 1;
	public static var PATCH_FACE    :Int = 2;
	public static var MESH_FACE     :Int = 3;
	public static var BILLBOARD_FACE:Int = 4;
	
	public var textureID : Int;// The index into the texture array
	public var fogNum : Int;// The index for the effects(or -1 = n/a)
	public var type : Int;// 1=polygon, 2=patch, 3=mesh, 4=billboard
	public var firstVertexIndex : Int;// The index into this face's first vertex
	public var numVertices : Int;// The number of vertices for this face
	public var firstMeshIndex : Int;// The index into the first meshvertex
	public var numMeshIndices : Int;// The number of mesh vertices
	public var lightmapID : Int;// The texture index for the lightmap
	
	//public var lMapCorner0 : Int;// The face's lightmap corner in the image[2]:Int;
	//public var lMapCorner1 : Int;
	//public var lMapSize0 : Int;// The size of the lightmap section[2]:Int;
	//public var lMapSize1 : Int;
	//public var lMapPos0 : Float;// The 3D origin of lightmap[3]:Float
	//public var lMapPos1 : Float;
	//public var lMapPos2 : Float;
	
	//public var lMapBitsets00 : Float;// The 3D space for s and t unit vectors.[2][3]:Float;
	//public var lMapBitsets01 : Float;
	//public var lMapBitsets02 : Float;
	//public var lMapBitsets10 : Float;
	//public var lMapBitsets11 : Float;
	//public var lMapBitsets12 : Float;
	
	//public var vNormal0 : Float;// The face normal.[3]:Float
	//public var vNormal1 : Float;
	//public var vNormal2 : Float;
	
	//patch dimensions
	public var width : Int;// The bezier patch dimensions.[2]:Int;
	public var height : Int;

	public var buffer:MeshBuffer;

	public static inline var sizeof : Int = 104;
	
	public function new()
	{
	}
}
