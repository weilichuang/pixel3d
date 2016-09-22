package pixel3d.light;
import flash.geom.Vector3D;
import pixel3d.math.Color;
class Light
{
	public static inline var DIRECTIONAL : Int = 0;
	public static inline var POINT : Int = 1;
	public static inline var SPOT : Int = 2;

	public var diffuseColor : Color;//反射光
	public var specularColor : Color;//高光
	public var position : Vector3D;
	public var direction : Vector3D;
	public var kc : Float;//constant衰减因子常量
	public var kl : Float;//linear衰减因子线性
	public var kq : Float;//quadratic衰减因子二次衰减因子
	public var powerFactor : Int;
	public var type : Int;//类型
	public var radius : Float;
	public var castShadows : Bool ;
	public function new()
	{
		diffuseColor = new Color(0, 0, 0);
		specularColor = new Color(0, 0, 0);
		position = new Vector3D();
		direction = new Vector3D(0., 0., 1.);
		kc = 0;
		kl = 0.002;
		kq = 0;
		powerFactor = 2;
		type = 0;
		radius = 1000;
		castShadows = false;
	}
	public inline function copy(l : Light) : Void
	{
		diffuseColor.copy(l.diffuseColor);
		specularColor.copy(l.specularColor);
		position = l.position.clone();
		direction = l.direction.clone();
		kc = l.kc;
		kl = l.kl;
		kq = l.kq;
		powerFactor = l.powerFactor;
		type = l.type;
		castShadows = l.castShadows;
	}
	public inline function clone() : Light
	{
		var l : Light = new Light();
		l.diffuseColor.copy(diffuseColor);
		l.specularColor.copy(specularColor);
		l.position = position.clone();
		l.direction = direction.clone();
		l.kc = kc;
		l.kl = kl;
		l.kq = kq;
		l.radius = radius;
		l.powerFactor = powerFactor;
		l.castShadows = castShadows;
		return l;
	}
}
