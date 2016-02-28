package pixel3d.renderer.basic;
import pixel3d.renderer.AbstractTriangleRenderer;
import flash.Vector;
import pixel3d.math.MathUtil;
import pixel3d.math.Vertex4D;
import pixel3d.utils.Logger;
import pixel3d.renderer.RenderState;
class BasicTextureFlat extends AbstractTriangleRenderer
{
	private var tu1 : Float;
	private var tv1 : Float;
	private var tu2 : Float;
	private var tv2 : Float;
	private var tu3 : Float;
	private var tv3 : Float;
	private var tu2u1 : Float;
	private var tu3u1 : Float;
	private var tv2v1 : Float;
	private var tv3v1 : Float;
	private var ui : Float;
	private var vi : Float;
	private var tw : Int;
	private var th : Int;
	private var dudya : Float;
	private var dvdya : Float;
	private var textel : UInt;
	private var aT : Int;
	private var dudx : Float;
	private var dudy : Float;
	private var dvdx : Float;
	private var dvdy : Float;
	private var ua : Float;
	private var va : Float;
	public function new()
	{
		super();
	}
	override public function drawIndexedTriangleList(vertices : Vector<Vertex4D>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int) : Void
	{
		//mipmap
		//var level : Int = Std.int(distance / mipMapDistance);
		texVector = texture.getVector();
		texWidth = texture.getWidth();
		texHeight = texture.getHeight();
		tw = texWidth - 1;
		th = texHeight - 1;
		
		perspectiveCorrect =(distance <perspectiveDistance);
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
			z1 = v1.z;
			z2 = v2.z;
			z3 = v3.z;
			if(perspectiveCorrect)
			{
				tu1 = v1.u * tw * z1;
				tv1 = v1.v * th * z1;
				tu2 = v2.u * tw * z2;
				tv2 = v2.v * th * z2;
				tu3 = v3.u * tw * z3;
				tv3 = v3.v * th * z3;
			} else
			{
				tu1 = v1.u * tw ;
				tv1 = v1.v * th ;
				tu2 = v2.u * tw ;
				tv2 = v2.v * th ;
				tu3 = v3.u * tw ;
				tv3 = v3.v * th ;
			}
			y1i = Std.int(y1);
			y2i = Std.int(y2);
			y3i = Std.int(y3);
			x2x1 = x2 - x1;
			x3x1 = x3 - x1;
			y2y1 = y2 - y1;
			y3y1 = y3 - y1;
			z2z1 = z2 - z1;
			z3z1 = z3 - z1;
			tu2u1 = tu2 - tu1;
			tu3u1 = tu3 - tu1;
			tv2v1 = tv2 - tv1;
			tv3v1 = tv3 - tv1;
			var denom : Float =(x3x1 * y2y1 - x2x1 * y3y1);
			if(denom == 0) continue;
			denom = 1 / denom;
			dzdx =(z3z1 * y2y1 - z2z1 * y3y1) * denom;
			dudx =(tu3u1 * y2y1 - tu2u1 * y3y1) * denom;
			dvdx =(tv3v1 * y2y1 - tv2v1 * y3y1) * denom;
			dzdy =(z2z1 * x3x1 - z3z1 * x2x1) * denom;
			dudy =(tu2u1 * x3x1 - tu3u1 * x2x1) * denom;
			dvdy =(tv2v1 * x3x1 - tv3v1 * x2x1) * denom;
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
				dudya = dxdya * dudx + dudy;
				dvdya = dxdya * dvdx + dvdy;
				// Perform subpixel pre-stepping along left edge
				dy = 1 -(y1 - y1i );
				xa = x1 + dy * dxdya;
				za = z1 + dy * dzdya;
				ua = tu1 + dy * dudya;
				va = tv1 + dy * dvdya;
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
					dudya = dxdy1 * dudx + dudy;
					dvdya = dxdy1 * dvdx + dvdy;
					xa = x1 + dy * dxdya;
					za = z1 + dy * dzdya;
					ua = tu1 + dy * dudya;
					va = tv1 + dy * dvdya;
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
					dudya = dxdy3 * dudx + dudy;
					dvdya = dxdy3 * dvdx + dvdy;
					dy = 1 -(y2 - y2i );
					xa = x2 + dy * dxdya;
					za = z2 + dy * dzdya;
					ua = tu2 + dy * dudya;
					va = tv2 + dy * dvdya;
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
			ui = ua + dx * dudx;
			vi = va + dx * dvdx;
			while(xs <xe )
			{
				pos = xs + ys * width;
				if(zi> buffer[pos])
				{
					if(perspectiveCorrect)
					{
					    if(isPowOfTow)
						{
							textel = texVector[(Std.int(ui / zi)&tw) +(Std.int(vi / zi)&th) * texWidth];
						}else
						{
							textel = texVector[Std.int(ui / zi) + Std.int(vi / zi) * texWidth];
						}
					} else
					{
						 if(isPowOfTow)
						{
							textel = texVector[(Std.int(ui)&tw) +(Std.int(vi)&th) * texWidth];
						}else
						{
							textel = texVector[Std.int(ui) + Std.int(vi) * texWidth];
						}
					}
					aT =(textel>> 24 & 0xFF);
					if(aT <255)
					{
						bgColor = target[pos];
						bga = bgColor>> 24 & 0xFF ;
						var invA1 : Int = 255 - aT;
						target[pos] =((aT + invA1 * bga>> 8) <<24 |
						((aT *(textel>> 16 & 0xFF)>> 8) +(invA1 *(bgColor>> 16 & 0xFF)>> 8)) <<16 |
						((aT *(textel>> 8 & 0xFF)>> 8) +(invA1 *(bgColor>> 8 & 0xFF)>> 8)) <<8 |
						((aT *(textel & 0xFF)>> 8) +(invA1 *(bgColor & 0xFF)>> 8)));
					} else
					{
						target[pos] = textel;
						buffer[pos] = zi;
					}
				}
				zi += dzdx;
				ui += dudx;
				vi += dvdx;
				xs ++;
			}
			xa += dxdya;
			xb += dxdyb;
			za += dzdya;
			ua += dudya;
			va += dvdya;
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
			ui = ua + dx * dudx;
			vi = va + dx * dvdx;
			while(xs <xe )
			{
				pos = xs + ys * width;
				bgColor = target[pos];
				bga = bgColor>> 24 & 0xFF ;
				if(bga <255 || zi> buffer[pos])
				{
					if(perspectiveCorrect)
					{
					    if(isPowOfTow)
						{
							textel = texVector[(Std.int(ui / zi)&tw) +(Std.int(vi / zi)&th) * texWidth];
						}else
						{
							textel = texVector[Std.int(ui / zi) + Std.int(vi / zi) * texWidth];
						}
					} else
					{
						 if(isPowOfTow)
						{
							textel = texVector[(Std.int(ui)&tw) +(Std.int(vi)&th) * texWidth];
						}else
						{
							textel = texVector[Std.int(ui) + Std.int(vi) * texWidth];
						}
					}
					aT =(textel>> 24 & 0xFF);
					if(aT <255)
					{
						var a1 : Float = alpha * aT * MathUtil.Reciprocal255;
						var invA1 : Float = 1.0 - a1;
						target[pos] =(Std.int(a1 * 255 + invA1 * bga) <<24 |
						Std.int(a1 *(textel>> 16 & 0xFF) + invA1 *(bgColor>> 16 & 0xFF)) <<16 |
						Std.int(a1 *(textel>> 8 & 0xFF) + invA1 *(bgColor>> 8 & 0xFF)) <<8 |
						Std.int(a1 *(textel & 0xFF) + invA1 *(bgColor & 0xFF)));
					} else
					{
						target[pos] =(Std.int(alpha * aT + invAlpha * bga) <<24 |
						Std.int(alpha *(textel>> 16 & 0xFF) + invAlpha *(bgColor>> 16 & 0xFF)) <<16 |
						Std.int(alpha *(textel>> 8 & 0xFF) + invAlpha *(bgColor>> 8 & 0xFF)) <<8 |
						Std.int(alpha *(textel & 0xFF) + invAlpha *(bgColor & 0xFF)));
					}
				}
				zi += dzdx;
				ui += dudx;
				vi += dvdx;
				xs ++;
			}
			xa += dxdya;
			xb += dxdyb;
			za += dzdya;
			ua += dudya;
			va += dvdya;
			ys ++;
		}
	}
}
