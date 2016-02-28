package pixel3d.scene;
import flash.Vector;
import pixel3d.mesh.MeshBuffer;
import flash.geom.Vector3D;
import pixel3d.material.Material;
import pixel3d.math.AABBox;
import pixel3d.math.Matrix4;
import pixel3d.math.Vertex;
import pixel3d.mesh.IMesh;
import pixel3d.mesh.MeshBuffer;
import pixel3d.mesh.Mesh;
import pixel3d.mesh.MeshManipulator;
import pixel3d.utils.Logger;
import pixel3d.renderer.IVideoDriver;
class MeshSceneNode extends SceneNode
{
	private var materials : Vector<Material>;
	private var materialCount : Int;
	private var mesh : IMesh;
	private var useDefaultMaterial : Bool ;
	private var hasShadow:Bool;
	
	public function new(mesh : IMesh = null, useDefaultMaterial : Bool = true)
	{
		super();
		materials = new Vector<Material>();
		materialCount = 0;
		this.useDefaultMaterial = useDefaultMaterial;
		setMesh(mesh);
	}

	public function setMesh(m : IMesh) : Void
	{
		mesh = m;
		setMaterials(useDefaultMaterial);
	}
	
	public function getMesh() : IMesh
	{
		return mesh;
	}
	
	private function setMaterials(value : Bool) : Void
	{
		materialCount = 0;
		materials.length = 0;
		if(mesh != null)
		{
			var count : Int = mesh.getMeshBufferCount();
			for(i in 0...count)
			{
				if(value)
				{
					materials[i] = mesh.getMeshBuffer(i).getMaterial();
				} else
				{
					materials[i] = mesh.getMeshBuffer(i).getMaterial().clone();
				}
			}
			materialCount = count;
		}
		
		updateMaterialTypes();
	}
	
	public function setUseDefaultMaterial(value : Bool) : Void
	{
		useDefaultMaterial = value;
		setMaterials(useDefaultMaterial);
	}
	
	public function getUseDefaultMaterial() : Bool
	{
		return useDefaultMaterial;
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
		if(mesh == null) return;
		
		var isTransparentPass : Bool =(sceneManager.getCurrentRenderType() == SceneNodeType.TRANSPARENT);
		
		var driver : IVideoDriver = sceneManager.getVideoDriver();
		
		driver.setTransformWorld(_absoluteTransformation);
		driver.setDistance(distance);

		var len : Int = mesh.getMeshBufferCount();
		for(i in 0...len)
		{
			if(materials[i].transparenting == isTransparentPass)
			{
				driver.setMaterial(materials[i]);
				driver.drawMeshBuffer(mesh.getMeshBuffer(i));
			}
		}
		if(debug)
		{
			driver.draw3DBox(getBoundingBox() , debugColor, debugAlpha, debugWireframe);
		}
	}
	
	override public function renderAmbientLight() : Void
	{
		var driver : IVideoDriver = sceneManager.getVideoDriver();
		if(mesh == null || driver == null) return;
		driver.setTransformWorld(_absoluteTransformation);
		driver.setDistance(distance);
		var len : Int = mesh.getMeshBufferCount();
		for(i in 0...len)
		{
			driver.setMaterial(materials[i]);
			driver.drawMeshBufferAmbientLight(mesh.getMeshBuffer(i));
		}
	}
	
	override public function getBoundingBox() : AABBox
	{
		if(mesh != null)
		{
			return mesh.getBoundingBox();
		}
		return super.getBoundingBox();
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
