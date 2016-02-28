package pixel3d.animator;
import flash.geom.Vector3D;
import pixel3d.math.MathUtil;
import pixel3d.scene.SceneNode;
class AnimatorFlyCircle implements IAnimator
{
	public var center : Vector3D;
	public var direction : Vector3D;
	public var radius : Float;
	public var speed : Float;
	public var time : Int;
	private var vecV : Vector3D;
	private var vecU : Vector3D;
	public function new(time : Int, center : Vector3D, radius : Float, speed : Float, direction : Vector3D)
	{
		this.time = time;
		this.center = center;
		this.radius = radius;
		this.speed = speed * MathUtil.DEGTORAD;
		this.direction = direction;
		init();
	}
	private function init() : Void
	{
		direction.normalize();
		if(direction.y != 0)
		{
			vecV = new Vector3D(1, 0, 0).crossProduct(direction);
			vecV.normalize();
		} else
		{
			vecV = new Vector3D(0, 1, 0).crossProduct(direction);
			vecV.normalize();
		}
		vecU = vecV.crossProduct(direction);
		vecU.normalize();
	}
	public function animateNode(node : SceneNode, timeMs : Int) : Void
	{
		if(node == null) return;
		var t : Float =(timeMs - time) * 0.01 * speed;
		var cos : Float = Math.cos(t);
		var sin : Float = Math.sin(t);
		node.x = center.x + radius *(cos * vecU.x + sin * vecV.x);
		node.y = center.y + radius *(cos * vecU.y + sin * vecV.y);
		node.z = center.z + radius *(cos * vecU.z + sin * vecV.z);
	}
	public function hasFinished() : Bool
	{
		return false;
	}
}
