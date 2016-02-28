package pixel3d.scene;
import flash.Vector;
import pixel3d.material.Material;
import pixel3d.math.AABBox;
import flash.geom.Vector3D;
import pixel3d.scene.octree.Octree;
import pixel3d.scene.octree.OctreeIndexData;
import pixel3d.scene.octree.OctreeMeshChunk;
import pixel3d.utils.Logger;
import pixel3d.renderer.IVideoDriver;

	class OctTreeSceneNode extends SceneNode 
	{
		/** variable: Octree
		 * Pointer to the <Octree> data structure
		 */
		private var octree:Octree;
		
		/** variable: meshChunks
		 * Pointer to the Array of <OctreeMeshChunk>
		 */
		private var meshChunks:Vector<OctreeMeshChunk>;

		/** variable: indexDatas
		 * Pointer to the Array of <OctreeIndexData>
		 */
		private var indexDatas:Vector<OctreeIndexData>;

		private var _tmpAABB:AABBox;
		
		private var materials : Vector<Material>;
		private var materialCount : Int;
	
		public function new(octree:Octree)
		{
			super();
			
			// check Octree
			if(Octree == null)
			{
				Logger.log("OctreeSceneNode - Octree is required",Logger.ERROR);
				return;
			}
			
			// store Octree
			this.octree = octree;
			
			// get pointers to data for rendering
			meshChunks = octree.getMeshChunks();
			indexDatas = octree.getIndexData();
			
			// get all materials
			materials = octree.getMaterials();
			materialCount = materials.length;
			
			// set auto cull off
			this.autoCulling = false;		
			
			_tmpAABB = new AABBox();
		}

		/** This method is called just before the rendering process of the whole scene.
		 */
		override public function onRegisterSceneNode():Void
		{
			if(visible)
			{
				if(_material_transparent) sceneManager.registerNodeForRendering(this, SceneNode.TRANSPARENT);
				if(_material_solid) sceneManager.registerNodeForRendering(this, SceneNode.SOLID);
				super.onRegisterSceneNode();
			}
		}
		/** Renders the node
		 */
		override public function render():Void
		{
			// get video driver
			var driver:IVideoDriver = sceneManager.getVideoDriver();
			
			// set world transform
			driver.setTransformWorld(_absoluteTransformation);

			// get visible nodes - todo:
			var cam_pos:Vector3D = sceneManager.getActiveCamera().getAbsolutePosition();
			
			var extent:Vector3D = new Vector3D(100, 100, 100);
			
			_tmpAABB.resetVector(cam_pos);
			_tmpAABB.addInternalVector(cam_pos.subtract(extent));
			_tmpAABB.addInternalVector(cam_pos.add(extent));
			octree.calculatePolysInAABB(_tmpAABB);
			
			for(i in 0...materialCount)
			{	
				var material:Material = materials[i];
				//if((material.flagAlpha) == is_transparent_pass) 
				//{
					// get corresponding mesh chunk
					var mesh_chunk:OctreeMeshChunk = meshChunks[i];
					var mesh_index_data:OctreeIndexData = indexDatas[i];
					driver.setDistance(distance);
					driver.setMaterial(material);
					driver.drawIndexedTriangleList(mesh_chunk.vertices, mesh_chunk.vertices.length, mesh_index_data.indices, Std.int(mesh_index_data.size / 3));
				//}
			}
		}
	}