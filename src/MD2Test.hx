package;
import flash.events.Event;
import flash.geom.Vector3D;
import flash.Lib;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import pixel3d.loader.MD2MeshLoader;
import pixel3d.material.ITexture;
import pixel3d.material.LoadingTexture;
import pixel3d.material.Material;
import pixel3d.mesh.IAnimatedMesh;
import pixel3d.scene.AnimatedMeshSceneNode;
import pixel3d.scene.LightSceneNode;
import pixel3d.scene.PlaneSceneNode;

class MD2Test extends Test
{
	static function main()
	{
	   var test:MD2Test = new MD2Test();
	   Lib.current.addChild(test);
	   test.startRender();
	}
	
	private var light:LightSceneNode;

	private var texture:ITexture;
	
	private var t:Int;
    
	public function new()
	{
		super();
		
		light = new LightSceneNode(0xff0000, 1500., 0);
		light.light.radius = 1500;
		light.setPosition(new Vector3D(0., 500., 300.));
		light.light.direction = new Vector3D( -1, 0, 1);
		manager.addChild(light);
		
		camera.y = 200;
		
		texture = new LoadingTexture("media/ratamahatta.png");

		t = Lib.getTimer();

		loader = new URLLoader();
		loader.dataFormat = URLLoaderDataFormat.BINARY;
		loader.addEventListener(Event.COMPLETE, __loadmd2);
		loader.load(new URLRequest("media/ratamahatta.md2"));
	}
	
	private var loader:URLLoader;
	private function __loadmd2(e:Event):Void 
	{
		var data:ByteArray = Lib.as(loader.data, ByteArray);
		var maxloader:MD2MeshLoader = new MD2MeshLoader();
		var mesh:IAnimatedMesh = maxloader.createAnimatedMesh(data);
		data.clear();
		data = null;
		maxloader = null;
        
		for( i in 0...2)
		{
			for(j in 0...2)
			{
				var node2:AnimatedMeshSceneNode = new AnimatedMeshSceneNode(mesh, false);
				//node2.debugColor = Std.int(Math.random() * 0xFFFFFF);
				//node2.debugAlpha = Math.random();
				node2.setAnimationSpeed(35 + Std.int(Math.random() * 30));
				var scale:Float = 8;
				node2.setScale(new Vector3D(scale, scale, scale));
				
				node2.setMaterialFlag(Material.GOURAUD_SHADE,true);
				node2.setMaterialFlag(Material.LIGHT, true);

				if(i == 0 && j == 0)
				{
					node2.setMaterialFlag(Material.TRANSPARTENT, true);
					node2.setMaterialAlpha(0.7);
				}
				else
				{
					node2.setMaterialTexture(texture);
				}

				node2.updateMaterialTypes();
				node2.x = i * 250;
				node2.z = j * 250;

				manager.addChild(node2);
			}
		}
		
		var node3:PlaneSceneNode = new PlaneSceneNode(800, 800, 3, 3);
		node3.setMaterialEmissiveColor(0x770000);
		node3.setMaterialTexture(texture);
		node3.rotationX = -90;
		node3.y = -200;
		manager.addChild(node3);
	}

	override private function _onEnterFrame(?e:Event=null):Void
	{
		light.rotationY -= 1;
		if(Lib.getTimer()  -  t>  4000)
		{
			t=Lib.getTimer();
			light.light.diffuseColor.color = Std.int(Math.random() * 0xffffff);
		}
		
		super._onEnterFrame();
	}
}