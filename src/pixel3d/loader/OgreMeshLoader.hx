package pixel3d.loader;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.Lib;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.Vector;
import pixel3d.events.MeshErrorEvent;
import pixel3d.events.MeshEvent;
import pixel3d.events.MeshProgressEvent;
import pixel3d.material.Material;
import pixel3d.math.MathUtil;
import pixel3d.math.Matrix4;
import pixel3d.math.Vector2f;
import flash.geom.Vector3D;
import pixel3d.math.Quaternion;
import pixel3d.math.Vertex;
import pixel3d.mesh.IMesh;
import pixel3d.mesh.Mesh;
import pixel3d.mesh.MeshBuffer;
import pixel3d.mesh.skin.Joint;
import pixel3d.mesh.skin.PositionKey;
import pixel3d.mesh.skin.RotationKey;
import pixel3d.mesh.skin.ScaleKey;
import pixel3d.mesh.skin.Weight;
import pixel3d.mesh.SkinnedMesh;
import pixel3d.mesh.SkinnedMeshBuffer;
import pixel3d.utils.Logger;


/** Definition of the OGRE .mesh file format 

    .mesh files are binary files (for read efficiency at runtime) and are arranged into chunks 
    of data, very like 3D Studio's format.
    A chunk always consists of:
        unsigned short CHUNK_ID        : one of the following chunk ids identifying the chunk
        unsigned long  LENGTH          : length of the chunk in bytes, including this header
        void*          DATA            : the data, which may contain other sub-chunks (various data types)
    
    A .mesh file can contain both the definition of the Mesh itself, and optionally the definitions
    of the materials is uses (although these can be omitted, if so the Mesh assumes that at runtime the
    Materials referred to by name in the Mesh are loaded/created from another source)

    A .mesh file only contains a single mesh, which can itself have multiple submeshes.
*/
class OgreMeshLoader extends EventDispatcher
{
	// Main Chunks
	public static inline var OGRE_HEADER:Int = 0x1000;
	public static inline var OGRE_SKELETON:Int = 0x2000;
	public static inline var OGRE_MESH:Int = 0x3000;
	
	// sub chunks of OGRE_MESH
	public static inline var OGRE_SUBMESH:Int = 0x4000;
	public static inline var OGRE_GEOMETRY:Int = 0x5000;
	public static inline var OGRE_SKELETON_LINK:Int = 0x6000;
	public static inline var OGRE_BONE_ASSIGNMENT:Int = 0x7000;
	public static inline var OGRE_MESH_LOD:Int = 0x8000;
	public static inline var OGRE_MESH_BOUNDS:Int = 0x9000;
	public static inline var OGRE_MESH_SUBMESH_NAME_TABLE:Int = 0xA000;
	public static inline var OGRE_MESH_EDGE_LISTS:Int = 0xB000;
	
	// sub chunks of OGRE_SKELETON
	public static inline var OGRE_BONE_PARENT:Int = 0x3000;
	public static inline var OGRE_ANIMATION:Int = 0x4000;
	public static inline var OGRE_ANIMATION_TRACK:Int = 0x4100;
	public static inline var OGRE_ANIMATION_KEYFRAME:Int = 0x4110;
	public static inline var OGRE_ANIMATION_LINK:Int = 0x5000;
	
	// sub chunks of OGRE_SUBMESH
	public static inline var OGRE_SUBMESH_OPERATION:Int = 0x4010;
	public static inline var OGRE_SUBMESH_BONE_ASSIGNMENT:Int = 0x4100;
	public static inline var OGRE_SUBMESH_TEXTURE_ALIAS:Int = 0x4200;

	// sub chunks of OGRE_GEOMETRY
	public static inline var OGRE_GEOMETRY_VERTEX_DECLARATION:Int = 0x5100;
	public static inline var OGRE_GEOMETRY_VERTEX_ELEMENT:Int = 0x5110;
	public static inline var OGRE_GEOMETRY_VERTEX_BUFFER:Int = 0x5200;
	public static inline var OGRE_GEOMETRY_VERTEX_BUFFER_DATA:Int = 0x5210;
	
	private var ogreMesh:OgreMesh;
	private var mesh:IMesh;
	private var skeleton:OgreSkeleton;
	private var skeletonName:String;
	private var numUV:Int;
	
	private var meshPath:String;
	private var materialPath:String;
	private var skeletonPath:String;
	private var isStatic:Bool;
	private var loadedCount:Int;//已经加载的项目
	private var meshLoader:URLLoader;
	private var materialLoader:URLLoader;
	private var skeletonLoader:URLLoader;
	private var meshLoaded:Bool;
	private var materialLoaded:Bool;
	private var skeletonLoaded:Bool;
	private var meshBytes:ByteArray;
	private var materialBytes:ByteArray;
	private var skeletonBytes:ByteArray;
	
	/**
	 * 可能会加载多个文件。
	 * 例如Sinbad.material,Sinbad.mesh,Sinbad.skeleton还有对应的贴图
	 * @param	type
	 */
	public function new()
	{
		super();
	}
	
	public function clear():Void
	{
		numUV = 0;
		skeletonName = "";
		mesh = null;
		skeleton = null;
		ogreMesh = null;
		skeleton = new OgreSkeleton();
	}
	
	/**
	 * 加载ogre mesh文件，meshPath必须有，否则报错。后面的materialPath和skeletonPath可选
	 * @param	meshPath
	 * @param	isStatic
	 * @param	materialPath
	 * @param	skeletonPath
	 */
	public function load(meshPath:String,isStatic:Bool,materialPath:String = "", skeletonPath:String = ""):Void
	{
		this.meshPath = meshPath;
		this.materialPath = materialPath;
		this.skeletonPath = skeletonPath;
		this.isStatic = isStatic;
		
		meshLoaded = false;
		materialLoaded = false;
		skeletonLoaded = false;
		loadedCount = 0;
		
		//不加载骨骼文件
		if (isStatic || skeletonPath == "")
		{
			loadedCount++;
		}
		
		//不加载材质文件
		if (materialPath == "")
		{
			loadedCount++;
		}
		
		if (meshPath == "")
		{
			loadedCount++;
		}
		
		if (loadedCount >= 3)
		{
			dispatchEvent(new MeshErrorEvent(MeshErrorEvent.ERROR, "load failed"));
			return;
		}
		
		loadMesh();
	}
	
	private function loadMesh():Void
	{
		meshLoader = new URLLoader();
		meshLoader.dataFormat = URLLoaderDataFormat.BINARY;
		meshLoader.addEventListener(Event.COMPLETE, __loadMeshComplete);
		meshLoader.addEventListener(IOErrorEvent.IO_ERROR, __loadMeshError);
		meshLoader.addEventListener(ProgressEvent.PROGRESS, __loadMeshProgress);
		meshLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, __loadMeshError);
		meshLoader.load(new URLRequest(meshPath));
	}
	
	private function loadMaterial():Void
	{
		materialLoader = new URLLoader();
		materialLoader.dataFormat = URLLoaderDataFormat.BINARY;
		materialLoader.addEventListener(Event.COMPLETE, __loadMaterialComplete);
		materialLoader.addEventListener(IOErrorEvent.IO_ERROR, __loadMaterialError);
		materialLoader.addEventListener(ProgressEvent.PROGRESS, __loadMaterialProgress);
		materialLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, __loadMaterialError);
		materialLoader.load(new URLRequest(materialPath));
	}
	
	private function loadSkeleton():Void
	{
		skeletonLoader = new URLLoader();
		skeletonLoader.dataFormat = URLLoaderDataFormat.BINARY;
		skeletonLoader.addEventListener(Event.COMPLETE, __loadSkeletonComplete);
		skeletonLoader.addEventListener(IOErrorEvent.IO_ERROR, __loadSkeletonError);
		skeletonLoader.addEventListener(ProgressEvent.PROGRESS, __loadSkeletonProgress);
		skeletonLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, __loadSkeletonError);
		skeletonLoader.load(new URLRequest(skeletonPath));
	}
	
	private function unloadMesh():Void
	{
		meshLoader.removeEventListener(Event.COMPLETE, __loadMeshComplete);
		meshLoader.removeEventListener(IOErrorEvent.IO_ERROR, __loadMeshError);
		meshLoader.removeEventListener(ProgressEvent.PROGRESS, __loadMeshProgress);
		meshLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, __loadMeshError);
		meshLoader = null;
	}
	
	private function unloadMaterial():Void
	{
		materialLoader.removeEventListener(Event.COMPLETE, __loadMaterialComplete);
		materialLoader.removeEventListener(IOErrorEvent.IO_ERROR, __loadMaterialError);
		materialLoader.removeEventListener(ProgressEvent.PROGRESS, __loadMaterialProgress);
		materialLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, __loadMaterialError);
		materialLoader = null;
	}
	
	private function unloadSkeleton():Void
	{
		skeletonLoader.removeEventListener(Event.COMPLETE, __loadSkeletonComplete);
		skeletonLoader.removeEventListener(IOErrorEvent.IO_ERROR, __loadSkeletonError);
		skeletonLoader.removeEventListener(ProgressEvent.PROGRESS, __loadSkeletonProgress);
		skeletonLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, __loadSkeletonError);
		skeletonLoader = null;
	}
	
	private function __loadMeshComplete(e:Event):Void
	{
        loadedCount++;
		meshLoaded = true;
		
		meshBytes = Lib.as(this.meshLoader.data, ByteArray);
		
		unloadMesh();
		
		if (loadedCount >= 3)//加载完成
		{
			//开始分析
			parse();
		}
		else if (materialPath != "") //加载material文件
		{
			loadMaterial();
		}
		else if (skeletonPath != "")//没有material文件,此时加载skeleton
		{
			loadSkeleton();
		}
	}
	
	private function __loadMeshProgress(e:Event):Void
	{
		dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, "load progress"));
	}
	
	private function __loadMeshError(e:Event):Void
	{
		unloadMesh();
		dispatchEvent(new MeshErrorEvent(MeshErrorEvent.ERROR, "load failed"));
	}
	
	private function __loadMaterialComplete(e:Event):Void
	{
		loadedCount++;
		materialLoaded = true;
		
		materialBytes = Lib.as(materialLoader.data, ByteArray);
		unloadMaterial();
		
		if (loadedCount >= 3)//加载完成
		{
			//开始分析
			parse();
		}
		else
		{
			//加载骨骼
			loadSkeleton();
		}
	}
	
	private function __loadMaterialProgress(e:Event):Void
	{
		dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, "load progress"));
	}
	
	private function __loadMaterialError(e:Event):Void
	{
		unloadMaterial();
		dispatchEvent(new MeshErrorEvent(MeshErrorEvent.ERROR, "load failed"));
	}
	
	private function __loadSkeletonComplete(e:Event):Void
	{
		loadedCount++;
		skeletonLoaded = true;
		
		skeletonBytes = Lib.as(skeletonLoader.data, ByteArray);
		unloadSkeleton();

		//开始分析
		parse();
	}
	
	private function __loadSkeletonProgress(e:Event):Void
	{
		dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, "load progress"));
	}
	
	private function __loadSkeletonError(e:Event):Void
	{
		unloadSkeleton();
		dispatchEvent(new MeshErrorEvent(MeshErrorEvent.ERROR, "load failed"));
	}

	private function parse():Void
	{
		if (meshBytes == null)
		{
			dispatchEvent(new MeshErrorEvent(MeshErrorEvent.ERROR, "load failed"));
			return;
		}
		
		meshBytes.position = 0;
		meshBytes.endian = Endian.LITTLE_ENDIAN;
		
		var id:Int = meshBytes.readUnsignedShort();

		var data:OgreChunkData = new OgreChunkData();
		
		var version:String = readString(meshBytes,data);

		if (version != "[MeshSerializer_v1.30]" && 
		    version != "[MeshSerializer_v1.40]" && 
			version != "[MeshSerializer_v1.41]")
		{
			dispatchEvent(new MeshErrorEvent(MeshErrorEvent.ERROR, "parse failed"));
			return;
		}
		
		clear();

		var data:OgreChunkData = new OgreChunkData();
			
		readChunkData(meshBytes, data);
			
		switch(data.header.id)
		{
			case OGRE_MESH:
			{
				ogreMesh = new OgreMesh();

				if (skeletonBytes != null)
				{
					readSkeleton();
				}
					
				readObjectChunk(meshBytes, data, ogreMesh);
					
				if (!isStatic && skeleton.bones.length > 0)
				{
					mesh = new SkinnedMesh();
				}
				else
				{
					mesh = new Mesh();
				}
					
				composeObject();
			}
		}

		if (mesh != null)
		{
			mesh.recalculateBoundingBox();
			dispatchEvent(new MeshEvent(MeshEvent.COMPLETE, mesh));
		}
		else
		{
			dispatchEvent(new MeshErrorEvent(MeshErrorEvent.ERROR, "parse failed"));
		}
	}
	
	public function readSkeleton():Bool
	{
		if (skeletonBytes == null) return false;
		
		skeletonBytes.position = 0;
		skeletonBytes.endian = Endian.LITTLE_ENDIAN;
		
		var id:Int = skeletonBytes.readUnsignedShort();
		
		#if debug
		    Logger.log("skeleton id = "+id);
		#end
		
		var head:OgreChunkData = new OgreChunkData();
		var skeletonVersion:String = readString(skeletonBytes, head);
		
		if (skeletonVersion != "[Serializer_v1.10]")
		{
			return false;
		}
		
		var boneID:Int = 0;
		var animationTotal:Float = 0.0;
		while (skeletonBytes.position < skeletonBytes.length)
		{
			var data:OgreChunkData = new OgreChunkData();
			readChunkData(skeletonBytes, data);
			
			switch(data.header.id)
			{
				case OGRE_SKELETON:
				{
					var bone:OgreBone = new OgreBone();
					skeleton.bones.push(bone);
					bone.name = readString(skeletonBytes, data);
					bone.handle = skeletonBytes.readUnsignedShort();
					data.read += 2;
					readVector3D(skeletonBytes, data, bone.position);
					readQuaternion(skeletonBytes, data, bone.orientation);
					
					#if debug
					    Logger.log("bone.name = " + bone.name);
						Logger.log("bone.handle = " + bone.handle);
						Logger.log("bone.position = " + bone.position);
						Logger.log("bone.orientation = "+bone.orientation);
					#end
					
					var len:UInt = (data.header.length - bone.name.length);
					if (data.read < len)
					{
						readVector3D(skeletonBytes, data, bone.scale);
						bone.scale.x *= -1.0;
						
						#if debug
					    Logger.log("bone.scale = " + bone.scale);
					    #end
					}
					else
					{
						bone.scale = new Vector3D(1, 1, 1);
					}
					bone.parent = 0xffff;
				}
				case OGRE_BONE_PARENT:
				{
					boneID = skeletonBytes.readUnsignedShort();
					var parentID:Int = skeletonBytes.readUnsignedShort();
					
					data.read += 4;
					
					var boneLength:Int = skeleton.bones.length;
					if (boneID < boneLength && parentID < boneLength)
					{
						skeleton.bones[boneID].parent = parentID;
					}
				}
				case OGRE_ANIMATION:
				{
					var animation:OgreAnimation = new OgreAnimation();
					skeleton.animations.push(animation);
					
					animation.name = readString(skeletonBytes, data);
					animation.length = skeletonBytes.readFloat();
					data.read += 4;

					animationTotal += animation.length;
					
					#if debug
					    Logger.log("Animation name : " + animation.name);
						Logger.log("Animation length : "+animation.length);
					#end
				}
				case OGRE_ANIMATION_TRACK:
				{
					boneID = skeletonBytes.readUnsignedShort(); // store current bone
					data.read += 2;
				}
				case OGRE_ANIMATION_KEYFRAME:
				{
					var keyframe:OgreKeyframe = new OgreKeyframe();
					skeleton.animations[skeleton.animations.length - 1].keyframes.push(keyframe);
					
					keyframe.time = skeletonBytes.readFloat() + animationTotal;
					data.read += 4;
					
					readQuaternion(skeletonBytes, data, keyframe.orientation);
					readVector3D(skeletonBytes, data, keyframe.position);
					if (data.read < data.header.length)
					{
						readVector3D(skeletonBytes, data, keyframe.scale);
						keyframe.scale.x *= -1.0;
					}
					else
					{
						keyframe.scale = new Vector3D(1, 1, 1);
					}
					keyframe.boneID = boneID;
				}
				case OGRE_ANIMATION_LINK:
				{
					#if debug
					    Logger.log("Animation link");
					#end
				}
			}
		}
		return true;
	}
	
	private function readObjectChunk(file:ByteArray, parent:OgreChunkData, ogreMesh:OgreMesh):Void
	{
		#if debug
		    Logger.log("Read Object Chunk");
		#end
		
		ogreMesh.skeletalAnimation = readBool(file, parent);
		
		#if debug
		    Logger.log("ogreMesh.skeletalAnimation = "+ogreMesh.skeletalAnimation);
		#end
		
		while (parent.read < parent.header.length && file.position < file.length)
		{
			var data:OgreChunkData = new OgreChunkData();
			readChunkData(file, data);
			
			switch(data.header.id)
			{
				case OGRE_GEOMETRY:
				{
					readGeometry(file, data, ogreMesh.geometry);
				}
				case OGRE_SUBMESH:
				{
					var m:OgreSubMesh = new OgreSubMesh();
					ogreMesh.subMeshes.push(m);
					readSubMesh(file, data, m);
				}
				case OGRE_MESH_BOUNDS:
				{
					#if debug
		    		Logger.log("Read Mesh Bounds");
					#end
					
					readVector3D(file, data, ogreMesh.boxMinEdge);
					readVector3D(file, data, ogreMesh.boxMaxEdge);
					ogreMesh.boxRadius = file.readFloat();
					data.read += 4;
				}
				case OGRE_SKELETON_LINK:
				{
					#if debug
		    		Logger.log("Read Skeleton link");
					#end
					
					skeletonName = readString(file, data);
					
					#if debug
		    		Logger.log("skeletonName = " + skeletonName);
					#end
				}
				case OGRE_BONE_ASSIGNMENT:
				{
					var assignment:OgreBoneAssignment = new OgreBoneAssignment();
					ogreMesh.boneAssignments.push(assignment);
					assignment.vertexID = file.readInt();
					assignment.boneID = file.readUnsignedShort();
					assignment.weight = file.readFloat();
					data.read += 10;
				}
				case OGRE_MESH_LOD, OGRE_MESH_SUBMESH_NAME_TABLE, OGRE_MESH_EDGE_LISTS:
				{
					// ignore chunk
					file.position += data.header.length - data.read;
					data.read = data.header.length;
				}
				default:
				{
					//ignore chunk
					file.position += data.header.length - data.read;
					data.read = data.header.length;
				}
			}
			parent.read += data.read;
		}
	}
	
	private function readGeometry(file:ByteArray, parent:OgreChunkData, geometry:OgreGeometry):Void
	{
		#if debug
		    Logger.log("Read Geometry");
		#end
		
		geometry.numVertex = file.readInt();
		parent.read += 4;
		
		#if debug
		    Logger.log("geometry.numVertex ="+geometry.numVertex);
		#end
		
		while (parent.read < parent.header.length)
		{
			var data:OgreChunkData = new OgreChunkData();
			readChunkData(file, data);
			
			switch(data.header.id)
			{
				case OGRE_GEOMETRY_VERTEX_DECLARATION:
				{
					readVertexDeclaration(file, data, geometry);
				}
				case OGRE_GEOMETRY_VERTEX_BUFFER:
				{
					readVertexBuffer(file, data, geometry);
				}
				default:
				    // ignore chunk
					file.position += data.header.length - data.read;
					data.read = data.header.length;
			}
			parent.read += data.read;
		}
	}
	
	private function readVertexDeclaration(file:ByteArray, parent:OgreChunkData, geometry:OgreGeometry):Void
	{
		#if debug
		    Logger.log("Read Vertex Declaration");
		#end
		
		numUV = 0;
		
		while (parent.read < parent.header.length)
		{
			var data:OgreChunkData = new OgreChunkData();
			readChunkData(file, data);
			
			switch(data.header.id)
			{
				case OGRE_GEOMETRY_VERTEX_ELEMENT:
				{
					var element:OgreVertexElement = new OgreVertexElement();
					geometry.elements.push(element);
					element.source = file.readUnsignedShort();
					element.type = file.readUnsignedShort();
					element.semantic = file.readUnsignedShort();

					if (element.semantic == 7) //tex coords
					{
						++numUV;
					}
					
					element.offset = file.readUnsignedShort();
					element.offset = Std.int(element.offset/4);
					element.index = file.readUnsignedShort();
					
					data.read += 2 * 5;
				}
				default:
				    //ignore chunk
					file.position += data.header.length - data.read;
					data.read = data.header.length;
			}
			
			parent.read += data.read;
		}
	}
	
	private function readVertexBuffer(file:ByteArray, parent:OgreChunkData, geometry:OgreGeometry):Void
	{
		#if debug
		    Logger.log("Read Vertex Buffer");
		#end
		
		var buf:OgreVertexBuffer = new OgreVertexBuffer();
		buf.bindIndex = file.readUnsignedShort();
		buf.vertexSize = file.readUnsignedShort();
		buf.vertexSize = Std.int(buf.vertexSize/4);
		
		parent.read += 2 * 2;
		
		var data:OgreChunkData = new OgreChunkData();
		readChunkData(file, data);
		
		if (data.header.id == OGRE_GEOMETRY_VERTEX_BUFFER_DATA)
		{
			buf.data = new Vector<Float>(geometry.numVertex * buf.vertexSize);
			readFloats(file, data, buf.data, geometry.numVertex * buf.vertexSize);
		}
		
		geometry.buffers.push(buf);
		parent.read += data.read;
	}
	
	private function readSubMesh(file:ByteArray, parent:OgreChunkData, subMesh:OgreSubMesh):Bool
	{
		#if debug
		    Logger.log("Read Submesh");
		#end
		
		subMesh.material = readString(file, parent);
		
		#if debug
		    Logger.log("subMesh.material ="+subMesh.material);
		#end
		
		subMesh.sharedVertices = readBool(file, parent);
		
		#if debug
		    Logger.log("subMesh.sharedVertices ="+subMesh.sharedVertices);
		#end
		
		var numIndices:Int = file.readInt();
		parent.read += 4;
		
		subMesh.indices = new Vector<Int>(numIndices);
		
		subMesh.indices32Bit = readBool(file, parent);
		
		if (subMesh.indices32Bit)
		{
			readInts(file, parent, subMesh.indices, numIndices);
		}
		else
		{
			readShorts(file, parent, subMesh.indices, numIndices);
		}
		
		while (parent.read < parent.header.length)
		{
			var data:OgreChunkData = new OgreChunkData();
			readChunkData(file, data);
			
			switch(data.header.id)
			{
				case OGRE_GEOMETRY:
				
				    readGeometry(file, data, subMesh.geometry);
					
				case OGRE_SUBMESH_OPERATION:
				    subMesh.operation = file.readUnsignedShort();
					data.read += 2;
					if (subMesh.operation != 4)
					{
						Logger.log("Primitive type != trilist not yet implemented");
					}
					
				case OGRE_SUBMESH_TEXTURE_ALIAS:
				    #if debug
		    	    Logger.log("Read Submesh Texture Alias");
			        #end

					var texture:String = readString(file, data);
					var alias:String = readString(file, data);
					subMesh.textureAliases.push(new OgreTextureAlias(texture, alias));
					
				case OGRE_SUBMESH_BONE_ASSIGNMENT:
				
				    var boneAssign:OgreBoneAssignment = new OgreBoneAssignment();
					subMesh.boneAssignments.push(boneAssign);
					boneAssign.vertexID = file.readInt();
					boneAssign.boneID = file.readUnsignedShort();
					boneAssign.weight = file.readFloat();
					data.read += 4 + 2 + 4;
					
				default:
					parent.read = parent.header.length;
					file.position -= 6;
					return true;
			}
			parent.read += data.read;
		}
		return true;
	}
	
	private function composeMeshBuffer(indices:Vector<Int>, geom:OgreGeometry):MeshBuffer
	{
		#if debug
		    Logger.log("composeMeshBuffer");
		#end
		
		var mb:MeshBuffer = new MeshBuffer();
		
		mb.indices = indices.concat();
		
		mb.vertices = new Vector<Vertex>(geom.numVertex);
		for (i in 0...geom.numVertex)
		{
			mb.vertices[i] = new Vertex();
		}
		
		var elementLength:Int = geom.elements.length;
		for (i in 0...elementLength)
		{
			var element:OgreVertexElement = geom.elements[i];
			if (element.semantic == 1) //pos
			{
				var bufferLength:Int = geom.buffers.length;
				for (j in 0...bufferLength)
				{
					var buffer:OgreVertexBuffer = geom.buffers[j];
					if (element.source == buffer.bindIndex)
					{
						var size:Int = buffer.vertexSize;
						var pos:Int = element.offset;
						for (k in 0...geom.numVertex)
						{
							//mb->Vertices[k].Color=mb->Material.DiffuseColor;
							mb.vertices[k].x = buffer.data[pos];
							mb.vertices[k].y = buffer.data[pos+1];
							mb.vertices[k].z = buffer.data[pos+2];
							pos += size;
						}
					}
				}
			}
			else if (element.semantic == 4) //normal
			{
				var bufferLength:Int = geom.buffers.length;
				for (j in 0...bufferLength)
				{
					var buffer:OgreVertexBuffer = geom.buffers[j];
					if (element.source == buffer.bindIndex)
					{
						var size:Int = buffer.vertexSize;
						var pos:Int = element.offset;
						for (k in 0...geom.numVertex)
						{
							mb.vertices[k].nx = buffer.data[pos];
							mb.vertices[k].ny = buffer.data[pos+1];
							mb.vertices[k].nz = buffer.data[pos+2];
							pos += size;
						}
					}
				}
			}
			else if (element.semantic == 7) //texCoord
			{
				var bufferLength:Int = geom.buffers.length;
				for (j in 0...bufferLength)
				{
					var buffer:OgreVertexBuffer = geom.buffers[j];
					if (element.source == buffer.bindIndex)
					{
						var size:Int = buffer.vertexSize;
						var pos:Int = element.offset;
						for (k in 0...geom.numVertex)
						{
							mb.vertices[k].u = buffer.data[pos];
							mb.vertices[k].v = buffer.data[pos + 1];
							if (numUV > 1)
							{
								mb.vertices[k].u2 = buffer.data[pos + 2];
								mb.vertices[k].v2 = buffer.data[pos + 3];
							}
							pos += size;
						}
					}
				}
			}
		}
		
		return mb;
	}
	
	private function composeSkinnedMeshBuffer(mesh:SkinnedMesh,indices:Vector<Int>, geom:OgreGeometry):SkinnedMeshBuffer
	{
		var mb:SkinnedMeshBuffer = mesh.addMeshBuffer();
		
		mb.indices = new Vector<Int>(indices.length);
		var i:UInt = 0;
		var indicesLength:UInt = indices.length;
		while (i < indicesLength)
		{
			mb.indices[i] = indices[i + 2];
			mb.indices[i + 1] = indices[i + 1];
			mb.indices[i + 2] = indices[i];
			
			i += 3;
		}
		
		mb.vertices = new Vector<Vertex>(geom.numVertex);
		for (i in 0...geom.numVertex)
		{
			mb.vertices[i] = new Vertex();
		}
		
		var elementCount:Int = geom.elements.length;
		for (i in 0...elementCount)
		{
			var element:OgreVertexElement = geom.elements[i];
			if (element.semantic == 1) //pos
			{
				var bufferLength:Int = geom.buffers.length;
				for (j in 0...bufferLength)
				{
					if (element.source == geom.buffers[j].bindIndex)
					{
						var size:Int = geom.buffers[j].vertexSize;
						var pos:Int = element.offset;
						for (k in 0...geom.numVertex)
						{
							//mb->Vertices[k].Color=mb->Material.DiffuseColor;
							mb.vertices[k].x = -geom.buffers[j].data[pos];
							mb.vertices[k].y = geom.buffers[j].data[pos+1];
							mb.vertices[k].z = geom.buffers[j].data[pos+2];
							pos += size;
						}
					}
				}
			}
			else if (element.semantic == 4) //normal
			{
				var bufferLength:Int = geom.buffers.length;
				for (j in 0...bufferLength)
				{
					if (element.source == geom.buffers[j].bindIndex)
					{
						var size:Int = geom.buffers[j].vertexSize;
						var pos:Int = element.offset;
						for (k in 0...geom.numVertex)
						{
							//mb->Vertices[k].Color=mb->Material.DiffuseColor;
							mb.vertices[k].nx = -geom.buffers[j].data[pos];
							mb.vertices[k].ny = geom.buffers[j].data[pos+1];
							mb.vertices[k].nz = geom.buffers[j].data[pos+2];
							pos += size;
						}
					}
				}
			}
			else if (element.semantic == 7) //texCoord
			{
				var bufferLength:Int = geom.buffers.length;
				for (j in 0...bufferLength)
				{
					if (element.source == geom.buffers[j].bindIndex)
					{
						var size:Int = geom.buffers[j].vertexSize;
						var pos:Int = element.offset;
						for (k in 0...geom.numVertex)
						{
							//mb->Vertices[k].Color=mb->Material.DiffuseColor;
							mb.vertices[k].u = geom.buffers[j].data[pos];
							mb.vertices[k].v = geom.buffers[j].data[pos + 1];
							if (numUV > 1)
							{
								mb.vertices[k].u2 = geom.buffers[j].data[pos + 2];
								mb.vertices[k].v2 = geom.buffers[j].data[pos + 3];
							}
							pos += size;
						}
					}
				}
			}
		}
		
		return mb;
	}

	private function composeObject():Void
	{
		isStatic = isStatic || skeleton.bones.length == 0;
        
		var subMeshLength:Int = ogreMesh.subMeshes.length;
		for (j in 0...subMeshLength)
		{
			var subMesh:OgreSubMesh = ogreMesh.subMeshes[j];
			var mb:MeshBuffer;
			if (subMesh.sharedVertices)
			{
				if (!isStatic)
				{
					mb = composeSkinnedMeshBuffer(Lib.as(mesh,SkinnedMesh), subMesh.indices, ogreMesh.geometry);
				}
				else 
				{
					mb = composeMeshBuffer(subMesh.indices, ogreMesh.geometry);
				}
			}
			else
			{
				if (!isStatic)
				{
					mb = composeSkinnedMeshBuffer(Lib.as(mesh,SkinnedMesh), subMesh.indices, subMesh.geometry);
				}
				else 
				{
					mb = composeMeshBuffer(subMesh.indices, subMesh.geometry);
				}
			}
				
			if (mb != null)
			{
				//composeMeshBufferMaterial(mb, ogreMesh.subMeshes[j].material);
				if (isStatic)
				{
					mesh.getMeshBuffers().push(mb);
				}
			}
		}
		
		if (!isStatic)
		{
			var skinnedMesh:SkinnedMesh = Lib.as(mesh, SkinnedMesh);
			var joints:Vector<Joint> = skinnedMesh.getAllJoints();
			
			var bones:Vector<OgreBone> = skeleton.bones;
			var scaleMatrix:Matrix4 = new Matrix4();
			//create Joints
			var boneLength:Int = bones.length;
			for (i in 0...boneLength)
			{
				var bone:OgreBone = bones[i];
				var jt:Joint = skinnedMesh.addJoint();
				jt.name = bone.name;
				
				jt.localMatrix = bone.orientation.getMatrix();
				if (bone.scale.x != 1 || bone.scale.y != 1 || bone.scale.z != 1)
				{
					scaleMatrix.identity();
					scaleMatrix.setScale(bone.scale);
					jt.localMatrix.prepend(scaleMatrix);
				}
				jt.localMatrix.setTranslation(bone.position);
			}
			
			//Joints hierarchy
			var boneLength:Int = bones.length;
			for (i in 0...boneLength)
			{
				if (bones[i].parent < skinnedMesh.getJointCount())
				{
					joints[bones[i].parent].children.push(joints[bones[i].handle]);
				}
			}
			
			//Weights
			var bufCount:Int = 0;
			var subMeshLength:Int = ogreMesh.subMeshes.length;
			for (j in 0...subMeshLength)
			{
				var subMesh:OgreSubMesh = ogreMesh.subMeshes[j];
				var boneAssLength:Int = subMesh.boneAssignments.length;
				for (k in 0...boneAssLength)
				{
					var ba:OgreBoneAssignment = subMesh.boneAssignments[k];
					if (ba.boneID < skinnedMesh.getJointCount())
					{
						var w:Weight = skinnedMesh.addWeight(joints[ba.boneID]);
						w.strength = ba.weight;
						w.vertexID = ba.vertexID;
						w.bufferID = bufCount;
					}
				}
				++bufCount;
			}
			
			var animations:Vector<OgreAnimation> = skeleton.animations;
			var animationCount:Int = animations.length;
			for (i in 0...animationCount)
			{
				var animation:OgreAnimation = animations[i];
				var keyframeCount:Int = animation.keyframes.length;
				for (j in 0...keyframeCount)
				{
					var frame:OgreKeyframe = animation.keyframes[j];
					var keyJoint:Joint = joints[frame.boneID];
					var posKey:PositionKey = skinnedMesh.addPositionKey(keyJoint);
					posKey.frame = Std.int(frame.time * 25);
					posKey.position = keyJoint.localMatrix.getTranslation().add(frame.position);
					
					var rotKey:RotationKey = skinnedMesh.addRotationKey(keyJoint);
					rotKey.frame = Std.int(frame.time * 25);
					//rotKey.rotation = new Quaternion();
					rotKey.rotation.setMatrix(keyJoint.localMatrix);
					rotKey.rotation.multiplyBy(frame.orientation);
					
					var scaleKey:ScaleKey = skinnedMesh.addScaleKey(keyJoint);
					scaleKey.frame = Std.int(frame.time * 25);
					scaleKey.scale = frame.scale.clone();
				}
			}
			skinnedMesh.finalize();
			
			ogreMesh = null;
		}
	}
	
	private inline function readChunkData(file:ByteArray, data:OgreChunkData):Void
	{
		data.header.id = file.readUnsignedShort();
		data.header.length = file.readUnsignedInt();
		
		data.read += 6;
	}
	
	private function readInts(file:ByteArray, data:OgreChunkData,out:Vector<Int>,num:Int):Void
	{
		for (i in 0...num)
		{
			out[i] = file.readInt();
		}
		data.read += num * 4;
	}
	
	private inline function readFloats(file:ByteArray, data:OgreChunkData,out:Vector<Float>,num:Int):Void
	{
		for (i in 0...num)
		{
			out[i] = file.readFloat();
		}
		data.read += num * 4;
	}
	
	private inline function readVector3D(file:ByteArray, data:OgreChunkData, out:Vector3D):Void
	{
		out.x = -file.readFloat();
		out.y = file.readFloat();
		out.z = file.readFloat();
		
		data.read += 4 * 3;
	}
	
	private inline function readQuaternion(file:ByteArray, data:OgreChunkData, out:Quaternion):Void
	{
		out.x = -file.readFloat();
		out.y = file.readFloat();
		out.z = file.readFloat();
		out.w = file.readFloat();
		
		data.read += 4 * 4;
	}
	
	private inline function readShorts(file:ByteArray, data:OgreChunkData, out:Vector<Int>, num:Int):Void
	{
		for (i in 0...num)
		{
			out[i] = file.readUnsignedShort();
		}
		data.read += num * 2;
	}
	
	private inline function readBool(file:ByteArray, data:OgreChunkData):Bool
	{
		data.read++;
		return (file.readByte() != 0);
	}
	
	private inline function readString(file:ByteArray,data:OgreChunkData):String
	{
		var out:String = "";
		
		var str:String = "";
		while (str != "\n")
		{
			str = file.readUTFBytes(1);
			data.read++;
			if (str != "\n")
			{
				out += str;
			}
		}
		
		return out;
	}
	
}

class OgreChunkHeader
{
	public var id:Int;
	public var length:UInt;
	
	public function new()
	{
		id = 0;
		length = 0;
	}
}

class OgreChunkData
{
	public var header:OgreChunkHeader;
	public var read:UInt;
	
	public function new()
	{
		header = new OgreChunkHeader();
		read = 0;
	}
}

class OgrePass
{
	public var material:Material;
	public var texture:OgreTexture;
	public var ambientTokenColor:Bool;
	public var diffuseTokenColor:Bool;
	public var specularTokenColor:Bool;
	public var emissiveTokenColor:Bool;
	public var maxLights:Int;
	public var pointSize:Float;
	public var pointSprites:Bool;
	public var pointSizeMin:Int;
	public var pointSizeMax:Int;
	public function new()
	{
		ambientTokenColor = false;
		diffuseTokenColor = false;
		specularTokenColor = false;
		emissiveTokenColor = false;
		pointSprites = false;
		
		maxLights = 8;
		pointSize = 1.0;
		pointSizeMax = 0;
		pointSizeMin = 0;
	}
}

class OgreTechnique
{
	public var name:String;
	public var scheme:String;
	public var lodIndex:Int;
	public var passes:Vector<OgrePass>;
	public function new()
	{
		name = "";
		lodIndex = 0;
		passes = new Vector<OgrePass>();
	}
}

class OgreMaterial
{
	public var name:String;
	public var receiveShadows:Bool;
	public var transparencyCastsShadows:Bool;
	public var lodDistance:Vector<Float>;
	public var techniques:Vector<OgreTechnique>;
	public function new()
	{
		lodDistance = new Vector<Float>();
		techniques = new Vector<OgreTechnique>();
	}
}

class OgreTexture
{
	public var fileName:String;
	public var alias:String;
	public var coordsType:String;
	public var mipMaps:String;
	public var alpha:String;
	public function new()
	{
		
	}
}

class OgreTextureAlias
{
	public var texture:String;
	public var alias:String;
	public function new(texture:String,alias:String)
	{
		this.texture = texture;
		this.alias = alias;
	}
}

class OgreVertexBuffer
{
	public var bindIndex:Int;
	public var vertexSize:Int;
	public var data:Vector<Float>;
	public function new()
	{
		bindIndex = 0;
		vertexSize = 0;
		data = new Vector<Float>();
	}
}

class OgreVertexElement
{
	public var source:Int;
	public var type:Int;
	public var semantic:Int;
	public var offset:Int;
	public var index:Int;
	
	public function new()
	{
		
	}
}

class OgreGeometry
{
	public var numVertex:Int;
	public var elements:Vector<OgreVertexElement>;
	public var buffers:Vector<OgreVertexBuffer>;
	public var vertices:Vector<Vector3D>;
	public var normals:Vector<Vector3D>;
	public var colors:Vector<Int>;
	public var texCoords:Vector<Vector2f>;
	public function new()
	{
		elements = new Vector<OgreVertexElement>();
		buffers = new Vector<OgreVertexBuffer>();
		vertices = new Vector<Vector3D>();
		normals = new Vector<Vector3D>();
		colors = new Vector<Int>();
		texCoords = new Vector<Vector2f>();
	}
}

class OgreBoneAssignment
{
	public var vertexID:Int;
	public var boneID:Int;
	public var weight:Float;
	public function new()
	{
		
	}
}

class OgreSubMesh
{
	public var material:String;
	public var sharedVertices:Bool;
	public var indices:Vector<Int>;
	public var geometry:OgreGeometry;
	public var operation:Int;
	public var textureAliases:Vector<OgreTextureAlias>;
	public var boneAssignments:Vector<OgreBoneAssignment>;
	public var indices32Bit:Bool;
	
	public function new()
	{
		geometry = new OgreGeometry();
		indices = new Vector<Int>();
		textureAliases = new Vector<OgreTextureAlias>();
		boneAssignments = new Vector<OgreBoneAssignment>();
	}
}

class OgreMesh
{
	public var skeletalAnimation:Bool;
	public var geometry:OgreGeometry;
	public var subMeshes:Vector<OgreSubMesh>;
	public var boneAssignments:Vector<OgreBoneAssignment>;
	public var boxMinEdge:Vector3D;
	public var boxMaxEdge:Vector3D;
	public var boxRadius:Float;
	
	public function new()
	{
		skeletalAnimation = false;
		geometry = new OgreGeometry();
		subMeshes = new Vector<OgreSubMesh>();
		boneAssignments = new Vector<OgreBoneAssignment>();
		boxMinEdge = new Vector3D();
		boxMaxEdge = new Vector3D();
		boxRadius = 0;
	}
}

class OgreBone
{
	public var name:String;
	public var position:Vector3D;
	public var orientation:Quaternion;
	public var scale:Vector3D;
	public var handle:Int;
	public var parent:Int;
	
	public function new()
	{
		position = new Vector3D();
		orientation = new Quaternion();
		scale = new Vector3D();
	}
}

class OgreKeyframe
{
	public var boneID:Int;
	public var time:Float;
	public var position:Vector3D;
	public var orientation:Quaternion;
	public var scale:Vector3D;
	
	public function new()
	{
		position = new Vector3D();
		orientation = new Quaternion();
		scale = new Vector3D(1,1,1);
	}
}

class OgreAnimation
{
	public var name:String;
	public var length:Float;
	public var keyframes:Vector<OgreKeyframe>;
	
	public function new()
	{
		keyframes = new Vector<OgreKeyframe>();
	}
}

class OgreSkeleton
{
	public var bones:Vector<OgreBone>;
	public var animations:Vector<OgreAnimation>;
	public function new()
	{
		bones = new Vector<OgreBone>();
		animations = new Vector<OgreAnimation>();
	}
}