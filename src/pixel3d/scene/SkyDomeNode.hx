package pixel3d.scene;
import flash.Vector;
import pixel3d.material.ITexture;
import pixel3d.material.Material;
import pixel3d.math.MathUtil;
import pixel3d.math.Matrix4;
import pixel3d.math.Vertex;
import pixel3d.mesh.MeshBuffer;
import pixel3d.renderer.IVideoDriver;

/** horiRes and vertRes:
 *  Controls the number of faces along the horizontal axis(30 is a good value)
 * 	and the number of faces along the vertical axis(8 is a good value).
 *
 * 	texturePercentage:
 * 	Only the top texturePercentage of the image is used, e.g. 0.8 uses the top 80% of the image,
 * 	1.0 uses the entire image. This is useful as some landscape images have a small banner
 * 	at the bottom that you don't want.
 *
 * 	spherePercentage:
 * 	This controls how far around the sphere the sky dome goes. For value 1.0 you get exactly the upper
 * 	hemisphere, for 1.1 you get slightly more, and for 2.0 you get a full sphere. It is sometimes useful
 * 	to use a value slightly bigger than 1 to avoid a gap between some ground place and the sky. This
 * 	parameters stretches the image to fit the chosen "sphere-size".
 */
class SkyDomeNode extends SceneNode
{
	private var texture:ITexture;
	private var horizontalResolution:Int;
	private var verticalResolution:Int;
	private var texturePercentage:Float;
	private var spherePercentage:Float;
	private var radius:Float;

	private var buffer:MeshBuffer;
	private var _tmpMatrix : Matrix4;
	/**
	 *
	 * @param	mgr
	 * @param	texture
	 * @param	spherePercentage
	 * @param	horiRes
	 * @param	vertRes
	 * @param	texturePercentage
	 * @param	radiu
	 */
	public function new(texture:ITexture,
						spherePercentage:Float = 2.0, horiRes:Int = 20, vertRes:Int = 8,
						texturePercentage:Float=1,radius:Float=500)
	{
		super();

		autoCulling = false;
		_tmpMatrix = new Matrix4();
		debug = false;

		this.texture = texture;
		this.horizontalResolution = horiRes;
		this.verticalResolution = vertRes;
		this.texturePercentage = texturePercentage;
		this.spherePercentage = spherePercentage;
		this.radius = radius;

		buffer = new MeshBuffer();
		buffer.getMaterial().wireframe = false;
		buffer.getMaterial().lighting = false;
		buffer.getMaterial().zBuffer = false;
		buffer.getMaterial().gouraudShading = false;
		buffer.getMaterial().setTexture(texture);

		// regenerate the meshBuffer
		generateMeshBuffer();
	}

	private function generateMeshBuffer():Void
	{
		var azimuth_step:Float = MathUtil.TWO_PI / horizontalResolution;

		if (spherePercentage <0.) spherePercentage = -spherePercentage;
		if (spherePercentage> 2.) spherePercentage = 2.;

		var elevation_step:Float = spherePercentage * MathUtil.HALF_PI / verticalResolution;

		var vertices:Vector<Vertex> = buffer.getVertices();
		var indices:Vector<Int> = buffer.getIndices();

		var sin = Math.sin;
		var cos = Math.cos;
		var tcV:Float = texturePercentage / verticalResolution;
		var azimuth:Float = 0;
		for (k in 0...(horizontalResolution+1))
		{
			var elevation:Float = MathUtil.HALF_PI;
			var tcU :Float= k / horizontalResolution;
			var sinA:Float = sin(azimuth);
			var cosA:Float = cos(azimuth);
			for (j in 0...(verticalResolution+1))
			{
				var cosEr:Float = radius * cos(elevation);

				var vtx:Vertex = new Vertex();
				vtx.color = 0xffffffff;
				vtx.x = cosEr * sinA;
				vtx.y = radius * sin(elevation);
				vtx.z = cosEr * cosA;
				vtx.u = tcU;
				vtx.v = j * tcV;
				vtx.nx = -vtx.x;
				vtx.ny = -vtx.y;
				vtx.nz = -vtx.z;
				vtx.normalize();

				vertices.push(vtx);
				elevation -= elevation_step;
			}
			azimuth += azimuth_step;
		}

		for (k in 0...horizontalResolution)
		{
			indices.push(verticalResolution + 2 +(verticalResolution + 1) * k);
			indices.push(1 +(verticalResolution + 1) * k);
			indices.push(0 +(verticalResolution + 1) * k);

			for (j in 1...verticalResolution)
			{
				indices.push(verticalResolution + 2 +(verticalResolution + 1) * k + j);
				indices.push(1 +(verticalResolution + 1) * k + j);
				indices.push(0 +(verticalResolution + 1) * k + j);

				indices.push(verticalResolution + 1 +(verticalResolution + 1) * k + j);
				indices.push(verticalResolution + 2 +(verticalResolution + 1) * k + j);
				indices.push(0 +(verticalResolution + 1) * k + j);
			}
		}
	}

	override public function render() : Void
	{
		var driver : IVideoDriver = sceneManager.getVideoDriver();
		var camera : CameraNode = sceneManager.getActiveCamera();
		if (driver == null || camera == null) return;

		_tmpMatrix.setTranslation(camera.getAbsolutePosition());

		driver.setDistance(0);
		driver.setTransformWorld(_tmpMatrix);
		driver.setMaterial(buffer.getMaterial());
		driver.drawMeshBuffer(buffer);
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
		return buffer.getMaterial();
	}
	override public function getMaterialCount() : Int
	{
		return 1;
	}
}