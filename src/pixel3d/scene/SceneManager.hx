package pixel3d.scene;
import flash.display.Sprite;
import flash.Lib;
import pixel3d.math.AABBox;
import pixel3d.math.MathUtil;
import pixel3d.math.Matrix4;
import pixel3d.renderer.IVideoDriver;
import pixel3d.renderer.RenderState;
import pixel3d.renderer.VideoDriverType;

//添加一个属性，用于判断是否需要交互
//TODO 根据输入参数来决定使用何种IVideoDriver。而不是由外部来传入
class SceneManager extends SceneNode implements ISceneManager
{
	private var _driver : IVideoDriver;
	private var _viewFrustum : ViewFrustum;
	private var _activeCamera : CameraSceneNode;
	
	private var _lightList : Array<LightSceneNode>;
	private var _solidList : Array<SceneNode>;
	private var _transparentList : Array<SceneNode>;
	private var _skyboxList : Array<SceneNode>;
	private var _shadowList : Array<SceneNode>;
	
	private var _lightCount : Int;
	private var _solidCount : Int;
	private var _transparentCount : Int;
	private var _skyboxCount : Int;
	private var _shadowCount : Int;
	
	private var tmpBox : AABBox;
	private var currentRenderType : Int;
	
	//鼠标当前位置的SceneNode
	private var prevSceneNode:SceneNode;
	private var currentSceneNode:SceneNode;
	
	private var renderTarget : Sprite;
	
	private var hasShadow:Bool;

	public function new(driver:IVideoDriver)
	{
		super();
		
		_solidList = new Array<SceneNode>();
		_transparentList = new Array<SceneNode>();
		_lightList = new Array<LightSceneNode>();
		_skyboxList = new Array<SceneNode>();
		_shadowList = new Array<SceneNode>();
		_lightCount = 0;
		_solidCount = 0;
		_transparentCount = 0;
		_skyboxCount = 0;
		_shadowCount = 0;
		currentRenderType = - 1;

		_sceneManager = this;
		autoCulling = false;
		debug = false;
		
		
		tmpBox = new AABBox();
		
		renderTarget = new Sprite();
		renderTarget.doubleClickEnabled = true;
		
		setVideoDriver(driver);
	}
	
	public function getCurrentRenderType() : Int
	{
		return currentRenderType;
	}

	public function getVideoDriver() : IVideoDriver
	{
		return _driver;
	}
	
	public function setRenderTarget(sp : Sprite) : Void
	{
		if(sp == null) return;
		if(renderTarget != null) renderTarget.removeChild(_driver.getBitmap());
		renderTarget = sp;
		renderTarget.doubleClickEnabled = true;
		renderTarget.addChild(_driver.getBitmap());
	}
	
	public function getRenderTarget():Sprite
	{
		return renderTarget;
	}
	
	public function setVideoDriver(driver : IVideoDriver) : Void
	{
		_driver = driver;
		
		renderTarget.addChild(_driver.getBitmap());
		//renderTarget.addEventListener(MouseEvent.CLICK, __click);
		//renderTarget.addEventListener(MouseEvent.DOUBLE_CLICK, __doubleClick);
		//renderTarget.addEventListener(MouseEvent.MOUSE_DOWN, __mouseDown);
		//renderTarget.addEventListener(MouseEvent.MOUSE_UP, __mouseUp);
		//renderTarget.addEventListener(MouseEvent.MOUSE_WHEEL, __mouseWheel);
		//renderTarget.addEventListener(MouseEvent.ROLL_OUT, _rollOut);
		//renderTarget.addEventListener(MouseEvent.ROLL_OVER, __rollOver);
	}
	
	public function registerNodeForRendering(node : SceneNode, type : Int) : Void
	{
		switch(type)
		{
			case SceneNodeType.SOLID :
			{
				if( ! node.autoCulling || ! isCulled(node))
				{
					_solidList[_solidCount++] = node;
				}
			}
			case SceneNodeType.TRANSPARENT :
			{
				if( ! node.autoCulling || ! isCulled(node))
				{
					_transparentList[_transparentCount++] = node;
				}
			}
			case SceneNodeType.LIGHT :
			{
				_lightList[_lightCount++] = Lib.as(node,LightSceneNode);
			}
			case SceneNodeType.SKYBOX :
			{
				_skyboxList[_skyboxCount++] = node;
			}
			case SceneNodeType.SHADOW :
			{
				_shadowList[_shadowCount++] = node;
			}
		}
	}
	
	public function drawAll() : Void
	{
		onRegisterSceneNode();
		
		_activeCamera.render();
		
		//render lights
		_driver.removeAllLights();
		currentRenderType = SceneNodeType.LIGHT;
		for(i in 0..._lightCount)
		{
			_lightList[i].render();
		}
		
		var castShadows : Bool = false;
		for(i in 0..._lightCount)
		{
			if(_lightList[i].light.castShadows)
			{
				castShadows = true;
				break;
			}
		}
		
		//是否会产生阴影
		hasShadow = (_driver.canShadow() && castShadows && _shadowCount > 0);
		untyped _solidList.sortOn("distance",16 | 2);
		if(hasShadow)
		{
			if (_driver.getDriverType() == VideoDriverType.SHADOWVOLUME)
			{
				_driver.setRenderState(RenderState.NORMAL);
				
				currentRenderType = SceneNodeType.SOLID;
				//关闭光源，将整个scence渲染一遍(只渲染不透明物体),获得深度值
				for(i in 0..._solidCount)
				{
					_solidList[i].renderAmbientLight();
				}
			
				currentRenderType = SceneNodeType.SHADOW;
				for(i in 0..._shadowCount)
				{
					_shadowList[i].render();
				}
			
				//清空深度
				_driver.clearZBuffer();
			
				_driver.setRenderState(RenderState.SHADOW);
			}
			else if (_driver.getDriverType() == VideoDriverType.SHADOWMAP)
			{
				currentRenderType = SceneNodeType.SOLID;
				//获得场景的深度值
				for(i in 0..._solidCount)
				{
					_solidList[i].renderShadowMap();
				}
			}
		}
		else
		{
			_driver.setRenderState(RenderState.NORMAL);
		}

		//先渲染近的，减少重复渲染同一点
		currentRenderType = SceneNodeType.SOLID;
		for(i in 0..._solidCount)
		{
			_solidList[i].render();
		}

		//先渲染不透明物体，然后再渲染skybox,避免多计算
		//如果有多个skybox,只渲染最后一个
		currentRenderType = SceneNodeType.SKYBOX;
		if(_skyboxCount> 0)
		{
			_skyboxList[_skyboxCount-1].render();
		}
		
		//先渲染远处的，避免透明度错误
		currentRenderType = SceneNodeType.TRANSPARENT;
		untyped _transparentList.sortOn("distance",16 | 1);
		for(i in 0..._transparentCount)
		{
			_transparentList[i].render();
		}
		
		onAnimate(Lib.getTimer());
		
		//updateCurrentSceneNodeCursor();

		_lightCount = 0;
		_solidCount = 0;
		_transparentCount = 0;
		_skyboxCount = 0;
		_shadowCount = 0;
	}
	
	public function getActiveCamera() : CameraSceneNode
	{
		return _activeCamera;
	}
	
	public function setActiveCamera(camera : CameraSceneNode) : Void
	{
		if(camera != null)
		{
			_activeCamera = camera;
			_viewFrustum = _activeCamera.getViewFrustum();
		}
	}
	
	public inline function isCulled(node : SceneNode) : Bool
	{
		var matrix : Matrix4 = node.getAbsoluteTransformation();
		matrix.transformBox2(node.getBoundingBox(), tmpBox);
		
		if(!tmpBox.intersectsWithBox(_viewFrustum.getBoundingBox()))
		{
			return true;
		}
		else
		{
			// set distance for render order purposes
			var camera_matrix : Matrix4 = _activeCamera.getAbsoluteTransformation();
			var vx : Float = matrix.m41 - camera_matrix.m41;
			var vy : Float = matrix.m42 - camera_matrix.m42;
			var vz : Float = matrix.m43 - camera_matrix.m43;
			node.distance = MathUtil.sqrt(vx * vx + vy * vy + vz * vz);
			return false;
		}
	}
	
	public function beginScene():Void
	{
		_driver.beginScene();
	}
	
	public function endScene():Void
	{
		_driver.endScene();
	}
	
	//public function getRayFromScreenCoordinates(pos:Vector2D, camera:CameraSceneNode=null):Segment3D
	//{
		//if(camera == null)
		//{
			//camera = this.getActiveCamera();
		//}
		//
		//var viewFrustrum:ViewFrustum = camera.getViewFrustum();
		//
		//var farLeftUp:Vector3D = viewFrustrum.getFarLeftUp();
		//var lefttoright:Vector3D = viewFrustrum.getFarRightUp().subtract(farLeftUp);
		//var uptodown:Vector3D = viewFrustrum.getFarLeftDown().subtract(farLeftUp);
		//
		//var screenSize:Dimension = _driver.getScreenSize();
		//
		//var dx:Float = pos.x / screenSize.width;
		//var dy:Float = pos.y / screenSize.height;
//
		//var end:Vector3D = new Vector3D();
		//end.x = farLeftUp.x +(lefttoright.x * dx) +(uptodown.x * dy);
		//end.y = farLeftUp.y +(lefttoright.y * dx) +(uptodown.y * dy);
		//end.z = farLeftUp.z +(lefttoright.z * dx) +(uptodown.z * dy);
//
		//var segment:Segment3D = new Segment3D();
		//segment.setFromPoints(camera.getAbsolutePosition(), end);
		//
		//return segment;
	//}
	
	//public function getSceneNodeFromSegment3D(segment3D:Segment3D):SceneNode
	//{
		//var nodes:Array<SceneNode> =[];
		//var children:flash.Vector<SceneNode>=this.getChildren();
		//for(i in 0...numChildren)
		//{
			//var child:SceneNode = children[i];
			//if(child.visible)
			//{
				//tmpBox.copy(child.getBoundingBox());
				//child.getAbsoluteTransformation().transformBox(tmpBox);
				//if(IntersectionSegment3DAABBox.test(tmpBox, segment3D))
				//{
					//nodes.push(child);
				//}
			//}
		//}
		//if(nodes.length == 0)
		//{
			//return null;
		//}else
		//{
			//untyped nodes.sortOn("distance", 16 | 2);//排序，取最近的一个
			//return nodes[0];
		//}
	//}
	
	//public function updateCurrentSceneNodeCursor():Void
	//{
		//prevSceneNode = currentSceneNode;
		//currentSceneNode = getSceneNodeFromSegment3D(getRayFromScreenCoordinates(new Vector2D(renderTarget.mouseX, renderTarget.mouseY)));
		//
		//if(currentSceneNode != null && currentSceneNode.isTrulyVisible() && currentSceneNode.isTrulyMouseEnabled() && currentSceneNode.buttonMode)
		//{
			//Mouse.cursor = MouseCursor.BUTTON;
		//}else
		//{
			//Mouse.cursor = MouseCursor.AUTO;
		//}
	//}
	
	//private function __click(e:MouseEvent):Void
	//{
		//if(currentSceneNode != null)
		//{
			//currentSceneNode.dispatchEvent(new Mouse3DEvent(Mouse3DEvent.CLICK, currentSceneNode));
		//}
	//}
	//
	//private function __doubleClick(e:MouseEvent):Void
	//{
		//if(currentSceneNode != null && currentSceneNode.doubleClickEnabled)
		//{
			//currentSceneNode.dispatchEvent(new Mouse3DEvent(Mouse3DEvent.DOUBLE_CLICK, currentSceneNode));
		//}
	//}
	//
	//private function __mouseUp(e:MouseEvent):Void
	//{
		//if(currentSceneNode != null)
		//{
			//currentSceneNode.dispatchEvent(new Mouse3DEvent(Mouse3DEvent.MOUSE_UP, currentSceneNode));
		//}
	//}
	//
	//private function __mouseDown(e:MouseEvent):Void
	//{
		//if(currentSceneNode != null)
		//{
			//currentSceneNode.dispatchEvent(new Mouse3DEvent(Mouse3DEvent.MOUSE_DOWN, currentSceneNode));
		//}
	//}
	//
	//private function _rollOut(e:MouseEvent):Void
	//{
		//if(currentSceneNode != prevSceneNode && prevSceneNode != null)
		//{
			//prevSceneNode.dispatchEvent(new Mouse3DEvent(Mouse3DEvent.ROLL_OUT, currentSceneNode));
		//}
	//}
	//
	//private function __rollOver(e:MouseEvent):Void
	//{
		//if(currentSceneNode != null)
		//{
			//currentSceneNode.dispatchEvent(new Mouse3DEvent(Mouse3DEvent.ROLL_OVER, currentSceneNode));
		//}
	//}
	//
	//private function __mouseWheel(e:MouseEvent):Void
	//{
		//if(currentSceneNode != null)
		//{
			//var event:Mouse3DEvent = new Mouse3DEvent(Mouse3DEvent.MOUSE_WHEEL, currentSceneNode);
			//event.delta = e.delta;
			//currentSceneNode.dispatchEvent(event);
		//}
	//}
}
