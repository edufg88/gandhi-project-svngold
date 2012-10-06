package
{
	import flash.display.MovieClip;
	
	public class GandhiHUD extends MovieClip
	{
		public var hudCircle:MovieClip;
		public var monigote:MovieClip;
		public var infoWeap:MovieClip;
		public var infoAmmo:MovieClip;
		public var fakeBack:MovieClip;
		public var infoText:MovieClip;
		public var siriCtrl:MovieClip;
		
		public function GandhiHUD()
		{
			super();
			siriCtrl.visible = false;
		}
		
		public function toggleHUD(show:Boolean) {
			hudCircle.visible = show;
			monigote.visible = show;
			infoWeap.visible = show;
			infoAmmo.visible = show;
			fakeBack.visible = show;
			infoText.visible = show;
			siriCtrl.visible = false;
		}
		
		public function showSiriCtrl(show:Boolean) {
			siriCtrl.visible = show;
		}
	}
}