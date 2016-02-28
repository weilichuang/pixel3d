package pixel3d.renderer;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.Vector;
import pixel3d.light.Light;
import pixel3d.material.Material;
import pixel3d.math.AABBox;
import pixel3d.math.Vector2i;
import pixel3d.math.Matrix4;
import flash.geom.Vector3D;
import pixel3d.math.Vertex;
import pixel3d.mesh.MeshBuffer;
interface IVideoDriver
{
	function beginScene() : Void;
	function endScene() : Void;
	
	function setCameraPosition(ps : Vector3D) : Void;
	function setTransformViewProjection(mat : Matrix4) : Void;
	function setTransformWorld(mat : Matrix4) : Void;
	function setTransformView(mat : Matrix4) : Void;
	function setTransformProjection(mat : Matrix4) : Void;
	
	function setMaterial(material : Material) : Void;
	
	function initRenderers():Void;
	
	function setDistance(distance : Float) : Void ;//根据物体的深度来判断是否使用MipMap和PerspectiveCorrect
	function setPerspectiveCorrectDistance(distance : Float = 400.) : Void;
	function getPerspectiveCorrectDistance() : Float;
	function setMipMapDistance(distance : Float = 500.) : Void;
	function getMipMapDistance() : Float;
	
	function drawIndexedTriangleList(vertices : Vector<Vertex>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int) : Void;
	function drawMeshBuffer(mb : MeshBuffer) : Void;
	function drawIndexedTriangleListAmbientLight(vertices : Vector<Vertex>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int) : Void;
	function drawMeshBufferAmbientLight(mb : MeshBuffer) : Void;
	
	function getScreenSize() : Vector2i;
	function setScreenSize(size : Vector2i) : Void;
	function getTriangleCountDrawn() : Int;

	//动态灯光相关
	function setAmbient(color : UInt) : Void;
	function removeAllLights() : Void;
	function addLight(light : Light) : Void;
	function getLight(i : Int) : Light;
	function getLightCount() : Int;
	
	
	function getDriverType() : Int;
	function createScreenShot() : BitmapData;
	
	function getBitmap():Bitmap;
	
	function setRenderState(state:Int):Void;
	function clearZBuffer():Void;
	
	// debug
	function draw3DLine(vs : Vector3D, ve : Vector3D, color : UInt) : Void;
	function draw3DTriangle(v0 : Vertex, v1 : Vertex, v2 : Vertex, color : UInt) : Void;
	function draw3DBox(box : AABBox, color : UInt, alpha : Float, wireframe : Bool = false) : Void;
	
	//shadow
	function canShadow() : Bool;
}
