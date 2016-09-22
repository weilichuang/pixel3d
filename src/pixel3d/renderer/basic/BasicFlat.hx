package pixel3d.renderer.basic;
import pixel3d.renderer.AbstractTriangleRenderer;
import flash.Vector;
import pixel3d.math.MathUtil;
import pixel3d.math.Vertex4D;
import pixel3d.renderer.RenderState;

class BasicFlat extends AbstractTriangleRenderer
{
	public function new()
	{
		super();
	}

	override public function drawIndexedTriangleList(vertices : Vector<Vertex4D>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int) : Void
	{
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
			x1 = v1.x ;
			y1 = v1.y ;
			x2 = v2.x ;
			y2 = v2.y ;
			x3 = v3.x ;
			y3 = v3.y ;
			r1 =(v1.r + v2.r + v3.r) * 0.333;
			g1 =(v1.g + v2.g + v3.g) * 0.333;
			b1 =(v1.b + v2.b + v3.b) * 0.333;
			z1 = v1.z;
			z2 = v2.z;
			z3 = v3.z;
			color = 0xFF000000 | Std.int(r1) <<16 | Std.int(g1) <<8 | Std.int(b1);
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
			dzdx = (z3z1 * y2y1 - z2z1 * y3y1) * denom;
			dzdy = (z2z1 * x3x1 - z3z1 * x2x1) * denom;

			// Calculate X-slopes along the edges
			dxdy1 = x2x1 / y2y1;
			dxdy2 = x3x1 / y3y1;
			dxdy3 = (x3 - x2) / (y3 - y2);

			// Determine which side of the poly the longer edge is on
			side = dxdy2> dxdy1;
			if (y1 == y2 )
			{
				side = x1> x2;
			}
			if (y2 == y3 )
			{
				side = x3> x2;
			}

			if ( ! side ) // Longer edge is on the left side
			{
				// Calculate slopes along left edge
				dxdya = dxdy2;
				dzdya = dxdya * dzdx + dzdy;
				// Perform subpixel pre-stepping along left edge
				dy = 1 -(y1 - y1i );
				xa = x1 + dy * dxdya;
				za = z1 + dy * dzdya;
				if (y1i <y2i) // Draw upper segment if possibly visible
				{
					// Set right edge X-slope and perform subpixel pre-stepping
					xb = x1 + dy * dxdy1;
					dxdyb = dxdy1;
					if (transparent && alpha <1)
					{
						drawSubTriAlpha(y1i, y2i);
					}
					else
					{
						drawSubTri(y1i, y2i);
					}
				}
				if (y2i <y3i) // Draw lower segment if possibly visible
				{
					// Set right edge X-slope and perform subpixel pre-stepping
					xb = x2 +(1 -(y2 - y2i)) * dxdy3;
					dxdyb = dxdy3;
					if (transparent && alpha <1)
					{
						drawSubTriAlpha(y2i, y3i);
					}
					else
					{
						drawSubTri(y2i, y3i);
					}
				}
			}
			else	// Longer edge is on the right side

			{
				// Set right edge X-slope and perform subpixel pre-stepping
				dxdyb = dxdy2;
				dy = 1 -(y1 - y1i);
				xb = x1 + dy * dxdyb;
				if (y1i <y2i ) // Draw upper segment if possibly visible

				{
					// Set slopes along left edge and perform subpixel pre-stepping
					dxdya = dxdy1;
					dzdya = dxdy1 * dzdx + dzdy;
					xa = x1 + dy * dxdya;
					za = z1 + dy * dzdya;
					if (transparent && alpha <1)
					{
						drawSubTriAlpha(y1i, y2i);
					}
					else
					{
						drawSubTri(y1i, y2i);
					}
				}
				if (y2i <y3i ) // Draw lower segment if possibly visible

				{
					// Set slopes along left edge and perform subpixel pre-stepping
					dxdya = dxdy3;
					dzdya = dxdy3 * dzdx + dzdy;
					dy = 1 -(y2 - y2i );
					xa = x2 + dy * dxdya;
					za = z2 + dy * dzdya;
					if (transparent && alpha <1)
					{
						drawSubTriAlpha(y2i, y3i);
					}
					else
					{
						drawSubTri(y2i, y3i);
					}
				}
			}
		}
	}

	private inline function drawSubTri(ys : Int, ye : Int ) : Void
	{
		var dx : Float;
		while (ys <ye )
		{
			xs = Std.int(xa);
			xe = Std.int(xb);
			zi = za +(1 -(xa - xs)) * dzdx;
			while (xs <xe )
			{
				pos = xs + ys * width;
				if (zi> buffer[pos])
				{
					target[pos] = color;
					buffer[pos] = zi;
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

	private inline function drawSubTriAlpha(ys : Int, ye : Int ) : Void
	{
		var dx : Float;
		while (ys <ye )
		{
			xs = Std.int(xa);
			xe = Std.int(xb);
			zi = za +(1 -(xa - xs)) * dzdx;
			while (xs <xe )
			{
				pos = xs + ys * width;
				bgColor = target[pos];
				bga = bgColor>> 24 & 0xFF ;
				if (bga <0xFF)
				{
					target[pos] =(Std.int(alpha * 255 + invAlpha * bga) <<24 |
					Std.int(alpha * r1 + invAlpha *(bgColor>> 16 & 0xFF)) <<16 |
					Std.int(alpha * g1 + invAlpha *(bgColor>> 8 & 0xFF)) <<8 |
					Std.int(alpha * b1 + invAlpha *(bgColor & 0xFF)));
				}
				else if (zi> buffer[pos])
				{
					target[pos] =(0xFF000000 |
					Std.int(alpha * r1 + invAlpha *(bgColor>> 16 & 0xFF)) <<16 |
					Std.int(alpha * g1 + invAlpha *(bgColor>> 8 & 0xFF)) <<8 |
					Std.int(alpha * b1 + invAlpha *(bgColor & 0xFF)));
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
