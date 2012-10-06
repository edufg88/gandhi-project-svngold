package
{
	import flash.display.MovieClip;
	
	public class HpBar extends MovieClip
	{
		public static var GREENBAR:int = 1;
		public static var YELLOWBAR:int = 2;
		public static var REDBAR:int = 3;
		
		public var maxbarw:Number;
		
		//instances
		public var bar:MovieClip;
		
		public function HpBar()
		{
			bar.stop();
			maxbarw = bar.width;
		}
		
		public function setVida(v:Number) {
			bar.width = v*maxbarw;
			if(v > 0.5) bar.gotoAndStop(GREENBAR);
			else if(v > 0.25) bar.gotoAndStop(YELLOWBAR);
			else bar.gotoAndStop(REDBAR);
			visible = v > 0;
		}
	}
}