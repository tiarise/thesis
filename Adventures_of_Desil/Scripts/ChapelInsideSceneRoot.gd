extends Node2D

var SceneSize = Vector2(1920,1080)

func _ready():

	#Set current scene
	get_node("/root/GameCore").CurrentSceneName = "ChapelInside"
	
	#Load the protagonist.
	var SpriteFramesData = preload("res://Textures/NPC1SpriteMap.tres")
	get_node("PlayerAndUI/Player").AddAnimatedSpriteFrames(SpriteFramesData)
	var b = RectangleShape2D.new()
	b.set_extents(Vector2(10,10))
	get_node("PlayerAndUI/Player/KinematicBody2D").add_shape( b )
	
	#Add animations
	get_node("PlayerAndUI/Player").AddAnimation("StopDown",preload("res://Animations/Characters/Protagonist/StopDown.tres"))
	get_node("PlayerAndUI/Player").AddAnimation("StopLeft",preload("res://Animations/Characters/Protagonist/StopLeft.tres"))
	get_node("PlayerAndUI/Player").AddAnimation("StopRight",preload("res://Animations/Characters/Protagonist/StopRight.tres"))
	get_node("PlayerAndUI/Player").AddAnimation("StopUp",preload("res://Animations/Characters/Protagonist/StopUp.tres"))
	get_node("PlayerAndUI/Player").AddAnimation("WalkDown",preload("res://Animations/Characters/Protagonist/WalkDown.tres"))
	get_node("PlayerAndUI/Player").AddAnimation("WalkLeft",preload("res://Animations/Characters/Protagonist/WalkLeft.tres"))
	get_node("PlayerAndUI/Player").AddAnimation("WalkRight",preload("res://Animations/Characters/Protagonist/WalkRight.tres"))
	get_node("PlayerAndUI/Player").AddAnimation("WalkUp",preload("res://Animations/Characters/Protagonist/WalkUp.tres"))
	
	#Load NPC-s
	LoadNPCsAndCritters()
	
	#Load Settings to scene.
	ActivateChapelInsideSettings()

	#Start music and sounds, must be after activate settings because it checks enviormental effect state
	get_node("Sounds").StartSounds() 
	
	#Load positions and saved assets
	if GameCore.LoadedFromPlayerSave == true:
		#If this is a load from the quick save ( after battle )
		if  GameCore.LoadedFromCombat == true:
			get_node("/root/GameCore").LoadPositionsDataToCurrentScene( get_node("/root/GameCore").beforeBattleQuickSaveRoute )
			get_node("/root/GameCore").LoadDialogDataToCurrentScene( get_node("/root/GameCore").beforeBattleQuickSaveRoute )
		#If this is a game load from the player
		else:
			get_node("/root/GameCore").LoadPositionsDataToCurrentScene( get_node("/root/GameCore").saveFileRoute )
			get_node("/root/GameCore").LoadDialogDataToCurrentScene( get_node("/root/GameCore").saveFileRoute )
	#This is a simple scene change 
	else:
		var player_start_pos = get_node("/root/GameCore").playerPosition
		get_node("PlayerAndUI/Player").set_pos(player_start_pos)
	
	#Must be after player position. Set the UI and the camera.
	get_node("PlayerAndUI").PositionUI()
	get_node("PlayerAndUI").SetCameraLimits( SceneSize ) 
	get_node("PlayerAndUI").PositionCamera()
	
	#Reset load values.
	GameCore.LoadedFromPlayerSave = false
	GameCore.LoadedFromCombat = false
	
	
func ActivateChapelInsideSettings():
	get_node("PlayerAndUI/UI/GameMenu").SetMasterVolume( get_node("/root/GameCore").Sound_MasterVolume )
	get_node("PlayerAndUI/UI/GameMenu").SetMusicVolume( get_node("/root/GameCore").Sound_MusicVolume )
	get_node("PlayerAndUI/UI/GameMenu").SetEnviormentalVolume( get_node("/root/GameCore").Sound_EnvironmentVolume )
	get_node("PlayerAndUI/UI/GameMenu")._on_ShowFPS_toggled( get_node("/root/GameCore").Video_Show_FPS )
	
	
	if( get_node("/root/GameCore").Video_GameEffectsLevel == "Low"):
		get_node("PlayerAndUI/UI/GameMenu")._on_EffectsSlider_value_changed( 1 )
	
	if( get_node("/root/GameCore").Video_GameEffectsLevel == "Medium"):
		get_node("PlayerAndUI/UI/GameMenu")._on_EffectsSlider_value_changed( 2 )
	
	if( get_node("/root/GameCore").Video_GameEffectsLevel == "High"):
		get_node("PlayerAndUI/UI/GameMenu")._on_EffectsSlider_value_changed( 3 )
		
	#This has to be after the effects set, because you have to set the level before you turn it on..
	get_node("PlayerAndUI/UI/GameMenu")._on_EnviormentalEffects_toggled( get_node("/root/GameCore").Video_GameEffects )

func LoadNPCsAndCritters():
	#NPC13--------------------------------------------------------------
	var SpriteFrameData = preload("res://Textures/Characters/NPCs/Belkor.png")
	get_node("NPCs/NPC13").AddSprite(SpriteFrameData)
	get_node("NPCs/NPC13").set_pos(Vector2(803,534))
	get_node("NPCs/NPC13").CommID = "Belkor"
	get_node("NPCs/NPC13").CharacterName = "Belkor"
	get_node("NPCs/NPC13").RemoveAnimatior()
	
	
	#Set the detection area2D
	var b = CircleShape2D.new()
	b.set_radius(60)

	get_node("NPCs/NPC13/Proximity_Area2D").add_shape(b)
	#/NPC13--------------------------------------------------------------