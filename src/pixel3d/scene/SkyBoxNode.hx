﻿package pixel3d.scene;
import flash.Vector;
import pixel3d.material.ITexture;
import pixel3d.material.Material;
import pixel3d.math.Matrix4;
import pixel3d.math.Vertex;
import pixel3d.renderer.IVideoDriver;
class SkyBoxNode extends SceneNode
{
	private var topVertices : Vector<Vertex>;
	private var topMaterial : Material;
	private var bottomVertices : Vector<Vertex>;
	private var bottomMaterial : Material;
	private var leftVertices : Vector<Vertex>;
	private var leftMaterial : Material;
	private var rightVertices : Vector<Vertex>;
	private var rightMaterial : Material;
	private var frontVertices : Vector<Vertex>;
	private var frontMaterial : Material;
	private var backVertices : Vector<Vertex>;
	private var backMaterial : Material;

	private var indices : Vector<Int>;
	private var materials : Vector<Material>;
	private var _tmpMatrix : Matrix4;
	public function new(
		top : ITexture,bottom : ITexture,
		left : ITexture,right : ITexture,
		front : ITexture,back : ITexture)
	{
		super();

		_tmpMatrix = new Matrix4();
		debug = false;
		autoCulling = false;

		materials = new Vector<Material>(6, true);
		// create indices
		indices = new Vector<Int>(6, true);
		indices[0] = 0;
		indices[1] = 1;
		indices[2] = 2;
		indices[3] = 0;
		indices[4] = 2;
		indices[5] = 3;

		// create front side
		var l : Float = 999.;
		frontMaterial = new Material();
		frontMaterial.wireframe = false;
		frontMaterial.gouraudShading = false;
		frontMaterial.lighting = false;
		frontMaterial.zBuffer = false;
		frontMaterial.texture = front;
		materials[0] = frontMaterial;
		var clr : UInt = 0xFFFFFF;
		frontVertices = new Vector<Vertex>(4, true);
		frontVertices[0] = new Vertex( - l, - l, - l, 0, 0, 1, clr, 1, 1);
		frontVertices[1] = new Vertex(l, - l, - l, 0, 0, 1, clr, 0, 1);
		frontVertices[2] = new Vertex(l, l, - l, 0, 0, 1, clr, 0, 0);
		frontVertices[3] = new Vertex( - l, l, - l, 0, 0, 1, clr, 1, 0);

		// create left side
		leftMaterial = new Material();
		leftMaterial.wireframe = false;
		leftMaterial.gouraudShading = false;
		leftMaterial.lighting = false;
		leftMaterial.zBuffer = false;
		leftMaterial.texture = left;
		materials[1] = leftMaterial;
		leftVertices = new Vector<Vertex>(4, true);
		leftVertices[0] = new Vertex(l, - l, - l, - 1, 0, 0, clr, 1, 1);
		leftVertices[1] = new Vertex(l, - l, l, - 1, 0, 0, clr, 0, 1);
		leftVertices[2] = new Vertex(l, l, l, - 1, 0, 0, clr, 0, 0);
		leftVertices[3] = new Vertex(l, l, - l, - 1, 0, 0, clr, 1, 0);

		// create back side
		backMaterial = new Material();
		backMaterial.wireframe = false;
		backMaterial.gouraudShading = false;
		backMaterial.lighting = false;
		backMaterial.zBuffer = false;
		backMaterial.texture = back;
		materials[2] = backMaterial;
		backVertices = new Vector<Vertex>(4, true);
		backVertices[0] = new Vertex(l, - l, l, 0, 0, - 1, clr, 1, 1);
		backVertices[1] = new Vertex( - l, - l, l, 0, 0, - 1, clr, 0, 1);
		backVertices[2] = new Vertex( - l, l, l, 0, 0, - 1, clr, 0, 0);
		backVertices[3] = new Vertex(l, l, l, 0, 0, - 1, clr, 1, 0);

		// create right side
		rightMaterial = new Material();
		rightMaterial.wireframe = false;
		rightMaterial.gouraudShading = false;
		rightMaterial.lighting = false;
		rightMaterial.zBuffer = false;
		rightMaterial.texture = right;
		materials[3] = rightMaterial;
		rightVertices = new Vector<Vertex>(4, true);
		rightVertices[0] = new Vertex( - l, - l, l, 1, 0, 0, clr, 1, 1);
		rightVertices[1] = new Vertex( - l, - l, - l, 1, 0, 0, clr, 0, 1);
		rightVertices[2] = new Vertex( - l, l, - l, 1, 0, 0, clr, 0, 0);
		rightVertices[3] = new Vertex( - l, l, l, 1, 0, 0, clr, 1, 0);

		// create top side
		topMaterial = new Material();
		topMaterial.wireframe = false;
		topMaterial.gouraudShading = false;
		topMaterial.lighting = false;
		topMaterial.zBuffer = false;
		topMaterial.texture = top;
		materials[4] = topMaterial;
		topVertices = new Vector<Vertex>(4, true);
		topVertices[0] = new Vertex(l, l, - l, 0, - 1, 0, clr, 1, 1);
		topVertices[1] = new Vertex(l, l, l, 0, - 1, 0, clr, 0, 1);
		topVertices[2] = new Vertex( - l, l, l, 0, - 1, 0, clr, 0, 0);
		topVertices[3] = new Vertex( - l, l, - l, 0, - 1, 0, clr, 1, 0);

		// create bottom side
		bottomMaterial = new Material();
		bottomMaterial.wireframe = false;
		bottomMaterial.gouraudShading = false;
		bottomMaterial.lighting = false;
		bottomMaterial.zBuffer = false;
		bottomMaterial.texture = bottom;
		materials[5] = bottomMaterial;
		bottomVertices = new Vector<Vertex>(4, true);
		bottomVertices[0] = new Vertex(l, - l, l, 0, 1, 0, clr, 0, 0);
		bottomVertices[1] = new Vertex(l, - l, - l, 0, 1, 0, clr, 1, 0);
		bottomVertices[2] = new Vertex( - l, - l, - l, 0, 1, 0, clr, 1, 1);
		bottomVertices[3] = new Vertex( - l, - l, l, 0, 1, 0, clr, 0, 1);
	}

	override public function render() : Void
	{
		var driver : IVideoDriver = sceneManager.getVideoDriver();
		var camera : CameraNode = sceneManager.getActiveCamera();
		if (driver == null || camera == null) return;
		_tmpMatrix.setTranslation(camera.getAbsolutePosition());
		driver.setDistance(0);
		driver.setTransformWorld(_tmpMatrix);
		//front
		driver.setMaterial(frontMaterial);
		driver.drawIndexedTriangleList(frontVertices, 4, indices, 6);
		//left
		driver.setMaterial(leftMaterial);
		driver.drawIndexedTriangleList(leftVertices, 4, indices, 6);
		//back
		driver.setMaterial(backMaterial);
		driver.drawIndexedTriangleList(backVertices, 4, indices, 6);
		//right
		driver.setMaterial(rightMaterial);
		driver.drawIndexedTriangleList(rightVertices, 4, indices, 6);
		//top
		driver.setMaterial(topMaterial);
		driver.drawIndexedTriangleList(topVertices, 4, indices, 6);
		//bottom
		driver.setMaterial(bottomMaterial);
		driver.drawIndexedTriangleList(bottomVertices, 4, indices, 6);
	}

	override public function onRegisterSceneNode() : Void
	{
		if (visible)
		{
			sceneManager.registerNodeForRendering(this, SceneNodeType.SKYBOX);
			super.onRegisterSceneNode();
		}
	}

	override public function getMaterial(i : Int = 0) : Material
	{
		if (i <0) i = 0;
		if (i>= 5) i = 5;
		return materials[i];
	}

	override public function getMaterialCount() : Int
	{
		return 6;
	}
}
