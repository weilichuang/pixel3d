package;
import flash.events.Event;
import flash.geom.Vector3D;
import flash.Lib;
import pixel3d.events.MeshEvent;
import pixel3d.light.Light;
import pixel3d.loader.Max3DSMeshLoader;
import pixel3d.material.ITexture;
import pixel3d.material.LoadingTexture;
import pixel3d.material.Material;
import pixel3d.mesh.MeshBuffer;
import pixel3d.scene.LightSceneNode;
import pixel3d.scene.MeshSceneNode;
import pixel3d.mesh.IMesh;
class Max3DSTest extends Test
{
	static function main()
	{
	   var test:Max3DSTest = new Max3DSTest();
	   Lib.current.addChild(test);
	   test.startRender();
	}
	
	private var light:LightSceneNode;

	private var texture:ITexture;
	
	private var t:Int;
    
	private var loader:Max3DSMeshLoader;
	
	public function new()
	{
		super();
		
		driver.setPerspectiveCorrectDistance(2000);

		light = new LightSceneNode(0xff0000, 1500., Light.SPOT);
		light.light.radius = 1500;
		light.setPosition(new Vector3D(0., 300., 200.));
		manager.addChild(light);
		
		camera.y = 300;
		camera.z = 1000;
		camera.lookAt(new Vector3D());

		t = Lib.getTimer();

		loader = new Max3DSMeshLoader();
		loader.addEventListener(MeshEvent.COMPLETE, __loadMax3DS);
		loader.load("media/build.3DS");
	}
	
	private var node2:MeshSceneNode;
	private function __loadMax3DS(e:MeshEvent):Void 
	{
		var mesh:pixel3d.mesh.IMesh = e.getMesh();
		var len:Int = mesh.getMeshBufferCount();
		//for (i in 0...len)
		//{
			//var buffer:MeshBuffer = mesh.getMeshBuffer(i);
			//var mat:Material = buffer.getMaterial();
			//if (mat.extra.texturePath != null)
			//{
				//mat.setTexture(new LoadingTexture("room/" + mat.extra.texturePath));
			//}
		//}
		//var mat:Material = new Material();
		//mat.setTexture();
		node2 = new MeshSceneNode(e.getMesh(), false);
		node2.setMaterialFlag(Material.GOURAUD_SHADE, true);
		node2.setMaterialFlag(Material.LIGHT, false);
		node2.setMaterialTexture(new LoadingTexture("media/build.jpg"));
		manager.addChild(node2);
	}

	override private function _onEnterFrame(?e:Event=null):Void
	{
		if (node2 != null)
		{
			node2.rotationY += 1;
			//node2.rotationX += 0.5;
		}
		light.rotationY -= 1;
		if(Lib.getTimer()  -  t >  4000)
		{
			t = Lib.getTimer();
			light.light.diffuseColor.color = Std.int(Math.random() * 0xffffff);
		}
		
		super._onEnterFrame();
	}
}