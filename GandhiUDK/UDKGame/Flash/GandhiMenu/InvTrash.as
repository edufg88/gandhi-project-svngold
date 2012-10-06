package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class InvTrash extends MovieClip
	{
		public function InvTrash()
		{
			super();
			stop();
//			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
//			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
//			GandhiInventory.eveDisp.addEventListener(GandhiInventory.EVENTDELETESLOT, destroy);
		}
		
		public function mouseUp(e:MouseEvent) {
//			trace("wtf UP 1");
			if(GandhiInventory.dragSlot != null && 
				(hitTestObject(GandhiInventory.dragSlot)
					|| hitTestPoint(GandhiInventory.sta.mouseX, GandhiInventory.sta.mouseY))) {
//				trace("wtf 222");
				GandhiInventory(parent).trashArmor();
			}
		}
		
		public function mouseMove(e:MouseEvent) {
			var slo:Slot = GandhiInventory.dragSlot;
			if(slo != null) { 
				if (hitTestObject(GandhiInventory.dragSlot)
					|| hitTestPoint(GandhiInventory.sta.mouseX, GandhiInventory.sta.mouseY)) {
//					trace("wtf MOVE");
					slo.alightRed();
					gotoAndStop(2);
					GandhiInventory(parent).infoPanel.gotoItem(GandhiInventory.INDTRASH);
				}
				else {
					slo.adarken(null);
					gotoAndStop(1);
					GandhiInventory(parent).infoPanel.gotoItem(GandhiInventory.INDNOTHING);
				}
			}
		}
		
		public function enable() {
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp, false, 1); //priority pre-slot up
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
		}
		
		public function disable() {
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
		}
	}
}