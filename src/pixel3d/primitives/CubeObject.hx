package pixel3d.primitives;
import flash.geom.Vector3D;
import flash.Lib;
import flash.Vector;
import pixel3d.math.AABBox;
import pixel3d.math.Vertex;
import flash.geom.Vector3D;
import pixel3d.math.Vertex;
import pixel3d.math.MathUtil;
import pixel3d.mesh.Mesh;
import pixel3d.mesh.IMesh;
import pixel3d.mesh.MeshBuffer;
import pixel3d.mesh.MeshManipulator;
import pixel3d.utils.Logger;
class CubeObject extends MeshBuffer
{
	public var color : UInt;
	/**
	*
	* @param	len    x
	* @param	height y
	* @param	width  z
	*/
	public function new(width : Float = 100., height : Float = 100., depth : Float = 100.)
	{
		super();
		color = 0x0;
		indices = Vector.ofArray([0, 2, 1, 0, 3, 2, 1, 5, 4, 1, 2, 5, 4, 6, 7, 4, 5, 6,
								  7, 3, 0, 7, 6, 3, 9, 5, 2, 9, 8, 5, 0, 11, 10, 0, 10, 7]);
		vertices[0] = new Vertex(0, 0, 0, - 1, - 1, - 1, color, 0, 1);
		vertices[1] = new Vertex(1, 0, 0, 1, - 1, - 1, color, 1, 1);
		vertices[2] = new Vertex(1, 1, 0, 1, 1, - 1, color, 1, 0);
		vertices[3] = new Vertex(0, 1, 0, - 1, 1, - 1, color, 0, 0);
		vertices[4] = new Vertex(1, 0, 1, 1, - 1, 1, color, 0, 1);
		vertices[5] = new Vertex(1, 1, 1, 1, 1, 1, color, 0, 0);
		vertices[6] = new Vertex(0, 1, 1, - 1, 1, 1, color, 1, 0);
		vertices[7] = new Vertex(0, 0, 1, - 1, - 1, 1, color, 1, 1);
		vertices[8] = new Vertex(0, 1, 1, - 1, 1, 1, color, 0, 1);
		vertices[9] = new Vertex(0, 1, 0, - 1, 1, - 1, color, 1, 1);
		vertices[10] = new Vertex(1, 0, 1, 1, - 1, 1, color, 1, 0);
		vertices[11] = new Vertex(1, 0, 0, 1, - 1, - 1, color, 0, 0);
		vertices[0].u2 = 0; vertices[0].v2 = 1;
		vertices[1].u2 = 1; vertices[1].v2 = 1;
		vertices[2].u2 = 1; vertices[2].v2 = 0;
		vertices[3].u2 = 0; vertices[3].v2 = 0;
		vertices[4].u2 = 0; vertices[4].v2 = 1;
		vertices[5].u2 = 0; vertices[5].v2 = 0;
		vertices[6].u2 = 1; vertices[6].v2 = 0;
		vertices[7].u2 = 1; vertices[7].v2 = 1;
		vertices[8].u2 = 0; vertices[8].v2 = 1;
		vertices[9].u2 = 1; vertices[9].v2 = 1;
		vertices[10].u2 = 1; vertices[10].v2 = 0;
		vertices[11].u2 = 0; vertices[11].v2 = 0;
		build(width, height, depth);
	}

	public function build(width : Float, height : Float, depth : Float) : Void
	{
		vertices[0].setTo(0, 0, 0);
		vertices[1].setTo(1, 0, 0);
		vertices[2].setTo(1, 1, 0);
		vertices[3].setTo(0, 1, 0);
		vertices[4].setTo(1, 0, 1);
		vertices[5].setTo(1, 1, 1);
		vertices[6].setTo(0, 1, 1);
		vertices[7].setTo(0, 0, 1);
		vertices[8].setTo(0, 1, 1);
		vertices[9].setTo(0, 1, 0);
		vertices[10].setTo(1, 0, 1);
		vertices[11].setTo(1, 0, 0);
		for (i in 0...12)
		{
			var vertex : Vertex = vertices[i];
			vertex.x -= 0.5;
			vertex.y -= 0.5;
			vertex.z -= 0.5;
			vertex.x *= width;
			vertex.y *= height;
			vertex.z *= depth;
		}

		recalculateBoundingBox();
	}

	/**
	* @param	colors Vector<UInt> colors.length>=12
	*/
	public inline function setColors(colors : Vector<UInt>) : Void
	{
		if (colors.length <12) return;
		for (i in 0...12)
		{
			vertices[i].color = colors[i];
		}
	}

	public inline function setColor(color : UInt) : Void
	{
		this.color = color;
		for (i in 0...12)
		{
			vertices[i].color = color;
		}
	}

	public function setBox(aabb : AABBox) : Void
	{
		aabb.repair();
		build(MathUtil.abs(aabb.maxX - aabb.minX), MathUtil.abs(aabb.maxY - aabb.minY), MathUtil.abs(aabb.maxZ - aabb.minZ));
		MeshManipulator.translateBuffer(this, aabb.getCenter());
	}
}
