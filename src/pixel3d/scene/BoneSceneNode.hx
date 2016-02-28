package pixel3d.scene;
import pixel3d.math.AABBox;

class BoneSceneNode extends SceneNode
{
    private var box:AABBox;
	
	private var skinningSpace:Int;
	private var animationMode:Int;
	
	private var boneIndex:Int;
	
	public var positionHint:Int;
	public var scaleHint:Int;
	public var rotationHint:Int;
	
	public function new(boneIndex:Int,boneName:String) 
	{
		super();
		this.name = boneName;
		this.boneIndex = boneIndex;
	}
	
	public function getBoneIndex():Int
	{
		return boneIndex;
	}
	
	public function setAnimationMode(mode:Int):Bool
	{
		animationMode = mode;
		return true;
	}
	
	override public function getBoundingBox():AABBox
	{
		return box;
	}
	
	public function getAnimationMode():Int
	{
		return animationMode;
	}
	
	public function setSkinningSpace(space:Int):Void
	{
		skinningSpace = space;
	}
	
	public function getSkinningSpace():Int
	{
		return skinningSpace;
	}
	
	private function helper_updateAbsolutePositionOfAllChildren(node:SceneNode):Void
	{
		node.updateAbsolutePosition();
		
		var len:Int = this.numChildren;
		for (i in 0...len)
		{
			helper_updateAbsolutePositionOfAllChildren(_children[i]);
		}
	}
	
	public function updateAbsolutePositionOfAllChildren():Void
	{
		helper_updateAbsolutePositionOfAllChildren(this);
	}
	
}

class BoneSkinningSpace
{
	public static inline var LOCAL:Int = 0;
	public static inline var GLOBAL:Int = 1;
	public static inline var COUNT:Int = 2;
}

class BoneAnimationMode
{
	public static inline var AUTOMATIC:Int = 0;
	public static inline var ANIMATED:Int = 1;
	public static inline var UNANIMATED:Int = 2;
	public static inline var COUNT:Int = 3;
}