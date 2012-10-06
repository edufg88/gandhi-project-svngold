class GPShockRifleItem extends GPInventoryItem;

simulated function AdjustPawn(GPPlayerPawn P, bool bRemoveBonus)
{
	if (P != None)
	{		
		GPInventoryManager(P.InvManager).CreateInventoryFromArchetype(GPPlayerReplicationInfo(P.PlayerReplicationInfo).ClassArchetype.WeaponArchetypes[1]);
		
		if (P.WeaponAmmount == 0)
		{
			P.IsCarryingWeapon = true;
		}
		else
		{
			P.Mesh.AttachComponentToSocket(P.ShockRifleMesh, P.FundaRifleSocketName);
		}

		P.WeaponAmmount++;
	}
}

function string GetName()
{
	return "Phaser Rifle";
}

DefaultProperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=GPLightEnvironment
		bSynthesizeSHLight=true
		bIsCharacterLightEnvironment=true
		bUseBooleanEnvironmentShadowing=false
		InvisibleUpdateTime=1.f
		MinTimeBetweenFullUpdates=0.2f
	End Object
	Begin Object Class=SkeletalMeshComponent Name=SK_shockrifle
		SkeletalMesh=SkeletalMesh'BlasterRifle.Mesh.SK_blaster_rifle'
		bAcceptsDynamicDecals=false
		CastShadow=true
		TickGroup=TG_DuringASyncWork
		LightEnvironment=GPLightEnvironment
	End Object
	DroppedPickupMesh=SK_shockrifle
	PickupFactoryMesh=SK_shockrifle
}
