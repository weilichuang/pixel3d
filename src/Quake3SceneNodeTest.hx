package ;
import flash.events.Event;
import flash.geom.Vector3D;
import flash.Lib;
import flash.text.TextField;
import pixel3d.events.MeshEvent;
import pixel3d.events.MeshProgressEvent;
import pixel3d.loader.bsp.BSPMeshLoader;
import pixel3d.material.ITexture;
import pixel3d.material.Material;
import pixel3d.mesh.Q3LevelMesh;
import pixel3d.scene.Quake3SceneNode;


class Quake3SceneNodeTest extends Test
{
	static function main()
	{
	   var test:Quake3SceneNodeTest = new Quake3SceneNodeTest();
	   Lib.current.addChild(test);
	   test.startRender();
	}
	
	private var texture:ITexture;
    private var q3loader:BSPMeshLoader;
	private var textField:TextField;
	public function new()
	{
		super();

		textField = new TextField();
		textField.textColor = 0x0;
		this.addChild(textField);

		q3loader = new BSPMeshLoader("bsp/demo/",3,false,4);
		q3loader.addEventListener(MeshEvent.COMPLETE, __load3ds);
		q3loader.addEventListener(MeshProgressEvent.PROGRESS, __progress);
		q3loader.load("bsp/demo/maps/q3tourney2.bsp");
	}

	private function __progress(e:MeshProgressEvent):Void
	{
		textField.text = e.getInfo();
		textField.x =(Lib.current.width - textField.width) / 2;
		textField.y =(Lib.current.height - textField.height) / 2;
	}

	private function __load3ds(e:MeshEvent):Void 
	{
		this.removeChild(textField);
		var q3LevelMesh:Q3LevelMesh = Lib.as(e.getMesh(), Q3LevelMesh);
		q3LevelMesh.setMaterialFlag(Material.GOURAUD_SHADE, true);
		q3loader.removeEventListener(Event.COMPLETE, __load3ds);
		q3loader.removeEventListener(MeshProgressEvent.PROGRESS, __progress);
		q3loader = null;
		
		var pos:Vector3D = q3LevelMesh.getRandomPlayerPosition();

		camera.setPosition(pos.add(new Vector3D(0, 60, 0)));//test
		camera.setTarget(pos.subtract(new Vector3D(0, -60, -100)));
		camera.updateAbsolutePosition();
		
		var node:Quake3SceneNode = new Quake3SceneNode(q3LevelMesh);
		manager.addChild(node);
	}
}