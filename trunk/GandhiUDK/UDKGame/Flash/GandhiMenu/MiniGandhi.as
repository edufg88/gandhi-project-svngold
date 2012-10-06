package
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	public class MiniGandhi extends MovieClip
	{
		public var Chest:MiniGandhiPiece;
		public var LUpperArm:MiniGandhiPiece;
		public var RUpperArm:MiniGandhiPiece;
		public var LForeArm:MiniGandhiPiece;
		public var RForeArm:MiniGandhiPiece;
		public var LThigh:MiniGandhiPiece;
		public var RThigh:MiniGandhiPiece;
		public var LCalf:MiniGandhiPiece;
		public var RCalf:MiniGandhiPiece;
		
		public static const INDCHEST:int = 2;
		public static const INDRFOREARM:int = 8;
		public static const INDLFOREARM:int = 4;
		public static const INDRUPPERARM:int = 10;
		public static const INDLUPPERARM:int = 6;
		public static const INDRTHIGH:int = 5;
		public static const INDLTHIGH:int = 9;
		public static const INDRCALF:int = 7;
		public static const INDLCALF:int = 3;
		public static const ENDARMORS:int = INDRUPPERARM; //fi armors
		
		public var arrAr:Array = new Array();
		
		public function MiniGandhi()
		{
			super();
			arrAr.push("fake", "fake");
			arrAr.push(Chest);
			arrAr.push(LCalf);
			arrAr.push(LForeArm);
			arrAr.push(RThigh);
			arrAr.push(LUpperArm);
			arrAr.push(RCalf);
			arrAr.push(RForeArm);
			arrAr.push(LThigh);
			arrAr.push(RUpperArm);
			
			reset();
		}
		
		public function updateArmor(ArmorCode:int, armorLife:Number)
		{
			MiniGandhiPiece(arrAr[ArmorCode]).setVida(armorLife);
		}
		
		public function reset() 
		{
			for(var i:int = 2; i <= ENDARMORS; i++) {
				MiniGandhiPiece(arrAr[i]).setVida(-1);
			}
		}
	}
}