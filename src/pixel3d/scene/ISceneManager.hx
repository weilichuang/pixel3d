package pixel3d.scene;

import pixel3d.scene.SceneNode;
import pixel3d.renderer.IVideoDriver;
interface ISceneManager 
{
	function registerNodeForRendering(node : SceneNode, type : Int) : Void;
	function getCurrentRenderType():Int;
	function getVideoDriver():IVideoDriver;
	function setVideoDriver(driver:IVideoDriver):Void;
	function getActiveCamera():CameraNode;
	function setActiveCamera(camera:CameraNode):Void;
	function beginScene():Void;
	function endScene():Void;
}