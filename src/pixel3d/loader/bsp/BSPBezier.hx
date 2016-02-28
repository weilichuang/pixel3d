package pixel3d.loader.bsp;
import pixel3d.math.Vertex;
import pixel3d.mesh.MeshBuffer;
import flash.Vector;
class BSPBezier 
{
    public var meshBuffer:MeshBuffer;
	
	public var control:Vector<Vertex>;
	private var level:Int;
	private var column:Vector<Vector<Vertex>> ;
	
	public function new() 
	{
		control = new Vector<Vertex>(9,true);
		column = new Vector<Vector<Vertex>>(3, true);
		for(i in 0...3)
		{
			column[i] = new Vector<Vertex>();
		}
	}
	
	public function tesselate(level:Int):Void
	{
		//Calculate how many vertices across/down there are
		column[0].length = level + 1;
		column[1].length = level + 1;
		column[2].length = level + 1;
		
		var w:Float =(1.0 / level);
		
		//Tesselate along the columns
		for(j in 0...(level + 1))
		{
			var f:Float = w * j;
			
			column[0][j] = control[0].getQuadraticInterpolated(control[3], control[6], f);
			column[1][j] = control[1].getQuadraticInterpolated(control[4], control[7], f);
			column[2][j] = control[2].getQuadraticInterpolated(control[5], control[8], f);
		}
		
		
		var vertices:Vector<Vertex> = meshBuffer.getVertices();
		var idx:Int = vertices.length;
		for(j in 0...(level + 1))
		{
			for(k in 0...(level + 1))
			{
				var vertex:Vertex = column[0][j].getQuadraticInterpolated(column[1][j], column[2][j], w * k);
				vertices.push(vertex);
			}
		}
		
		var indices:Vector<Int> = meshBuffer.getIndices();
		//connect
		for(j in 0...level)
		{
			for(k in 0...level)
			{
				var inx:Int = idx +(k *(level + 1)) + j;
				
				indices.push(inx);
				indices.push(inx +(level + 1));
				indices.push(inx +(level + 1) + 1);
				
				indices.push(inx);
				indices.push(inx +(level + 1) + 1);
				indices.push(inx + 1);
			}
		}
	}
}