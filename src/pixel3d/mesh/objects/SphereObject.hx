package pixel3d.mesh.objects;
import flash.Vector;
import pixel3d.math.MathUtil;
import flash.geom.Vector3D;
import pixel3d.math.AABBox;
import pixel3d.math.Vertex;
import pixel3d.mesh.MeshBuffer;
class SphereObject extends MeshBuffer
{
	public function new(radius : Float = 100., polyCountX : Int = 6, polyCountY : Int = 6)
	{
		super();
		build(radius, polyCountX, polyCountY);
	}
	public inline function build(radius : Float, polyCountX : Int, polyCountY : Int) : Void
	{
		vertices.length = 0;
		indices.length = 0;
		if (polyCountX <2)
			polyCountX = 2;
		if (polyCountY <2)
			polyCountY = 2;
		if (polyCountX * polyCountY> 32767) // prevent u16 overflow

		{
			if (polyCountX> polyCountY) // prevent u16 overflow
				polyCountX = Std.int(32767 / polyCountY) - 1;
			else
				polyCountY = Std.int(32767 /(polyCountX + 1));
		}
		var polyCountXPitch : Int = polyCountX + 1;
		// get to same vertex on next level
		vertices.length =((polyCountXPitch * polyCountY) + 2);
		indices.length =((polyCountX * polyCountY) * 6);
		var clr : UInt = 0x445566;
		var i : Int = 0;
		var level : Int = 0;
		for (p1 in 0...(polyCountY - 1))
		{
			//main quads, top to bottom
			for (p2 in 0...(polyCountX - 1))
			{
				var curr : Int = level + p2;
				indices[i ++] = curr + polyCountXPitch;
				indices[i ++] = curr;
				indices[i ++] = curr + 1;
				indices[i ++] = curr + polyCountXPitch;
				indices[i ++] = curr + 1;
				indices[i ++] = curr + 1 + polyCountXPitch;
			}
			// the connectors from front to end
			indices[i ++] = level + polyCountX - 1 + polyCountXPitch;
			indices[i ++] = level + polyCountX - 1;
			indices[i ++] = level + polyCountX;
			indices[i ++] = level + polyCountX - 1 + polyCountXPitch;
			indices[i ++] = level + polyCountX;
			indices[i ++] = level + polyCountX + polyCountXPitch;
			level += polyCountXPitch;
		}
		var polyCountSq : Int = polyCountXPitch * polyCountY;
		// top point
		var polyCountSq1 : Int = polyCountSq + 1;
		// bottom point
		var polyCountSqM1 : Int =(polyCountY - 1) * polyCountXPitch;
		// last row's first vertex
		for (p2 in 0...(polyCountX - 1))
		{
			// create triangles which are at the top of the sphere
			indices[i ++] = polyCountSq;
			indices[i ++] = p2 + 1;
			indices[i ++] = p2;
			// create triangles which are at the bottom of the sphere
			indices[i ++] = polyCountSqM1 + p2;
			indices[i ++] = polyCountSqM1 + p2 + 1;
			indices[i ++] = polyCountSq1;
		}
		// create final triangle which is at the top of the sphere
		indices[i ++] = polyCountSq;
		indices[i ++] = polyCountX;
		indices[i ++] = polyCountX - 1;
		// create final triangle which is at the bottom of the sphere
		indices[i ++] = polyCountSqM1 + polyCountX - 1;
		indices[i ++] = polyCountSqM1;
		indices[i ++] = polyCountSq1;
		// calculate the angle which separates all points in a circle
		var angleX : Float = 2 * Math.PI / polyCountX;
		var angleY : Float = Math.PI / polyCountY;
		i = 0;
		var axz : Float;
		// we don't start at 0.
		var ay : Float = 0;
		//AngleY / 2;
		var pos : Vector3D = new Vector3D();
		var normal : Vector3D = new Vector3D();
		for (y in 0...polyCountY)
		{
			ay += angleY;
			var sinay : Float = Math.sin(ay);
			axz = 0;
			// calculate the necessary vertices without the doubled one
			for (xz in 0...polyCountX)
			{
				// calculate points position
				pos.x =(radius * Math.cos(axz) * sinay);
				pos.y =(radius * Math.cos(ay));
				pos.z =(radius * Math.sin(axz) * sinay);
				// for spheres the normal is the position
				normal.x = pos.x;
				normal.y = pos.y;
				normal.z = pos.z;
				normal.normalize();
				// calculate texture coordinates via sphere mapping
				// tu is the same on each level, so only calculate once
				var tu : Float = 0.5;
				if (y == 0)
				{
					if (normal.y != - 1.0 && normal.y != 1.0)
						tu = Math.acos(MathUtil.clamp(normal.x / sinay, - 1.0, 1.0)) * 0.5 / Math.PI;
					if (normal.z <0.0)
						tu = 1 - tu;
				}
				else
				{
					tu = vertices[i - polyCountXPitch].u;
				}
				vertices[i ++] = new Vertex(pos.x, pos.y, pos.z,
											normal.x, normal.y, normal.z,
											clr, tu,
											(ay / Math.PI));
				axz += angleX;
			}
			// This is the doubled vertex on the initial position
			vertices[i] = vertices[i - polyCountX];
			vertices[i].u = 1.0;
			i ++;
		}
		// the vertex at the top of the sphere
		vertices[i] = new Vertex(0.0, radius, 0.0, 0.0, 1.0, 0.0, clr, 0.5, 0.0);
		// the vertex at the bottom of the sphere
		i ++;
		vertices[i] = new Vertex(0.0, - radius, 0.0, 0.0, - 1.0, 0.0, clr, 0.5, 1.0);

		// recalculate bounding box
		boundingBox.reset(0, 0, 0);
		boundingBox.addInternalVertex(vertices[i]);
		boundingBox.addInternalVertex(vertices[i - 1]);
		boundingBox.addInternalXYZ(radius, 0.0, 0.0);
		boundingBox.addInternalXYZ( - radius, 0.0, 0.0);
		boundingBox.addInternalXYZ(0.0, 0.0, radius);
		boundingBox.addInternalXYZ(0.0, 0.0, - radius);
	}
}
