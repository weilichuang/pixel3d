package pixel3d.loader.bsp;
/**
* The visdata lump stores bit vectors that provide cluster-to-cluster visibility information.
* There is exactly one visdata record, with a length equal to that specified in the lump directory.
* Cluster x is visible from cluster y if the(1 <<y % 8) bit of vecs[x * sz_vecs + y / 8] is set.
* Note that clusters are associated with leaves.
*/

class BSPVisData
{
	public var numClusters : Int;// The Number of clusters
	public var bytesPerCluster : Int;// Bytes(8 bits) in the cluster's bitset
	public var bitsets : Array<Int>;// Array of bytes holding the cluster vis. c8

	public function new()
	{
	}
}
