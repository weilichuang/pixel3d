package pixel3d.scene;
import flash.Lib;
import flash.Vector;
import pixel3d.math.Vector2f;
import pixel3d.mesh.MeshBuffer;
import pixel3d.material.Material;
import pixel3d.math.AABBox;
import flash.geom.Vector3D;
import pixel3d.math.Vector2i;
import pixel3d.math.Matrix4;
import pixel3d.math.Vertex;
import pixel3d.mesh.Mesh;
import pixel3d.mesh.MeshBuffer;
import pixel3d.renderer.IVideoDriver;
class BillboardSceneNode extends MeshSceneNode
{
	private var size : Vector2f;
	private var vertices : Vector<Vertex>;
	private var indices : Vector<Int>;
	private var meshBuffer:MeshBuffer;
	private var material:Material;
	public function new(size : Vector2f = null)
	{
		super();
		//indices and vertices
		indices = Vector.ofArray([0, 2, 1, 0, 3, 2]);
		vertices = new Vector<Vertex>(4, true);
		var vertex : Vertex = new Vertex();
		vertex.u = 1.0;
		vertex.v = 1.0;
		vertices[0] = vertex;
		vertex = new Vertex();
		vertex.u = 1.0;
		vertex.v = 0.0;
		vertices[1] = vertex;
		vertex = new Vertex();
		vertex.u = 0.0;
		vertex.v = 0.0;
		vertices[2] = vertex;
		vertex = new Vertex();
		vertex.u = 0.0;
		vertex.v = 1.0;
		vertices[3] = vertex;
		meshBuffer = new MeshBuffer();
		meshBuffer.setVertices(vertices);
		meshBuffer.setIndices(indices);
		material = meshBuffer.getMaterial();

		var mesh:Mesh = new Mesh();
		mesh.addMeshBuffer(meshBuffer);
		this.setMesh(mesh);
		setSize(size);
	}

	private static var _tmpMatrix : Matrix4 = new Matrix4();
	override public function render() : Void
	{
		var driver : IVideoDriver = sceneManager.getVideoDriver();
		var camera : CameraSceneNode = sceneManager.getActiveCamera();
		// make billboard look to camera
		var pos : Vector3D = this.getAbsolutePosition();
		var campos : Vector3D = camera.getAbsolutePosition();
		var target : Vector3D = camera.getTarget();
		var up : Vector3D = camera.getUpVector();
		var view : Vector3D = target.subtract(campos);
		view.normalize();
		var horizontal : Vector3D = up.crossProduct(view);
		if(horizontal.length == 0 )
		{
			horizontal.x = up.x;
			horizontal.y = up.y;
			horizontal.z = up.z;
		}
		horizontal.normalize();
		horizontal.scaleBy(0.5 * size.x);
		var vertical : Vector3D = horizontal.crossProduct(view);
		vertical.normalize();
		vertical.scaleBy(0.5 * size.y);
		view.scaleBy( - 1);
		var vertex : Vertex;
		for(i in 0...4)
		{
			vertex = vertices[i];
			vertex.nx = view.x;
			vertex.ny = view.y;
			vertex.nz = view.z;
		}
		vertex = vertices[0];
		vertex.x = pos.x + horizontal.x + vertical.x;
		vertex.y = pos.y + horizontal.y + vertical.y;
		vertex.z = pos.z + horizontal.z + vertical.z;
		vertex = vertices[1];
		vertex.x = pos.x + horizontal.x - vertical.x;
		vertex.y = pos.y + horizontal.y - vertical.y;
		vertex.z = pos.z + horizontal.z - vertical.z;
		vertex = vertices[2];
		vertex.x = pos.x - horizontal.x - vertical.x;
		vertex.y = pos.y - horizontal.y - vertical.y;
		vertex.z = pos.z - horizontal.z - vertical.z;
		vertex = vertices[3];
		vertex.x = pos.x - horizontal.x + vertical.x;
		vertex.y = pos.y - horizontal.y + vertical.y;
		vertex.z = pos.z - horizontal.z + vertical.z;
		
		_tmpMatrix.identity();
		driver.setMaterial(material);
		driver.setTransformWorld(_tmpMatrix);

		driver.setDistance(distance);
		driver.drawIndexedTriangleList(vertices, 4, indices, 6);
		
		if(debug)
		{
			driver.draw3DBox(getBoundingBox(),debugColor,debugAlpha,debugWireframe);
		}
	}
	
	public function setSize(size : Vector2f) : Void
	{
		if(size == null) return;
		
		this.size = size;
	}
	
	public function getSize() : Vector2f
	{
		return size;
	}
}
