package pixel3d.animator;
import flash.geom.Vector3D;
import pixel3d.scene.SceneNode;
class AnimatorRotation implements IAnimator
{
	public var startTime : Int;
	public var rotation : Vector3D;
	
	public function new(now : Int, rotation : Vector3D)
	{
		this.startTime = now;
		this.rotation = rotation;
	}
	
	public function animateNode(node : SceneNode, timeMs : Int) : Void
	{
		if (node == null) return;
		
		var diffTime : Int = timeMs - startTime;
		if(diffTime != 0)
		{
			var newRotation : Vector3D = node.getRotation();
			var r:Vector3D = rotation.clone();
			r.scaleBy(diffTime * 0.1);
			newRotation.incrementBy(r);
			node.setRotation(newRotation);
			startTime = timeMs;
		}
	}
	
	public function hasFinished() : Bool
	{
		return false;
	}
}
