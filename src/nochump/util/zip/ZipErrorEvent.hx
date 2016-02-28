package nochump.util.zip;
import flash.events.Event;
class ZipErrorEvent extends Event
{
	// Event constants
	public static inline var PARSE_ERROR : String = "entryParseError";
	private var err : Int;
	public function new(type : String, ?bubbles : Bool = false, ?cancelable : Bool = false, ?err : Int = 0)
	{
		super(type, bubbles, cancelable);
		this.err = err;
	}
	public override function clone() : Event
	{
		return new ZipErrorEvent(type);
	}
}
