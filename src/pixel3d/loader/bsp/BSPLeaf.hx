package pixel3d.loader.bsp;
import flash.utils.ByteArray;
import flash.Vector;
import pixel3d.math.AABBox;

/** 
 * The leafs lump stores the leaves of the map's BSP tree.
 * Each leaf is a convex region that contains, among other things,
 * a cluster index(for determining the other leafs potentially visible from within the leaf),
 * a list of faces(for rendering), and a list of brushes(for collision detection).
 * There are a total of length / sizeof(leaf) records in the lump,
 * where length is the size of the lump itself, as specified in the lump directory.
 */
class BSPLeaf
{
	public var cluster : Int;// The visibility cluster
	public var area : Int;// The area portal
	public var firstLeafFace : Int;// The first index into the leafface array
	public var numFaces : Int;// The number of faces for this leaf
	public var firstLeafBrush : Int;// The first index for into the brushes
	public var numBrushes : Int;// The number of brushes for this leaf
	public var faceIndices : Array<Int>;// all face indices visible from this leaf

	public var brushes : Array<BSPBrush>;// all collidable brushes in this leaf.
	
	public var boundingBox:AABBox;

	public static inline var sizeof : Int = 48;
	
	public function new()
	{
		faceIndices = new Array<Int>();
		
		brushes = new Array<BSPBrush>();
		
		boundingBox = new AABBox();
	}
}
