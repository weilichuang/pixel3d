package pixel3d.scene;
import pixel3d.light.Light;
import pixel3d.math.AABBox;
import pixel3d.math.Matrix4;
import pixel3d.renderer.IVideoDriver;
import flash.geom.Vector3D;
class LightNode extends SceneNode
{
	public var light : Light ;
	public function new(color : UInt = 0xFFFFFF, radius : Float = 200., type : Int = 0)
	{
		super();
		light = new Light();
		light.diffuseColor.color = color;
		light.radius = radius;
		light.type = type;
		autoCulling = false;
	}

	public inline function setDiffuseColor(color : UInt) : Void
	{
		light.diffuseColor.color = color;
	}

	public inline function setSpecularColor(color : UInt) : Void
	{
		light.specularColor.color = color;
	}

	override public function onRegisterSceneNode() : Void
	{
		if (visible)
		{
			if (light.type == Light.DIRECTIONAL || light.type == Light.SPOT)
			{
				light.direction.x = 0.;
				light.direction.y = 0.;
				light.direction.z = 1.;
				_absoluteTransformation.rotateVector(light.direction);
				light.direction.normalize();
			}
			if (light.type == Light.POINT || light.type == Light.SPOT)
			{
				light.position.x = _absoluteTransformation.m41;
				light.position.y = _absoluteTransformation.m42;
				light.position.z = _absoluteTransformation.m43;
			}
			sceneManager.registerNodeForRendering(this, SceneNodeType.LIGHT);
			super.onRegisterSceneNode();
		}
	}

	override public function render() : Void
	{
		var driver : IVideoDriver = sceneManager.getVideoDriver();
		driver.addLight(light);
		//if(debug)
		//{
		//driver.setTransformWorld(_absoluteTransformation);
		//driver.draw3DBox(getBoundingBox(), debugColor, debugAlpha, debugWireframe);
		//}
	}
}