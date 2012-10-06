package
{
	import flash.display.MovieClip;
	
	public class InfoPanel extends MovieClip
	{
		public var infoLbl:MovieClip;
		public var infoUse:MovieClip;
		
		public function InfoPanel()
		{
			super();
			infoLbl.stop();
			infoUse.stop();
		}
		
		public function gotoItem(i:int) {
			infoLbl.gotoAndStop(i);
			infoUse.gotoAndStop(i);
		}
	}
}