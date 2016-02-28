package pixel3d.utils;
import flash.display.InteractiveObject;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.Vector;
import pixel3d.math.Vector2i;
import pixel3d.math.Vector2f;
class CursorControl
{
	private var keyDowns : Vector<Bool>;
	private var keyShiftDown : Bool;
	private var keyCtrlDown : Bool;
	private var mouseDown:Bool;
	
	private var windowSize : Vector2i;
	private var invWindowSize:Vector2f;

	private var target : InteractiveObject;

	private var cursorPos:Vector2f;
	private var relativePos:Vector2f;
	private var centerPos:Vector2f;

	public function new(size : Vector2i, target : InteractiveObject)
	{
		this.target = target;
		
		keyDowns = new Vector<Bool>();
		keyShiftDown = false;
		keyCtrlDown = false;
		mouseDown = false;
		
		windowSize = new Vector2i();
		invWindowSize = new Vector2f();
		
		cursorPos = new Vector2f();
		relativePos = new Vector2f(0.5, 0.5);
		centerPos = new Vector2f(0.5,0.5);
		
		reset();
		
		setWindowSize(size);
	}
	
	public function setPosition(x:Float, y:Float):Void
	{
		cursorPos.x = x;
		cursorPos.y = y;
	}
	
	private function updateRelativePosition():Void
	{
		cursorPos.x = target.mouseX;
		cursorPos.y = target.mouseY;
		
		relativePos.x = cursorPos.x * invWindowSize.x;
		relativePos.y = cursorPos.y * invWindowSize.y;
	}
	
	public function getRelativePosition():Vector2f
	{
		updateRelativePosition();
		return relativePos;
	}
	
	public function getPosition():Vector2f
	{
		updateRelativePosition();
		return cursorPos;
	}
	
	public function getCenterPosition():Vector2f
	{
		return centerPos;
	}
	
	public function isKeyDown(keyCode:Int):Bool
	{
		return keyDowns[keyCode];
	}
	
	public function isKeyShiftDown():Bool
	{
		return keyShiftDown;
	}
	
	public function isKeyCtrlDown():Bool
	{
		return keyCtrlDown;
	}
	
	public function isMouseDown():Bool
	{
		return mouseDown;
	}
	
	public function addListener() : Void
	{
		if (target != null && target.stage != null)
		{
			target.stage.addEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
			target.stage.addEventListener(KeyboardEvent.KEY_UP, __onKeyUp);
			
			target.addEventListener(MouseEvent.MOUSE_DOWN, __onMouseEvent);
			target.addEventListener(MouseEvent.MOUSE_UP, __onMouseEvent);
			target.addEventListener(MouseEvent.MOUSE_OUT, __onMouseEvent);
		}
	}
	
	public function removeListener() : Void
	{
		if (target != null && target.stage != null)
		{
		    target.stage.removeEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
		    target.stage.removeEventListener(KeyboardEvent.KEY_UP, __onKeyUp);
			
			target.removeEventListener(MouseEvent.MOUSE_DOWN, __onMouseEvent);
			target.removeEventListener(MouseEvent.MOUSE_OUT, __onMouseEvent);
			target.removeEventListener(MouseEvent.MOUSE_UP, __onMouseEvent);
		}
	}
	
	public function getWindowSize() : Vector2i
	{
		return windowSize;
	}
	
	public function setWindowSize(size : Vector2i) : Void
	{
		if(size == null) return;
		windowSize.width = size.width;
		windowSize.height = size.height;
		invWindowSize.x = 1 / windowSize.width;
		invWindowSize.y = 1 / windowSize.height;
	}
	
	private function __onKeyDown(event : KeyboardEvent) : Void
	{
		keyDowns[event.keyCode] = true;
		keyShiftDown = event.shiftKey;
		keyCtrlDown = event.ctrlKey;
		event.stopImmediatePropagation();
	}
	
	private function __onKeyUp(event : KeyboardEvent) : Void
	{
		keyDowns[event.keyCode] = false;
		keyShiftDown = event.shiftKey;
		keyCtrlDown = event.ctrlKey;
	}
	
	private function __onMouseEvent(event : MouseEvent) : Void
	{
		if(event.type == MouseEvent.MOUSE_DOWN)
		{
			mouseDown = true;
			
			centerPos.x = target.mouseX / invWindowSize.x;
			centerPos.y = target.mouseY / invWindowSize.y;
		}
		else if(event.type == MouseEvent.MOUSE_UP || event.type == MouseEvent.MOUSE_OUT)
		{
			mouseDown = false;
		}
	}

	public function reset() : Void
	{
		var len : Int = keyDowns.length;
		keyDowns.length =(len == 0) ? 256 : len;
		for(i in 0...len)
		{
			keyDowns[i] = false;
		}
		keyShiftDown = false;
		keyCtrlDown = false;
		mouseDown = false;
	}
}
