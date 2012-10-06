package
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.system.fscommand;
	
	public class GandhiNewMenu extends MovieClip
	{
		public static var MENUSAVE:int = 2;
		public static var MENULOAD:int = 3;
		public static var MENUHELP:int = 4;
		public static var MENUSETT:int = 5;
		public static var MENUEXIT:int = 6;
		
		//instances
		public var menuRight:MovieClip;
		public var btnSave:SimpleButton;
		public var btnLoad:SimpleButton;
		public var btnHelp:SimpleButton;
		public var btnSettings:SimpleButton;
		public var btnExit:SimpleButton;
		public var fakeSave:MovieClip;
		public var fakeLoad:MovieClip;
		public var fakeControls:MovieClip;
		public var fakeSettings:MovieClip;
		public var fakeExit:MovieClip;
		public var btnYes:SimpleButton;
		
		public function GandhiNewMenu()
		{
			menuRight.gotoAndStop(1);
			btnSave.addEventListener(MouseEvent.CLICK, saveClicked);
			btnLoad.addEventListener(MouseEvent.CLICK, loadClicked);
			btnHelp.addEventListener(MouseEvent.CLICK, helpClicked);
			btnSettings.addEventListener(MouseEvent.CLICK, settClicked);
			btnExit.addEventListener(MouseEvent.CLICK, exitClicked);
			
//			fakeSave.mouseEnabled = false;
//			fakeLoad.mouseEnabled = false;
//			fakeControls.mouseEnabled = false;
//			fakeSettings.mouseEnabled = false;
//			fakeExit.mouseEnabled = false;
		}
		
		public function buttonReset() {
			btnSave.visible = true;
			btnLoad.visible = true;
			btnHelp.visible = true;
			btnSettings.visible = true;
			btnExit.visible = true;
			
			fakeSave.visible = false;
			fakeLoad.visible = false;
			fakeControls.visible = false;
			fakeSettings.visible = false;
			fakeExit.visible = false;
			
		}
		
		public function saveClicked(e:MouseEvent) {
			buttonReset();
			btnSave.visible = false;
			fakeSave.visible = true;
			menuRight.gotoAndStop(MENUSAVE);
		}
		
		public function loadClicked(e:MouseEvent) {
			buttonReset();
			btnLoad.visible = false;
			fakeLoad.visible = true;
			menuRight.gotoAndStop(MENULOAD);
		}
		
		public function helpClicked(e:MouseEvent) {
			buttonReset();
			btnHelp.visible = false;
			fakeControls.visible = true;
			menuRight.gotoAndStop(MENUHELP);
		}
		
		public function settClicked(e:MouseEvent) {
			buttonReset();
			btnSettings.visible = false;
			fakeSettings.visible = true;
			menuRight.gotoAndStop(MENUSETT);
		}
		
		public function exitClicked(e:MouseEvent) {
			buttonReset();
			btnExit.visible = false;
			fakeExit.visible = true;
			menuRight.gotoAndStop(MENUEXIT);
			menuRight.btnYes.addEventListener(MouseEvent.CLICK, exit);
		}
		
		public function exit(e:MouseEvent) {
			ExternalInterface.call("exitGame");
		}
	}
}