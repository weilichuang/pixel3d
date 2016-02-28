package pixel3d.loader.bsp;
/** class: Q3Entity
* Quake3 entity, can be player start point, weapons, ammo, sound etc
*
* example:
* "origin" "1600 640 344"
* "_color" "0.75 0.5 0.25"
* "light" "125"
* "classname" "light"
*/
class BSPEntity implements Dynamic
{
	public var classname : String;
	public function new()
	{
		classname = "";
	}
}
