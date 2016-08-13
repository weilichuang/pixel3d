package;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Vector3D;
import flash.Lib;
import flash.text.TextField;
import pixel3d.animator.AnimatorCameraFPS;
import pixel3d.material.TextureManager;
import pixel3d.math.Vector2i;
import pixel3d.scene.CameraSceneNode;
import pixel3d.scene.SceneManager;
import pixel3d.utils.CursorControl;
import pixel3d.renderer.IVideoDriver;
import pixel3d.renderer.VideoDriverBasic;
class Test extends Sprite
{
    private var manager:SceneManager;
	private var textureManager:TextureManager;
	private var driver:IVideoDriver;
	private var camera:CameraSceneNode;
	private var cameraFPS:AnimatorCameraFPS;
	private var target:Sprite;

	private var control:CursorControl;
	
	private var fpsText:TextField;
	private var fps:Int;
	private var time:Int;
	public function new() 
	{
		super();
		
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;

		textureManager = new TextureManager();
		
		driver = new VideoDriverBasic(new Vector2i(Std.int(Lib.current.stage.stageWidth), Std.int(Lib.current.stage.stageHeight)));
        driver.setPerspectiveCorrectDistance(1000);
        driver.setMipMapDistance(4000);
		driver.setAmbient(0xFFF000);
		  
		manager = new SceneManager(driver);
		this.addChild(manager.getRenderTarget());
        
		fpsText = new TextField();
		fpsText.width = 100;
		fpsText.textColor = 0xff0000;
		//fpsText.backgroundColor = 0xffffff;
		fpsText.selectable = false;
		this.addChild(fpsText);
		
		control = new CursorControl(new Vector2i(540, 480), manager.getRenderTarget());

		camera = new CameraSceneNode(new Vector3D(0, 0, 0));
        camera.setPosition(new Vector3D(0., 230., -500.));
		camera.setFar(2000);
		camera.setNear(1);
		
		cameraFPS = new AnimatorCameraFPS(control, 2, 0.5, 0, true, false);
		camera.addAnimator(cameraFPS);
	
		manager.addChild(camera);
		manager.setActiveCamera(camera);
		
		Lib.current.stage.addEventListener(Event.RESIZE, onResize);
	}
	
	private function onResize(event:Event):Void
	{
		driver.setScreenSize(new Vector2i(Std.int(stage.stageWidth), Std.int(stage.stageHeight)));
	}
	
	public function startRender():Void 
	{
		control.addListener();
		this.addEventListener(Event.ENTER_FRAME, _onEnterFrame);
		
		time = Lib.getTimer();
	}
	
	public function stopRender():Void 
	{
		control.removeListener();
		this.removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
	}
	
	private function _onEnterFrame(?e:Event=null):Void
	{
	    if(Lib.getTimer() - time>= 1000)
		{
			fpsText.text = fps + "/" + Lib.current.stage.frameRate + ",triangles:"+driver.getTriangleCountDrawn();
			fps = 0;
			time = Lib.getTimer();
		}
		manager.beginScene();
		manager.drawAll();
		manager.endScene(); 
		fps++;
	}
}