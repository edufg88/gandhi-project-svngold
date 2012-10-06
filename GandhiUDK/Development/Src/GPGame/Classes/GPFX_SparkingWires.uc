class GPFX_SparkingWires extends Actor
   ClassGroup(GP_Assets)
   AutoExpandCategories(GPFX_SparkingWires)
   placeable;

// Expose to Unrealscript and Unreal Editor
var() const EditInline Instanced array<PrimitiveComponent> PrimitiveComponents;

var (Wire) SkeletalMeshComponent wireSkeletalMesh;
//var (Wire) PhysicsAssetInstance wirePhysicsAssetInst;
//var (Wire) PhysicsAsset wirePhysicsAsset;
//var (SparksPS) ParticleSystemComponent sparksPS;
//var (SparksPS) const name sparksSocketName;
var bool collided;

simulated event PostBeginPlay()
{
	local int i;  
	// Check the primitive components array to see if we need to add any components into the components array.
	if (PrimitiveComponents.Length > 0)
	{
		for (i = 0; i < PrimitiveComponents.Length; ++i)
		{
		  if (PrimitiveComponents[i] != None)
		  {
			AttachComponent(PrimitiveComponents[i]);
		  }
		}
	 }

	Super.PostBeginPlay();

	collided = false;
	
	//if (sparksPS != None && self.wireSkeletalMesh != None)
	//{
	//	if (wireSkeletalMesh.GetSocketByName(sparksSocketName) != None)
	//	{
	//		wireSkeletalMesh.AttachComponentToSocket(sparksPS, sparksSocketName);
	//		`Log("[GPFX_SparkingWires] attaching sparksPS at socket "$sparksSocketName);

	//	}
	//	else `Log("[GPFX_SparkingWires] cannot find socket "$sparksSocketName);
	//}
	//else `Log("[GPFX_SparkingWires] PS or SKMesh no initialized ");
}

simulated function Tick(Float Delta)
{
	//Test move PS
	if (collided){
		//`Log("[GPFX_SparkingWires] Tick");
		collided = false;
	}
}

event RigidBodyCollision (PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent, const out CollisionImpactData RigidCollisionData, int ContactIndex)
{
	TakeDamage(1,None,RigidCollisionData.ContactInfos[ContactIndex].ContactPosition,vect(0,0,0),None);
}

simulated function TakeRadiusDamage (Controller InstigatedBy, float BaseDamage, float DamageRadius, class<DamageType> DamageType, float Momentum, Object.Vector HurtOrigin, bool bFullDamage, Actor DamageCauser, optional float DamageFalloffExponent)
{
	TakeDamage(BaseDamage,InstigatedBy,HurtOrigin,vect(0,0,0),DamageType);
}

event TakeDamage (int DamageAmount, Controller EventInstigator, Object.Vector HitLocation, Object.Vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	collided = true;
}

defaultproperties
{
	//sparksSocketName = ParticleSystem'ceilingWire.ParticleSystems.PS_WireElectricalSparks'

	//Begin Object Class=ParticleSystemComponent Name=GPSparksPS  //Template=ParticleSystem'3DMapStand.ParticleSystems.PS_WireElectricalSparks'
	//	sparksPS = ParticleSystem'ceilingWire.ParticleSystems.PS_WireElectricalSparks'
 //   End Object
	//sparksPS = GPSparksPS
	//Components.Add(GPSparksPS)

	//Physics asset del Wire
	//Begin Object Class=PhysicsAssetInstance Name=GPWirePAInst
	//	wirePhysicsAssetInst = ParticleSystem'ceilingWire.ParticleSystems.PS_WireElectricalSparks'
	//End Object
	//wirePhysicsAssetInst = GPWirePAInst
	//Components.Add(GPWirePAInst)
	//Begin Object Class=PhysicsAsset Name=GPWirePA
	//	wirePhysicsAsset = ParticleSystem'ceilingWire.ParticleSystems.PS_WireElectricalSparks'
	//End Object
	//wirePhysicsAsset = GPWirePA
	//Components.Add(GPWirePA)
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bSynthesizeSHLight=true
		bIsCharacterLightEnvironment=true
		bUseBooleanEnvironmentShadowing=false
		InvisibleUpdateTime=1.f
		MinTimeBetweenFullUpdates=0.2f
	End Object


	Begin Object class=SkeletalMeshComponent Name=wireSKMesh
		LightEnvironment=MyLightEnvironment

		bHasPhysicsAssetInstance = true
		bHasValidBodies=true

		bNotifyRigidBodyCollision=true
		ScriptRigidBodyCollisionThreshold=0.001
		AlwaysCheckCollision=TRUE
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,Pawn=TRUE,EffectPhysics=TRUE,FracturedMeshPart=FALSE)
		BlockRigidBody=true
		CollideActors=true
		BlockZeroExtent=true

		CastShadow=true
		bCastDynamicShadow=true
		
		bAcceptsDecals=false
		bAcceptsStaticDecals=false
		bAcceptsDynamicDecals=false
		
		SkeletalMesh=SkeletalMesh'ceilingWire.SkeletalMeshes.SK_CeilingWire'

		//set objectes 
		//wireSkeletalMesh = SkeletalMesh'ceilingWire.SkeletalMeshes.SK_CeilingWire'
		//PhysicsAsset=wirePhysicsAssetInst
	End Object
	wireSkeletalMesh=wireSKMesh
	Components.Add(wireSKMesh)
}
