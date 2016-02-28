package pixel3d.loader;

import flash.geom.Vector3D;
import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.Vector;
import pixel3d.events.MeshEvent;
import pixel3d.material.Material;
import pixel3d.math.AABBox;
import pixel3d.math.Color;
import pixel3d.math.MathUtil;
import pixel3d.math.Matrix4;
import pixel3d.math.Plane3D;
import pixel3d.math.Vertex;
import pixel3d.mesh.IMesh;
import pixel3d.mesh.MeshBuffer;
import pixel3d.mesh.Mesh;
import pixel3d.mesh.MeshBuffer;
import pixel3d.utils.Logger;

class Max3DSMeshLoader extends MeshLoader
{
	// Primary chunk
	public static inline var MAX_MAIN3DS : Int = 0x4D4D;
	
	// Main Chunks
	public static inline var MAX_EDIT3DS : Int = 0x3D3D;
	public static inline var MAX_KEYF3DS : Int = 0xB000;
	public static inline var MAX_VERSION : Int = 0x0002;
	public static inline var MAX_MESHVERSION : Int = 0x3D3E;
	
	// sub chunks of MAX_EDIT3DS
	public static inline var MAX_EDIT_MATERIAL : Int = 0xAFFF;
	public static inline var MAX_EDIT_OBJECT : Int	= 0x4000;
	
	// sub chunks of MAX_EDIT_MATERIAL
	public static inline var MAX_MATNAME : Int = 0xA000;
	public static inline var MAX_MATAMBIENT : Int = 0xA010;
	public static inline var MAX_MATDIFFUSE : Int = 0xA020;
	public static inline var MAX_MATSPECULAR : Int = 0xA030;
	public static inline var MAX_MATSHININESS : Int = 0xA040;
	public static inline var MAX_MATSHIN2PCT : Int = 0xA041;
	public static inline var MAX_TRANSPARENCY : Int = 0xA050;
	public static inline var MAX_TRANSPARENCY_FALLOFF : Int = 0xA052;
	public static inline var MAX_REFL_BLUR : Int = 0xA053;
	public static inline var MAX_TWO_SIDE : Int = 0xA081;
	public static inline var MAX_WIRE : Int = 0xA085;
	public static inline var MAX_SHADING : Int = 0xA100;
	public static inline var MAX_MATTEXMAP : Int = 0xA200;
	public static inline var MAX_MATSPECMAP : Int = 0xA204;
	public static inline var MAX_MATOPACMAP : Int = 0xA210;
	public static inline var MAX_MATREFLMAP : Int = 0xA220;
	public static inline var MAX_MATBUMPMAP : Int = 0xA230;
	public static inline var MAX_MATMAPFILE : Int = 0xA300;
	public static inline var MAX_MAT_TEXTILING : Int = 0xA351;
	public static inline var MAX_MAT_USCALE : Int = 0xA354;
	public static inline var MAX_MAT_VSCALE : Int = 0xA356;
	public static inline var MAX_MAT_UOFFSET : Int = 0xA358;
	public static inline var MAX_MAT_VOFFSET : Int = 0xA35A;
	
	// subs of MAX_EDIT_OBJECT
	public static inline var MAX_OBJTRIMESH : Int = 0x4100;
	
	// subs of MAX_OBJTRIMESH
	public static inline var MAX_TRIVERT : Int = 0x4110;
	public static inline var MAX_POINTFLAGARRAY : Int = 0x4111;
	public static inline var MAX_TRIFACE : Int = 0x4120;
	public static inline var MAX_TRIFACEMAT : Int = 0x4130;
	public static inline var MAX_TRIUV : Int = 0x4140;
	public static inline var MAX_TRISMOOTH : Int = 0x4150;
	public static inline var MAX_TRIMATRIX : Int = 0x4160;
	public static inline var MAX_MESHCOLOR : Int = 0x4165;
	public static inline var MAX_DIRECT_LIGHT : Int = 0x4600;
	public static inline var MAX_DL_INNER_RANGE : Int = 0x4659;
	public static inline var MAX_DL_OUTER_RANGE : Int = 0x465A;
	public static inline var MAX_DL_MULTIPLIER : Int = 0x465B;
	public static inline var MAX_CAMERA : Int = 0x4700;
	public static inline var MAX_CAM_SEE_CONE : Int = 0x4710;
	public static inline var MAX_CAM_RANGES : Int = 0x4720;
	
	// subs of MAX_KEYF3DS
	public static inline var MAX_KF_HDR : Int = 0xB00A;
	public static inline var MAX_AMBIENT_TAG : Int = 0xB001;
	public static inline var MAX_OBJECT_TAG : Int = 0xB002;
	public static inline var MAX_CAMERA_TAG : Int = 0xB003;
	public static inline var MAX_TARGET_TAG : Int = 0xB004;
	public static inline var MAX_LIGHTNODE_TAG : Int = 0xB005;
	public static inline var MAX_KF_SEG : Int = 0xB008;
	public static inline var MAX_KF_CURTIME : Int = 0xB009;
	public static inline var MAX_KF_NODE_HDR : Int = 0xB010;
	public static inline var MAX_PIVOTPOINT : Int = 0xB013;
	public static inline var MAX_BOUNDBOX : Int = 0xB014;
	public static inline var MAX_MORPH_SMOOTH : Int = 0xB015;
	public static inline var MAX_POS_TRACK_TAG : Int = 0xB020;
	public static inline var MAX_ROT_TRACK_TAG : Int = 0xB021;
	public static inline var MAX_SCL_TRACK_TAG : Int = 0xB022;
	public static inline var MAX_NODE_ID : Int = 0xB030;
	
	// Viewport definitions
	public static inline var MAX_VIEWPORT_LAYOUT : Int = 0x7001;
	public static inline var MAX_VIEWPORT_DATA : Int = 0x7011;
	public static inline var MAX_VIEWPORT_DATA_3 : Int = 0x7012;
	public static inline var MAX_VIEWPORT_SIZE : Int = 0x7020;
	
	// different color chunk types
	public static inline var MAX_COL_RGB : Int = 0x0010;
	public static inline var MAX_COL_TRU : Int = 0x0011;
	public static inline var MAX_COL_LIN_24 : Int = 0x0012;
	public static inline var MAX_COL_LIN_F : Int = 0x0013;
	
	// percentage chunk types
	public static inline var MAX_PERCENTAGE_I : Int = 0x0030;
	public static inline var MAX_PERCENTAGE_F : Int = 0x0031;
	
	
	private var vertices : Vector<Float>;
	private var indices : Vector<Int>;
	private var smothingGroups : Vector<Int>;
	private var tcoords : Vector<Float>;
	
	private var verticesCount : Int;
	private var facesCount : Int;
	private var tCoordsCount : Int;
	
	
	private var materialGroups : Vector<MaterialGroup>;
	private var currentMaterial : CurrentMaterial;
	private var materials : Vector<CurrentMaterial>;
	private var meshBufferNames : Vector<String>;
	private var transformMatrix : Matrix4;
	
	private var mesh : Mesh;
	private var parentChunkData : ChunkData;
	
	public function new(type:Int = 0)
	{
		super(type);
		
		materials = new Vector<CurrentMaterial>();
		meshBufferNames = new Vector<String>();
		transformMatrix = new Matrix4();
		currentMaterial = new CurrentMaterial();
		materialGroups = new Vector<MaterialGroup>();
	}
	
	override public function loadBytes(data:ByteArray, type:Int):Void
	{
		switch(type)
		{
			case 0: 
			{
				createStaticMesh(data);
			}
		}
		dispatchEvent(new MeshEvent(MeshEvent.COMPLETE, mesh));
	}
	
	public function createStaticMesh(data : ByteArray) : IMesh
	{
		if(data == null) return null;
		cleanUp();
		
		data.endian = Endian.LITTLE_ENDIAN;
		data.position = 0;
		
		parentChunkData = new ChunkData();
		readChunkData(data, parentChunkData);
		
		if(parentChunkData.header.id != MAX_MAIN3DS)
		{
			return null;
		}
		
		mesh = new Mesh();
		
		if(readChunk(data, parentChunkData))
		{
			// success
			var i : Int = 0;
			while(i <mesh.getMeshBufferCount())
			{
				var mb : MeshBuffer = mesh.getMeshBuffer(i);
				if(mb.getIndexCount() == 0 || mb.getVertexCount() == 0)
				{
					mesh.getMeshBuffers().splice(i, 1);
				} 
				else
				{
					mb.recalculateBoundingBox();
					i++;
				}
			}

			mesh.recalculateBoundingBox();
			
			return mesh;
		}
		return null;
	}
	
	private function readChunkData(byteArray : ByteArray, data : ChunkData) : Void
	{
		// read a header
		data.header = new ChunkHeader();
		data.header.id = byteArray.readUnsignedShort();
		data.header.length = byteArray.readInt();
		data.read += 6;//(u16 + s32) ==(2 + 4);
	}
	
	private function readChunk(byteArray : ByteArray, parent : ChunkData) : Bool
	{
		#if debug
		    Logger.log("---------readChunk:--------------");
		#end

		while(parent.read < parent.header.length)
		{
			var data : ChunkData = new ChunkData();
			readChunkData(byteArray, data);
			
			switch(data.header.id)
			{
				case MAX_VERSION :
				{
					var version : Int = byteArray.readUnsignedShort();
					byteArray.position += (data.header.length - data.read - 2);
					data.read = data.header.length;
					if(version != 0x03)
					{
						Logger.log("Cannot load 3ds files of version other than 3.",Logger.ERROR);
						return false;
					}
				}
				case MAX_EDIT_MATERIAL :
				{
					readMaterialChunk(byteArray, data);
				}
				case MAX_KEYF3DS :
				{
					readFrameChunk(byteArray, data);
				}
				case MAX_EDIT3DS :
				{
				}
				case MAX_MESHVERSION, 0x01 :
				{
					var version : Int = byteArray.readUnsignedInt();
					data.read += 4;//sizeof(u32);
				}
				case MAX_EDIT_OBJECT :
				{
					var name : String = readString(byteArray, data);
					readObjectChunk(byteArray, data);
					composeObject(byteArray, name);
				}
				default :
				{
					// ignore chunk
					byteArray.position +=(data.header.length - data.read);
					data.read = data.header.length;
				}
			}
			
			parent.read += data.read;
		}
		return true;
	}
	private function readPercentageChunk(byteArray : ByteArray, chunk : ChunkData) : Float
	{
		#if debug
		    Logger.log("---------readPercentageChunk:--------------");
		#end
		
		var data : ChunkData = new ChunkData();
		readChunkData(byteArray, data);
		
		var intpercentage : Int;
		var fpercentage : Float = 0.0;
		switch(data.header.id)
		{
			case MAX_PERCENTAGE_I :
			{
				// read short
				intpercentage = byteArray.readShort();
				fpercentage = intpercentage * 0.01;
				data.read += 2;
			}
			case MAX_PERCENTAGE_F :
			{
				// read float
				fpercentage = byteArray.readFloat();
				data.read += 4;
			}
			default :
			{
				//Unknown percentage chunk in 3Ds file.;
				byteArray.position += data.header.length - data.read;
				data.read = data.header.length;
			}
		}
		chunk.read += data.read;
		return fpercentage;
	}
	private function readColorChunk(byteArray : ByteArray, chunk : ChunkData) : Color
	{
		#if debug
		    Logger.log("Load color chunk.");
		#end
		
		var data : ChunkData = new ChunkData();
		readChunkData(byteArray, data);
		
		var color : Color = new Color();
		switch(data.header.id)
		{
			case MAX_COL_TRU,MAX_COL_LIN_24 :
			{
				// read 8 bit data
				color.setRGBA(byteArray.readUnsignedByte() , byteArray.readUnsignedByte() , byteArray.readUnsignedByte() , 255);
				data.read += 3;
			}
			case MAX_COL_RGB,MAX_COL_LIN_F :
			{
				// read float data
				color.setPercent(byteArray.readFloat() , byteArray.readFloat() , byteArray.readFloat() , 1);
				data.read += 12;//sizeof(f32);
			}
			default :
			{
				//Unknown size of color chunk in 3Ds file;
				byteArray.position += data.header.length - data.read;
				data.read = data.header.length;
			}
		}
		
		chunk.read += data.read;
		
		return color;
	}
	private function readMaterialChunk(byteArray : ByteArray, parent : ChunkData) : Bool
	{
		#if debug
		    Logger.log("Load material chunk.");
		#end
		
		var matSection : Int = 0;
		while(parent.read <parent.header.length)
		{
			var data : ChunkData = new ChunkData();
			readChunkData(byteArray, data);
			
			switch(data.header.id)
			{
				case MAX_MATNAME :
				{
					var c : String = byteArray.readUTFBytes(data.header.length - data.read);
					if(c.length> 0)
					{
						currentMaterial.setName(c);
					}
					data.read = data.header.length;
				}
				case MAX_MATAMBIENT :
					currentMaterial.material.ambientColor = readColorChunk(byteArray, data);
				case MAX_MATDIFFUSE :
					currentMaterial.material.diffuseColor = readColorChunk(byteArray, data);
				case MAX_MATSPECULAR :
					currentMaterial.material.specularColor = readColorChunk(byteArray, data);
				case MAX_MATSHININESS :
					currentMaterial.material.shininess =(1.0 - currentMaterial.material.shininess) * 128.;
				case MAX_TRANSPARENCY :
				{
					var percentage : Float = readPercentageChunk(byteArray, data);
					if(percentage> 0.0)
					{
						currentMaterial.material.transparenting = true;
						currentMaterial.material.alpha = percentage;
						//currentMaterial.material.alphaType = Material.MATERIAL_ALPHA_VERTEX;
					}
					else 
					{
						currentMaterial.material.transparenting = false;
					}
				}
				case MAX_WIRE :
					currentMaterial.material.wireframe = true;
				case MAX_TWO_SIDE :
					currentMaterial.material.backfaceCulling = false;
					currentMaterial.material.frontfaceCulling = false;
				case MAX_SHADING :
				{
					var flags : Int = byteArray.readShort();
					switch(flags)
					{
						case 0 :
							currentMaterial.material.wireframe = true;
						case 1 :
							currentMaterial.material.wireframe = false;
							currentMaterial.material.gouraudShading = false;
						case 2 :
							currentMaterial.material.wireframe = false;
							currentMaterial.material.gouraudShading = true;
						default :
						// phong and metal missing
					}
					data.read = data.header.length;
				}
				case MAX_MATTEXMAP, MAX_MATSPECMAP, MAX_MATOPACMAP, MAX_MATREFLMAP, MAX_MATBUMPMAP :
				{
					matSection = data.header.id;
					
					// Should contain a percentage chunk, but does
					// not always have it
					var position : UInt = byteArray.position;
					var testvar : Int = byteArray.readShort();
					byteArray.position = position;
					
					if(testvar == MAX_PERCENTAGE_I || testvar == MAX_PERCENTAGE_F)
					{
						switch(matSection)
						{
							case MAX_MATTEXMAP  : currentMaterial.strengths[0] = readPercentageChunk(byteArray, data);
							case MAX_MATSPECMAP : currentMaterial.strengths[1] = readPercentageChunk(byteArray, data);
							case MAX_MATOPACMAP : currentMaterial.strengths[2] = readPercentageChunk(byteArray, data);
							case MAX_MATREFLMAP : currentMaterial.strengths[3] = readPercentageChunk(byteArray, data);
							case MAX_MATBUMPMAP : currentMaterial.strengths[4] = readPercentageChunk(byteArray, data);
						}
					}
				}
				case MAX_MATMAPFILE :
				{
					// read texture file name
					var c : String = byteArray.readUTFBytes(data.header.length - data.read);
					switch(matSection)
					{
						case MAX_MATTEXMAP  : 
						{
							currentMaterial.filenames[0] = c;
							currentMaterial.material.extra.texturePath = c;
						}
						case MAX_MATSPECMAP : currentMaterial.filenames[1] = c;
						case MAX_MATOPACMAP : currentMaterial.filenames[2] = c;
						case MAX_MATREFLMAP : currentMaterial.filenames[3] = c;
						case MAX_MATBUMPMAP : currentMaterial.filenames[4] = c;
					}
					data.read = data.header.length;
				}
				case MAX_MAT_TEXTILING :
				{
					byteArray.readShort();
					data.read += 2;
				}
				case MAX_MAT_USCALE, MAX_MAT_VSCALE, MAX_MAT_UOFFSET, MAX_MAT_VOFFSET :
				{
					byteArray.readFloat();
					data.read += 4;
				}
				default :
				{
					// ignore chunk
					byteArray.position += data.header.length - data.read;
					data.read = data.header.length;
				}
			}
			parent.read += data.read;
		}
		
		materials.push(currentMaterial);
		currentMaterial = new CurrentMaterial();
		return true;
	}
	private function readTrackChunk(byteArray : ByteArray, data : ChunkData, mb : MeshBuffer, pivot : Vector3D) : Bool
	{
		#if debug
		    Logger.log("Load track chunk.");
		#end
		
		//u16 flags;
		//u32 flags2;
		// Track flags
		byteArray.readUnsignedShort();
		byteArray.readUnsignedInt();
		byteArray.readUnsignedInt();
		// Num keys
		byteArray.readUnsignedInt();
		byteArray.readUnsignedInt();
		// TCB flags
		byteArray.readUnsignedShort();
		data.read += 20;
		
		var angle : Float = 0.0;
		if(data.header.id == MAX_ROT_TRACK_TAG)
		{
			// Angle
			angle = byteArray.readFloat();
			data.read += 4;
			//sizeof(f32);
			
		}
		var vec : Vector3D = new Vector3D(byteArray.readFloat() , byteArray.readFloat() , byteArray.readFloat());
		data.read += 12;
		vec.decrementBy(pivot);
		
		// apply transformation to mesh buffer
		if(false) //mb != null)
		{
			var vertices : Vector<Vertex>= mb.getVertices();
			if(data.header.id == MAX_POS_TRACK_TAG)
			{
				var len:Int = mb.getVertexCount();
				for(i in 0...len)
				{
				    var vertex:Vertex = vertices[i];
				    vertex.x += vec.x;
					vertex.y += vec.y;
					vertex.z += vec.z;
				}
			} 
			else if(data.header.id == MAX_ROT_TRACK_TAG)
			{
				//TODO
				
			} 
			else if(data.header.id == MAX_SCL_TRACK_TAG)
			{
				//TODO
				
			}
		}
		
		// skip further frames
		byteArray.position += data.header.length - data.read;
		data.read = data.header.length;
		return true;
	}
	private function readFrameChunk(byteArray : ByteArray, parent : ChunkData) : Bool
	{
		#if debug
		    Logger.log("Load frame chunk.");
		#end
		
		//KF_HDR is always at the beginning
		var data : ChunkData = new ChunkData();
		readChunkData(byteArray, data);
		
		if(data.header.id != MAX_KF_HDR)
		{
			return false;
		} 
		else 
		{
			var version : Int = byteArray.readUnsignedShort();//u16
			var name : String = readString(byteArray, data);
			var flags : Int = byteArray.readUnsignedInt();//u32
			data.read += data.header.length;
			parent.read += data.read;
		}
		
		data.read = 0;
		var mb : MeshBuffer = null;
		var pivot : Vector3D = new Vector3D();
		var bboxCenter : Vector3D = new Vector3D();
		while(parent.read <parent.header.length)
		{
			readChunkData(byteArray, data);
			switch(data.header.id)
			{
				case MAX_OBJECT_TAG :
				{
					#if debug
					    Logger.log("Load object tag.");
					#end
					mb = null;
					pivot.x = pivot.y = pivot.z = 0;
				}
				case MAX_KF_SEG :
				{
					#if debug
					    Logger.log("Load keyframe segment.");
					#end
					
					var flags : UInt = byteArray.readUnsignedInt();
					flags = byteArray.readUnsignedInt();
					data.read += 8;
				}
				case MAX_KF_NODE_HDR :
				{
					#if debug
					    Logger.log("Load keyframe node header.");
					#end
					
					var c : String = byteArray.readUTFBytes(data.header.length - data.read - 6);
					
					// search mesh buffer to apply these transformations to
					var len : Int = meshBufferNames.length;
					for(i in 0...len)
					{
						if(meshBufferNames[i] == c)
						{
							mb = mesh.getMeshBuffer(i);
							break;
						}
					}
					var flags : Int = byteArray.readShort();
					flags = byteArray.readShort();
					flags = byteArray.readShort();
					data.read = data.header.length;
				}
				case MAX_KF_CURTIME :
				{
					#if debug
					    Logger.log("Load keyframe current time.");
					#end
					
					var flags : UInt = byteArray.readUnsignedInt();
					data.read = data.header.length;
				}
				case MAX_NODE_ID :
				{
					#if debug
					    Logger.log("Load node ID.");
					#end
					
					var flags : UInt = byteArray.readUnsignedShort();
					data.read += 2;
				}
				case MAX_PIVOTPOINT :
				{
					#if debug
					    Logger.log("Load pivot point.");
					#end
					
					pivot.x = byteArray.readFloat();
					pivot.y = byteArray.readFloat();
					pivot.z = byteArray.readFloat();
					data.read = data.header.length;//12
				}
				case MAX_BOUNDBOX :
				{
					#if debug
					    Logger.log("Load bounding box.");
					#end
					
					var bbox : AABBox = new AABBox();
					// abuse bboxCenter as temporary variable
					bboxCenter.x = byteArray.readFloat();
					bboxCenter.y = byteArray.readFloat();
					bboxCenter.z = byteArray.readFloat();
					bbox.resetVector(bboxCenter);
					bboxCenter.x = byteArray.readFloat();
					bboxCenter.y = byteArray.readFloat();
					bboxCenter.z = byteArray.readFloat();
					bbox.addInternalVector(bboxCenter);
					bboxCenter = bbox.getCenter();
					data.read += data.header.length - 24;
				}
				case MAX_MORPH_SMOOTH :
				{
					#if debug
					    Logger.log("Load bounding box.");
					#end
					
					var flag : Float = byteArray.readFloat();//f32
					data.read += 4;
				}
				case MAX_POS_TRACK_TAG, MAX_ROT_TRACK_TAG, MAX_SCL_TRACK_TAG :
				{
					readTrackChunk(byteArray, data, mb, bboxCenter.subtract(pivot));
				}
				default :
				{
					// ignore chunk
					byteArray.position += data.header.length - data.read;
					data.read = data.header.length;
				}
			}
			
			parent.read += data.read;
			data.read = 0;
		}
		return true;
	}
	private function readObjectChunk(byteArray : ByteArray, parent : ChunkData) : Bool
	{
		#if debug
		    Logger.log("Load object chunk.");
		#end
		
		while (parent.read < parent.header.length)
		{
			var data : ChunkData = new ChunkData();
			readChunkData(byteArray, data);
			
			switch(data.header.id)
			{
				case MAX_OBJTRIMESH :
					readObjectChunk(byteArray, data);
				case MAX_TRIVERT :
					readVertices(byteArray, data);
				case MAX_POINTFLAGARRAY :
				{
					var numVertex : Int = byteArray.readUnsignedShort();
					for(i in 0...numVertex)
					{
						var flags : Int = byteArray.readUnsignedShort();
					}
					data.read +=(numVertex + 1) * 2;
				}
				case MAX_TRIFACE :
					readIndices(byteArray, data);
					readObjectChunk(byteArray, data);// read smooth and material groups
				case MAX_TRIFACEMAT :
					readMaterialGroup(byteArray, data);
				case MAX_TRIUV : // getting texture coordinates
					readTextureCoords(byteArray, data);
				case MAX_TRIMATRIX :
				{
					var mat : Vector<Vector<Float>>= new Vector<Vector<Float>>(4);
					for(i in 0...4)
					{
						mat[i] = new Vector<Float>(3);
						for(j in 0...3)
						{
							mat[i][j] = byteArray.readFloat();
						}
					}
					transformMatrix.identity();
					transformMatrix.m11 = mat[0][0];
					transformMatrix.m12 = mat[0][1];
					transformMatrix.m13 = mat[0][2];
					transformMatrix.m21 = mat[1][0];
					transformMatrix.m22 = mat[1][1];
					transformMatrix.m23 = mat[1][2];
					transformMatrix.m31 = mat[2][0];
					transformMatrix.m32 = mat[2][1];
					transformMatrix.m33 = mat[2][2];
					transformMatrix.m41 = mat[3][0];
					transformMatrix.m42 = mat[3][1];
					transformMatrix.m43 = mat[3][2];
					mat = null;
					data.read +=(12 * 4);//12*sizeof(f32);
				}
				case MAX_MESHCOLOR :
				{
					var flag : Int = byteArray.readUnsignedByte();//u8
					data.read ++;
				}
				case MAX_TRISMOOTH : // TODO
				{
					smothingGroups = new Vector<Int>(facesCount);
					for(i in 0...facesCount)
					{
						smothingGroups[i] = byteArray.readUnsignedInt();
					}
					data.read += facesCount * 4;
				}
				default :
				{
					// ignore chunk
					byteArray.position += data.header.length - data.read;
					data.read = data.header.length;
				}
			}
			
			parent.read += data.read;
		}
		return true;
	}
	private function composeObject(byteArray : ByteArray, name : String) : Void
	{
		var length:Int = materials.length;
		if(mesh.getMeshBufferCount() != length)
		{
			loadMaterials(byteArray);
		}
		
		var currentMat : CurrentMaterial = new CurrentMaterial();
		if(materialGroups.length == 0)
		{
			// no material group, so add all
			var group : MaterialGroup = new MaterialGroup();
			group.faceCount = facesCount;
			for(i in 0...facesCount)
			{
				group.faces[i] = i;
			}
			materialGroups.push(group);
			
			// if we've got no material, add one without a texture
			if(materials.length == 0)
			{
				currentMat = new CurrentMaterial();
				materials.push(currentMat);
				
				var buffer : MeshBuffer = new MeshBuffer();
				buffer.setMaterial(currentMaterial.material);
				mesh.addMeshBuffer(buffer);
				// add an empty mesh buffer name
				meshBufferNames.push("");
			}
		}
        
		var tmp_plane : Plane3D = new Plane3D();
		var len : Int = materialGroups.length;
		for(i in 0...len)
		{
			var buffer : MeshBuffer = null ;
			var mat : Material = null ;
			
			// find mesh buffer for this group
			var mat_group : MaterialGroup = materialGroups[i];
			var matLen : Int = materials.length;
			for(j in 0...matLen)
			{
				currentMat = materials[j];
				if(mat_group.materialName == currentMat.name)
				{
					buffer = mesh.getMeshBuffer(j);
					mat = currentMat.material;
					meshBufferNames[j] = name;
					break;
				}
			}
			
			if(buffer != null)
			{
				// add geometry to the buffer.
				var color : UInt = mat.diffuseColor.color;
				//if(mat->MaterialType==video::EMT_TRANSPARENT_VERTEX_ALPHA)
				//{
				//	vtx.Color.setAlpha((int)(255.0f*mat->MaterialTypeParam));
				//}
				
				var buffer_vertices:flash.Vector<Vertex> = buffer.getVertices();
				var buffer_indices:flash.Vector<Int> = buffer.getIndices();
				
				var flen : Int = mat_group.faceCount;
				for(f in 0...flen)
				{
					var vtxCount : Int = buffer_vertices.length;
					var idx0 : Int =(mat_group.faces[f] * 4);
					for(v in 0...3)
					{
						var vtx : Vertex = new Vertex();
						vtx.color = color;
						var idx : Int = indices[(idx0 + v)];
						if(verticesCount> idx)
						{
							vtx.x = vertices[((idx * 3) + 0)];
							vtx.z = vertices[((idx * 3) + 1)];
							vtx.y = vertices[((idx * 3) + 2)];
						}
						if(tCoordsCount> idx)
						{
							vtx.u = MathUtil.clamp(tcoords[(idx * 2)] , 0, 1);
							vtx.v = MathUtil.clamp((1.0 - tcoords[(idx * 2) + 1]) , 0, 1);
						}
						buffer_vertices.push(vtx);
					}
					
					// compute normal
					var v0 : Vertex = buffer_vertices[vtxCount];
					var v1 : Vertex = buffer_vertices[vtxCount + 2];
					var v2 : Vertex = buffer_vertices[vtxCount + 1];
					
					tmp_plane.setPlane3(v0.position, v1.position, v2.position);
					
					v0.nx = v1.nx = v2.nx = tmp_plane.normal.x;
					v0.ny = v1.ny = v2.ny = tmp_plane.normal.y;
					v0.nz = v1.nz = v2.nz = tmp_plane.normal.z;
					
					// add indices
					buffer_indices.push(vtxCount);
					buffer_indices.push(vtxCount + 2);
					buffer_indices.push(vtxCount + 1);
				}
				
				buffer.recalculateBoundingBox();
			} 
			else
			{
				Logger.log("Found no matching material for Group in 3ds file.",Logger.WARNING);
			}
		} 
		
		cleanUp();
	}
	private function getTextureFileName(texture : String, model : String) : String
	{
		var idx : Int = model.lastIndexOf('/');
		if(idx == - 1)
		{
			idx = model.lastIndexOf('\\');
		}
		if(idx == - 1)
		{
			return "";
		}
		return untyped model.substring(0, idx + 1) + texture;
	}
	
	private function loadMaterials(byteArray : ByteArray) : Void
	{
		// create a mesh buffer for every material
		//var modelFilename:String = byteArray.fileName;
		if(materials.length == 0)
		{
			Logger.log("No materials found in 3ds file.");
		}
		
		var len : Int = materials.length;
		meshBufferNames.length = 0;
		for(i in 0...len)
		{
			meshBufferNames.push("");
			
			var buffer : MeshBuffer = new MeshBuffer();
			buffer.setMaterial(materials[i].material);
			mesh.addMeshBuffer(buffer);
		}
	}
	
	private function cleanUp() : Void
	{
		vertices = new Vector<Float>();
		verticesCount = 0;
		indices = new Vector<Int>();
		facesCount = 0;
		smothingGroups = new Vector<Int>();
		tcoords = new Vector<Float>();
		tCoordsCount = 0;
		materialGroups.length = 0;
	}
	private function readTextureCoords(byteArray : ByteArray, data : ChunkData) : Void
	{
		#if debug
		    Logger.log("Load texture coords.");
		#end
		
		tCoordsCount = byteArray.readUnsignedShort();
		data.read += 2;//u16
		
		var tcoordsBufferByteSize : Int = tCoordsCount * 4 * 2;
		if((data.header.length - data.read) != tcoordsBufferByteSize)
		{
			Logger.log("Invalid size of tcoords found in 3ds file.");
			return;
		}
		
		var len : Int =(tCoordsCount * 2);
		for(i in 0...len)
		{
			tcoords[i] = byteArray.readFloat();
		}
		data.read += tcoordsBufferByteSize;
	}
	
	private function readMaterialGroup(byteArray : ByteArray, data : ChunkData) : Void
	{
		#if debug
		    Logger.log("Load material group.");
		#end
		
		var group : MaterialGroup = new MaterialGroup();
		group.materialName = readString(byteArray, data);
		group.faceCount = byteArray.readUnsignedShort();
		data.read += 2;

		// read faces
		var len : Int = group.faceCount;
		for(i in 0...len)
		{
			group.faces[i] = byteArray.readShort();
		}
		data.read += 2 * group.faceCount;
		
		materialGroups.push(group);
	}
	private function readIndices(byteArray : ByteArray, data : ChunkData) : Void
	{
		#if debug
		    Logger.log("Load indices.");
		#end
		
		facesCount = byteArray.readUnsignedShort();
		data.read += 2;

		var indexBufferByteSize : Int = facesCount * 2 * 4;
		
		// Indices are u16s.
		// After every 3 Indices in the array, there follows an edge flag.
		var len : Int =(facesCount * 4);
		for(i in 0...len)
		{
			indices[i] = byteArray.readUnsignedShort();
		}
		data.read += indexBufferByteSize;
	}
	private function readVertices(byteArray : ByteArray, data : ChunkData) : Void
	{
		#if debug
		    Logger.log("Load vertices.");
		#end
		
		verticesCount = byteArray.readUnsignedShort();
		data.read += 2;

		var vertexBufferByteSize : Int = verticesCount * 4 * 3;
		
		if((data.header.length - data.read) != vertexBufferByteSize)
		{
			Logger.log("Invalid size of vertices found in 3ds file.");
			return;
		}
		
		// read a float for each x,y,z for each vertex
		var len : Int =(verticesCount * 3);
		for(i in 0...len)
		{
			vertices[i] = byteArray.readFloat();
		}
		data.read += vertexBufferByteSize;
	}
	private function readString(byteArray : ByteArray, data : ChunkData) : String
	{
		var c : UInt = 1;
		var out : String = "";
		while(c != 0)
		{
			c = byteArray.readUnsignedByte();
			if(c != 0)
			{
				out +=(String.fromCharCode(c));
			}
			data.read ++;
		}
		return out;
	}
}
class ChunkHeader
{
	public var id : Int;
	public var length : Int;
	public function new()
	{
		id = 0;
		length = 0;
	}
}
class ChunkData
{
	public var header : ChunkHeader;
	public var read : Int;
	public function new()
	{
		read = 0;
	}
}
class CurrentMaterial
{
	public var material : Material ;
	public var name : String;
	public var filenames : Vector<String>;
	public var strengths : Vector<Float>;
	public function new()
	{
		material = new Material();
		name = "";
		filenames = new Vector<String>(5, true);
		for(i in 0...5)
		{
			filenames[i] = "";
		}
		strengths = new Vector<Float>(5, true);
		for(i in 0...5)
		{
			strengths[i] = 0.0;
		}
	}
	public function setName(n : String) : Void
	{
		name = n;
		material.name = n;
	}
	public function clear() : Void
	{
		name = "";
		material = new Material();
		filenames[0] = "";
		filenames[1] = "";
		filenames[2] = "";
		filenames[3] = "";
		filenames[4] = "";
		strengths[0] = 0.0;
		strengths[1] = 0.0;
		strengths[2] = 0.0;
		strengths[3] = 0.0;
		strengths[4] = 0.0;
	}
}
class MaterialGroup
{
	public var materialName : String;
	public var faceCount : Int;//u16;
	public var faces : Vector<Int>;//u16*
	public function new()
	{
		materialName = "";
		faces = new Vector<Int>();
		faceCount = 0;
	}
	public function clear() : Void
	{
		faces.length = 0;
		faces = null;
		faceCount = 0;
	}
	public function copy(other : MaterialGroup) : Void
	{
		materialName = other.materialName;
		faceCount = other.faceCount;
		faces = other.faces.concat(null);
	}
}
