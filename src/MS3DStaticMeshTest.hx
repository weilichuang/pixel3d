package ;
import flash.events.Event;
import flash.Lib;
import pixel3d.events.MeshEvent;
import pixel3d.loader.MeshLoader;
import pixel3d.loader.MS3DMeshLoader;
import pixel3d.material.ITexture;
import pixel3d.material.LoadingTexture;
import pixel3d.material.Material;
import pixel3d.mesh.IMesh;
import pixel3d.scene.MeshSceneNode;

class MS3DStaticMeshTest extends Test
{
	static function main()
	{
	   var test:MS3DStaticMeshTest = new MS3DStaticMeshTest();
	   Lib.current.addChild(test);
	   test.startRender();
	}

	private var node:MeshSceneNode;
	
	private var texture:ITexture;

	private var maxloader:MS3DMeshLoader;

	public function new()
	{
		super();

		texture = new LoadingTexture("media/fskin.jpg");

		camera.z = 200;
		camera.y = 200;

		maxloader = new MS3DMeshLoader(MeshLoader.STATIC_MESH);
		maxloader.addEventListener(MeshEvent.COMPLETE, __load3ds);
		maxloader.load("media/f360.ms3d");
	}
	
	
	private function __load3ds(e:MeshEvent):Void 
	{
		var mesh:IMesh = e.getMesh();
		
		node = new MeshSceneNode(mesh,false);
		node.setScaleXYZ(2,2,2);
		node.setMaterialFlag(Material.GOURAUD_SHADE, true);
		//node.setMaterialFlag(Material.TRANSPARTENT, true);
		//node.setMaterialAlpha(0.7);
		node.setMaterialTexture(texture);

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