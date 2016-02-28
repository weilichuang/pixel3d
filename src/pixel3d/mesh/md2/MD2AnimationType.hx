package pixel3d.mesh.md2;
import pixel3d.mesh.KeyFrameData;
class MD2AnimationType
{
	public static inline var STAND : KeyFrameData = new KeyFrameData(0, 39, 9);
	public static inline var RUN : KeyFrameData = new KeyFrameData(40, 45, 10);
	public static inline var ATTACK : KeyFrameData = new KeyFrameData(46, 53, 10);
	public static inline var PAIN_A : KeyFrameData = new KeyFrameData(54, 57, 7);
	public static inline var PAIN_B : KeyFrameData = new KeyFrameData(58, 61, 7);
	public static inline var PAIN_C : KeyFrameData = new KeyFrameData(62, 65, 7);
	public static inline var JUMP : KeyFrameData = new KeyFrameData(66, 71, 7);
	public static inline var FLIP : KeyFrameData = new KeyFrameData(72, 83, 7);
	public static inline var SALUTE : KeyFrameData = new KeyFrameData(84, 94, 7);
	public static inline var FALLBACK : KeyFrameData = new KeyFrameData(95, 111, 10);
	public static inline var WAVE : KeyFrameData = new KeyFrameData(112, 122, 7);
	public static inline var POINT : KeyFrameData = new KeyFrameData(123, 134, 6);
	public static inline var CROUCH_STAND : KeyFrameData = new KeyFrameData(135, 153, 10);
	public static inline var CROUCH_WALK : KeyFrameData = new KeyFrameData(154, 159, 7);
	public static inline var CROUCH_ATTACK : KeyFrameData = new KeyFrameData(160, 168, 10);
	public static inline var CROUCH_PAIN : KeyFrameData = new KeyFrameData(169, 172, 7);
	public static inline var CROUCH_DEATH : KeyFrameData = new KeyFrameData(173, 177, 5);
	public static inline var DEATH_FALLBACK : KeyFrameData = new KeyFrameData(178, 183, 7);
	public static inline var DEATH_FALLFORWARD : KeyFrameData = new KeyFrameData(184, 189, 7);
	public static inline var DEATH_FALLBACKSLOW : KeyFrameData = new KeyFrameData(190, 197, 7);
	public static inline var BOOM : KeyFrameData = new KeyFrameData(197, 197, 5);
	public static inline var ALL : KeyFrameData = new KeyFrameData(0, 197, 7);
}
