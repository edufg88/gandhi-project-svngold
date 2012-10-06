package
{
	import flash.display.MovieClip;
	
	public class HUDCircle extends MovieClip
	{
		public var hudLife:MovieClip;
		
		public function HUDCircle()
		{
			super();
			hudLife.stop();
		}
		
		public function setVida(v:Number) {
			hudLife.gotoAndStop(int(v*10) + 1);
			if(v > 0 && v < 0.1) hudLife.gotoAndStop(2);
		}
	}
}