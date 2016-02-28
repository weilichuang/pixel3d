package pixel3d.scene.octree;
import flash.Lib;
import flash.Vector;
import pixel3d.material.Material;
import pixel3d.math.AABBox;
import pixel3d.math.Triangle3D;
import pixel3d.math.Vertex;
import pixel3d.mesh.IMesh;
import pixel3d.mesh.MeshBuffer;
import pixel3d.utils.Logger;
	/** Octree data structure, used for collision detection.
	 */
	class OctreeCollisionMesh
	{
		/** Top node of Octree
		 */
		private var rootNode:OctreeNode;
		
		/** Array of <IndexData>
		 */
		private var indexData:OctreeIndexData;
		private var indexDatas:flash.Vector<OctreeIndexData>;
				
		/** Array of <Material>, materials used in Octree mesh
		 */
		private var materials:Vector<Material>;
		
		/** Array of <Triangle3D>, used during collision tests
		 */
		private var triangles:Vector<Triangle3D>;
			
		/** Constructor
		 */
		public function new()
		{
			// setup
			rootNode = new OctreeNode();
			indexData = new OctreeIndexData();
			indexDatas = new Vector<OctreeIndexData>();
			indexDatas.push(indexData);
			
			materials = new Vector<Material>();
			triangles = new Vector<Triangle3D>();
		}
		
		// ********************
		// Construction methods
		// ********************
		/** Default creation method.
		 */
		public function create(mesh:IMesh, minimalPolysPerNode:Int=10):Void
		{
			// record time we start
			var stats_time_start:Int = Lib.getTimer();
			var stats_node_count:Int = 0;
			var stats_poly_count:Int = 0;
	
			// loop all mesh buffers
			var len:Int = mesh.getMeshBufferCount();
			for(i in 0...len)
			{
				// get the mesh buffer
				var mb:MeshBuffer = mesh.getMeshBuffer(i);
								
				// add mesh buffer material to Octree material list
				materials.push(mb.getMaterial());
				
				// construct triangles
				var verts:flash.Vector<Vertex> = mb.getVertices();
				var indices:Vector<Int> = mb.getIndices();
				var index_count:Int = mb.getIndexCount();
				var idx:Int = 0;
				while(idx <index_count)
				//for(var idx:Int=0; idx<index_count; idx+=3)
				{
					var v0:Vertex = verts[indices[idx]];
					var v1:Vertex = verts[indices[idx+1]];
					var v2:Vertex = verts[indices[idx+2]];
					
					// create new triangle & store reference to material
					var triangle:Triangle3D = new Triangle3D(v0.position,v1.position,v2.position);
					triangle.info = i;
					// add to list of tri's
					triangles.push(triangle);
					
					idx += 3;
				}
				
				// get some stats
				stats_poly_count += Std.int(index_count / 3);
			}
			
			// ------------------------------------------------------------
			// part two - create index data

			
			// create new OctreeIndexChunk
			var index_chunk:OctreeIndexChunk = new OctreeIndexChunk();
						
			// loop all triangles and create index
			len = triangles.length;
			for(i in 0...len)
			{
				index_chunk.indices.push(i);
			}
			
			/* create Octree by passing mesh chunks through the Octreenode class
			this is a recursive function so may take some time to run
			*/
			stats_node_count = rootNode.createCollisionMesh(0, triangles, index_chunk, minimalPolysPerNode);
			
			// report
			var stats_time_end:Int = Lib.getTimer();
			var stats_msg:String = "Needed " +(stats_time_end - stats_time_start) +" to create Octree SceneNode.(" +(stats_node_count) + " nodes " +(stats_poly_count) + " polys)";
			Logger.log(stats_msg,Logger.INFORMATION);
		} 
		// ********************
		// Intersection methods
		// ********************
		public function calculatePolysInAABB(aabb:AABBox):Void
		{
			// -------------------------------------------------------
			// reset visibility data
			indexData.size = 0;
			// -------------------------------------------------------
			
			rootNode.calculatePolysInAABB(aabb, indexDatas);
		}
		// **************
		// return methods
		// **************
		public function getIndexData():OctreeIndexData
		{
			return indexData;
		}
		
		public function getTriangles():flash.Vector<Triangle3D>
		{
			return triangles;
		}
		
		public function getMaterials():Vector<Material>
		{
			return materials;
		}
		
		public function getBoundingBox():AABB
		{
			if(rootNode == null) return null;
				
			return rootNode.boundingBox;
		}
	}