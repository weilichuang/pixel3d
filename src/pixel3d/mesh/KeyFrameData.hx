package pixel3d.mesh;
class KeyFrameData
{
	public var name : String;
	public var begin : Int;
	public var end : Int;
	public var fps : Int;
	public function new(begin : Int = 0, end : Int = 1, fps : Int = 1)
	{
		this.begin = begin;
		this.end = end;
		this.fps = fps;
		name = "";
	}
	public function copy(other : KeyFrameData) : Void
	{
		begin = other.begin;
		end = other.end;
		fps = other.fps;
		name = other.name;
	}
	public function clone() : KeyFrameData
	{
		var data : KeyFrameData = new KeyFrameData();
		data.copy(this);
		return data;
	}
}
