package pixel3d.scene.octree;
import flash.Lib;
import flash.Vector;
import pixel3d.material.Material;
import pixel3d.math.AABBox;
import pixel3d.math.Vertex;
import pixel3d.mesh.IMesh;
import pixel3d.mesh.MeshBuffer;
import pixel3d.scene.ViewFrustum;
import pixel3d.utils.Logger;

/**
 * Octree data structure, used for rendering and collision detection
 */
class Octree
{
	//Top node of Octree
	private var rootNode : OctreeNode;
	//
	private var indexDatas:Vector<OctreeIndexData>;
	private var materials:Vector<Material>;
	private var meshChunks:flash.Vector<OctreeMeshChunk>;
	private var indexDataCount : Int;
	private var materialCount : Int;
	private var chunkCount : Int;
	
	public function new()
	{
		rootNode = null;
		indexDatas = new flash.Vector<OctreeIndexData>();
		materials = new flash.Vector<Material>();
		meshChunks = new flash.Vector<OctreeMeshChunk>();
	}
	
	public function create(mesh:IMesh, minimalPolysPerNode:Int=128):Void
	{
		// record time we start
		var stats_time_start:Float = Lib.getTimer();
		var stats_node_count:Int = 0;
		var stats_poly_count:Int = 0;
	
		// loop all mesh buffers
		var len:Int = mesh.getMeshBufferCount();
		for(i in 0...len)
		{
			// get the mesh buffer
			var mb:MeshBuffer = mesh.getMeshBuffer(i);
				

			// create a mesh chunk for this mesh buffer
			var mesh_chunk:OctreeMeshChunk = new OctreeMeshChunk();
			meshChunks.push(mesh_chunk);
				
			// add mesh buffer material to Octree material list
			materials.push(mb.getMaterial());
				
			// set material id
			mesh_chunk.materialId = i;


			// add vertices from mesh buffer to mesh chunk
			var verts:flash.Vector<Vertex> = mb.getVertices();
			var vl:Int = mb.getVertexCount();
			for(v in 0...vl)
			{
				mesh_chunk.vertices.push(verts[v]);
			}
				
			// get some stats
			stats_poly_count += Std.int(mb.getIndexCount() / 3);
								
			// add indices from mesh buffer to mesh chunk
			var indices:flash.Vector<Int> = mb.getIndices();
			var il:Int = mb.getIndexCount();
			for(v in 0...il)
			{
				mesh_chunk.indices.push(indices[v]);
			}
		}
			
		// part two - create index data
			
		// construct array of all indices
		var index_chunks:flash.Vector<OctreeIndexChunk> = new flash.Vector<OctreeIndexChunk>();
			
		// loop all mesh chunks
		len = meshChunks.length;
		for(i in 0...len)
		{
			// get current mesh chunk
			var mesh_chunk:OctreeMeshChunk = meshChunks[i];
				
			// ------------------------------------------------------
			// create a new OctreeIndexData
			var index_data:OctreeIndexData = new OctreeIndexData();
			index_data.size = 0;
			index_data.maxSize = mesh_chunk.indices.length;
			index_data.indices = new flash.Vector<Int>(index_data.maxSize);
				
			// add to indexDatas array
			indexDatas.push(index_data);
								
			// ------------------------------------------------------
			// create new OctreeIndexChunk
			var index_chunk:OctreeIndexChunk = new OctreeIndexChunk();
				
			// set material id
			index_chunk.materialId = mesh_chunk.materialId;
				
			// add index chunk to index_chunks array
			index_chunks.push(index_chunk);
				
			// add all indices from current mesh into the index_chunk
			var indices_length:Int = mesh_chunk.indices.length;
			for(t in 0...indices_length)
			{
				index_chunk.indices.push(mesh_chunk.indices[t]);
			}
			// ------------------------------------------------------			
		}
			
		/* create Octree by passing mesh chunks through the Octreenode class
		this is a recursive function so may take some time to run
		*/
		rootNode = new OctreeNode();
		stats_node_count = rootNode.create(0, meshChunks, index_chunks, minimalPolysPerNode);
			
		// report
		var stats_time_end:Float = Lib.getTimer();
		var stats_msg:String = "Needed " +(stats_time_end - stats_time_start) +" to create Octree SceneNode.(" +(stats_node_count) + " nodes " +(stats_poly_count) + " polys)";
		Logger.log(stats_msg, Logger.INFORMATION);
	} 

	public function calculatePolysInAABB(aabb:AABBox):Void
	{
		// -------------------------------------------------------
		// reset visibility data
		var len:Int = indexDatas.length;
		for(i in 0...len)
		{
			var index_data:OctreeIndexData = indexDatas[i];
			index_data.size = 0;
		}
		// -------------------------------------------------------
		rootNode.calculatePolysInAABB(aabb, indexDatas);
	}
		
	public function calculatePolysInFrustum(frustum:ViewFrustum):Void
	{
			
	}

	public function getIndexData():Vector<OctreeIndexData>
	{
		return indexDatas;
	}
		
	public function getMeshChunks():Vector<OctreeMeshChunk>
	{
		return meshChunks;
	}
		
	public function getMaterials():Vector<Material>
	{
		return materials;
	}
}
