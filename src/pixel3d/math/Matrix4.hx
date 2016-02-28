package pixel3d.math;
import flash.geom.Vector3D;
import flash.Lib;
import flash.Vector;
import pixel3d.math.AABBox;
import pixel3d.math.AABBox;
@:final class Matrix4
{
	/**
	* The matrix is a D3D style matrix, row major with translations in the 4th row.
	* Matrix4 :
	* x-axis   y-axis    z-axis
	*   m11     m12       m13     m14      m[0]   m[1]   m[2]   m[3]
	*
	*   m21     m22       m23     m24      m[4]   m[5]   m[6]   m[7]
	*
	*   m31     m32       m33     m34      m[8]   m[9]   m[10]  m[11]
	*
	*   m41(tx) m42(ty)   m43(tz) m44      m[12]  m[13]  m[14]  m[15]
	*/
	
	public var m11 : Float;
	public var m12 : Float;
	public var m13 : Float;
	public var m14 : Float;
	public var m21 : Float;
	public var m22 : Float;
	public var m23 : Float;
	public var m24 : Float;
	public var m31 : Float;
	public var m32 : Float;
	public var m33 : Float;
	public var m34 : Float;
	public var m41 : Float;
	public var m42 : Float;
	public var m43 : Float;
	public var m44 : Float;
	
	public var determinant(get, never):Float;
	
	public function new(args:Vector<Float> = null)
	{
		if(args != null && args.length>= 16)
		{
			m11 = args[0]; m12 = args[1]; m13 = args[2]; m14 = args[3];
			m21 = args[4]; m22 = args[5]; m23 = args[6]; m24 = args[7];
			m31 = args[8]; m32 = args[9]; m33 = args[10]; m34 = args[11];
			m41 = args[12]; m42 = args[13]; m43 = args[14]; m44 = args[15];
		}
		else
		{
			identity();
		}
	}

	public function invert() : Bool
	{
		var d : Float = determinant;
						
		if(d == 0.0)
		{
			return false;
		}else
		{
			d = 1.0 / d;
			
			var n00 : Float = d *(m22 *(m33 * m44 - m34 * m43) + m23 *(m34 * m42 - m32 * m44) + m24 *(m32 * m43 - m33 * m42));
			var n01 : Float = d *(m32 *(m13 * m44 - m14 * m43) + m33 *(m14 * m42 - m12 * m44) + m34 *(m12 * m43 - m13 * m42));
			var n02 : Float = d *(m42 *(m13 * m24 - m14 * m23) + m43 *(m14 * m22 - m12 * m24) + m44 *(m12 * m23 - m13 * m22));
			var n03 : Float = d *(m12 *(m24 * m33 - m23 * m34) + m13 *(m22 * m34 - m24 * m32) + m14 *(m23 * m32 - m22 * m33));
			var n10 : Float = d *(m23 *(m31 * m44 - m34 * m41) + m24 *(m33 * m41 - m31 * m43) + m21 *(m34 * m43 - m33 * m44));
			var n11 : Float = d *(m33 *(m11 * m44 - m14 * m41) + m34 *(m13 * m41 - m11 * m43) + m31 *(m14 * m43 - m13 * m44));
			var n12 : Float = d *(m43 *(m11 * m24 - m14 * m21) + m44 *(m13 * m21 - m11 * m23) + m41 *(m14 * m23 - m13 * m24));
			var n13 : Float = d *(m13 *(m24 * m31 - m21 * m34) + m14 *(m21 * m33 - m23 * m31) + m11 *(m23 * m34 - m24 * m33));
			var n20 : Float = d *(m24 *(m31 * m42 - m32 * m41) + m21 *(m32 * m44 - m34 * m42) + m22 *(m34 * m41 - m31 * m44));
			var n21 : Float = d *(m34 *(m11 * m42 - m12 * m41) + m31 *(m12 * m44 - m14 * m42) + m32 *(m14 * m41 - m11 * m44));
			var n22 : Float = d *(m44 *(m11 * m22 - m12 * m21) + m41 *(m12 * m24 - m14 * m22) + m42 *(m14 * m21 - m11 * m24));
			var n23 : Float = d *(m14 *(m22 * m31 - m21 * m32) + m11 *(m24 * m32 - m22 * m34) + m12 *(m21 * m34 - m24 * m31));
			var n30 : Float = d *(m21 *(m33 * m42 - m32 * m43) + m22 *(m31 * m43 - m33 * m41) + m23 *(m32 * m41 - m31 * m42));
			var n31 : Float = d *(m31 *(m13 * m42 - m12 * m43) + m32 *(m11 * m43 - m13 * m41) + m33 *(m12 * m41 - m11 * m42));
			var n32 : Float = d *(m41 *(m13 * m22 - m12 * m23) + m42 *(m11 * m23 - m13 * m21) + m43 *(m12 * m21 - m11 * m22));
			var n33 : Float = d *(m11 *(m22 * m33 - m23 * m32) + m12 *(m23 * m31 - m21 * m33) + m13 *(m21 * m32 - m22 * m31));
		
			m11 = n00; m12 = n01; m13 = n02; m14 = n03;
			m21 = n10; m22 = n11; m23 = n12; m24 = n13;
			m31 = n20; m32 = n21; m33 = n22; m34 = n23;
			m41 = n30; m42 = n31; m43 = n32; m44 = n33;
		
			return true;
		}
	}
	
	/*
	 *    
	 *     | m22  m23  m24 |          | m21  m23  m24 |          | m21  m22  m24 |          | m21  m22  m23 |
	 * m11*| m32  m33  m34 |   - m12 *| m31  m33  m34 |   + m13 *| m31  m32  m34 |   - m14 *| m31  m32  m33 |
	 *     | m42  m43  m44 |          | m41  m43  m44 |          | m41  m42  m44 |          | m41  m42  m43 |
	 * 
	 * m11*(m22*(m33*m44 - m34*m43) + m23*(m34*m42 - m32*m44) + m24*(m32*m43 - m33*m42)) -
	 * .........
	 */
	public inline function get_determinant():Float
	{
		return(m11 * m22 - m12 * m21) *(m33 * m44 - m34 * m43) - 
		      (m11 * m23 - m13 * m21) *(m32 * m44 - m34 * m42) +
		      (m11 * m24 - m14 * m21) *(m32 * m43 - m33 * m42) + 
			  (m12 * m23 - m13 * m22) *(m31 * m44 - m34 * m41) -
		      (m12 * m24 - m14 * m22) *(m31 * m43 - m33 * m41) + 
			  (m13 * m24 - m14 * m23) *(m31 * m42 - m32 * m41);
	}
	
	public function getInvert(out : Matrix4 = null) : Matrix4
	{
		if(out == null) out = new Matrix4();
		
		var d : Float = determinant;
						
		if(d == 0.0)
		{
			return out;
		}
		else
		{
			d = 1.0 / d;
		}
		
		out.m11 = d *(m22 *(m33 * m44 - m34 * m43) + m23 *(m34 * m42 - m32 * m44) + m24 *(m32 * m43 - m33 * m42));
		out.m12 = d *(m32 *(m13 * m44 - m14 * m43) + m33 *(m14 * m42 - m12 * m44) + m34 *(m12 * m43 - m13 * m42));
		out.m13 = d *(m42 *(m13 * m24 - m14 * m23) + m43 *(m14 * m22 - m12 * m24) + m44 *(m12 * m23 - m13 * m22));
		out.m14 = d *(m12 *(m24 * m33 - m23 * m34) + m13 *(m22 * m34 - m24 * m32) + m14 *(m23 * m32 - m22 * m33));
		out.m21 = d *(m23 *(m31 * m44 - m34 * m41) + m24 *(m33 * m41 - m31 * m43) + m21 *(m34 * m43 - m33 * m44));
		out.m22 = d *(m33 *(m11 * m44 - m14 * m41) + m34 *(m13 * m41 - m11 * m43) + m31 *(m14 * m43 - m13 * m44));
		out.m23 = d *(m43 *(m11 * m24 - m14 * m21) + m44 *(m13 * m21 - m11 * m23) + m41 *(m14 * m23 - m13 * m24));
		out.m24 = d *(m13 *(m24 * m31 - m21 * m34) + m14 *(m21 * m33 - m23 * m31) + m11 *(m23 * m34 - m24 * m33));
		out.m31 = d *(m24 *(m31 * m42 - m32 * m41) + m21 *(m32 * m44 - m34 * m42) + m22 *(m34 * m41 - m31 * m44));
		out.m32 = d *(m34 *(m11 * m42 - m12 * m41) + m31 *(m12 * m44 - m14 * m42) + m32 *(m14 * m41 - m11 * m44));
		out.m33 = d *(m44 *(m11 * m22 - m12 * m21) + m41 *(m12 * m24 - m14 * m22) + m42 *(m14 * m21 - m11 * m24));
		out.m34 = d *(m14 *(m22 * m31 - m21 * m32) + m11 *(m24 * m32 - m22 * m34) + m12 *(m21 * m34 - m24 * m31));
		out.m41 = d *(m21 *(m33 * m42 - m32 * m43) + m22 *(m31 * m43 - m33 * m41) + m23 *(m32 * m41 - m31 * m42));
		out.m42 = d *(m31 *(m13 * m42 - m12 * m43) + m32 *(m11 * m43 - m13 * m41) + m33 *(m12 * m41 - m11 * m42));
		out.m43 = d *(m41 *(m13 * m22 - m12 * m23) + m42 *(m11 * m23 - m13 * m21) + m43 *(m12 * m21 - m11 * m22));
		out.m44 = d *(m11 *(m22 * m33 - m23 * m32) + m12 *(m23 * m31 - m21 * m33) + m13 *(m21 * m32 - m22 * m31));
		return out;
	}
	
	//public function getInvert4x3(out : Matrix4 = null) : Matrix4
	//{
		//if(out == null) out = new Matrix4();
		//var d : Float =(m11 * m22 - m12 * m21) * m33 - 
		               //(m11 * m23 - m13 * m21) * m32 + 
						//(m12 * m23 - m13 * m22) * m31 ;
		//
		//if(d == 0.0)
		//{
			//return out;
		//}
		//else
		//{
			//d = 1.0 / d;
		//}
		//
		//out.m11 = d *(m22 * m33 - m23 * m32);
		//out.m12 = d *(m32 * m13 - m33 * m12);
		//out.m13 = d *(m12 * m23 - m13 * m22);
		//out.m14 = 0;
		//out.m21 = d *(m23 * m31 - m21 * m33);
		//out.m22 = d *(m33 * m11 - m31 * m13);
		//out.m23 = d *(m13 * m21 - m11 * m23);
		//out.m24 = 0;
		//out.m31 = d *(m21 * m32 - m22 * m31);
		//out.m32 = d *(m31 * m12 - m32 * m11);
		//out.m33 = d *(m11 * m22 - m12 * m21);
		//out.m34 = 0;
		//out.m41 = d *(m21 *(m33 * m42 - m32 * m43) + m22 *(m31 * m43 - m33 * m41) + m23 *(m32 * m41 - m31 * m42));
		//out.m42 = d *(m31 *(m13 * m42 - m12 * m43) + m32 *(m11 * m43 - m13 * m41) + m33 *(m12 * m41 - m11 * m42));
		//out.m43 = d *(m41 *(m13 * m22 - m12 * m23) + m42 *(m11 * m23 - m13 * m21) + m43 *(m12 * m21 - m11 * m22));
		//out.m44 = 1;
		//return out;
	//}
	
	//public function invert4x3() : Bool
	//{
		//var d : Float =(m11 * m22 - m12 * m21) * m33 - 
		               //(m11 * m23 - m13 * m21) * m32 + 
						//(m12 * m23 - m13 * m22) * m31 ;
		//if(d == 0.0)
		//{
			//return false;
		//}
		//else
		//{
			//d = 1.0 / d;
			//
			//var n00 : Float = d *(m22 * m33 - m23 * m32);
			//var n01 : Float = d *(m32 * m13 - m33 * m12);
			//var n02 : Float = d *(m12 * m23 - m13 * m22);
			//var n10 : Float = d *(m23 * m31 - m21 * m33);
			//var n11 : Float = d *(m33 * m11 - m31 * m13);
			//var n12 : Float = d *(m13 * m21 - m11 * m23);
			//var n20 : Float = d *(m21 * m32 - m22 * m31);
			//var n21 : Float = d *(m31 * m12 - m32 * m11);
			//var n22 : Float = d *(m11 * m22 - m12 * m21);
			//var n30 : Float = d *(m21 *(m33 * m42 - m32 * m43) + m22 *(m31 * m43 - m33 * m41) + m23 *(m32 * m41 - m31 * m42));
			//var n31 : Float = d *(m31 *(m13 * m42 - m12 * m43) + m32 *(m11 * m43 - m13 * m41) + m33 *(m12 * m41 - m11 * m42));
			//var n32 : Float = d *(m41 *(m13 * m22 - m12 * m23) + m42 *(m11 * m23 - m13 * m21) + m43 *(m12 * m21 - m11 * m22));
		//
			//m11 = n00; m12 = n01; m13 = n02; m14 = 0;
			//m21 = n10; m22 = n11; m23 = n12; m24 = 0;
			//m31 = n20; m32 = n21; m33 = n22; m34 = 0;
			//m41 = n30; m42 = n31; m43 = n32; m44 = 1;
		//
			//return true;
		//}
	//}
	
	public inline function identity() : Void
	{
		m11 = 1.; m12 = 0.; m13 = 0.; m14 = 0.;
		m21 = 0.; m22 = 1.; m23 = 0.; m24 = 0.;
		m31 = 0.; m32 = 0.; m33 = 1.; m34 = 0.;
		m41 = 0.; m42 = 0.; m43 = 0.; m44 = 1.;
	}
	
	public inline function isIdentity() : Bool
	{
		return(m11 == 1.0 && m12 == 0.0 && m13 == 0.0 && m14 == 0.0 &&
		        m21 == 0.0 && m22 == 1.0 && m23 == 0.0 && m24 == 0.0 &&
		        m31 == 0.0 && m32 == 0.0 && m33 == 1.0 && m34 == 0.0 &&
		        m41 == 0.0 && m42 == 0.0 && m43 == 0.0 && m44 == 1.0);
	}
	
	public inline function setRotation(rotation : Vector3D,useDegree:Bool=false) : Void
	{
		var rx:Float;
		var ry:Float;
		var rz:Float;
		if (useDegree)
		{
			rx = rotation.x * MathUtil.DEGTORAD;
			ry = rotation.y * MathUtil.DEGTORAD;
			rz = rotation.z * MathUtil.DEGTORAD;
		}
		else
		{
			rx = rotation.x;
			ry = rotation.y;
			rz = rotation.z;
		}
		
		var sin = Math.sin;
		var cos = Math.cos;
		var cr : Float = cos(rx);
		var sr : Float = sin(rx);
		var cp : Float = cos(ry);
		var sp : Float = sin(ry);
		var cy : Float = cos(rz);
		var sy : Float = sin(rz);
		
		m11 =(cp * cy );
		m12 =(cp * sy );
		m13 =( - sp );
		var srsp : Float = sr * sp;
		var crsp : Float = cr * sp;
		m21 =(srsp * cy - cr * sy );
		m22 =(srsp * sy + cr * cy );
		m23 =(sr * cp );
		m31 =(crsp * cy + sr * sy );
		m32 =(crsp * sy - sr * cy );
		m33 =(cr * cp );
	}

	public inline function getRotation(useDegree:Bool=true) : Vector3D
	{
		var y : Float = - Math.asin(m13);
		var c : Float = Math.cos(y);
		var rotx : Float, roty : Float, x : Float, z : Float;
		c = MathUtil.abs(c);
		if(c> 0.0005)
		{
			c = 1 / c;
			rotx = m33 * c;
			roty = m23 * c;
			x = Math.atan2(roty, rotx );
			rotx = m11 * c;
			roty = m12 * c;
			z = Math.atan2(roty, rotx );
		} 
		else
		{
			x = 0.0;
			rotx = m22;
			roty = - m21;
			z = Math.atan2(roty, rotx );
		}
		if(x <0.00)
		{
			x += MathUtil.TWO_PI;
		}
		if(y <0.00)
		{
			y += MathUtil.TWO_PI;
		}
		if(z <0.00)
		{
			z += MathUtil.TWO_PI;
		}
		
		if (useDegree)
		{
			return new Vector3D(x * MathUtil.RADTODEG, y * MathUtil.RADTODEG, z * MathUtil.RADTODEG);
		}else
		{
			return new Vector3D(x, y, z);
		}
	}
	
	// Multiply by scalar.
	public inline function multiplyN(scalar : Float) : Matrix4
	{
		m11 *= scalar;
		m12 *= scalar;
		m13 *= scalar;
		m14 *= scalar;
		m21 *= scalar;
		m22 *= scalar;
		m23 *= scalar;
		m24 *= scalar;
		m31 *= scalar;
		m32 *= scalar;
		m33 *= scalar;
		m34 *= scalar;
		m41 *= scalar;
		m42 *= scalar;
		m43 *= scalar;
		m44 *= scalar;
		return this;
	}
	
	public inline function getTranslation(out:Vector3D=null) : Vector3D
	{
		if (out == null) out = new Vector3D();
		out.x = m41;
		out.y = m42;
		out.z = m43;
		return out;
	}
	
	public inline function setTranslation(translation : Vector3D) : Matrix4
	{
		m41 = translation.x;
		m42 = translation.y;
		m43 = translation.z;
		return this;
	}
	
	public inline function setInverseTranslation(translation : Vector3D) : Matrix4
	{
		m41 = - translation.x;
		m42 = - translation.y;
		m43 = - translation.z;
		return this;
	}
	
	public inline function setScale(scale : Vector3D ) : Matrix4
	{
		m11 = scale.x;
		m22 = scale.y;
		m33 = scale.z;
		return this;
	}
	
	//TODO rename
	public inline function multiplyVector3D(v : Vector3D) : Void
	{
		m11 *= v.x ; m12 *= v.x ; m13 *= v.x ;
		m21 *= v.y ; m22 *= v.y ; m23 *= v.y ;
		m31 *= v.z ; m32 *= v.z ; m33 *= v.z ;
	}
	
	/**
	Note that this always returns the absolute(positive) values.  Unfortunately it
	does not appear to be possible to extract any original negative values.  The best
	that we could do would be to arbitrarily make one scale negative if one or three
	of them were negative.
	FIXME - return the original values.
	*/
	public inline function getScale() : Vector3D
	{
		// See http://www.robertblum.com/articles/2005/02/14/decomposing-matrices
		// Deal with the 0 rotation case first
		if(m12 == 0 && m13 == 0 && m21 == 0 && m23 == 0 && m31 == 0 && m32 == 0)
		{
			return new Vector3D(m11, m22, m33);
		} else 
		{
			// We have to do the full calculation.
			return new Vector3D(MathUtil.sqrt(m11 * m11 + m12 * m12 + m13 * m13) ,
			                    MathUtil.sqrt(m21 * m21 + m22 * m22 + m23 * m23) ,
			                    MathUtil.sqrt(m31 * m31 + m32 * m32 + m33 * m33));
		}
	}
	
	public inline function getRight(out:Vector3D=null) : Vector3D
	{
		if (out == null) out = new Vector3D();
		out.x = m11;
		out.y = m12;
		out.z = m13;
		return out;
	}
	
	public inline function getUp(out:Vector3D=null) : Vector3D
	{
		if (out == null) out = new Vector3D();
		out.x = m21;
		out.y = m22;
		out.z = m23;
		return out;
	}
	
	public inline function getForward(out:Vector3D=null) : Vector3D
	{
		if (out == null) out = new Vector3D();
		out.x = m31;
		out.y = m32;
		out.z = m33;
		return out;
	}
	
	public inline function copy(other : Matrix4) : Void
	{
		m11 = other.m11; m12 = other.m12; m13 = other.m13; m14 = other.m14;
		m21 = other.m21; m22 = other.m22; m23 = other.m23; m24 = other.m24;
		m31 = other.m31; m32 = other.m32; m33 = other.m33; m34 = other.m34;
		m41 = other.m41; m42 = other.m42; m43 = other.m43; m44 = other.m44;
	}
	
	public inline function clone() : Matrix4
	{
		var m : Matrix4 = new Matrix4();
		m.m11 = m11;m.m12 = m12;m.m13 = m13;m.m14 = m14;
		m.m21 = m21;m.m22 = m22;m.m23 = m23;m.m24 = m24;
		m.m31 = m31;m.m32 = m32;m.m33 = m33;m.m34 = m34;
		m.m41 = m41;m.m42 = m42;m.m43 = m43;m.m44 = m44;
		return m;
	}
	
	public inline function multiply(other : Matrix4) : Matrix4
	{
		var m : Matrix4 = new Matrix4();
		m.m11 = m11 * other.m11 + m21 * other.m12 + m31 * other.m13 + m41 * other.m14;
		m.m12 = m12 * other.m11 + m22 * other.m12 + m32 * other.m13 + m42 * other.m14;
		m.m13 = m13 * other.m11 + m23 * other.m12 + m33 * other.m13 + m43 * other.m14;
		m.m14 = m14 * other.m11 + m24 * other.m12 + m34 * other.m13 + m44 * other.m14;
		m.m21 = m11 * other.m21 + m21 * other.m22 + m31 * other.m23 + m41 * other.m24;
		m.m22 = m12 * other.m21 + m22 * other.m22 + m32 * other.m23 + m42 * other.m24;
		m.m23 = m13 * other.m21 + m23 * other.m22 + m33 * other.m23 + m43 * other.m24;
		m.m24 = m14 * other.m21 + m24 * other.m22 + m34 * other.m23 + m44 * other.m24;
		m.m31 = m11 * other.m31 + m21 * other.m32 + m31 * other.m33 + m41 * other.m34;
		m.m32 = m12 * other.m31 + m22 * other.m32 + m32 * other.m33 + m42 * other.m34;
		m.m33 = m13 * other.m31 + m23 * other.m32 + m33 * other.m33 + m43 * other.m34;
		m.m34 = m14 * other.m31 + m24 * other.m32 + m34 * other.m33 + m44 * other.m34;
		m.m41 = m11 * other.m41 + m21 * other.m42 + m31 * other.m43 + m41 * other.m44;
		m.m42 = m12 * other.m41 + m22 * other.m42 + m32 * other.m43 + m42 * other.m44;
		m.m43 = m13 * other.m41 + m23 * other.m42 + m33 * other.m43 + m43 * other.m44;
		m.m44 = m14 * other.m41 + m24 * other.m42 + m34 * other.m43 + m44 * other.m44;
		return m;
	}
	
	public inline function multiply4x3(other : Matrix4) : Matrix4
	{
		var m : Matrix4 = new Matrix4();
		m.m11 = m11 * other.m11 + m21 * other.m12 + m31 * other.m13 ;
		m.m12 = m12 * other.m11 + m22 * other.m12 + m32 * other.m13 ;
		m.m13 = m13 * other.m11 + m23 * other.m12 + m33 * other.m13 ;
		m.m14 = 0.;
		m.m21 = m11 * other.m21 + m21 * other.m22 + m31 * other.m23 ;
		m.m22 = m12 * other.m21 + m22 * other.m22 + m32 * other.m23 ;
		m.m23 = m13 * other.m21 + m23 * other.m22 + m33 * other.m23 ;
		m.m24 = 0.;
		m.m31 = m11 * other.m31 + m21 * other.m32 + m31 * other.m33 ;
		m.m32 = m12 * other.m31 + m22 * other.m32 + m32 * other.m33 ;
		m.m33 = m13 * other.m31 + m23 * other.m32 + m33 * other.m33 ;
		m.m34 = 0.;
		m.m41 = m11 * other.m41 + m21 * other.m42 + m31 * other.m43 + m41;
		m.m42 = m12 * other.m41 + m22 * other.m42 + m32 * other.m43 + m42 ;
		m.m43 = m13 * other.m41 + m23 * other.m42 + m33 * other.m43 + m43 ;
		m.m44 = 1.;
		return m;
	}
	
	public inline function prepend(other : Matrix4) : Void
	{
		var n00 : Float = m11; var n01 : Float = m12; var n02 : Float = m13; var n03 : Float = m14;
		var n10 : Float = m21; var n11 : Float = m22; var n12 : Float = m23; var n13 : Float = m24;
		var n20 : Float = m31; var n21 : Float = m32; var n22 : Float = m33; var n23 : Float = m34;
		var n30 : Float = m41; var n31 : Float = m42; var n32 : Float = m43; var n33 : Float = m44;
		m11 = n00 * other.m11 + n10 * other.m12 + n20 * other.m13 + n30 * other.m14;
		m12 = n01 * other.m11 + n11 * other.m12 + n21 * other.m13 + n31 * other.m14;
		m13 = n02 * other.m11 + n12 * other.m12 + n22 * other.m13 + n32 * other.m14;
		m14 = n03 * other.m11 + n13 * other.m12 + n23 * other.m13 + n33 * other.m14;
		m21 = n00 * other.m21 + n10 * other.m22 + n20 * other.m23 + n30 * other.m24;
		m22 = n01 * other.m21 + n11 * other.m22 + n21 * other.m23 + n31 * other.m24;
		m23 = n02 * other.m21 + n12 * other.m22 + n22 * other.m23 + n32 * other.m24;
		m24 = n03 * other.m21 + n13 * other.m22 + n23 * other.m23 + n33 * other.m24;
		m31 = n00 * other.m31 + n10 * other.m32 + n20 * other.m33 + n30 * other.m34;
		m32 = n01 * other.m31 + n11 * other.m32 + n21 * other.m33 + n31 * other.m34;
		m33 = n02 * other.m31 + n12 * other.m32 + n22 * other.m33 + n32 * other.m34;
		m34 = n03 * other.m31 + n13 * other.m32 + n23 * other.m33 + n33 * other.m34;
		m41 = n00 * other.m41 + n10 * other.m42 + n20 * other.m43 + n30 * other.m44;
		m42 = n01 * other.m41 + n11 * other.m42 + n21 * other.m43 + n31 * other.m44;
		m43 = n02 * other.m41 + n12 * other.m42 + n22 * other.m43 + n32 * other.m44;
		m44 = n03 * other.m41 + n13 * other.m42 + n23 * other.m43 + n33 * other.m44;
	}
	
	public inline function prepend2(other : Matrix4 , out : Matrix4) : Void
	{
		out.m11 = m11 * other.m11 + m21 * other.m12 + m31 * other.m13 + m41 * other.m14;
		out.m12 = m12 * other.m11 + m22 * other.m12 + m32 * other.m13 + m42 * other.m14;
		out.m13 = m13 * other.m11 + m23 * other.m12 + m33 * other.m13 + m43 * other.m14;
		out.m14 = m14 * other.m11 + m24 * other.m12 + m34 * other.m13 + m44 * other.m14;
		out.m21 = m11 * other.m21 + m21 * other.m22 + m31 * other.m23 + m41 * other.m24;
		out.m22 = m12 * other.m21 + m22 * other.m22 + m32 * other.m23 + m42 * other.m24;
		out.m23 = m13 * other.m21 + m23 * other.m22 + m33 * other.m23 + m43 * other.m24;
		out.m24 = m14 * other.m21 + m24 * other.m22 + m34 * other.m23 + m44 * other.m24;
		out.m31 = m11 * other.m31 + m21 * other.m32 + m31 * other.m33 + m41 * other.m34;
		out.m32 = m12 * other.m31 + m22 * other.m32 + m32 * other.m33 + m42 * other.m34;
		out.m33 = m13 * other.m31 + m23 * other.m32 + m33 * other.m33 + m43 * other.m34;
		out.m34 = m14 * other.m31 + m24 * other.m32 + m34 * other.m33 + m44 * other.m34;
		out.m41 = m11 * other.m41 + m21 * other.m42 + m31 * other.m43 + m41 * other.m44;
		out.m42 = m12 * other.m41 + m22 * other.m42 + m32 * other.m43 + m42 * other.m44;
		out.m43 = m13 * other.m41 + m23 * other.m42 + m33 * other.m43 + m43 * other.m44;
		out.m44 = m14 * other.m41 + m24 * other.m42 + m34 * other.m43 + m44 * other.m44;
	}
	
	//public inline function multiply4x3By(other : Matrix4) : Void
	//{
		//var n00 : Float = m11;
		//var n01 : Float = m12;
		//var n02 : Float = m13;
		//var n10 : Float = m21;
		//var n11 : Float = m22;
		//var n12 : Float = m23;
		//var n20 : Float = m31;
		//var n21 : Float = m32;
		//var n22 : Float = m33;
		//var n30 : Float = m41;
		//var n31 : Float = m42;
		//var n32 : Float = m43;
		//m11 = n00 * other.m11 + n10 * other.m12 + n20 * other.m13 ;
		//m12 = n01 * other.m11 + n11 * other.m12 + n21 * other.m13 ;
		//m13 = n02 * other.m11 + n12 * other.m12 + n22 * other.m13 ;
		//m14 = 0.;
		//m21 = n00 * other.m21 + n10 * other.m22 + n20 * other.m23 ;
		//m22 = n01 * other.m21 + n11 * other.m22 + n21 * other.m23 ;
		//m23 = n02 * other.m21 + n12 * other.m22 + n22 * other.m23 ;
		//m24 = 0.;
		//m31 = n00 * other.m31 + n10 * other.m32 + n20 * other.m33 ;
		//m32 = n01 * other.m31 + n11 * other.m32 + n21 * other.m33 ;
		//m33 = n02 * other.m31 + n12 * other.m32 + n22 * other.m33 ;
		//m34 = 0.;
		//m41 = n00 * other.m41 + n10 * other.m42 + n20 * other.m43 + n30 ;
		//m42 = n01 * other.m41 + n11 * other.m42 + n21 * other.m43 + n31 ;
		//m43 = n02 * other.m41 + n12 * other.m42 + n22 * other.m43 + n32 ;
		//m44 = 1.;
	//}
	
	public inline function translateVertex(vect : Vertex) : Void
	{
		vect.x += m41;
		vect.y += m42;
		vect.z += m43;
	}
	
	public inline function translateVector(vect : Vector3D) : Void
	{
		vect.x += m41;
		vect.y += m42;
		vect.z += m43;
	}
	
	public inline function rotateVector(vect : Vector3D ) : Void
	{
		var x : Float = vect.x;
		var y : Float = vect.y;
		var z : Float = vect.z;
		vect.x = x * m11 + y * m21 + z * m31;
		vect.y = x * m12 + y * m22 + z * m32;
		vect.z = x * m13 + y * m23 + z * m33;
	}
	
	public inline function rotateVector2D(vect : Vector3D, out : Vector3D=null) : Vector3D
	{
		var x : Float = vect.x;
		var y : Float = vect.y;
		var z : Float = vect.z;
		out.x = x * m11 + y * m21 + z * m31;
		out.y = x * m12 + y * m22 + z * m32;
		out.z = x * m13 + y * m23 + z * m33;
		return out;
	}
	
	public inline function rotateVertex(vect : Vertex, normal : Bool = false) : Void
	{
		var x : Float = vect.x;
		var y : Float = vect.y;
		var z : Float = vect.z;
		vect.x = x * m11 + y * m21 + z * m31;
		vect.y = x * m12 + y * m22 + z * m32;
		vect.z = x * m13 + y * m23 + z * m33;
		if(normal)
		{
			x = vect.nx;
			y = vect.ny;
			z = vect.nz;
			vect.nx =(m11 * x + m21 * y + m31 * z);
			vect.ny =(m11 * x + m21 * y + m31 * z);
			vect.nz =(m11 * x + m21 * y + m31 * z);
			vect.normalize();
		}
	}
	
	public inline function transformPlane(plane : Plane3D) : Void
	{
		//rotate normal -> rotateVect( plane.n );
		var x : Float = plane.normal.x * m11 + plane.normal.y * m21 + plane.normal.z * m31;
		var y : Float = plane.normal.x * m12 + plane.normal.y * m22 + plane.normal.z * m32;
		var z : Float = plane.normal.x * m13 + plane.normal.y * m23 + plane.normal.z * m33;
		//compute new d. -> getTranslation(). dotproduct( plane.n )
		plane.d -=(m41 * x + m42 * y + m43 * z);
		plane.normal.x = x;
		plane.normal.y = y;
		plane.normal.z = z;
	}
	
	public inline function transformVector(vector : Vector3D) : Void
	{
		var x : Float = vector.x;
		var y : Float = vector.y;
		var z : Float = vector.z;
		vector.x =(m11 * x + m21 * y + m31 * z + m41);
		vector.y =(m12 * x + m22 * y + m32 * z + m42);
		vector.z =(m13 * x + m23 * y + m33 * z + m43);
	}
	
	public inline function transformVector2D(vector : Vector3D, out : Vector3D) : Void
	{
		var x : Float = vector.x;
		var y : Float = vector.y;
		var z : Float = vector.z;
		out.x =(m11 * x + m21 * y + m31 * z + m41);
		out.y =(m12 * x + m22 * y + m32 * z + m42);
		out.z =(m13 * x + m23 * y + m33 * z + m43);
	}
	
	public inline function transformVertex(vect : Vertex, normal : Bool = false) : Void
	{
		var x : Float = vect.x;
		var y : Float = vect.y;
		var z : Float = vect.z;
		vect.x =(m11 * x + m21 * y + m31 * z + m41);
		vect.y =(m12 * x + m22 * y + m32 * z + m42);
		vect.z =(m13 * x + m23 * y + m33 * z + m43);
		if(normal)
		{
			//rotate normal and normalize;
			x = vect.nx;
			y = vect.ny;
			z = vect.nz;
			vect.nx =(m11 * x + m21 * y + m31 * z);
			vect.ny =(m11 * x + m21 * y + m31 * z);
			vect.nz =(m11 * x + m21 * y + m31 * z);
			vect.normalize();
		}
	}
	
	/**
	 * Transforms a axis aligned bounding box more accurately than transformBox()
	 * @param	box
	 */
	public inline function transformBoxEx(box:AABBox):Void
	{
		var edges:Vector<Vector3D> = box.getEdges();

		for (i in 0...8)
		{
			transformVector(edges[i]);
		}
	
		box.resetVector(edges[0]);
	
		for (i in 0...8)
		{
			box.addInternalVector(edges[i]);
		}
	}
	
	public inline function transformBox(box : AABBox) : Void
	{
		var x : Float = m11 * box.minX + m21 * box.minY + m31 * box.minZ + m41;
		var y : Float = m12 * box.minX + m22 * box.minY + m32 * box.minZ + m42;
		var z : Float = m13 * box.minX + m23 * box.minY + m33 * box.minZ + m43;
		box.minX = x;
		box.minY = y;
		box.minZ = z;
		x = m11 * box.maxX + m21 * box.maxY + m31 * box.maxZ + m41;
		y = m12 * box.maxX + m22 * box.maxY + m32 * box.maxZ + m42;
		z = m13 * box.maxX + m23 * box.maxY + m33 * box.maxZ + m43;
		box.maxX = x;
		box.maxY = y;
		box.maxZ = z;
		box.repair();
	}
	
	public inline function transformBox2(box : AABBox, out : AABBox) : Void
	{
		out.minX = m11 * box.minX + m21 * box.minY + m31 * box.minZ + m41;
		out.minY = m12 * box.minX + m22 * box.minY + m32 * box.minZ + m42;
		out.minZ = m13 * box.minX + m23 * box.minY + m33 * box.minZ + m43;
		out.maxX = m11 * box.maxX + m21 * box.maxY + m31 * box.maxZ + m41;
		out.maxY = m12 * box.maxX + m22 * box.maxY + m32 * box.maxZ + m42;
		out.maxZ = m13 * box.maxX + m23 * box.maxY + m33 * box.maxZ + m43;
		out.repair();
	}

	public inline function transpose() : Void
	{
		var n00 : Float = m11; var n01 : Float = m12; var n02 : Float = m13; var n03 : Float = m14;
		var n10 : Float = m21; var n11 : Float = m22; var n12 : Float = m23; var n13 : Float = m24;
		var n20 : Float = m31; var n21 : Float = m32; var n22 : Float = m33; var n23 : Float = m34;
		var n30 : Float = m41; var n31 : Float = m42; var n32 : Float = m43; var n33 : Float = m44;
		
		this.m11 = n00; this.m12 = n10; this.m13 = n20; this.m14 = n30;
		this.m21 = n01; this.m22 = n11; this.m23 = n21; this.m24 = n31;
        this.m31 = n02; this.m32 = n12; this.m33 = n22; this.m34 = n32;
		this.m41 = n03; this.m42 = n13; this.m43 = n23; this.m44 = n33;
	}
	
	/**
	 * creates a new matrix as interpolated matrix from this and the passed one.
	 * @param	b
	 * @param	percent  0~1
	 * @return
	 */
	public inline function interpolate(b : Matrix4, percent : Float) : Matrix4
	{
		var mat : Matrix4 = new Matrix4();
		mat.m11 = m11 +(b.m11 - m11) * percent;
		mat.m12 = m12 +(b.m12 - m12) * percent;
		mat.m13 = m13 +(b.m13 - m13) * percent;
		mat.m14 = m14 +(b.m14 - m14) * percent;
		mat.m21 = m21 +(b.m21 - m21) * percent;
		mat.m22 = m22 +(b.m22 - m22) * percent;
		mat.m23 = m23 +(b.m23 - m23) * percent;
		mat.m24 = m24 +(b.m24 - m24) * percent;
		mat.m31 = m31 +(b.m31 - m31) * percent;
		mat.m32 = m32 +(b.m32 - m32) * percent;
		mat.m33 = m33 +(b.m33 - m33) * percent;
		mat.m34 = m34 +(b.m34 - m34) * percent;
		mat.m41 = m41 +(b.m41 - m41) * percent;
		mat.m42 = m42 +(b.m42 - m42) * percent;
		mat.m43 = m43 +(b.m43 - m43) * percent;
		mat.m44 = m44 +(b.m44 - m44) * percent;
		return mat;
	}
	
	public inline function buildNDCToDCMatrix(rect : Vector2i, scale : Float = 1.0) : Void
	{
		var scaleX : Float =(rect.width - 0.75) * 0.5;
		var scaleY : Float = -(rect.height - 0.75) * 0.5;
		var dx : Float = - 0.5 + rect.width * 0.5;
		var dy : Float = - 0.5 + rect.height * 0.5;
		identity();
		m11 = scaleX;
		m22 = scaleY;
		m33 = scale;
		m41 = dx;
		m42 = dy;
	}
	
	// Builds a left-handed look-at matrix.
	public inline function buildCameraLookAtMatrix(position : Vector3D, target : Vector3D, upVector : Vector3D) : Void
	{
		var zaxis : Vector3D = target.subtract(position);
		zaxis.normalize();
		var xaxis : Vector3D = upVector.crossProduct(zaxis);
		xaxis.normalize();
		var yaxis : Vector3D = zaxis.crossProduct(xaxis);
		m11 = xaxis.x;
		m12 = yaxis.x;
		m13 = zaxis.x;
		m14 = 0.;
		m21 = xaxis.y;
		m22 = yaxis.y;
		m23 = zaxis.y;
		m24 = 0.;
		m31 = xaxis.z;
		m32 = yaxis.z;
		m33 = zaxis.z;
		m34 = 0.;
		m41 = - xaxis.dotProduct(position);
		m42 = - yaxis.dotProduct(position);
		m43 = - zaxis.dotProduct(position);
		m44 = 1.0;
	}
	
	public inline function buildEulerCameraMatrix(position:Vector3D, rotation:Vector3D):Void
	{
		var sin = Math.sin;
		var cos = Math.cos;
		
		var rx : Float = rotation.x * MathUtil.DEGTORAD;
		var ry : Float = rotation.y * MathUtil.DEGTORAD;
		var rz : Float = rotation.z * MathUtil.DEGTORAD;
		
		var headSin:Float = sin(rx);
		var headCos:Float = cos(rx);
		var pitchSin:Float = sin(ry);
		var pitchCos:Float = cos(ry);
		var rollSin:Float = sin(rz);
		var rollCos:Float = cos(rz);
		
		m11 = headCos * rollCos + headSin * pitchSin * rollSin;
		m12 = -headCos * rollSin + headSin * pitchSin * rollCos;
		m13 = headSin * pitchCos;
		m14 = 0;
		m21 = rollSin * pitchCos;
		m22 = rollCos * pitchCos;
		m23 = -pitchSin;
		m24 = 0.;
		m31 = -headSin * rollCos + headCos * pitchSin * rollSin;
		m32 = rollSin * headSin + headCos * pitchSin * rollCos;
		m33 = headCos * pitchCos;
		m34 = 0.;
		m41 = position.x;
		m42 = position.y;
		m43 = position.z;
		m44 = 1.0;
	}
 
	/**
	 * Builds a matrix that flattens geometry into a plane.
	 * @param	light
	 * @param	plane
	 * @param	point
	 * @return
	 */
	public inline function buildShadowMatrix(light : Vector3D, plane : Plane3D, point : Float) : Matrix4
	{
		plane.normal.normalize();
		var d : Float = plane.normal.dotProduct(light);
		m11 =( - plane.normal.x * light.x + d);
		m12 =( - plane.normal.x * light.y);
		m13 =( - plane.normal.x * light.z);
		m14 =( - plane.normal.x * point);
		m21 =( - plane.normal.y * light.x);
		m22 =( - plane.normal.y * light.y + d);
		m23 =( - plane.normal.y * light.z);
		m24 =( - plane.normal.y * point);
		m31 =( - plane.normal.z * light.x);
		m32 =( - plane.normal.z * light.y);
		m33 =( - plane.normal.z * light.z + d);
		m34 =( - plane.normal.z * point);
		m41 =( - plane.d * light.x);
		m42 =( - plane.d * light.y);
		m43 =( - plane.d * light.z);
		m44 =( - plane.d * point + d);
		return this;
	}

	/**
	 * Builds a left-handed perspective projection matrix.
	 * @param	width
	 * @param	height
	 * @param	zNear
	 * @param	zFar
	 * @return
	 */
	public inline function buildProjectionMatrixPerspective(width : Float, height : Float, zNear : Float, zFar : Float) : Matrix4
	{
		m11 =(2 * zNear / width);
		m12 = 0;
		m13 = 0;
		m14 = 0;
		m21 = 0;
		m22 =(2 * zNear / height);
		m23 = 0;
		m24 = 0;
		m31 = 0;
		m32 = 0;
		m33 =(zFar /(zFar - zNear));
		m34 = 1;
		m41 = 0;
		m42 = 0;
		m43 =(zNear * zFar /(zNear - zFar));
		m44 = 0;
		return this;
	}

	/**
	 * Builds a left-handed perspective projection matrix based on a field of view
	 * @param	fov
	 * @param	aspect
	 * @param	zNear
	 * @param	zFar
	 * @return
	 */
	public inline function buildProjectionMatrixPerspectiveFov(fov : Float, aspect : Float, zNear : Float, zFar : Float) : Matrix4
	{
		var h : Float = 1.0 / Math.tan(fov * 0.5);
		m11 = h / aspect;
		m12 = 0.;
		m13 = 0.;
		m14 = 0.;
		m21 = 0;
		m22 = h;
		m23 = 0.;
		m24 = 0.;
		m31 = 0.;
		m32 = 0.;
		m33 = zFar /(zFar - zNear);
		m34 = 1.;
		m41 = 0.;
		m42 = 0.;
		m43 = - zNear * zFar /(zFar - zNear);
		m44 = 0.;
		return this;
	}

	/**
	 * Multiplies this matrix by a 1x4 matrix
	 * @param	vec
	 * @return
	 */
	public inline function multiplyWithQuaternion(vec : Quaternion = null ) : Quaternion
	{
		if(vec == null) vec = new Quaternion();
		var x : Float = vec.x;
		var y : Float = vec.y;
		var z : Float = vec.z;
		var w : Float = vec.w;
		vec.x = m11 * x + m21 * y + m31 * z + m41 * w;
		vec.y = m12 * x + m22 * y + m32 * z + m42 * w;
		vec.z = m13 * x + m23 * y + m33 * z + m43 * w;
		vec.w = m14 * x + m24 * y + m34 * z + m44 * w;
		return vec;
	}

	/**
	* 矩阵格式化打印，每个项只输出三位小数
	*/
	public function toString() : String
	{
		var s : String = new String("Matrix4 :\n");
		s +=(Std.int(m11 * 1000) / 1000) + "\t" +(Std.int(m12 * 1000) / 1000) + "\t" +(Std.int(m13 * 1000) / 1000) + "\t" +(Std.int(m14 * 1000) / 1000) + "\n";
		s +=(Std.int(m21 * 1000) / 1000) + "\t" +(Std.int(m22 * 1000) / 1000) + "\t" +(Std.int(m23 * 1000) / 1000) + "\t" +(Std.int(m24 * 1000) / 1000) + "\n";
		s +=(Std.int(m31 * 1000) / 1000) + "\t" +(Std.int(m32 * 1000) / 1000) + "\t" +(Std.int(m33 * 1000) / 1000) + "\t" +(Std.int(m34 * 1000) / 1000) + "\n";
		s +=(Std.int(m41 * 1000) / 1000) + "\t" +(Std.int(m42 * 1000) / 1000) + "\t" +(Std.int(m43 * 1000) / 1000) + "\t" +(Std.int(m44 * 1000) / 1000) + "\n";
		return s;
	}
}
