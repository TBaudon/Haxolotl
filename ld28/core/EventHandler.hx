package ld28.core;
import flash.display.Stage;
import flash.events.MouseEvent;
import flash.events.TouchEvent;

/**
 * ...
 * @author Thomas B
 */
class EventHandler
{
	
	var touchX : Float;
	var touchY : Float;
	
	var stages : List<ld28.core.Stage>;

	public function new(_stage : flash.display.Stage, _stages : List<ld28.core.Stage>) 
	{
		#if mobile
			_stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			_stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
			_stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
		#else
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		#end
		
		stages = _stages;
	}
	
	
	private function onMouseMove(e:MouseEvent):Void 
	{
		setTouchPos(e.localX, e.localY);
		for (a in stages)
			a.TOUCH_MOVE.dispatch();
	}
	
	private function onMouseUp(e:MouseEvent):Void 
	{
		setTouchPos(e.localX, e.localY);
		for (a in stages)
			a.TOUCH_UP.dispatch();
	}
	
	private function onMouseDown(e:MouseEvent):Void 
	{
		setTouchPos(e.localX, e.localY);
		for (a in stages)
			a.TOUCH_DOWN.dispatch();
	}
	
	private function onTouchMove(e:TouchEvent):Void 
	{
		setTouchPos(e.localX, e.localY);
		for (a in stages)
			a.TOUCH_MOVE.dispatch();
	}
	
	private function onTouchEnd(e:TouchEvent):Void 
	{
		setTouchPos(e.localX, e.localY);
		for (a in stages)
			a.TOUCH_UP.dispatch();
	}
	
	private function onTouchBegin(e:TouchEvent):Void 
	{
		setTouchPos(e.localX, e.localY);
		for (a in stages)
			a.TOUCH_DOWN.dispatch();
	}
	
	function setTouchPos(x : Float, y : Float):Void 
	{
		touchX = x;
		touchY = y;
	}
	
}