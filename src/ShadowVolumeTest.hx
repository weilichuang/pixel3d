package;

import flash.geom.Vector3D;
import flash.Lib;
import pixel3d.animator.AnimatorFlyCircle;
import pixel3d.light.Light;
import pixel3d.material.ITexture;
import pixel3d.material.LoadingTexture;
import pixel3d.material.Material;
import pixel3d.scene.CubeSceneNode;
import pixel3d.scene.LightSceneNode;
import pixel3d.scene.PlaneSceneNode;

//不太正确，有时会报错
class ShadowVolumeTest extends Test
{
	static function main()
	{
	   var test:ShadowVolumeTest = new ShadowVolumeTest();
	   Lib.current.addChild(test);
	   test.startRender();
	}
	
	private var light:LightSceneNode;
	private var texture:ITexture;

	public function new()
	{
		super();
		
		//driver.setShadowPercent(0.5);
		
		light = new LightSceneNode(0xffff00, 1000., Light.POINT);
		light.light.radius = 500;
		light.light.castShadows = true;
		light.setPosition(new Vector3D(100.,300., 150.));
		manager.addChild(light);
		
		texture = new LoadingTexture("media/yellow.jpg");

		initSceneNode();
	}
	
	private function initSceneNode():Void 
	{

		var box1:CubeSceneNode = new CubeSceneNode(100, 200, 100);
		box1.setMaterialFlag(Material.LIGHT, true);
		box1.setMaterialFlag(Material.GOURAUD_SHADE, true);
		box1.setMaterialTexture(texture);
		box1.y = 100;
		box1.addShadowVolume(null, false, 20);
		manager.addChild(box1);

		var box2:CubeSceneNode = new CubeSceneNode(100, 200, 100);
		box2.setMaterialTexture(texture);
		box2.setMaterialFlag(Material.LIGHT, true);
		box2.x = 200;
		box2.y = 100;
		box2.setMaterialFlag(Material.GOURAUD_SHADE, true);
		manager.addChild(box2);
		
		
		var node3:PlaneSceneNode = new PlaneSceneNode(600, 600, 1, 1);
		node3.setMaterialEmissiveColor(0x770000);
		node3.rotationX = -90;
		manager.addChild(node3);
		
		var node4:PlaneSceneNode = new PlaneSceneNode(600, 400, 1, 1);
		node4.setMaterialEmissiveColor(0x007700);
		node4.setMaterialFlag(Material.BACKFACE, true);
		node4.setMaterialFlag(Material.LIGHT, false);
		node4.setMaterialAlpha(0.9);
		node4.z = -300;
		node4.y = 200;
		manager.addChild(node4);
		
		var node5:PlaneSceneNode = new PlaneSceneNode(600, 400, 1, 1);
		node5.setMaterialEmissiveColor(0x000077);
		node5.setMaterialFlag(Material.BACKFACE, true);
		node5.setMaterialFlag(Material.LIGHT, false);
		node5.rotationY = -90;
		node5.setMaterialAlpha(0.9);
		node5.x = 300;
		node5.y = 200;
		manager.addChild(node5);
		
		var node6:PlaneSceneNode = new PlaneSceneNode(600, 400, 1, 1);
		node6.setMaterialEmissiveColor(0x004477);
		node6.setMaterialFlag(Material.BACKFACE, true);
		node6.setMaterialFlag(Material.LIGHT, false);
		node6.rotationY = -270;
		node6.x = -300;
		node6.y = 200;
		manager.addChild(node6);
		
		var node7:PlaneSceneNode = new PlaneSceneNode(600, 400, 1, 1);
		node7.setMaterialEmissiveColor(0x777700);
		node7.setMaterialFlag(Material.BACKFACE, true);
		node7.setMaterialFlag(Material.LIGHT, false);
		node7.rotationY = 180;
		node7.z = 300;
		node7.y = 200;
		manager.addChild(node7);

		light.addAnimator(new AnimatorFlyCircle(Lib.getTimer(), new Vector3D(0, 450, 0), 450, 5, new Vector3D(0.2, 1, 0.4)));
		var cube:CubeSceneNode = new CubeSceneNode(20, 20, 20);
		cube.setMaterialColor(0xff0000);
		light.addChild(cube);
	}
}