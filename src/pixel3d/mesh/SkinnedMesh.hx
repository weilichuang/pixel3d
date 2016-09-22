
package pixel3d.mesh;
import flash.geom.Vector3D;
import flash.Lib;
import flash.Vector;
import pixel3d.material.ITexture;
import pixel3d.math.AABBox;
import pixel3d.math.MathUtil;
import pixel3d.math.Matrix4;
import pixel3d.math.Quaternion;
import pixel3d.math.Vertex;
import pixel3d.mesh.AnimatedMeshType;
import pixel3d.mesh.IMesh;
import pixel3d.mesh.IntepolationMode;
import pixel3d.mesh.MeshBuffer;
import pixel3d.mesh.skin.Joint;
import pixel3d.mesh.skin.PositionKey;
import pixel3d.mesh.skin.RotationKey;
import pixel3d.mesh.skin.ScaleKey;
import pixel3d.mesh.skin.Weight;
import pixel3d.scene.BoneSceneNode;
import pixel3d.scene.SkinnedMeshSceneNode;
import pixel3d.utils.Logger;

class SkinnedMesh implements ISkinnedMesh
{
	private var skiningBuffers : Vector<MeshBuffer>;

	private var allJoints : Vector<Joint>;
	private var rootJoints : Vector<Joint>;

	private var boundingBox : AABBox;

	private var vertices_Moved:Vector<Vector<Bool>>;

	private var animationFrames : Float;

	private var lastAnimatedFrame : Float;
	private var lastSkinnedFrame:Float;

	private var interpolationMode : Int;

	private var hasAnimation : Bool;
	private var preparedForSkinning:Bool;
	private var boneControlUsed:Bool;
	private var animateNormals:Bool;

	//cache......
	private var vertexMove : Vector3D ;
	private var normalMove : Vector3D ;
	private var jointVertexPull : Matrix4 ;
	private var _position : Vector3D;
	private var _scale : Vector3D;
	private var _rotation : Quaternion;

	/**
	* 用于重置所有weight的moved属性
	*/
	private var weights : Vector<Weight>;

	public function new()
	{
		skiningBuffers = new Vector<MeshBuffer>();

		allJoints = new Vector<Joint>();
		rootJoints = new Vector<Joint>();

		weights = new Vector<Weight>();

		interpolationMode = IntepolationMode.LINEAR;

		hasAnimation = false;
		animateNormals = false;
		boneControlUsed = false;
		preparedForSkinning = false;

		animationFrames = 0;
		lastAnimatedFrame = 0;
		lastSkinnedFrame = 0;

		boundingBox = new AABBox();

		vertexMove = new Vector3D();
		normalMove = new Vector3D();
		jointVertexPull = new Matrix4();
		_position = new Vector3D();
		_scale = new Vector3D();
		_rotation = new Quaternion();
	}

	public function getFrameCount() : Int
	{
		return MathUtil.floor(animationFrames);
	}

	public function getLastAnimatedFrame():Float
	{
		return lastAnimatedFrame;
	}

	public function getMesh(frame : Int, detailLevel : Int = 255, startFrameLoop : Int = - 1, endFrameLoop : Int = - 1) : IMesh
	{
		if (frame == -1)
		{
			return this;
		}
		animateMesh(frame, 1.0);
		skinMesh();
		return this;
	}

	/**
	 *Animates this mesh's joints based on frame input
	 * @param	frame
	 * @param	blend {0-old position, 1-New position}
	 */
	public function animateMesh(frame : Float, blend : Float) : Void
	{
		if ( !hasAnimation || lastAnimatedFrame == frame)
		{
			return;
		}

		lastAnimatedFrame = frame;

		if (blend <= 0.0)
		{
			return;//No need to animate
		}

		blend = MathUtil.clamp(blend, 0, 1);

		var len : Int = allJoints.length;
		for (i in 0...len)
		{
			getFrameData(frame, allJoints[i], blend);
		}

		buildAllLocalAnimatedMatrices();
	}

	private function buildAllLocalAnimatedMatrices() : Void
	{
		var len : Int = allJoints.length;
		for (i in 0...len)
		{
			var jt : Joint = allJoints[i];

			//Could be faster:
			if (jt != null &&
			(jt.useAnimationFrom.positionKeys.length > 0 ||
			jt.useAnimationFrom.scaleKeys.length > 0 ||
			jt.useAnimationFrom.rotationKeys.length > 0 ))
			{
				var mat : Matrix4 = jt.localAnimatedMatrix;
				jt.curRotation.getMatrix(mat);

				var pos : Vector3D = jt.curPosition;
				//mat.m11 += pos.x * mat.m14;
				//mat.m12 += pos.y * mat.m14;
				//mat.m13 += pos.z * mat.m14;

				//mat.m21 += pos.x * mat.m24;
				//mat.m22 += pos.y * mat.m24;
				//mat.m23 += pos.z * mat.m24;

				//mat.m31 += pos.x * mat.m34;
				//mat.m32 += pos.y * mat.m34;
				//mat.m33 += pos.z * mat.m34;

				//mat.m41 += pos.x * mat.m44;
				//mat.m42 += pos.y * mat.m44;
				//mat.m43 += pos.z * mat.m44;

				mat.m41 += pos.x;
				mat.m42 += pos.y;
				mat.m43 += pos.z;

				// -----------------------------------

				jt.globalSkinningSpace = false;

				if (jt.scaleKeys.length > 0)
				{
					//core::matrix4 scaleMatrix;
					//scaleMatrix.setScale(jt.curScale);
					//jt.LocalAnimatedMatrix *= scaleMatrix;

					// -------- jt.LocalAnimatedMatrix *= scaleMatrix -----------------
					var scale:Vector3D = jt.curScale;
					if (scale.x != 1)
					{
						mat.m11 *= scale.x;
						mat.m12 *= scale.x;
						mat.m13 *= scale.x;
						//mat.m14 *= scale.x;
					}

					if (scale.y != 1)
					{
						mat.m21 *= scale.y;
						mat.m22 *= scale.y;
						mat.m23 *= scale.y;
						//mat.m24 *= scale.y;
					}

					if (scale.z != 1)
					{
						mat.m31 *= scale.z;
						mat.m32 *= scale.z;
						mat.m33 *= scale.z;
						//mat.m34 *= scale.z;
					}
				}
			}
			else
			{
				jt.localAnimatedMatrix.copy(jt.localMatrix);
			}
		}
	}

	private function buildAllGlobalAnimatedMatrices(joint : Joint = null, parentJoint : Joint = null) : Void
	{
		if (joint == null)
		{
			var len : Int = rootJoints.length;
			for (i in 0...len)
			{
				buildAllGlobalAnimatedMatrices(rootJoints[i], null);
			}
			return;
		}
		else
		{
			// Find global matrix...
			if (parentJoint == null || joint.globalSkinningSpace)
			{
				joint.globalAnimatedMatrix.copy(joint.localAnimatedMatrix);
			}
			else
			{
				parentJoint.globalAnimatedMatrix.prepend2(joint.localAnimatedMatrix, joint.globalAnimatedMatrix);
			}
		}

		var len : Int = joint.children.length;
		for (i in 0...len)
		{
			buildAllGlobalAnimatedMatrices(joint.children[i], joint);
		}
	}

	private function getFrameData(frame : Float, jt : Joint, blend : Float) : Void
	{
		var foundPositionIndex : Int = - 1;
		var foundScaleIndex : Int = - 1;
		var foundRotationIndex : Int = - 1;

		if (jt.useAnimationFrom != null)
		{
			var positionKeys : Vector<PositionKey> = jt.useAnimationFrom.positionKeys;
			var scaleKeys : Vector<ScaleKey> = jt.useAnimationFrom.scaleKeys;
			var rotationKeys : Vector<RotationKey> = jt.useAnimationFrom.rotationKeys;

			var position : Vector3D = jt.curPosition;
			var scale : Vector3D = jt.curScale;
			var rotation : Quaternion = jt.curRotation;
			if (blend != 1)
			{
				_position.x = position.x;
				_position.y = position.y;
				_position.z = position.z;
				_scale.x = scale.x;
				_scale.y = scale.y;
				_scale.z = scale.z;
				_rotation.copy(rotation);
			}

			var posLen:Int = positionKeys.length;
			if (posLen > 0)
			{
				foundPositionIndex = - 1;

				var positionHint : Int = jt.positionHint;

				//Test the Hints...
				if (positionHint >= 0 && positionHint < posLen)
				{
					//check this hint
					if (positionHint > 0 && positionKeys[positionHint].frame >= frame &&
							positionKeys[positionHint - 1].frame < frame )
					{
						foundPositionIndex = positionHint;
					}
					else if (positionHint + 1 < posLen)
					{
						//check the next index
						if (positionKeys[positionHint + 1].frame >= frame &&
								positionKeys[positionHint + 0].frame < frame)
						{
							positionHint++;
							foundPositionIndex = positionHint;
						}
					}
				}

				//The hint test failed, do a full scan...
				if (foundPositionIndex == - 1)
				{
					for (i in 0...posLen)
					{
						if (positionKeys[i].frame >= frame) //Keys should to be sorted by frame
						{
							foundPositionIndex = i;
							positionHint = i;
							break;
						}
					}
				}
				jt.positionHint = positionHint;

				//Do interpolation...
				if (foundPositionIndex != -1)
				{
					if (interpolationMode == IntepolationMode.CONSTANT ||
							foundPositionIndex == 0)
					{
						position.x = positionKeys[foundPositionIndex].position.x;
						position.y = positionKeys[foundPositionIndex].position.y;
						position.z = positionKeys[foundPositionIndex].position.z;
					}
					else if (interpolationMode == IntepolationMode.LINEAR)
					{
						var keyA : PositionKey = positionKeys[foundPositionIndex];
						var keyB : PositionKey = positionKeys[foundPositionIndex - 1];

						var posA : Vector3D = keyA.position;
						var posB : Vector3D = keyB.position;

						var k : Float = (frame - keyA.frame) / (keyB.frame - keyA.frame);

						position.x = (posB.x - posA.x) * k + posA.x;
						position.y = (posB.y - posA.y) * k + posA.y;
						position.z = (posB.z - posA.z) * k + posA.z;
					}
				}
			}

			//-------------------scale-------------------------------
			var scaleLen:Int = scaleKeys.length;
			if (scaleLen > 0)
			{
				foundScaleIndex = - 1;

				var scaleHint : Int = jt.scaleHint;
				//Test the Hints...
				if (scaleHint >= 0 && scaleHint < scaleLen)
				{
					//check this hint
					if (scaleHint > 0 && scaleKeys[scaleHint].frame >= frame &&
							scaleKeys[scaleHint - 1].frame <frame)
					{
						foundScaleIndex = scaleHint;
					}
					else if (scaleHint + 1 < scaleLen)
					{
						//check the next index
						if (scaleKeys[scaleHint + 1].frame >= frame &&
								scaleKeys[scaleHint + 0].frame < frame)
						{
							scaleHint++;
							foundScaleIndex = scaleHint;
						}
					}
				}

				//The hint test failed, do a full scan...
				if (foundScaleIndex == - 1)
				{
					for (i in 0...scaleLen)
					{
						if (scaleKeys[i].frame >= frame) //Keys should to be sorted by frame
						{
							foundScaleIndex = i;
							scaleHint = i;
							break;
						}
					}
				}
				jt.scaleHint = scaleHint;

				//Do interpolation...
				if (foundScaleIndex != -1)
				{
					if (interpolationMode == IntepolationMode.CONSTANT ||
							foundScaleIndex == 0)
					{
						scale.x = scaleKeys[foundScaleIndex].scale.x;
						scale.y = scaleKeys[foundScaleIndex].scale.y;
						scale.z = scaleKeys[foundScaleIndex].scale.z;
					}
					else if (interpolationMode == IntepolationMode.LINEAR)
					{
						var keySA : ScaleKey = scaleKeys[foundScaleIndex];
						var keySB : ScaleKey = scaleKeys[foundScaleIndex - 1];

						var posA : Vector3D = keySA.scale;
						var posB : Vector3D = keySB.scale;

						var k : Float = (frame - keySA.frame) / (keySB.frame - keySA.frame);

						scale.x = (posB.x - posA.x) * k + posA.x;
						scale.y = (posB.y - posA.y) * k + posA.y;
						scale.z = (posB.z - posA.z) * k + posA.z;
					}
				}
			}

			//-------------------------rotation---------------------------
			var rotationLen:Int = rotationKeys.length;
			if (rotationLen > 0)
			{
				foundRotationIndex = - 1;

				var rotationHint : Int = jt.rotationHint;
				//Test the Hints...
				if (rotationHint >= 0 && rotationHint < rotationLen)
				{
					//check this hint
					if (rotationHint > 0 && rotationKeys[rotationHint].frame >= frame &&
							rotationKeys[rotationHint - 1].frame < frame )
					{
						foundRotationIndex = rotationHint;
					}
					else if (rotationHint + 1 < rotationLen)
					{
						//check the next index
						if (rotationKeys[rotationHint + 1].frame >= frame &&
								rotationKeys[rotationHint + 0].frame < frame)
						{
							rotationHint++;
							foundRotationIndex = rotationHint;
						}
					}
				}

				//The hint test failed, do a full scan...
				if (foundRotationIndex == - 1)
				{
					for (i in 0...rotationLen)
					{
						if (rotationKeys[i].frame >= frame) //Keys should be sorted by frame
						{
							foundRotationIndex = i;
							rotationHint = i;
							break;
						}
					}
				}
				jt.rotationHint = rotationHint;

				//Do interpolation...
				if (foundRotationIndex != -1)
				{
					if (interpolationMode == IntepolationMode.CONSTANT ||
							foundRotationIndex == 0)
					{
						rotation.copy(rotationKeys[foundRotationIndex].rotation);
					}
					else if (interpolationMode == IntepolationMode.LINEAR)
					{
						var keyRA : RotationKey = rotationKeys[foundRotationIndex];
						var keyRB : RotationKey = rotationKeys[foundRotationIndex - 1];

						var k : Float = (frame - keyRA.frame) / (keyRB.frame - keyRA.frame);

						rotation.slerp(keyRA.rotation, keyRB.rotation, k);
					}
				}
			}

			if (blend != 1)
			{
				//blend animation
				var invBlend : Float = (1 - blend);

				position.x = blend * position.x + _position.x * invBlend;
				position.y = blend * position.y + _position.y * invBlend;
				position.z = blend * position.z + _position.z * invBlend;

				scale.x = blend * scale.x + _scale.x * invBlend;
				scale.y = blend * scale.y + _scale.y * invBlend;
				scale.z = blend * scale.z + _scale.z * invBlend;

				rotation.slerp(_rotation, rotation, blend);
			}
		}
	}

	/**
	* Preforms a software skin on this mesh based of joint positions
	*/
	public function skinMesh() : Void
	{
		if (!hasAnimation)
		{
			return;
		}

		buildAllGlobalAnimatedMatrices();

		//rigid animation
		//var len : Int = allJoints.length;
		//for(i in 0...len)
		//{
		//var joint : Joint = allJoints[i];
		//for(j in 0...joint.attachedMeshes.length)
		//{
		//var buffer : SkinnedMeshBuffer = Lib.as(skiningBuffers[joint.attachedMeshes[j]],SkinnedMeshBuffer);
		//
		//buffer.transformation.copy(joint.globalAnimatedMatrix);
		//}
		//}

		//reset weight moved false
		var len:Int = weights.length;
		for (i in 0...len)
		{
			weights[i].moved = false;
		}

		//skin starting with the root joints
		len = rootJoints.length;
		for (i in 0...len)
		{
			skinJoint(rootJoints[i], null);
		}

		recalculateBoundingBox();
	}

	public function skinJoint(joint : Joint, parentJoint : Joint = null) : Void
	{
		var weightLen : Int = joint.weights.length;
		if (weightLen > 0)
		{
			//Find this joints pull on vertices...
			joint.globalAnimatedMatrix.prepend2(joint.globalInversedMatrix, jointVertexPull);

			//Skin Vertices Positions and Normals...
			for (i in 0...weightLen)
			{
				var weight : Weight = joint.weights[i];

				var strength : Float = weight.strength;

				// Pull this vertex...
				jointVertexPull.transformVector2D(weight.pos, vertexMove);
				if (animateNormals)
				{
					jointVertexPull.rotateVector2D(weight.normal, normalMove);
				}

				var vertex : Vertex = skiningBuffers[weight.bufferID].getVertex(weight.vertexID);
				if (!weight.moved)
				{
					weight.moved = true;

					vertex.x = vertexMove.x * strength;
					vertex.y = vertexMove.y * strength;
					vertex.z = vertexMove.z * strength;

					if (animateNormals)
					{
						vertex.nx = normalMove.x * strength;
						vertex.ny = normalMove.y * strength;
						vertex.nz = normalMove.z * strength;
					}
				}
				else
				{
					vertex.x += vertexMove.x * strength;
					vertex.y += vertexMove.y * strength;
					vertex.z += vertexMove.z * strength;

					if (animateNormals)
					{
						vertex.nx += normalMove.x * strength;
						vertex.ny += normalMove.y * strength;
						vertex.nz += normalMove.z * strength;
					}
				}
			}
		}

		//Skin all children
		var cLen:Int = joint.children.length;
		for (j in 0...cLen)
		{
			skinJoint(joint.children[j],joint);
		}
	}

	private function calculateGlobalMatrixes(joint : Joint, parentJoint : Joint = null) : Void
	{
		if (joint == null && parentJoint != null)
		{
			return;
		}

		//Go through the root bones
		if (joint == null)
		{
			var len : Int = rootJoints.length;
			for (i in 0...len)
			{
				calculateGlobalMatrixes(rootJoints[i], null);
			}
			return;
		}

		if (parentJoint == null)
		{
			joint.globalMatrix.copy(joint.localMatrix);
		}
		else
		{
			parentJoint.globalMatrix.prepend2(joint.localMatrix, joint.globalMatrix);
		}

		joint.localAnimatedMatrix.copy(joint.localMatrix);
		joint.globalAnimatedMatrix.copy(joint.globalMatrix);

		if (joint.globalInversedMatrix.isIdentity()) //might be pre calculated
		{
			joint.globalInversedMatrix.copy(joint.globalMatrix);
			joint.globalInversedMatrix.invert();
		}

		var len : Int = joint.children.length;
		for (i in 0...len)
		{
			calculateGlobalMatrixes(joint.children[i],joint);
		}
	}

	private function checkForAnimation() : Void
	{
		hasAnimation = false;

		var jt : Joint;

		var jointLen : Int = allJoints.length;
		for (i in 0...jointLen)
		{
			jt = allJoints[i];
			if (jt != null)
			{
				if (jt.positionKeys.length > 0 ||
				jt.scaleKeys.length > 0 ||
				jt.rotationKeys.length > 0 )
				{
					hasAnimation = true;
					break;
				}
			}
		}

		//meshes with weights, are still counted as animated for ragdolls, etc
		if ( !hasAnimation)
		{
			for (i in 0...jointLen)
			{
				jt = allJoints[i];
				if (jt.weights.length > 0)
				{
					hasAnimation = true;
					break;
				}
			}
		}

		if (hasAnimation)
		{
			//--- Find the length of the animation ---
			animationFrames = 0;
			for (i in 0...jointLen)
			{
				jt = allJoints[i];
				if (jt != null)
				{
					var frame:Int;
					var len : Int = jt.positionKeys.length;
					if (len > 0)
					{
						frame = jt.positionKeys[len - 1].frame;
						if (frame > animationFrames)
						{
							animationFrames = frame;
						}
					}

					len = jt.scaleKeys.length;
					if (len > 0)
					{
						frame = jt.scaleKeys[len - 1].frame;
						if (frame > animationFrames)
						{
							animationFrames = frame;
						}
					}

					len = jt.rotationKeys.length;
					if (len > 0)
					{
						frame = jt.rotationKeys[len - 1].frame;
						if (frame > animationFrames)
						{
							animationFrames = frame;
						}
					}
				}
			}

			//prepared for skinning

			//check for bugs:
			//for(i in 0...jointLen)
			//{
			//jt = allJoints[i];
			//
			//var weightLen : Int = jt.weights.length;
			//for(j in 0...weightLen)
			//{
			//var weight : Weight = jt.weights[j];
			//var buffer_id : Int = weight.bufferID;
			//var vertex_id : Int = weight.vertexID;
			//
			//check for invalid ids
			//if(buffer_id >= skiningBuffers.length)
			//{
			//Logger.log("Skinned Mesh: Weight buffer id too large", Logger.WARNING);
			//weight.bufferID = weight.vertexID = 0;
			//}
			//else if(vertex_id >= skiningBuffers[buffer_id].getVertexCount())
			//{
			//Logger.log("Skinned Mesh: Weight vertex id too large", Logger.WARNING);
			//weight.bufferID = weight.vertexID = 0;
			//}
			//}
			//}

			// For skinning: cache weight values for speed
			for (i in 0...jointLen)
			{
				jt = allJoints[i];

				var weightLen : Int = jt.weights.length;
				for (j in 0...weightLen)
				{
					var wt : Weight = jt.weights[j];

					var vertex : Vertex = skiningBuffers[wt.bufferID].getVertex(wt.vertexID);

					wt.moved = false;

					wt.pos.x = vertex.x;
					wt.pos.y = vertex.y;
					wt.pos.z = vertex.z;

					wt.normal.x = vertex.nx;
					wt.normal.y = vertex.ny;
					wt.normal.z = vertex.nz;
				}
			}

			// normalize weights
			normalizeWeights();

			//get all weight
			weights.length = 0;
			var jointLen : Int = allJoints.length;
			for (i in 0...jointLen)
			{
				var weightLen : Int = allJoints[i].weights.length;
				for (j in 0...weightLen)
				{
					weights.push(allJoints[i].weights[j]);
				}
			}
		}
	}

	// called by loader after populating with mesh and bone data
	public function finalize() : Void
	{
		lastAnimatedFrame = - 1;
		lastSkinnedFrame = -1;

		rootJoints.length = 0;
		var allJointsLen : Int = allJoints.length;
		for (j in 0...allJointsLen)
		{
			var foundParent : Bool = false;
			for (i in 0...allJointsLen)
			{
				var childLen : Int = allJoints[i].children.length;
				for (n in 0...childLen)
				{
					var jt : Joint = allJoints[i];
					if (jt.children[n] == allJoints[j])
					{
						foundParent = true;
					}
				}
			}

			if ( !foundParent)
			{
				rootJoints.push(allJoints[j]);
			}
		}

		var len:Int = allJoints.length;
		for (i in 0...len)
		{
			allJoints[i].useAnimationFrom = allJoints[i];
		}

		//Todo: optimise keys here...
		checkForAnimation();

		//if(hasAnimation)
		//{
		//--- optimize and check keyframes ---
		//var len : Int = allJoints.length;
		//for(i in 0...len)
		//{
		//var joint : Joint = allJoints[i];
		//var positionKeys : Vector<PositionKey> = joint.positionKeys;
		//var scaleKeys : Vector<ScaleKey> = joint.scaleKeys;
		//var rotationKeys : Vector<RotationKey> = joint.rotationKeys;
		//
		//貌似不是很必要这样做
		//if(positionKeys.length > 2)
		//{
		//var j : Int = 0;
		//while(j < (positionKeys.length - 2))
		//{
		//var p0 : Vector3D = positionKeys[j].position;
		//var p1 : Vector3D = positionKeys[j + 1].position;
		//var p2 : Vector3D = positionKeys[j + 2].position;
		//if(p0.equals(p1) && p1.equals(p2))
		//{
		//positionKeys.splice(j + 1, 1);
		//the middle key is unneeded
		//j--;
		//}
		//j ++;
		//}
		//}
		//
		//if(positionKeys.length > 1)
		//{
		//var j : Int = 0;
		//while(j <(positionKeys.length - 1))
		//{
		//if(positionKeys[j].frame >= positionKeys[j + 1].frame) //bad frame, unneed and may cause problems
		//{
		//positionKeys.splice(j + 1, 1);
		//j--;
		//}
		//j ++;
		//}
		//}
		//
		//if(scaleKeys.length > 2)
		//{
		//var j : Int = 0;
		//while(j <(scaleKeys.length - 2))
		//{
		//var p0:Vector3D = scaleKeys[j].scale;
		//var p1:Vector3D = scaleKeys[j + 1].scale;
		//var p2:Vector3D = scaleKeys[j + 2].scale;
		//if(p0.equals(p1) && p1.equals(p2))
		//{
		//scaleKeys.splice(j + 1, 1);
		//the middle key is unneeded
		//j--;
		//}
		//j ++;
		//}
		//}
		//
		//if(scaleKeys.length > 1)
		//{
		//var j : Int = 0;
		//while(j <(scaleKeys.length - 1))
		//{
		//if(scaleKeys[j].frame>= scaleKeys[j + 1].frame) //bad frame, unneed and may cause problems
		//{
		//scaleKeys.splice(j + 1, 1);
		//j--;
		//}
		//j++;
		//}
		//}
		//
		//if(rotationKeys.length > 2)
		//{
		//var j : Int = 0;
		//while(j <(scaleKeys.length - 2))
		//{
		//var r0 : Quaternion = rotationKeys[j].rotation;
		//var r1 : Quaternion = rotationKeys[j + 1].rotation;
		//var r2 : Quaternion = rotationKeys[j + 2].rotation;
		//if(r0.equals(r1) && r1.equals(r2))
		//{
		//rotationKeys.splice(j + 1, 1);
		//j --;
		//}
		//j ++;
		//}
		//}
		//
		//if(rotationKeys.length > 1)
		//{
		//var j : Int = 0;
		//while(j < (scaleKeys.length - 1))
		//{
		//if(rotationKeys[j].frame>= rotationKeys[j + 1].frame) //bad frame, unneed and may cause problems
		//{
		//rotationKeys.splice(j + 1, 1);
		//j--;
		//}
		//j++;
		//}
		//}
		//
		//Fill empty keyframe areas
		//if(positionKeys.length > 0)
		//{
		//getFirst,使其首帧为0
		//if(positionKeys[0].frame != 0)
		//{
		//positionKeys.unshift(positionKeys[0].clone());
		//positionKeys[0].frame = 0;
		//}
		//getLast
		//if(positionKeys[positionKeys.length - 1].frame != animationFrames)
		//{
		//positionKeys.push(positionKeys[positionKeys.length - 1].clone());
		//positionKeys[positionKeys.length - 1].frame = Std.int(animationFrames);
		//}
		//}
		//
		//if(scaleKeys.length > 0)
		//{
		//getFirst,使其首帧为0
		//if(scaleKeys[0].frame != 0)
		//{
		//scaleKeys.unshift(scaleKeys[0].clone());
		//scaleKeys[0].frame = 0;
		//}
		//getLast
		//if(scaleKeys[scaleKeys.length - 1].frame != animationFrames)
		//{
		//scaleKeys.push(scaleKeys[scaleKeys.length - 1].clone());
		//scaleKeys[scaleKeys.length - 1].frame = Std.int(animationFrames);
		//}
		//}
		//
		//if(rotationKeys.length > 0)
		//{
		//getFirst,使其首帧为0
		//if(rotationKeys[0].frame != 0)
		//{
		//rotationKeys.unshift(rotationKeys[0].clone());
		//rotationKeys[0].frame = 0;
		//}
		//getLast
		//if(rotationKeys[rotationKeys.length - 1].frame != animationFrames)
		//{
		//rotationKeys.push(rotationKeys[rotationKeys.length - 1].clone());
		//rotationKeys[rotationKeys.length - 1].frame = Std.int(animationFrames);
		//}
		//}
		//
		//更新joint中的数据
		//joint.refresh();
		//}
		//}
		//
		//Needed for animation and skinning...
		calculateGlobalMatrixes(null, null);

		//rigid animation for non animated meshes
		var len : Int = allJoints.length;
		for (i in 0...len)
		{
			var joint : Joint = allJoints[i];
			var l:Int = joint.attachedMeshes.length;
			for (j in 0...l)
			{
				var buffer : SkinnedMeshBuffer = Lib.as(joint.attachedMeshes[j],SkinnedMeshBuffer);
				buffer.transformation.copy(joint.globalAnimatedMatrix);
			}
		}

		recalculateBoundingBox();
	}

	public function getMeshType() : Int
	{
		return AnimatedMeshType.AMT_SKINNED;
	}

	public function getAllJoints():Vector<Joint>
	{
		return allJoints;
	}

	// Gets joint count.
	public function getJointCount() : Int
	{
		return allJoints.length;
	}

	// Gets the name of a joint.
	public function getJointName(num : Int) : String
	{
		var len:Int = allJoints.length;
		if (num < 0 || num >= len)
		{
			return null;
		}
		return allJoints[num].name;
	}

	// Gets a joint number from its name
	public function getJointIndex(name : String) : Int
	{
		var len : Int = allJoints.length;
		for (i in 0...len)
		{
			if (allJoints[i].name == name)
			{
				return i;
			}
		}
		return -1;
	}

	// returns amount of mesh buffers.
	public function getMeshBufferCount() : Int
	{
		return skiningBuffers.length;
	}

	// returns pointer to a mesh buffer
	public function getMeshBuffer(nr : Int) : MeshBuffer
	{
		var len:Int = skiningBuffers.length;
		if (nr < 0 || nr >= len)
		{
			return null;
		}
		return skiningBuffers[nr];
	}

	// sets a flag of all contained materials to a new value
	public function setMaterialFlag(flag : Int, value : Bool) : Void
	{
		var len : Int = skiningBuffers.length;
		for (i in 0...len)
		{
			skiningBuffers[i].getMaterial().setFlag(flag, value);
		}
	}

	public function setMaterialTexture(texture : ITexture, layer : Int = 0) : Void
	{
		if (layer < 0 || layer > 1) return;
		var len : Int = skiningBuffers.length;
		for (i in 0...len)
		{
			skiningBuffers[i].getMaterial().setTexture(texture, layer);
		}
	}

	public function useAnimationFrom(mesh:ISkinnedMesh):Bool
	{
		var unmatched:Bool = false;

		var len:Int = allJoints.length;
		for (i in 0...len)
		{
			var jt:Joint = allJoints[i];
			jt.useAnimationFrom = null;

			if (jt.name == "")
			{
				unmatched = true;
			}
			else
			{
				var len:Int = mesh.getAllJoints().length;
				for (j in 0...len)
				{
					var otherJoint:Joint = mesh.getAllJoints()[j];
					if (otherJoint.name == jt.name)
					{
						jt.useAnimationFrom = otherJoint;
					}
				}

				if (jt.useAnimationFrom == null)
				{
					unmatched = true;
				}
			}
		}

		checkForAnimation();

		return !unmatched;
	}

	public function recoverJointsFromMesh(jointChildSceneNodes:Vector<BoneSceneNode>):Void
	{
		var len:Int = allJoints.length;
		for (i in 0...len)
		{
			var node:BoneSceneNode = jointChildSceneNodes[i];
			var jt:Joint = allJoints[i];

			node.setPosition(jt.localAnimatedMatrix.getTranslation());
			node.setRotation(jt.localAnimatedMatrix.getRotation(true));
			node.setScale(jt.localAnimatedMatrix.getScale());

			node.positionHint = jt.positionHint;
			node.scaleHint = jt.scaleHint;
			node.rotationHint = jt.rotationHint;

			node.updateAbsolutePosition();
		}
	}

	public function transferJointsToMesh(jointChildSceneNodes:Vector<BoneSceneNode>):Void
	{
		var len:Int = allJoints.length;
		for (i in 0...len)
		{
			var node:BoneSceneNode = jointChildSceneNodes[i];
			var jt:Joint = allJoints[i];

			jt.localAnimatedMatrix.setRotation(node.getRotation(), true);
			jt.localAnimatedMatrix.setTranslation(node.getPosition());
			var matrix:Matrix4 = new Matrix4();
			matrix.setScale(node.getScale());
			jt.localAnimatedMatrix.prepend(matrix);

			jt.positionHint = node.positionHint;
			jt.scaleHint = node.scaleHint;
			jt.rotationHint = node.rotationHint;

			jt.globalSkinningSpace = node.getSkinningSpace() == BoneSkinningSpace.GLOBAL;
		}

		//remove cache,temp...
		lastAnimatedFrame = -1;
		lastSkinnedFrame = -1;
	}

	public function transferOnlyJointsHintsToMesh(jointChildSceneNodes:Vector<BoneSceneNode>):Void
	{
		var len:Int = allJoints.length;
		for (i in 0...len)
		{
			var node:BoneSceneNode = jointChildSceneNodes[i];
			var jt:Joint = allJoints[i];

			jt.positionHint = node.positionHint;
			jt.scaleHint = node.scaleHint;
			jt.rotationHint = node.rotationHint;
		}
	}

	public function createJoints(jointChildSceneNodes:Vector<BoneSceneNode>, sceneNode:SkinnedMeshSceneNode):Void
	{
		//Create new joints
		var len:Int = allJoints.length;
		for (i in 0...len)
		{
			jointChildSceneNodes.push(new BoneSceneNode(i, allJoints[i].name));
		}

		//Match up parents
		var len:Int = jointChildSceneNodes.length;
		for (i in 0...len)
		{
			var boneSceneNode:BoneSceneNode = jointChildSceneNodes[i];

			var jt:Joint = allJoints[i];

			var parentID:Int = -1;
		}
	}

	public function updateNormalsWhenAnimating(on : Bool = false) : Void
	{
		animateNormals = on;
	}

	//Sets Interpolation Mode
	public function setInterpolationMode(mode : Int) : Void
	{
		interpolationMode = mode;
	}

	public function getMeshBuffers() : Vector<MeshBuffer>
	{
		return skiningBuffers;
	}

	public function addMeshBuffer() : SkinnedMeshBuffer
	{
		var buffer : SkinnedMeshBuffer = new SkinnedMeshBuffer();
		skiningBuffers.push(buffer);
		return buffer;
	}

	public function addJoint(parent : Joint = null) : Joint
	{
		var jt : Joint = new Joint();
		allJoints.push(jt);

		if (parent != null)
		{
			//Set parent(Be careful of the mesh loader also setting the parent)
			parent.children.push(jt);
		}

		return jt;
	}

	public function addPositionKey(jt : Joint) : PositionKey
	{
		if (jt == null) return null;
		var key : PositionKey = new PositionKey();
		jt.positionKeys.push(key);
		return key;
	}

	public function addScaleKey(jt : Joint) : ScaleKey
	{
		if (jt == null) return null;
		var key : ScaleKey = new ScaleKey();
		jt.scaleKeys.push(key);
		return key;
	}

	public function addRotationKey(jt : Joint) : RotationKey
	{
		if (jt == null) return null;
		var key : RotationKey = new RotationKey();
		jt.rotationKeys.push(key);
		return key;
	}

	public function addWeight(jt : Joint) : Weight
	{
		if (jt == null) return null;
		var weight : Weight = new Weight();
		jt.weights.push(weight);
		return weight;
	}

	/**
	 * Check if the mesh is non-animated
	 * @return
	 */
	public function isStatic() : Bool
	{
		return !hasAnimation;
	}

	public function normalizeWeights() : Void
	{
		// note: unsure if weights ids are going to be used.

		// Normalise the weights on bones....
		var totalWeights : Vector<Vector<Float>> = new Vector<Vector<Float>>();

		var len : Int = skiningBuffers.length;
		for (i in 0...len)
		{
			totalWeights.push(new Vector<Float>(skiningBuffers[i].getVertexCount()));
		}

		var weight : Weight;

		var jointLen : Int = allJoints.length;
		for (i in 0...jointLen)
		{
			var jt : Joint = allJoints[i];
			var j : Int = 0;
			var jtLen:Int = jt.weights.length;
			while (j < jtLen)
			{
				weight = jt.weights[j];

				if (weight.strength < 0) //Check for invalid weights
				{
					jt.weights.splice(j, 1);
					j--;
					jtLen--;
				}
				else
				{
					totalWeights[weight.bufferID][weight.vertexID] += weight.strength;
				}
				j++;
			}
		}

		for (i in 0...jointLen)
		{
			var jt : Joint = allJoints[i];

			var weightLen : Int = jt.weights.length;
			for (j in 0...weightLen)
			{
				weight = jt.weights[j];
				var total : Float = totalWeights[weight.bufferID][weight.vertexID];
				if (total != 0)
				{
					weight.strength /= total;
				}
			}
		}

		totalWeights = null;
	}

	public function getBoundingBox():AABBox
	{
		return boundingBox;
	}

	public function setBoundingBox(box:AABBox):Void
	{
		this.boundingBox = box;
	}

	public function recalculateBoundingBox() : Void
	{
		if (skiningBuffers == null || skiningBuffers.length == 0)
		{
			boundingBox.reset(0, 0, 0);
			return;
		}

		var bb : AABBox = new AABBox();
		var len : Int = skiningBuffers.length;
		for (i in 0...len)
		{
			var buffer : SkinnedMeshBuffer = Lib.as(skiningBuffers[i], SkinnedMeshBuffer);
			buffer.recalculateBoundingBox();
			bb.copy(buffer.getBoundingBox());
			buffer.transformation.transformBoxEx(bb);
			if (i == 0)
			{
				boundingBox.resetAABBox(bb);
			}
			else
			{
				boundingBox.addInternalAABBox(bb);
			}
		}
	}
}
