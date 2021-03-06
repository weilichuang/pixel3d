﻿package example ;
import flash.geom.Vector3D;
import flash.Lib;
import pixel3d.animator.AnimatorFlyCircle;
import pixel3d.events.MeshEvent;
import pixel3d.loader.MS3DMeshLoader;
import pixel3d.material.ITexture;
import pixel3d.material.LoadingTexture;
import pixel3d.material.Material;
import pixel3d.mesh.SkinnedMesh;
import pixel3d.scene.LightNode;
import pixel3d.scene.PlaneNode;
import pixel3d.scene.SkinnedMeshNode;
class MS3DFileLoaderTest extends example.Test
{
	static function main()
	{
		var test:MS3DFileLoaderTest = new MS3DFileLoaderTest();
		Lib.current.addChild(test);
		test.startRender();
	}

	private var light:LightNode;

	private var node:SkinnedMeshNode;

	private var texture:ITexture;

	private var maxloader:MS3DMeshLoader;

	public function new()
	{
		super();

		texture = new LoadingTexture("media/nskinbr.jpg");

		light = new LightNode(0x770000, 1000., 1);
		light.setPosition(new Vector3D(0., 0., 0.));
		light.addAnimator(new AnimatorFlyCircle(Lib.getTimer(),new Vector3D(0,100,0), 10000, 0.002, new Vector3D(0.3, 1, 0.2)));

		manager.addChild(light);

		var node3:PlaneNode = new PlaneNode(400, 400, 1, 1);
		node3.setMaterialTexture(texture);
		node3.rotationX = -90;
		node3.y = -5;

		manager.addChild(node3);

		camera.z = 300;
		camera.y = 200;

		maxloader = new MS3DMeshLoader();
		maxloader.addEventListener(MeshEvent.COMPLETE, __load3ds);
		maxloader.load("media/ninja.ms3d");
	}

	private function __load3ds(e:MeshEvent):Void
	{
		var mesh:SkinnedMesh = Lib.as(e.getMesh(), SkinnedMesh);
		mesh.updateNormalsWhenAnimating(true);

		node = new SkinnedMeshNode(mesh,false);
		node.setScaleXYZ(20,20,20);
		node.setAnimationSpeed(10);
		node.setMaterialFlag(Material.LIGHT, true);
		node.setMaterialFlag(Material.GOURAUD_SHADE, true);
		node.setMaterialAlpha(0.6);
		//node.setMaterialTexture(texture);
		//node.buttonMode = true;
		//node.mouseEnabled = true;
		//node.debug = true;
		node.x = -80;

		var node1:SkinnedMeshNode = new SkinnedMeshNode(mesh,false);
		node1.setScaleXYZ(20,20,20);
		node1.setAnimationSpeed(5);
		node1.setFrameLoop(0,300);
		node1.setMaterialTexture(texture);
		node1.x = 80;

		manager.addChild(node);
		manager.addChild(node1);
	}
}