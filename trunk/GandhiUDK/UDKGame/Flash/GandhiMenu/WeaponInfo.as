package
{
	import flash.display.MovieClip;
	
	public class WeaponInfo extends MovieClip
	{
		public function WeaponInfo()
		{
			gotoAndStop(4);
			super();
		}
		
		public function updateWeapon(i:int) {
			gotoAndStop(i);
			if(i != 4) visible = true;
			else visible = false;
		}
	}
}