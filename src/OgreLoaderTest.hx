package ;
import flash.events.Event;
import flash.Lib;
import pixel3d.events.MeshEvent;
import pixel3d.loader.OgreMeshLoader;
import pixel3d.material.ITexture;
import pixel3d.material.LoadingTexture;
import pixel3d.mesh.SkinnedMesh;
import pixel3d.scene.MeshNode;
import pixel3d.scene.SceneNode;
import pixel3d.scene.SkinnedMeshNode;

class OgreLoaderTest extends Test
{
	static function main()
	{
		var test:OgreLoaderTest = new OgreLoaderTest();
		Lib.current.addChild(test);
		test.startRender();
	}

	private var node:SceneNode;

	private var texture:ITexture;

	private var loader:OgreMeshLoader;

	public function new()
	{
		super();

		camera.z = 500;

		texture = new LoadingTexture("ogre/textures/penguin.jpg");

		loader = new OgreMeshLoader();
		loader.addEventListener(MeshEvent.COMPLETE, __load3ds);
		loader.load("ogre/models/penguin.mesh",false,"","ogre/models/penguin.skeleton");
	}

	private function __load3ds(e:MeshEvent):Void
	{
		var mesh:SkinnedMesh = Lib.as(e.getMesh(), SkinnedMesh);

		if (mesh != null)
		{
			node = new SkinnedMeshNode(mesh, true);
			Lib.as(node, SkinnedMeshNode).gotoAndPlay(0);
		}
		else
		{
			node = new MeshNode(e.getMesh(), true);

		}

		//node.setMaterialFlag(Material.WIREFRAME, true);
		node.setMaterialTexture(texture);
		node.setScaleXYZ(10, 10, 10);
		node.x = 50;
		manager.addChild(node);
	}

	override private function _onEnterFrame(?e:Event=null):Void
	{
		if (node!=null)
		{
			node.rotationY += 2;
		}
		super._onEnterFrame();
	}
}