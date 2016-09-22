package pixel3d.scene;
import pixel3d.math.MathUtil;
import flash.geom.Vector3D;
import pixel3d.math.AABBox;
import pixel3d.math.Vector2i;
import pixel3d.math.Matrix4;
import pixel3d.math.Vector3DUtil;
import pixel3d.scene.CameraSceneNode;
import pixel3d.scene.CameraSceneNode;
import pixel3d.scene.CameraSceneNode;
import pixel3d.scene.CameraSceneNode;
import pixel3d.scene.CameraSceneNode;
import pixel3d.scene.CameraSceneNode;
import pixel3d.scene.CameraSceneNode;
import pixel3d.scene.CameraSceneNode;
import pixel3d.scene.CameraSceneNode;
import pixel3d.renderer.IVideoDriver;

class CameraSceneNode extends SceneNode
{
	private var _fovy : Float;// Field of view, in radians.
	private var _aspect : Float;// Aspect ratio.
	private var _near : Float;// value of the near view-plane.
	private var _far : Float;// Z-value of the far view-plane.

	private var _view : Matrix4;
	private var _projection : Matrix4;
	private var _view_projection : Matrix4;
	private var _affector:Matrix4;
	private var _viewArea : ViewFrustum;

	private var _upVector : Vector3D;
	private var _target : Vector3D;

	private var targetAndRotationAreBound:Bool;
	private var inputReceiverEnabled:Bool;
	private var isOrthogonal:Bool;

	/*private*/
	private var _tgtv : Vector3D ;
	private var _tmp_up : Vector3D ;
	private var _tmp_position : Vector3D ;

	public function new(lookat : Vector3D = null)
	{
		super();

		autoCulling = false;
		inputReceiverEnabled = true;
		targetAndRotationAreBound = false;
		isOrthogonal = false;

		_view = new Matrix4();
		_projection = new Matrix4();
		_view_projection = new Matrix4();
		_affector = new Matrix4();
		_viewArea = new ViewFrustum();

		// set default projection
		_fovy = MathUtil.PI / 2.5;// Field of view, in radians.

		_aspect = 4.0 / 3.0;
		_near = 1.;
		_far = 3000.;
		_upVector = new Vector3D(0., 1., 0.);

		if (lookat != null)
		{
			_target = lookat;
		}
		else
		{
			_target = new Vector3D(0., 0., 0.);
		}

		_tgtv = new Vector3D();
		_tmp_up = new Vector3D();
		_tmp_position = new Vector3D();

		recalculateProjectionMatrix();
	}

	/**
	 * Disables or enables the camera to get key or mouse inputs.
	 * @param	enabled
	 */
	public function setInputReceiverEnabled(enabled:Bool):Void
	{
		inputReceiverEnabled = enabled;
	}

	/**
	 *
	 * @return if the input receiver of the camera is currently enabled.
	 */
	public function isInputReceiverEnabled():Bool
	{
		return inputReceiverEnabled;
	}

	/**
	 *
	 * @param	projection The new projection matrix of the camera
	 * @param	isOrthogonal
	 */
	public function setProjectionMatrix(projection:Matrix4, isOrthogonal:Bool):Void
	{
		this.isOrthogonal = isOrthogonal;
		this._projection = projection;
	}

	/**
	 * Gets the current projection matrix of the camera
	 * @return the current projection matrix of the camera.
	 */
	public function getProjectionMatrix() : Matrix4
	{
		return _projection;
	}

	/**
	 * Sets a custom view matrix affector. The matrix passed here, will be
	 * multiplied with the view matrix when it gets updated.
	 * This allows for custom camera setups like, for example, a reflection camera.
	 * @param	affector The affector matrix.
	 */
	public function setAffector(affector:pixel3d.math.Matrix4):Void
	{
		_affector = affector;
	}

	/**
	 * Gets the custom view matrix affector.
	 * @return the custom view matrix affector.
	 */
	public function getAffector():pixel3d.math.Matrix4
	{
		return _affector;
	}

	public function getViewFrustum() : ViewFrustum
	{
		return _viewArea;
	}

	override public function onRegisterSceneNode() : Void
	{
		//if (sceneManager.getActiveCamera() == this)
		//{
		//sceneManager.registerNodeForRendering(this, SceneNodeType.CAMERA);
		//}

		super.onRegisterSceneNode();
	}

	override public function render() : Void
	{
		_tmp_position.x = _absoluteTransformation.m41;
		_tmp_position.y = _absoluteTransformation.m42;
		_tmp_position.z = _absoluteTransformation.m43;

		_tgtv.x = _target.x - _tmp_position.x;
		_tgtv.y = _target.y - _tmp_position.y;
		_tgtv.z = _target.z - _tmp_position.z;
		_tgtv.normalize();

		// if upvector and vector to the target are the same, we have a
		// problem. so solve this problem:
		_tmp_up.x = _upVector.x;
		_tmp_up.y = _upVector.y;
		_tmp_up.z = _upVector.z;
		_tmp_up.normalize();

		var dp : Float = _tgtv.dotProduct(_tmp_up);
		if (MathUtil.abs(dp) == 1.0)
		{
			_tmp_up.x += 0.5;
		}

		_view.buildCameraLookAtMatrix(_tmp_position, _target, _tmp_up);
		_view.prepend(_affector);
		recalculateViewArea();

		var driver:IVideoDriver = sceneManager.getVideoDriver();
		if (driver != null)
		{
			driver.setCameraPosition(_tmp_position);
			driver.setTransformViewProjection(_view_projection);
		}
	}

	public function setFOV(fov : Float) : Void
	{
		_fovy = fov;
		recalculateProjectionMatrix();
	}

	public function setAspectRatio(f : Float) : Void
	{
		_aspect = f;
		recalculateProjectionMatrix();
	}

	public function setNear(zn : Int) : Void
	{
		_near = zn;
		recalculateProjectionMatrix();
	}

	public function setFar(zf : Int) : Void
	{
		_far = zf;
		recalculateProjectionMatrix();
	}

	public function getFOV() : Float
	{
		return _fovy;
	}

	public function getAspectRatio() : Float
	{
		return _aspect;
	}

	public function getNear() : Float
	{
		return _near;
	}

	public function getFar() : Float
	{
		return _far;
	}

	public function getViewMatrix() : Matrix4
	{
		return _view;
	}

	public function getViewProjectionMatrix() : Matrix4
	{
		return _view_projection;
	}

	public function recalculateProjectionMatrix() : Void
	{
		_projection.buildProjectionMatrixPerspectiveFov(_fovy, _aspect, _near, _far);
	}

	public inline function recalculateViewArea() : Void
	{
		_viewArea.cameraPosition = getAbsolutePosition();

		_projection.prepend2(_view, _view_projection);

		_viewArea.setFrom(_view_projection);
	}

	/**
	 * sets the look at target of the camera
	 * @param pos Look at target of the camera.
	 */
	public function setTarget(pos : Vector3D) : Void
	{
		_target = pos;

		if (targetAndRotationAreBound)
		{
			var toTarget:Vector3D = _target.subtract(getAbsolutePosition());
			setRotation(Vector3DUtil.getHorizontalAngle(toTarget));
		}
	}

	/**
	 * Gets the current look at target of the camera
	 * @return the current look at target of the camera
	 */
	public function getTarget() : Vector3D
	{
		return _target;
	}

	/**
	 * Sets the rotation of the node.
	 * This only modifies the relative rotation of the node.
	 * If the camera's target and rotation are bound ( @see bindTargetAndRotation() )
	 * then calling this will also change the camera's target to match the rotation.
	 * @param rotation New rotation of the node in degrees.
	 */
	override public function setRotation(rotation:Vector3D):Void
	{
		if (targetAndRotationAreBound)
		{
			_target = getAbsolutePosition().add(Vector3DUtil.rotationToDirection(rotation));
		}
		super.setRotation(rotation);
	}

	/**
	 * sets the up vector of the camera
	 * @param	pos New upvector of the camera.
	 */
	public function setUpVector(pos:Vector3D):Void
	{
		_upVector = pos;
	}

	/**
	 * Gets the up vector of the camera.
	 * @return the up vector of the camera.
	 */
	public function getUpVector() : Vector3D
	{
		return _upVector;
	}

	override public function getBoundingBox():AABBox
	{
		return _viewArea.getBoundingBox();
	}

	/**
	 * Set the binding between the camera's rotation adn target.
	 * @param	bound
	 */
	public function bindTargetAndRotation(bound:Bool):Void
	{
		targetAndRotationAreBound = bound;
	}

	/**
	 * Gets the binding between the camera's rotation and target.
	 * @return
	 */
	public function getTargetAndRotationBinding():Bool
	{
		return targetAndRotationAreBound;
	}

	override public function getType():Int
	{
		return SceneNodeType.CAMERA;
	}
}
