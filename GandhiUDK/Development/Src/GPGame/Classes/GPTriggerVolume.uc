class GPTriggerVolume extends DynamicTriggerVolume;

// Según el tipo de volumen le podemos dar diferentes usos
var (GPVolume) const int MaxTouchNumber;
var int touches;
var (GPVolume) int type;
var (GPVolume) const int typeEnablingWV;
var (GPVolume) const int typeDisablingWV;
var (GPVolume) const int typeCheckPuzzlePieces;
var (GPVolume) const bool bIsToggleable;


event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	local GPWaterVolume WVolume;
	local GPPostProcessVolume PPVolume;
	local GPPuzzlePiece PPiece;
	local int countOfPieces;

	//if (touches < MaxTouchNumber)
	//{
	if(!Other.IsA('GPPlayerPawn')) return;

		switch (type)
		{
			case typeEnablingWV:
				// Activamos el agua
				ForEach AllActors(class'GPWaterVolume', WVolume)
				{
					WVolume.bEnabled=true;
					WVolume.SetCollision(true);
				}
				// Y sus efectos
				ForEach AllActors(class'GPPostProcessVolume', PPVolume)
				{
					PPVolume.bEnabled=true;
					PPVolume.SetActive(true);
					PPVolume.Settings.bEnableDOF = true;
					GPPlayerController(Pawn(Other).Controller).ppsOff = PPVolume.Settings;
				}
				// Marcamos que gandhi está en el agua
				GPPlayerPawn(Other).IsUnderWater = true;
				if(GPPlayerPawn(Other).turbine != none) GPPlayerPawn(Other).turbine.showBubbles();
			
				GPPlayerController(Pawn(Other).Controller).ToggleWaterGlasses();
				GPPlayerController(Pawn(Other).Controller).ToggleWaterGlasses();
			
				// Reproducimos sonido especifico
				if (!GPGame(WorldInfo.Game).WaterSound.IsPlaying())
					GPGame(WorldInfo.Game).WaterSound.Play();

				break;
			case typeDisablingWV:
				// Desactivamos el agua
				ForEach AllActors(class'GPWaterVolume', WVolume)
				{
					WVolume.bEnabled=false;
					WVolume.SetCollision(false, false);

					if (GPPlayerController(Pawn(Other).Controller).GlassesOn)
					{
						GPPlayerController(Pawn(Other).Controller).ToggleWaterGlasses();
					}
				}
				// Y sus efectos
				ForEach AllActors(class'GPPostProcessVolume', PPVolume)
				{
					PPVolume.bEnabled=false;
					PPVolume.SetActive(false);
				}
				// Marcamos que gandhi NO está en el agua
				GPPlayerPawn(Other).IsUnderWater = false;
				if(GPPlayerPawn(Other).turbine != none) GPPlayerPawn(Other).turbine.hideBubbles();

				// Paramos el sonido especifico
				if (GPGame(WorldInfo.Game).WaterSound.IsPlaying())
					GPGame(WorldInfo.Game).WaterSound.Stop();

				break;

			case typeCheckPuzzlePieces:
				countOfPieces = 0;
				foreach Pawn(Other).InvManager.InventoryActors(class'GPPuzzlePiece', PPiece)
				{
					countOfPieces++;
				}
				if (countOfPieces == 3)
				{
					Super.Touch(Other, OtherComp, HitLocation, HitNormal);
				}
				break;
		}

	//	touches++;
	//}

	
}

event untouch(Actor Other)
{
	//if (bIsToggleable)
	//{
	//	if (type == typeEnablingWV) type = typeDisablingWV;
	//	else if (type == typeDisablingWV) type = typeEnablingWV;
	//}
}

DefaultProperties
{
	MaxTouchNumber = 1;
	touches = 0;

	bIsToggleable = true;
	typeEnablingWV = 1;
	typeDisablingWV = 2;
	typeCheckPuzzlePieces = 3;

	type = 2;

	
}
