package pixel3d.mesh;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import pixel3d.math.Color;
import pixel3d.math.Vertex;
import pixel3d.math.Vector2i;
import flash.geom.Vector3D;
import pixel3d.math.Vector2f;
import pixel3d.math.MathUtil;
import pixel3d.math.Plane3D;
import pixel3d.mesh.IMesh;
import pixel3d.mesh.MeshBuffer;
import pixel3d.mesh.Mesh;
import pixel3d.material.Material;
import flash.Vector;
class GeometryCreator
{
	/**
	*
	* @param	tileWidth
	* @param	tileHeight
	* @param	tileXCount
	* @param	tileYCount
	* @param	hillHeight
	* @param	hillXCount
	* @param	hillYCount
	* @param	textureRepeatX
	* @param	textureRepeatY
	* @return
	*/
	public static function createHillPlane(tileWidth : Float, tileHeight : Float, 
	                                        tileXCount : Int, tileYCount : Int,
	                                        hillHeight : Float, hillXCount : Int, hillYCount : Int, 
											textureRepeatX : Int, textureRepeatY : Int) : MeshBuffer
	{
		if(hillHeight == 0) hillHeight = 1.0;
		if(hillXCount <0) hillXCount = 1;
		if(hillYCount <0) hillYCount = 1;
		// center
		var centerX : Float =(tileWidth * tileXCount) / 2.0;
		var centerY : Float =(tileHeight * tileYCount) / 2.0;
		// texture coord step
		var texPx : Float = textureRepeatX / tileXCount;
		var texPy : Float = textureRepeatY / tileYCount;
		// add one more point in each direction for proper tile count
		tileYCount ++;
		tileXCount ++;
		var buffer : MeshBuffer = new MeshBuffer();
		var vertices : flash.Vector<Vertex>= buffer.getVertices();
		var indices : flash.Vector<Int>= buffer.getIndices();
		var PI : Float = MathUtil.PI;
		var tmpHillHeight : Float = hillHeight;
		// create vertices from left-front to right-back
		var sx : Float = 0;
		var tsx : Float = 0;
		var sy : Float = 0.0;
		var tsy : Float = 0.;
		for(x in 0...tileXCount)
		{
			sy = 0.0;
			tsy = 0.;
			for(y in 0...tileYCount)
			{
				var vtx : Vertex = new Vertex();
				vtx.color = Std.int(Math.random() * 0xFFFFFF);
				vtx.x = sx - centerX;
				vtx.z = sy - centerY;
				vtx.y =(Math.sin(vtx.x * hillXCount * PI / centerX) * Math.cos(vtx.z * hillYCount * PI / centerY)) * hillHeight;
				if(tsx> 1)
				{
					vtx.u = tsx - Std.int(tsx);
				} else 
				{
					vtx.u = tsx;
				}
				if((1 - tsy) <0)
				{
					vtx.v = MathUtil.abs(1 - tsy - Std.int(1 - tsy));
				} else 
				{
					vtx.v = 1 - tsy;
				}
				vertices.push(vtx);
				sy += tileHeight;
				tsy += texPy;
			}
			sx += tileWidth;
			tsx += texPx;
		}
		// create indices
		for(x in 0...(tileXCount - 1))
		{
			for(y in 0...(tileYCount - 1))
			{
				var current : Int = x * tileYCount + y;
				indices.push(current);
				indices.push(current + 1);
				indices.push(current + tileYCount);
				indices.push(current + 1);
				indices.push(current + 1 + tileYCount);
				indices.push(current + tileYCount);
			}
		}
		MeshManipulator.recalculateBufferNormals(buffer, true, true);
		buffer.recalculateBoundingBox();
		return buffer;
	}
	/**
	*
	* @param	heightMap
	* @param	stretchSize
	* @param	maxHeight
	* @param	maxVtxBlockSize
	* @param	debugBorders
	* @return
	*/
	public static function createTerrainMesh(heightMap : BitmapData, stretchSize : Vector2i, maxHeight : Float, maxVtxBlockSize : Vector2i, debugBorders : Bool) : Mesh
	{
		if(heightMap == null) return null;
		var borderSkip = debugBorders ? 0 : 1;
		var vtx : Vertex;
		var mesh : Mesh = new Mesh();
		var hMapSize : Rectangle = heightMap.rect;
		maxHeight /= 255.0;
		// height step per color value
		var color : Color = new Color();
		var processed : Vector2f = new Vector2f();
		while(processed.y <hMapSize.height)
		{
			while(processed.x <hMapSize.width)
			{
				var blockSize : Vector2i = maxVtxBlockSize.clone();
				if(processed.x + blockSize.width> hMapSize.width)
				blockSize.width = Std.int(hMapSize.width - processed.x);
				if(processed.y + blockSize.height> hMapSize.height)
				blockSize.height = Std.int(hMapSize.height - processed.y);
				var buffer : MeshBuffer = new MeshBuffer();
				var indices : Vector<Int>= buffer.getIndices();
				var vertices : Vector<Vertex>= buffer.getVertices();
				// add vertices of vertex block
				var pos : Vector2f = new Vector2f(0., processed.y * stretchSize.height);
				var bs : Vector2f = new Vector2f(1. / blockSize.width, 1. / blockSize.height);
				var tc : Vector2f = new Vector2f(0., 0.5 * bs.y);
				for(y in 0...blockSize.height)
				{
					pos.x = processed.x * stretchSize.width;
					tc.x = 0.5 * bs.x;
					for(x in 0...blockSize.width)
					{
						color.color = (heightMap.getPixel(Std.int(x + processed.x) , Std.int(y + processed.y)));
						var height : Float = color.getAverage() * maxHeight;
						vtx = new Vertex();
						vtx.color = (0xFFFFFFFF);
						vtx.x = pos.x;
						vtx.y = height;
						vtx.z = pos.y;
						vtx.u = tc.x;
						vtx.v = tc.y;
						vertices.push(vtx);
						pos.x += stretchSize.width;
						tc.x += bs.x;
					}
					pos.y += stretchSize.height;
					tc.y += bs.y;
				}
				//buffer.indices.reallocate((blockSize.height-1)*(blockSize.width-1)*6);
				// add indices of vertex block
				var c1 : Int = 0;
				for(y in 0...(blockSize.height - 1))
				{
					for(x in 0...(blockSize.width - 1))
					{
						var c : Int = c1 + x;
						indices.push(c);
						indices.push(c + blockSize.width);
						indices.push(c + 1);
						indices.push(c + 1);
						indices.push(c + blockSize.width);
						indices.push(c + 1 + blockSize.width);
					}
					c1 += blockSize.width;
				}
				MeshManipulator.recalculateBufferNormals(buffer, true, true);
				buffer.recalculateBoundingBox();
				mesh.addMeshBuffer(buffer);
				// keep on processing
				processed.x += maxVtxBlockSize.width - borderSkip;
			}
			// keep on processing
			processed.x = 0;
			processed.y += maxVtxBlockSize.height - borderSkip;
		}
		mesh.recalculateBoundingBox();
		return mesh;
	}
}
