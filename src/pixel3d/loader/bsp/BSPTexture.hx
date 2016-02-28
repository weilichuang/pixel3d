package pixel3d.loader.bsp;
import flash.utils.ByteArray;
import pixel3d.utils.Logger;
class BSPTexture
{
	public static inline var	CONTENTS_SOLID : Int	= 1;
	public static inline var	CONTENTS_LAVA : Int	= 8;
	public static inline var	CONTENTS_SLIME : Int	= 16;
	public static inline var	CONTENTS_WATER : Int	= 32;
	public static inline var	CONTENTS_FOG : Int	= 64;
	public static inline var CONTENTS_NOTTEAM1 : Int	= 0x0080;
	public static inline var CONTENTS_NOTTEAM2 : Int	= 0x0100;
	public static inline var CONTENTS_NOBOTCLIP : Int	= 0x0200;
	public static inline var	CONTENTS_AREAPORTAL : Int	= 0x8000;
	public static inline var	CONTENTS_PLAYERCLIP : Int	= 0x10000;
	public static inline var	CONTENTS_MONSTERCLIP : Int	= 0x20000;
	//bot specific contents types
	public static inline var	CONTENTS_TELEPORTER : Int	= 0x40000;
	public static inline var	CONTENTS_JUMPPAD : Int	= 0x80000;
	public static inline var CONTENTS_CLUSTERPORTAL : Int	= 0x100000;
	public static inline var CONTENTS_DONOTENTER : Int	= 0x200000;
	public static inline var CONTENTS_BOTCLIP : Int	= 0x400000;
	public static inline var CONTENTS_MOVER : Int	= 0x800000;
	public static inline var	CONTENTS_ORIGIN : Int	= 0x1000000;
	// removed before bsping an entity
	public static inline var	CONTENTS_BODY : Int	= 0x2000000;
	// should never be on a brush, only in game
	public static inline var	CONTENTS_CORPSE : Int	= 0x4000000;
	public static inline var	CONTENTS_DETAIL : Int	= 0x8000000;
	// brushes not used for the bsp
	public static inline var	CONTENTS_STRUCTURAL : Int	= 0x10000000;
	// brushes used for the bsp
	public static inline var	CONTENTS_TRANSLUCENT : Int	= 0x20000000;
	// don't consume surface fragments inside
	public static inline var	CONTENTS_TRIGGER : Int	= 0x40000000;
	public static inline var	CONTENTS_NODROP : Float	= 0x80000000;
	// don't leave bodies or items(death fog, lava)
	public static inline var	SURF_NODAMAGE : Int	= 0x1	;
	// never give falling damage
	public static inline var	SURF_SLICK : Int	= 0x2	;
	// effects game physics
	public static inline var	SURF_SKY : Int	= 0x4	;
	// lighting from environment map
	public static inline var	SURF_LADDER : Int	= 0x8;
	public static inline var	SURF_NOIMPACT : Int	= 0x10;
	// don't make missile explosions
	public static inline var	SURF_NOMARKS : Int	= 0x20;
	// don't leave missile marks
	public static inline var	SURF_FLESH : Int	= 0x40;
	// make flesh sounds and effects
	public static inline var	SURF_NODRAW : Int	= 0x80;
	// don't generate a drawsurface at all
	public static inline var	SURF_HINT : Int	= 0x100;
	// make a primary bsp splitter
	public static inline var	SURF_SKIP : Int	= 0x200;
	// completely ignore, allowing non-closed brushes
	public static inline var	SURF_NOLIGHTMAP : Int	= 0x400;
	// surface doesn't need a lightmap
	public static inline var	SURF_POINTLIGHT : Int	= 0x800;
	// generate lighting info at vertexes
	public static inline var	SURF_METALSTEPS : Int	= 0x1000;
	// clanking footsteps
	public static inline var	SURF_NOSTEPS : Int	= 0x2000;
	// no footstep sounds
	public static inline var	SURF_NONSOLID : Int	= 0x4000;
	// don't collide against curves with this set
	public static inline var	SURF_LIGHTFILTER : Int	= 0x8000;
	// act as a light filter during q3map -light
	public static inline var	SURF_ALPHASHADOW : Int	= 0x10000;
	// do per-pixel light shadow casting in q3map
	public static inline var	SURF_NODLIGHT : Int	= 0x20000;
	// don't dlight even if solid(solid lava, skies)
	public static inline var SURF_DUST : Int	= 0x40000;
	// leave a dust trail when walking on this surface
	
	public var name : String;
	// The name of the texture w/o the extension(c8[64]);
	public var flags : UInt;
	// The surface flags(u32)
	public var contents : UInt ;
	// The content flags(u32)
	// size of : u32 + u32 +(c8 *64)
	public static inline var sizeof : Int = 72;

	public function new()
	{
		
	}
}
