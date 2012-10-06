class GPDroppedLUpperArmArmor extends GPDroppedArmor;

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=ArmorPickUpComp
		StaticMesh=StaticMesh'Gandhi.Mesh.SM_armor_Larm_01'
		Scale3D=(X=0.5,Y=0.5,Z=0.5)
		Scale=0.5
		AlwaysLoadOnClient=TRUE
		AlwaysLoadOnServer=TRUE
		Translation=(X=0,Y=0,Z=0)
		CastShadow=FALSE
		bCastDynamicShadow=FALSE
		bAcceptsLights=TRUE
		bForceDirectLightMap=TRUE
		LightingChannels=(BSP=TRUE,Dynamic=FALSE,Static=TRUE,CompositeDynamic=TRUE)
		LightEnvironment=DroppedPickupLightEnvironment

		CollideActors=FALSE
		MaxDrawDistance=2000
	End Object
	PickupMesh=ArmorPickUpComp
	Components.Add(ArmorPickUpComp)

	PickupSound=SoundCue'A_Pickups.Shieldbelt.Cue.A_Pickups_Shieldbelt_Activate_Cue' //EFG: Cambiar el sonido
}