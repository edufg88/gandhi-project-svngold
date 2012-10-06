package
{
	import flash.external.ExternalInterface;

	public class InvItem
	{
		public var text:String;
		public var vida:Number;
		public var attached:Boolean;
//		public var sloname:String;
//		public var slotImg:int;
		public var index:int;
		public var type:int;
		
		public function InvItem(nam:String, vid:Number, att:Boolean, ind:int, typ:int)
		{
			text = nam;
			vida = vid;
			attached = att;
			index = ind;
			type = typ;
		}
		
//		public function unequip() {
//			attached = false;
//			ExternalInterface.call("invEquip", index, false);
//			if(GandhiInventory.debuggin) {
//				if(text == "DebugRUpperArmArmor") GandhiInventory.debugRupperAtt = false;
//				else if(text == "DebugLUpperArmArmor") GandhiInventory.debugLupperAtt = false;
//			}
//		}
//		
//		public function equip() {
//			attached = true;
//			ExternalInterface.call("invEquip", index, true);
//			if(GandhiInventory.debuggin) {
//				if(text == "DebugRUpperArmArmor") GandhiInventory.debugRupperAtt = true;
//				else if(text == "DebugLUpperArmArmor") GandhiInventory.debugLupperAtt = true;
//			}
//		}
	}
}