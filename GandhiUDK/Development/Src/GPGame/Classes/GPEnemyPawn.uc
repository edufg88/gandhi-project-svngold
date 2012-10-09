class GPEnemyPawn extends Pawn
	placeable
	HideCategories(Camera, Debug, Physics, Advanced, Object);

var GPDroppedItemsGenerator DIG;
var class<actor> DropClass;
var GPSoundZone SoundZ;



simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	DIG = Spawn(class'GPDroppedItemsGenerator');
}

event ThrowObject()
{
	if(DropClass != none) DIG.DropItem(DropClass, self.location);
	//else DIG.DropRandomItem(self.Location);
}


function SetRagdoll()
{
	CylinderComponent.SetActorCollision(false, false, false);
	CollisionComponent = Mesh;

	Mesh.MinDistFactorForKinematicUpdate = 0.f;
	Mesh.SetRBChannel(RBCC_Pawn);
	Mesh.SetRBCollidesWithChannel(RBCC_Default, true);
	Mesh.SetRBCollidesWithChannel(RBCC_Pawn, false);
	Mesh.SetRBCollidesWithChannel(RBCC_Vehicle, false);
	Mesh.SetRBCollidesWithChannel(RBCC_Untitled3, false);
	//Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume, true);
	Mesh.ForceSkelUpdate();
	Mesh.SetTickGroup(TG_PostAsyncWork);
	
	Mesh.SetActorCollision(true, false);
	Mesh.SetTraceBlocking(true, true);
	SetPhysics(PHYS_RigidBody);
	Mesh.PhysicsWeight = 1.0;

	if (Mesh.bNotUpdatingKinematicDueToDistance)
	{
	  Mesh.UpdateRBBonesFromSpaceBases(true, true);
	}

	Mesh.PhysicsAssetInstance.SetAllBodiesFixed(false);
	Mesh.bUpdateKinematicBonesFromAnimation = false;
	Mesh.SetRBLinearVelocity(Velocity, false);
	Mesh.ScriptRigidBodyCollisionThreshold = MaxFallSpeed;
	Mesh.SetNotifyRigidBodyCollision(true);
	Mesh.WakeRigidBody();
}

function UnSetRagdoll()
{
	Mesh.SetNotifyRigidBodyCollision(false);
	Mesh.ScriptRigidBodyCollisionThreshold = 0;
	Mesh.bUpdateKinematicBonesFromAnimation = true;
	Mesh.PhysicsWeight = 0.0;
	SetMovementPhysics();
	Mesh.SetTraceBlocking(false, false);
	Mesh.SetActorCollision(true, true);
	CylinderComponent.SetActorCollision(true, true);
	Mesh.ForceSkelUpdate();
	Mesh.SetTickGroup(TG_PreAsyncWork);
	Mesh.SetRBChannel(RBCC_Untitled3);
	Mesh.SetRBCollidesWithChannel(RBCC_Untitled3, true);

	GPEnemyDroidController(Controller).bParalyzed = false;
}

State Dying
{
	event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
	{
		
	}
}

defaultproperties
{
	
}
