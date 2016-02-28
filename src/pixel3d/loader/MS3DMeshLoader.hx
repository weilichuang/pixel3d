package pixel3d.loader;
import pixel3d.events.MeshEvent;
import pixel3d.material.Material;
import pixel3d.math.Matrix4;
import pixel3d.mesh.IMesh;
import pixel3d.mesh.MeshBuffer;
import pixel3d.mesh.Mesh;
import pixel3d.mesh.MeshBuffer;
import pixel3d.mesh.MeshManipulator;
import pixel3d.mesh.skin.Joint;
import pixel3d.mesh.skin.PositionKey;
import pixel3d.mesh.skin.RotationKey;
import pixel3d.mesh.skin.Weight;
import pixel3d.utils.Logger;
import pixel3d.math.MathUtil;
import flash.geom.Vector3D;
import pixel3d.math.Color;
import pixel3d.math.Plane3D;
import pixel3d.math.Vertex;
import pixel3d.mesh.SkinnedMesh;
import pixel3d.mesh.SkinnedMeshBuffer;
import flash.Vector;
import flash.utils.ByteArray;
import flash.utils.Endian;

 //-------------base on MilkShape 3D Model Viewer Sample------------//
class MS3DMeshLoader extends MeshLoader
{
	public function new(type:Int=2)
	{
		super(type);
	}
	
	override public function loadBytes(data:ByteArray, type:Int):Void
	{
		var mesh:IMesh = null;
		switch(type)
		{
			case 0: 
			{
				mesh = createStaticMesh(data);
			}
			case 2:
			{
				mesh = createSkinnedMesh(data);
			}
		}
		dispatchEvent(new MeshEvent(MeshEvent.COMPLETE, mesh));
	}
	
	/**
	 * 根据ms3d模型数据生成静态模型，生成的模型没有骨骼等数据
	 * @param	data
	 * @return 静态模型
	 */
	public function createStaticMesh(data : ByteArray) : IMesh
	{
		if(data == null || data.length == 0)
		{
			#if debug
			Logger.log("Not a valid Milkshape3D Model File.", Logger.ERROR);
			#end
			return null;
		}
		data.endian = Endian.LITTLE_ENDIAN;
		data.position = 0;
		// read header
		var id : String = data.readUTFBytes(10);
		if(id != "MS3D000000")
		{
			#if debug
			Logger.log("Not a valid Milkshape3D Model File.", Logger.ERROR);
			#end
			return null;
		}
		var version : Int = data.readInt();
		#if debug
		Logger.log("MS3D File Version : " + version, Logger.INFORMATION);
		#end
		if(version <3 || version> 4)
		{
			#if debug
			Logger.log("Only Milkshape3D version 3 and 4(1.3 to 1.8) is supported.", Logger.ERROR);
			#end
			return null;
		}
		var mesh : Mesh = new Mesh();
		//顶点数
		var numVertices : Int = data.readUnsignedShort();
		
		#if debug
		Logger.log("numVertices=" + numVertices);
		#end
		
		var ms3dVertices : Vector<MS3DVertex>= new Vector<MS3DVertex>(numVertices);
		for(i in 0...numVertices)
		{
			var ms3dVertex : MS3DVertex = new MS3DVertex();
			ms3dVertex.flags = data.readUnsignedByte();
			ms3dVertex.x = data.readFloat();
			ms3dVertex.y = data.readFloat();
			ms3dVertex.z = - data.readFloat();
			ms3dVertex.boneID = data.readUnsignedByte();
			ms3dVertex.refCount = data.readUnsignedByte();
			ms3dVertices[i] = ms3dVertex;
		}
		//triangles
		var numTriangles : Int = data.readUnsignedShort();
		var triangles : Vector<MS3DTriangle> = new Vector<MS3DTriangle>(numTriangles);
		for(i in 0...numTriangles)
		{
			var triangle : MS3DTriangle = new MS3DTriangle();
			triangle.flags = data.readUnsignedShort();
			triangle.indices[0] = data.readUnsignedShort();
			triangle.indices[1] = data.readUnsignedShort();
			triangle.indices[2] = data.readUnsignedShort();
			triangle.normals[0].x = data.readFloat();
			triangle.normals[1].x = data.readFloat();
			triangle.normals[2].x = data.readFloat();
			triangle.normals[0].y = data.readFloat();
			triangle.normals[1].y = data.readFloat();
			triangle.normals[2].y = data.readFloat();
			triangle.normals[0].z = - data.readFloat();
			triangle.normals[1].z = - data.readFloat();
			triangle.normals[2].z = - data.readFloat();
			triangle.tUs[0] = data.readFloat();
			triangle.tUs[1] = data.readFloat();
			triangle.tUs[2] = data.readFloat();
			triangle.tVs[0] = data.readFloat();
			triangle.tVs[1] = data.readFloat();
			triangle.tVs[2] = data.readFloat();
			triangle.smoothingGroup = data.readUnsignedByte();
			triangle.groupIndex = data.readUnsignedByte();
			triangles[i] = triangle;
		}
		//groups
		var numGroups : Int = data.readUnsignedShort();
		var groups : Vector<MS3DGroup>= new Vector<MS3DGroup>(numGroups);
		for(i in 0...numGroups)
		{
			var group : MS3DGroup = new MS3DGroup();
			data.position += 1;
			//1 byte flags
			group.name = data.readUTFBytes(32);
			var triangleCount : Int = data.readUnsignedShort();
			// triangle indices
			group.indices = new Vector<Int>(triangleCount);
			for(j in 0...triangleCount)
			{
				group.indices[j] = data.readUnsignedShort();
			}
			group.materialID = data.readUnsignedByte();
			// material index
			if(group.materialID == 255) group.materialID = 0;
			groups[i] = group;
		}
		
		// materials
		var numMaterials : Int = data.readUnsignedShort();
		var buffer : MeshBuffer;
		if(numMaterials == 0)
		{
			// if there are no materials, add at least one buffer
			mesh.addMeshBuffer(new MeshBuffer());
		}
		
		for(i in 0...numMaterials)
		{
			buffer = new MeshBuffer();
			mesh.addMeshBuffer(buffer);
			var mat : Material = buffer.getMaterial();
			mat.name = data.readUTFBytes(32);
			
			mat.ambientColor.r =(data.readFloat() * 255);
			mat.ambientColor.g =(data.readFloat() * 255);
			mat.ambientColor.b =(data.readFloat() * 255);
			mat.ambientColor.a =(data.readFloat() * 255);

			mat.diffuseColor.r =(data.readFloat() * 255);
			mat.diffuseColor.g =(data.readFloat() * 255);
			mat.diffuseColor.b =(data.readFloat() * 255);
			mat.diffuseColor.a =(data.readFloat() * 255);

			mat.emissiveColor.r =(data.readFloat() * 255);
			mat.emissiveColor.g =(data.readFloat() * 255);
			mat.emissiveColor.b =(data.readFloat() * 255);
			mat.emissiveColor.a =(data.readFloat() * 255);

			mat.specularColor.r =(data.readFloat() * 255);
			mat.specularColor.g =(data.readFloat() * 255);
			mat.specularColor.b =(data.readFloat() * 255);
			mat.specularColor.a =(data.readFloat() * 255);

			mat.shininess = data.readFloat();
			mat.alpha = data.readFloat();

			if(mat.alpha <1)
			{
				mat.transparenting = true;
			}
			data.readUnsignedByte();
			//mode
			var texfile : String = data.readUTFBytes(128);
			
			#if debug
			    Logger.log("texture file=" + texfile);
			#end
			
			mat.extra.texturePath = texfile;
			
			//alphaMap
			var alphaMap : String = data.readUTFBytes(128);
			
			#if debug
			    Logger.log("alphaMap=" + alphaMap);
			#end
			
			mat.extra.texturePath2 = alphaMap;
		}
		data.position = 0;//reset data position to 0
		
		//static mesh don`t need joint and weight,so ignore it.
		
		// create vertices and indices
		var vertex : Vertex;
		var vertices : Vector<Vertex>;
		var indices : Vector<Int> = new Vector<Int>();
		var triangle : MS3DTriangle;
		var buffers : Vector<MeshBuffer> = mesh.getMeshBuffers();
		for(i in 0...numTriangles)
		{
			triangle = triangles[i];
			var groupIndex : Int = triangle.groupIndex;
			var tmp : Int = groups[groupIndex].materialID;
			vertices = buffers[tmp].getVertices();
			var group : MS3DGroup = groups[groupIndex];
			var j : Int = 2;
			while(j> - 1)
			{
				vertex = new Vertex();
				vertex.u = triangle.tUs[j];
				vertex.v = triangle.tVs[j];
				vertex.nx = triangle.normals[j].x;
				vertex.ny = triangle.normals[j].y;
				vertex.nz = triangle.normals[j].z;
				vertex.x = ms3dVertices[triangle.indices[j]].x;
				vertex.y = ms3dVertices[triangle.indices[j]].y;
				vertex.z = ms3dVertices[triangle.indices[j]].z;
				var index : Int = - 1;
				var len : Int = vertices.length;
				for(iv in 0...len)
				{
					if(vertex.equals(vertices[iv]))
					{
						index = iv;
						break;
					}
				}
				if(index == - 1 )
				{
					index = vertices.length;
					vertices.push(vertex);
				}
				indices.push(index);
				j --;
			}
		}
		//create groups
		var iIndex : Int = - 1;
		var len : Int = groups.length;
		for(i in 0...len)
		{
			var grp : MS3DGroup = groups[i];
			if(grp.materialID>= mesh.getMeshBufferCount())
			{
				grp.materialID = 0;
			}
			var buffer : MeshBuffer = mesh.getMeshBuffer(grp.materialID);
			var bufferIndices : Vector<Int>= buffer.getIndices();
			var groupIndexCount : Int = grp.indices.length;
			for(m in 0...groupIndexCount)
			{
				for(l in 0...3)
				{
					bufferIndices.push(indices[++ iIndex]);
				}
			}
		}
		var i : Int = 0;
		while(i <mesh.getMeshBufferCount())
		{
			var buffer : MeshBuffer = mesh.getMeshBuffer(i);
			//delete empty MeshBuffer
			if(buffer.getIndexCount() == 0 || buffer.getVertexCount() == 0)
			{
				mesh.getMeshBuffers().splice(i, 1);
			} else 
			{
				buffer.recalculateBoundingBox();
				i ++;
			}
		}
		mesh.recalculateBoundingBox();
		//clean up
		ms3dVertices = null;
		triangles = null;
		groups = null;
		return mesh;
	}
	
	// loads an ms3d file and create a SkinnedMesh
	public function createSkinnedMesh(data : ByteArray) : SkinnedMesh
	{
		if(data == null || data.length == 0)
		{
			#if debug
			Logger.log("Not a valid Milkshape3D Model File.");
			#end
			return null;
		}
		data.endian = Endian.LITTLE_ENDIAN;
		data.position = 0;
		// read header
		var id : String = data.readUTFBytes(10);
		if(id != "MS3D000000")
		{
			#if debug
			Logger.log("Not a valid Milkshape3D Model File.", Logger.ERROR);
			#end
			return null;
		}
		var version : Int = data.readInt();
		
		#if debug
		Logger.log("MS3D File Version : " + version, Logger.INFORMATION);
		#end
		
		if(version <3 || version> 4)
		{
			#if debug
			Logger.log("Only Milkshape3D version 3 and 4(1.3 to 1.8) is supported.", Logger.ERROR);
			#end
			
			return null;
		}
		var animatedMesh : SkinnedMesh = new SkinnedMesh();
		//顶点数
		var numVertices : Int = data.readUnsignedShort();
		var ms3dVertices : Vector<MS3DVertex>= new Vector<MS3DVertex>(numVertices);
		for(i in 0...numVertices)
		{
			var ms3dVertex : MS3DVertex = new MS3DVertex();
			ms3dVertex.flags = data.readUnsignedByte();
			ms3dVertex.x = data.readFloat();
			ms3dVertex.y = data.readFloat();
			ms3dVertex.z = - data.readFloat();
			ms3dVertex.boneID = data.readUnsignedByte();
			ms3dVertex.refCount = data.readUnsignedByte();
			ms3dVertices[i] = ms3dVertex;
		}
		//triangles
		var numTriangles : Int = data.readUnsignedShort();
		var triangles : Vector<MS3DTriangle>= new Vector<MS3DTriangle>(numTriangles);
		for(i in 0...numTriangles)
		{
			var triangle : MS3DTriangle = new MS3DTriangle();
			triangle.flags = data.readUnsignedShort();
			triangle.indices[0] = data.readUnsignedShort();
			triangle.indices[1] = data.readUnsignedShort();
			triangle.indices[2] = data.readUnsignedShort();
			triangle.normals[0].x = data.readFloat();
			triangle.normals[1].x = data.readFloat();
			triangle.normals[2].x = data.readFloat();
			triangle.normals[0].y = data.readFloat();
			triangle.normals[1].y = data.readFloat();
			triangle.normals[2].y = data.readFloat();
			triangle.normals[0].z = - data.readFloat();
			triangle.normals[1].z = - data.readFloat();
			triangle.normals[2].z = - data.readFloat();
			triangle.tUs[0] = data.readFloat();
			triangle.tUs[1] = data.readFloat();
			triangle.tUs[2] = data.readFloat();
			triangle.tVs[0] = data.readFloat();
			triangle.tVs[1] = data.readFloat();
			triangle.tVs[2] = data.readFloat();
			triangle.smoothingGroup = data.readUnsignedByte();
			triangle.groupIndex = data.readUnsignedByte();
			triangles[i] = triangle;
		}
		//groups
		var numGroups : Int = data.readUnsignedShort();
		var groups : Vector<MS3DGroup>= new Vector<MS3DGroup>(numGroups);
		for(i in 0...numGroups)
		{
			var group : MS3DGroup = new MS3DGroup();
			data.position += 1;
			//1 byte flags
			group.name = data.readUTFBytes(32);
			var triangleCount : Int = data.readUnsignedShort();
			// triangle indices
			group.indices = new Vector<Int>(triangleCount);
			for(j in 0...triangleCount)
			{
				group.indices[j] = data.readUnsignedShort();
			}
			group.materialID = data.readUnsignedByte();
			// material index
			if(group.materialID == 255) group.materialID = 0;
			groups[i] = group;
		}
		// materials
		var numMaterials : Int = data.readUnsignedShort();
		var buffer : SkinnedMeshBuffer;
		if(numMaterials == 0)
		{
			// if there are no materials, add at least one buffer
			animatedMesh.addMeshBuffer();
		}
		for(i in 0...numMaterials)
		{
			buffer = animatedMesh.addMeshBuffer();
			var mat : Material = buffer.getMaterial();
			mat.name = data.readUTFBytes(32);
			mat.ambientColor.r =(data.readFloat() * 255);
			mat.ambientColor.g =(data.readFloat() * 255);
			mat.ambientColor.b =(data.readFloat() * 255);
			mat.ambientColor.a =(data.readFloat() * 255);

			mat.diffuseColor.r =(data.readFloat() * 255);
			mat.diffuseColor.g =(data.readFloat() * 255);
			mat.diffuseColor.b =(data.readFloat() * 255);
			mat.diffuseColor.a =(data.readFloat() * 255);

			mat.emissiveColor.r =(data.readFloat() * 255);
			mat.emissiveColor.g =(data.readFloat() * 255);
			mat.emissiveColor.b =(data.readFloat() * 255);
			mat.emissiveColor.a =(data.readFloat() * 255);

			mat.specularColor.r =(data.readFloat() * 255);
			mat.specularColor.g =(data.readFloat() * 255);
			mat.specularColor.b =(data.readFloat() * 255);
			mat.specularColor.a =(data.readFloat() * 255);

			mat.shininess = Std.int(data.readFloat());//0~128
			mat.alpha = data.readFloat();// 0~1
			if(mat.alpha <1)
			{
				mat.transparenting = true;
			}
			data.readUnsignedByte();
			//mode
			var texturepath : String = data.readUTFBytes(128);
			
			#if debug
			    Logger.log("texturepath=" + texturepath);
			#end
			
			mat.extra.texturePath = texturepath;

			var alphaMap : String = data.readUTFBytes(128);
			//alphaMap
			
			#if debug
			    Logger.log("alphaMap=" + alphaMap);
			#end
			
			mat.extra.texturePath2 = alphaMap;
		}
		//animation time
		var framesPerSecond : Float = data.readFloat();
		if(framesPerSecond <1) framesPerSecond = 1.0;
		var startTime : Float = data.readFloat();
		//current time
		//帧数
		//calculated inside SkinnedMesh
		var frameCount : Int = data.readInt();
		//joints
		var jointCount : Int = data.readUnsignedShort();
		//var joint : Joint;
		var rotation : Vector3D = new Vector3D();
		var translation : Vector3D = new Vector3D();
		var tmpVec : Vector3D = new Vector3D();
		var tmpMatrix : Matrix4 = new Matrix4();
		var parentNames : Vector<String>= new Vector<String>();
		for(i in 0...jointCount)
		{
			var flags : Int = data.readUnsignedByte();
			var jointName : String = data.readUTFBytes(32);
			var parentName : String = data.readUTFBytes(32);
			rotation.x = data.readFloat();
			rotation.y = data.readFloat();
			rotation.z = data.readFloat();
			translation.x = data.readFloat();
			translation.y = data.readFloat();
			translation.z = data.readFloat();
			var numRotationKeyframes : Int = data.readUnsignedShort();
			var numTranslationKeyframes : Int = data.readUnsignedShort();
			var joint : Joint = animatedMesh.addJoint();
			joint.name = jointName;
			joint.localMatrix.identity();
			joint.localMatrix.setRotation(rotation,false);
			// convert right-handed to left-handed
			joint.localMatrix.m13 = - joint.localMatrix.m13;
			joint.localMatrix.m23 = - joint.localMatrix.m23;
			joint.localMatrix.m31 = - joint.localMatrix.m31;
			joint.localMatrix.m32 = - joint.localMatrix.m32;
			joint.localMatrix.setTranslation(translation);
			parentNames.push(parentName);
			//get rotation keyframes
			for(j in 0...numRotationKeyframes)
			{
				var time : Float = data.readFloat();
				tmpVec.x = data.readFloat();
				tmpVec.y = data.readFloat();
				tmpVec.z = data.readFloat();
				var rk : RotationKey = animatedMesh.addRotationKey(joint);
				rk.frame = Std.int(time * framesPerSecond);
				tmpMatrix.identity();
				tmpMatrix.setRotation(tmpVec,false);
				// convert right-handed to left-handed
				tmpMatrix.m13 = - tmpMatrix.m13;
				tmpMatrix.m23 = - tmpMatrix.m23;
				tmpMatrix.m31 = - tmpMatrix.m31;
				tmpMatrix.m32 = - tmpMatrix.m32;
				tmpMatrix = joint.localMatrix.multiply(tmpMatrix);
				rk.rotation.setMatrix(tmpMatrix);
			}
			//get translation keyframes
			for(j in 0...numTranslationKeyframes)
			{
				var time : Float = data.readFloat();
				tmpVec.x = data.readFloat();
				tmpVec.y = data.readFloat();
				tmpVec.z = data.readFloat();
				var pk : PositionKey = animatedMesh.addPositionKey(joint);
				pk.frame = Std.int(time * framesPerSecond);
				pk.position.x = tmpVec.x + translation.x;
				pk.position.y = tmpVec.y + translation.y;
				pk.position.z = tmpVec.z + translation.z;
			}
		}
		//MS3DWeight
		var vertexWeights : Vector<MS3DWeight>= new Vector<MS3DWeight>();
		if(version == 4 && data.bytesAvailable> 0)
		{
			var subVersion : Int = data.readInt();
			// comment subVersion, always 1
			//Logger.log("subVersion: " + subVersion);
			/**
			* group-->material-->joint-->model
			* comment顺序为group,material,joint,model
			*/
			var index : Int;
			var len : Int;
			var comment : String;
			//group,material,joint comment
			for(j in 0...3) // comment groups
			{
				var numComments : Int = data.readUnsignedInt();
				for(i in 0...numComments)
				{
					index = data.readInt();//index
					len = data.readInt();//字符串长度
					comment = data.readUTFBytes(len);
					
					#if debug
					    Logger.log("comment" + index + "=" + comment);
					#end
				}
			}
			//model comment
			var numComment : Int = data.readInt();
			if(numComment == 1)
			{
				len = data.readInt();
				comment = data.readUTFBytes(len);
				
				#if debug
				    Logger.log("model comment =" + comment);
				#end
			}
			// vertex extra
			if(data.bytesAvailable> 0)
			{
				subVersion = data.readInt();
				// vertex subVersion, 1 or 2
				vertexWeights.length = numVertices;
				//subVersion==2时，有extra
				var offset : Int =(subVersion == 1) ? 0 : 4;
				for(i in 0...numVertices)
				{
					var ms3dWeight : MS3DWeight = new MS3DWeight();
					ms3dWeight.bone0 = data.readByte();
					ms3dWeight.bone1 = data.readByte();
					ms3dWeight.bone2 = data.readByte();
					ms3dWeight.weight0 = data.readUnsignedByte();
					ms3dWeight.weight1 = data.readUnsignedByte();
					ms3dWeight.weight2 = data.readUnsignedByte();
					vertexWeights[i] = ms3dWeight;
					data.position += offset;
					//ignoring data 'extra' from 1.8.2
				}
			}
			// joint extra
			if(data.bytesAvailable> 0)
			{
				subVersion = data.readInt();
				// joint subVersion, 1 or 2
				if(subVersion == 1)
				{
					var joint : Joint;
					for(i in 0...jointCount)
					{
						joint = animatedMesh.getAllJoints()[i];
						joint.color.r = data.readFloat() * 255.0;
						joint.color.g = data.readFloat() * 255.0;
						joint.color.b = data.readFloat() * 255.0;
					}
				} else
				{
					// skip joint colors
					data.position += 3 * 4 * jointCount;
				}
			}
			// model extra
			if(data.bytesAvailable> 0)
			{
				subVersion = data.readInt();
				// model subVersion, 1 or 2
				if(subVersion == 1)
				{
					var jointSize : Float = data.readFloat();
					var transparencyMode : Int = data.readInt();
					var alphaRef : Int = data.readInt();
				} else
				{
					#if debug
					Logger.log("Unknown subversion for model extra" + subVersion, Logger.WARNING);
					#end
				}
			}
		}
		data.position = 0;
		//find parent of every joint
		var joints : Vector<Joint>= animatedMesh.getAllJoints();
		var len : Int = joints.length;
		for(i in 0...len)
		{
			for(j in 0...len)
			{
				if(i != j && parentNames[i] == joints[j].name)
				{
					joints[j].children.push(joints[i]);
					break;
				}
			}
		}
		// create vertices and indices, attach them to the joints.
		var indices : Vector<Int>= new Vector<Int>();
		var triangle : MS3DTriangle;
		var group : MS3DGroup;
		var weight : Weight;
		var animatedBuffers : Vector<MeshBuffer>= animatedMesh.getMeshBuffers();
		var allJoints : Vector<Joint>= animatedMesh.getAllJoints();
		var jointLength : Int = allJoints.length;
		for(i in 0...numTriangles)
		{
			triangle = triangles[i];
			var groupIndex : Int = triangle.groupIndex;
			var vertices : Vector<Vertex>= animatedBuffers[groups[groupIndex].materialID].getVertices();
			group = groups[groupIndex];
			var j : Int = 2;
			while(j> - 1)
			{
				var vertex : Vertex = new Vertex();
				vertex.u = triangle.tUs[j];
				vertex.v = triangle.tVs[j];
				vertex.nx = triangle.normals[j].x;
				vertex.ny = triangle.normals[j].y;
				vertex.nz = triangle.normals[j].z;
				vertex.x = ms3dVertices[triangle.indices[j]].x;
				vertex.y = ms3dVertices[triangle.indices[j]].y;
				vertex.z = ms3dVertices[triangle.indices[j]].z;
				var index : Int = - 1;
				var len:Int = vertices.length;
				for(iv in 0...len)
				{
					if(vertex.equals(vertices[iv]))
					{
						index = iv;
						break;
					}
				}
				if(index == - 1 )
				{
					index = vertices.length;
					var vertidx : Int = triangle.indices[j];
					var matidx : Int = groups[groupIndex].materialID;
					var boneid : Int = ms3dVertices[vertidx].boneID;
					if(vertexWeights.length == 0)
					{
						if(boneid <jointLength)
						{
							weight = animatedMesh.addWeight(allJoints[boneid]);
							weight.bufferID = matidx;
							weight.strength = 1.0;
							weight.vertexID = index;
						}
					} else // new weights from 1.8.x
					
					{
						var sum : Float = 1.0;
						var ms3dWeight : MS3DWeight = vertexWeights[vertidx];
						if(boneid <jointLength && ms3dWeight.weight0 != 0)
						{
							weight = animatedMesh.addWeight(allJoints[boneid]);
							weight.bufferID = matidx;
							sum -=(weight.strength = ms3dWeight.weight0 / 100.);
							weight.vertexID = index;
						}
						boneid = ms3dWeight.bone0;
						if(boneid > 0 && boneid < jointLength && ms3dWeight.weight1 != 0)
						{
							weight = animatedMesh.addWeight(allJoints[boneid]);
							weight.bufferID = matidx;
							sum -=(weight.strength = ms3dWeight.weight1 / 100.);
							weight.vertexID = index;
						}
						boneid = ms3dWeight.bone1;
						if(boneid > 0 && boneid < jointLength && ms3dWeight.weight2 != 0)
						{
							weight = animatedMesh.addWeight(allJoints[boneid]);
							weight.bufferID = matidx;
							sum -=(weight.strength = ms3dWeight.weight2 / 100.);
							weight.vertexID = index;
						}
						boneid = ms3dWeight.bone2;
						if(boneid > 0 && boneid < jointLength && sum> 0.)
						{
							weight = animatedMesh.addWeight(allJoints[boneid]);
							weight.bufferID = matidx;
							weight.strength = sum;
							weight.vertexID = index;
						}
						// fallback, if no bone chosen. Seems to be an error in the specs
						boneid = ms3dVertices[vertidx].boneID;
						if(sum == 1.&& boneid <jointLength)
						{
							weight = animatedMesh.addWeight(allJoints[boneid]);
							weight.bufferID = matidx;
							weight.strength = 1.;
							weight.vertexID = index;
						}
					}
					vertices.push(vertex);
				}
				indices.push(index);
				j --;
			}
		}
		//create groups
		var iIndex : Int = - 1;
		var groupLen : Int = groups.length;
		for(i in 0...groupLen)
		{
			var grp : MS3DGroup = groups[i];
			if(grp.materialID>= animatedMesh.getMeshBufferCount())
			{
				grp.materialID = 0;
			}
			var bufferIndices : Vector<Int> = animatedMesh.getMeshBuffer(grp.materialID).getIndices();
			var indiceCount:Int = grp.indices.length;
			for(m in 0...indiceCount)
			{
				for(l in 0...3)
				{
					bufferIndices.push(indices[++ iIndex]);
				}
			}
		}
		//recalculate boundingbox,refresh and remove empty buffer
		var i : Int = 0;
		while(i <animatedMesh.getMeshBufferCount())
		{
			var buffer : MeshBuffer = animatedMesh.getMeshBuffer(i);
			buffer.recalculateBoundingBox();
			//删除空的MeshBuffer
			if(buffer.getIndexCount() == 0 || buffer.getVertexCount() == 0)
			{
				animatedMesh.getMeshBuffers().splice(i, 1);
			} else 
			{
				i ++;
			}
		}
		animatedMesh.recalculateBoundingBox();
		animatedMesh.finalize();
		//clean up
		ms3dVertices = null;
		triangles = null;
		groups = null;
		parentNames = null;
		return animatedMesh;
	}
}
class MS3DHeader
{
	public var ID : String;//[10] char
	public var version : Int;
}
class MS3DGroup
{
	public var name : String;
	public var indices : Vector<Int>;//u16
	public var materialID : Int;//u16
	public function new()
	{
		name = "";
		indices = new Vector<Int>();
		materialID = 0;
	}
}
// Triangle information
class MS3DTriangle
{
	public var flags : Int;//u16
	public var indices : Vector<Int>;//u16
	public var normals : Vector<Vector3D>;//Float
	public var tUs : Vector<Float>;
	public var tVs : Vector<Float>;
	public var smoothingGroup : Int;//u8
	public var groupIndex : Int;//u8
	public function new()
	{
		indices = new Vector<Int>(3, true);
		normals = new Vector<Vector3D>(3, true);
		for(i in 0...3)
		{
			normals[i] = new Vector3D();
		}
		tUs = new Vector<Float>(3, true);
		tVs = new Vector<Float>(3, true);
	}
}
//Material infomation
class MS3DMaterial
{
	public var name : String;//[32] char
	public var ambient : Color;//float[4]
	public var diffuse : Color;//float[4]
	public var specular : Color;//float[4]
	public var emissive : Color;//float[4]
	public var shininess : Float;//0.0-128
	public var transparency : Float;//0.0-1.0
	public var mode : Int;//u8 0,1,2 is unused now
	public var texture : String;//[128] char
	public var alphaMap : String;//[128] char
	public function new()
	{
		ambient = new Color();
		diffuse = new Color();
		specular = new Color();
		emissive = new Color();
	}
}
class MS3DJoint
{
	public var flags : Int;//u8
	public var name : String;//char 32
	public var parentName : String;//char 32
	public var rotation : Vector3D;//float;
	public var translation : Vector3D;//float
	public var numRotationKeyframes : Int;//u16
	public var numTranslationKeyframes : Int;//u16
	public function new()
	{
		rotation = new Vector3D();
		translation = new Vector3D();
	}
}
//keyframe data
class MS3DKeyframe
{
	public var time : Float;
	public var parameter : Vector<Float>;
	public function new()
	{
		parameter = new Vector<Float>(3);
	}
}
class MS3DVertex
{
	public var flags : Int;//u8
	public var x : Float;//float
	public var y : Float;//float
	public var z : Float;//float
	public var boneID : Int;//char
	public var refCount : Int;//u8
	public function new()
	{
	}
}
// vertex weight in 1.8.x
class MS3DWeight
{
	public var bone0 : Int;//char
	public var bone1 : Int;//char
	public var bone2 : Int;//char
	public var weight0 : Int;//unsigned char
	public var weight1 : Int;//unsigned char
	public var weight2 : Int;//unsigned char
	public function new()
	{
	}
}
