package pixel3d.scene.octree;
import pixel3d.scene.octree.OctreeIndexChunk;
import flash.Vector;
import pixel3d.math.AABBox;
import pixel3d.math.Triangle3D;
import flash.geom.Vector3D;
import pixel3d.math.Vertex;
import pixel3d.scene.octree.OctreeIndexChunk;
/** Octree base node
 */
class OctreeNode
{
	/** Bounds of node.
	 */
	public var boundingBox:AABBox;

	/** Array of <OctreeIndexChunk>
	 */
	public var indexChunkData:flash.Vector<OctreeIndexChunk>;

	/** Array of <OctreeNode> 0 to 7
	 */
	public var children:flash.Vector<OctreeNode>;

	/** Depth node is in tree
	 */
	public var depth:Int;

	/** Constructor
	 */
	public function new()
	{
		// setup defaults
		indexChunkData = new Vector<OctreeIndexChunk>();
		boundingBox = new AABBox();
		children = new Vector<OctreeNode>(8,true);
		depth = 0;
	}

	// ********************
	// Construction methods
	// ********************
	public function createCollisionMesh(currentDepth:Int, triangles:flash.Vector<Triangle3D>, indexChunk:OctreeIndexChunk, minimalPolysPerNode:Int):Int
	{
		// set index data
		indexChunkData.push(indexChunk);

		// set depth
		depth = currentDepth + 1;

		// ---------------------------------------------------------------------
		// find first vertex for bounding box
		var bounding_box:AABBox = bounds.boundingBox;
		if (indexChunk!=null)
		{
			// get index and then triangle
			var index:Int = indexChunk.indices[0];
			var triangle:Triangle3D = triangles[index];

			// reset the bounding box
			bounding_box.resetVector(triangle.v0);
		}
		else
		{
			// no index data
			return 0;
		}

		// used to check max polys
		var total_polys:Int = 0;

		// create node counter, used to track how many nodes are created
		var node_count:Int = 1;

		// ---------------------------------------------------------------------
		/* now lets calculate our bounding box
		the bounding box incompases all the data down to this point.*/
		var indices:flash.Vector<Int> = indexChunk.indices;
		var jl:Int = indices.length;
		for (j in 0...jl)
		{
			// get index and then triangle
			var index:Int = indices[j];
			var triangle:Triangle3D = triangles[index];

			// add vertex to bounding box
			bounding_box.addInternalVector(triangle.v0);
			bounding_box.addInternalVector(triangle.v1);
			bounding_box.addInternalVector(triangle.v2);
		}

		// add to total poly count
		total_polys += jl;

		// update bounds(creates bounding sphere info)
		bounds.update();

		// check total poly count
		if ((total_polys/3) <= minimalPolysPerNode || bounding_box.isEmpty())
			return node_count;

		// check max depth
		if (depth> 5)
			return node_count;

		// ---------------------------------------------------------------------
		/* calculate all eight children */

		// get the bounds of the bounding box
		var middle:Vector3D = bounding_box.getCenter();
		var edges:flash.Vector<Vector3D> = bounding_box.getEdges();

		var box:AABBox = new AABBox();
		for (ch in 0...8)
		{
			// setup oct segment
			box.resetVector(middle);
			box.addInternalVector(edges[ch]);

			// create a new OctreeIndexChunk
			var new_index_chunk:OctreeIndexChunk = new OctreeIndexChunk();

			indices = indexChunk.indices;
			jl = indices.length;
			var j:Int = 0;
			while (j <jl)
			{
				// get index and then triangle
				var index:Int = indices[j];
				var triangle:Triangle3D = triangles[index];

				var pointInBox1:Bool = box.isPointInside(triangle.v0);
				var pointInBox2:Bool = box.isPointInside(triangle.v1);
				var pointInBox3:Bool = box.isPointInside(triangle.v2);

				if ((pointInBox1 && pointInBox2) ||(pointInBox2 && pointInBox3) ||(pointInBox1 && pointInBox3))
				{
					// at least two points are inside the new child bounding box

					// add the index to this child box
					new_index_chunk.indices.push(index);

					// erase the index from the current node
					indices.splice(j,1);

					// adjust total and step back
					j-=1;
					jl-=1;
				}
				j++;
			}

			// check if any indices where added
			if (new_index_chunk.indices.length == 0)
			{
				// delete index chunk object
				new_index_chunk = null;
			}

			// check if we are left with any indices for the current node
			if (indexChunk.indices.length == 0)
			{
				// set a placeholder value
				indexChunkData[7] = null;
			}

			var child_node:OctreeNode = new OctreeNode();
			children[ch] = child_node;

			// recursive function
			var nodes_created:Int = child_node.createCollisionMesh(depth, triangles, new_index_chunk, minimalPolysPerNode);

			// check returned nodes created!
			if (nodes_created == 0)
			{
				// no data left
				children[ch] = null;
			}
			else
			{
				// add to node count
				node_count += nodes_created;
			}

		} // end for all children

		// return nodes created including this node
		return node_count;
	}

	/** Builds an Octree node by subdividing the passed mesh chunks into 2*2*2 grid
	 */
	public function create(currentDepth:Int, meshChunks:Vector<OctreeMeshChunk>, indexChunks:flash.Vector<OctreeIndexChunk>, minimalPolysPerNode:Int):Int
	{
		// set index data
		indexChunkData = indexChunks;

		// set depth
		depth = currentDepth+1;

		// ---------------------------------------------------------------------
		// find first vertex for bounding box
		var bounding_box:AABBox = bounds.boundingBox;

		var found_vertex:Bool = false;
		var len:Int = indexChunks.length;
		for (i in 0...len)
		{
			// get index chunk
			var index_chunk:OctreeIndexChunk = indexChunkData[i];
			if (index_chunk != null)
			{
				// get mesh chunk
				var mesh_chunk:OctreeMeshChunk = meshChunks[i];

				// get index and then vertex
				var index:Int = index_chunk.indices[0];
				var vertex:Vertex = mesh_chunk.vertices[index];

				// reset the bounding box
				bounding_box.resetVertex(vertex);
				found_vertex = true;
				break;
			}
		}

		// check we found a vertex
		if (!found_vertex)
			return 0;

		// used to check max polys
		var total_polys:Int = 0;

		// create node counter, used to track how many nodes are created
		var node_count:Int = 1;

		// ---------------------------------------------------------------------
		/* now lets calculate our bounding box
		the bounding box incompases all the data down to this point.*/
		len = indexChunks.length;
		for (i in 0...len)
		{
			// get index chunk
			var index_chunk:OctreeIndexChunk = indexChunkData[i];

			if (index_chunk != null)
			{
				// get mesh chunk
				var mesh_chunk:OctreeMeshChunk = meshChunks[i];

				var jl:Int = index_chunk.indices.length;
				for (j in 0...jl)
				{
					// get index and then vertex
					var index:Int = index_chunk.indices[j];
					var vertex:Vertex = mesh_chunk.vertices[index];

					// add vertex to bounding box
					bounding_box.addInternalVertex(vertex);
				}

				// add to total poly count
				total_polys += index_chunk.indices.length;
			}
		}

		// update bounds(creates bounding sphere info)
		bounds.update();

		// check total poly count
		if ((total_polys/3) <= minimalPolysPerNode || bounding_box.isEmpty())
			return node_count;

		// check max depth
		if (depth> 5)
			return node_count;

		// ---------------------------------------------------------------------
		/* calculate all eight children */

		// get the bounds of the bounding box
		var middle:Vector3D = bounding_box.getCenter();
		var edges:flash.Vector<Vector3D> = bounding_box.getEdges();

		var box:AABBox = new AABBox();
		for (ch in 0...8)
		{
			// setup oct segment
			box.resetVector(middle);
			box.addInternalVector(edges[ch]);

			// create indices for child - <OctreeIndexChunk>
			var new_index_chunks:flash.Vector<OctreeIndexChunk> = new Vector<OctreeIndexChunk>();

			var len:Int = meshChunks.length;
			for (i in 0...len)
			{
				// get index chunk
				var index_chunk:OctreeIndexChunk = indexChunkData[i];
				if (index_chunk == null)
				{
					// set a placeholder value
					new_index_chunks.push(null);
					continue;
				}

				// get mesh chunk
				var mesh_chunk:OctreeMeshChunk = meshChunks[i];

				// create a new OctreeIndexChunk
				var new_index_chunk:OctreeIndexChunk = new OctreeIndexChunk();
				new_index_chunk.materialId = mesh_chunk.materialId;

				// add to array of index_chunks
				new_index_chunks.push(new_index_chunk);

				var total_indices:Int = index_chunk.indices.length;
				var t:Int = 0;
				while (t <total_indices)
					//for(t in 0...total_indices; t+=3)
				{
					// get indices and then vertices
					var index1:Int = index_chunk.indices[t];
					var index2:Int = index_chunk.indices[t+1];
					var index3:Int = index_chunk.indices[t+2];

					var vertex1:Vertex = mesh_chunk.vertices[index1];
					var vertex2:Vertex = mesh_chunk.vertices[index2];
					var vertex3:Vertex = mesh_chunk.vertices[index3];

					var pointInBox1:Bool = box.isVertexInside(vertex1);
					var pointInBox2:Bool = box.isVertexInside(vertex2);
					var pointInBox3:Bool = box.isVertexInside(vertex3);

					if ((pointInBox1 && pointInBox2) ||(pointInBox2 && pointInBox3) ||(pointInBox1 && pointInBox3))
					{
						// all three points are inside the new child bounding box

						// add the indices to this child box
						new_index_chunk.indices.push(index1);
						new_index_chunk.indices.push(index2);
						new_index_chunk.indices.push(index3);

						// erase the indices from the current node
						index_chunk.indices.splice(t, 3);

						// adjust total and step back
						t-=3;
						total_indices-=3;
					}
					t += 3;
				}

				// check if any indices where added
				if (new_index_chunk.indices.length == 0)
				{
					// delete index chunk object
					new_index_chunk = null;
					//new_index_chunks[new_index_chunks.length - 1];
					// set a placeholder value
					new_index_chunks[new_index_chunks.length - 1] = null;
				}

				// check if we are left with any indices for the current node
				if (index_chunk.indices.length == 0)
				{
					// delete index chunk object
					index_chunk = null;
					//delete indexChunkData[i];

					// set a placeholder value
					indexChunkData[i] = null;
				}
			}

			var child_node:OctreeNode = new OctreeNode();
			children[ch] = child_node;

			// recursive function
			var nodes_created:Int = child_node.create(depth, meshChunks, new_index_chunks, minimalPolysPerNode);

			if (nodes_created == 0)
			{
				// no data left
				children[ch] = null;
			}
			else
			{
				// add to node count
				node_count += nodes_created;
			}

		} // end for all children

		// return nodes created including this node
		return node_count;
	}

	// ******************
	// Visibility methods
	// ******************
	public function calculatePolysInAABB(aabb:AABBox, indexData:Vector<OctreeIndexData>):Void
	{
		// check intersection
		if (aabb.intersectsWithBox(boundingBox))
		{
			// ----------------------------------------------------------
			// add to node's indices to index data's indices

			// loop all materials
			var len:Int = indexData.length;
			for (i in 0...len)
			{
				var index_chunk:OctreeIndexChunk = indexChunkData[i];
				if (index_chunk!=null)
				{
					var node_indices:flash.Vector<Int> = index_chunk.indices;
					var node_indices_length:Int = node_indices.length;

					var index_data:OctreeIndexData = indexData[i];
					var index_data_indices:flash.Vector<Int> = index_data.indices;

					var start:Int = index_data.size;
					var end:Int = start + node_indices_length;
					var j:Int = 0;

					//for(;start<end;start++)
					for (n in start...end)
					{
						index_data_indices[n] = node_indices[j++];
					}

					index_data.size += node_indices_length;
				}
			}

			// ----------------------------------------------------------
			// check children
			for (i in 0...8)
			{
				var child:OctreeNode = children[i];
				if (child!=null)
				{
					child.calculatePolysInAABB(aabb, indexData);
				}
			}
		}
	}
}