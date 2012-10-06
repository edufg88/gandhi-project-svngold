package
{
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	
	public class ScreenText extends MovieClip
	{
		public static var BASEMS:Number = 1000; //ms per letter
		public static var MPL:Number = 100; //ms per letter
		public var t:Timer = new Timer(BASEMS, 1);
		
		public function ScreenText()
		{
			txtSubs.visible = false;
//			stop();
			t.addEventListener(TimerEvent.TIMER, timerEnd);
		}
		
		public function startText(str:String) {
			t.stop();
			txtSubs.text = str;
			txtSubs.visible = true;
		}
		
		public function endText() {
			txtSubs.visible = false;
			ExternalInterface.call("textEndedEvent");
		}
		
		//-1: infinit; 0:automàtic
		public function showText(str:String, ms:int = -1) {
//			setSize(small);
			if(ms == 0) {
				ms = BASEMS + str.length * MPL;
			}
			startText(str);
			if(ms > 0) {
				t.delay = ms;
				t.reset();
//				t.addEventListener(TimerEvent.TIMER, timerEnd);
				t.start();
			}
		}
		
		public function timerEnd(e:TimerEvent) {
			endText();
		}
		
//		public function setSize(small:Boolean) {
//			if(small) gotoAndStop(2);
//			else gotoAndStop(1);
//		}
	}
}