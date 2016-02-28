package pixel3d.events;
import flash.events.Event;
import pixel3d.mesh.IMesh;

class MeshEvent extends Event
{
	public static inline var COMPLETE:String = "complete";
	
	private var mesh:IMesh;
	public function new(type : String,mesh:IMesh) 
	{
		super(type );
		this.mesh = mesh;
	}
	
	public function getMesh():IMesh
	{
		return this.mesh;
	}
	
	override public function clone():Event
	{
		return new MeshEvent(type, mesh);
	}
	
}