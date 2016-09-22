package pixel3d.animator;
import haxe.Log;
import flash.geom.Vector3D;
import pixel3d.scene.SceneNode;
class AnimatorFlyStraight implements IAnimator
{
	public var start : Vector3D;
	public var end : Vector3D;
	public var wayLength : Float;
	public var timeFactor : Float;
	public var startTime : Int;
	public var timeForWay : Int;
	public var loop : Bool;
	public var vector : Vector3D;
	public function new(now : Int, start : Vector3D, end : Vector3D, timeForWay : Int, loop : Bool = false)
	{
		this.startTime = now;
		this.start = start;
		this.end = end;
		this.timeForWay = timeForWay;
		this.loop = loop;
		vector = end.subtract(start);
		vector.normalize();
		wayLength = Vector3D.distance(start, end);
		timeFactor = wayLength / timeForWay;
	}
	public function animateNode(node : SceneNode, timeMs : Int) : Void
	{
		if (node == null) return;
		var t : Int =(timeMs - startTime);
		//var pos:Vector3D = start.clone();
		//if(!loop && t>= timeForWay)
		//{
		//	pos = end.clone();
		//}else
		//{
		//	pos.incrementBy(vector.scale((t % timeForWay) * timeFactor));
		//}
		//node.setPosition(pos);
		var px : Float = start.x;
		var py : Float = start.y;
		var pz : Float = start.z;
		if ( ! loop && t>= timeForWay)
		{
			px = end.x;
			py = end.y;
			pz = end.z;
		}
		else
		{
			var sl : Float =(t % timeForWay) * timeFactor;
			px += vector.x * sl;
			py += vector.y * sl;
			pz += vector.z * sl;
		}
		node.x = px;
		node.y = py;
		node.z = pz;
	}
	public function hasFinished() : Bool
	{
		return false;
	}
}
