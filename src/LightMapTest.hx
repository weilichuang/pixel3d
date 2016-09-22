package ;
import flash.events.Event;
import flash.Lib;
import pixel3d.material.LoadingTexture;
import pixel3d.scene.CubeNode;

/**
 * LightMap可以设置多种混合方式
 */
class LightMapTest extends Test
{
	static function main()
	{
		var test:LightMapTest = new LightMapTest();
		Lib.current.addChild(test);
		test.startRender();
	}

	private var box:CubeNode;
	public function new()
	{
		super();
		box = new CubeNode(250, 250, 250);
		//box.setMaterialFlag(Material.GOURAUD_SHADE, false);
		box.setMaterialTexture(new LoadingTexture("media/brick.jpg"), 1);
		box.setMaterialTexture(new LoadingTexture("media/smiley.gif"), 2);
		manager.addChild(box);
		box.setRotationXYZ(45, 45, 45);
	}

	override private function _onEnterFrame(?e:Event=null):Void
	{
		super._onEnterFrame();

		box.rotationY += 1;
	}

}