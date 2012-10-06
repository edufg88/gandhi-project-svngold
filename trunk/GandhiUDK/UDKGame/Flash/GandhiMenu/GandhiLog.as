package
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	
	import scaleform.clik.data.DataProvider;
	
	public class GandhiLog extends MovieClip
	{
		public static var MENUDIAL:int = 2;
		public static var MENUINFO:int = 3;
		
		public var arrInfo:Array = new Array();
		public var arrDial:Array = new Array();
		
		//instances
		public var menuRight:MovieClip;
		public var btnDialogs:SimpleButton;
		public var btnInfo:SimpleButton;
		public var fakeDial:MovieClip;
		public var fakeInfo:MovieClip;
		
		public function GandhiLog()
		{
//			menuRight.gotoAndStop(1);
			btnDialogs.addEventListener(MouseEvent.CLICK, dialClicked);
			btnInfo.addEventListener(MouseEvent.CLICK, infoClicked);
			
//			fakeDial.mouseEnabled = false;
//			fakeInfo.mouseEnabled = false;
			
//			var itemsData:Array = new Array();
//			for (var i:int = 1; i < 15; i++) {
//				itemsData.push({label:"Item " + i, index:i});
//			}
		}
		
		public function buttonReset() {
			btnDialogs.visible = true;
			btnInfo.visible = true;
			fakeDial.visible = false;
			fakeInfo.visible = false;
		}
		
		public function dialClicked(e:MouseEvent) {
			buttonReset();
			btnDialogs.visible = false;
			fakeDial.visible = true;
//			menuRight.gotoAndStop(MENUDIAL);
			menuRight.lstLog.dataProvider = new DataProvider(arrDial);
		}
		
		public function infoClicked(e:MouseEvent) {
			buttonReset();
			btnInfo.visible = false;
			fakeInfo.visible = true;
//			menuRight.gotoAndStop(MENUINFO);
			menuRight.lstLog.dataProvider = new DataProvider(arrInfo);
		}
	}
}