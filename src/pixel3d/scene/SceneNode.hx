package pixel3d.scene;
import flash.display.Shape;
import flash.events.EventDispatcher;
import flash.Vector;
import pixel3d.animator.IAnimator;
import pixel3d.material.ITexture;
import pixel3d.material.Material;
import pixel3d.math.AABBox;
import pixel3d.math.MathUtil;
import pixel3d.math.Matrix4;
import flash.geom.Vector3D;
import pixel3d.utils.UserData;

//TODO 需要添加事件
class SceneNode extends EventDispatcher
{
	private var _parent : SceneNode;
	private var _children : Vector<SceneNode>;
	private var _numChildren : Int;
	private var _animators : Vector<IAnimator>;
	private var _animatorCount : Int;

	//世界坐标系下的信息
	private var _absoluteTransformation : Matrix4;
	private var _absolutePosition:Vector3D;
	//相对，本地坐标系下的信息
	private var _relativeTransformation : Matrix4;
	private var _relativeTranslation : Vector3D;
	private var _relativeRotation : Vector3D;
	private var _relativeScale : Vector3D;

	//场景管理器
	private var _sceneManager : ISceneManager;
	//包围盒
	private var boundingBox:AABBox;

	// 用于判断物体材质信息
	private var _material_solid:Bool;
	private var _material_transparent:Bool;

	//for debug
	public var debug : Bool;
	public var debugColor : UInt;
	public var debugAlpha : Float;
	public var debugWireframe : Bool;

	public var distance : Float ;
	public var autoCulling : Bool;
	public var visible : Bool ;
	public var id : Int;
	public var name:String;

	//设置鼠标是否响应，以及是否显示按钮模式
	public var buttonMode:Bool;
	public var mouseEnabled:Bool;
	public var mouseChildren:Bool;
	public var doubleClickEnabled:Bool;

	public var userData:UserData;//用户自定义信息

	//get and set
	public var x(get, set) : Float;
	public var y(get, set) : Float;
	public var z(get, set) : Float;
	public var scaleX(get, set) : Float;
	public var scaleY(get, set) : Float;
	public var scaleZ(get, set) : Float;
	public var rotationX(get, set) : Float;
	public var rotationY(get, set) : Float;
	public var rotationZ(get, set) : Float;
	public var parent(get, never) : SceneNode;
	public var numChildren(get,never) : Int;
	public var sceneManager(get, set) : ISceneManager;

	private static var ID:Int = 0;

	/**
	 * A scene node is a node in the hierarchical scene graph. Every scene
	 * node may have children, which are also scene nodes. Children move
	 * relative to their parent's position. If the parent of a node is not
	 * visible, its children won't be visible either. In this way, it is for
	 * example easily possible to attach a light to a moving car, or to place
	 * a walking character on a moving platform on a moving ship.
	 */
	public function new()
	{
		super();

		id = ID++;

		_relativeTranslation = new Vector3D(0., 0., 0.);
		_relativeRotation = new Vector3D(0., 0., 0.);
		_relativeScale = new Vector3D(1., 1., 1.);
		_absolutePosition = new Vector3D();
		_absoluteTransformation = new Matrix4();
		_relativeTransformation = new Matrix4();
		_children = new Vector<SceneNode>();
		_animators = new Vector<IAnimator>();
		_numChildren = 0;
		_animatorCount = 0;

		boundingBox = new AABBox();

		distance = 0.;
		visible = true;
		autoCulling = true;
		buttonMode = false;
		mouseEnabled = true;
		mouseChildren = true;
		doubleClickEnabled = false;

		userData = new UserData();

		//debug
		debug = false;
		debugColor = 0xffffff;
		debugAlpha = 0.7;
		debugWireframe = false;
	}

	public function getID():Int
	{
		return id;
	}

	public function addChild(child : SceneNode) : Void
	{
		if (child != null && child != this)
		{
			child.removeFromParent();

			child._parent = this;

			_children[_numChildren++] = child;

			if (_sceneManager != null)
			{
				child.sceneManager = _sceneManager;
			}
		}
	}

	public function removeChild(child : SceneNode) : Bool
	{
		var i : Int = _children.indexOf(child);
		if (i == - 1) return false;

		child._parent = null;
		child._sceneManager = null;

		_children.splice(i, 1);
		_numChildren --;

		return true;
	}

	/**
	 * 删除所有Children
	 */
	public function removeAll() : Void
	{
		var child:SceneNode;
		for (i in 0..._numChildren)
		{
			child = _children[i];
			child._parent = null;
			child._sceneManager = null;
		}
		_children.length = 0;
		_numChildren = 0;
	}

	public function removeFromParent() : Void
	{
		if (_parent != null)
		{
			_parent.removeChild(this);
		}
	}

	public function hasChild(child : SceneNode) : Bool
	{
		return child.parent == this;
	}

	public function getChildAt(i : Int) : SceneNode
	{
		if (i <0 || i>= _numChildren) return null;
		return _children[i];
	}

	public function setParent(newParent : SceneNode) : SceneNode
	{
		if (_parent != null)
		{
			_parent.removeChild(this);
		}

		_parent = newParent;

		if (_parent != null)
		{
			_parent.addChild(this);
		}

		return _parent;
	}

	public function addAnimator(animator : IAnimator) : Void
	{
		if (animator != null)
		{
			_animators[_animatorCount++] = animator;
		}
	}

	public function removeAnimator(animator : IAnimator) : Bool
	{
		var idx : Int = _animators.indexOf(animator);

		if (idx == - 1) return false;

		_animators.splice(idx, 1);

		_animatorCount --;

		return true;
	}

	public function removeAnimators() : Void
	{
		_animators.length = 0;
		_animatorCount = 0;
	}

	public function getAnimatorCount() : Int
	{
		return _animatorCount;
	}

	public function getMaterial(i : Int = 0) : Material
	{
		return null;
	}

	public function getMaterialCount() : Int
	{
		return 0;
	}

	/**
	 * 用来判断材质是透明还是不透明
	 * 渲染是需要这个信息
	 * 只用于VideoSoftware32
	 */
	public function updateMaterialTypes():Void
	{
		// loop all materials and work out type
		var mat_type_transparent:Int = 0;
		var mat_type_solid:Int = 0;

		var count:Int = getMaterialCount();
		for (i in 0...count)
		{
			var material:Material = getMaterial(i);
			if (!material.transparenting)
			{
				mat_type_solid++;
			}
			else
			{
				mat_type_transparent++;
			}

			if (mat_type_transparent > 0 && mat_type_solid > 0)
			{
				// node contains materials that both transparent and solid
				_material_solid = true;
				_material_transparent = true;
				return;
			}
		}

		// must be solid or transparent or no material
		if (mat_type_solid> 0)
		{
			_material_solid = true;
		}
		else if (mat_type_transparent> 0)
		{
			_material_transparent = true;
		}
		else
		{
			// no materials
			_material_solid = false;
			_material_transparent = false;
		}
	}

	public function setMaterialFlag(flag : Int, value : Bool) : Void
	{
		var count : Int = getMaterialCount();
		var material : Material;
		for (i in 0...count)
		{
			material = getMaterial(i);
			if (material != null)
			{
				material.setFlag(flag, value);
			}
		}
	}

	public function setMaterialTexture(texture : ITexture, layer : Int = 1) : Void
	{
		if (layer <1 || layer> 2) return;
		var count : Int = getMaterialCount();
		var material : Material;
		for (i in 0...count)
		{
			material = getMaterial(i);
			if (material != null)
			{
				material.setTexture(texture, layer);
			}
		}
	}

	/**
	* 设置所有materials的透明度
	*/
	public function setMaterialAlpha(alpha : Float) : Void
	{
		var count : Int = getMaterialCount();
		var material : Material;
		for (i in 0...count)
		{
			material = getMaterial(i);
			if (material != null)
			{
				material.alpha = alpha;
			}
		}
	}

	public function setMaterialColor(diffuse : UInt = 0xFFFFFF, ambient : UInt = 0xFFFFFF, emissive : UInt = 0x0000FF, specular : UInt = 0x0000FF) : Void
	{
		var count : Int = getMaterialCount();
		var material : Material;
		for (i in 0...count)
		{
			material = getMaterial(i);
			if (material != null)
			{
				material.diffuseColor.color = diffuse;
				material.ambientColor.color = ambient;
				material.emissiveColor.color = emissive;
				material.specularColor.color = specular;
			}
		}
	}

	public function setMaterialDiffuseColor(color : UInt) : Void
	{
		var count : Int = getMaterialCount();
		var material : Material;
		for (i in 0...count)
		{
			material = getMaterial(i);
			if (material != null)
			{
				material.diffuseColor.color = color;
			}
		}
	}

	public function setMaterialAmbientColor(color : UInt) : Void
	{
		var count : Int = getMaterialCount();
		var material : Material;
		for (i in 0...count)
		{
			material = getMaterial(i);
			if (material != null)
			{
				material.ambientColor.color = color;
			}
		}
	}

	public function setMaterialEmissiveColor(color : UInt) : Void
	{
		var count : Int = getMaterialCount();
		var material : Material;
		for (i in 0...count)
		{
			material = getMaterial(i);
			if (material != null)
			{
				material.emissiveColor.color = color;
			}
		}
	}

	public function setMaterialSpecularColor(color : UInt) : Void
	{
		var count : Int = getMaterialCount();
		var material : Material;
		for (i in 0...count)
		{
			material = getMaterial(i);
			if (material != null)
			{
				material.specularColor.color = color;
			}
		}
	}

	public function onRegisterSceneNode() : Void
	{
		if (visible)
		{
			for (i in 0..._numChildren)
			{
				_children[i].onRegisterSceneNode();
			}
		}
	}

	public function onAnimate(timeMs : Int) : Void
	{
		if (visible)
		{
			for (i in 0..._animatorCount)
			{
				_animators[i].animateNode(this, timeMs);
			}

			updateAbsolutePosition();

			for (i in 0..._numChildren)
			{
				_children[i].onAnimate(timeMs);
			}
		}
	}

	public function render() : Void
	{
	}

	/**
	 * 仅用环境光绘制
	 * 只用在VideoSoftware32中
	 */
	public function renderAmbientLight() : Void
	{
	}

	/**
	 * 需要ShadowMap时使用
	 */
	public function renderShadowMap() : Void
	{
	}

	public function updateAbsolutePosition() : Void
	{
		_relativeTransformation.identity();
		_relativeTransformation.setRotation(_relativeRotation,true);
		_relativeTransformation.setTranslation(_relativeTranslation);
		if (_relativeScale.x != 1.0 || _relativeScale.y != 1.0 || _relativeScale.z != 1.0)
		{
			_relativeTransformation.multiplyVector3D(_relativeScale);
		}

		if (_parent != null)
		{
			var absolute : Matrix4 = _parent.getAbsoluteTransformation();
			_absoluteTransformation.m11 = absolute.m11 * _relativeTransformation.m11 + absolute.m21 * _relativeTransformation.m12 + absolute.m31 * _relativeTransformation.m13;
			_absoluteTransformation.m12 = absolute.m12 * _relativeTransformation.m11 + absolute.m22 * _relativeTransformation.m12 + absolute.m32 * _relativeTransformation.m13;
			_absoluteTransformation.m13 = absolute.m13 * _relativeTransformation.m11 + absolute.m23 * _relativeTransformation.m12 + absolute.m33 * _relativeTransformation.m13;
			_absoluteTransformation.m14 = 0.0;
			_absoluteTransformation.m21 = absolute.m11 * _relativeTransformation.m21 + absolute.m21 * _relativeTransformation.m22 + absolute.m31 * _relativeTransformation.m23;
			_absoluteTransformation.m22 = absolute.m12 * _relativeTransformation.m21 + absolute.m22 * _relativeTransformation.m22 + absolute.m32 * _relativeTransformation.m23;
			_absoluteTransformation.m23 = absolute.m13 * _relativeTransformation.m21 + absolute.m23 * _relativeTransformation.m22 + absolute.m33 * _relativeTransformation.m23;
			_absoluteTransformation.m24 = 0.0;
			_absoluteTransformation.m31 = absolute.m11 * _relativeTransformation.m31 + absolute.m21 * _relativeTransformation.m32 + absolute.m31 * _relativeTransformation.m33;
			_absoluteTransformation.m32 = absolute.m12 * _relativeTransformation.m31 + absolute.m22 * _relativeTransformation.m32 + absolute.m32 * _relativeTransformation.m33;
			_absoluteTransformation.m33 = absolute.m13 * _relativeTransformation.m31 + absolute.m23 * _relativeTransformation.m32 + absolute.m33 * _relativeTransformation.m33;
			_absoluteTransformation.m34 = 0.0;
			_absoluteTransformation.m41 = absolute.m11 * _relativeTransformation.m41 + absolute.m21 * _relativeTransformation.m42 + absolute.m31 * _relativeTransformation.m43 + absolute.m41;
			_absoluteTransformation.m42 = absolute.m12 * _relativeTransformation.m41 + absolute.m22 * _relativeTransformation.m42 + absolute.m32 * _relativeTransformation.m43 + absolute.m42;
			_absoluteTransformation.m43 = absolute.m13 * _relativeTransformation.m41 + absolute.m23 * _relativeTransformation.m42 + absolute.m33 * _relativeTransformation.m43 + absolute.m43;
			_absoluteTransformation.m44 = 1.0;
		}
		else
		{
			_absoluteTransformation.copy(_relativeTransformation);
		}

		_absoluteTransformation.getTranslation(_absolutePosition);
	}

	public function getBoundingBox() : AABBox
	{
		return boundingBox;
	}

	public function getTransformedBoundingBox():AABBox
	{
		var box:AABBox = new AABBox();
		box.resetAABBox(boundingBox);
		_absoluteTransformation.transformBoxEx(box);
		return box;
	}

	public function getAbsoluteTransformation() : Matrix4
	{
		return _absoluteTransformation;
	}

	public function getRelativeTransformation() : Matrix4
	{
		return _relativeTransformation;
	}

	public function getAbsolutePosition() : Vector3D
	{
		return _absolutePosition;
	}

	// sets rotation so that the scene node faces
	public function lookAt(target:Vector3D):Void
	{
		var tx:Float = target.x - _absolutePosition.x;
		var ty:Float = target.y - _absolutePosition.y;
		var tz:Float = target.z - _absolutePosition.z;

		var xz_length:Float = MathUtil.sqrt(tx * tx + tz * tz);

		// set rotation
		_relativeRotation.x = Math.atan2( -ty, xz_length);
		_relativeRotation.y = Math.atan2(tx, tz);
		_relativeRotation.z = 0;
	}

	//TODO
	public function clone() : SceneNode
	{
		return null;
	}

	override public function toString() : String
	{
		return name;
	}

	//read only
	public inline function getChildren() :Vector<SceneNode>
	{
		return _children;
	}

	public inline function getAnimators() :Vector<IAnimator>
	{
		return _animators;
	}

	private function set_sceneManager(manager : ISceneManager) : ISceneManager
	{
		_sceneManager = manager;
		for (i in 0..._numChildren)
		{
			_children[i]._sceneManager = manager;
		}
		return manager;
	}

	private function get_sceneManager() : ISceneManager
	{
		return _sceneManager;
	}

	/**
	 * 测试是否该Node完全可见，parent不可见则自己也不可见
	 * @return
	 */
	public function isTrulyVisible() : Bool
	{
		if (!visible) return false;
		if (parent == null) return true;
		return parent.isTrulyVisible();
	}

	public function isTrulyMouseChildren():Bool
	{
		if (!mouseChildren) return false;
		if (_parent == null) return true;
		return _parent.isTrulyMouseChildren();
	}

	//判断一个物体是否真的可响应鼠标，需要判断parent的mouseChildren属性
	public function isTrulyMouseEnabled():Bool
	{
		if (!mouseEnabled)
		{
			return false;
		}
		else if (_parent == null)
		{
			return true;
		}
		else
		{
			return _parent.isTrulyMouseChildren();
		}
	}

	public function getPosition() : Vector3D
	{
		return _relativeTranslation.clone();
	}

	public function getRotation() : Vector3D
	{
		return _relativeRotation.clone();
	}

	public function setPosition(pos : Vector3D) : Void
	{
		_relativeTranslation = pos.clone();
	}

	public function setPositionXYZ(x : Float, y : Float, z : Float) : Void
	{
		_relativeTranslation.x = x;
		_relativeTranslation.y = y;
		_relativeTranslation.z = z;
	}

	public function setRotationXYZ(rx : Float, ry : Float, rz : Float) : Void
	{
		_relativeRotation.x = rx;
		_relativeRotation.y = ry;
		_relativeRotation.z = rz;
	}

	public function setRotation(rot : Vector3D) : Void
	{
		_relativeRotation = rot.clone();
	}

	public function getScale() : Vector3D
	{
		return _relativeScale.clone();
	}

	public function setScale(s : Vector3D) : Void
	{
		_relativeScale = s.clone();
	}

	public function setScaleXYZ(x : Float, y : Float, z : Float) : Void
	{
		_relativeScale.x = x;
		_relativeScale.y = y;
		_relativeScale.z = z;
	}

	//-----------------------------------get and set---------------------------------//

	private function get_x() : Float
	{
		return _relativeTranslation.x;
	}

	private function set_x(px : Float) : Float
	{
		_relativeTranslation.x = px;
		return px;
	}

	private function get_y() : Float
	{
		return _relativeTranslation.y;
	}

	private function set_y(py : Float) : Float
	{
		_relativeTranslation.y = py;
		return py;
	}

	private function get_z() : Float
	{
		return _relativeTranslation.z;
	}

	private function set_z(pz : Float) : Float
	{
		_relativeTranslation.z = pz;
		return pz;
	}

	private function get_rotationX() : Float
	{
		return _relativeRotation.x;
	}

	private function set_rotationX(rx : Float) : Float
	{
		_relativeRotation.x = rx;
		return rx;
	}

	private function get_rotationY() : Float
	{
		return _relativeRotation.y;
	}

	private function set_rotationY(ry : Float) : Float
	{
		_relativeRotation.y = ry;
		return ry;
	}

	private function get_rotationZ() : Float
	{
		return _relativeRotation.z;
	}

	private function set_rotationZ(rz : Float) : Float
	{
		_relativeRotation.z = rz;
		return rz;
	}

	private function get_scaleX() : Float
	{
		return _relativeScale.x;
	}

	private function set_scaleX(sx : Float) : Float
	{
		_relativeScale.x = sx;
		return sx;
	}

	private function get_scaleY() : Float
	{
		return _relativeScale.y;
	}

	private function set_scaleY(sy : Float) : Float
	{
		_relativeScale.y = sy;
		return sy;
	}

	private function get_scaleZ() : Float
	{
		return _relativeScale.z;
	}

	private function set_scaleZ(sz : Float) : Float
	{
		_relativeScale.z = sz;
		return sz;
	}

	private inline function get_numChildren():Int
	{
		return _numChildren;
	}

	private inline function get_parent():SceneNode
	{
		return _parent;
	}

	/**
	 * Returns type of the scene node
	 * @return The type of this node.
	 */
	public function getType():Int
	{
		return SceneNodeType.UNKOWN;
	}
}
