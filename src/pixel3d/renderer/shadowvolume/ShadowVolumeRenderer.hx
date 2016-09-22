package pixel3d.renderer.shadowvolume;
import pixel3d.renderer.AbstractTriangleRenderer;
import flash.Vector;
import pixel3d.math.MathUtil;
import pixel3d.math.Vertex4D;
class ShadowVolumeRenderer extends AbstractTriangleRenderer
{
	public static inline var BACKFACE : Int = - 1;
	public static inline var FRONTFACE : Int = 1;
	private var currentPass : Int;
	private var zfail : Bool;
	public function new()
	{
		super();
	}
	public function setCurrentPass(pass : Int) : Void
	{
		this.currentPass = pass;
	}
	public function setZfail(fail : Bool)
	{
		this.zfail = fail;
	}
	override public function drawIndexedTriangleList(vertices : Vector<Vertex4D>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int) : Void
	{
		var drawSubTri;
		if (currentPass == FRONTFACE)
		{
			drawSubTri = drawSubTriFront;
		}
		else
		{
			drawSubTri = drawSubTriBack;
		}
		var dy : Float;
		var i : Int = 0;
		while (i <indexCount)
		{
			v1 = vertices[indexList[i]];
			v2 = vertices[indexList[i + 1]];
			v3 = vertices[indexList[i + 2]];
			i += 3;
			if (v2.y <v1.y)
			{
				tmp = v1;
				v1 = v2;
				v2 = tmp;
			}
			if (v3.y <v1.y)
			{
				tmp = v1;
				v1 = v3;
				v3 = tmp;
			}
			if (v3.y <v2.y)
			{
				tmp = v2;
				v2 = v3;
				v3 = tmp;
			}

			x1 = v1.x;
			y1 = v1.y;
			x2 = v2.x;
			y2 = v2.y;
			x3 = v3.x;
			y3 = v3.y;
			z1 = v1.z;
			z2 = v2.z;
			z3 = v3.z;
			y1i = Std.int(y1);
			y2i = Std.int(y2);
			y3i = Std.int(y3);
			x2x1 = x2 - x1;
			x3x1 = x3 - x1;
			y2y1 = y2 - y1;
			y3y1 = y3 - y1;
			z2z1 = z2 - z1;
			z3z1 = z3 - z1;
			var denom : Float =(x3x1 * y2y1 - x2x1 * y3y1);
			if (denom == 0) continue;
			denom = 1 / denom;
			dzdx =(z3z1 * y2y1 - z2z1 * y3y1) * denom;
			dzdy =(z2z1 * x3x1 - z3z1 * x2x1) * denom;
			dxdy1 = x2x1 / y2y1;
			dxdy2 = x3x1 / y3y1;
			dxdy3 =(x3 - x2) /(y3 - y2);
			side = dxdy2> dxdy1;
			if (y1 == y2 )
			{
				side = x1> x2;
			}
			if (y2 == y3 )
			{
				side = x3> x2;
			}
			if ( ! side )
			{
				dxdya = dxdy2;
				dzdya = dxdya * dzdx + dzdy;
				dy = 1 -(y1 - y1i );
				xa = x1 + dy * dxdya;
				za = z1 + dy * dzdya;
				if (y1i <y2i)
				{
					xb = x1 + dy * dxdy1;
					dxdyb = dxdy1;
					drawSubTri(y1i, y2i);
				}
				if (y2i <y3i)
				{
					xb = x2 +(1 -(y2 - y2i)) * dxdy3;
					dxdyb = dxdy3;
					drawSubTri(y2i, y3i);
				}
			}
			else
			{
				dxdyb = dxdy2;
				dy = 1 -(y1 - y1i);
				xb = x1 + dy * dxdyb;
				if (y1i <y2i )
				{
					dxdya = dxdy1;
					dzdya = dxdy1 * dzdx + dzdy;
					xa = x1 + dy * dxdya;
					za = z1 + dy * dzdya;
					drawSubTri(y1i, y2i);
				}
				if (y2i <y3i )
				{
					dxdya = dxdy3;
					dzdya = dxdy3 * dzdx + dzdy;
					dy = 1 -(y2 - y2i );
					xa = x2 + dy * dxdya;
					za = z2 + dy * dzdya;
					drawSubTri(y2i, y3i);
				}
			}
		}
	}
	private inline function drawSubTriFront(ys : Int, ye : Int ) : Void
	{
		while (ys <ye )
		{
			xs = Std.int(xa);
			xe = Std.int(xb);
			zi = za +(1 -(xa - xs)) * dzdx;
			while (xs <xe )
			{
				pos = xs + ys * width;
				//如果阴影体正面某点z坐标小于该点物体的z坐标，则代表该点穿过阴影体正面，+1
				if (zi > buffer[pos])
				{
					stencileBuffer[pos] += 1;
				}
				zi += dzdx;
				xs ++;
			}
			xa += dxdya;
			xb += dxdyb;
			za += dzdya;
			ys ++;
		}
	}
	private inline function drawSubTriBack(ys : Int, ye : Int ) : Void
	{
		while (ys <ye )
		{
			xs = Std.int(xa);
			xe = Std.int(xb);
			zi = za +(1 -(xa - xs)) * dzdx;
			while (xs <xe )
			{
				pos = xs + ys * width;
				//如果阴影体背面某点z坐标小于该点物体的z坐标，则代表该点穿过阴影体背面，-1
				if (zi>= buffer[pos])
				{
					stencileBuffer[pos] -= 1;
				}
				zi += dzdx;
				xs ++;
			}
			xa += dxdya;
			xb += dxdyb;
			za += dzdya;
			ys ++;
		}
	}
	private inline function drawSubTriZFail(ys : Int, ye : Int ) : Void
	{
		while (ys <ye )
		{
			xs = Std.int(xa);
			xe = Std.int(xb);
			zi = za +(1 -(xa - xs)) * dzdx;
			while (xs <xe )
			{
				pos = xs + ys * width;
				if (zi <= buffer[pos])
				{
					stencileBuffer[pos] += 1;
				}
				zi += dzdx;
				xs ++;
			}
			xa += dxdya;
			xb += dxdyb;
			za += dzdya;
			ys ++;
		}
	}
}
