package pixel3d.mesh;
import flash.Vector;
import pixel3d.material.ITexture;
import pixel3d.math.AABBox;
interface IMesh
{
	/**
	 *
	 * @return
	 */
	function getMeshBufferCount() : Int;
	/**
	 *
	 * @param	i
	 * @return
	 */
	function getMeshBuffer(i : Int) : MeshBuffer;
	/**
	 *
	 * @return
	 */
	function getMeshBuffers() : Vector<MeshBuffer>;
	/**
	 *
	 * @return
	 */
	function getBoundingBox() : AABBox;
	/**
	 *
	 * @param	box
	 */
	function setBoundingBox(box:AABBox):Void;
	/**
	 *
	 */
	function recalculateBoundingBox() : Void;
	/**
	 *
	 * @param	flag
	 * @param	value
	 */
	function setMaterialFlag(flag : Int, value : Bool) : Void;
	/**
	 *
	 * @param	texture
	 * @param	layer
	 */
	function setMaterialTexture(texture : ITexture, layer : Int = 1) : Void;

}
