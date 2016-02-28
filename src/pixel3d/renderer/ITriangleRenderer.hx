package pixel3d.renderer;
import flash.Vector;
import pixel3d.math.Vertex4D;
import pixel3d.material.Material;
interface ITriangleRenderer
{
	function setMaterial(material : Material) : Void;
	function drawIndexedTriangleList(vertices : Vector<Vertex4D>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int) : Void;
	function setPerspectiveCorrectDistance(distance : Float = 400.) : Void;
	function setMipMapDistance(distance : Float = 500.) : Void;
	function setDistance(distance : Float) : Void;
	function setRenderState(state : Int) : Void;
	function setWidth(width : Int) : Void;
	function setHeight(height : Int) : Void;
	function setVector(target : Vector<UInt>, buffer : Vector<Float>) : Void;
	function setStencileBuffer(buffer : Vector<Int>) : Void;
	function setShadowPercent(per : Float) : Void;
}
