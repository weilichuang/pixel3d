package pixel3d.loader.bsp;
import flash.utils.ByteArray;
/** class: Q3BSPBrushSide
* The brushsides lump stores descriptions of brush bounding surfaces.
* There are a total of length / sizeof(brushsides) records in the lump,
* where length is the size of the lump itself, as specified in the lump directory.
*/
class BSPBrushSide
{
	public var plane : Int;// The plane index
	public var textureID : Int;// The texture index
	
	public static inline var sizeof : Int = 8;
	
	public function new()
	{
	}
}
