package pixel3d.loader.bsp;

/** class: BSPBrush
* The brushes lump stores a set of brushes, which are in turn used for collision detection.
* Each brush describes a convex volume as defined by its surrounding surfaces.
* There are a total of length / sizeof(brushes) records in the lump,
* where length is the size of the lump itself, as specified in the lump directory.
*/
class BSPBrush
{
	public var firstBrushSide : Int;// The starting brush side for the brush
	public var numBrushSides : Int;// Number of brush sides for the brush
	public var textureID : Int;// The texture index for the brush

	public static inline var sizeof : Int = 12;

	public function new()
	{
	}
}
