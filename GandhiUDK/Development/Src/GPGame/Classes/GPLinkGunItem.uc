class GPLinkGunItem extends GPInventoryItem;

simulated function AdjustPawn(GPPlayerPawn P, bool bRemoveBonus)
{
	if (P != None)
	{		
		GPInventoryManager(P.InvManager).CreateInventoryFromArchetype(GPPlayerReplicationInfo(P.PlayerReplicationInfo).ClassArchetype.WeaponArchetypes[0]);
		
		if (P.WeaponAmmount == 0)
		{
			P.IsCarryingWeapon = true;
		}
		else
		{
			P.Mesh.AttachComponentToSocket(P.LinkGunMesh, P.FundaPistolaSocketName);
		}

		P.WeaponAmmount++;
	}
}

function string GetName()
{
	return "Blaster Gun";
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
	Begin Object Class=SkeletalMeshComponent Name=SK_linkgun
		SkeletalMesh=SkeletalMesh'blastergun.Mesh.SK_blastergun'
		bAcceptsDynamicDecals=false
		CastShadow=true
		TickGroup=TG_DuringASyncWork
		LightEnvironment=GPLightEnvironment
	End Object
	DroppedPickupMesh=SK_linkgun
	PickupFactoryMesh=SK_linkgun
}
