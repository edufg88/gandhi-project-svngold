class GPPlayerController extends PlayerController;

// Required for camera switching
var name PreviousState;
var Pawn UnpossessedPawn;

var GPFX_SphereShieldGandhi Shield;
var SpotLightComponent LightAttachment;
var SpotLightComponent LightAttachment2;
var LightFunction lff;

var GPSceneCapture2D sca;

// 0: Gandhi / 1: Siri / -1: None
var int bWhoAmI;
var GPSiriController AISiri;
var GPPlayerPawn GandhiPawn;
var bool bCanControlSiri;
var bool bCanUseShield;
var bool bIsMiniSiri;
var class<Camera> MatineeCameraClass;
var Actor OldViewTarget;
var Camera OldCamera;

var PostProcessChain PPC;

var GPWeapon PreviousWeapon;
///////////Coberturas/////////////
`define Trace(obj) `obj.Run( self );

struct SCoverWall
{
	// goal position we are covering on
	var vector	Goal;

	// surface normal of the covergoal
	var vector	Normal;
	var vector	EdgeNormal;
};

var SCoverWall Wall;
var bool IsCovering;
var int saveLoc;
var float MinProximity;
var float EdgeDist;
var float EdgeDepth;
var float EdgeConst;
var int LastStrafe;
var Vector LastCoverLocation;

var bool CoverCornering;

// Efectos de postprocesado para las gafas acuaticas
var PostProcessSettings ppsOn;
var PostProcessSettings ppsOff;
var bool GlassesOn;

simulated event PostBeginPlay ()
{
	local GPPostProcessVolumeGlasses PPVolume;
	local PostProcessSettings pps;
	
	Super.PostBeginPlay();
	SetAudioGroupVolume('Voice', 1.5);
	
	pps.bEnableBloom = true;
	pps.bEnableDOF = false;
	pps.bEnableMotionBlur = true;
	pps.bEnableSceneEffect = true;
	
	pps.DOF_FocusInnerRadius = 2000;
	pps.Scene_HighLights.X = 1;
	pps.Scene_HighLights.Y = 0.7;
	pps.Scene_HighLights.Z = 1;
	pps.Scene_MidTones.X = 1;
	pps.Scene_MidTones.Y = 0.8;
	pps.Scene_MidTones.Z = 1;
	pps.Scene_Shadows.X = 0;
	pps.Scene_Shadows.Y = 0;
	pps.Scene_Shadows.Z = 0.8;

	ppsOn = pps;
	
	ForEach AllActors(class'GPPostProcessVolumeGlasses', PPVolume)
	{
		ppsOff = PPVolume.Settings;
	}

	//class'GPHUD'.static.setHUDWeapon('none');
}

exec function GPHangar(int i)
{
	ClientPrepareMapChange(name("HangarMap"), false, true);
	ClientCommitMapChange();
}

exec function ToggleCoverState()
{
	//ToggleCover = !ToggleCover;
	if(IsCovering) {
		IsCovering = false;
		//GetALocalPlayerController().ClientMessage("IsCovering="$IsCovering);
		GPPlayerPawn(Pawn).GotoState('');
		GotoState('PlayerWalking');
	}
	else {
		TryCoverWall();
		//GetALocalPlayerController().ClientMessage("IsCovering="$IsCovering);
		if(IsCovering) {
			//GetALocalPlayerController().ClientMessage("Wall="$Wall.Goal);
			GPPlayerPawn(Pawn).IsAiming = false;
			GPPlayerPawn(Pawn).GotoState('Covering');
			GotoState('Covering');
		}
	}
	
	
}

function TryCoverWall() 
{
	local GPCoverTrace WallTrace;
	local vector x, y, z;
	local Vector camLoc;
	local Rotator camRot;

	WallTrace =  new class'GPGame.GPCoverTrace';
	GetPlayerViewPoint(camLoc, camRot);
	//GetAxes(Pawn.Rotation, x, y, z);
	GetAxes(camRot, x, y, z);
	x.Z = 0;
	WallTrace.Start = Pawn.Mesh.GetBoneLocation( name("GANDHI:Pelvis") );
	WallTrace.End = WallTrace.Start;
	WallTrace.End += x * MinProximity;

	//DrawDebugLine(WallTrace.Start, WallTrace.End, 255,0,0, true);

	`Trace( WallTrace );

	if ( WallTrace.Hit() )
	{
		IsCovering = true;
		
		Wall.Goal = WallTrace.Location;
		Wall.Normal = WallTrace.Normal;
		Wall.EdgeNormal = Wall.Normal;
		Wall.EdgeNormal.X = -Wall.EdgeNormal.X;
		Wall.EdgeNormal.Y = -Wall.EdgeNormal.Y;
		
		//crouch
		WallTrace.Start = Pawn.Mesh.GetBoneLocation( name("GANDHI:Head") );
		WallTrace.End = WallTrace.Start;
		WallTrace.End += x * MinProximity;

		//DrawDebugLine(WallTrace.Start, WallTrace.End, 0,0,255, true);
		`Trace( WallTrace );

		GPPlayerPawn(Pawn).IsCrouched = !WallTrace.Hit();
		
		return;
	}
}

function bool TryCoverEdge(bool leftEdge) 
{
	local GPCoverTrace WallTrace;
	local vector x, y, z;
	local rotator HalfCircle, CoverBiNormal;

	// we calculate a rotator parallel to the surface
	HalfCircle = rot( 0, 16384, 0 );
	CoverBiNormal = Normalize( rotator(Wall.Normal) - HalfCircle );

	GetAxes(CoverBiNormal,x,y,z);
	if(leftEdge) x = -x;

	WallTrace =  new class'GPGame.GPCoverTrace';
	
	WallTrace.Start = Pawn.Mesh.GetBoneLocation( name("GANDHI:Pelvis") );
	WallTrace.Start += x * EdgeDist;
	WallTrace.End = WallTrace.Start;
	WallTrace.End += -y * EdgeDepth;

	//DrawDebugLine(WallTrace.Start, WallTrace.End, 0,255,0, false);

	`Trace( WallTrace );

	if ( WallTrace.Hit() ) return false;

	return true;
}

state Covering extends PlayerWalking
{
	function PlayerMove( float DeltaTime )
	{
		local vector			X,Y,Z, NewAccel;
		local eDoubleClickDir	DoubleClickMove;
		local rotator			OldRotation, HalfCircle, CoverBiNormal;

		if( Pawn == None )
		{
			GotoState('Dead');
			return;
		}

		if(PlayerInput.aForward < 0) ToggleCoverState();

		if(Pawn.IsInState('CoverEdging')) PlayerInput.aStrafe = 0;

		CoverCornering = false;
		if(PlayerInput.aStrafe != 0) {
			LastStrafe = (PlayerInput.aStrafe > 0) ? 1 : -1;
			if(saveLoc < 4) LastCoverLocation = Pawn.Location;
			if(TryCoverEdge(PlayerInput.aStrafe < 0)) {
				CoverCornering = true;
				PlayerInput.aStrafe = 0;
				saveLoc++;
			}
			else saveLoc = 0;
		}
		//else LastStrafe = 0;

		GroundPitch = 0;

		// we calculate a rotator parallel to the surface
		HalfCircle = rot( 0, 16383, 0 );
		CoverBiNormal = Normalize( rotator(Wall.Normal) - HalfCircle );

		GetAxes(CoverBiNormal,X,Y,Z);

		// and update acceleration based on this parallel vector
		NewAccel = PlayerInput.aStrafe*X;

		NewAccel.Z	= 0;
		NewAccel = Pawn.AccelRate * Normal(NewAccel);

		// now we make sure we move a little bit towards the wall we are pressing on...
		// this is used for cylinders and such.
		//NewAccel += Max( 0.25, ( VSize( NewAccel ) / Pawn.AccelRate ) ) * ( Pawn.AccelRate * ( VSize( Cover.Wall.Goal - Pawn.Mesh.GetBoneLocation( name("GANDHI:Pelvis") ) ) / CoverConfig.IdealDistance ) * -Y );
		DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );

		// Update rotation.
		/*if(!CoverCornering) */UpdateRotation( DeltaTime );
		bDoubleJump = false;

		if( bPressedJump )
		{
			bPressedJump = false;
		}

		if( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
	}

	exec function ToggleAim()
	{
		local vector			X,Y,Z;
		local rotator			HalfCircle, CoverBiNormal;
		local rotator CoverNormal;

		HalfCircle = rot( 0, 16384, 0 );
		CoverBiNormal = Normalize( rotator(Wall.Normal) - HalfCircle );

		GetAxes(CoverBiNormal,X,Y,Z);

		if(GPPlayerPawn(Pawn).IsInState('CoverEdging')) {
			GPPlayerPawn(Pawn).IsAiming = false;
			Wall.Goal = LastCoverLocation;
			CoverNormal = Normalize( rotator(Wall.EdgeNormal) );
			CoverNormal.Yaw += LastStrafe;
			Pawn.SetRotation(CoverNormal);
			Pawn.GotoState('Covering');
		}
		else if(GPPlayerPawn(Pawn).IsCrouched) {
			Wall.Goal = LastCoverLocation;
			Pawn.GotoState('CoverEdging');
		}
		else if(LastStrafe != 0 && TryCoverEdge(LastStrafe < 0)) {
			Wall.Goal = LastCoverLocation + LastStrafe*EdgeConst*X;
			CoverNormal = Normalize( rotator(Wall.Normal) );
			CoverNormal.Yaw -= LastStrafe;
			Pawn.SetRotation(CoverNormal);
			Pawn.GotoState('CoverEdging');
		}
		
		//GPPlayerPawn(Pawn).Weapon.Class;
	}

	exec function AimKeyUp() 
	{
		ToggleAim();
	}
}
///////////FinCoberturas/////////////

function SpawnCamera()
{
	// Associate Camera with PlayerController
	if(OldCamera == none) OldCamera = PlayerCamera;
	PlayerCamera = Spawn(MatineeCameraClass, self);

	if (PlayerCamera != None)
	{
		OldViewTarget = ViewTarget;
		PlayerCamera.InitializeFor(self);
		PlayerCamera.SetViewTarget(OldViewTarget);
	}
	else
	{
		`Log("Couldn't Spawn Camera Actor for Player!!");
	}
}

simulated event GetPlayerViewPoint( out vector POVLocation, out Rotator POVRotation )
{
	// support for using CameraActor views
	if ( CameraActor(ViewTarget) != None )
	{
		if(ViewTarget != OldViewTarget) {
			super.ResetCameraMode();
			SpawnCamera();
		}
		//super.GetPlayerViewPoint( POVLocation, POVRotation );
	}
	else {
		if(OldCamera != None) {
			//super.ResetCameraMode();
			PlayerCamera = OldCamera;
			OldCamera = None;
			OldViewTarget = none;
			Possess(Pawn, true);
		}
	}
	super.GetPlayerViewPoint( POVLocation, POVRotation );
}

state BeingGandhi
{
	event BeginState(Name PreviousStateName)
	{
		local GPSiriPawn Siri;

		if (bWhoAmI != -1)
		{
			Siri = GPGame(WorldInfo.Game).Siri.Siri;

			bWhoAmI = 0;

			if (AISiri != none && GandhiPawn != none)
			{
				Siri.ChangeController(AISiri);
				UnPossess();
				Possess(GandhiPawn, true);
				AISiri.GotoState('Idle');
			}
		}
	}
	event EndState(Name NextStateName)
	{}

	event Possess(Pawn inPawn, bool bVehicleTransition)
	{
		Super.Possess(inPawn, bVehicleTransition);

		//sca = new(self) class'GPSceneCapture2D';
	
		//inPawn.AttachComponent(sca);
		//inPawn.Mesh.AttachComponent(sca, name("GANDHI:Pelvis"), vect(0,0,0), Rotator(vect(0,0,-3.5)));
	}

	event UnPossess()
	{
		
	}
}

state BeingSiri
{
	event BeginState(Name PreviousStateName)
	{
		local GPSiriPawn Siri;
		Siri = GPGame(WorldInfo.Game).Siri.Siri;
	
		// Es la primera vez que hacemos el cambio... guardamos lo que nos interesa
		if (bWhoAmI == -1)
		{
			//GandhiPawn = GPPlayerPawn(self.Pawn);
			AISiri = GPGame(WorldInfo.Game).Siri;
		}
		AISiri.GotoState('PlayerControlled');

		// Somos Siri
		bWhoAmI = 1;
		// Le decimos a Siri empiece estar controlado por nosotros
		Siri.ChangeController(self);
		// Guardamos el Pawn de Gandhi actual
		GandhiPawn = GPPlayerPawn(self.Pawn);
		// Le cambiamos el pawn
		UnPossess();
		Possess(GPGame(WorldInfo.Game).Siri.Siri, true);
	}

	event EndState(Name NextStateName)
	{
		
	}

	event Possess(Pawn inPawn, bool bVehicleTransition)
	{
		Super.Possess(inPawn, bVehicleTransition);
	}

	
}

////Update player rotation when walking
//state PlayerWalking
//{
//ignores SeePlayer, HearNoise, Bump;

//   function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
//   {
//	  local Vector tempAccel;
//		local Rotator CameraRotationYawOnly;

//      if( Pawn == None )
//      {
//         return;
//      }

//      if (Role == ROLE_Authority)
//      {
//         // Update ViewPitch for remote clients
//         Pawn.SetRemoteViewPitch( Rotation.Pitch );
//      }

//      tempAccel.Y =  PlayerInput.aStrafe * DeltaTime * 100 * PlayerInput.MoveForwardSpeed;
//      tempAccel.X = PlayerInput.aForward * DeltaTime * 100 * PlayerInput.MoveForwardSpeed;
//      tempAccel.Z = 0; //no vertical movement for now, may be needed by ladders later
	  
//	 //get the controller yaw to transform our movement-accelerations by
//	CameraRotationYawOnly.Yaw = Rotation.Yaw; 
//	tempAccel = tempAccel>>CameraRotationYawOnly; //transform the input by the camera World orientation so that it's in World frame
//	Pawn.Acceleration = tempAccel;
   
//	Pawn.FaceRotation(Rotation,DeltaTime); //notify pawn of rotation

//    CheckJumpOrDuck();
//   }
//}

////Controller rotates with turning input
//function UpdateRotation( float DeltaTime )
//{
//local Rotator   DeltaRot, newRotation, ViewRotation;

//   ViewRotation = Rotation;
//   if (Pawn!=none)
//   {
//      Pawn.SetDesiredRotation(ViewRotation);
//   }

//   // Calculate Delta to be applied on ViewRotation
//   DeltaRot.Yaw   = PlayerInput.aTurn;
//   DeltaRot.Pitch   = PlayerInput.aLookUp;

//   ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
//   SetRotation(ViewRotation);

//   NewRotation = ViewRotation;
//   NewRotation.Roll = Rotation.Roll;

//   if ( Pawn != None )
//      Pawn.FaceRotation(NewRotation, deltatime); //notify pawn of rotation
//} 

state PlayerWalking
{
	function PlayerMove( float DeltaTime )
	{
		if (Pawn.IsA('GPPlayerPawn'))
		{
			if(GPPlayerPawn(Pawn).isAiming) super.PlayerMove(DeltaTime);
			else NewPlayerMove(DeltaTime);
		}
		else if (Pawn.IsA('GPSiriPawn'))
		{
			if(GPSiriPawn(Pawn).isAiming) super.PlayerMove(DeltaTime);
			else NewPlayerMove(DeltaTime);
		}
	}

	function NewPlayerMove( float DeltaTime )
	{
		local vector X,Y,Z, NewAccel;
		local eDoubleClickDir DoubleClickMove;
		local rotator OldRotation;
		local bool bSaveJump;

		if( Pawn == None )
		{
			GotoState('Dead');
		}
		else
		{
			GetAxes(Rotation,X,Y,Z);

			// Update acceleration.
		   // X.X=1;
			//Y.Y=1;
			
			NewAccel = PlayerInput.aForward*X + PlayerInput.aStrafe*Y;
			NewAccel = Pawn.AccelRate * Normal(NewAccel);
			//Pawn.Acceleration = NewAccel;
			
			DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );

			// Update rotation.
		   OldRotation = Rotation;
		   UpdateRotation( DeltaTime );
			bDoubleJump = false;

			if( bPressedJump && Pawn.CannotJumpNow() )
			{
				bSaveJump = true;
				bPressedJump = false;
			}
			else
			{
				bSaveJump = false;
			}

			if( Role < ROLE_Authority ) // then save this move and replicate it
			{
				ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
			}
			else
			{
				ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
			}
			
		 
			bPressedJump = bSaveJump;
		}
	}
}

function UpdateRotation( float DeltaTime )
{
	if (Pawn.IsA('GPPlayerPawn'))
	{
		if(GPPlayerPawn(Pawn).isAiming) super.UpdateRotation(DeltaTime);
		else NewUpdateRotation(DeltaTime);
	}
	else if (Pawn.IsA('GPSiriPawn'))
	{
		if(GPSiriPawn(Pawn).isAiming) super.UpdateRotation(DeltaTime);
		else NewUpdateRotation(DeltaTime);
	}
}

function NewUpdateRotation( float DeltaTime )
{
		local Rotator DeltaRot, newRotation, ViewRotation, PawnRot, out_Rot;
		local vector out_Loc;
		local int newYaw;
		
		if(Pawn == None) return;

		ViewRotation = Rotation;
		PawnRot = Rotation;
		//CPRot = Pawn(owner).Rotation;
		
		GetPlayerViewPoint(out_Loc, out_Rot);
		
		
		if (Pawn!=none)
		{
		  Pawn.SetDesiredRotation(PawnRot);
		}

		newYaw = 0;
		// Calculate Delta to be applied on ViewRotation
		if (PlayerInput.aStrafe < 0) newYaw -= 16384;
		else if (PlayerInput.aStrafe > 0) newYaw += 16384;
		if (PlayerInput.aForward > 0) newYaw /= 2;
		else if (PlayerInput.aForward < 0) newYaw = -newYaw/2 - 32768;
		//if (PlayerInput.aForward>0)
		
		//`Log(""$(out_Rot.Yaw - Pawn.Rotation.Yaw)$" "$(out_Rot.Yaw + Pawn.Rotation.Yaw)$" "$(-out_Rot.Yaw - Pawn.Rotation.Yaw)$" "$(-out_Rot.Yaw + Pawn.Rotation.Yaw));
		//if(IsInState('Covering') && out_Rot.Yaw + Pawn.Rotation.Yaw < 0) {
		//	`Log("malameeeeeent");
		//	newYaw = 0;
		//}
		//else `Log("bEEEE");
		PawnRot.Yaw += newYaw;
		
		DeltaRot.Yaw = PlayerInput.aTurn;
		DeltaRot.Pitch = PlayerInput.aLookUp;

		ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
		SetRotation(ViewRotation);

		ViewShake( deltaTime );

		NewRotation = PawnRot;
		
		//NewRotation.Roll = PawnRot.Roll;

		//if ( Pawn != None );
		//Pawn.FaceRotation(NewRotation, deltatime);
	if ( Pawn != None && (PlayerInput.RawJoyRight != 0.0 || PlayerInput.RawJoyUp != 0.0)) {
		//if(IsInState('Covering') && PlayerInput.aStrafe != 0 && out_Rot.Yaw + Pawn.Rotation.Yaw < 0) {
		//	//res
		//}
		/*else */Pawn.FaceRotation(NewRotation, deltatime);
	}
		
		
}

/**
 * List important PlayerController variables on canvas.  HUD will call DisplayDebug() on the current ViewTarget when the ShowDebug exec is used.
 *
 * @param		HUD				HUD with canvas to draw on
 * @param		out_YL			Height of the current font
 * @param		out_YPos		Y position on Canvas. out_YPos += out_YL, gives position to draw text for next debug line.
 */
simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
	local GPPlayerReplicationInfo GPPlayerReplicationInfo;

	Super.DisplayDebug(HUD, out_YL, out_YPos);

	// Get the GPPlayerReplicationInfo
	GPPlayerReplicationInfo = GPPlayerReplicationInfo(PlayerReplicationInfo);
	if (GPPlayerReplicationInfo == None)
	{
		return;
	}

	// Draw the class information
	HUD.Canvas.SetDrawColor(255, 0, 255);
	HUD.Canvas.DrawText("Class "$GPPlayerReplicationInfo.ClassArchetype);
	out_YPos += out_YL;
	HUD.Canvas.SetPos(4, out_YPos);
}

//////////////////////////////////////////////////
//
//              Exec functions
//////////////////////////////////////////////////

exec function ToggleDebugMode()
{
	`log("-- Toggling DEBUG MODE --");
	
	ConsoleCommand("Show BOUNDS");
	ConsoleCommand("Show CONSTRAINTS");
	ConsoleCommand("Show DECALINFO");
	//ConsoleCommand("Show HITPROXIES");
	ConsoleCommand("Show PATHS");
	ConsoleCommand("Show SPEEDTREES");
	ConsoleCommand("Show VOLUMES");
	ConsoleCommand("Stat FPS");
	ConsoleCommand("SHOWOCTREE");
	ConsoleCommand("SHOWLOG");
	ConsoleCommand("TOGGLELOGDETAILEDACTORUPDATESTATS");
	ConsoleCommand("TOGGLELOGDETAILEDCOMPONENTSTATS");
	ConsoleCommand("TOGGLELOGDETAILEDTICKSTATS");
	ConsoleCommand("RENDERTARGET_MEM_USAGE");
	ConsoleCommand("MESHSCALES");
	ConsoleCommand("KISMETLOG");
	ConsoleCommand("LOGACTORCOUNTS");
	ConsoleCommand("LOGOUSTATLEVELS");
}

exec function ToggleFlashLight()
{
	if(GPPlayerPawn(Pawn).IsInMenu) return;

	if(LightAttachment == none || LightAttachment.Owner != Pawn) {
		LightAttachment = new(self) class'SpotLightComponent';
		LightAttachment.SetLightProperties(5.0,,);

		LightAttachment.CastDynamicShadows = true;
		LightAttachment.SetEnabled( true );

		GPPlayerPawn( Pawn ).Mesh.AttachComponent(LightAttachment, name("GANDHI:Head"));
		LightAttachment.SetRotation(Rotator(vect(0,-1,0)));
	}
	else if(LightAttachment.bEnabled) {
		LightAttachment.SetEnabled(false);
	}
	else {
		LightAttachment.SetEnabled(true);
	}
	//}

	//ModifyPlayer( Other );
} 

exec function ToggleShield()
{
	if(GPPlayerPawn(Pawn).IsInMenu || bCanUseShield==false) return;

	if(Shield == none) {
		Shield = Spawn(class'GPFX_SphereShieldGandhi', Pawn);
		Shield.SetDrawScale(2.0);
		//Shield = new GPFX_SphereShield();
		//Pawn.Attach(Shield);
	}
	else {
		Shield.Destroy();
		Shield = none;
	}
}

exec function ToggleAim()
{
	//`Log("-- Toggle Aiming --");
	if(GPPlayerPawn(Pawn).IsInMenu) 
	{
		GPHUD(myHUD).rightClick();
	}
	else
	{ 
		if ((bWhoAmI == 0 || bWhoAmI == -1) && !(GPPlayerPawn(Pawn).IsUnderWater) && GPPlayerPawn(Pawn).IsCarryingWeapon && GPPlayerPawn(Pawn).Weapon != None)
		{
			GPPlayerPawn(Pawn).IsAiming = !GPPlayerPawn(Pawn).IsAiming;
		}
		else if (bWhoAmI == 1)
		{
			GPSiriPawn(Pawn).IsAiming = !GPSiriPawn(Pawn).IsAiming;
		}
	}
}

/////////////////////////////////////////////////////////////////////
//   SIRI        ////////////////////////////////////////////////////

// Siri no puede saltar ni agacharse
function CheckJumpOrDuck()
{
	if (bWhoAmI != 1)
	{
		if ( bPressedJump && (Pawn != None) )
		{
			//GPPlayerPawn(Pawn).FullBodyAnimSlot.PlayCustomAnim('test_Idle_jump', 1.0);//test_walkcycle_jump
			Pawn.DoJump( bUpdating );
		}
		// Play animation
		
		//Super.CheckJumpOrDuck();
	}
}
//function CheckJumpOrDuck()
//{
//	if ( bPressedJump && (Pawn != None) )
//	{
//		Pawn.DoJump( bUpdating );
//	}
//}

// Tampoco puede usar cosas
exec function Use()
{
	if (bWhoAmI != 1)
		Super.Use();
}

exec function MiniSiri()
{
	if (bWhoAmI == 1)
	{
		if (bIsMiniSiri)
		{
			Pawn.SetDrawScale(8.0);
			Pawn.CylinderComponent.SetCylinderSize(Pawn.CylinderComponent.CollisionRadius, 50);
		}
		else
		{
			Pawn.SetDrawScale(3.0);
			Pawn.CylinderComponent.SetCylinderSize(Pawn.CylinderComponent.CollisionRadius, 20);
		}

		bIsMiniSiri = !bIsMiniSiri;
	}
}

exec function ChangePawn()
{
	if(GPPlayerPawn(Pawn).IsInMenu || bCanControlSiri == false) 
		return;

	if (bWhoAmI != 1)
	{
		GotoState('BeingSiri');
	}
	else
	{
		GotoState('BeingGandhi');
	}
}

exec function CallSiri()
{
	if (bCanControlSiri)
		GPGame(WorldInfo.Game).Siri.GotoState('Seek',, true);
}

exec function StopSiri()
{
	if (bCanControlSiri)
		GPGame(WorldInfo.Game).Siri.GotoState('Stay',, true);
}

exec function SendSiri()
{
	local GPPlayerPawn Gandhi;
	local GPWeapon W;
	local Vector HitLocation, HitNormal, SocketLocation;
	local Rotator SocketRotation;
	local Actor HitActor;
	local SkeletalMeshComponent SMC;

	if (bCanControlSiri)
	{
		Gandhi = GPPlayerPawn(Pawn);
		W = GPWeapon(Gandhi.Weapon);
	
		// Check to see if the weapon can perform a world trace to find the true cross hair location
		SMC = SkeletalMeshComponent(W.Mesh);
		if (W != None && Gandhi.IsAiming)
		{
			if (SMC != None && W.FireModes.Length > 0 && W.FireModes[0] != None && SMC.GetSocketByName(W.FireModes[0].FireSocketName) != None)
			{
				// Trace out to find if the crosshair will target something
				SMC.GetSocketWorldLocationAndRotation(W.FireModes[0].FireSocketName, SocketLocation, SocketRotation);
				HitActor = Trace(HitLocation, HitNormal, SocketLocation + Vector(SocketRotation) * 16384.f, SocketLocation, true,,, TRACEFLAG_Bullet);  

				if (HitActor != None)
				{
					if (HitActor.isA('GPFX_SphereShieldGandhi')) 
					{
						HitActor = Trace(HitLocation, HitNormal, SocketLocation + Vector(SocketRotation) * 16384.f, HitLocation + Vector(SocketRotation) * 32.f, true,,, TRACEFLAG_Bullet);
					}
					if (HitActor != None)
					{
						if(HitActor.isA('GPEnemyPawn') || HitActor.IsA('GPFX_SphereShieldEnemy'))
						{
							GPGame(WorldInfo.Game).Siri.target = HitActor;
							GPGame(WorldInfo.Game).Siri.GotoState('Attack',, true);
						}			
					}
				}
			}
		}
	}
}

exec function menuSendSiri()
{
	if(GPHUD(myHUD).siriMenuShowing) {
		SendSiri();
		GPHUD(myHUD).HideSiriMenu();
	}
}

exec function menuStopSiri()
{
	if(GPHUD(myHUD).siriMenuShowing) {
		StopSiri();
		GPHUD(myHUD).HideSiriMenu();
	}
}

exec function menuCallSiri()
{
	if(GPHUD(myHUD).siriMenuShowing) {
		CallSiri();
		GPHUD(myHUD).HideSiriMenu();
	}
}

exec function menuChangePawn()
{
	if(GPHUD(myHUD).siriMenuShowing) {
		ChangePawn();
		GPHUD(myHUD).HideSiriMenu();
	}
}

//WARNING NO SE USA NUNCA
//exec function ChangePostProcess()
//{
//	//local PostProcessSettings pps;
//	local LocalPlayer lp;

//	lp.RemoveAllPostProcessingChains();
//	lp.InsertPostProcessingChain(PPC, INDEX_NONE, true);
//	lp.TouchPlayerPostProcessChain();
//	//Material'PostProcess.Materials.M_UnderWaterPostProcess'
//}


simulated exec function GPWalk()
{
	Pawn.GroundSpeed = Pawn.GroundSpeed / 2;
	Pawn.AirSpeed = Pawn.AirSpeed / 1.5;
	Pawn.WaterSpeed = Pawn.WaterSpeed / 2;
	Pawn.LadderSpeed = Pawn.LadderSpeed / 1.5;
	//Pawn.JumpZ = Pawn.JumpZ / 1.5;
}

simulated exec function GPRun()
{
	Pawn.GroundSpeed = Pawn.GroundSpeed * 2;
	Pawn.AirSpeed = Pawn.AirSpeed * 1.5;
	Pawn.WaterSpeed = Pawn.WaterSpeed * 2;
	Pawn.LadderSpeed = Pawn.LadderSpeed * 1.5;
	//Pawn.JumpZ = Pawn.JumpZ * 1.5;
}

simulated exec function ToggleWaterGlasses()
{
	local GPPostProcessVolumeGlasses PPVolume;
	//local PostProcessSettings pps;

	if (GPPlayerPawn(Pawn).IsUnderWater)
	{
		ForEach AllActors(class'GPPostProcessVolumeGlasses', PPVolume)
		{
			if (GlassesOn)
			{
				PPVolume.Settings = ppsOff;	
			}
			else
			{
				PPVolume.Settings = ppsOn;	
			}

			GlassesOn = !GlassesOn;
		}
	}
}

function EnfundarPistola()
{
	GPPlayerPawn(Pawn).Mesh.AttachComponentToSocket(GPPlayerPawn(Pawn).LinkGunMesh, GPPlayerPawn(Pawn).FundaPistolaSocketName);
}

function EnfundarRifle()
{
	GPPlayerPawn(Pawn).Mesh.AttachComponentToSocket(GPPlayerPawn(Pawn).ShockRifleMesh, GPPlayerPawn(Pawn).FundaRifleSocketName);
}

function DesenfundarPistola()
{
	GPPlayerPawn(Pawn).Mesh.DetachComponent(GPPlayerPawn(Pawn).LinkGunMesh);
}

function DesenfundarRifle()
{
	GPPlayerPawn(Pawn).Mesh.DetachComponent(GPPlayerPawn(Pawn).ShockRifleMesh);
}

simulated exec function ToggleHolster()
{
	local GPPlayerPawn GPPawn;
	GPPawn = GPPlayerPawn(Pawn);

	if (GPPawn.IsCarryingWeapon)
	{
		PreviousWeapon = GPWeapon(GPPawn.Weapon);
		if (PreviousWeapon.WeaponName == 'LinkGun')
		{
			// Enfundamos la pistola
			GPPawn.TopHalfAnimSlot.PlayCustomAnim('test_Idle_enfundar',2.0);
			SetTimer(0.5f, false, NameOf(EnfundarPistola));

			// La ponemos en el socket
			//GPPawn.Mesh.AttachComponentToSocket(GPPawn.LinkGunMesh, GPPawn.FundaPistolaSocketName);
		}
		else if (PreviousWeapon.WeaponName == 'ShockRifle')
		{
			// Enfundamos el rifle
			GPPawn.TopHalfAnimSlot.PlayCustomAnim('test_Idle_enfundar2',2.0);
			SetTimer(0.4f, false, NameOf(EnfundarRifle));
		}
			
		GPInventoryManager(GPPawn.InvManager).SetCurrentWeapon(None);
		GPPawn.IsCarryingWeapon = false;
		GPPawn.IsAiming = false;
	}
	else if (GPPawn.WeaponAmmount > 0)
	{
		if (PreviousWeapon != None)
		{
			if (PreviousWeapon.WeaponName == 'LinkGun')
			{
				// La quitamos del socket
				GPPawn.Mesh.DetachComponent(GPPawn.LinkGunMesh);
				// Desenfundamos
				GPPawn.TopHalfAnimSlot.PlayCustomAnim('test_Idle_desenfundar',2.0);			
			}
			else if (PreviousWeapon.WeaponName == 'ShockRifle')
			{
				// La quitamos del socket
				SetTimer(0.35f, false, NameOf(DesenfundarRifle));
				// Desefundamos el rifle
				GPPawn.TopHalfAnimSlot.PlayCustomAnim('test_Idle_desenfundar2',2.0);
				
			}

			GPInventoryManager(GPPawn.InvManager).SetCurrentWeapon(PreviousWeapon);
		}

		GPPawn.IsCarryingWeapon = true;
	}
	
}

exec function SwitchToBestWeapon(optional bool bForceNewWeapon)
{
	return;
}

exec function PrevWeapon()
{
	if ( WorldInfo.Pauser!=None )
		return;

	if ( Pawn.Weapon == None )
	{
		//SwitchToBestWeapon();
		ToggleHolster();
		return;
	}

	if ( Pawn.InvManager != None )
		Pawn.InvManager.PrevWeapon();
}

exec function NextWeapon()
{
	//if ( WorldInfo.Pauser!=None )
	//	return;

	if ( Pawn.Weapon == None )
	{
		//SwitchToBestWeapon();
		ToggleHolster();
		return;
	}

	if ( Pawn.InvManager != None )
		Pawn.InvManager.NextWeapon();
}

exec function CanHazShield()
{
	bCanUseShield=true;
}

DefaultProperties
{	
	CameraClass=class'GPPlayerCamera'
	bWhoAmI=-1;
	bCanControlSiri=false;
	bCanUseShield=false;
	bIsMiniSiri=false;
	MatineeCameraClass=class'Engine.Camera'

	IsCovering=False;
	CoverCornering=false;
	saveLoc=0;
	MinProximity=128.0;
	EdgeDist=40.0;
	EdgeDepth=16.0;
	EdgeConst=64;
	LastStrafe=0;

	PPC = PostProcessChain'PostProcess.PPChains.PPC_UnderwaterDistortion';

	GlassesOn = false;
}