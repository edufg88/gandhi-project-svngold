package
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	public class GandhiInventory extends MovieClip
	{
		public var inventory:Array = new Array();
		public var invWeapIndex:int = 1;
		public var invItemIndex:int = 1;
		public var invCorIndex:int = 1;
		public var invSpecialIndex:int = 1;
		public var invKeysIndex:int = 1;
		
		public var repKitSlot:Slot;
		public var enerCellSlot:Slot;
		public var actualSlot:Slot;
		public var toRepair:InvItem;
		
		public static const MAXARMORS = 14;
		
		public static const INDFAKE:int = 69;
		public static const INDCHEST:int = 2;
		public static const INDRFOREARM:int = 8;
		public static const INDLFOREARM:int = 4;
		public static const INDRUPPERARM:int = 10;
		public static const INDLUPPERARM:int = 6;
		public static const INDRTHIGH:int = 5;
		public static const INDLTHIGH:int = 9;
		public static const INDRCALF:int = 7;
		public static const INDLCALF:int = 3;
		public static const ENDARMORS:int = INDRUPPERARM; //fi armors
		
		public static const INDWEAPON1:int = 11;
		public static const INDWEAPON2:int = 12;
		public static const INDWEAPON3:int = 13;
		public static const INDWEAPON4:int = 14;
		public static const ENDWEAPONS:int = INDWEAPON4; //fi weapons
		
		public static const INDREPAIRKIT:int = 15;
		public static const INDENERGYCELL:int = 16;
		public static const INDC4:int = 17;
		public static const INDKEY1:int = 18;
		public static const INDKEY2:int = 19;
		public static const INDKEY3:int = 20;
		public static const INDKEY4:int = 21;
		public static const INDKEY5:int = 22;
		public static const INDKEY6:int = 23;
		public static const INDPUZZLE1:int = 24;
		public static const INDPUZZLE2:int = 25;
		public static const INDPUZZLE3:int = 26;
		public static const INDPUZZLE4:int = 27;
		public static const ENDITEMS:int = INDPUZZLE4; //fi items
		
		public static const INDSIRIMOD:int = 28;
		public static const INDSHIELD:int = 29;
		public static const INDFLASH:int = 30;
		public static const INDTURBINA:int = 31;
		
		public static const INDNOTHING:int = 32;
		
		public static const INDTRASH:int = 33;
		
//		public static var MAXINFOBARRAW:Number;
		
		public const mapZControl:Number = 1100;
		public const mapZFirst:Number = mapZControl + 750;
		public const mapZSecond:Number = mapZFirst + 650;
		public const mapZThird:Number = mapZSecond + 500;
		
		public static var sta:Stage;
		public static var dragSlot:Slot;
		public static var eveDisp:EventDispatcher = new EventDispatcher();
		public static const EVENTRESETSLOT:String = "resetSlot";
		public static const EVENTDELETESLOT:String = "deleteSlot";
		public static const EVENTLIGHTENARMORS:String = "lightenArmors";
		public static const EVENTDARKEN:String = "darken";
		public static const EVENTFAKEOVER:String = "fakeOver";
		
//		public var endDebugItems:Boolean = false;
		public static var debuggin:Boolean = true;
		public var debugHeal:int = 2;
		public var debugKit:int = 2;
		public static var debugRupperAtt = false;
		public static var debugLupperAtt = true;
		
		public var arrInfo:Array = new Array();
		public var arrDial:Array = new Array();
		
		//instances
		public var mouseCursor:MovieClip;
		public var movMapa:MovieClip;
		public var infoPanel:MovieClip;
//		public var vidaGandhi:HUDCircle;
//		public var monigote:MiniGandhi;
		public var modCorazas:MovieClip;
		public var modArmas:MovieClip;
		public var modItems:MovieClip;
		public var btnEquipment:SimpleButton;
		public var btnInventario:SimpleButton;
		public var btnMapa:SimpleButton;
		public var btnLog:SimpleButton;
		public var btnOpciones:SimpleButton;
		public var MyRenderTarget_mc:MovieClip;
		
		public var slotWeap1:Slot;
		public var slotWeap2:Slot;
		
		public var slotcor1:Slot;
		public var slotcor2:Slot;
		public var slotcor3:Slot;
		public var slotcor4:Slot;
		public var slotcor5:Slot;
		public var slotcor6:Slot;
		public var slotcor7:Slot;
		public var slotcor8:Slot;
		public var slotcor9:Slot;
		public var slotcor10:Slot;
		
		public var slotitem1:Slot;
		public var slotitem2:Slot;
		public var slotitem3:Slot;
		public var slotitem4:Slot;
		public var slotitem5:Slot;
		public var slotitem6:Slot;
		public var slotitem7:Slot;
		public var slotitem8:Slot;
		public var slotitem9:Slot;
		public var slotitem10:Slot;
		
		public var slotkey1:Slot;
		public var slotkey2:Slot;
		public var slotkey3:Slot;
		public var slotkey4:Slot;
		public var slotkey5:Slot;
		
		public var slotSpecial1:Slot;
		public var slotSpecial2:Slot;
		public var slotSpecial3:Slot;
		public var slotSpecial4:Slot;
		public var slotSpecial5:Slot;
		public var slotSpecial6:Slot;
		public var slotSpecial7:Slot;
		public var slotSpecial8:Slot;
		
		public var slotAttWeapon1:Slot;
		public var slotAttChest1:Slot;
		public var slotAttRUpperArm1:Slot;
		public var slotAttRForeArm1:Slot;
		public var slotAttRThigh1:Slot;
		public var slotAttRCalf1:Slot;
		public var slotAttLUpperArm1:Slot;
		public var slotAttLForeArm1:Slot;
		public var slotAttLThigh1:Slot;
		public var slotAttLCalf1:Slot;
		
		public var menuLog:GandhiLog;
		public var menuOptions:GandhiNewMenu;
		
		public var movTrash:InvTrash;
		
		
		public function GandhiInventory()
		{
			stop();
			sta = stage;
			stage.addEventListener(Event.ENTER_FRAME, update);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, rightFake);
			buttonEvents();
			tabEquipmentEvents(null);
			
			mouseCursor.mouseEnabled = false;
			mouseCursor.mouseChildren = false;
			
			sendDebugInventory();
//			endDebugItems = true;
			
			fillSlots();
		}
		
		public function sendDebugInventory() {
			newItem("DebugRUpperArmArmor", 1, debugRupperAtt);
			if(debugHeal > 0) newItem("DebugEnergy", 0, false);
			newItem("DebugLUpperArmArmor", 0.5, debugLupperAtt);
			if(debugKit > 0) newItem("DebugRepair", 0, false);
			newItem("DebugLinkGun", 0, true);
			newItem("DebugShockRifle", 0, false);
			if(debugHeal > 1) newItem("DebugEnergy", 0, false);
			if(debugKit > 1) newItem("DebugRepair", 0, false);
//			newItem("DebugTurbine", 0.3, false);
			newItem("DebugChestArmor", 0.2, false);
			
			arrInfo.unshift("debug dialog 1 this one is long because I want tot prove myself to you, motherfucker, bitches, there are snakes!");
			arrInfo.unshift("Do you remember the humans? Of course you do, it’s the first data they put into you.");
			arrInfo.unshift("Another Test 3");
			arrInfo.unshift("Hola hey 4");
		}
		
		public function stopDebug() {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, rightFake);
			inventory = new Array();
			arrInfo = new Array();
			debuggin = false;
		}
		
		public function showEqu() {
			tabEquipmentEvents(null);
		}
		
		public function showInv() {
			tabInventarioEvents(null);
		}
		
		public function showMap() {
			tabMapaEvents(null);
		}
		
		public function showLog() {
			tabLogEvents(null);
		}
		
		public function showEsc() {
			tabOpcionesEvents(null);
		}
		
		public function update(e:Event) {
			mouseCursor.x = mouseX;
			mouseCursor.y = mouseY;
		}
		
		public function coordGandhi(ganX:Number, ganY:Number, ganZ:Number, ganW:int) {
			//X:4832    277
			//Y:-5088   300
			
			//X:-2871    -234.30
			//Y:-894   -68.95
			
			//0,0
			//X:0    351.9
			//Y:0   374.1
//			var mapX:Number = ganX * 3.0/50.0;
//			var mapY:Number = ganY * 3.0/50.0;
			
			var mapX:Number = ganX * 2.0/25.0;
			var mapY:Number = ganY * 2.0/25.0;
			var ico:MovieClip = new icoGandhi();
			if(ganZ > mapZThird) movMapa.mapThird.visible = true;
			else if(ganZ > mapZSecond) movMapa.mapSecond.visible = true;
			else if(ganZ > mapZFirst) movMapa.mapFirst.visible = true;
			else if(ganZ > mapZControl) movMapa.mapControl.visible = true;
//			else movMapa.mapHangar.visible = true;
			movMapa.ganLoc.addChild(ico);
			ico.x = mapX;
			ico.y = mapY;
			ico.rotation = ganW;
		}
		
		public function coordPuzzle(ganX:Number, ganY:Number, ganZ:Number) {
			var mapX:Number = ganX * 2.0/25.0;
			var mapY:Number = ganY * 2.0/25.0;
			var ico:MovieClip = new icoPuzzle();
//			if(ganZ > mapZThird) movMapa.mapThird.visible = true;
//			else if(ganZ > mapZSecond) movMapa.mapSecond.visible = true;
//			else if(ganZ > mapZFirst) movMapa.mapFirst.visible = true;
//			else if(ganZ > mapZControl) movMapa.mapControl.visible = true;
			//			else movMapa.mapHangar.visible = true;
			movMapa.ganLoc.addChild(ico);
			ico.x = mapX;
			ico.y = mapY;
		}
		
		public function newItem(item:String, vida:Number, attached:Boolean) {
//			if(endDebugItems) {
//				endDebugItems = false;
//				inventory = new Array();
//			}
			var it:InvItem = new InvItem(item, vida, attached, inventory.length, getType(item));
			inventory.push(it);
//			btnEquipment.visible = false;
//			it.sloname = getSlotName(item, attached, true);
//			it.slotImg = slotImg;
		}
		
		public function fillSlots() {
			if(currentFrame == 1) fillSlotsEqu();
			else fillSlotsInv();
		}
		
		public function fillSlotsEqu() {
			eveDisp.dispatchEvent(new Event(EVENTRESETSLOT));
			actualSlot = null;
			repKitSlot = null;
			enerCellSlot = null;
			invWeapIndex = 1;
			invCorIndex = 1;
			invItemIndex = 1;
			invSpecialIndex = 1;
			invKeysIndex = 1;
			for(var i:int = 0; i < inventory.length; i++) {
				var it:InvItem = InvItem(inventory[i]);
				var slo:Slot;
				if(it.type == INDFAKE) continue;
				if(it.type == INDREPAIRKIT) {
					if(repKitSlot == null) {
						slo = Slot(getChildByName(getSlotName(it.type, it.attached, true)));
						repKitSlot = slo;
					}
					else {
						slo = repKitSlot;
						slo.stackUp();
					}
				}
//				else if(it.type == INDENERGYCELL) {
//					if(enerCellSlot == null) {
//						slo = Slot(getChildByName(getSlotName(it.type, it.attached, true)));
//						enerCellSlot = slo;
//					}
//					else {
//						slo = enerCellSlot;
//						slo.stackUp();
//					}
//				}
				else if(it.type <= ENDWEAPONS) slo = Slot(getChildByName(getSlotName(it.type, it.attached, true)));
				else continue;
				slo.inv = it;
				slo.update();
			}
			
			infoPanel.gotoItem(INDNOTHING);
			eveDisp.dispatchEvent(new Event(EVENTFAKEOVER));
			
//			darkenMods();
		}
		
		public function fillSlotsInv() {
			eveDisp.dispatchEvent(new Event(EVENTRESETSLOT));
			actualSlot = null;
			repKitSlot = null;
			enerCellSlot = null;
			invWeapIndex = 1;
			invCorIndex = 1;
			invItemIndex = 1;
			invSpecialIndex = 1;
			invKeysIndex = 1;
			for(var i:int = 0; i < inventory.length; i++) {
				var it:InvItem = InvItem(inventory[i]);
				var slo:Slot;
				if(it.type == INDFAKE) continue;
				if(it.type == INDREPAIRKIT) {
					continue;
				}
				else if(it.type == INDENERGYCELL) {
					if(enerCellSlot == null) {
						slo = Slot(getChildByName(getSlotName(it.type, it.attached, true)));
						enerCellSlot = slo;
					}
					else {
						slo = enerCellSlot;
						slo.stackUp();
					}
				}
				else if(it.type > ENDWEAPONS) slo = Slot(getChildByName(getSlotName(it.type, it.attached, true)));
				else continue;
				slo.inv = it;
				slo.update();
			}
			
			infoPanel.gotoItem(INDNOTHING);
			eveDisp.dispatchEvent(new Event(EVENTFAKEOVER));
			
//			darkenMods();
		}
		
		public function getType(item:String):int {
			if(item.indexOf("Armor") >= 0) {
				if(item.indexOf("Chest") >= 0) return INDCHEST;
				else if(item.indexOf("RForeArm") >= 0) return INDRFOREARM;
				else if(item.indexOf("LForeArm") >= 0) return INDLFOREARM;
				else if(item.indexOf("RUpperArm") >= 0) return INDRUPPERARM;
				else if(item.indexOf("LUpperArm") >= 0) return INDLUPPERARM;
				else if(item.indexOf("LThigh") >= 0) return INDLTHIGH;
				else if(item.indexOf("RThigh") >= 0) return INDRTHIGH;
				else if(item.indexOf("LCalf") >= 0) return INDLCALF;
				else if(item.indexOf("RCalf") >= 0) return INDRCALF;
			}
			else if(item.indexOf("LinkGun") >= 0) return INDWEAPON1;
			else if(item.indexOf("ShockRifle") >= 0) return INDWEAPON2;
			else if(item.indexOf("Energy") >= 0) return INDENERGYCELL;
			else if(item.indexOf("Repair") >= 0) return INDREPAIRKIT;
			else if(item.indexOf("C4") >= 0) return INDC4;
			else if(item.indexOf("Key1") >= 0) return INDKEY1;
			else if(item.indexOf("Key2") >= 0) return INDKEY2;
			else if(item.indexOf("Key3") >= 0) return INDKEY3;
			else if(item.indexOf("Key4") >= 0) return INDKEY4;
			else if(item.indexOf("Key5") >= 0) return INDKEY5;
			else if(item.indexOf("Key6") >= 0) return INDKEY6;
			else if(item.indexOf("PuzzlePieceA") >= 0) return INDPUZZLE1;
			else if(item.indexOf("PuzzlePieceB") >= 0) return INDPUZZLE2;
			else if(item.indexOf("PuzzlePieceC") >= 0) return INDPUZZLE3;
			else if(item.indexOf("Siri") >= 0) return INDSIRIMOD;
			else if(item.indexOf("Shield") >= 0) return INDSHIELD;
			else if(item.indexOf("Flash") >= 0) return INDFLASH;
			else if(item.indexOf("Turbine") >= 0) return INDTURBINA;
			//else
			return INDFAKE;
		}
		
		public function getSlotName(type:int, attached:Boolean, increase:Boolean):String {
			var strSlot:String;
			var indSlot:int;
			
			if(attached) {
				switch(type) {
					case INDCHEST:
						strSlot = "Chest";
						break;
					case INDRFOREARM:
						strSlot = "RForeArm";
						break;
					case INDLFOREARM:
						strSlot = "LForeArm";
						break;
					case INDRUPPERARM:
						strSlot = "RUpperArm";
						break;
					case INDLUPPERARM:
						strSlot = "LUpperArm";
						break;
					case INDRTHIGH:
						strSlot = "RThigh";
						break;
					case INDLTHIGH:
						strSlot = "LThigh";
						break;
					case INDRCALF:
						strSlot = "RCalf";
						break;
					case INDLCALF:
						strSlot = "LCalf";
						break;
					case INDWEAPON1:
					case INDWEAPON2:
					case INDWEAPON3:
					case INDWEAPON4:
						strSlot = "Weapon";
						break;
				}
				strSlot = "slotAtt" + strSlot;
				indSlot = 1;
			}
			else if(type <= ENDARMORS) {
				strSlot = "slotcor";
				indSlot = invCorIndex;
				if(increase) invCorIndex++;
			}
			else if(type <= ENDWEAPONS) {
				strSlot = "slotWeap";
				indSlot = invWeapIndex;
				if(increase) invWeapIndex++;
			}
			else if(type > ENDITEMS) {
				strSlot = "slotSpecial";
				indSlot = invSpecialIndex;
				if(increase) invSpecialIndex++;
			}
			else if(type >= INDKEY1 && type <= INDKEY6) {
				strSlot = "slotkey";
				indSlot = invKeysIndex;
				if(increase) invKeysIndex++;
			}
			else {
				strSlot = "slotitem";
				indSlot = invItemIndex;
				if(increase) invItemIndex++;
			}
			return strSlot + indSlot;
		}
		
		public function rightFake(e:Event) {
			trace("faaaaaake right click");
			rightClick();
		}
		
		public function rightClick() {
			if(actualSlot != null) {
//				trace(actualSlot);
				equipalaParda(actualSlot.inv);
				if(dragSlot != null) dragSlot.mouseUp(null);
				fillSlots();
			}
		}
		
		public function lightenSlots(slo:Slot) {
			if(slo.inv == null) return;
			if(slo.inv.type == INDREPAIRKIT) {
				eveDisp.dispatchEvent(new Event(EVENTLIGHTENARMORS));
//				modCorazas.gotoAndStop(2);
			}
			else {
				var sloAtt:Slot = Slot(getChildByName(getSlotName(slo.inv.type, true, false)));
				if(sloAtt != null) {
					sloAtt.alightGreen();
				}
//				if(slo.inv.attached) {
//					if(slo.inv.type <= ENDARMORS) modCorazas.gotoAndStop(2);
//					else if(slo.inv.type <= ENDWEAPONS) modArmas.gotoAndStop(2);
//				}
			}
			
			slo.alightBlue();
			actualSlot = slo;
			
			infoPanel.gotoItem(slo.inv.type);
//			new TextField().setTextFormat(new TextFormat("FontTechnic"));
//			infoPanel.txtUse.setTextFormat(new TextFormat("Technic Bold"));;
//			infoPanel.barraVida.width = MAXINFOBARRAW*slo.inv.vida;
//			infoPanel.barraVida.setVida(slo.inv.vida);
		}
		
		public function resetSlots(slo:Slot) {
			if(slo.inv == null) return;
//			slo.adarken();
//			actualSlot = null;
//			
//			slo = Slot(getChildByName(getSlotName(slo.inv.type, true, false)));
//			if(slo != null) {
//				slo.adarken();
//			}
			eveDisp.dispatchEvent(new Event(EVENTDARKEN));
			actualSlot = null;
			infoPanel.gotoItem(INDNOTHING);
			
//			darkenMods();
		}
		
//		public function darkenMods() {
//			modArmas.gotoAndStop(1);
//			modCorazas.gotoAndStop(1);
//			modItems.gotoAndStop(1);
//		}
		
		public function dragEvent(targetSlot:Slot) {
			if(dragSlot.inv == null) return;
			
			if(dragSlot.inv.type == INDREPAIRKIT) {
				if(targetSlot.inv != null && targetSlot.inv.type <= ENDARMORS) {
					toRepair = targetSlot.inv;
					equipalaParda(dragSlot.inv);
				}
			}
			else if(!dragSlot.attachable && targetSlot.attachable) {
				if(targetSlot.name == getSlotName(dragSlot.inv.type, true, false)) {
//					var tempInv:InvItem = dstSlot.inv;
//					dstSlot.inv = dragSlot.inv;
//					dragSlot.inv = tempInv;
					
//					if(targetSlot.inv != null) targetSlot.inv.unequip();
//					dragSlot.inv.equip();
					equipalaParda(dragSlot.inv);
					fillSlots();
//					trace("yup!");
				}
			}
			else if(dragSlot.attachable && !targetSlot.attachable) {
				if(dragSlot.inv.type <= ENDARMORS && !CanHazMoreArmor()) return;
				ExternalInterface.call("invEquip", dragSlot.inv.index, false);
				resetInventory();
			}
			//					GandhiInventory.dragSlot.inv = null;
		}
		
		public function CanHazMoreArmor():Boolean {
			var uneqArmors:int;
			
			uneqArmors = 0;
			
			for each(var inv:InvItem in inventory)
			{
				if(inv.type <= ENDARMORS && !inv.attached) uneqArmors++;
			}
				
			return uneqArmors < MAXARMORS;
		}
		
		public function enableTrash() {
			movTrash.enable();
		}
		
		public function disableTrash() {
			if(movTrash != null) movTrash.disable();
		}
		
		public function trashArmor() {
//			trace("wtf TRASH");
			if(dragSlot.inv == null || dragSlot.inv.type > ENDARMORS) return;
//			trace("wtf ARMOR");
			ExternalInterface.call("invTrash", dragSlot.inv.index);
//			if(debuggin) debugHeal--;
			resetInventory();
		}
		
		public function equipalaParda(inv:InvItem) {
			if(inv.type <= ENDARMORS || inv.type == INDTURBINA) {
				var slo:Slot = Slot(getChildByName(getSlotName(inv.type, true, false)));
				if(slo.inv != null) {
					//Unequip
					if(!CanHazMoreArmor()) return;
					ExternalInterface.call("invEquip", slo.inv.index, false);
				}
				if(inv != slo.inv) {
					//Equip
					ExternalInterface.call("invEquip", inv.index, true);
				}
				resetInventory();
			}
			else if(inv.type <= ENDWEAPONS) {
				ExternalInterface.call("attWeap", inv.index);
				resetInventory();
			}
			else if(inv.type == INDENERGYCELL) {
				ExternalInterface.call("invHeal", inv.index);
				if(debuggin) debugHeal--;
				resetInventory();
			}
			else if(inv.type == INDREPAIRKIT && toRepair != null) {
				ExternalInterface.call("invRepair", inv.index, toRepair.index);
				if(debuggin) debugKit--;
				toRepair = null;
				resetInventory();
			}
		}
		
		public function resetInventory() {
			inventory = new Array();
			ExternalInterface.call("sendInventory");
			if(debuggin) sendDebugInventory();
			fillSlots();
		}
		
		public function addLog(str:String, isDialog:Boolean) {
			if(isDialog) arrDial.unshift(str);
			else arrInfo.unshift(str);
		}
		
		public function buttonEvents() {
			btnEquipment.addEventListener(MouseEvent.CLICK, tabEquipmentEvents);
			btnInventario.addEventListener(MouseEvent.CLICK, tabInventarioEvents);
			btnMapa.addEventListener(MouseEvent.CLICK, tabMapaEvents);
			btnLog.addEventListener(MouseEvent.CLICK, tabLogEvents);
			btnOpciones.addEventListener(MouseEvent.CLICK, tabOpcionesEvents);
		}
		
		public function buttonReset() {
			btnEquipment.visible = true;
			btnInventario.visible = true;
			btnMapa.visible = true;
			btnLog.visible = true;
			btnOpciones.visible = true;
		}
		
		public function tabEquipmentEvents(e:Event) {
//			eveDisp.dispatchEvent(new Event(EVENTDELETESLOT));
			tabMapaEvents(null);
			gotoAndStop(1);
			buttonReset();
			btnEquipment.visible = false;
			
//			darkenMods();
			
			infoPanel.gotoItem(INDNOTHING);
			
//			repKitSlot = null;
//			enerCellSlot = null;
//			actualSlot = null;
			fillSlots();
			ExternalInterface.call("updActualTab", 0);
		}
		
		public function tabInventarioEvents(e:Event) {
//			eveDisp.dispatchEvent(new Event(EVENTDELETESLOT));
			tabMapaEvents(null);
			gotoAndStop(2);
			buttonReset();
			btnInventario.visible = false;
			
//			darkenMods();
			
			infoPanel.gotoItem(INDNOTHING);

//			repKitSlot = null;
//			enerCellSlot = null;
//			actualSlot = null;
			fillSlots();
			ExternalInterface.call("updActualTab", 0);
		}
		
		public function tabMapaEvents(e:Event) {
			disableTrash();
			gotoAndStop(3);
			buttonReset();
			btnMapa.visible = false;
			
			movMapa.mapFirst.visible = false;
			movMapa.mapSecond.visible = false;
			movMapa.mapThird.visible = false;
			movMapa.mapControl.visible = false;
			ExternalInterface.call("updGandhiCoord");
			eveDisp.dispatchEvent(new Event(EVENTDELETESLOT));
			
			repKitSlot = null;
			enerCellSlot = null;
			actualSlot = null;
			ExternalInterface.call("updActualTab", 1);
		}
		
		public function tabLogEvents(e:Event) {
			disableTrash();
			gotoAndStop(4);
			buttonReset();
			btnLog.visible = false;
			
			menuLog.arrDial = arrDial;
			menuLog.arrInfo = arrInfo;
			menuLog.infoClicked(null);
			
			eveDisp.dispatchEvent(new Event(EVENTDELETESLOT));
			repKitSlot = null;
			enerCellSlot = null;
			actualSlot = null;
			ExternalInterface.call("updActualTab", 2);
		}
		
		public function tabOpcionesEvents(e:Event) {
			disableTrash();
			gotoAndStop(5);
			buttonReset();
			btnOpciones.visible = false;
			
			menuOptions.helpClicked(null);
			
			eveDisp.dispatchEvent(new Event(EVENTDELETESLOT));
			repKitSlot = null;
			enerCellSlot = null;
			actualSlot = null;
			ExternalInterface.call("updActualTab", 3);
		}
	}
}