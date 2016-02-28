package pixel3d.renderer.basic;
import pixel3d.renderer.AbstractTriangleRenderer;
import flash.Vector;
import pixel3d.math.MathUtil;
import pixel3d.math.Vertex4D;
import pixel3d.renderer.RenderState;
class BasicGouraud extends AbstractTriangleRenderer
{
	private var r2r1 : Float;
	private var r3r1 : Float;
	private var g2g1 : Float;
	private var g3g1 : Float;
	private var b2b1 : Float;
	private var b3b1 : Float;
	private var r2 : Float;
	private var g2 : Float;
	private var b2 : Float;
	private var r3 : Float;
	private var g3 : Float;
	private var b3 : Float;
	private var drdya : Float;
	private var dgdya : Float;
	private var dbdya : Float;
	private var ra : Float;
	private var ga : Float;
	private var ba : Float;
	private var drdx : Float;
	private var drdy : Float;
	private var dgdx : Float;
	private var dgdy : Float;
	private var dbdx : Float;
	private var dbdy : Float;
	private var ri : Float;
	private var gi : Float;
	private var bi : Float;
	public function new()
	{
		super();
	}
	override public function drawIndexedTriangleList(vertices : Vector<Vertex4D>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int) : Void
	{
		var dy : Float;
		var i : Int = 0;
		while(i <indexCount)
		{
			v1 = vertices[indexList[i]];
			v2 = vertices[indexList[i + 1]];
			v3 = vertices[indexList[i + 2]];
			i += 3;
			if(v2.y <v1.y)
			{
				tmp = v1;
				v1 = v2;
				v2 = tmp;
			}
			if(v3.y <v1.y)
			{
				tmp = v1;
				v1 = v3;
				v3 = tmp;
			}
			if(v3.y <v2.y)
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
			r1 = v1.r;
			g1 = v1.g;
			b1 = v1.b;
			r2 = v2.r;
			g2 = v2.g;
			b2 = v2.b;
			r3 = v3.r;
			g3 = v3.g;
			b3 = v3.b;
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
			r2r1 = r2 - r1;
			r3r1 = r3 - r1;
			g2g1 = g2 - g1;
			g3g1 = g3 - g1;
			b2b1 = b2 - b1;
			b3b1 = b3 - b1;
			var denom : Float =(x3x1 * y2y1 - x2x1 * y3y1);
			if(denom == 0) continue;
			denom = 1 / denom;
			dzdx =(z3z1 * y2y1 - z2z1 * y3y1) * denom;
			drdx =(r3r1 * y2y1 - r2r1 * y3y1) * denom;
			dgdx =(g3g1 * y2y1 - g2g1 * y3y1) * denom;
			dbdx =(b3b1 * y2y1 - b2b1 * y3y1) * denom;
			dzdy =(z2z1 * x3x1 - z3z1 * x2x1) * denom;
			drdy =(r2r1 * x3x1 - r3r1 * x2x1) * denom;
			dgdy =(g2g1 * x3x1 - g3g1 * x2x1) * denom;
			dbdy =(b2b1 * x3x1 - b3b1 * x2x1) * denom;
			// Calculate X-slopes along the edges
			dxdy1 = x2x1 / y2y1;
			dxdy2 = x3x1 / y3y1;
			dxdy3 =(x3 - x2) /(y3 - y2);
			// Determine which side of the poly the longer edge is on
			side = dxdy2> dxdy1;
			if(y1 == y2 )
			{
				side = x1> x2;
			}
			if(y2 == y3 )
			{
				side = x3> x2;
			}
			if(side == false ) // Longer edge is on the left side
			
			{
				// Calculate slopes along left edge
				dxdya = dxdy2;
				dzdya = dxdya * dzdx + dzdy;
				drdya = dxdya * drdx + drdy;
				dgdya = dxdya * dgdx + dgdy;
				dbdya = dxdya * dbdx + dbdy;
				// Perform subpixel pre-stepping along left edge
				dy = 1 -(y1 - y1i );
				xa = x1 + dy * dxdya;
				za = z1 + dy * dzdya;
				ra = r1 + dy * drdya;
				ga = g1 + dy * dgdya;
				ba = b1 + dy * dbdya;
				if(y1i <y2i) // Draw upper segment if possibly visible
				
				{
					// Set right edge X-slope and perform subpixel pre-stepping
					xb = x1 + dy * dxdy1;
					dxdyb = dxdy1;
					if(transparent && alpha <1)
					{
						drawSubTriAlpha(y1i, y2i);
					} else
					{
						drawSubTri(y1i, y2i);
					}
				}
				if(y2i <y3i) // Draw lower segment if possibly visible
				
				{
					// Set right edge X-slope and perform subpixel pre-stepping
					xb = x2 +(1 -(y2 - y2i)) * dxdy3;
					dxdyb = dxdy3;
					if(transparent && alpha <1)
					{
						drawSubTriAlpha(y2i, y3i);
					} else
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
				if(y1i <y2i ) // Draw upper segment if possibly visible
				
				{
					// Set slopes along left edge and perform subpixel pre-stepping
					dxdya = dxdy1;
					dzdya = dxdy1 * dzdx + dzdy;
					drdya = dxdy1 * drdx + drdy;
					dgdya = dxdy1 * dgdx + dgdy;
					dbdya = dxdy1 * dbdx + dbdy;
					xa = x1 + dy * dxdya;
					za = z1 + dy * dzdya;
					ra = r1 + dy * drdya;
					ga = g1 + dy * dgdya;
					ba = b1 + dy * dbdya;
					if(transparent && alpha <1)
					{
						drawSubTriAlpha(y1i, y2i);
					} else
					{
						drawSubTri(y1i, y2i);
					}
				}
				if(y2i <y3i ) // Draw lower segment if possibly visible
				
				{
					// Set slopes along left edge and perform subpixel pre-stepping
					dxdya = dxdy3;
					dzdya = dxdy3 * dzdx + dzdy;
					drdya = dxdy3 * drdx + drdy;
					dgdya = dxdy3 * dgdx + dgdy;
					dbdya = dxdy3 * dbdx + dbdy;
					dy = 1 -(y2 - y2i );
					xa = x2 + dy * dxdya;
					za = z2 + dy * dzdya;
					ra = r2 + dy * drdya;
					ga = g2 + dy * dgdya;
					ba = b2 + dy * dbdya;
					if(transparent && alpha <1)
					{
						drawSubTriAlpha(y2i, y3i);
					} else
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
		while(ys <ye )
		{
			xs = Std.int(xa);
			xe = Std.int(xb);
			dx = 1 -(xa - xs );
			zi = za + dx * dzdx;
			ri = ra + dx * drdx;
			gi = ga + dx * dgdx;
			bi = ba + dx * dbdx;
			while(xs <xe )
			{
				pos = xs + ys * width;
				if(zi> buffer[pos])
				{
					target[pos] =(0xFF000000 | Std.int(ri) <<16 | Std.int(gi) <<8 | Std.int(bi));
					buffer[pos] = zi;
				}
				zi += dzdx;
				ri += drdx;
				gi += dgdx;
				bi += dbdx;
				xs ++;
			}
			xa += dxdya;
			xb += dxdyb;
			za += dzdya;
			ra += drdya;
			ga += dgdya;
			ba += dbdya;
			ys ++;
		}
	}

	private inline function drawSubTriAlpha(ys : Int, ye : Int ) : Void
	{
		var dx : Float;
		while(ys <ye )
		{
			xs = Std.int(xa);
			xe = Std.int(xb);
			dx = 1 -(xa - xs );
			zi = za + dx * dzdx;
			ri = ra + dx * drdx;
			gi = ga + dx * dgdx;
			bi = ba + dx * dbdx;
			while(xs <xe )
			{
				pos = xs + ys * width;
				bgColor = target[pos];
				bga = bgColor>> 24 & 0xFF ;
				if(bga <0xFF)
				{
					target[pos] =(Std.int(alpha * 255 + invAlpha * bga) <<24 |
					Std.int(alpha * ri + invAlpha *(bgColor>> 16 & 0xFF)) <<16 |
					Std.int(alpha * gi + invAlpha *(bgColor>> 8 & 0xFF)) <<8 |
					Std.int(alpha * bi + invAlpha *(bgColor & 0xFF)));
				} else if(zi> buffer[pos])
				{
					target[pos] =(0xFF000000 |
					Std.int(alpha * ri + invAlpha *(bgColor>> 16 & 0xFF)) <<16 |
					Std.int(alpha * gi + invAlpha *(bgColor>> 8 & 0xFF)) <<8 |
					Std.int(alpha * bi + invAlpha *(bgColor & 0xFF)));
				}
				zi += dzdx;
				ri += drdx;
				gi += dgdx;
				bi += dbdx;
				xs ++;
			}
			xa += dxdya;
			xb += dxdyb;
			za += dzdya;
			ra += drdya;
			ga += dgdya;
			ba += dbdya;
			ys ++;
		}
	}
}
