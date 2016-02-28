package pixel3d.animator;
import flash.events.KeyboardEvent;
import flash.Lib;
import flash.ui.Keyboard;
import flash.Vector;
import pixel3d.math.MathUtil;
import pixel3d.math.Vector3DUtil;
import pixel3d.math.Matrix4;
import pixel3d.math.Vector2f;
import flash.geom.Vector3D;
import pixel3d.scene.CameraSceneNode;
import pixel3d.scene.ISceneManager;
import pixel3d.scene.SceneManager;
import pixel3d.scene.SceneNode;
import pixel3d.scene.SceneNodeType;
import pixel3d.utils.CursorControl;
import pixel3d.utils.Logger;

class AnimatorCameraFPS implements IAnimator
{
    private var maxVerticalAngle:Float;
	private var moveSpeed:Float;
	private var rotateSpeed:Float;
	private var jumpSpeed:Float;
	private var mouseYDirection:Float;// -1.0f for inverted mouse, defaults to 1.0f
  
	private var lastAnimationTime:Int;

	private var firstUpdate:Bool;
	
	private var noVerticalMovement:Bool;
	
	private var cursorControl:CursorControl;

	private var tmpMatrix:Matrix4;
	private var strafevect:Vector3D;
	private var movedir:Vector3D;
	private var target:Vector3D;
	private var centerPos:Vector2f;
	
	public function new(cursorControl:CursorControl,
	                    rotateSpeed:Float = 2., 
						moveSpeed:Float = 2., 
						jumpSpeed:Float = 0.,
	                    noVerticalMovement:Bool = true,
						invertY:Bool=false) 
	{
		
		this.cursorControl = cursorControl;
		this.rotateSpeed = rotateSpeed;
		this.moveSpeed = moveSpeed;
		this.jumpSpeed = jumpSpeed;
		this.noVerticalMovement = noVerticalMovement;
		this.mouseYDirection = invertY ? -1.0 : 1.0;

		maxVerticalAngle = 88.0;
		lastAnimationTime = 0;
		firstUpdate = true;
		
		tmpMatrix = new Matrix4();
		strafevect = new Vector3D();
		movedir = new Vector3D();
		centerPos = new Vector2f(0.5, 0.5);
	}
	
	public function animateNode(node:SceneNode, timeMs:Int):Void 
	{
		if (node == null || node.getType() != SceneNodeType.CAMERA) 
		{
			return;
		}
		
		var camera:CameraSceneNode = Lib.as(node, CameraSceneNode);
		
		var manager:ISceneManager = camera.sceneManager;
		
		if(manager == null || manager.getActiveCamera() != camera) return;
		
		if(firstUpdate)
		{
			camera.updateAbsolutePosition();
			
			if (cursorControl != null && camera != null)
			{
				cursorControl.setPosition(0.5, 0.5);
			}

			lastAnimationTime = timeMs;
			
			firstUpdate = false;
		}
		
		//get time
		var timeDiff:Float = (timeMs - lastAnimationTime);
		
		lastAnimationTime = timeMs;
		
		//update position
		var pos:Vector3D = camera.getPosition();
		
		//update rotation
		var target:Vector3D = camera.getTarget().subtract(camera.getAbsolutePosition());
		var relativeRotation:Vector3D = Vector3DUtil.getHorizontalAngle(target);
		
		if(cursorControl.isMouseDown())
		{
			var cursorPos:Vector2f = cursorControl.getRelativePosition();
			if(cursorPos.x != centerPos.x || cursorPos.y != centerPos.y)
			{
				relativeRotation.y -= (0.5 - cursorPos.x) * rotateSpeed;
				relativeRotation.x -= (0.5 - cursorPos.y) * rotateSpeed * mouseYDirection;

				if (relativeRotation.x > maxVerticalAngle * 2 && relativeRotation.x < 360 - maxVerticalAngle)
				{
					relativeRotation.x = 360 - maxVerticalAngle;	
				}
				else if (relativeRotation.x > maxVerticalAngle && relativeRotation.x < 360 - maxVerticalAngle)
				{
					relativeRotation.x = maxVerticalAngle;
				}
			}
		}
		
		//set target
		target.x = 0;
		target.y = 0;
		target.z = MathUtil.max(1.0, pos.length);
        movedir = target.clone();
		
		tmpMatrix.identity();
		tmpMatrix.setRotation(new Vector3D(relativeRotation.x, relativeRotation.y, 0),true);
		tmpMatrix.transformVector(target);
		
		if(noVerticalMovement)
		{
			tmpMatrix.setRotation(new Vector3D(0, relativeRotation.y, 0),true);
			tmpMatrix.transformVector(movedir);
		}
		else
		{
			movedir = target.clone();
		}
		
		movedir.normalize();
		
		var speed:Float = timeDiff * moveSpeed;
		if(cursorControl.isKeyDown(Keyboard.UP) || cursorControl.isKeyDown(87)) //up and w
		{
			pos.x += movedir.x * speed;
			pos.y += movedir.y * speed;
			pos.z += movedir.z * speed;
		}
		if(cursorControl.isKeyDown(Keyboard.DOWN) || cursorControl.isKeyDown(83))//down and s
		{
			pos.x -= movedir.x * speed;
			pos.y -= movedir.y * speed;
			pos.z -= movedir.z * speed;
		}
		
		// strafing
		strafevect = target.clone();
		strafevect = strafevect.crossProduct(camera.getUpVector());
		if (noVerticalMovement) 
		{
			strafevect.y = 0.0;
		}
		strafevect.normalize();
		
		if(cursorControl.isKeyDown(Keyboard.LEFT) || cursorControl.isKeyDown(65))//left and a
		{
			pos.x += strafevect.x * speed;
			pos.y += strafevect.y * speed;
			pos.z += strafevect.z * speed;
		}
		
		if(cursorControl.isKeyDown(Keyboard.RIGHT) || cursorControl.isKeyDown(68))//right and d
		{
			pos.x -= strafevect.x * speed;
			pos.y -= strafevect.y * speed;
			pos.z -= strafevect.z * speed;
		}
		
		//TODO 添加jump

		//write translation
		camera.setPosition(pos);
		
		//write right target
		target.incrementBy(pos);
		camera.setTarget(target);
	}
	
	public function getMoveSpeed():Float
	{
		return moveSpeed;
	}
	
	public function getRotateSpeed():Float
	{
		return rotateSpeed;
	}
	
	public function setMoveSpeed(speed:Float):Void 
	{
		moveSpeed = speed;
	}
	
	public function setRotateSpeed(speed:Float):Void 
	{
		rotateSpeed = speed;
	}
	
	public function setVerticalMovement(allow:Bool):Void 
	{
		noVerticalMovement = !allow;
	}
	
	public function setInvertMouse(invert:Bool):Void 
	{
		if(invert)
		    mouseYDirection = -1.0;
		else
		    mouseYDirection = 1.0;
	}
	
	public function hasFinished() : Bool
	{
		return false;
	}
}