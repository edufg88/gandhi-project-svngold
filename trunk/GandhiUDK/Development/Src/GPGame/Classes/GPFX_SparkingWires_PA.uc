class GPFX_SparkingWires_PA extends Actor
   ClassGroup(Common)
   AutoExpandCategories(GPFX_SparkingWires_PA)
   placeable;

// Expose to Unrealscript and Unreal Editor
var() const EditInline Instanced array<PrimitiveComponent> PrimitiveComponents;

function PostBeginPlay()
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
}

defaultproperties
{
  Begin Object Class=SpriteComponent Name=Sprite
    Sprite=Texture2D'EditorResources.S_Actor'
   HiddenGame=True
   AlwaysLoadOnClient=False
   AlwaysLoadOnServer=False
  End Object
  Components.Add(Sprite)
}
 //class GPFX_SparkingWires_PA extends Actor
//	placeable;

//// Expose to Unrealscript and Unreal Editor
//var() SkeletalMeshComponent SkeletalMesh;

//defaultproperties
//{
//  // Declare sub object
//  Begin Object Class=SkeletalMeshComponent Name=MyStaticMeshComponent
//    StaticMesh=SkeletalMesh'EditorMeshes.SkeletalMesh.DefaultSkeletalMesh'
//  End Object
//  StaticMesh=MyStaticMeshComponent
//  Components.Add(MyStaticMeshComponent)
//}