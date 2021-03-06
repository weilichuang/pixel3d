﻿package pixel3d.primitives;
import flash.Vector;
import flash.geom.Point;
import pixel3d.math.MathUtil;
import pixel3d.math.Vertex;
import pixel3d.mesh.MeshBuffer;
import pixel3d.mesh.MeshManipulator;
class CylinderObject extends MeshBuffer
{
	public function new(radius : Float = 100, length : Float = 100, tesselation : Int = 5, closeTop : Bool = false, oblique : Float = 0)
	{
		super();
		build(radius, length, tesselation, closeTop, oblique);
	}
	public inline function build(radius : Float, length : Float, tesselation : Int, closeTop : Bool, oblique : Float) : Void
	{
		vertices.length = 0;
		indices.length = 0;
		var recTesselation : Float = 1 / tesselation;
		var recTesselationHalf : Float = recTesselation * 0.5;
		var angleStep : Float = MathUtil.TWO_PI * recTesselation;
		var angleStepHalf : Float = angleStep * 0.5;
		//vertices.length =(tesselation * 4 +(closeTop?2:1));
		//indices.length  =(tesselation * 2) *(closeTop?12:9);
		var tcx : Float = 0.;

		var sin = Math.sin;
		var cos = Math.cos;
		var i : Int = 0;
		var vertex : Vertex;
		var vertex1 : Vertex;
		while (i != tesselation)
		{
			var angle : Float = angleStep * i;
			vertex = new Vertex();
			vertex.x = radius * cos(angle);
			vertex.y = 0.;
			vertex.z = radius * sin(angle);
			vertex.nx = vertex.x;
			vertex.ny = vertex.y;
			vertex.nz = vertex.z;
			vertex.normalize();
			vertex.u = tcx;
			vertex.v = 0.;
			vertices.push(vertex);
			vertex1 = new Vertex();
			vertex1.x = vertex.x + oblique;
			vertex1.y = length;
			vertex1.z = vertex.z;
			vertex1.nx = vertex1.x;
			vertex1.ny = vertex1.y;
			vertex1.nz = vertex1.z;
			vertex1.normalize();
			vertex1.u = vertex.u;
			vertex1.v = 1.;
			vertices.push(vertex1);
			vertex = new Vertex();
			vertex.x = radius * cos(angle + angleStepHalf);
			vertex.y = 0.;
			vertex.z = radius * sin(angle + angleStepHalf);
			vertex.nx = vertex.x;
			vertex.ny = vertex.y;
			vertex.nz = vertex.z;
			vertex.normalize();
			vertex.u = tcx + recTesselationHalf;
			vertex.v = 0.;
			vertices.push(vertex);
			vertex1 = new Vertex();
			vertex1.x = vertex.x + oblique;
			vertex1.y = length;
			vertex1.z = vertex.z;
			vertex1.nx = vertex1.x;
			vertex1.ny = vertex1.y;
			vertex1.nz = vertex1.z;
			vertex1.normalize();
			vertex1.u = vertex.u;
			vertex1.v = 1.;
			vertices.push(vertex1);
			tcx += recTesselation;
			i ++;
		}
		var nonWrappedSize : Float =(tesselation * 4 ) - 2;
		i = 0;
		while (i != nonWrappedSize)
		{
			indices.push(i + 2 );
			indices.push(i + 0 );
			indices.push(i + 1 );
			indices.push(i + 2 );
			indices.push(i + 1 );
			indices.push(i + 3 );
			i += 2;
		}
		indices.push(0 );
		indices.push(i + 0 );
		indices.push(i + 1 );
		indices.push(0 );
		indices.push(i + 1 );
		indices.push(1 );
		// close down
		vertex = new Vertex();
		vertex.x = 0;
		vertex.y = 0;
		vertex.z = 0.;
		vertex.nx = 0.;
		vertex.ny = - 1.;
		vertex.nz = 0.;
		vertex.u = 1.;
		vertex.v = 1.;
		vertices.push(vertex );
		var index : Int = vertices.length - 1;
		i = 0;
		while (i != nonWrappedSize)
		{
			indices.push(index );
			indices.push(i + 0 );
			indices.push(i + 2 );
			i += 2;
		}
		indices.push(index );
		indices.push(i + 0 );
		indices.push(0 );
		if (closeTop)
		{
			// close top
			vertex = new Vertex();
			vertex.x = oblique;
			vertex.y = length;
			vertex.z = 0.;
			vertex.nx = 0.;
			vertex.ny = 1.;
			vertex.nz = 0.;
			vertex.u = 0.;
			vertex.v = 0.;
			vertices.push(vertex );
			index = vertices.length - 1;
			i = 0;
			while (i != nonWrappedSize)
			{
				indices.push(i + 1 );
				indices.push(index );
				indices.push(i + 3 );
				i += 2;
			}
			indices.push(i + 1 );
			indices.push(index );
			indices.push(1 );
		}
		recalculateBoundingBox();
	}
}
