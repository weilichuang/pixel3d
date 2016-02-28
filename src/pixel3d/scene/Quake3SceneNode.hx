package pixel3d.scene;
import flash.Vector;
import pixel3d.loader.bsp.BSPFace;
import pixel3d.material.Material;
import pixel3d.math.AABBox;
import pixel3d.math.Matrix4;
import flash.geom.Vector3D;
import pixel3d.mesh.MeshBuffer;
import pixel3d.mesh.Q3LevelMesh;
import pixel3d.renderer.IVideoDriver;
class Quake3SceneNode extends SceneNode
{
	private var levelMesh : Q3LevelMesh;
	private var meshBuffers : Vector<MeshBuffer>;
	
	private var materials : Vector<Material>;
	private var materialCount : Int;
	
	private var inverse_Matrix : Matrix4;
	private var local_camera_position : Vector3D;
    private var local_frustumAABB:AABBox;

	public function new(mesh : Q3LevelMesh)
	{
		super();
		
		levelMesh = mesh;
		
		materials = new Vector<Material>();
		meshBuffers = levelMesh.buffers;
		materialCount = meshBuffers.length;
		for (i in 0...materialCount)
		{
			materials[i] = meshBuffers[i].material;
		}
		updateMaterialTypes();
		
		autoCulling = false;
		
		inverse_Matrix = new Matrix4();
		local_camera_position = new Vector3D();
		local_frustumAABB = new AABBox();
	}
	
	override public function onRegisterSceneNode() : Void
	{
		if(visible)
		{
			if(_material_transparent) sceneManager.registerNodeForRendering(this, SceneNodeType.TRANSPARENT);
			if(_material_solid) sceneManager.registerNodeForRendering(this, SceneNodeType.SOLID);
			super.onRegisterSceneNode();
		}
	}
	
	override public function render() : Void
	{
		var driver : IVideoDriver = sceneManager.getVideoDriver();
		
		var camera : CameraSceneNode = sceneManager.getActiveCamera();
		
		if(camera == null || driver == null) return;
		
		var isTransparentPass : Bool = (sceneManager.getCurrentRenderType() == SceneNodeType.TRANSPARENT);
		
		driver.setTransformWorld(_absoluteTransformation);
		
		// get inverse transform and move camera into object space
		//获得相机在物体空间内的位置
		_absoluteTransformation.getInvert(inverse_Matrix);
		inverse_Matrix.transformVector2D(camera.getAbsolutePosition(), local_camera_position);
		
		var frustumAABB:AABBox = camera.getViewFrustum().getBoundingBox();
		inverse_Matrix.transformBox2(frustumAABB, local_frustumAABB);
		
		levelMesh.calculateVisibleFaces(local_camera_position, local_frustumAABB);
		for (n in 0...levelMesh.numFaces)
		{
			if (levelMesh.facesToDraw.isSet(n))//该face是否可见
			{
				var face:BSPFace = levelMesh.faces[n];
				
				var buffer:MeshBuffer = face.buffer;
				if(buffer != null && buffer.material.transparenting == isTransparentPass)
				{
					driver.setMaterial(buffer.material);
					driver.drawMeshBuffer(buffer);
				}
			}
		}
	}

	override public function getMaterial(i : Int = 0) : Material
	{
		if(i <0 || i>= materialCount) return null;
		return materials[i];
	}
	
	override public function getMaterialCount() : Int
	{
		return materialCount;
	}
}
