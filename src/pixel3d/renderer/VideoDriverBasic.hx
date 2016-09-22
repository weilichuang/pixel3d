package pixel3d.renderer;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.Vector;
import pixel3d.light.Light;
import pixel3d.math.Color;
import pixel3d.math.Vector2i;
import pixel3d.math.MathUtil;
import flash.geom.Vector3D;
import pixel3d.math.Quaternion;
import pixel3d.math.Vertex;
import pixel3d.math.Vertex4D;
import pixel3d.renderer.basic.BasicFlat;
import pixel3d.renderer.basic.BasicGouraud;
import pixel3d.renderer.basic.BasicSkyBox;
import pixel3d.renderer.basic.BasicTextureFlat;
import pixel3d.renderer.basic.BasicTextureGouraud;
import pixel3d.renderer.basic.BasicTextureLightMap;
import pixel3d.renderer.basic.BasicWireframe;
import pixel3d.renderer.TriangleRendererType;

class VideoDriverBasic extends AbstractVideoDriver implements IVideoDriver
{
	private var curRender : ITriangleRenderer;
	private var renderers : Vector<ITriangleRenderer>;

	private var target : Bitmap;

	private var targetVector : Vector<UInt>;
	private var depthBuffer : Vector<Float>;

	public function new(size : Vector2i)
	{
		super();

		target = new Bitmap();

		initRenderers();

		setScreenSize(size);
	}

	override public function initRenderers():Void
	{
		renderers = new Vector<ITriangleRenderer>(TriangleRendererType.COUNT, true);
		renderers[TriangleRendererType.WIREFRAME] = new BasicWireframe();
		renderers[TriangleRendererType.FLAT] = new BasicFlat();
		renderers[TriangleRendererType.GOURAUD] = new BasicGouraud();
		renderers[TriangleRendererType.TEXTURE_FLAT] = new BasicTextureFlat();
		renderers[TriangleRendererType.TEXTURE_GOURAUD] = new BasicTextureGouraud();
		renderers[TriangleRendererType.TEXTURE_FLAT_NoZ] = new BasicSkyBox();
		renderers[TriangleRendererType.TEXTURE_LIGHTMAP] = new BasicTextureLightMap();
	}

	override public function setRenderState(state : Int) : Void
	{
		this.renderState = state;
		for (i in 0...TriangleRendererType.COUNT)
		{
			renderers[i].setRenderState(renderState);
		}
	}

	override public function clearZBuffer() : Void
	{
		depthBuffer.fixed = false;
		depthBuffer.length = 0;
		depthBuffer.length = screenSize.width * screenSize.height;
		depthBuffer.fixed = true;
	}

	override public function checkCurrentRender() : Void
	{
		var index:Int = 0;
		if (material.wireframe)
		{
			index = TriangleRendererType.WIREFRAME;
		}
		else if (hasTexture)
		{
			if (hasLightmap)
			{
				index = TriangleRendererType.TEXTURE_LIGHTMAP;
			}
			else if (lighting || gouraudShading)
			{
				index = TriangleRendererType.TEXTURE_GOURAUD;
			}
			else if (material.zBuffer)
			{
				index = TriangleRendererType.TEXTURE_FLAT;
			}
			else
			{
				index = TriangleRendererType.TEXTURE_FLAT_NoZ;
			}
		}
		else
		{
			if (gouraudShading)
			{
				index = TriangleRendererType.GOURAUD;
			}
			else
			{
				index = TriangleRendererType.FLAT;
			}
		}
		curRender = renderers[index];
		curRender.setMaterial(material);
	}

	override public function beginScene() : Void
	{
		trianglesDrawn = 0;

		targetVector.fixed = false;
		depthBuffer.fixed = false;
		targetVector.length = 0;
		depthBuffer.length = 0;
		var len : Int = screenSize.width * screenSize.height;
		targetVector.length = len;
		depthBuffer.length = len;
		targetVector.fixed = true;
		depthBuffer.fixed = true;
	}

	override public function endScene() : Void
	{
		target.bitmapData.lock();
		target.bitmapData.setVector(screenRect, targetVector);
		target.bitmapData.unlock();
	}

	override public function getBitmap() : Bitmap
	{
		return target;
	}

	override public function setScreenSize(size : Vector2i) : Void
	{
		super.setScreenSize(size);

		if (target.bitmapData != null)
		{
			target.bitmapData.dispose();
		}

		target.bitmapData = new BitmapData(screenSize.width, screenSize.height, true, 0);

		targetVector = new Vector<UInt>();
		depthBuffer = new Vector<Float>();
		var len : Int = screenSize.width * screenSize.height;
		targetVector.length = len;
		depthBuffer.length = len;
		targetVector.fixed = true;
		depthBuffer.fixed = true;

		setVector(targetVector, depthBuffer);
		setWidth(screenSize.width);
		setHeight(screenSize.height);
	}

	private var v0x : Float;
	private var v0y : Float;
	private var v0z : Float;
	private var v1x : Float;
	private var v1y : Float;
	private var v1z : Float;
	private var v2x : Float;
	private var v2y : Float;
	private var v2z : Float;
	private var v0 : Vertex;
	private var v1 : Vertex;
	private var v2 : Vertex;
	private var tv0 : Vertex4D;
	private var tv1 : Vertex4D;
	private var tv2 : Vertex4D;
	private var m11 : Float ;
	private var m21 : Float ;
	private var m31 : Float ;
	private var m41 : Float ;
	private var m12 : Float ;
	private var m22 : Float ;
	private var m32 : Float ;
	private var m42 : Float ;
	private var m13 : Float ;
	private var m23 : Float ;
	private var m33 : Float ;
	private var m43 : Float ;
	private var m14 : Float ;
	private var m24 : Float ;
	private var m34 : Float ;
	private var m44 : Float ;
	private var memi : Color ;
	private var mamb : Color ;
	private var mdif : Color ;
	private var globalR : Float ;
	private var globalG : Float ;
	private var globalB : Float ;
	override public function drawIndexedTriangleList(vertices : Vector<Vertex>, vertexCount : Int, indexList : Vector<Int>, triangleCount : Int) : Void
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
		//lighting
		var light : Light ;
		var pos : Vector3D ;
		var dir : Vector3D ;
		var lightLen : Int = getLightCount();
		var len : Int = triangleCount * 2;
		var _transformLen : Int = _transformedVertexes.length;
		if (_transformLen <len)
		{
			_transformedVertexes.fixed = false;
			for (i in _transformLen...len)
			{
				_transformedVertexes[i] = new Vertex4D();
			}
			_transformedVertexes.fixed = true;
		}
		tCount = 0;
		iCount = 0;
		vCount = 0;
		if (lighting)
		{
			// transfrom lights into object's world space
			for (i in 0...lightLen)
			{
				dir = _lightsDir[i];
				pos = _lightsPos[i];
				light = lights[i];
				var type : Int = light.type;
				if ((type == Light.SPOT) ||(type == Light.DIRECTIONAL))
				{
					var x : Float = light.direction.x;
					var y : Float = light.direction.y;
					var z : Float = light.direction.z;
					dir.x = x * _world_inv.m11 + y * _world_inv.m21 + z * _world_inv.m31;
					dir.y = x * _world_inv.m12 + y * _world_inv.m22 + z * _world_inv.m32;
					dir.z = x * _world_inv.m13 + y * _world_inv.m23 + z * _world_inv.m33;
					dir.normalize();
				}
				if ((type == Light.SPOT) ||(type == Light.POINT))
				{
					var x : Float = light.position.x;
					var y : Float = light.position.y;
					var z : Float = light.position.z;
					pos.x = _world_inv.m11 * x + _world_inv.m21 * y + _world_inv.m31 * z + _world_inv.m41;
					pos.y = _world_inv.m12 * x + _world_inv.m22 * y + _world_inv.m32 * z + _world_inv.m42;
					pos.z = _world_inv.m13 * x + _world_inv.m23 * y + _world_inv.m33 * z + _world_inv.m43;
				}
			}
		}

		m11  = _current.m11; m21  = _current.m21; m31  = _current.m31; m41  = _current.m41;
		m12  = _current.m12; m22  = _current.m22; m32  = _current.m32; m42  = _current.m42;
		m13  = _current.m13; m23  = _current.m23; m33  = _current.m33; m43  = _current.m43;
		m14  = _current.m14; m24  = _current.m24; m34  = _current.m34; m44  = _current.m44;
		memi  = material.emissiveColor;
		mamb  = material.ambientColor;
		mdif  = material.diffuseColor;
		globalR  =(ambientColor.r * mamb.r * MathUtil.Reciprocal255) + memi.r;
		globalG  =(ambientColor.g * mamb.g * MathUtil.Reciprocal255) + memi.g;
		globalB  =(ambientColor.b * mamb.b * MathUtil.Reciprocal255) + memi.b;

		var ii : Int = 0;
		while (ii <triangleCount )
		{
			v0 = vertices[indexList[ii]];
			v1 = vertices[indexList[ii + 1]];
			v2 = vertices[indexList[ii + 2]];
			ii += 3;

			v0x = v0.x; v0y = v0.y; v0z = v0.z;
			v1x = v1.x; v1y = v1.y; v1z = v1.z;
			v2x = v2.x; v2y = v2.y; v2z = v2.z;

			if (backfaceCulling || frontfaceCulling)
			{
				var t : Float =((v1y - v0y) *(v2z - v0z) -(v1z - v0z) *(v2y - v0y)) *(_invCamPos.x - v0x) +
							   ((v1z - v0z) *(v2x - v0x) -(v1x - v0x) *(v2z - v0z)) *(_invCamPos.y - v0y) +
							   ((v1x - v0x) *(v2y - v0y) -(v1y - v0y) *(v2x - v0x)) *(_invCamPos.z - v0z);
				if ((backfaceCulling && t <= 0) ||(frontfaceCulling && t> 0))
				{
					continue;
				}
			}

			tv0 = _transformedVertexes[tCount++];
			tv1 = _transformedVertexes[tCount++];
			tv2 = _transformedVertexes[tCount++];
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

			//lighting 在物体自身坐标计算
			if (lighting)
			{
				//初始化总体反射光照颜色
				var dif_r_sum0 : Float = 0.;
				var dif_g_sum0 : Float = 0.;
				var dif_b_sum0 : Float = 0.;
				var diffuse : Color;
				var dist : Float;
				var dist2 : Float;
				var dpsl : Float;
				var dp : Float;
				var radius : Float;
				var k : Float;
				if ( ! gouraudShading) //flat Light
				{
					for (j in 0...lightLen)
					{
						light = lights[j];
						diffuse = light.diffuseColor;
						//l=v1.subtract(v0);
						_light_L.x = v1x - v0x;
						_light_L.y = v1y - v0y;
						_light_L.z = v1z - v0z;
						//v=v2.subtract(v0);
						_light_V.x = v2x - v0x;
						_light_V.y = v2y - v0y;
						_light_V.z = v2z - v0z;
						//三角形法线
						//n=l.cross(v);
						_light_N.x = _light_L.y * _light_V.z - _light_L.z * _light_V.y;
						_light_N.y = _light_L.z * _light_V.x - _light_L.x * _light_V.z;
						_light_N.z = _light_L.x * _light_V.y - _light_L.y * _light_V.x;
						//法线长度
						var nlenSquared : Float = _light_N.lengthSquared;
						if (light.type == 0) //DIRECTIONAL
						{
							dir = _lightsDir[j];
							dp =(_light_N.x * dir.x + _light_N.y * dir.y + _light_N.z * dir.z) * MathUtil.invSqrt(nlenSquared);
							if (dp> 0)
							{
								dif_r_sum0 += diffuse.r * dp;
								dif_g_sum0 += diffuse.g * dp;
								dif_b_sum0 += diffuse.b * dp;
							}
						}
						else if (light.type == 1)  //POINT
						{
							pos = _lightsPos[j];
							_light_L.x = pos.x - v0x;
							_light_L.y = pos.y - v0y;
							_light_L.z = pos.z - v0z;
							dp =(_light_N.x * _light_L.x + _light_N.y * _light_L.y + _light_N.z * _light_L.z);
							dist2 = _light_L.lengthSquared;
							dist = MathUtil.sqrt(dist2);
							if (dp> 0 && dist <light.radius)
							{
								k = dp * MathUtil.invSqrt(nlenSquared) /((light.kc + light.kl * dist + light.kq * dist2) * dist);
								dif_r_sum0 += diffuse.r * k;
								dif_g_sum0 += diffuse.g * k;
								dif_b_sum0 += diffuse.b * k;
							}
						} //SPOT
						else
						{
							pos = _lightsPos[j];
							dir = _lightsDir[j];
							_light_L.x = pos.x - v0x;
							_light_L.y = pos.y - v0y;
							_light_L.z = pos.z - v0z;
							dp = _light_N.dotProduct(dir);
							dist2 = _light_L.lengthSquared;
							dist = MathUtil.sqrt(dist2);
							if (dp> 0 && dist <light.radius)
							{
								dpsl = _light_L.dotProduct(dir) / dist;
								if (dpsl> 0 )
								{
									k = dp * Math.pow(dpsl, light.powerFactor) * MathUtil.invSqrt(nlenSquared) /(light.kc + light.kl * dist + light.kq * dist2);
									dif_r_sum0 += diffuse.r * k;
									dif_g_sum0 += diffuse.g * k;
									dif_b_sum0 += diffuse.b * k;
								}
							}
						}
					}
					tv0.r = globalR +(dif_r_sum0 * mdif.r * MathUtil.Reciprocal255);
					tv0.g = globalG +(dif_g_sum0 * mdif.g * MathUtil.Reciprocal255);
					tv0.b = globalB +(dif_b_sum0 * mdif.b * MathUtil.Reciprocal255);
					tv1.r = tv0.r;
					tv1.g = tv0.g;
					tv1.b = tv0.b;
					tv2.r = tv0.r;
					tv2.g = tv0.g;
					tv2.b = tv0.b;
				}
				else
				{
					var dif_r_sum1 : Float = 0.;
					var dif_g_sum1 : Float = 0.;
					var dif_b_sum1 : Float = 0.;
					var dif_r_sum2 : Float = 0.;
					var dif_g_sum2 : Float = 0.;
					var dif_b_sum2 : Float = 0.;
					for (j in 0...lightLen)
					{
						light = lights[j];
						diffuse = light.diffuseColor;
						radius = light.radius;
						if (light.type == 0) //DIRECTIONAL
						{
							dir = _lightsDir[j];
							//tv0
							dp =(v0.nx * dir.x + v0.ny * dir.y + v0.nz * dir.z);
							if (dp> 0)
							{
								dif_r_sum0 += diffuse.r * dp;
								dif_g_sum0 += diffuse.g * dp;
								dif_b_sum0 += diffuse.b * dp;
							}
							//tv1
							dp =(v1.nx * dir.x + v1.ny * dir.y + v1.nz * dir.z);
							if (dp> 0)
							{
								dif_r_sum1 += diffuse.r * dp;
								dif_g_sum1 += diffuse.g * dp;
								dif_b_sum1 += diffuse.b * dp;
							}
							//tv2
							dp =(v2.nx * dir.x + v2.ny * dir.y + v2.nz * dir.z);
							if (dp> 0)
							{
								dif_r_sum2 += diffuse.r * dp;
								dif_g_sum2 += diffuse.g * dp;
								dif_b_sum2 += diffuse.b * dp;
							}
						}
						else if (light.type == 1) //POINT
						{
							var kc : Float = light.kc;
							var kl : Float = light.kl;
							var kq : Float = light.kq;
							pos = _lightsPos[j];
							//              I0point * Clpoint
							//  I(d)point = ___________________
							//              kc +  kl*d + kq*d2
							//
							//  Where d = |p - s|
							_light_L.x = pos.x - v0x;
							_light_L.y = pos.y - v0y;
							_light_L.z = pos.z - v0z;
							//tv0
							dp =(v0.nx * _light_L.x + v0.ny * _light_L.y + v0.nz * _light_L.z);
							dist2 = _light_L.lengthSquared;
							dist = MathUtil.sqrt(dist2);
							if (dp> 0 && dist <radius)
							{
								k = dp /(dist *(kc + kl * dist + kq * dist2));
								dif_r_sum0 += diffuse.r * k;
								dif_g_sum0 += diffuse.g * k;
								dif_b_sum0 += diffuse.b * k;
							}
							//tv1
							_light_L.x = pos.x - v1x;
							_light_L.y = pos.y - v1y;
							_light_L.z = pos.z - v1z;
							dp =(v1.nx * _light_L.x + v1.ny * _light_L.y + v1.nz * _light_L.z);
							dist2 = _light_L.lengthSquared;
							dist = MathUtil.sqrt(dist2);
							if (dp> 0 && dist <radius)
							{
								k = dp /(dist *(kc + kl * dist + kq * dist2));
								dif_r_sum1 += diffuse.r * k;
								dif_g_sum1 += diffuse.g * k;
								dif_b_sum1 += diffuse.b * k;
							}
							//tv2
							_light_L.x = pos.x - v2x;
							_light_L.y = pos.y - v2y;
							_light_L.z = pos.z - v2z;
							dp =(v2.nx * _light_L.x + v2.ny * _light_L.y + v2.nz * _light_L.z);
							dist2 = _light_L.lengthSquared;
							dist = MathUtil.sqrt(dist2);
							if (dp> 0 && dist <radius)
							{
								k = dp /(dist *(kc + kl * dist + kq * dist2));
								dif_r_sum2 += diffuse.r * k;
								dif_g_sum2 += diffuse.g * k;
								dif_b_sum2 += diffuse.b * k;
							}
						} //SPOT
						else
						{
							var kc : Float = light.kc;
							var kl : Float = light.kl;
							var kq : Float = light.kq;
							var pf : Int = light.powerFactor;
							dir = _lightsDir[j];
							pos = _lightsPos[j];
							//         	     I0spotlight * Clspotlight * MAX((l . s), 0)^pf
							// I(d)spotlight = __________________________________________
							//               		 kc + kl*d + kq*d2
							// Where d = |p - s|, and pf = power factor
							//tv0
							_light_L.x = pos.x - v0x;
							_light_L.y = pos.y - v0y;
							_light_L.z = pos.z - v0z;
							dp =(v0.nx * dir.x + v0.ny * dir.y + v0.nz * dir.z);
							dist2 = _light_L.lengthSquared;
							dist = MathUtil.sqrt(dist2);
							if (dp> 0 && dist <radius)
							{
								dpsl =(_light_L.x * dir.x + _light_L.y * dir.y + _light_L.z * dir.z) / dist;
								if (dpsl> 0 )
								{
									k = dp * Math.pow(dpsl, pf) /(kc + kl * dist + kq * dist2);
									dif_r_sum0 += diffuse.r * k;
									dif_g_sum0 += diffuse.g * k;
									dif_b_sum0 += diffuse.b * k;
								}
							}
							//tv1
							_light_L.x = pos.x - v1x;
							_light_L.y = pos.y - v1y;
							_light_L.z = pos.z - v1z;
							dp =(v1.nx * dir.x + v1.ny * dir.y + v1.nz * dir.z);
							dist2 = _light_L.lengthSquared;
							dist = MathUtil.sqrt(dist2);
							if (dp> 0 && dist <radius)
							{
								dpsl =(_light_L.x * dir.x + _light_L.y * dir.y + _light_L.z * dir.z) / dist;
								if (dpsl> 0 )
								{
									k = dp * Math.pow(dpsl, pf) /(kc + kl * dist + kq * dist2);
									dif_r_sum1 += diffuse.r * k;
									dif_g_sum1 += diffuse.g * k;
									dif_b_sum1 += diffuse.b * k;
								}
							}
							//tv2
							_light_L.x = pos.x - v2x;
							_light_L.y = pos.y - v2y;
							_light_L.z = pos.z - v2z;
							dp =(v2.nx * dir.x + v2.ny * dir.y + v2.nz * dir.z);
							dist2 = _light_L.lengthSquared;
							dist = MathUtil.sqrt(dist2);
							if (dp> 0 && dist <radius)
							{
								dpsl =(_light_L.x * dir.x + _light_L.y * dir.y + _light_L.z * dir.z) / dist;
								if (dpsl> 0 )
								{
									k = dp * Math.pow(dpsl, pf) /(kc + kl * dist + kq * dist2);
									dif_r_sum2 += diffuse.r * k;
									dif_g_sum2 += diffuse.g * k;
									dif_b_sum2 += diffuse.b * k;
								}
							}
						}
					}
					tv0.r = globalR +(dif_r_sum0 * mdif.r * MathUtil.Reciprocal255);
					tv0.g = globalG +(dif_g_sum0 * mdif.g * MathUtil.Reciprocal255);
					tv0.b = globalB +(dif_b_sum0 * mdif.b * MathUtil.Reciprocal255);
					tv1.r = globalR +(dif_r_sum1 * mdif.r * MathUtil.Reciprocal255);
					tv1.g = globalG +(dif_g_sum1 * mdif.g * MathUtil.Reciprocal255);
					tv1.b = globalB +(dif_b_sum1 * mdif.b * MathUtil.Reciprocal255);
					tv2.r = globalR +(dif_r_sum2 * mdif.r * MathUtil.Reciprocal255);
					tv2.g = globalG +(dif_g_sum2 * mdif.g * MathUtil.Reciprocal255);
					tv2.b = globalB +(dif_b_sum2 * mdif.b * MathUtil.Reciprocal255);
				}
				if (tv0.r> 255) tv0.r = 255;
				if (tv0.g> 255) tv0.g = 255;
				if (tv0.b> 255) tv0.b = 255;
				if (tv1.r> 255) tv1.r = 255;
				if (tv1.g> 255) tv1.g = 255;
				if (tv1.b> 255) tv1.b = 255;
				if (tv2.r> 255) tv2.r = 255;
				if (tv2.g> 255) tv2.g = 255;
				if (tv2.b> 255) tv2.b = 255;
			}
			else if (this.gouraudShading || !hasTexture) //no lighting
			{
				tv0.r = v0.r + memi.r;
				tv0.g = v0.g + memi.g;
				tv0.b = v0.b + memi.b;
				tv1.r = v1.r + memi.r;
				tv1.g = v1.g + memi.g;
				tv1.b = v1.b + memi.b;
				tv2.r = v2.r + memi.r;
				tv2.g = v2.g + memi.g;
				tv2.b = v2.b + memi.b;
				if (tv0.r> 255) tv0.r = 255;
				if (tv0.g> 255) tv0.g = 255;
				if (tv0.b> 255) tv0.b = 255;
				if (tv1.r> 255) tv1.r = 255;
				if (tv1.g> 255) tv1.g = 255;
				if (tv1.b> 255) tv1.b = 255;
				if (tv2.r> 255) tv2.r = 255;
				if (tv2.g> 255) tv2.g = 255;
				if (tv2.b> 255) tv2.b = 255;
			}

			// texture coords
			if (hasTexture)
			{
				tv0.u = v0.u ;
				tv0.v = v0.v ;
				tv1.u = v1.u ;
				tv1.v = v1.v ;
				tv2.u = v2.u ;
				tv2.v = v2.v ;
				if (hasLightmap) //lightmap
				{
					tv0.u2 = v0.u2 ;
					tv0.v2 = v0.v2 ;
					tv1.u2 = v1.u2 ;
					tv1.v2 = v1.v2 ;
					tv2.u2 = v2.u2 ;
					tv2.v2 = v2.v2 ;
				}
			}

			if (clipcount == 0) // no clipping required
			{
				//tv0
				var tmp:Float = 1 / tv0.w;
				tv0.x = tv0.x * _scale_m11 * tmp + _scale_m41;
				tv0.y = tv0.y * _scale_m22 * tmp + _scale_m42;
				tv0.z = tmp ;

				//tv1
				tmp = 1 / tv1.w;
				tv1.x = tv1.x * _scale_m11 * tmp + _scale_m41;
				tv1.y = tv1.y * _scale_m22 * tmp + _scale_m42;
				tv1.z = tmp ;

				//tv2
				tmp = 1 / tv2.w;
				tv2.x = tv2.x * _scale_m11 * tmp + _scale_m41;
				tv2.y = tv2.y * _scale_m22 * tmp + _scale_m42;
				tv2.z = tmp;

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
				//plane = _clipPlanes[1];
				b = source[0];
				//bdot = b.z * plane.z + b.w * plane.w;
				bdot = - b.z - b.w;
				var i : Int = 1;
				while (i <= inCount)
				{
					a = source[i % inCount];
					i ++;
					//adot = a.z * plane.z + a.w * plane.w;
					adot = - a.z - a.w;
					// current point inside
					if (adot <= 0.0 )
					{
						// last point outside
						if (bdot> 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices4[outCount ++] = out;
							//t = bdot /((b.z - a.z) * plane.z +(b.w - a.w) * plane.w);
							t = bdot /( -(b.z - a.z) -(b.w - a.w));
							out.interpolate(a, b, t, hasTexture,hasLightmap);
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
							//t = bdot /((b.z - a.z) * plane.z +(b.w - a.w) * plane.w);
							t = bdot /( -(b.z - a.z) -(b.w - a.w));
							out.interpolate(a, b, t, hasTexture,hasLightmap);
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
				//plane = _clipPlanes[2];
				b = source[0];
				//bdot = b.x * plane.x + b.w * plane.w;
				bdot = b.x - b.w ;
				var i : Int = 1;
				while (i <= inCount)
				{
					a = source[i % inCount];
					i ++;
					//adot = a.x * plane.x + a.w * plane.w;
					adot = a.x - a.w;
					if (adot <= 0.0 )
					{
						if (bdot> 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices3[outCount ++] = out;
							//t = bdot /((b.x - a.x) * plane.x +(b.w - a.w) * plane.w);
							t = bdot /((b.x - a.x) -(b.w - a.w));
							out.interpolate(a, b, t, hasTexture,hasLightmap);
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
							//t = bdot /((b.x - a.x) * plane.x +(b.w - a.w) * plane.w);
							t = bdot /((b.x - a.x) -(b.w - a.w));
							out.interpolate(a, b, t, hasTexture,hasLightmap);
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
				//plane = _clipPlanes[3];
				b = source[0];
				//bdot = b.x * plane.x + b.w * plane.w;
				bdot = - b.x - b.w;
				var i : Int = 1;
				while (i <= inCount)
				{
					a = source[i % inCount];
					i ++;
					//adot = a.x * plane.x + a.w * plane.w;
					adot = - a.x - a.w;
					if (adot <= 0.0 )
					{
						if (bdot> 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices2[outCount ++] = out;
							//t = bdot /((b.x - a.x) * plane.x +(b.w - a.w) * plane.w);
							t = bdot /( -(b.x - a.x) -(b.w - a.w));
							out.interpolate(a, b, t, hasTexture,hasLightmap);
						}
						_clippedVertices2[outCount ++] = a;
					}
					else
					{
						if (bdot <= 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices2[outCount ++] = out;
							//t = bdot /((b.x - a.x) * plane.x +(b.w - a.w) * plane.w);
							t = bdot /( -(b.x - a.x) -(b.w - a.w));
							out.interpolate(a, b, t, hasTexture,hasLightmap);
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
				//plane = _clipPlanes[4];
				b = source[0];
				//bdot = b.y * plane.y + b.w * plane.w;
				bdot = b.y - b.w ;
				var i : Int = 1;
				while (i <= inCount)
				{
					a = source[i % inCount];
					i ++;
					//adot = a.y * plane.y + a.w * plane.w;
					adot = a.y - a.w;
					if (adot <= 0.0 )
					{
						if (bdot> 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices1[outCount ++] = out;
							//t = bdot /((b.y - a.y) * plane.y +(b.w - a.w) * plane.w);
							t = bdot /((b.y - a.y) -(b.w - a.w));
							out.interpolate(a, b, t, hasTexture,hasLightmap);
						}
						_clippedVertices1[outCount ++] = a;
					}
					else
					{
						if (bdot <= 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices1[outCount ++] = out;
							//t = bdot /((b.y - a.y) * plane.y +(b.w - a.w) * plane.w);
							t = bdot /((b.y - a.y) -(b.w - a.w));
							out.interpolate(a, b, t, hasTexture,hasLightmap);
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
				//plane = _clipPlanes[5];
				b = source[0];
				//bdot = b.y * plane.y + b.w * plane.w;
				bdot = - b.y - b.w;
				var i : Int = 1;
				while (i <= inCount)
				{
					a = source[i % inCount];
					i ++;
					//adot = a.y * plane.y + a.w * plane.w;
					adot = - a.y - a.w ;
					if (adot <= 0.0 )
					{
						if (bdot> 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices0[outCount ++] = out;
							//t = bdot /((b.y - a.y) * plane.y +(b.w - a.w) * plane.w);
							t = bdot /( -(b.y - a.y) -(b.w - a.w));
							out.interpolate(a, b, t, hasTexture,hasLightmap);
						}
						_clippedVertices0[outCount ++] = a;
					}
					else
					{
						if (bdot <= 0.0 )
						{
							out = _transformedVertexes[tCount ++];
							_clippedVertices0[outCount ++] = out;
							//t = bdot /((b.y - a.y) * plane.y +(b.w - a.w) * plane.w);
							t = bdot /( -(b.y - a.y) -(b.w - a.w));
							out.interpolate(a, b, t, hasTexture,hasLightmap);
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
				var tmp:Float = 1 / tv0.w;
				tv0.x = tv0.x * _scale_m11 * tmp + _scale_m41;
				tv0.y = tv0.y * _scale_m22 * tmp + _scale_m42;
				tv0.z = tmp ;
				_clippedVertices[vCount ++] = tv0;
			}
			// re-tesselate( triangle-fan, 0-1-2,0-2-3.. )
			var c:Int =(outCount - 2);
			for (g in 0... c)
			{
				_clippedIndices[iCount++] = vCount2;
				_clippedIndices[iCount++] = vCount2 + g + 1;
				_clippedIndices[iCount++] = vCount2 + g + 2;
			}
		}
		trianglesDrawn += Std.int(iCount/3);
		curRender.drawIndexedTriangleList(_clippedVertices, vCount, _clippedIndices, iCount);
	}

	override public function getDriverType() : Int
	{
		return VideoDriverType.BASIC;
	}

	override public function createScreenShot() : BitmapData
	{
		return getBitmap().bitmapData.clone();
	}

	override public function setPerspectiveCorrectDistance(distance : Float = 400.) : Void
	{
		persDistance = (distance < 10) ? 10 : distance;
		for (i in 0...TriangleRendererType.COUNT)
		{
			renderers[i].setPerspectiveCorrectDistance(distance);
		}
	}

	override public function setMipMapDistance(distance : Float = 500.) : Void
	{
		mipMapDistance =(distance <10) ? 10 : distance;
		for (i in 0...TriangleRendererType.COUNT)
		{
			renderers[i].setMipMapDistance(distance);
		}
	}

	private function setWidth(width : Int) : Void
	{
		for (i in 0...TriangleRendererType.COUNT)
		{
			renderers[i].setWidth(width);
		}
	}

	private function setHeight(height : Int) : Void
	{
		for (i in 0...TriangleRendererType.COUNT)
		{
			renderers[i].setHeight(height);
		}
	}

	private function setVector(tv : Vector<UInt>, bv : Vector<Float>) : Void
	{
		for (i in 0...TriangleRendererType.COUNT)
		{
			renderers[i].setVector(tv, bv);
		}
	}

	override public function setDistance(distance : Float) : Void
	{
		if (curRender != null) curRender.setDistance(distance);
	}

	override public function canShadow() : Bool
	{
		return false;
	}
}
