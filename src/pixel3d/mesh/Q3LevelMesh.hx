package pixel3d.mesh;
import flash.Lib;
import flash.Vector;
import pixel3d.loader.bsp.BSPLeaf;
import pixel3d.loader.bsp.BSPNode;
import pixel3d.loader.bsp.BSPEntity;
import pixel3d.loader.bsp.BSPVisData;
import pixel3d.loader.bsp.BSPFace;
import pixel3d.material.ITexture;
import pixel3d.material.LoadingTexture;
import pixel3d.material.Texture;
import pixel3d.math.AABBox;
import pixel3d.math.Plane3D;
import flash.geom.Vector3D;
import pixel3d.mesh.AnimatedMeshType;
import pixel3d.mesh.IAnimatedMesh;
import pixel3d.mesh.IMesh;
import pixel3d.mesh.MeshBuffer;
import pixel3d.mesh.Mesh;
import pixel3d.mesh.MeshBuffer;
import pixel3d.mesh.MeshManipulator;
import flash.Vector;

class Q3LevelMesh extends Mesh
{
	public var planes : Vector<Plane3D>;
	public var numPlanes : Int;
	
	public var nodes : Vector<BSPNode>;
	public var numNodes : Int;
	
	public var leafs : Vector<BSPLeaf>;
	public var numLeafs : Int;
	
	public var leafFaces : Vector<Int>;
	public var numLeafFaces : Int;
	
	public var faces : Vector<BSPFace>;
	public var numFaces : Int;
	
	public var entities : Vector<BSPEntity>;
	public var numEntities : Int;
	
	//private var leafBrushes : Vector<Int>;
	//private var numLeafBrushes : Int;
	
	//private var brushes : Vector<BSPBrush>;
	//private var numBrushes : Int;
	
	//private var brusheSides : Vector<BSPBrushSide>;
	//private var numBrusheSides : Int;

	//private var models : Vector<BSPModel>;
	//private var numModels : Int;
	
	public var defalutPositions:Vector<Vector3D>;
	
	public var visData : BSPVisData;
	
	public var facesToDraw:BitSet;

	public function new()
	{
		super();
	}
	
	/**
	 * 
	 * @return get a random camera position
	 */
	public function getRandomPlayerPosition():Vector3D
	{
		if (defalutPositions.length > 0)
		{
			return defalutPositions[Std.int(defalutPositions.length * Math.random())].clone();
		}
		else
		{
			return new Vector3D();
		}
	}

	/**
	 * Returns a BSPLeaf for the supplied index
	 * @param : leaf index. Use findCurrentLeaf to get a vaild index
	 * @return : leaf or null if index is out of range
	 */
	public function getLeafByIndex(index : Int) : BSPLeaf
	{
		var leaf : BSPLeaf = null;
		if (index > -1 && index < numLeafs)
		{
			leaf = leafs[index];
			if(leaf.cluster == - 1)
			{
				return null;
			}
		}
		return leaf;
	}
	
	/** 
	 * Used to find which leaf a camera or other object is in.
	 *
	 * @param position position to use when finding leaf
	 *
	 * @return An index to the current leaf or -1
	 */
	public function findCurrentLeaf(position : Vector3D) : Int
	{
		var index : Int = 0;
		while (index >= 0)
		{
			var node : BSPNode = nodes[index];
			
			var plane : Plane3D = planes[node.plane];
			
			// Distance from point to a plane
			if ((plane.normal.dotProduct(position) - plane.d) < 0)
			{
				index = node.back;
			} 
			else 
			{
				index = node.front;
			}
		}
		//return -index - 1;
		return ~index;
	}
	
	/** 
	 * gets all the entity info for this map
	 */
	public function getEntities() : Vector<BSPEntity>
	{
		return entities;
	}
	
	/**
	 * 判断某个leaf是否可见
	 * @param	visCluster  通常是相机所在的leaf.cluster
	 * @param	testCluster 要测试的Cluster
	 * @return  true代表该节点可见，否则不可见
	 */
	public inline function isClusterVisible(visCluster:Int, testCluster:Int):Bool
	{
		var i:Int = (visCluster * visData.bytesPerCluster) + (testCluster >> 3);
		return (visData.bitsets[i] & (1 << (testCluster & 7))) != 0;
	}
	
	/**
	 * 根据当前相机位置和视椎体包围盒找出可见的BSPFace
	 * @param	cameraPosition 相机位置（已转为本地坐标）
	 * @param	frustumAABB 视椎体包围盒（已转为本地坐标）
	 */
	private var last_camera_leaf:BSPLeaf;
	public function calculateVisibleFaces(cameraPosition:Vector3D,frustumAABB:AABBox):Void
	{
		//Clear the list of faces drawn
		facesToDraw.clear();
		
		var cameraLeaf:BSPLeaf = getLeafByIndex(findCurrentLeaf(cameraPosition));
		
		if (cameraLeaf == null)
		{
			cameraLeaf = last_camera_leaf;
		}
		else
		{
			last_camera_leaf = cameraLeaf;
		}
		
		if (cameraLeaf != null)
		{
			var cameraCluster:Int = cameraLeaf.cluster;
			
			//loop through the leaves
			for (i in 0...numLeafs)
			{
				var currentLeaf:BSPLeaf = leafs[i];

				//if the leaf is not in the PVS, continue
				if (!isClusterVisible(cameraCluster, currentLeaf.cluster))
				{
					continue;
				}
				
				//if this leaf does not lie in the frustum, continue
				if (!currentLeaf.boundingBox.intersectsWithBox(frustumAABB))
				{
					continue;
				}
				
				//loop through faces in this leaf and mark them to be drawn
				for (j in 0...currentLeaf.numFaces)
				{
					facesToDraw.set(leafFaces[currentLeaf.firstLeafFace + j]);
				}
			}
		}
	}
}


class BitSet
{
	private var bits:Vector<Int>;
	private var numBytes:Int;
	
	public function new(numberOfBits:Int)
	{
		//Calculate size
		this.numBytes = (numberOfBits >> 3) + 1;
		
		bits = new Vector<Int>(numBytes, true);
	}
	
	public function clear():Void
	{
		bits.fixed = false;
		bits.length = 0;
		bits.length = numBytes;
		bits.fixed = true;
	}
	
	public inline function set(bitNumber:Int):Void
	{
		bits[bitNumber >> 3] |= 1 << (bitNumber & 7);
	}
	
	public inline function remove(bitNumber:Int):Void
	{
		bits[bitNumber >> 3] &= ~(1 << (bitNumber & 7));
	}
	
	public inline function isSet(bitNumber:Int):Bool
	{
		return bits[bitNumber >> 3] & 1 << (bitNumber & 7) != 0;
	}
}
