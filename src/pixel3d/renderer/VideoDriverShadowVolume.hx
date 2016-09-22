package pixel3d.renderer;
import flash.Vector;
import pixel3d.math.Color;
import pixel3d.math.Vector2i;
import pixel3d.math.MathUtil;
import flash.geom.Vector3D;
import pixel3d.math.Quaternion;
import pixel3d.math.Vertex;
import pixel3d.math.Vertex4D;
import pixel3d.scene.shadow.ShadowBuffer;
import pixel3d.renderer.shadowvolume.DepthTriangleRenderer;
import pixel3d.renderer.shadowvolume.ShadowVolumeFlat;
import pixel3d.renderer.shadowvolume.ShadowVolumeGouraud;
import pixel3d.renderer.shadowvolume.ShadowVolumeRenderer;
import pixel3d.renderer.shadowvolume.ShadowVolumeSkyBox;
import pixel3d.renderer.shadowvolume.ShadowVolumeTextureFlat;
import pixel3d.renderer.shadowvolume.ShadowVolumeTextureGouraud;
import pixel3d.renderer.shadowvolume.ShadowVolumeTextureLightMap;
import pixel3d.renderer.shadowvolume.ShadowVolumeWireframe;
import pixel3d.renderer.TriangleRendererType;

class VideoDriverShadowVolume extends VideoDriverBasic
{
	private var shadowVolumeRender : ShadowVolumeRenderer;
	private var depthTriangleRenderer : DepthTriangleRenderer;
	private var shadowPerctent : Float;

	private var stencileBuffer : Vector<Int>;// use by shadow volume

	public function new(size : Vector2i)
	{
		super(size);
	}

	override public function initRenderers():Void
	{
		renderers = new Vector<ITriangleRenderer>(TriangleRendererType.COUNT, true);
		renderers[TriangleRendererType.WIREFRAME] = new ShadowVolumeWireframe();
		renderers[TriangleRendererType.FLAT] = new ShadowVolumeFlat();
		renderers[TriangleRendererType.GOURAUD] = new ShadowVolumeGouraud();
		renderers[TriangleRendererType.TEXTURE_FLAT] = new ShadowVolumeTextureFlat();
		renderers[TriangleRendererType.TEXTURE_GOURAUD] = new ShadowVolumeTextureGouraud();
		renderers[TriangleRendererType.TEXTURE_FLAT_NoZ] = new ShadowVolumeSkyBox();
		renderers[TriangleRendererType.TEXTURE_LIGHTMAP] = new ShadowVolumeTextureLightMap();

		shadowVolumeRender = new ShadowVolumeRenderer();
		depthTriangleRenderer = new DepthTriangleRenderer();

		backfaceVectors = new Vector<Vector3D>();
		backfaceCount = 0;
	}

	override public function setRenderState(state : Int) : Void
	{
		this.renderState = state;
		for (i in 0...TriangleRendererType.COUNT)
		{
			renderers[i].setRenderState(renderState);
		}
	}

	public function setShadowPercent(per : Float) : Void
	{
		shadowPerctent = MathUtil.clamp(per, 0, 1);
		for (i in 0...TriangleRendererType.COUNT)
		{
			renderers[i].setShadowPercent(per);
		}
	}

	public function getStencileBuffer() : Vector<Int>
	{
		return stencileBuffer;
	}

	override public function beginScene() : Void
	{
		super.beginScene();
		stencileBuffer.fixed = false;
		stencileBuffer.length = 0;
		stencileBuffer.length = screenSize.width * screenSize.height;
		stencileBuffer.fixed = true;
	}

	override public function setScreenSize(size : Vector2i) : Void
	{
		super.setScreenSize(size);

		stencileBuffer = new Vector<Int>();
		stencileBuffer.length = screenSize.width * screenSize.height;
		stencileBuffer.fixed = true;
		setStencileBuffer(stencileBuffer);
	}

	//只使用环境光绘制绘制场景
	override public function drawIndexedTriangleListAmbientLight(vertices : Vector<Vertex>, vertexCount : Int, indexList : Vector<Int>, triangleCount : Int) : Void
	{
		var tCount : Int;
		var iCount : Int;
		var vCount : Int;
		var vCount2 : Int;
		//clipping
		var a : Vertex4D;
		var b : Vertex4D;
		var out : Vertex4D;
		var inCount : Int;
		var outCount : Int;
		var plane : Quaternion;
		var source : Vector<Vertex4D>;
		var adot : Float;
		var bdot : Float;
		var t : Float;
		var len : Int = triangleCount * 2;
		var _transformLen : Int = _transformedVertexes.length;
		if (_transformLen <len)
		{
			for (i in _transformLen...len)
			{
				_transformedVertexes[i] = new Vertex4D();
			}
		}
		var m11 : Float = _current.m11;
		var m21 : Float = _current.m21;
		var m31 : Float = _current.m31;
		var m41 : Float = _current.m41;
		var m12 : Float = _current.m12;
		var m22 : Float = _current.m22;
		var m32 : Float = _current.m32;
		var m42 : Float = _current.m42;
		var m13 : Float = _current.m13;
		var m23 : Float = _current.m23;
		var m33 : Float = _current.m33;
		var m43 : Float = _current.m43;
		var m14 : Float = _current.m14;
		var m24 : Float = _current.m24;
		var m34 : Float = _current.m34;
		var m44 : Float = _current.m44;
		tCount = 0;
		iCount = 0;
		vCount = 0;
		if (shadowPerctent == 1)
		{
			var ii : Int = 0;
			while (ii <triangleCount )
			{
				v0 = vertices[indexList[ii]];
				v1 = vertices[indexList[ii + 1]];
				v2 = vertices[indexList[ii + 2]];
				ii += 3;
				v0x = v0.x;
				v0y = v0.y;
				v0z = v0.z;
				v1x = v1.x;
				v1y = v1.y;
				v1z = v1.z;
				v2x = v2.x;
				v2y = v2.y;
				v2z = v2.z;
				var t : Float =((v1y - v0y) *(v2z - v0z) -(v1z - v0z) *(v2y - v0y)) *(_invCamPos.x - v0x) +
							   ((v1z - v0z) *(v2x - v0x) -(v1x - v0x) *(v2z - v0z)) *(_invCamPos.y - v0y) +
							   ((v1x - v0x) *(v2y - v0y) -(v1y - v0y) *(v2x - v0x)) *(_invCamPos.z - v0z);
				if (t <= 0)
				{
					continue;
				}
				tv0 = _transformedVertexes[tCount ++];
				tv1 = _transformedVertexes[tCount ++];
				tv2 = _transformedVertexes[tCount ++];
				//	- transform Model * World * Camera * Projection matrix ,then after clip and light * NDCSpace matrix
				tv0.x = m11 * v0x + m21 * v0y + m31 * v0z + m41;
				tv0.y = m12 * v0x + m22 * v0y + m32 * v0z + m42;
				tv0.z = m13 * v0x + m23 * v0y + m33 * v0z + m43;
				tv0.w = m14 * v0x + m24 * v0y + m34 * v0z + m44;
				tv1.x = m11 * v1x + m21 * v1y + m31 * v1z + m41;
				tv1.y = m12 * v1x + m22 * v1y + m32 * v1z + m42;
				tv1.z = m13 * v1x + m23 * v1y + m33 * v1z + m43;
				tv1.w = m14 * v1x + m24 * v1y + m34 * v1z + m44;
				tv2.x = m11 * v2x + m21 * v2y + m31 * v2z + m41;
				tv2.y = m12 * v2x + m22 * v2y + m32 * v2z + m42;
				tv2.z = m13 * v2x + m23 * v2y + m33 * v2z + m43;
				tv2.w = m14 * v2x + m24 * v2y + m34 * v2z + m44;
				var inside : Bool = true;
				var clipcount : Int = 0;
				//far Quaternion(0.0 , 0.0 , 1.0 , -1.0 );
				if ((tv0.z - tv0.w)>= 0.0)
				{
					if ((tv1.z - tv1.w )>= 0.0)
					{
						if ((tv2.z - tv2.w)>= 0.0)
						{
							inside = false;
						}
					}
					clipcount += 1;
				}
				else
				{
					if ((tv1.z - tv1.w ) <0.0)
					{
						if ((tv2.z - tv2.w )>= 0.0)
						{
							clipcount += 1;
						}
					}
					else
					{
						clipcount += 1;
						//(1 <<0);

					}
				}
				if ( ! inside)
				{
					tCount -= 3;
					continue;
				}
				// near Quaternion(0.0 , 0.0 , -1.0, -1.0 );
				if (( - tv0.z - tv0.w)>= 0.0)
				{
					if (( - tv1.z - tv1.w )>= 0.0)
					{
						if (( - tv2.z - tv2.w)>= 0.0)
						{
							inside = false;
						}
					}
					clipcount += 2;
				}
				else
				{
					if (( - tv1.z - tv1.w ) <0.0)
					{
						if (( - tv2.z - tv2.w)>= 0.0)
						{
							clipcount += 2;
						}
					}
					else
					{
						clipcount += 2;
					}
				}
				if ( ! inside)
				{
					tCount -= 3;
					continue;
				}
				// left Quaternion(1.0 , 0.0 , 0.0 , -1.0 )
				if ((tv0.x - tv0.w)>= 0.0)
				{
					if ((tv1.x - tv1.w)>= 0.0)
					{
						if ((tv2.x - tv2.w)>= 0.0)
						{
							inside = false;
						}
					}
					clipcount += 4;
				}
				else
				{
					if ((tv1.x - tv1.w) <0.0)
					{
						if ((tv2.x - tv2.w)>= 0.0)
						{
							clipcount += 4;
						}
					}
					else
					{
						clipcount += 4;
					}
				}
				if ( ! inside)
				{
					tCount -= 3;
					continue;
				}
				// right Quaternion(-1.0, 0.0 , 0.0 , -1.0 )
				if (( - tv0.x - tv0.w)>= 0.0)
				{
					if (( - tv1.x - tv1.w )>= 0.0)
					{
						if (( - tv2.x - tv2.w)>= 0.0)
						{
							inside = false;
						}
					}
					clipcount += 8;
				}
				else
				{
					if (( - tv1.x - tv1.w ) <0.0)
					{
						if (( - tv2.x - tv2.w)>= 0.0)
						{
							clipcount += 8;
						}
					}
					else
					{
						clipcount += 8;
					}
				}
				if ( ! inside)
				{
					tCount -= 3;
					continue;
				}
				// bottom Quaternion(0.0 , 1.0 , 0.0 , -1.0 )
				if ((tv0.y - tv0.w)>= 0.0)
				{
					if ((tv1.y - tv1.w )>= 0.0)
					{
						if ((tv2.y - tv2.w)>= 0.0)
						{
							inside = false;
						}
					}
					clipcount += 16;
				}
				else
				{
					if ((tv1.y - tv1.w) <0.0)
					{
						if ((tv2.y - tv2.w)>= 0.0)
						{
							clipcount += 16;
						}
					}
					else
					{
						clipcount += 16;
					}
				}
				if ( ! inside)
				{
					tCount -= 3;
					continue;
				}
				//top Quaternion(0.0 , -1.0, 0.0 , -1.0 )
				if (( - tv0.y - tv0.w)>= 0.0)
				{
					if (( - tv1.y - tv1.w )>= 0.0)
					{
						if (( - tv2.y - tv2.w)>= 0.0)
						{
							inside = false;
						}
					}
					clipcount += 32;
				}
				else
				{
					if (( - tv1.y - tv1.w) <0.0)
					{
						if (( - tv2.y - tv2.w)>= 0.0)
						{
							clipcount += 32;
						}
					}
					else
					{
						clipcount += 32;
					}
				}
				if ( ! inside)
				{
					tCount -= 3;
					continue;
				}
				if (clipcount == 0) // no clipping required
				{
					//tv0
					tv0.z = 1 / tv0.w ;
					tv0.x = tv0.x * _scale_m11 * tv0.z + _scale_m41;
					tv0.y = tv0.y * _scale_m22 * tv0.z + _scale_m42;
					//tv1
					tv1.z = 1 / tv1.w ;
					tv1.x = tv1.x * _scale_m11 * tv1.z + _scale_m41;
					tv1.y = tv1.y * _scale_m22 * tv1.z + _scale_m42;
					//tv2
					tv2.z = 1 / tv2.w ;
					tv2.x = tv2.x * _scale_m11 * tv2.z + _scale_m41;
					tv2.y = tv2.y * _scale_m22 * tv2.z + _scale_m42;
					// add to _clippedIndices
					_clippedIndices[iCount ++] = vCount;
					_clippedVertices[vCount ++] = tv0;
					_clippedIndices[iCount ++] = vCount;
					_clippedVertices[vCount ++] = tv1;
					_clippedIndices[iCount ++] = vCount;
					_clippedVertices[vCount ++] = tv2;
					continue;
				}
				// put into list for clipping
				_unclippedVertices[0] = tv0;
				_unclippedVertices[1] = tv1;
				_unclippedVertices[2] = tv2;
				source = _unclippedVertices;
				outCount = 3;
				/********** clip in NDC Space to Frustum **********/
				//(0.0, 0.0, -1.0, - 1.0 ) near
				if ((clipcount & 2) == 2)
				{
					inCount = outCount;
					outCount = 0;
					b = source[0];
					bdot = - b.z - b.w;
					var i : Int = 1;
					while (i <= inCount)
					{
						a = source[i % inCount];
						i ++;
						adot = - a.z - a.w;
						// current point inside
						if (adot <= 0.0 )
						{
							// last point outside
							if (bdot> 0.0 )
							{
								out = _transformedVertexes[tCount ++];
								_clippedVertices4[outCount ++] = out;
								t = bdot /( -(b.z - a.z) -(b.w - a.w));
								out.interpolateXYZW(a, b, t);
							}
							// add a to out
							_clippedVertices4[outCount ++] = a;
						}
						else
						{
							if (bdot <= 0.0 )
							{
								out = _transformedVertexes[tCount ++];
								_clippedVertices4[outCount ++] = out;
								t = bdot /( -(b.z - a.z) -(b.w - a.w));
								out.interpolateXYZW(a, b, t);
							}
						}
						b = a;
						bdot = adot;
					}
					// check we have 3 or more vertices
					if (outCount <3)
					{
						continue;
					}
					source = _clippedVertices4;
				}
				//(1.0, 0.0, 0.0, - 1.0 )  left
				if ((clipcount & 4) == 4)
				{
					inCount = outCount;
					outCount = 0;
					b = source[0];
					bdot = b.x - b.w ;
					var i : Int = 1;
					while (i <= inCount)
					{
						a = source[i % inCount];
						i ++;
						adot = a.x - a.w;
						if (adot <= 0.0 )
						{
							if (bdot> 0.0 )
							{
								out = _transformedVertexes[tCount ++];
								_clippedVertices3[outCount ++] = out;
								t = bdot /((b.x - a.x) -(b.w - a.w));
								out.interpolateXYZW(a, b, t);
							}
							// add a to out
							_clippedVertices3[outCount ++] = a;
						}
						else
						{
							if (bdot <= 0.0 )
							{
								out = _transformedVertexes[tCount ++];
								_clippedVertices3[outCount ++] = out;
								t = bdot /((b.x - a.x) -(b.w - a.w));
								out.interpolateXYZW(a, b, t);
							}
						}
						b = a;
						bdot = adot;
					}
					if (outCount <3)
					{
						continue;
					}
					source = _clippedVertices3;
				}
				//( - 1.0, 0.0, 0.0, - 1.0 )  right
				if ((clipcount & 8) == 8)
				{
					inCount = outCount;
					outCount = 0;
					b = source[0];
					bdot = - b.x - b.w;
					var i : Int = 1;
					while (i <= inCount)
					{
						a = source[i % inCount];
						i ++;
						adot = - a.x - a.w;
						if (adot <= 0.0 )
						{
							if (bdot> 0.0 )
							{
								out = _transformedVertexes[tCount ++];
								_clippedVertices2[outCount ++] = out;
								t = bdot /( -(b.x - a.x) -(b.w - a.w));
								out.interpolateXYZW(a, b, t);
							}
							_clippedVertices2[outCount ++] = a;
						}
						else
						{
							if (bdot <= 0.0 )
							{
								out = _transformedVertexes[tCount ++];
								_clippedVertices2[outCount ++] = out;
								t = bdot /( -(b.x - a.x) -(b.w - a.w));
								out.interpolateXYZW(a, b, t);
							}
						}
						b = a;
						bdot = adot;
					}
					if (outCount <3)
					{
						continue;
					}
					source = _clippedVertices2;
				}
				//(0.0, 1.0, 0.0, - 1.0 ) bottom
				if ((clipcount & 16) == 16)
				{
					inCount = outCount;
					outCount = 0;
					b = source[0];
					bdot = b.y - b.w ;
					var i : Int = 1;
					while (i <= inCount)
					{
						a = source[i % inCount];
						i ++;
						adot = a.y - a.w;
						if (adot <= 0.0 )
						{
							if (bdot> 0.0 )
							{
								out = _transformedVertexes[tCount ++];
								_clippedVertices1[outCount ++] = out;
								t = bdot /((b.y - a.y) -(b.w - a.w));
								out.interpolateXYZW(a, b, t);
							}
							_clippedVertices1[outCount ++] = a;
						}
						else
						{
							if (bdot <= 0.0 )
							{
								out = _transformedVertexes[tCount ++];
								_clippedVertices1[outCount ++] = out;
								t = bdot /((b.y - a.y) -(b.w - a.w));
								out.interpolateXYZW(a, b, t);
							}
						}
						b = a;
						bdot = adot;
					}
					if (outCount <3)
					{
						continue;
					}
					source = _clippedVertices1;
				}
				//(0.0, - 1.0, 0.0, - 1.0 ) top
				if ((clipcount & 32) == 32)
				{
					inCount = outCount;
					outCount = 0;
					b = source[0];
					bdot = - b.y - b.w;
					var i : Int = 1;
					while (i <= inCount)
					{
						a = source[i % inCount];
						i ++;
						adot = - a.y - a.w ;
						if (adot <= 0.0 )
						{
							if (bdot> 0.0 )
							{
								out = _transformedVertexes[tCount ++];
								_clippedVertices0[outCount ++] = out;
								t = bdot /( -(b.y - a.y) -(b.w - a.w));
								out.interpolateXYZW(a, b, t);
							}
							_clippedVertices0[outCount ++] = a;
						}
						else
						{
							if (bdot <= 0.0 )
							{
								out = _transformedVertexes[tCount ++];
								_clippedVertices0[outCount ++] = out;
								t = bdot /( -(b.y - a.y) -(b.w - a.w));
								out.interpolateXYZW(a, b, t);
							}
						}
						b = a;
						bdot = adot;
					}
					if (outCount <3)
					{
						continue;
					}
					source = _clippedVertices0;
				}
				// put back into screen space.
				vCount2 = vCount;
				for (g in 0...outCount)
				{
					tv0 = source[g];
					tv0.z = 1 / tv0.w ;
					tv0.x = tv0.x * _scale_m11 * tv0.z + _scale_m41;
					tv0.y = tv0.y * _scale_m22 * tv0.z + _scale_m42;
					//tv0.z = tmp;
					_clippedVertices[vCount ++] = tv0;
				}
				// re-tesselate( triangle-fan, 0-1-2,0-2-3.. )
				for (g in 0...(outCount - 2))
				{
					_clippedIndices[iCount ++] = vCount2;
					_clippedIndices[iCount ++] = vCount2 + g + 1;
					_clippedIndices[iCount ++] = vCount2 + g + 2;
				}
			}
			depthTriangleRenderer.drawIndexedTriangleList(_clippedVertices, vCount, _clippedIndices, iCount);
		}
		else
		{
			if (hasTexture)
			{
				curRender = renderers[TriangleRendererType.TEXTURE_GOURAUD];
			}
			else
			{
				curRender = renderers[TriangleRendererType.FLAT];
			}
			curRender.setMaterial(material);
			var memi : Color = material.emissiveColor;
			var mamb : Color = material.ambientColor;
			var mdif : Color = material.diffuseColor;
			var globalR : Float =(ambientColor.r * mamb.r * MathUtil.Reciprocal255) + memi.r;
			var globalG : Float =(ambientColor.g * mamb.g * MathUtil.Reciprocal255) + memi.g;
			var globalB : Float =(ambientColor.b * mamb.b * MathUtil.Reciprocal255) + memi.b;
			var ii : Int = 0;
			while (ii <triangleCount )
			{
				v0 = vertices[indexList[ii]];
				v1 = vertices[indexList[ii + 1]];
				v2 = vertices[indexList[ii + 2]];
				ii += 3;
				v0x = v0.x;
				v0y = v0.y;
				v0z = v0.z;
				v1x = v1.x;
				v1y = v1.y;
				v1z = v1.z;
				v2x = v2.x;
				v2y = v2.y;
				v2z = v2.z;
				var t : Float =((v1y - v0y) *(v2z - v0z) -(v1z - v0z) *(v2y - v0y)) *(_invCamPos.x - v0x) +
				((v1z - v0z) *(v2x - v0x) -(v1x - v0x) *(v2z - v0z)) *(_invCamPos.y - v0y) +
				((v1x - v0x) *(v2y - v0y) -(v1y - v0y) *(v2x - v0x)) *(_invCamPos.z - v0z);
				if (t <= 0)
				{
					continue;
				}
				tv0 = _transformedVertexes[tCount ++];
				tv1 = _transformedVertexes[tCount ++];
				tv2 = _transformedVertexes[tCount ++];
				//	- transform Model * World * Camera * Projection matrix ,then after clip and light * NDCSpace matrix
				tv0.x = m11 * v0x + m21 * v0y + m31 * v0z + m41;
				tv0.y = m12 * v0x + m22 * v0y + m32 * v0z + m42;
				tv0.z = m13 * v0x + m23 * v0y + m33 * v0z + m43;
				tv0.w = m14 * v0x + m24 * v0y + m34 * v0z + m44;
				tv1.x = m11 * v1x + m21 * v1y + m31 * v1z + m41;
				tv1.y = m12 * v1x + m22 * v1y + m32 * v1z + m42;
				tv1.z = m13 * v1x + m23 * v1y + m33 * v1z + m43;
				tv1.w = m14 * v1x + m24 * v1y + m34 * v1z + m44;
				tv2.x = m11 * v2x + m21 * v2y + m31 * v2z + m41;
				tv2.y = m12 * v2x + m22 * v2y + m32 * v2z + m42;
				tv2.z = m13 * v2x + m23 * v2y + m33 * v2z + m43;
				tv2.w = m14 * v2x + m24 * v2y + m34 * v2z + m44;
				var inside : Bool = true;
				var clipcount : Int = 0;
				//far Quaternion(0.0 , 0.0 , 1.0 , -1.0 );
				if ((tv0.z - tv0.w)>= 0.0)
				{
					if ((tv1.z - tv1.w )>= 0.0)
					{
						if ((tv2.z - tv2.w)>= 0.0)
						{
							inside = false;
						}
					}
					clipcount += 1;
				}
				else
				{
					if ((tv1.z - tv1.w ) <0.0)
					{
						if ((tv2.z - tv2.w )>= 0.0)
						{
							clipcount += 1;
						}
					}
					else
					{
						clipcount += 1;
						//(1 <<0);

					}
				}
				if ( ! inside)
				{
					tCount -= 3;
					continue;
				}
				// near Quaternion(0.0 , 0.0 , -1.0, -1.0 );
				if (( - tv0.z - tv0.w)>= 0.0)
				{
					if (( - tv1.z - tv1.w )>= 0.0)
					{
						if (( - tv2.z - tv2.w)>= 0.0)
						{
							inside = false;
						}
					}
					clipcount += 2;
				}
				else
				{
					if (( - tv1.z - tv1.w ) <0.0)
					{
						if (( - tv2.z - tv2.w)>= 0.0)
						{
							clipcount += 2;
						}
					}
					else
					{
						clipcount += 2;
					}
				}
				if ( ! inside)
				{
					tCount -= 3;
					continue;
				}
				// left Quaternion(1.0 , 0.0 , 0.0 , -1.0 )
				if ((tv0.x - tv0.w)>= 0.0)
				{
					if ((tv1.x - tv1.w)>= 0.0)
					{
						if ((tv2.x - tv2.w)>= 0.0)
						{
							inside = false;
						}
					}
					clipcount += 4;
				}
				else
				{
					if ((tv1.x - tv1.w) <0.0)
					{
						if ((tv2.x - tv2.w)>= 0.0)
						{
							clipcount += 4;
						}
					}
					else
					{
						clipcount += 4;
					}
				}
				if ( ! inside)
				{
					tCount -= 3;
					continue;
				}
				// right Quaternion(-1.0, 0.0 , 0.0 , -1.0 )
				if (( - tv0.x - tv0.w)>= 0.0)
				{
					if (( - tv1.x - tv1.w )>= 0.0)
					{
						if (( - tv2.x - tv2.w)>= 0.0)
						{
							inside = false;
						}
					}
					clipcount += 8;
				}
				else
				{
					if (( - tv1.x - tv1.w ) <0.0)
					{
						if (( - tv2.x - tv2.w)>= 0.0)
						{
							clipcount += 8;
						}
					}
					else
					{
						clipcount += 8;
					}
				}
				if ( ! inside)
				{
					tCount -= 3;
					continue;
				}
				// bottom Quaternion(0.0 , 1.0 , 0.0 , -1.0 )
				if ((tv0.y - tv0.w)>= 0.0)
				{
					if ((tv1.y - tv1.w )>= 0.0)
					{
						if ((tv2.y - tv2.w)>= 0.0)
						{
							inside = false;
						}
					}
					clipcount += 16;
				}
				else
				{
					if ((tv1.y - tv1.w) <0.0)
					{
						if ((tv2.y - tv2.w)>= 0.0)
						{
							clipcount += 16;
						}
					}
					else
					{
						clipcount += 16;
					}
				}
				if ( ! inside)
				{
					tCount -= 3;
					continue;
				}
				//top Quaternion(0.0 , -1.0, 0.0 , -1.0 )
				if (( - tv0.y - tv0.w)>= 0.0)
				{
					if (( - tv1.y - tv1.w )>= 0.0)
					{
						if (( - tv2.y - tv2.w)>= 0.0)
						{
							inside = false;
						}
					}
					clipcount += 32;
				}
				else
				{
					if (( - tv1.y - tv1.w) <0.0)
					{
						if (( - tv2.y - tv2.w)>= 0.0)
						{
							clipcount += 32;
						}
					}
					else
					{
						clipcount += 32;
					}
				}
				if ( ! inside)
				{
					tCount -= 3;
					continue;
				}
				tv0.r = globalR;
				tv0.g = globalG;
				tv0.b = globalB;
				tv1.r = globalR;
				tv1.g = globalG;
				tv1.b = globalB;
				tv2.r = globalR;
				tv2.g = globalG;
				tv2.b = globalB;
				// texture coords
				if (hasTexture)
				{
					tv0.u = v0.u ;
					tv0.v = v0.v ;
					tv1.u = v1.u ;
					tv1.v = v1.v ;
					tv2.u = v2.u ;
					tv2.v = v2.v ;
				}
				if (clipcount == 0) // no clipping required

				{
					//tv0
					tv0.z = 1 / tv0.w ;
					tv0.x = tv0.x * _scale_m11 * tv0.z + _scale_m41;
					tv0.y = tv0.y * _scale_m22 * tv0.z + _scale_m42;
					//tv1
					tv1.z = 1 / tv1.w ;
					tv1.x = tv1.x * _scale_m11 * tv1.z + _scale_m41;
					tv1.y = tv1.y * _scale_m22 * tv1.z + _scale_m42;
					//tv2
					tv2.z = 1 / tv2.w ;
					tv2.x = tv2.x * _scale_m11 * tv2.z + _scale_m41;
					tv2.y = tv2.y * _scale_m22 * tv2.z + _scale_m42;
					// add to _clippedIndices
					_clippedIndices[iCount ++] = vCount;
					_clippedVertices[vCount ++] = tv0;
					_clippedIndices[iCount ++] = vCount;
					_clippedVertices[vCount ++] = tv1;
					_clippedIndices[iCount ++] = vCount;
					_clippedVertices[vCount ++] = tv2;
					continue;
				}
				// put into list for clipping
				_unclippedVertices[0] = tv0;
				_unclippedVertices[1] = tv1;
				_unclippedVertices[2] = tv2;
				source = _unclippedVertices;
				outCount = 3;
				/********** clip in NDC Space to Frustum **********/
				//(0.0, 0.0, -1.0, - 1.0 ) near
				if ((clipcount & 2) == 2)
				{
					inCount = outCount;
					outCount = 0;
					b = source[0];
					bdot = - b.z - b.w;
					var i : Int = 1;
					while (i <= inCount)
					{
						a = source[i % inCount];
						i ++;
						adot = - a.z - a.w;
						// current point inside
						if (adot <= 0.0 )
						{
							// last point outside
							if (bdot> 0.0 )
							{
								out = _transformedVertexes[tCount ++];
								_clippedVertices4[outCount ++] = out;
								t = bdot /( -(b.z - a.z) -(b.w - a.w));
								out.interpolate(a, b, t, hasTexture,false);
							}
							// add a to out
							_clippedVertices4[outCount ++] = a;
						}
						else
						{
							if (bdot <= 0.0 )
							{
								out = _transformedVertexes[tCount ++];
								_clippedVertices4[outCount ++] = out;
								t = bdot /( -(b.z - a.z) -(b.w - a.w));
								out.interpolate(a, b, t, hasTexture,false);
							}
						}
						b = a;
						bdot = adot;
					}
					// check we have 3 or more vertices
					if (outCount <3)
					{
						continue;
					}
					source = _clippedVertices4;
				}
				//(1.0, 0.0, 0.0, - 1.0 )  left
				if ((clipcount & 4) == 4)
				{
					inCount = outCount;
					outCount = 0;
					b = source[0];
					bdot = b.x - b.w ;
					var i : Int = 1;
					while (i <= inCount)
					{
						a = source[i % inCount];
						i ++;
						adot = a.x - a.w;
						if (adot <= 0.0 )
						{
							if (bdot> 0.0 )
							{
								out = _transformedVertexes[tCount ++];
								_clippedVertices3[outCount ++] = out;
								t = bdot /((b.x - a.x) -(b.w - a.w));
								out.interpolate(a, b, t, hasTexture,false);
							}
							// add a to out
							_clippedVertices3[outCount ++] = a;
						}
						else
						{
							if (bdot <= 0.0 )
							{
								out = _transformedVertexes[tCount ++];
								_clippedVertices3[outCount ++] = out;
								t = bdot /((b.x - a.x) -(b.w - a.w));
								out.interpolate(a, b, t, hasTexture,false);
							}
						}
						b = a;
						bdot = adot;
					}
					if (outCount <3)
					{
						continue;
					}
					source = _clippedVertices3;
				}
				//( - 1.0, 0.0, 0.0, - 1.0 )  right
				if ((clipcount & 8) == 8)
				{
					inCount = outCount;
					outCount = 0;
					b = source[0];
					bdot = - b.x - b.w;
					var i : Int = 1;
					while (i <= inCount)
					{
						a = source[i % inCount];
						i ++;
						adot = - a.x - a.w;
						if (adot <= 0.0 )
						{
							if (bdot> 0.0 )
							{
								out = _transformedVertexes[tCount ++];
								_clippedVertices2[outCount ++] = out;
								t = bdot /( -(b.x - a.x) -(b.w - a.w));
								out.interpolate(a, b, t, hasTexture,false);
							}
							_clippedVertices2[outCount ++] = a;
						}
						else
						{
							if (bdot <= 0.0 )
							{
								out = _transformedVertexes[tCount ++];
								_clippedVertices2[outCount ++] = out;
								t = bdot /( -(b.x - a.x) -(b.w - a.w));
								out.interpolate(a, b, t, hasTexture,false);
							}
						}
						b = a;
						bdot = adot;
					}
					if (outCount <3)
					{
						continue;
					}
					source = _clippedVertices2;
				}
				//(0.0, 1.0, 0.0, - 1.0 ) bottom
				if ((clipcount & 16) == 16)
				{
					inCount = outCount;
					outCount = 0;
					b = source[0];
					bdot = b.y - b.w ;
					var i : Int = 1;
					while (i <= inCount)
					{
						a = source[i % inCount];
						i ++;
						adot = a.y - a.w;
						if (adot <= 0.0 )
						{
							if (bdot> 0.0 )
							{
								out = _transformedVertexes[tCount ++];
								_clippedVertices1[outCount ++] = out;
								t = bdot /((b.y - a.y) -(b.w - a.w));
								out.interpolate(a, b, t, hasTexture,false);
							}
							_clippedVertices1[outCount ++] = a;
						}
						else
						{
							if (bdot <= 0.0 )
							{
								out = _transformedVertexes[tCount ++];
								_clippedVertices1[outCount ++] = out;
								t = bdot /((b.y - a.y) -(b.w - a.w));
								out.interpolate(a, b, t, hasTexture,false);
							}
						}
						b = a;
						bdot = adot;
					}
					if (outCount <3)
					{
						continue;
					}
					source = _clippedVertices1;
				}
				//(0.0, - 1.0, 0.0, - 1.0 ) top
				if ((clipcount & 32) == 32)
				{
					inCount = outCount;
					outCount = 0;
					b = source[0];
					bdot = - b.y - b.w;
					var i : Int = 1;
					while (i <= inCount)
					{
						a = source[i % inCount];
						i ++;
						adot = - a.y - a.w ;
						if (adot <= 0.0 )
						{
							if (bdot> 0.0 )
							{
								out = _transformedVertexes[tCount ++];
								_clippedVertices0[outCount ++] = out;
								t = bdot /( -(b.y - a.y) -(b.w - a.w));
								out.interpolate(a, b, t, hasTexture,false);
							}
							_clippedVertices0[outCount ++] = a;
						}
						else
						{
							if (bdot <= 0.0 )
							{
								out = _transformedVertexes[tCount ++];
								_clippedVertices0[outCount ++] = out;
								t = bdot /( -(b.y - a.y) -(b.w - a.w));
								out.interpolate(a, b, t, hasTexture,false);
							}
						}
						b = a;
						bdot = adot;
					}
					if (outCount <3)
					{
						continue;
					}
					source = _clippedVertices0;
				}
				// put back into screen space.
				vCount2 = vCount;
				for (g in 0...outCount)
				{
					tv0 = source[g];
					tv0.z = 1 / tv0.w ;
					tv0.x = tv0.x * _scale_m11 * tv0.z + _scale_m41;
					tv0.y = tv0.y * _scale_m22 * tv0.z + _scale_m42;
					//tv0.z = tmp;
					_clippedVertices[vCount ++] = tv0;
				}
				// re-tesselate( triangle-fan, 0-1-2,0-2-3.. )
				for (g in 0...(outCount - 2))
				{
					_clippedIndices[iCount ++] = vCount2;
					_clippedIndices[iCount ++] = vCount2 + g + 1;
					_clippedIndices[iCount ++] = vCount2 + g + 2;
				}
			}
			curRender.drawIndexedTriangleList(_clippedVertices, vCount, _clippedIndices, iCount);
		}
	}

	private var vv0 : Vector3D;
	private var vv1 : Vector3D;
	private var vv2 : Vector3D;
	private var backfaceVectors : Vector<Vector3D>;
	private var backfaceCount : Int;
	override public function drawStencilShadowVolume(volume : ShadowBuffer, zfail : Bool) : Void
	{
		var m11 : Float = _current.m11;
		var m21 : Float = _current.m21;
		var m31 : Float = _current.m31;
		var m41 : Float = _current.m41;
		var m12 : Float = _current.m12;
		var m22 : Float = _current.m22;
		var m32 : Float = _current.m32;
		var m42 : Float = _current.m42;
		var m13 : Float = _current.m13;
		var m23 : Float = _current.m23;
		var m33 : Float = _current.m33;
		var m43 : Float = _current.m43;
		var m14 : Float = _current.m14;
		var m24 : Float = _current.m24;
		var m34 : Float = _current.m34;
		var m44 : Float = _current.m44;
		var tCount : Int;
		var iCount : Int;
		var vCount : Int;
		var vCount2 : Int;
		//clipping
		var a : Vertex4D;
		var b : Vertex4D;
		var out : Vertex4D;
		var inCount : Int;
		var outCount : Int;
		var plane : Quaternion;
		var source : Vector<Vertex4D>;
		var adot : Float;
		var bdot : Float;
		var t : Float;
		var vertices : flash.Vector<Vector3D>= volume.vertices;
		var triangleCount : Int = volume.count;
		var len : Int = triangleCount * 6;
		var _transformLen : Int = _transformedVertexes.length;
		if (_transformLen <len)
		{
			for (i in _transformLen...len)
			{
				_transformedVertexes[i] = new Vertex4D();
			}
		}
		shadowVolumeRender.setZfail(zfail);
		//设置是否使用zfail
		//首先绘制正面，剔除背面，目前这种效率比较低下（分两次循环），以后考虑集中到一起来做。
		tCount = 0;
		iCount = 0;
		vCount = 0;
		backfaceCount = 0;
		var ii : Int = 0;
		while (ii <triangleCount )
		{
			vv0 = vertices[ii];
			vv1 = vertices[ii + 1];
			vv2 = vertices[ii + 2];
			ii += 3;
			v0x = vv0.x;
			v0y = vv0.y;
			v0z = vv0.z;
			v1x = vv1.x;
			v1y = vv1.y;
			v1z = vv1.z;
			v2x = vv2.x;
			v2y = vv2.y;
			v2z = vv2.z;
			if (((v1y - v0y) *(v2z - v0z) -(v1z - v0z) *(v2y - v0y)) *(_invCamPos.x - v0x) +((v1z - v0z) *(v2x - v0x) -(v1x - v0x) *(v2z - v0z)) *(_invCamPos.y - v0y) +((v1x - v0x) *(v2y - v0y) -(v1y - v0y) *(v2x - v0x)) *(_invCamPos.z - v0z) <= 0) //背面剔除

			{
				backfaceVectors[backfaceCount] = vv0;
				backfaceVectors[backfaceCount + 1] = vv1;
				backfaceVectors[backfaceCount + 2] = vv2;
				backfaceCount += 3;
				continue;
			}
			tv0 = _transformedVertexes[tCount ++];
			tv1 = _transformedVertexes[tCount ++];
			tv2 = _transformedVertexes[tCount ++];
			//	- transform Model * World * Camera * Projection matrix ,then after clip and light * NDCSpace matrix
			tv0.x = m11 * v0x + m21 * v0y + m31 * v0z + m41;
			tv0.y = m12 * v0x + m22 * v0y + m32 * v0z + m42;
			tv0.z = m13 * v0x + m23 * v0y + m33 * v0z + m43;
			tv0.w = m14 * v0x + m24 * v0y + m34 * v0z + m44;
			tv1.x = m11 * v1x + m21 * v1y + m31 * v1z + m41;
			tv1.y = m12 * v1x + m22 * v1y + m32 * v1z + m42;
			tv1.z = m13 * v1x + m23 * v1y + m33 * v1z + m43;
			tv1.w = m14 * v1x + m24 * v1y + m34 * v1z + m44;
			tv2.x = m11 * v2x + m21 * v2y + m31 * v2z + m41;
			tv2.y = m12 * v2x + m22 * v2y + m32 * v2z + m42;
			tv2.z = m13 * v2x + m23 * v2y + m33 * v2z + m43;
			tv2.w = m14 * v2x + m24 * v2y + m34 * v2z + m44;
			var inside : Bool = true;
			var clipcount : Int = 0;
			//far Quaternion(0.0 , 0.0 , 1.0 , -1.0 );
			if ((tv0.z - tv0.w)>= 0.0)
			{
				if ((tv1.z - tv1.w )>= 0.0)
				{
					if ((tv2.z - tv2.w)>= 0.0)
					{
						inside = false;
					}
				}
				clipcount += 1;
			}
			else
			{
				if ((tv1.z - tv1.w ) <0.0)
				{
					if ((tv2.z - tv2.w )>= 0.0)
					{
						clipcount += 1;
					}
				}
				else
				{
					clipcount += 1;
					//(1 <<0);

				}
			}
			if ( ! inside)
			{
				tCount -= 3;
				continue;
			}
			// near Quaternion(0.0 , 0.0 , -1.0, -1.0 );
			if (( - tv0.z - tv0.w)>= 0.0)
			{
				if (( - tv1.z - tv1.w )>= 0.0)
				{
					if (( - tv2.z - tv2.w)>= 0.0)
					{
						inside = false;
					}
				}
				clipcount += 2;
			}
			else
			{
				if (( - tv1.z - tv1.w ) <0.0)
				{
					if (( - tv2.z - tv2.w)>= 0.0)
					{
						clipcount += 2;
					}
				}
				else
				{
					clipcount += 2;
				}
			}
			if ( ! inside)
			{
				tCount -= 3;
				continue;
			}
			// left Quaternion(1.0 , 0.0 , 0.0 , -1.0 )
			if ((tv0.x - tv0.w)>= 0.0)
			{
				if ((tv1.x - tv1.w)>= 0.0)
				{
					if ((tv2.x - tv2.w)>= 0.0)
					{
						inside = false;
					}
				}
				clipcount += 4;
			}
			else
			{
				if ((tv1.x - tv1.w) <0.0)
				{
					if ((tv2.x - tv2.w)>= 0.0)
					{
						clipcount += 4;
					}
				}
				else
				{
					clipcount += 4;
				}
			}
			if ( ! inside)
			{
				tCount -= 3;
				continue;
			}
			// right Quaternion(-1.0, 0.0 , 0.0 , -1.0 )
			if (( - tv0.x - tv0.w)>= 0.0)
			{
				if (( - tv1.x - tv1.w )>= 0.0)
				{
					if (( - tv2.x - tv2.w)>= 0.0)
					{
						inside = false;
					}
				}
				clipcount += 8;
			}
			else
			{
				if (( - tv1.x - tv1.w ) <0.0)
				{
					if (( - tv2.x - tv2.w)>= 0.0)
					{
						clipcount += 8;
					}
				}
				else
				{
					clipcount += 8;
				}
			}
			if ( ! inside)
			{
				tCount -= 3;
				continue;
			}
			// bottom Quaternion(0.0 , 1.0 , 0.0 , -1.0 )
			if ((tv0.y - tv0.w)>= 0.0)
			{
				if ((tv1.y - tv1.w )>= 0.0)
				{
					if ((tv2.y - tv2.w)>= 0.0)
					{
						inside = false;
					}
				}
				clipcount += 16;
			}
			else
			{
				if ((tv1.y - tv1.w) <0.0)
				{
					if ((tv2.y - tv2.w)>= 0.0)
					{
						clipcount += 16;
					}
				}
				else
				{
					clipcount += 16;
				}
			}
			if ( ! inside)
			{
				tCount -= 3;
				continue;
			}
			//top Quaternion(0.0 , -1.0, 0.0 , -1.0 )
			if (( - tv0.y - tv0.w)>= 0.0)
			{
				if (( - tv1.y - tv1.w )>= 0.0)
				{
					if (( - tv2.y - tv2.w)>= 0.0)
					{
						inside = false;
					}
				}
				clipcount += 32;
			}
			else
			{
				if (( - tv1.y - tv1.w) <0.0)
				{
					if (( - tv2.y - tv2.w)>= 0.0)
					{
						clipcount += 32;
					}
				}
				else
				{
					clipcount += 32;
				}
			}
			if ( ! inside)
			{
				tCount -= 3;
				continue;
			}
			if (clipcount == 0) // no clipping required

			{
				//tv0
				tv0.z = 1 / tv0.w ;
				tv0.x = tv0.x * _scale_m11 * tv0.z + _scale_m41;
				tv0.y = tv0.y * _scale_m22 * tv0.z + _scale_m42;
				//tv1
				tv1.z = 1 / tv1.w ;
				tv1.x = tv1.x * _scale_m11 * tv1.z + _scale_m41;
				tv1.y = tv1.y * _scale_m22 * tv1.z + _scale_m42;
				//tv2
				tv2.z = 1 / tv2.w ;
				tv2.x = tv2.x * _scale_m11 * tv2.z + _scale_m41;
				tv2.y = tv2.y * _scale_m22 * tv2.z + _scale_m42;
				// add to _clippedIndices
				_clippedIndices[iCount ++] = vCount;
				_clippedVertices[vCount ++] = tv0;
				_clippedIndices[iCount ++] = vCount;
				_clippedVertices[vCount ++] = tv1;
				_clippedIndices[iCount ++] = vCount;
				_clippedVertices[vCount ++] = tv2;
				continue;
			}
			// put into list for clipping
			_unclippedVertices[0] = tv0;
			_unclippedVertices[1] = tv1;
			_unclippedVertices[2] = tv2;
			source = _unclippedVertices;
			outCount = 3;
			/********** clip in NDC Space to Frustum **********/
			//(0.0, 0.0, -1.0, - 1.0 ) near
			if ((clipcount & 2) == 2)
			{
				inCount = outCount;
				outCount = 0;
				b = source[0];
				bdot = - b.z - b.w;
				var i : Int = 1;
				while (i <= inCount)
				{
					a = source[i % inCount];
					i ++;
					adot = - a.z - a.w;
					// current point inside
					if (adot <= 0.0 )
					{
						// last point outside
						if (bdot> 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices4[outCount ++] = out;
							t = bdot /( -(b.z - a.z) -(b.w - a.w));
							out.interpolateXYZW(a, b, t);
						}
						// add a to out
						_clippedVertices4[outCount ++] = a;
					}
					else
					{
						if (bdot <= 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices4[outCount ++] = out;
							t = bdot /( -(b.z - a.z) -(b.w - a.w));
							out.interpolateXYZW(a, b, t);
						}
					}
					b = a;
					bdot = adot;
				}
				// check we have 3 or more vertices
				if (outCount <3)
				{
					continue;
				}
				source = _clippedVertices4;
			}
			//(1.0, 0.0, 0.0, - 1.0 )  left
			if ((clipcount & 4) == 4)
			{
				inCount = outCount;
				outCount = 0;
				b = source[0];
				bdot = b.x - b.w ;
				var i : Int = 1;
				while (i <= inCount)
				{
					a = source[i % inCount];
					i ++;
					adot = a.x - a.w;
					if (adot <= 0.0 )
					{
						if (bdot> 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices3[outCount ++] = out;
							t = bdot /((b.x - a.x) -(b.w - a.w));
							out.interpolateXYZW(a, b, t);
						}
						// add a to out
						_clippedVertices3[outCount ++] = a;
					}
					else
					{
						if (bdot <= 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices3[outCount ++] = out;
							t = bdot /((b.x - a.x) -(b.w - a.w));
							out.interpolateXYZW(a, b, t);
						}
					}
					b = a;
					bdot = adot;
				}
				if (outCount <3)
				{
					continue;
				}
				source = _clippedVertices3;
			}
			//( - 1.0, 0.0, 0.0, - 1.0 )  right
			if ((clipcount & 8) == 8)
			{
				inCount = outCount;
				outCount = 0;
				b = source[0];
				bdot = - b.x - b.w;
				var i : Int = 1;
				while (i <= inCount)
				{
					a = source[i % inCount];
					i ++;
					adot = - a.x - a.w;
					if (adot <= 0.0 )
					{
						if (bdot> 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices2[outCount ++] = out;
							t = bdot /( -(b.x - a.x) -(b.w - a.w));
							out.interpolateXYZW(a, b, t);
						}
						_clippedVertices2[outCount ++] = a;
					}
					else
					{
						if (bdot <= 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices2[outCount ++] = out;
							t = bdot /( -(b.x - a.x) -(b.w - a.w));
							out.interpolateXYZW(a, b, t);
						}
					}
					b = a;
					bdot = adot;
				}
				if (outCount <3)
				{
					continue;
				}
				source = _clippedVertices2;
			}
			//(0.0, 1.0, 0.0, - 1.0 ) bottom
			if ((clipcount & 16) == 16)
			{
				inCount = outCount;
				outCount = 0;
				b = source[0];
				bdot = b.y - b.w ;
				var i : Int = 1;
				while (i <= inCount)
				{
					a = source[i % inCount];
					i ++;
					adot = a.y - a.w;
					if (adot <= 0.0 )
					{
						if (bdot> 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices1[outCount ++] = out;
							t = bdot /((b.y - a.y) -(b.w - a.w));
							out.interpolateXYZW(a, b, t);
						}
						_clippedVertices1[outCount ++] = a;
					}
					else
					{
						if (bdot <= 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices1[outCount ++] = out;
							t = bdot /((b.y - a.y) -(b.w - a.w));
							out.interpolateXYZW(a, b, t);
						}
					}
					b = a;
					bdot = adot;
				}
				if (outCount <3)
				{
					continue;
				}
				source = _clippedVertices1;
			}
			//(0.0, - 1.0, 0.0, - 1.0 ) top
			if ((clipcount & 32) == 32)
			{
				inCount = outCount;
				outCount = 0;
				b = source[0];
				bdot = - b.y - b.w;
				var i : Int = 1;
				while (i <= inCount)
				{
					a = source[i % inCount];
					i ++;
					adot = - a.y - a.w ;
					if (adot <= 0.0 )
					{
						if (bdot> 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices0[outCount ++] = out;
							t = bdot /( -(b.y - a.y) -(b.w - a.w));
							out.interpolateXYZW(a, b, t);
						}
						_clippedVertices0[outCount ++] = a;
					}
					else
					{
						if (bdot <= 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices0[outCount ++] = out;
							t = bdot /( -(b.y - a.y) -(b.w - a.w));
							out.interpolateXYZW(a, b, t);
						}
					}
					b = a;
					bdot = adot;
				}
				if (outCount <3)
				{
					continue;
				}
				source = _clippedVertices0;
			}
			// put back into screen space.
			vCount2 = vCount;
			for (g in 0...outCount)
			{
				tv0 = source[g];
				tv0.z = 1 / tv0.w ;
				tv0.x = tv0.x * _scale_m11 * tv0.z + _scale_m41;
				tv0.y = tv0.y * _scale_m22 * tv0.z + _scale_m42;
				//tv0.z = tmp;
				_clippedVertices[vCount ++] = tv0;
			}
			// re-tesselate( triangle-fan, 0-1-2,0-2-3.. )
			for (g in 0...(outCount - 2))
			{
				_clippedIndices[iCount ++] = vCount2;
				_clippedIndices[iCount ++] = vCount2 + g + 1;
				_clippedIndices[iCount ++] = vCount2 + g + 2;
			}
		}
		shadowVolumeRender.setCurrentPass(ShadowVolumeRenderer.FRONTFACE);
		shadowVolumeRender.drawIndexedTriangleList(_clippedVertices, vCount, _clippedIndices, iCount);
		//渲染背面，剔除正面
		tCount = 0;
		iCount = 0;
		vCount = 0;
		ii = 0;
		while (ii <backfaceCount )
		{
			vv0 = backfaceVectors[ii];
			vv1 = backfaceVectors[ii + 1];
			vv2 = backfaceVectors[ii + 2];
			ii += 3;
			v0x = vv0.x;
			v0y = vv0.y;
			v0z = vv0.z;
			v1x = vv1.x;
			v1y = vv1.y;
			v1z = vv1.z;
			v2x = vv2.x;
			v2y = vv2.y;
			v2z = vv2.z;
			tv0 = _transformedVertexes[tCount ++];
			tv1 = _transformedVertexes[tCount ++];
			tv2 = _transformedVertexes[tCount ++];
			//	- transform Model * World * Camera * Projection matrix ,then after clip and light * NDCSpace matrix
			tv0.x = m11 * v0x + m21 * v0y + m31 * v0z + m41;
			tv0.y = m12 * v0x + m22 * v0y + m32 * v0z + m42;
			tv0.z = m13 * v0x + m23 * v0y + m33 * v0z + m43;
			tv0.w = m14 * v0x + m24 * v0y + m34 * v0z + m44;
			tv1.x = m11 * v1x + m21 * v1y + m31 * v1z + m41;
			tv1.y = m12 * v1x + m22 * v1y + m32 * v1z + m42;
			tv1.z = m13 * v1x + m23 * v1y + m33 * v1z + m43;
			tv1.w = m14 * v1x + m24 * v1y + m34 * v1z + m44;
			tv2.x = m11 * v2x + m21 * v2y + m31 * v2z + m41;
			tv2.y = m12 * v2x + m22 * v2y + m32 * v2z + m42;
			tv2.z = m13 * v2x + m23 * v2y + m33 * v2z + m43;
			tv2.w = m14 * v2x + m24 * v2y + m34 * v2z + m44;
			var inside : Bool = true;
			var clipcount : Int = 0;
			//far Quaternion(0.0 , 0.0 , 1.0 , -1.0 );
			if ((tv0.z - tv0.w)>= 0.0)
			{
				if ((tv1.z - tv1.w )>= 0.0)
				{
					if ((tv2.z - tv2.w)>= 0.0)
					{
						inside = false;
					}
				}
				clipcount += 1;
			}
			else
			{
				if ((tv1.z - tv1.w ) <0.0)
				{
					if ((tv2.z - tv2.w )>= 0.0)
					{
						clipcount += 1;
					}
				}
				else
				{
					clipcount += 1;
					//(1 <<0);

				}
			}
			if ( ! inside)
			{
				tCount -= 3;
				continue;
			}
			// near Quaternion(0.0 , 0.0 , -1.0, -1.0 );
			if (( - tv0.z - tv0.w)>= 0.0)
			{
				if (( - tv1.z - tv1.w )>= 0.0)
				{
					if (( - tv2.z - tv2.w)>= 0.0)
					{
						inside = false;
					}
				}
				clipcount += 2;
			}
			else
			{
				if (( - tv1.z - tv1.w ) <0.0)
				{
					if (( - tv2.z - tv2.w)>= 0.0)
					{
						clipcount += 2;
					}
				}
				else
				{
					clipcount += 2;
				}
			}
			if ( ! inside)
			{
				tCount -= 3;
				continue;
			}
			// left Quaternion(1.0 , 0.0 , 0.0 , -1.0 )
			if ((tv0.x - tv0.w)>= 0.0)
			{
				if ((tv1.x - tv1.w)>= 0.0)
				{
					if ((tv2.x - tv2.w)>= 0.0)
					{
						inside = false;
					}
				}
				clipcount += 4;
			}
			else
			{
				if ((tv1.x - tv1.w) <0.0)
				{
					if ((tv2.x - tv2.w)>= 0.0)
					{
						clipcount += 4;
					}
				}
				else
				{
					clipcount += 4;
				}
			}
			if ( ! inside)
			{
				tCount -= 3;
				continue;
			}
			// right Quaternion(-1.0, 0.0 , 0.0 , -1.0 )
			if (( - tv0.x - tv0.w)>= 0.0)
			{
				if (( - tv1.x - tv1.w )>= 0.0)
				{
					if (( - tv2.x - tv2.w)>= 0.0)
					{
						inside = false;
					}
				}
				clipcount += 8;
			}
			else
			{
				if (( - tv1.x - tv1.w ) <0.0)
				{
					if (( - tv2.x - tv2.w)>= 0.0)
					{
						clipcount += 8;
					}
				}
				else
				{
					clipcount += 8;
				}
			}
			if ( ! inside)
			{
				tCount -= 3;
				continue;
			}
			// bottom Quaternion(0.0 , 1.0 , 0.0 , -1.0 )
			if ((tv0.y - tv0.w)>= 0.0)
			{
				if ((tv1.y - tv1.w )>= 0.0)
				{
					if ((tv2.y - tv2.w)>= 0.0)
					{
						inside = false;
					}
				}
				clipcount += 16;
			}
			else
			{
				if ((tv1.y - tv1.w) <0.0)
				{
					if ((tv2.y - tv2.w)>= 0.0)
					{
						clipcount += 16;
					}
				}
				else
				{
					clipcount += 16;
				}
			}
			if ( ! inside)
			{
				tCount -= 3;
				continue;
			}
			//top Quaternion(0.0 , -1.0, 0.0 , -1.0 )
			if (( - tv0.y - tv0.w)>= 0.0)
			{
				if (( - tv1.y - tv1.w )>= 0.0)
				{
					if (( - tv2.y - tv2.w)>= 0.0)
					{
						inside = false;
					}
				}
				clipcount += 32;
			}
			else
			{
				if (( - tv1.y - tv1.w) <0.0)
				{
					if (( - tv2.y - tv2.w)>= 0.0)
					{
						clipcount += 32;
					}
				}
				else
				{
					clipcount += 32;
				}
			}
			if ( ! inside)
			{
				tCount -= 3;
				continue;
			}
			if (clipcount == 0) // no clipping required

			{
				//tv0
				tv0.z = 1 / tv0.w ;
				tv0.x = tv0.x * _scale_m11 * tv0.z + _scale_m41;
				tv0.y = tv0.y * _scale_m22 * tv0.z + _scale_m42;
				//tv1
				tv1.z = 1 / tv1.w ;
				tv1.x = tv1.x * _scale_m11 * tv1.z + _scale_m41;
				tv1.y = tv1.y * _scale_m22 * tv1.z + _scale_m42;
				//tv2
				tv2.z = 1 / tv2.w ;
				tv2.x = tv2.x * _scale_m11 * tv2.z + _scale_m41;
				tv2.y = tv2.y * _scale_m22 * tv2.z + _scale_m42;
				// add to _clippedIndices
				_clippedIndices[iCount ++] = vCount;
				_clippedVertices[vCount ++] = tv0;
				_clippedIndices[iCount ++] = vCount;
				_clippedVertices[vCount ++] = tv1;
				_clippedIndices[iCount ++] = vCount;
				_clippedVertices[vCount ++] = tv2;
				continue;
			}
			// put into list for clipping
			_unclippedVertices[0] = tv0;
			_unclippedVertices[1] = tv1;
			_unclippedVertices[2] = tv2;
			source = _unclippedVertices;
			outCount = 3;
			//(0.0, 0.0, -1.0, - 1.0 ) near
			if ((clipcount & 2) == 2)
			{
				inCount = outCount;
				outCount = 0;
				b = source[0];
				bdot = - b.z - b.w;
				var i : Int = 1;
				while (i <= inCount)
				{
					a = source[i % inCount];
					i ++;
					adot = - a.z - a.w;
					// current point inside
					if (adot <= 0.0 )
					{
						// last point outside
						if (bdot> 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices4[outCount ++] = out;
							t = bdot /( -(b.z - a.z) -(b.w - a.w));
							out.interpolateXYZW(a, b, t);
						}
						// add a to out
						_clippedVertices4[outCount ++] = a;
					}
					else
					{
						if (bdot <= 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices4[outCount ++] = out;
							t = bdot /( -(b.z - a.z) -(b.w - a.w));
							out.interpolateXYZW(a, b, t);
						}
					}
					b = a;
					bdot = adot;
				}
				// check we have 3 or more vertices
				if (outCount <3)
				{
					continue;
				}
				source = _clippedVertices4;
			}
			//(1.0, 0.0, 0.0, - 1.0 )  left
			if ((clipcount & 4) == 4)
			{
				inCount = outCount;
				outCount = 0;
				b = source[0];
				bdot = b.x - b.w ;
				var i : Int = 1;
				while (i <= inCount)
				{
					a = source[i % inCount];
					i ++;
					adot = a.x - a.w;
					if (adot <= 0.0 )
					{
						if (bdot> 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices3[outCount ++] = out;
							t = bdot /((b.x - a.x) -(b.w - a.w));
							out.interpolateXYZW(a, b, t);
						}
						// add a to out
						_clippedVertices3[outCount ++] = a;
					}
					else
					{
						if (bdot <= 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices3[outCount ++] = out;
							t = bdot /((b.x - a.x) -(b.w - a.w));
							out.interpolateXYZW(a, b, t);
						}
					}
					b = a;
					bdot = adot;
				}
				if (outCount <3)
				{
					continue;
				}
				source = _clippedVertices3;
			}
			//( - 1.0, 0.0, 0.0, - 1.0 )  right
			if ((clipcount & 8) == 8)
			{
				inCount = outCount;
				outCount = 0;
				b = source[0];
				bdot = - b.x - b.w;
				var i : Int = 1;
				while (i <= inCount)
				{
					a = source[i % inCount];
					i ++;
					adot = - a.x - a.w;
					if (adot <= 0.0 )
					{
						if (bdot> 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices2[outCount ++] = out;
							t = bdot /( -(b.x - a.x) -(b.w - a.w));
							out.interpolateXYZW(a, b, t);
						}
						_clippedVertices2[outCount ++] = a;
					}
					else
					{
						if (bdot <= 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices2[outCount ++] = out;
							t = bdot /( -(b.x - a.x) -(b.w - a.w));
							out.interpolateXYZW(a, b, t);
						}
					}
					b = a;
					bdot = adot;
				}
				if (outCount <3)
				{
					continue;
				}
				source = _clippedVertices2;
			}
			//(0.0, 1.0, 0.0, - 1.0 ) bottom
			if ((clipcount & 16) == 16)
			{
				inCount = outCount;
				outCount = 0;
				b = source[0];
				bdot = b.y - b.w ;
				var i : Int = 1;
				while (i <= inCount)
				{
					a = source[i % inCount];
					i ++;
					adot = a.y - a.w;
					if (adot <= 0.0 )
					{
						if (bdot> 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices1[outCount ++] = out;
							t = bdot /((b.y - a.y) -(b.w - a.w));
							out.interpolateXYZW(a, b, t);
						}
						_clippedVertices1[outCount ++] = a;
					}
					else
					{
						if (bdot <= 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices1[outCount ++] = out;
							t = bdot /((b.y - a.y) -(b.w - a.w));
							out.interpolateXYZW(a, b, t);
						}
					}
					b = a;
					bdot = adot;
				}
				if (outCount <3)
				{
					continue;
				}
				source = _clippedVertices1;
			}
			//(0.0, - 1.0, 0.0, - 1.0 ) top
			if ((clipcount & 32) == 32)
			{
				inCount = outCount;
				outCount = 0;
				b = source[0];
				bdot = - b.y - b.w;
				var i : Int = 1;
				while (i <= inCount)
				{
					a = source[i % inCount];
					i ++;
					adot = - a.y - a.w ;
					if (adot <= 0.0 )
					{
						if (bdot> 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices0[outCount ++] = out;
							t = bdot /( -(b.y - a.y) -(b.w - a.w));
							out.interpolateXYZW(a, b, t);
						}
						_clippedVertices0[outCount ++] = a;
					}
					else
					{
						if (bdot <= 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices0[outCount ++] = out;
							t = bdot /( -(b.y - a.y) -(b.w - a.w));
							out.interpolateXYZW(a, b, t);
						}
					}
					b = a;
					bdot = adot;
				}
				if (outCount <3)
				{
					continue;
				}
				source = _clippedVertices0;
			}
			// put back into screen space.
			vCount2 = vCount;
			for (g in 0...outCount)
			{
				tv0 = source[g];
				tv0.z = 1 / tv0.w ;
				tv0.x = tv0.x * _scale_m11 * tv0.z + _scale_m41;
				tv0.y = tv0.y * _scale_m22 * tv0.z + _scale_m42;
				//tv0.z = tmp;
				_clippedVertices[vCount ++] = tv0;
			}
			// re-tesselate( triangle-fan, 0-1-2,0-2-3.. )
			for (g in 0...(outCount - 2))
			{
				_clippedIndices[iCount ++] = vCount2;
				_clippedIndices[iCount ++] = vCount2 + g + 1;
				_clippedIndices[iCount ++] = vCount2 + g + 2;
			}
		}
		shadowVolumeRender.setCurrentPass(ShadowVolumeRenderer.BACKFACE);
		shadowVolumeRender.drawIndexedTriangleList(_clippedVertices, vCount, _clippedIndices, iCount);
	}

	override public function getDriverType() : Int
	{
		return VideoDriverType.SHADOWVOLUME;
	}

	private function setStencileBuffer(buffer : Vector<Int>) : Void
	{
		for (i in 0...TriangleRendererType.COUNT)
		{
			renderers[i].setStencileBuffer(buffer);
		}
		shadowVolumeRender.setStencileBuffer(buffer);
	}

	override private function setWidth(width : Int) : Void
	{
		super.setWidth(width);
		shadowVolumeRender.setWidth(width);
		depthTriangleRenderer.setWidth(width);
	}

	override private function setHeight(height : Int) : Void
	{
		super.setHeight(height);
		shadowVolumeRender.setHeight(height);
		depthTriangleRenderer.setHeight(height);
	}

	override private function setVector(tv : Vector<UInt>, bv : Vector<Float>) : Void
	{
		super.setVector(tv, bv);
		shadowVolumeRender.setVector(tv, bv);
		depthTriangleRenderer.setVector(tv, bv);
	}

	override public function canShadow() : Bool
	{
		return true;
	}
}
