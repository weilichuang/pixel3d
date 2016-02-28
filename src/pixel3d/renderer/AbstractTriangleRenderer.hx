package pixel3d.renderer;
import flash.geom.Vector3D;
import flash.Vector;
import flash.display.BitmapData;
import pixel3d.math.Vertex4D;
import pixel3d.math.Vector2i;
import pixel3d.math.MathUtil;
import pixel3d.math.Vector2f;
import pixel3d.material.ITexture;
import pixel3d.material.Texture;
import pixel3d.material.Material;
import pixel3d.utils.Logger;

class AbstractTriangleRenderer implements ITriangleRenderer
{
	private var target : Vector<UInt>;
	private var buffer : Vector<Float>;
	private var material : Material;
	
	private var texture : ITexture;
	private var texVector : Vector<UInt>;
	private var texWidth : Int;
	private var texHeight : Int;
	
	private var texture2 : ITexture;
	private var texVector2D : Vector<UInt>;
	private var texWidth2 : Int;
	private var texHeight2 : Int;
	
	private var perspectiveCorrect : Bool;
	private var perspectiveDistance : Float;
	private var mipMapDistance : Float;
	private var isPowOfTow:Bool;
	//alpha
	private var transparent : Bool;
	private var alpha : Float;
	private var invAlpha : Float;
	private var width : Int;
	private var height : Int;
	private var distance : Float;
	
	private var dzdx : Float;
	private var dzdy : Float;
	private var xa : Float;
	private var xb : Float;
	private var za : Float;
	private var dxdya : Float;
	private var dxdyb : Float;
	private var dzdya : Float;
	private var side : Bool;
	private var tmp : Vertex4D;
	private var v1 : Vertex4D;
	private var v2 : Vertex4D;
	private var v3 : Vertex4D;
	private var x1 : Float;
	private var y1 : Float;
	private var z1 : Float;
	private var x2 : Float;
	private var y2 : Float;
	private var z2 : Float;
	private var x3 : Float;
	private var y3 : Float;
	private var z3 : Float;
	private var r1 : Float;
	private var g1 : Float;
	private var b1 : Float;
	private var color : UInt;
	private var x2x1 : Float;
	private var x3x1 : Float;
	private var y2y1 : Float;
	private var y3y1 : Float;
	private var z2z1 : Float;
	private var z3z1 : Float;
	private var y1i : Int;
	private var y2i : Int;
	private var y3i : Int;
	private var zi : Float;
	private var xs : Int;
	private var xe : Int;
	private var pos : Int;
	private var dxdy1 : Float;
	private var dxdy2 : Float;
	private var dxdy3 : Float;
	private var bgColor : UInt;
	private var bga : Int;

	//shadow
	private var stencileBuffer : Vector<Int>;
	private var shadowPerctent : Float;
	private var invsa : Float;
	private var renderState : Int;
	public function new()
	{
		perspectiveCorrect = false;
		perspectiveDistance = 400.;
		mipMapDistance = 500.;
		distance = 0;
		renderState = 0;
	}

	public function setShadowPercent(per : Float) : Void
	{
		shadowPerctent = MathUtil.clamp(per, 0, 1);
		invsa = 1.0 - shadowPerctent;
	}
	
	public function setRenderState(state : Int) : Void
	{
		this.renderState = state;
	}
	
	public function setStencileBuffer(buffer : Vector<Int>) : Void
	{
		this.stencileBuffer = buffer;
	}
	
	public function drawIndexedTriangleList(vertices : Vector<Vertex4D>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int) : Void
	{
	}
	
	public function setDistance(distance : Float) : Void
	{
		this.distance = distance;
	}
	
	public function setVector(target : Vector<UInt>, buffer : Vector<Float>) : Void
	{
		this.target = target;
		this.buffer = buffer;
	}
	
	public function setWidth(width : Int) : Void
	{
		this.width = width;
	}
	
	public function setHeight(height : Int) : Void
	{
		this.height = height;
	}
	
	public function setPerspectiveCorrectDistance(distance : Float = 400.) : Void
	{
		perspectiveDistance = distance;
	}
	
	public function setMipMapDistance(distance : Float = 500.) : Void
	{
		mipMapDistance = distance;
	}
	
	public function setMaterial(mat : Material) : Void
	{
		material = mat;
		isPowOfTow = material.isPowOfTow;
		transparent = material.transparenting;
		if(transparent)
		{
			alpha = material.alpha;
			invAlpha = 1.0 - alpha;
		}
		else
		{
			alpha = 1.0;
			invAlpha = 0.0;
		}
		texture = material.getTexture();
		texture2 = material.getTexture2();
	}
}
