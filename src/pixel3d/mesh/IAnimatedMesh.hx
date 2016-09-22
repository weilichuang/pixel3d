package pixel3d.mesh;
import pixel3d.mesh.IMesh;
interface IAnimatedMesh extends IMesh
{
	/**
	 *
	 * @return
	 */
	function getFrameCount() : Int;
	/**
	 *
	 * @param	frame
	 * @param	detailLevel
	 * @param	startFrameLoop
	 * @param	endFrameLoop
	 * @return
	 */
	function getMesh(frame : Int, detailLevel : Int = 255, startFrameLoop : Int = - 1, endFrameLoop : Int = - 1) : IMesh;
	/**
	 *
	 * @return
	 */
	function getMeshType() : Int;
}
