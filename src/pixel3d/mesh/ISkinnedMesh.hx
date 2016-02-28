package pixel3d.mesh;
import flash.Vector;
import pixel3d.mesh.skin.Joint;

/**
 * Interface for using some special functions of Skinned meshes
 */
interface ISkinnedMesh extends IAnimatedMesh
{
	function getAllJoints():Vector<Joint>;
	/**
	 * Gets joint count.
	 * @return Amount of joints in the skeletal animated mesh
	 */
    function getJointCount() : Int;
	/**
	 * Gets the name of a joint
	 * @param num Zero based index of joint. The last joint has the number getJointCount()-1;
	 * @return Name of joint and null if an error happened
	 */
	function getJointName(num : Int) : String;
	/**
	 * Gets a joint number from its name
	 * @param	name Name of the joint.
	 * @return Number of the joint or -1 if not found.
	 */
	function getJointIndex(name : String) : Int;
	
	/**
	 * Use animation from another mesh so make sure they are unique.
	 * @param	mesh
	 * @return True if all joints in this mesh were matched up
	 */
	function useAnimationFrom(mesh:ISkinnedMesh):Bool;
	/**
	 * Update Normals when Animating
	 * @param	on on If false don't animate, which is faster.
		Else update normals, which allows for proper lighting of
		animated meshes.
	 */
	function updateNormalsWhenAnimating(on : Bool = false) : Void;
	/**
	 * Sets Interpolation Mode
	 * @param	mode
	 */
	function setInterpolationMode(mode : Int) : Void;
	/**
	 * Animates this mesh's joints based on frame input
	 * @param	frame
	 * @param	blend
	 */
	function animateMesh(frame : Float, blend : Float) : Void;
	/**
	 * Preforms a software skin on this mesh based of joint positions
	 */
	function skinMesh() : Void;
}