package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	
	public class Slot extends MovieClip
	{
		public static const FONDONORMAL:int = 1;
		public static const FONDORED:int = 2;
		public static const FONDOGREEN:int = 3;
		public static const FONDOBLUE:int = 4;
		public static const FONDOBLACK:int = 5;
		public static const FONDOYELLOW:int = 6;
		
		public static const SLOTBLUE:int = 1;
		public static const SLOTRED:int = 3;
		public static const SLOTGREEN:int = 5;
		public static const SLOTYELLOW:int = 7;
		public static const SLOTEMPTY:int = 9;
		
		public var draggin:Boolean = false;
//		public var maxbarw:Number;
//		public var slotImg:int;
		public var inv:InvItem;
		public var attachable:Boolean;
		public var isAlighted:Boolean = false;
		public var stackNum:int;
		public var wannaDrag:Boolean = false;
		
		//instances
		public var label:TextField;
		public var barra:MovieClip;
		public var img:MovieClip;
		public var fondo:MovieClip;
		public var txtStack:TextField;
		
		public function Slot()
		{
//			maxbarw = barra.width;
			attachable = name.indexOf("Att") >= 0;
			if(attachable) {
				fondo.alpha = 0.6;
//				img.alpha = 0.75;
			}
			label.visible = false;
			
			GandhiInventory.eveDisp.addEventListener(GandhiInventory.EVENTRESETSLOT, resetSlot);
			GandhiInventory.eveDisp.addEventListener(GandhiInventory.EVENTDELETESLOT, deleteSlot);
			GandhiInventory.eveDisp.addEventListener(GandhiInventory.EVENTLIGHTENARMORS, lightenIfArmor);
			GandhiInventory.eveDisp.addEventListener(GandhiInventory.EVENTDARKEN, adarken);
			GandhiInventory.eveDisp.addEventListener(GandhiInventory.EVENTFAKEOVER, fakeOver);
			resetSlot(null);
			
			mouseChildren = false;
			doubleClickEnabled = true;
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			addEventListener(MouseEvent.ROLL_OVER, mouseRollOver);
			addEventListener(MouseEvent.ROLL_OUT, mouseRollOut);
			addEventListener(MouseEvent.DOUBLE_CLICK, mouseDblClick);
			addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			if(GandhiInventory.sta != null) GandhiInventory.sta.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			else stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		}
		
		public function alightVida(v:Number) {
			if(attachable && inv == null) fondo.gotoAndStop(SLOTEMPTY);
			else if(inv == null || inv.type > GandhiInventory.ENDARMORS) fondo.gotoAndStop(SLOTBLUE);
			else if(v > 0.5) fondo.gotoAndStop(SLOTGREEN);
			else if(v > 0.25) fondo.gotoAndStop(SLOTYELLOW);
			else fondo.gotoAndStop(SLOTRED);
			isAlighted = false;
		}
		
		public function resetSlot(e:Event) {
			if(label == null) return;
			label.text = "";
//			label.visible = false;
			barra.setVida(0);
			img.stop();
			img.visible = false;
//			fondo.gotoAndStop(SLOTBLUE);
			txtStack.visible = false;
			stackNum = 1;
			inv = null;
			alightVida(0);
			adarken(null);
		}
		
		public function deleteSlot(e:Event) {
			removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			GandhiInventory.sta.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
//			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			removeEventListener(MouseEvent.ROLL_OVER, mouseRollOver);
			removeEventListener(MouseEvent.ROLL_OUT, mouseRollOut);
			removeEventListener(MouseEvent.DOUBLE_CLICK, mouseDblClick);
			removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			GandhiInventory.eveDisp.removeEventListener(GandhiInventory.EVENTRESETSLOT, resetSlot);
			GandhiInventory.eveDisp.removeEventListener(GandhiInventory.EVENTDELETESLOT, deleteSlot);
			GandhiInventory.eveDisp.removeEventListener(GandhiInventory.EVENTLIGHTENARMORS, lightenIfArmor);
			GandhiInventory.eveDisp.removeEventListener(GandhiInventory.EVENTDARKEN, adarken);
			GandhiInventory.eveDisp.removeEventListener(GandhiInventory.EVENTFAKEOVER, fakeOver);
		}
		
		public function lightenIfArmor(e:Event) {
			if(inv != null && inv.type <= GandhiInventory.ENDARMORS) {
				alightYellow();
			}
		}
		
		public function alight() {
			if(!isAlighted) fondo.gotoAndStop(fondo.currentFrame + 1);
			isAlighted = true;
		}
		
		public function alightGreen() {
			alight();
//			fondo.gotoAndStop(FONDOGREEN);
//			isAlighted = true;
		}
		
		public function alightBlue() {
			alight();
//			fondo.gotoAndStop(FONDOBLUE);
//			isAlighted = true;
		}
		
		public function alightYellow() {
			alight();
//			fondo.gotoAndStop(FONDOYELLOW);
//			isAlighted = true;
		}
		
		public function alightRed() {
			alight();
//			fondo.gotoAndStop(FONDORED);
//			isAlighted = true;
		}
		
		public function adarken(e:Event) {
//			fondo.gotoAndStop(FONDONORMAL);
			if(isAlighted) fondo.gotoAndStop(fondo.currentFrame - 1);
			isAlighted = false;
		}
		
		public function stackUp() {
			stackNum++;
			txtStack.text = "" + stackNum;
			txtStack.visible = true;
		}
		
		public function update() {
			label.text = inv.text;
//			slotImg = inv.type;
			img.gotoAndStop(inv.type);
			img.visible = true;
//			barra.width = maxbarw*inv.vida;
			barra.setVida(inv.vida);
			alightVida(inv.vida);
		}
		
		public function fakeOver(e:Event) {
			if(stage != null && hitTestPoint(stage.mouseX, stage.mouseY)) mouseRollOver(null);
		}
		
		public function mouseRollOver(e:MouseEvent) {
//			trace("over! start", name);
			if(inv == null) return;
//			trace("over! in", name);
			GandhiInventory(parent).lightenSlots(this);
		}
		
		public function mouseRollOut(e:MouseEvent) {
//			trace("OUT! start", name);
			if(inv == null) return;
//			trace("OUT! in", name);
			if(GandhiInventory.dragSlot == null || GandhiInventory.dragSlot.inv != inv) GandhiInventory(parent).resetSlots(this);
		}
		
		public function mouseDblClick(e:MouseEvent) {
//			trace("fucker");
			GandhiInventory(parent).rightClick();
		}
		
		public function mouseDown(e:MouseEvent) {
			if(draggin) return;
			if(inv == null) return;
			wannaDrag = true;
		}
		
		public function mouseMove(e:MouseEvent) {
//			if(!isAlighted) mouseRollOver(e);
			if(!wannaDrag) return;
			wannaDrag = false;
			var popSlot:Slot = new Slot();
			popSlot.label.text = label.text;
			popSlot.img.gotoAndStop(inv.type);
			popSlot.img.visible = true;
			//			popSlot.barra.width = barra.width;
			popSlot.barra.setVida(inv.vida);
			popSlot.alightVida(inv.vida);
			//			var p:Point = localToGlobal(new Point(0, 0));
			popSlot.x = x;
			popSlot.y = y;
			popSlot.inv = inv;
			popSlot.attachable = attachable;
			//			GandhiInventory(parent).lightenSlots(inv);
			popSlot.draggin = true;
			GandhiInventory.dragSlot = popSlot;
			parent.addChild(popSlot);
			if(inv.type <= GandhiInventory.ENDARMORS) GandhiInventory(parent).enableTrash();
			popSlot.startDrag(false);
		}
		
		public function mouseUp(e:MouseEvent) {
			wannaDrag = false;
			//			Game2.dragPieza = this;
			if(draggin) {
//				trace("draggg", name);
				//				GandhiInventory(parent).resetSlots(inv);
				stopDrag();
				GandhiInventory.dragSlot = null;
				mouseRollOut(null);
				GandhiInventory(parent).disableTrash();
				parent.removeChild(this);
				deleteSlot(null);
				
			}
			else if(GandhiInventory.dragSlot != null && 
				(isAlighted && hitTestObject(GandhiInventory.dragSlot)
				|| hitTestPoint(GandhiInventory.sta.mouseX, GandhiInventory.sta.mouseY))) {
//				trace("uppppp", name);
				GandhiInventory(parent).dragEvent(this);
			}
		}
	}
}