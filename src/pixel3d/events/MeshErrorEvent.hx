package pixel3d.events;
import flash.events.ErrorEvent;
import flash.events.Event;

class MeshErrorEvent extends Event
{
	public static inline var ERROR:String = "error";

	private var text:String;
	public function new(type:String,text:String)
	{
		super(type);
		this.text = text;
	}

	override public function clone():Event
	{
		return new MeshErrorEvent(this.type, this.text);
	}

	public function getText():String
	{
		return text;
	}
}