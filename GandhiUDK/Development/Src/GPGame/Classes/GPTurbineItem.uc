class GPTurbineItem extends GPArmorItem;

var ParticleSystemComponent BubblesPSL;
var ParticleSystemComponent BubblesPSR;

simulated function AdjustPawn(GPPlayerPawn P, bool bRemoveBonus)
{
	
	if (P != None)
	{	
		// La equipamos
		//AttachToPawn(P, P.TurbineSocketName);
		P.Mesh.AttachComponentToSocket(P.TurbineMesh, P.TurbineSocketName);
		// Le damos el poder al pawn
		P.ToggleTurbine();
		P.turbine = self;
		
		// Creamos los efectos de particulas
		//if (P.IsUnderWater)
		//{
			if (P.TurbineMesh != None)
			{		

					//BubblesPS = Worldinfo.MyEmitterPool.SpawnEmitterCustomLifetime(ParticleSystem'PS_AirBubbles.ParticleSystems.PS_WaterBubbles_Pressure', false);
					//BubblesPS.SetAbsolute(false,false,false);
					//BubblesPS.bUpdateComponentInTick = true;
					//BubblesPS.SetTickGroup(TG_EffectsUpdateWork);
					//BubblesPS.SetScale3D(Vect(0.2, 0.2,0.2));
					// Attach the weapon mesh to the instigator's skeletal mesh
					//P.TurbineMesh.AttachComponentToSocket(BubblesPSL, 'BubblesLeftSocket');
					//P.TurbineMesh.AttachComponentToSocket(BubblesPSR, 'BubblesRightSocket');

			}
		//}
	}
}

function GivenTo(Pawn NewOwner, optional bool bDoNotActivate)
{
	Super.GivenTo(NewOwner, bDoNotActivate);
	AdjustPawn(GPPlayerPawn(NewOwner), false);
}

function showBubbles()
{
	GPPlayerPawn(InvManager.Owner).TurbineMesh.AttachComponentToSocket(BubblesPSL, 'BubblesLeftSocket');
	GPPlayerPawn(InvManager.Owner).TurbineMesh.AttachComponentToSocket(BubblesPSR, 'BubblesRightSocket');
}

function hideBubbles()
{
	GPPlayerPawn(InvManager.Owner).TurbineMesh.DetachComponent(BubblesPSL);
	GPPlayerPawn(InvManager.Owner).TurbineMesh.DetachComponent(BubblesPSR);
}

function Unequip()
{
	Super.Unequip();

	// Le quitamos el poder al pawn
	GPPlayerPawn(InvManager.Owner).ToggleTurbine();
}

function destroyTurbine()
{
	local GPPlayerPawn P;
	P = GPPlayerPawn(InvManager.Owner);
	Unequip();
	P.Mesh.DetachComponent(P.TurbineMesh);
	P.TurbineMesh.DetachFromAny();
	//P.TurbineMesh.SetScale(0.f);
	P.TurbineMesh.SetHidden(true);
	P.InvManager.RemoveFromInventory(self);
	P.turbine = none;
	Destroy();
}

function string GetName()
{
	return "Turbine";
}

defaultproperties
{
	Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent1
		SkeletalMesh=SkeletalMesh'Turbina.Mesh.SK_Turbina'
		bOnlyOwnerSee=false
		CastShadow=false
		bForceDirectLightMap=true
		bCastDynamicShadow=false
		CollideActors=false
		BlockRigidBody=false
		Scale3D=(X=0.5,Y=0.5,Z=0.5)
		Scale=0.5
	End Object
	DroppedPickupMesh=SkeletalMeshComponent1
	PickupFactoryMesh=SkeletalMeshComponent1

	Begin Object Class=ParticleSystemComponent Name=BubblesPSAct
		Template=ParticleSystem'PS_AirBubbles.ParticleSystems.PS_WaterBubbles_Turbine'
	End Object
	Begin Object Class=ParticleSystemComponent Name=BubblesPSActr
		Template=ParticleSystem'PS_AirBubbles.ParticleSystems.PS_WaterBubbles_Turbine'
	End Object
	BubblesPSL=BubblesPSAct
	BubblesPSR=BubblesPSActr

	// EFG: Cambiar los efectos de sonido
	RespawnTime=100.0
	bReceiveOwnerEvents=true

	PickupSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_JumpBoots_PickupCue'
	ActivateSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_JumpBoots_JumpCue'

	ArmorPoints=200;
	MaxArmorPoints=200;

	//BubblesPS = ParticleSystem'PS_AirBubbles.ParticleSystems.PS_WaterBubbles_Pressure';
}
