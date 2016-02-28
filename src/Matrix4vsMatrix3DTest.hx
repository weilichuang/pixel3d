package ;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.Lib;
import flash.text.TextField;
import pixel3d.math.Matrix4;
import flash.geom.Vector3D;
class Matrix4vsMatrix3DTest 
{
	static function main()
	{
		var t:Matrix4vsMatrix3DTest = new Matrix4vsMatrix3DTest();
	}
     
	private var textField:TextField;
	
	private var m1:Matrix4;
	private var m2:Matrix3D;
	public function new() 
	{
		textField = new TextField();
		textField.multiline = true;
		textField.width = 300;
		textField.height = 600;
		
		Lib.current.addChild(textField);

		m1 = new Matrix4();
		m2 = new Matrix3D();
		
		var tmp:Matrix4 = new Matrix4();
		var time:Int = Lib.getTimer();
		for (i in 0...100000)
		{
			m1.prepend(tmp);
		}
		textField.appendText("\nMatrix4 prepend time:" + (Lib.getTimer() - time));
		
		var tmp2:Matrix3D = new Matrix3D();
		time = Lib.getTimer();
		for (i in 0...100000)
		{
			m2.prepend(tmp2);
		}
		textField.appendText("\nMatrix3D prepend time:" + (Lib.getTimer() - time));
	}
	
}