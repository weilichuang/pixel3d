package pixel3d.loader.bsp;
import flash.utils.ByteArray;
import pixel3d.math.AABBox;
/**
* The nodes lump stores all of the nodes in the map's BSP tree.
* The BSP tree is used primarily as a spatial subdivision scheme,
* dividing the world into convex regions called leafs.
* The first node in the lump is the tree's root node.
* There are a total of length / sizeof(node) records in the lump,
* where length is the size of the lump itself, as specified in the lump directory.
*
*/
class BSPNode
{
	public var plane : Int;// The index into the planes array

	public var front : Int;// The child index for the front node
	
	public var back : Int;// The child index for the back node
	
    public var boundingBox:AABBox;
	
	public static inline var sizeof : Int = 36;
	
	public function new()
	{
		boundingBox = new AABBox();
	}
}
