package
{
	import flash.display.MovieClip;
	
	public class AmmoInfo extends MovieClip
	{
		public var BullWidth:Number;
		public var bullMask:MovieClip;
		
		public function AmmoInfo()
		{
			txtAmmo.text = "";
			BullWidth = bullMask.width;
		}
		
		public function updateAmmo(ammo:int, maxAmmo:int) {
			txtAmmo.text = "" + ammo;
//			barAmmo.setVida(Number(ammo)/maxAmmo);
			bullMask.width = (Number(ammo)/maxAmmo) * BullWidth;
		}
	}
}