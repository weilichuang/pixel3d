package pixel3d.loader.bsp;
import flash.utils.ByteArray;
import pixel3d.math.AABBox;
/**
* The models lump describes rigid groups of world geometry.
* The first model correponds to the base portion of the map
* while the remaining models correspond to movable portions of the map,
* such as the map's doors, platforms, and buttons.
* Each model has a list of faces and list of brushes;
* these are especially important for the movable parts of the map,
* which(unlike the base portion of the map) do not have BSP trees associated with them.
* There are a total of length / sizeof(models) records in the lump,
* where length is the size of the lump itself, as specified in the lump directory.
*/
class BSPModel
{
	// The min position for the bounding box[3]:Float;
	// The max position for the bounding box.[3]:Float;
	public var boundingBox:AABBox;
	
	public var faceIndex : Int;
	// The first face index in the model
	public var numOfFaces : Int;
	// The number of faces in the model
	public var brushIndex : Int;
	// The first brush index in the model
	public var numOfBrushes : Int;
	// The number brushes for the model
	public static inline var sizeof : Int = 40;
	
	public function new()
	{
		boundingBox = new AABBox();
	}
}
