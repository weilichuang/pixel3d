package pixel3d.renderer.shadowvolume;
import pixel3d.renderer.AbstractTriangleRenderer;

import flash.Vector;
import pixel3d.math.Vertex4D;
class ShadowVolumeWireframe extends AbstractTriangleRenderer
{
	public function new()
	{
		super();
	}
	
	override public function drawIndexedTriangleList(vertices : Vector<Vertex4D>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int) : Void
	{
		var color : UInt;
		var x0 : Int;
		var x1 : Int;
		var x2 : Int;
		var y0 : Int;
		var y1 : Int;
		var y2 : Int;

		if( ! material.transparenting)
		{
			var i : Int = 0;
			while(i <indexCount)
			{
				v1 = vertices[indexList[i]];
				v2 = vertices[indexList[i + 1]];
				v3 = vertices[indexList[i + 2]];
				i += 3;
				color =(0xFF000000 | Std.int(v1.r) <<16 | Std.int(v1.g) <<8 | Std.int(v1.b));
				bresenham(Std.int(v1.x) , Std.int(v1.y) , v1.z, Std.int(v2.x) , Std.int(v2.y) , v2.z, color);
				color =(0xFF000000 | Std.int(v2.r) <<16 | Std.int(v2.g) <<8 | Std.int(v2.b));
				bresenham(Std.int(v2.x) , Std.int(v2.y) , v2.z, Std.int(v3.x) , Std.int(v3.y) , v3.z, color);
				color =(0xFF000000 | Std.int(v3.r) <<16 | Std.int(v3.g) <<8 | Std.int(v3.b));
				bresenham(Std.int(v3.x) , Std.int(v3.y) , v3.z, Std.int(v1.x) , Std.int(v1.y) , v1.z, color);
			}
		} else
		{
			var i : Int = 0;
			while(i <indexCount)
			{
				v1 = vertices[indexList[i]];
				v2 = vertices[indexList[i + 1]];
				v3 = vertices[indexList[i + 2]];
				i += 3;
				bresenhamAlpha(Std.int(v1.x) , Std.int(v1.y) , v1.z, Std.int(v2.x) , Std.int(v2.y) , v2.z, Std.int(v1.r) , Std.int(v1.g) , Std.int(v1.b));
				bresenhamAlpha(Std.int(v2.x) , Std.int(v2.y) , v2.z, Std.int(v3.x) , Std.int(v3.y) , v3.z, Std.int(v2.r) , Std.int(v2.g) , Std.int(v2.b));
				bresenhamAlpha(Std.int(v3.x) , Std.int(v3.y) , v3.z, Std.int(v1.x) , Std.int(v1.y) , v1.z, Std.int(v3.r) , Std.int(v3.g) , Std.int(v3.b));
			}
		}
	}
	
	private inline function bresenham(x0 : Int, y0 : Int, z0 : Float, x1 : Int, y1 : Int, z1 : Float, value : UInt ) : Void
	{
		var pos : Int;
		var error : Int;
		var dx : Int = x1 - x0;
		var dy : Int = y1 - y0;
		var yi : Int = 1;
		var dz : Float = z1 - z0;
		var dzdy : Float;
		if(dx <dy )
		{
			x0 ^= x1;
			x1 ^= x0;
			x0 ^= x1;
			y0 ^= y1;
			y1 ^= y0;
			y0 ^= y1;
			var t : Float = z1;
			z1 = z0;
			z0 = t;
		}
		if(dx <0 )
		{
			dx = - dx;
			yi = - yi;
			dz = - dz;
		}
		if(dy <0 )
		{
			dy = - dy;
			yi = - yi;
			dz = - dz;
		}
		if(dy> dx )
		{
			error = -(dy>> 1 );
			dzdy = dz /(y0 - y1);
			for(y in y1...y0)
			{
				pos = x1 + y * width;
				target[pos] = value;
				buffer[pos] = z1;
				error += dx;
				if(error> 0 )
				{
					x1 += yi;
					z1 += dzdy;
					error -= dy;
				}
			}
		} 
		else
		{
			error = -(dx>> 1 );
			dzdy = dz /(x1 - x0);
			for(x in x0...x1)
			{
				pos = x + y0 * width;
				target[pos] = value;
				buffer[pos] = z1;
				error += dy;
				if(error> 0 )
				{
					y0 += yi;
					z0 += dzdy;
					error -= dx;
				}
			}
		}
	}

	private inline function bresenhamAlpha(x0 : Int, y0 : Int, z0 : Float, x1 : Int, y1 : Int, z1 : Float, r : Int, g : Int, b : Int ) : Void
	{
		var bgColor : UInt;
		var bga : Int;
		var error : Int;
		var dx : Int = x1 - x0;
		var dy : Int = y1 - y0;
		var yi : Int = 1;
		var pos : Int;
		var dz : Float = z1 - z0;
		var dzdy : Float;
		if(dx <dy )
		{
			x0 ^= x1;
			x1 ^= x0;
			x0 ^= x1;
			y0 ^= y1;
			y1 ^= y0;
			y0 ^= y1;
			var t : Float = z1;
			z1 = z0;
			z0 = t;
		}
		if(dx <0 )
		{
			dx = - dx;
			yi = - yi;
			dz = - dz;
		}
		if(dy <0 )
		{
			dy = - dy;
			yi = - yi;
			dz = - dz;
		}
		if(dy> dx )
		{
			error = -(dy>> 1 );
			dzdy = dz /(y0 - y1);
			for(y in y1...y0)
			{
				pos = x1 + y * width;
				bgColor = target[pos];
				bga = bgColor>> 24 & 0xFF ;
				if(bga <0xFF)
				{
					target[pos] =(Std.int(alpha * 255 + invAlpha * bga) <<24 |
					                Std.int(alpha * r + invAlpha *(bgColor>> 16 & 0xFF)) <<16 |
					                Std.int(alpha * g + invAlpha *(bgColor>> 8 & 0xFF)) <<8 |
					                Std.int(alpha * b + invAlpha *(bgColor & 0xFF)));
				} else if(z1> buffer[pos])
				{
					target[pos] =(0xFF000000 |
					                Std.int(alpha * r + invAlpha *(bgColor>> 16 & 0xFF)) <<16 |
					                Std.int(alpha * g + invAlpha *(bgColor>> 8 & 0xFF)) <<8 |
					                Std.int(alpha * b + invAlpha *(bgColor & 0xFF)));
				}
				error += dx;
				if(error> 0 )
				{
					x1 += yi;
					z1 += dzdy;
					error -= dy;
				}
			}
		} 
		else
		{
			error = -(dx>> 1 );
			dzdy = dz /(x1 - x0);
			for(x in x0...x1)
			{
				pos = x + y0 * width;
				bgColor = target[pos];
				bga = bgColor>> 24 & 0xFF ;
				if(bga <0xFF)
				{
					target[pos] =(Std.int(alpha * 255 + invAlpha * bga) <<24 |
					                Std.int(alpha * r + invAlpha *(bgColor>> 16 & 0xFF)) <<16 |
					                Std.int(alpha * g + invAlpha *(bgColor>> 8 & 0xFF)) <<8 |
					                Std.int(alpha * b + invAlpha *(bgColor & 0xFF)));
				} else if(z0> buffer[pos])
				{
					target[pos] =(0xFF000000 |
					                Std.int(alpha * r + invAlpha *(bgColor>> 16 & 0xFF)) <<16 |
					                Std.int(alpha * g + invAlpha *(bgColor>> 8 & 0xFF)) <<8 |
					                Std.int(alpha * b + invAlpha *(bgColor & 0xFF)));
				}
				error += dy;
				if(error> 0 )
				{
					y0 += yi;
					z0 += dzdy;
					error -= dx;
				}
			}
		}
	}
}
