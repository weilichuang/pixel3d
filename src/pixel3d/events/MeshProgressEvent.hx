package pixel3d.events;
import flash.events.Event;
import flash.events.ProgressEvent;

class MeshProgressEvent extends Event
{
	public static var PROGRESS:String = ProgressEvent.PROGRESS;
    private var info:String;
	public function new(type:String,info:String) 
	{
		super(type);
		this.info = info;
	}
	
	public function getInfo():String
	{
		return this.info;
	}
	
	override public function clone():Event
	{
		return new MeshProgressEvent(type, info);
	}
	
}