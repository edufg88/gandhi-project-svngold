package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	public class GandhiMenu extends MovieClip
	{
		
		public const MENUMAIN:int = 1;
		public const MENUHELP:int = 2;
		public const MENUCREDITS:int = 3;
		
		public var nextMenu:int = MENUMAIN;
		
		public function GandhiMenu()
		{
			anim.gotoAndStop(MENUMAIN);
			mainEvents();
			stage.addEventListener(Event.ENTER_FRAME, update);
		}
		
		public function mainEvents() {
			anim.core.btnPlay.addEventListener(MouseEvent.CLICK, playClicked);
//			anim.core.btnPlay;
//			new SimpleButton().mouseEnabled = false;
//			new MovieClip().mo
			anim.core.btnHelp.addEventListener(MouseEvent.CLICK, helpClicked);
			anim.core.btnCredits.addEventListener(MouseEvent.CLICK, creditsClicked);
			anim.core.btnExit.addEventListener(MouseEvent.CLICK, exitClicked);
		}
		
		public function backEvents() {
			anim.core.btnBack.addEventListener(MouseEvent.CLICK, backClicked);
		}
		
		public function playClicked(e:MouseEvent) {
			play();
			nextMenu = 0;
		}
		
		public function helpClicked(e:MouseEvent) {
			play();
			nextMenu = MENUHELP;
		}
		
		public function backClicked(e:MouseEvent) {
			play();
			nextMenu = MENUMAIN;
		}
		
		public function creditsClicked(e:MouseEvent) {
			play();
			nextMenu = MENUCREDITS;
		}
		
		public function exitClicked(e:MouseEvent) {
			ExternalInterface.call("exitGame");
		}
		
		public function update(e:Event) {
			mouseCursor.x = mouseX;
			mouseCursor.y = mouseY;
			if(currentFrame == 20) {
				this.mouseChildren = true;
			}
			else this.mouseChildren = false;
			if(currentFrame == totalFrames) {
				if(nextMenu == 0) {
					resume();
					return;
				}
				anim.gotoAndStop(nextMenu);
				if(nextMenu == MENUMAIN) mainEvents();
				else backEvents();
				gotoAndPlay(1);
			}
		}
		
		public function resume() {
			ExternalInterface.call("hideMenu");
		}
	}
}