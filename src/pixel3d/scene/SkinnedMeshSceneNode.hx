package pixel3d.scene;
import flash.Lib;
import flash.Vector;
import pixel3d.material.Material;
import pixel3d.math.AABBox;
import pixel3d.math.MathUtil;
import pixel3d.math.Matrix4;
import pixel3d.mesh.MeshBuffer;
import pixel3d.mesh.SkinnedMesh;
import pixel3d.mesh.SkinnedMeshBuffer;
import pixel3d.renderer.IVideoDriver;

class SkinnedMeshSceneNode extends SceneNode
{
	private var materials : Vector<Material>;
	private var materialCount : Int;
	private var useDefaultMaterial : Bool ;
	private var mesh : SkinnedMesh;
	private var beginFrameTime : Int;
	private var startFrame : Int;
	private var endFrame : Int;
	private var framesPerSecond : Float;
	private var currentFrame : Float;
	private var beforeFrame : Float;
	private var looping : Bool;
	private var lastTimeMs : Int;
	private var worldTransformMatrix : Matrix4;
	
	/**
	* @param	?mesh
	* @param	?useDefaultMaterial
	*/
	public function new(mesh : SkinnedMesh = null, useDefaultMaterial : Bool = true )
	{
		super();
		beginFrameTime = Lib.getTimer();
		startFrame = 0;
		endFrame = 0;
		currentFrame = 0;
		beforeFrame = 0;
		lastTimeMs = 0;
		framesPerSecond = 25.0 / 1000.;
		looping = true;
		materials = new Vector<Material>();
		materialCount = 0;
		worldTransformMatrix = new Matrix4();
		this.useDefaultMaterial = useDefaultMaterial;
		setSkinnedMesh(mesh);
	}
	
	public function setCurrentFrame(frame : Float) : Void
	{
		beforeFrame = currentFrame;
		currentFrame = MathUtil.clamp(frame, startFrame * 1.0, endFrame * 1.0);
		if(framesPerSecond> 0)
		{
			beginFrameTime = Lib.getTimer() + Std.int((currentFrame - startFrame) / framesPerSecond);
		} else
		{
			beginFrameTime = Lib.getTimer() - Std.int((currentFrame - endFrame) / framesPerSecond);
		}
	}
	
	public function buildFrameNr(timeMs : Int) : Void
	{
		beforeFrame = currentFrame;
		if(startFrame == endFrame || framesPerSecond == 0.0)
		{
			currentFrame = startFrame;
		} else if(looping)
		{
			currentFrame += timeMs * framesPerSecond;
			//play animation looped
			if(framesPerSecond> 0.0) //forwards ...
			{
				if(currentFrame> endFrame)
				{
					currentFrame -=(endFrame - startFrame);
				}
			} else //backwards...
			{
				if(currentFrame <startFrame)
				{
					currentFrame +=(endFrame - startFrame);
				}
			}
		} else
		{
			// play animation non looped
			currentFrame += timeMs * framesPerSecond;
			if(framesPerSecond> 0.0) //forwards
			{
				if(currentFrame> endFrame)
				{
					currentFrame = endFrame;
					//loopCallBack
				}
			}else
			{
				if(currentFrame <startFrame)
				{
					currentFrame = startFrame;
				}
			}
		}
	}
	
	public function gotoAndStop(i : Int = 0) : Void
	{
		if(mesh == null) return;
		setFrameLoop(i, i);
	}
	
	public function gotoAndPlay(s : Int, e : Int = - 1)
	{
		if(mesh == null) return;
		if(e == - 1)
		{
			setFrameLoop(s, mesh.getFrameCount());
		} else
		{
			setFrameLoop(s, e);
		}
	}
	
	public function getCurrentFrame() : Float
	{
		return currentFrame;
	}
	
	override public function onRegisterSceneNode() : Void
	{
		if(visible)
		{
			if(_material_transparent) sceneManager.registerNodeForRendering(this, SceneNodeType.TRANSPARENT);
			if(_material_solid) sceneManager.registerNodeForRendering(this, SceneNodeType.SOLID);
			super.onRegisterSceneNode();
		}
	}
	
	override public function onAnimate(timeMs : Int) : Void
	{
		buildFrameNr(timeMs - lastTimeMs);
		lastTimeMs = timeMs;
		super.onAnimate(timeMs);
	}
	
	override public function render() : Void
	{
		var driver : IVideoDriver = sceneManager.getVideoDriver();
		
		if (mesh == null || driver == null) return;
		
		var isTransparentPass : Bool = (sceneManager.getCurrentRenderType() == SceneNodeType.TRANSPARENT);
		
		if ( !mesh.isStatic() && mesh.getLastAnimatedFrame() != currentFrame ) //静态模型则不需要更新
		{
			mesh.animateMesh(currentFrame, 1);
			mesh.skinMesh();
		}
		
		var count : Int = mesh.getMeshBufferCount();
		for(i in 0...count)
		{
			var sk : SkinnedMeshBuffer = Lib.as(mesh.getMeshBuffer(i),SkinnedMeshBuffer);
			if(materials[i].transparenting == isTransparentPass)
			{
				_absoluteTransformation.prepend2(sk.transformation, worldTransformMatrix);
				
				driver.setTransformWorld(worldTransformMatrix);
				
				driver.setMaterial(materials[i]);
				driver.drawMeshBuffer(sk);
			}
		}
		if(debug)
		{
			debugWireframe = true;
			driver.draw3DBox(getBoundingBox(), debugColor, debugAlpha, debugWireframe);
		}
	}
	
	public function getStartFrame() : Int
	{
		return startFrame;
	}
	
	public function getEndFrame() : Int
	{
		return endFrame;
	}
	
	public function setFrameLoop(begin : Int, end : Int) : Bool
	{
		var maxFrameCount : Int = mesh.getFrameCount() - 1;
		if(end <begin)
		{
			startFrame = MathUtil.clampInt(end, 0, maxFrameCount);
			endFrame = MathUtil.clampInt(begin, startFrame, maxFrameCount);
		} else 
		{
			startFrame = MathUtil.clampInt(begin, 0, maxFrameCount);
			endFrame = MathUtil.clampInt(end, startFrame, maxFrameCount);
		}
		if(framesPerSecond <0)
		{
			setCurrentFrame(endFrame);
		} else 
		{
			setCurrentFrame(startFrame);
		}
		return true;
	}
	
	public function setAnimationSpeed(per : Float) : Void
	{
		framesPerSecond = per * 0.001;
	}
	
	public function getAnimationSpeed() : Float
	{
		return(framesPerSecond * 1000);
	}
	
	override public function getBoundingBox() : AABBox
	{
		if(mesh == null) return null;
		return mesh.getBoundingBox();
	}
	
	override public function getMaterial(i : Int = 0) : Material
	{
		if(i <0 || i>= materialCount) return null;
		return materials[i];
	}
	
	override public function getMaterialCount() : Int
	{
		return materialCount;
	}
	
	public function setLoopMode(looped : Bool) : Void
	{
		looping = looped;
	}
	
	public function setSkinnedMesh(mesh : SkinnedMesh) : Void
	{
		if(mesh == null) return;
		this.mesh = Lib.as(mesh.getMesh(0),SkinnedMesh);
		setMaterials(mesh, useDefaultMaterial);
		setFrameLoop(0, mesh.getFrameCount());
	}
	
	private function setMaterials(mesh : SkinnedMesh, value : Bool) : Void
	{
		materials.length = 0;
		materialCount = 0;
		if(mesh != null)
		{
			var len : Int = mesh.getMeshBufferCount();
			for(i in 0...len)
			{
				var buffer : MeshBuffer = mesh.getMeshBuffer(i);
				if(value && buffer != null)
				{
					materials[i] = buffer.getMaterial();
				} 
				else 
				{
					if(buffer == null)
					{
						materials[i] = new Material();
					} else
					{
						materials[i] = buffer.getMaterial().clone();
					}
				}
			}
		}
		materialCount = materials.length;
		updateMaterialTypes();
	}
	
	public function setUseDefaultMaterial(value : Bool) : Void
	{
		if(useDefaultMaterial != value)
		{
			useDefaultMaterial = value;
			setMaterials(mesh, useDefaultMaterial);
		}
	}
	
	public function isUseDefaultMaterial() : Bool
	{
		return useDefaultMaterial;
	}
}
