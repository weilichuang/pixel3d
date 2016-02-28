package;
import flash.Lib;
import pixel3d.events.Mouse3DEvent;
import pixel3d.scene.CubeSceneNode;
import pixel3d.scene.PlaneSceneNode;

class IntersectionTest extends Test
{
	static function main()
	{
	   var test:IntersectionTest = new IntersectionTest();
	   Lib.current.addChild(test);
	   test.startRender();
	}
	
    private var plane:PlaneSceneNode;
	private var cube1:CubeSceneNode;
	private var cube2:CubeSceneNode;
	private var cube3:CubeSceneNode;
	private var cube4:CubeSceneNode;
	public function new() 
	{
		super();
		
		camera.setPositionXYZ(0, 100, -300);
		
		cube1 = new CubeSceneNode(50, 50, 50);
		cube1.setMaterialEmissiveColor(0x00ff00);
		cube1.x = -100;
		cube1.z = 200;
		cube1.buttonMode = true;
		cube1.addEventListener(Mouse3DEvent.MOUSE_WHEEL, __wheel);
		
		cube2 = new CubeSceneNode(50, 50, 50);
		cube2.setMaterialEmissiveColor(0x0000ff);
		cube2.x = 100;
		cube2.z = 200;
		cube2.buttonMode = true;
		cube2.doubleClickEnabled = true;
		cube2.addEventListener(Mouse3DEvent.DOUBLE_CLICK, __doubleClick);
		
		cube3 = new CubeSceneNode(50, 50, 50);
		cube3.setMaterialEmissiveColor(0x00ffff);
		cube3.x = -100;
		cube3.z = 0;
		cube3.buttonMode = true;
		cube3.mouseEnabled = true;
		
		cube4 = new CubeSceneNode(50, 50, 50);
		cube4.setMaterialEmissiveColor(0xffff00);
		cube4.x = 100;
		cube4.z = 0;

		manager.addChild(cube1);
		manager.addChild(cube2);
		manager.addChild(cube3);
		manager.addChild(cube4);
	}
	
	private function __wheel(e:Mouse3DEvent):Void
	{
		e.node.scaleX += e.delta;
		e.node.scaleY += e.delta;
		e.node.scaleZ += e.delta;
	}
	
	private function __doubleClick(e:Mouse3DEvent):Void
	{
		e.node.setMaterialEmissiveColor(0xff0000);
	}
}