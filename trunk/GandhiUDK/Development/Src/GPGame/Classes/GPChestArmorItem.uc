class GPChestArmorItem extends GPArmorItem;

simulated function OwnerEvent(name EventName)
{
	//if (Role == ROLE_Authority)
	//{
	//	if (EventName == 'A') // EFG: Controlar el nombre de los eventos
	//	{
	//		// La clase que hace el spawn de este ítem es un Dropped Pick Up
	//		//GPPlayerPawn(Owner).CambiarAlgunAtributo
	//		Spawn(class'GPChestArmorDPU', Owner,, Owner.Location, Owner.Rotation);
	//		Owner.PlaySound(ActivateSound, false, true, false);
	//	}
	//	else if (EventName == 'B')
	//	{
	//		Destroy();
	//	}
	//}
	//else if (EventName == 'A')
	//{
	//	Owner.PlaySound(ActivateSound, false, true, false);
	//}
}

function RenderStats(HUD HUD)
{
	local int PosX, PosY, NbCases, i;
	PosX = 30;
	PosY = 50;
	NbCases = 10 * ArmorPoints / 200;
	i = 0;

	while(i < NbCases && i < 10)
	{
		HUD.Canvas.SetPos(PosX, PosY);
		HUD.Canvas.SetDrawColor(250,10,10,200); //R,G,B
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
	HUD.Canvas.SetDrawColor(250, 10, 10, 200);
	HUD.Canvas.Font = class'Engine'.static.GetSmallFont();
	HUD.Canvas.DrawText("Chest Armor");
}

simulated function AdjustPawn(GPPlayerPawn P, bool bRemoveBonus)
{
	if (P != None)
	{		
		AttachToPawn(P, P.ChestArmorSocketName);
		//DroppedPickupMesh.Scale = 1;
		//DroppedPickupMesh.Scale3D=(X=1,Y=1,Z=1);
		
	}
}

function string GetName()
{
	return "Chest Armor";
}

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
		StaticMesh=StaticMesh'Gandhi.Mesh.SM_armor_body_Ribcage'
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

	ArmorPoints=200;
	MaxArmorPoints=200;

	ArmorCode=2;
}