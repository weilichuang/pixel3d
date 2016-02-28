package nochump.util.zip;
import flash.events.Event;
import flash.utils.ByteArray;
import nochump.util.zip.ZipEntry;
class ZipEvent extends Event
{
	// Event constants
	public static inline var ENTRY_PARSED : String = "entryParsed";
	public var entry : ByteArray;
	public function new(type : String, ?bubbles : Bool = false, ?cancelable : Bool = false, ?entry : ByteArray = null)
	{
		super(type, bubbles, cancelable);
		this.entry = entry;
	}
	public override function clone() : Event
	{
		return new ZipEvent(type);
	}
}
