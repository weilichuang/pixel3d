package pixel3d.scene;
import flash.Lib;
import flash.Vector;
import pixel3d.material.Material;
import pixel3d.math.AABBox;
import pixel3d.math.MathUtil;
import pixel3d.mesh.AnimatedMeshType;
import pixel3d.mesh.IAnimatedMesh;
import pixel3d.mesh.IMesh;
import pixel3d.mesh.MeshBuffer;
import pixel3d.mesh.KeyFrameData;
import pixel3d.mesh.md2.AnimatedMeshMD2;
import pixel3d.renderer.IVideoDriver;
class AnimatedMeshSceneNode extends SceneNode
{
	private var materials : Vector<Material>;
	private var numMaterial : Int;
	private var useDefaultMaterial : Bool ;
	private var animateMesh : IAnimatedMesh;
	private var beginFrameTime : Int;
	private var startFrame : Int;
	private var endFrame : Int;
	private var lastTimeMs : Int;
	private var framesPerSecond : Float;
	private var beforeFrame : Float;
	private var currentFrame : Float;
	private var looping : Bool;
	
	private var currentMesh:IMesh;

	private var hasShadow:Bool;
	public function new(mesh : IAnimatedMesh = null, useDefaultMaterial : Bool = true)
	{
		super();
		beginFrameTime = Lib.getTimer();
		startFrame = 0;
		endFrame = 0;
		lastTimeMs = 0;
		framesPerSecond = 25.0 / 1000.;
		beforeFrame = 0;
		currentFrame = 0;
		looping = true;
		materials = new Vector<Material>();
		numMaterial = 0;
		this.useDefaultMaterial = useDefaultMaterial;
		setAnimateMesh(mesh);
	}
	
	public function setCurrentFrame(frame : Float) : Void
	{
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
	
	public function getCurrentFrame() : Float
	{
		return currentFrame;
	}
	
	public function getCurrentMesh():IMesh 
	{
		return currentMesh;
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
		if(animateMesh == null || driver==null) return;
		var isTransparentPass : Bool =(sceneManager.getCurrentRenderType() == SceneNodeType.TRANSPARENT);
		
		currentMesh = animateMesh.getMesh(Std.int(currentFrame) , 255, startFrame, endFrame);
		
		driver.setTransformWorld(_absoluteTransformation);

		var len : Int = currentMesh.getMeshBufferCount();
		for(i in 0...len)
		{
			if(materials[i].transparenting == isTransparentPass)
			{
				driver.setMaterial(materials[i]);
				driver.setDistance(distance);
				driver.drawMeshBuffer(currentMesh.getMeshBuffer(i));
			}
		}
		if(debug)
		{
			driver.draw3DBox(getBoundingBox() , debugColor, debugAlpha, debugWireframe);
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
		var maxFrameCount : Int = animateMesh.getFrameCount() - 1;
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
		framesPerSecond =(per * 0.001);
	}
	public function getAnimationSpeed() : Float
	{
		return(framesPerSecond * 1000);
	}
	
	override public function getBoundingBox() : AABBox
	{
		if(animateMesh == null) return super.getBoundingBox();
		return animateMesh.getBoundingBox();
	}
	
	override public function getMaterial(i : Int = 0) : Material
	{
		if(i <0 || i>= numMaterial) return null;
		return materials[i];
	}
	override public function getMaterialCount() : Int
	{
		return numMaterial;
	}
	public function setMD2Animation(data : KeyFrameData) : Bool
	{
		if(animateMesh == null || animateMesh.getMeshType() != AnimatedMeshType.AMT_MD2) return false;
		var m : AnimatedMeshMD2 = Lib.as(animateMesh, AnimatedMeshMD2);
		if(m == null) return false;
		var frameData : KeyFrameData = m.getFrame(data);
		if(frameData != null)
		{
			setAnimationSpeed(frameData.fps);
			setFrameLoop(frameData.begin, frameData.end);
			frameData = null;
			return true;
		}
		return false;
	}
	
	public function setLoopMode(looped : Bool) : Void
	{
		looping = looped;
	}
	
	public function setAnimateMesh(mesh : IAnimatedMesh) : Void
	{
		animateMesh = mesh;
		if(animateMesh != null)
		{
			var m : IMesh = animateMesh.getMesh(Std.int(currentFrame) , 255);
			setMaterials(m, useDefaultMaterial);
			setFrameLoop(0, animateMesh.getFrameCount() - 1);
		}
	}
	
	private function setMaterials(m : IMesh, value : Bool) : Void
	{
		numMaterial = 0;
		materials.length = 0;
		if(m != null)
		{
			var mb : MeshBuffer;
			var count : Int = m.getMeshBufferCount();
			for(i in 0...count)
			{
				mb = m.getMeshBuffer(i);
				if(value)
				{
					materials[i] = mb.getMaterial();
				}else
				{
					materials[i] = mb.getMaterial().clone();
				}
			}
		}
		numMaterial = materials.length;
		updateMaterialTypes();
	}
	public function setUseDefaultMaterial(value : Bool) : Void
	{
		useDefaultMaterial = value;
		var m : IMesh = animateMesh.getMesh(Std.int(currentFrame) , 255);
		setMaterials(m, useDefaultMaterial);
	}
	public function isUseDefaultMaterial() : Bool
	{
		return useDefaultMaterial;
	}
}
