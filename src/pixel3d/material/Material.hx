package pixel3d.material;
import pixel3d.math.Color;
import pixel3d.math.MathUtil;
import pixel3d.utils.UserData;
class Material
{
	//TODO 设置可以一次修改多个的方式，用 0x0001等等
	public static inline var WIREFRAME : Int = 0;
	public static inline var GOURAUD_SHADE : Int = 1;
	public static inline var BACKFACE : Int = 2;
	public static inline var FRONTFACE : Int = 3;
	public static inline var LIGHT : Int = 4;
	public static inline var TRANSPARTENT : Int = 5;
	public static inline var ZBUFFER : Int = 6;
	
	public var backfaceCulling : Bool ;//背面剔除
	public var frontfaceCulling : Bool;//正面剔除
	public var transparenting : Bool ;//透明
	public var gouraudShading : Bool ;//平滑着色
	public var lighting : Bool ;
	public var wireframe : Bool;
	public var zBuffer : Bool;
	public var isPowOfTow:Bool;//用于部分uv坐标需要调制的模型，比如bsp,设为true时贴图大小必须是2的n次方
	
	public var ambientColor : Color;
	public var diffuseColor : Color;
	public var emissiveColor : Color;
	public var specularColor : Color;
	
	
	public var texture : ITexture;//纹理图
	public var texture2 : ITexture;//光照图,或其他类型的贴图
	
	public var shininess : Float;//指数，用于高光部分
	
	private var _alpha : Float;
	public var alpha(get, set) : Float;
	
	public var name : String;
	
	public var extra:UserData;
	
	public function new()
	{
		name = "";
		shininess = 0;
		_alpha = 1.;
		backfaceCulling = true;
		frontfaceCulling = false;
		transparenting = false;
		gouraudShading = false;
		lighting = false;
		wireframe = false;
		isPowOfTow = false;
		zBuffer = true;
		
		ambientColor = new Color(255, 255, 255);
		diffuseColor = new Color(255, 255, 255);
		emissiveColor = new Color(0, 0, 0);
		specularColor = new Color(0, 0, 0);
		
		extra = new UserData();
	}
	
	private inline function set_alpha(value : Float) : Float
	{
		_alpha = MathUtil.clamp(value, 0.0, 1.0);
		return _alpha;
	}
	private inline function get_alpha() : Float
	{
		return _alpha;
	}
	/**
	* 设置贴图，layer不为1时则设置附加贴图，附加贴图用途可能有多种，比如光照图等。
	* @param	texture
	* @param	?layer
	*/
	public function setTexture(t : ITexture, layer : Int = 1) : Void
	{
		if(layer == 1)
		{
			texture = t;
		} else 
		{
			texture2 = t;
		}
	}
	
	public function getTexture() : ITexture
	{
		return texture;
	}
	
	public function getTexture2() : ITexture
	{
		return texture2;
	}
	
	public function setFlag(flag : Int, value : Bool) : Void
	{
		switch(flag)
		{
			case BACKFACE :backfaceCulling = value;
			case GOURAUD_SHADE :gouraudShading = value;
			case LIGHT :lighting = value;
			case TRANSPARTENT :transparenting = value;
			case WIREFRAME :wireframe = value;
			case FRONTFACE :frontfaceCulling = value;
			case ZBUFFER :zBuffer = value;
		}
	}
	
	public function clone() : Material
	{
		var mat : Material = new Material();
		mat.copy(this);
		return mat;
	}
	
	public function copy(mat : Material) : Void
	{
		frontfaceCulling = mat.frontfaceCulling;
		backfaceCulling = mat.backfaceCulling;
		transparenting = mat.transparenting;
		gouraudShading = mat.gouraudShading;
		wireframe = mat.wireframe;
		lighting = mat.lighting;
		zBuffer = mat.zBuffer;
		isPowOfTow = mat.isPowOfTow;
		ambientColor.copy(mat.ambientColor);
		diffuseColor.copy(mat.diffuseColor);
		emissiveColor.copy(mat.emissiveColor);
		alpha = mat.alpha;
		shininess = mat.shininess;
		texture = mat.texture;
		texture2 = mat.texture2;
	}
	
	public function toString() : String
	{
		return name;
	}
}
