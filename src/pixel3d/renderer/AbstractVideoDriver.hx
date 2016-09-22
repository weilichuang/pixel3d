package pixel3d.renderer;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.Vector;
import pixel3d.light.Light;
import pixel3d.material.Material;
import pixel3d.math.AABBox;
import pixel3d.math.Color;
import pixel3d.math.Vector2i;
import pixel3d.math.Matrix4;
import flash.geom.Vector3D;
import pixel3d.math.Quaternion;
import pixel3d.math.Vertex;
import pixel3d.math.Vertex4D;
import pixel3d.mesh.MeshBuffer;
import pixel3d.primitives.CubeObject;

class AbstractVideoDriver implements IVideoDriver
{
	private var trianglesDrawn : Int;
	private var screenSize : Vector2i;
	private var ambientColor : Color ;
	private var lights : Vector<Light>;
	private var lightCount : Int;
	private var persDistance : Float;
	private var mipMapDistance : Float;

	private var debugCube : CubeObject;

	private var material : Material;
	private var hasTexture : Bool;
	private var hasLightmap:Bool;

	private var _lightsDir : Vector<Vector3D>;
	private var _lightsPos : Vector<Vector3D>;

	//matrix vars
	private var _view : Matrix4;
	private var _world : Matrix4;
	//ClipScale from NDC to DC Space
	private var _projection : Matrix4;
	private var _current : Matrix4 ;
	private var _view_project : Matrix4;
	private var _world_inv : Matrix4;
	private var _scaleMatrix : Matrix4;

	private var screenRect : Rectangle;

	private var _invCamPos : Vector3D;
	private var _cam_pos : Vector3D;

	//lighting
	private var _light_L : Vector3D ;
	private var _light_N : Vector3D ;
	private var _light_V : Vector3D ;

	private var lighting : Bool;
	private var backfaceCulling : Bool;
	private var frontfaceCulling : Bool;
	private var gouraudShading : Bool;

	private var _scale_m11 : Float ;
	private var _scale_m22 : Float ;
	private var _scale_m41 : Float ;
	private var _scale_m42 : Float ;
	private var renderState : Int;

	private var _clipPlanes : Vector<Quaternion>;
	private var _transformedVertexes : Vector<Vertex4D>;
	private var _unclippedVertices : Vector<Vertex4D>;
	private var _clippedVertices : Vector<Vertex4D>;
	private var _clippedIndices : Vector<Int>;
	private var _clippedVertices0 : Vector<Vertex4D>;
	private var _clippedVertices1 : Vector<Vertex4D>;
	private var _clippedVertices2 : Vector<Vertex4D>;
	private var _clippedVertices3 : Vector<Vertex4D>;
	private var _clippedVertices4 : Vector<Vertex4D>;

	private var _tmpVertex : Vertex4D;

	public function new()
	{
		trianglesDrawn = 0;
		screenSize = new Vector2i(300, 300);
		lights = new Vector<Light>(8, true);
		lightCount = 0;
		persDistance = 400.;
		mipMapDistance = 500.;
		ambientColor = new Color(0, 0, 0);

		debugCube = new CubeObject(10, 10, 10);
		debugCube.getMaterial().transparenting = false;
		debugCube.getMaterial().lighting = false;

		//matrix4
		_scaleMatrix = new Matrix4();
		_current = new Matrix4();
		_view = new Matrix4();
		_projection = new Matrix4();
		_view_project = new Matrix4();
		_world_inv = new Matrix4();
		//lighting
		var count : Int = getMaxLightAmount();
		_lightsDir = new Vector<Vector3D>(count, true);
		_lightsPos = new Vector<Vector3D>(count, true);
		for (i in 0...count)
		{
			_lightsDir[i] = new Vector3D();
			_lightsPos[i] = new Vector3D();
		}
		_invCamPos = new Vector3D();

		_light_L = new Vector3D();
		_light_N = new Vector3D();
		_light_V = new Vector3D();

		//预存一些点
		_transformedVertexes = new Vector<Vertex4D>(2000);
		for (i in 0...2000)
		{
			_transformedVertexes[i] = new Vertex4D();
		}
		_transformedVertexes.fixed = true;
		/*
		generic plane clipping in homogenous coordinates
		special case ndc frustum <-w,w>,<-w,w>,<-w,w>
		can be rewritten with compares e.q near plane, a.z <-a.w and b.z <-b.w
		*/
		_clipPlanes = new Vector<Quaternion>(6, true);
		_clipPlanes[0] = new Quaternion(0.0, 0.0, 1.0, - 1.0 );   // far
		_clipPlanes[1] = new Quaternion(0.0, 0.0, - 1.0, - 1.0 );  // near
		_clipPlanes[2] = new Quaternion(1.0, 0.0, 0.0, - 1.0 );   // left
		_clipPlanes[3] = new Quaternion( - 1.0, 0.0, 0.0, - 1.0 );  // right
		_clipPlanes[4] = new Quaternion(0.0, 1.0, 0.0, - 1.0 );   // bottom
		_clipPlanes[5] = new Quaternion(0.0, - 1.0, 0.0, - 1.0 );  // top

		// arrays for storing clipped vertices & indices
		_clippedIndices = new Vector<Int>();
		_clippedVertices = new Vector<Vertex4D>();
		_unclippedVertices = new Vector<Vertex4D>(3,true);
		for (i in 0...3)
		{
			_unclippedVertices[i] = new Vertex4D();
		}
		_clippedVertices0 = new Vector<Vertex4D>();
		_clippedVertices1 = new Vector<Vertex4D>();
		_clippedVertices2 = new Vector<Vertex4D>();
		_clippedVertices3 = new Vector<Vertex4D>();
		_clippedVertices4 = new Vector<Vertex4D>();

		_tmpVertex = new Vertex4D();
	}

	public function beginScene():Void
	{

	}

	public function endScene():Void
	{

	}

	public function initRenderers():Void
	{

	}

	public function getBitmap():Bitmap
	{
		return null;
	}

	public function clearZBuffer():Void
	{

	}

	public function setRenderState(state:Int):Void
	{

	}

	public function setTransformViewProjection(mat : Matrix4) : Void
	{
		_view_project = mat;
	}
	public function setTransformProjection(mat : Matrix4) : Void
	{
		_projection = mat;
	}
	public function setCameraPosition(pos : Vector3D) : Void
	{
		_cam_pos = pos;
	}
	public function setTransformWorld(mat : Matrix4) : Void
	{
		_world = mat;
		_view_project.prepend2(_world, _current);
		_world.getInvert(_world_inv);
		_world_inv.transformVector2D(_cam_pos, _invCamPos);
	}
	public function setTransformView(mat : Matrix4) : Void
	{
		_view = mat;
		_projection.prepend2(_view, _view_project);
	}

	public function setMaterial(mat : Material) : Void
	{
		this.material = mat;
		hasTexture =(material.texture != null && material.texture.hasTexture());
		hasLightmap =(material.texture2 != null && material.texture2.hasTexture());
		lighting = material.lighting;
		backfaceCulling = material.backfaceCulling;
		frontfaceCulling = material.frontfaceCulling;
		gouraudShading = material.gouraudShading;
		checkCurrentRender();
	}

	public function checkCurrentRender():Void
	{
	}

	public function setDistance(distance : Float) : Void
	{

	}

	public function setScreenSize(size : Vector2i) : Void
	{
		if (size == null) return;
		screenSize = size;
		screenRect = screenSize.toRect();
		_scaleMatrix.buildNDCToDCMatrix(screenSize, 1);
		_scale_m11 = _scaleMatrix.m11;
		_scale_m41 = _scaleMatrix.m41;
		_scale_m22 = _scaleMatrix.m22;
		_scale_m42 = _scaleMatrix.m42;
	}

	//根据物体的深度来判断是否使用MipMap和PerspectiveCorrect
	public function setPerspectiveCorrectDistance(distance : Float = 400.) : Void
	{

	}

	public function setMipMapDistance(distance : Float = 500.) : Void
	{

	}

	public function drawIndexedTriangleList(vertices : Vector<Vertex>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int) : Void
	{

	}

	public function drawMeshBuffer(mesh : MeshBuffer) : Void
	{
		drawIndexedTriangleList(mesh.getVertices(), mesh.getVertexCount(), mesh.getIndices(), mesh.getIndexCount());
	}

	public function drawIndexedTriangleListAmbientLight(vertices : Vector<Vertex>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int) : Void
	{

	}

	public function drawMeshBufferAmbientLight(mesh : MeshBuffer) : Void
	{
		drawIndexedTriangleListAmbientLight(mesh.getVertices(), mesh.getVertexCount(), mesh.getIndices(), mesh.getIndexCount());
	}

	public function getDriverType() : Int
	{
		return VideoDriverType.NULL;
	}
	public function createScreenShot() : BitmapData
	{
		return null;
	}
	// debug
	public function draw3DLine(vs : Vector3D, ve : Vector3D, color : UInt) : Void
	{

	}
	public function draw3DTriangle(v0 : Vertex, v1 : Vertex, v2 : Vertex, color : UInt) : Void
	{

	}

	public function draw3DBox(box : AABBox, color : UInt, alpha : Float, wireframe : Bool = false) : Void
	{
		debugCube.getMaterial().alpha = alpha;
		debugCube.getMaterial().wireframe = wireframe;
		debugCube.setColor(color);
		debugCube.setBox(box);
		setMaterial(debugCube.getMaterial());
		drawMeshBuffer(debugCube);
	}

	public function canShadow() : Bool
	{
		return false;
	}

	public function getScreenSize() : Vector2i
	{
		return screenSize.clone();
	}

	//lights
	/**
	* 环境光，环境光只需要一个，默认颜色为黑色。
	*/
	public function setAmbient(color : UInt) : Void
	{
		ambientColor.color = color;
	}
	public function getAmbient() : Color
	{
		return ambientColor;
	}
	/**
	* 场景中被渲染物体的多边形数量
	*/
	public function getTriangleCountDrawn() : Int
	{
		return trianglesDrawn;
	}

	//--------------------------------light--------------------------------//
	public function removeAllLights() : Void
	{
		lightCount = 0;
	}

	/**
	* 如果灯光数量大于最大数量，则新加入的会替换最后一个
	*/
	public function addLight(light : Light) : Void
	{
		if (light == null) return;
		if (lightCount>= getMaxLightAmount())
		{
			lights[getMaxLightAmount() - 1] = light;
		}
		else
		{
			lights[lightCount] = light;
			lightCount ++;
		}
	}
	public function getMaxLightAmount() : Int
	{
		return 8;
	}
	public function getLightCount() : Int
	{
		return lightCount;
	}
	public function getLight(index : Int) : Light
	{
		if (index <0 || index>= getLightCount()) return null;
		return lights[index];
	}

	public function getMipMapDistance() : Float
	{
		return mipMapDistance;
	}

	public function getPerspectiveCorrectDistance() : Float
	{
		return persDistance;
	}
}
