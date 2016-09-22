package pixel3d.mesh.md2;
import flash.Lib;
import flash.Vector;
import pixel3d.material.ITexture;
import pixel3d.material.Material;
import pixel3d.math.AABBox;
import pixel3d.math.MathUtil;
import pixel3d.math.Vertex;
import pixel3d.mesh.AnimatedMeshType;
import pixel3d.mesh.IAnimatedMesh;
import pixel3d.mesh.IMesh;
import pixel3d.mesh.MeshBuffer;
import pixel3d.mesh.KeyFrameData;
import pixel3d.mesh.MeshBuffer;
class AnimatedMeshMD2 implements IAnimatedMesh
{
	private static inline var FRAME_SHIFT : Int = 2;
	private static inline var FRAME_SHIFT_RECIPROCAL : Float = 1 /(1 <<FRAME_SHIFT );

	public var interpolateBuffer : MeshBuffer;// keyframe transformations
	public var frameTransforms : Vector<MD2KeyFrameTransform>;// keyframe vertex data
	public var frameList : Vector<Vector<MD2Vertex>>;// bounding boxes for each keyframe
	public var boxList : Vector<AABBox>;// named animations
	public var keyFrameDatas : Vector<KeyFrameData>;

	public var numFrames : Int;
	public var numTriangles : Int;
	public var name : String;

	private var _tmpFrameData : KeyFrameData;

	public function new()
	{
		this.name = "";
		interpolateBuffer = new MeshBuffer();
		frameTransforms = new Vector<MD2KeyFrameTransform>();
		boxList = new Vector<AABBox>();
		keyFrameDatas = new Vector<KeyFrameData>();
		numFrames = 0;
		numTriangles = 0;
		_tmpFrameData = new KeyFrameData();
	}
	public inline function getFrame(frame : KeyFrameData) : KeyFrameData
	{
		_tmpFrameData.begin = frame.begin <<FRAME_SHIFT;
		_tmpFrameData.end = frame.end <<FRAME_SHIFT;
		_tmpFrameData.fps = frame.fps <<FRAME_SHIFT;
		return _tmpFrameData;
	}
	public function getMeshBuffer(i : Int) : MeshBuffer
	{
		return interpolateBuffer;
	}
	public function getMeshBuffers() : Vector<MeshBuffer>
	{
		return null;
	}
	public function getMaterial() : Material
	{
		return interpolateBuffer.getMaterial();
	}
	public function getMeshBufferCount() : Int
	{
		return 1;
	}
	public function getIndices() : Vector<Int>
	{
		return interpolateBuffer.getIndices();
	}
	public function getIndexCount() : Int
	{
		return interpolateBuffer.getIndexCount();
	}
	public function getAnimationCount() : Int
	{
		return keyFrameDatas.length;
	}
	public function getFrameCount() : Int
	{
		return numFrames <<FRAME_SHIFT;
	}
	public function getAnimationName(i : Int) : String
	{
		var len:Int = keyFrameDatas.length;
		if (i <0 || i>= len) return null;
		return keyFrameDatas[i].name;
	}
	public function updateInterpolationBuffer(frame : Int, startFrameLoop : Int, endFrameLoop : Int) : Void
	{
		var firstFrame : Int, secondFrame : Int;
		var div : Float;
		var normalTable : Vector<Float>= VERTEX_NORMAL_TABLE;
		if (endFrameLoop == startFrameLoop)
		{
			firstFrame = frame>> FRAME_SHIFT;
			firstFrame = MathUtil.minInt(numFrames - 1, firstFrame);
			var targetVertexs : Vector<Vertex> = interpolateBuffer.getVertices();
			var firstVertexs : Vector<MD2Vertex> = frameList[firstFrame];
			var target : Vertex ;
			var first : MD2Vertex;
			var transform : MD2KeyFrameTransform;
			var count : Int = frameList[firstFrame].length;
			for (i in 0...count)
			{
				target = targetVertexs[i];
				first = firstVertexs[i];
				transform = frameTransforms[firstFrame];
				target.x = first.x * transform.sx + transform.tx;
				target.y = first.y * transform.sy + transform.ty;
				target.z = first.z * transform.sz + transform.tz;
				target.nx = normalTable[first.normalIdx * 3];
				target.ny = normalTable[first.normalIdx * 3 + 1];
				target.nz = normalTable[first.normalIdx * 3 + 2];
			}
			//update bounding box
			interpolateBuffer.getBoundingBox().resetAABBox(boxList[firstFrame]);
		}
		else
		{
			//key frames
			var s : Int = startFrameLoop>> FRAME_SHIFT;
			var e : Int = endFrameLoop>> FRAME_SHIFT;
			firstFrame = frame>> FRAME_SHIFT;
			secondFrame =(firstFrame + 1> e) ? s : firstFrame + 1;
			firstFrame = MathUtil.minInt(numFrames - 1, firstFrame);
			secondFrame = MathUtil.minInt(numFrames - 1, secondFrame);
			frame &=(1 <<FRAME_SHIFT) - 1;
			div = frame * FRAME_SHIFT_RECIPROCAL;
			var targetVertexs : Vector<Vertex>= interpolateBuffer.getVertices();
			var firstVertexs : Vector<MD2Vertex>= frameList[firstFrame];
			var secondVertexs : Vector<MD2Vertex>= frameList[secondFrame];
			var target : Vertex ;
			var first : MD2Vertex;
			var second : MD2Vertex;
			var transform : MD2KeyFrameTransform;
			var count : Int = frameList[firstFrame].length;
			for (i in 0...count)
			{
				target = targetVertexs[i];
				first = firstVertexs[i];
				second = secondVertexs[i];
				transform = frameTransforms[firstFrame];
				var sx : Float = first.x * transform.sx + transform.tx;
				var sy : Float = first.y * transform.sy + transform.ty;
				var sz : Float = first.z * transform.sz + transform.tz;
				transform = frameTransforms[secondFrame];
				var ex : Float = second.x * transform.sx + transform.tx;
				var ey : Float = second.y * transform.sy + transform.ty;
				var ez : Float = second.z * transform.sz + transform.tz;
				target.x =(ex - sx) * div + sx;
				target.y =(ey - sy) * div + sy;
				target.z =(ez - sz) * div + sz;
				target.nx =(normalTable[second.normalIdx * 3] - normalTable[first.normalIdx * 3]) * div + normalTable[first.normalIdx * 3];
				target.ny =(normalTable[second.normalIdx * 3 + 1] - normalTable[first.normalIdx * 3 + 1]) * div + normalTable[first.normalIdx * 3 + 1];
				target.nz =(normalTable[second.normalIdx * 3 + 2] - normalTable[first.normalIdx * 3 + 2]) * div + normalTable[first.normalIdx * 3 + 2];
			}
			//update bounding box
			interpolateBuffer.getBoundingBox().interpolate(boxList[secondFrame], boxList[firstFrame], div);
		}
	}
	// returns the animated mesh based on a detail level. 0 is the lowest, 255 the highest detail. Note, that some Meshes will ignore the detail level.
	public function getMesh(frame : Int, detailLevel : Int = 255, startFrameLoop : Int = - 1, endFrameLoop : Int = - 1) : IMesh
	{
		if (frame> getFrameCount()) frame =(frame % getFrameCount());
		if (startFrameLoop == - 1 && endFrameLoop == - 1)
		{
			startFrameLoop = 0;
			endFrameLoop = getFrameCount() - 1;
		}
		updateInterpolationBuffer(frame, startFrameLoop, endFrameLoop);
		return this;
	}

	public function getBoundingBox() : AABBox
	{
		return interpolateBuffer.getBoundingBox();
	}

	public function setBoundingBox(box:AABBox):Void
	{
		interpolateBuffer.boundingBox = box;
	}

	public function recalculateBoundingBox():Void
	{
		interpolateBuffer.recalculateBoundingBox();
	}

	public function setMaterialFlag(flag : Int, value : Bool) : Void
	{
		interpolateBuffer.getMaterial().setFlag(flag, value);
	}

	public function setMaterialTexture(texture : ITexture, textureLayer : Int = 1) : Void
	{
		if (textureLayer <1 || textureLayer> 2) return;
		interpolateBuffer.getMaterial().setTexture(texture, textureLayer);
	}

	public function setMaterial(mat : Material) : Void
	{
		interpolateBuffer.setMaterial(mat);
	}

	public function getMeshType() : Int
	{
		return AnimatedMeshType.AMT_MD2;
	}

	public function toString() : String
	{
		return name;
	}

	public static inline var VERTEX_NORMAL_TABLE_SIZE : Int = 162;
	public static var VERTEX_NORMAL_TABLE : Vector<Float>= Vector.ofArray([- 0.525731, 0.000000, 0.850651,
			- 0.442863, 0.238856, 0.864188,
			- 0.295242, 0.000000, 0.955423,
			- 0.309017, 0.500000, 0.809017,
			- 0.162460, 0.262866, 0.951056,
			0.000000, 0.000000, 1.000000,
			0.000000, 0.850651, 0.525731,
			- 0.147621, 0.716567, 0.681718,
			0.147621, 0.716567, 0.681718,
			0.000000, 0.525731, 0.850651,
			0.309017, 0.500000, 0.809017,
			0.525731, 0.000000, 0.850651,
			0.295242, 0.000000, 0.955423,
			0.442863, 0.238856, 0.864188,
			0.162460, 0.262866, 0.951056,
			- 0.681718, 0.147621, 0.716567,
			- 0.809017, 0.309017, 0.500000,
			- 0.587785, 0.425325, 0.688191,
			- 0.850651, 0.525731, 0.000000,
			- 0.864188, 0.442863, 0.238856,
			- 0.716567, 0.681718, 0.147621,
			- 0.688191, 0.587785, 0.425325,
			- 0.500000, 0.809017, 0.309017,
			- 0.238856, 0.864188, 0.442863,
			- 0.425325, 0.688191, 0.587785,
			- 0.716567, 0.681718, - 0.147621,
			- 0.500000, 0.809017, - 0.309017,
			- 0.525731, 0.850651, 0.000000,
			0.000000, 0.850651, - 0.525731,
			- 0.238856, 0.864188, - 0.442863,
			0.000000, 0.955423, - 0.295242,
			- 0.262866, 0.951056, - 0.162460,
			0.000000, 1.000000, 0.000000,
			0.000000, 0.955423, 0.295242,
			- 0.262866, 0.951056, 0.162460,
			0.238856, 0.864188, 0.442863,
			0.262866, 0.951056, 0.162460,
			0.500000, 0.809017, 0.309017,
			0.238856, 0.864188, - 0.442863,
			0.262866, 0.951056, - 0.162460,
			0.500000, 0.809017, - 0.309017,
			0.850651, 0.525731, 0.000000,
			0.716567, 0.681718, 0.147621,
			0.716567, 0.681718, - 0.147621,
			0.525731, 0.850651, 0.000000,
			0.425325, 0.688191, 0.587785,
			0.864188, 0.442863, 0.238856,
			0.688191, 0.587785, 0.425325,
			0.809017, 0.309017, 0.500000,
			0.681718, 0.147621, 0.716567,
			0.587785, 0.425325, 0.688191,
			0.955423, 0.295242, 0.000000,
			1.000000, 0.000000, 0.000000,
			0.951056, 0.162460, 0.262866,
			0.850651, - 0.525731, 0.000000,
			0.955423, - 0.295242, 0.000000,
			0.864188, - 0.442863, 0.238856,
			0.951056, - 0.162460, 0.262866,
			0.809017, - 0.309017, 0.500000,
			0.681718, - 0.147621, 0.716567,
			0.850651, 0.000000, 0.525731,
			0.864188, 0.442863, - 0.238856,
			0.809017, 0.309017, - 0.500000,
			0.951056, 0.162460, - 0.262866,
			0.525731, 0.000000, - 0.850651,
			0.681718, 0.147621, - 0.716567,
			0.681718, - 0.147621, - 0.716567,
			0.850651, 0.000000, - 0.525731,
			0.809017, - 0.309017, - 0.500000,
			0.864188, - 0.442863, - 0.238856,
			0.951056, - 0.162460, - 0.262866,
			0.147621, 0.716567, - 0.681718,
			0.309017, 0.500000, - 0.809017,
			0.425325, 0.688191, - 0.587785,
			0.442863, 0.238856, - 0.864188,
			0.587785, 0.425325, - 0.688191,
			0.688191, 0.587785, - 0.425325,
			- 0.147621, 0.716567, - 0.681718,
			- 0.309017, 0.500000, - 0.809017,
			0.000000, 0.525731, - 0.850651,
			- 0.525731, 0.000000, - 0.850651,
			- 0.442863, 0.238856, - 0.864188,
			- 0.295242, 0.000000, - 0.955423,
			- 0.162460, 0.262866, - 0.951056,
			0.000000, 0.000000, - 1.000000,
			0.295242, 0.000000, - 0.955423,
			0.162460, 0.262866, - 0.951056,
			- 0.442863, - 0.238856, - 0.864188,
			- 0.309017, - 0.500000, - 0.809017,
			- 0.162460, - 0.262866, - 0.951056,
			0.000000, - 0.850651, - 0.525731,
			- 0.147621, - 0.716567, - 0.681718,
			0.147621, - 0.716567, - 0.681718,
			0.000000, - 0.525731, - 0.850651,
			0.309017, - 0.500000, - 0.809017,
			0.442863, - 0.238856, - 0.864188,
			0.162460, - 0.262866, - 0.951056,
			0.238856, - 0.864188, - 0.442863,
			0.500000, - 0.809017, - 0.309017,
			0.425325, - 0.688191, - 0.587785,
			0.716567, - 0.681718, - 0.147621,
			0.688191, - 0.587785, - 0.425325,
			0.587785, - 0.425325, - 0.688191,
			0.000000, - 0.955423, - 0.295242,
			0.000000, - 1.000000, 0.000000,
			0.262866, - 0.951056, - 0.162460,
			0.000000, - 0.850651, 0.525731,
			0.000000, - 0.955423, 0.295242,
			0.238856, - 0.864188, 0.442863,
			0.262866, - 0.951056, 0.162460,
			0.500000, - 0.809017, 0.309017,
			0.716567, - 0.681718, 0.147621,
			0.525731, - 0.850651, 0.000000,
			- 0.238856, - 0.864188, - 0.442863,
			- 0.500000, - 0.809017, - 0.309017,
			- 0.262866, - 0.951056, - 0.162460,
			- 0.850651, - 0.525731, 0.000000,
			- 0.716567, - 0.681718, - 0.147621,
			- 0.716567, - 0.681718, 0.147621,
			- 0.525731, - 0.850651, 0.000000,
			- 0.500000, - 0.809017, 0.309017,
			- 0.238856, - 0.864188, 0.442863,
			- 0.262866, - 0.951056, 0.162460,
			- 0.864188, - 0.442863, 0.238856,
			- 0.809017, - 0.309017, 0.500000,
			- 0.688191, - 0.587785, 0.425325,
			- 0.681718, - 0.147621, 0.716567,
			- 0.442863, - 0.238856, 0.864188,
			- 0.587785, - 0.425325, 0.688191,
			- 0.309017, - 0.500000, 0.809017,
			- 0.147621, - 0.716567, 0.681718,
			- 0.425325, - 0.688191, 0.587785,
			- 0.162460, - 0.262866, 0.951056,
			0.442863, - 0.238856, 0.864188,
			0.162460, - 0.262866, 0.951056,
			0.309017, - 0.500000, 0.809017,
			0.147621, - 0.716567, 0.681718,
			0.000000, - 0.525731, 0.850651,
			0.425325, - 0.688191, 0.587785,
			0.587785, - 0.425325, 0.688191,
			0.688191, - 0.587785, 0.425325,
			- 0.955423, 0.295242, 0.000000,
			- 0.951056, 0.162460, 0.262866,
			- 1.000000, 0.000000, 0.000000,
			- 0.850651, 0.000000, 0.525731,
			- 0.955423, - 0.295242, 0.000000,
			- 0.951056, - 0.162460, 0.262866,
			- 0.864188, 0.442863, - 0.238856,
			- 0.951056, 0.162460, - 0.262866,
			- 0.809017, 0.309017, - 0.500000,
			- 0.864188, - 0.442863, - 0.238856,
			- 0.951056, - 0.162460, - 0.262866,
			- 0.809017, - 0.309017, - 0.500000,
			- 0.681718, 0.147621, - 0.716567,
			- 0.681718, - 0.147621, - 0.716567,
			- 0.850651, 0.000000, - 0.525731,
			- 0.688191, 0.587785, - 0.425325,
			- 0.587785, 0.425325, - 0.688191,
			- 0.425325, 0.688191, - 0.587785,
			- 0.425325, - 0.688191, - 0.587785,
			- 0.587785, - 0.425325, - 0.688191,
			- 0.688191, - 0.587785, - 0.42532]);
}
