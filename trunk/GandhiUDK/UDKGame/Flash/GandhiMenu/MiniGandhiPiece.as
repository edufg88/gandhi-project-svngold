package
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	public class MiniGandhiPiece extends MovieClip
	{
		public var RED:uint = 0xFF0000;
		public var YELLOW:uint = 0xFFFF00;
		public var GREEN:uint = 0x00FF00;
		public var BLACK:uint = 0x000000;
		
		public function MiniGandhiPiece()
		{
			super();
		}
		
		public function setVida(v:Number) {
			var myColorTransform = new ColorTransform();
			
			visible = true;
			
			if(v > 0.5) myColorTransform.color = GREEN;
			else if(v > 0.25) myColorTransform.color = YELLOW;
			else if(v >= 0) myColorTransform.color = RED;
			else visible = false;
			
			transform.colorTransform = myColorTransform;
		} 
	}
}