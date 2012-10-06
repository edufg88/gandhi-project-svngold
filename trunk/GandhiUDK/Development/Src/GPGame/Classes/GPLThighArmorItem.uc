class GPLThighArmorItem extends GPArmorItem;

simulated function AdjustPawn(GPPlayerPawn P, bool bRemoveBonus)
{
	if (P != None)
	{		
		AttachToPawn(P, P.UpperLeftLegArmorSocketName);
	}
}

function RenderStats(HUD HUD)
{
	local int PosX, PosY, NbCases, i;
	PosX = 30;
	PosY = 150;
	NbCases = 10 * ArmorPoints / 50;
	i = 0;

	while(i < NbCases && i < 10)
	{
		HUD.Canvas.SetPos(PosX, PosY);
		HUD.Canvas.SetDrawColor(10,250,10,200); //R,G,B
		HUD.Canvas.DrawRect(8,12);

		PosX += 10;
		i++;
	}

	while(i < 10)
	{
		HUD.Canvas.SetPos(PosX, PosY);
		HUD.Canvas.SetDrawColor(255, 255, 255, 80);
		HUD.Canvas.DrawRect(8, 12);

		PosX += 10;
		i++;
	}

	HUD.Canvas.SetPos(PosX + 5, PosY);
	HUD.Canvas.SetDrawColor(10, 250, 10, 200);
	HUD.Canvas.Font = class'Engine'.static.GetSmallFont();
	HUD.Canvas.DrawText("L Thigh Armor");
}

function string GetName()
{
	return "Left Thigh Armor";
}


defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
		StaticMesh=StaticMesh'Gandhi.Mesh.SM_armor_Lleg_01'
		bOnlyOwnerSee=false
		CastShadow=false
		bForceDirectLightMap=true
		bCastDynamicShadow=false
		CollideActors=false
		BlockRigidBody=false
		//Translation=(X=100,Y=-100,Z=-200.0)
		Scale3D=(X=0.5,Y=0.5,Z=0.5)
		Scale=0.5
	End Object
	DroppedPickupMesh=StaticMeshComponent1
	PickupFactoryMesh=StaticMeshComponent1

	// EFG: Cambiar los efectos de sonido
	RespawnTime=100.0
	bReceiveOwnerEvents=true
	PickupSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_JumpBoots_PickupCue'

	ActivateSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_JumpBoots_JumpCue'

	ArmorPoints=50;
	MaxArmorPoints=50;

	ArmorCode=9;
}