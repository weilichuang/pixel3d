package pixel3d.loader;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.Lib;
import flash.Vector;
import pixel3d.events.MeshEvent;
import pixel3d.math.Vector2f;
import pixel3d.mesh.IMesh;
import pixel3d.mesh.md2.MD2KeyFrameTransform;
import pixel3d.mesh.md2.MD2Triangle;
import pixel3d.mesh.md2.MD2Vertex;
import flash.geom.Vector3D;
import flash.utils.ByteArray;
import flash.utils.Endian;
import pixel3d.math.AABBox;
import pixel3d.math.Matrix4;
import pixel3d.math.Vertex;
import pixel3d.mesh.MeshBuffer;
import pixel3d.mesh.md2.AnimatedMeshMD2;
import pixel3d.mesh.IAnimatedMesh;
import pixel3d.mesh.KeyFrameData;
import pixel3d.utils.Logger;

//TODO 添加一个生成静态模型的功能
class MD2MeshLoader extends MeshLoader
{
	public static inline var MD2_MAGIC_NUMBER : Int = 844121161;
	public static inline var MD2_VERSION : Int = 8;
	public static inline var MD2_MAX_VERTS : Int = 2048;
	public static inline var MD2_FRAME_SHIFT : Int = 3;
	public function new(type:Int=1)
	{
		super(type);
	}

	override public function loadBytes(data:ByteArray, type:Int):Void
	{
		var mesh:IMesh = null;
		switch (type)
		{
			//case 0:
			//{
			//mesh = createAnimatedMesh(data);
			//}
			case 1:
				{
					mesh = createAnimatedMesh(data);
				}
		}
		dispatchEvent(new MeshEvent(MeshEvent.COMPLETE, mesh));
	}

	public function createAnimatedMesh(data : ByteArray) : IAnimatedMesh
	{
		if (data == null) return null;

		var regexp : EReg = ~/([0 - 9])/g;

		var mesh : AnimatedMeshMD2 = new AnimatedMeshMD2();

		// read file header
		data.endian = Endian.LITTLE_ENDIAN;
		data.position = 0;
		var magic : Int = data.readInt();
		var version : Int = data.readInt();
		var skinWidth : Int = data.readInt();
		var skinHeight : Int = data.readInt();
		var frameSize : Int = data.readInt();
		var numSkins : Int = data.readInt();
		var numVertices : Int = data.readInt();
		var numTexcoords : Int = data.readInt();
		var numTriangles : Int = data.readInt();
		var numGlCommands : Int = data.readInt();
		var numFrames : Int = data.readInt();
		var offsetSkins : Int = data.readInt();
		var offsetTexcoords : Int = data.readInt();
		var offsetTriangles : Int = data.readInt();
		var offsetFrames : Int = data.readInt();
		var offsetGlCommands : Int = data.readInt();
		var offsetEnd : Int = data.readInt();
		if (magic != MD2_MAGIC_NUMBER || version != MD2_VERSION)
		{
			Logger.log("This is not a md2 model", Logger.ERROR);
			return null;
		}
		mesh.numFrames = numFrames;
		mesh.numTriangles = numTriangles;
		// create keyframes
		mesh.frameTransforms = new Vector<MD2KeyFrameTransform>(numFrames);
		for (i in 0...numFrames)
		{
			mesh.frameTransforms[i] = new MD2KeyFrameTransform();
		}
		// create vertex arrays for each keyframe
		mesh.frameList = new Vector<Vector<MD2Vertex>>(numFrames);
		for (i in 0...numFrames)
		{
			mesh.frameList[i] = new Vector<MD2Vertex>(numVertices);
		}
		// allocate interpolation buffer vertices
		var count : Int = numTriangles * 3;
		var vertices : Vector<Vertex>= new Vector<Vertex>(count);
		var buffer : MeshBuffer = mesh.interpolateBuffer;
		for (i in 0...count)
		{
			vertices[i] = new Vertex();
		}
		var indices : Vector<Int>= new Vector<Int>(count);
		var i : Int = 0;
		while (i <count)
		{
			indices[i] = i++;
			//indices[i + 1] = i + 1;
			//indices[i + 2] = i + 2;
			//i += 3;
		}
		// read TextureCoords
		data.position = offsetTexcoords;
		var invWidth : Float = 1.0 / skinWidth;
		var invHeight : Float = 1.0 / skinHeight;
		var uvList : Vector<Vector2f>= new Vector<Vector2f>(numTexcoords);
		for (i in 0...numTexcoords)
		{
			var uv : Vector2f = new Vector2f();
			uv.x =(data.readShort() + 0.5) * invWidth;
			uv.y =(data.readShort() + 0.5) * invHeight;
			uvList[i] = uv;
		}
		// read Triangles
		data.position = offsetTriangles;
		var triangles : Vector<MD2Triangle>= new Vector<MD2Triangle>(numTriangles);
		for (i in 0...numTriangles)
		{
			var tri : MD2Triangle = new MD2Triangle();
			tri.v0 = data.readShort();
			tri.v1 = data.readShort();
			tri.v2 = data.readShort();
			tri.t0 = data.readShort();
			tri.t1 = data.readShort();
			tri.t2 = data.readShort();
			triangles[i] = tri;
		}
		mesh.boxList = new Vector<AABBox>(numFrames);
		// read Frames
		data.position = offsetFrames;
		var transforms : Vector<MD2KeyFrameTransform>= mesh.frameTransforms;
		for (i in 0...numFrames)
		{
			// read data into frame
			var sx : Float = data.readFloat();
			var sz : Float = data.readFloat();
			var sy : Float = data.readFloat();
			var tx : Float = data.readFloat();
			var tz : Float = data.readFloat();
			var ty : Float = data.readFloat();
			var name : String = data.readUTFBytes(16);
			// save keyframe scale and translation
			transforms[i].sx = sx;
			transforms[i].sy = sy;
			transforms[i].sz = sz;
			transforms[i].tx = tx;
			transforms[i].ty = ty;
			transforms[i].tz = tz;
			// store frame data
			var frame : KeyFrameData = new KeyFrameData();
			frame.begin = i;
			frame.end = i;
			frame.fps = 7;
			frame.name = '';
			// find the current frame's name
			var sl : Int = name.length;
			if (sl> 0)
			{
				frame.name = regexp.replace(name, "");
				if (mesh.keyFrameDatas.length == 0)
				{
					mesh.keyFrameDatas.push(frame);
				}
				else
				{
					var last : KeyFrameData = mesh.keyFrameDatas[mesh.keyFrameDatas.length - 1];
					if (last.name == frame.name)
					{
						last.end ++;
					}
					else
					{
						mesh.keyFrameDatas.push(frame);
					}
				}
			}
			var list : flash.Vector<MD2Vertex>= new Vector<MD2Vertex>();
			//x,y,z,normalIndex
			for (j in 0...numVertices)
			{
				// read vertex
				var vex : MD2Vertex = new MD2Vertex();
				vex.x = data.readUnsignedByte();
				vex.z = data.readUnsignedByte();
				vex.y = data.readUnsignedByte();
				vex.normalIdx = data.readUnsignedByte();
				list[j] = vex;
			}
			var box : AABBox = new AABBox();
			mesh.boxList[i] = box;
			for (j in 0...numTriangles)
			{
				var vex : MD2Vertex = list[triangles[j].v0];
				mesh.frameList[i][j * 3] = vex;
				var px : Float = vex.x * sx + tx;
				var py : Float = vex.y * sy + ty;
				var pz : Float = vex.z * sz + tz;
				if (j == 0)
				{
					box.reset(px, py, pz);
				}
				else
				{
					box.addInternalXYZ(px, py, pz);
				}
				vex = list[triangles[j].v1];
				mesh.frameList[i][j * 3 + 1] = vex;
				px = vex.x * sx + tx;
				py = vex.y * sy + ty;
				pz = vex.z * sz + tz;
				box.addInternalXYZ(px, py, pz);
				vex = list[triangles[j].v2];
				mesh.frameList[i][j * 3 + 2] = vex;
				px = vex.x * sx + tx;
				py = vex.y * sy + ty;
				pz = vex.z * sz + tz;
				box.addInternalXYZ(px, py, pz);
			}
		}
		for (j in 0...numTriangles)
		{
			vertices[j * 3].u = uvList[triangles[j].t0].x;
			vertices[j * 3].v = uvList[triangles[j].t0].y;
			vertices[j * 3 + 1].u = uvList[triangles[j].t1].x;
			vertices[j * 3 + 1].v = uvList[triangles[j].t1].y;
			vertices[j * 3 + 2].u = uvList[triangles[j].t2].x;
			vertices[j * 3 + 2].v = uvList[triangles[j].t2].y;
		}
		buffer.setVertices(vertices);
		buffer.setIndices(indices);
		triangles.length = 0;
		uvList.length = 0;
		triangles = null;
		uvList = null;
		regexp = null;
		return mesh;
	}
}
