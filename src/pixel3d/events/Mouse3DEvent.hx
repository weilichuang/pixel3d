package pixel3d.events;
import flash.events.Event;
import flash.events.MouseEvent;
import pixel3d.scene.SceneNode;

class Mouse3DEvent extends MouseEvent
{
	public static var CLICK:String = MouseEvent.CLICK;
	public static var DOUBLE_CLICK:String = MouseEvent.DOUBLE_CLICK;
	public static var MOUSE_DOWN:String = MouseEvent.MOUSE_DOWN;
	public static var MOUSE_UP:String = MouseEvent.MOUSE_UP;
	public static var MOUSE_WHEEL:String = MouseEvent.MOUSE_WHEEL;
	public static var ROLL_OUT:String = MouseEvent.ROLL_OUT;
	public static var ROLL_OVER:String = MouseEvent.ROLL_OVER;

	public var node:SceneNode;

	public function new(type:String,node:SceneNode)
	{
		super(type, false, false);
		this.node = node;
	}

	override public function clone():Event
	{
		var event:Mouse3DEvent = new Mouse3DEvent(type,node);
		event.node = node;
		return event;
	}
}