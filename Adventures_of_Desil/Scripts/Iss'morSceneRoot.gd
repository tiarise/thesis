extends Node2D


var SceneSize = Vector2(3000,3000)

func _ready():
	#set current scene
	get_node("/root/GameCore").CurrentSceneName = "Iss'mor"
	
	#Load The protagonist.
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
	ActivateIssmorSettings()

	#Start music and sounds, must be after activate settings because it checks enviormental effect state
	get_node("Sounds").StartSounds() #This considers eviormental effect states
	
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
	#If this is a simple scene change ( read the preset player positon )
	else:
		var player_start_pos = get_node("/root/GameCore").playerPosition
		get_node("PlayerAndUI/Player").set_pos(player_start_pos)
	
	#Must be after player position. Set the ui and the camera.
	get_node("PlayerAndUI").PositionUI()
	get_node("PlayerAndUI").SetCameraLimits( SceneSize ) #Must be before setcamera
	get_node("PlayerAndUI").PositionCamera()
	
	#Reset load values.
	GameCore.LoadedFromPlayerSave = false
	GameCore.LoadedFromCombat = false
	
	
	
	
func LoadNPCsAndCritters():
	
	#Initializing trap system of the hag.
	get_node("WorldEvents/AreaTrigger/Trap1").StartTrap(1.3)
	get_node("WorldEvents/AreaTrigger/Trap2").StartTrap(1.1)
	get_node("WorldEvents/AreaTrigger/Trap3").StartTrap(0.8)
	get_node("WorldEvents/AreaTrigger/Trap4").StartTrap(1.4)
	get_node("WorldEvents/AreaTrigger/Trap5").StartTrap(0.4)
	
	#NPC15--------------------------------------------------------------
	var SpriteFrameData = preload("res://Textures/Characters/NPCs/Nolt.png")
	get_node("NPCs/NPC15").AddSprite(SpriteFrameData)
	get_node("NPCs/NPC15").set_pos(Vector2(666,2359))
	get_node("NPCs/NPC15").CommID = "Nolt" #this will search for a Velrath.cfg in dialogs.
	get_node("NPCs/NPC15").CharacterName = "Nolt"
	get_node("NPCs/NPC15").RemoveAnimatior()
	
	#Set the detection area2D
	var b = CircleShape2D.new()
	b.set_radius(60)

	get_node("NPCs/NPC15/Proximity_Area2D").add_shape(b)
	#/NPC15--------------------------------------------------------------
	
	#NPC16--------------------------------------------------------------
	var SpriteFrameData = preload("res://Textures/Characters/NPCs/Cylie.png")
	get_node("NPCs/NPC16").AddSprite(SpriteFrameData)
	get_node("NPCs/NPC16").set_pos(Vector2(1490,2683))
	get_node("NPCs/NPC16").CommID = "Cylie" #this will search for a Velrath.cfg in dialogs.
	get_node("NPCs/NPC16").CharacterName = "Cylie"
	get_node("NPCs/NPC16").RemoveAnimatior()
	
	#Set the detection area2D
	var b = CircleShape2D.new()
	b.set_radius(60)

	get_node("NPCs/NPC16/Proximity_Area2D").add_shape(b)
	#/NPC16--------------------------------------------------------------
	
	#NPC17--------------------------------------------------------------
	var SpriteFrameData = preload("res://Textures/Characters/NPCs/Doltran.png")
	get_node("NPCs/NPC17").AddSprite(SpriteFrameData)
	get_node("NPCs/NPC17").set_pos(Vector2(2229,2677))
	get_node("NPCs/NPC17").CommID = "Doltran" #this will search for a Velrath.cfg in dialogs.
	get_node("NPCs/NPC17").CharacterName = "Doltran"
	get_node("NPCs/NPC17").RemoveAnimatior()
	
	#Set the detection area2D
	var b = CircleShape2D.new()
	b.set_radius(60)

	get_node("NPCs/NPC17/Proximity_Area2D").add_shape(b)
	#/NPC17--------------------------------------------------------------

	#NPC18--------------------------------------------------------------
	var SpriteFrameData = preload("res://Textures/Characters/NPCs/ForestBodyGuard1.png")
	get_node("NPCs/NPC18").AddSprite(SpriteFrameData)
	get_node("NPCs/NPC18").set_pos(Vector2(2353,2681))
	get_node("NPCs/NPC18").CommID = "NPC-NON-COM" #this will search for a Velrath.cfg in dialogs.
	get_node("NPCs/NPC18").CharacterName = ""
	get_node("NPCs/NPC18").RemoveAnimatior()
	
	#Set the detection area2D
	var b = CircleShape2D.new()
	b.set_radius(60)

	get_node("NPCs/NPC18/Proximity_Area2D").add_shape(b)
	#/NPC18--------------------------------------------------------------

	#NPC19--------------------------------------------------------------
	var SpriteFrameData = preload("res://Textures/Characters/NPCs/ForestBodyGuard2.png")
	get_node("NPCs/NPC19").AddSprite(SpriteFrameData)
	get_node("NPCs/NPC19").set_pos(Vector2(2117,2808))
	get_node("NPCs/NPC19").CommID = "NPC-NON-COM" #this will search for a Velrath.cfg in dialogs.
	get_node("NPCs/NPC19").CharacterName = ""
	get_node("NPCs/NPC19").RemoveAnimatior()
	
	#Set the detection area2D
	var b = CircleShape2D.new()
	b.set_radius(60)

	get_node("NPCs/NPC19/Proximity_Area2D").add_shape(b)
	#/NPC19--------------------------------------------------------------
	
	#NPC20--------------------------------------------------------------
	var SpriteFrameData = preload("res://Textures/Characters/NPCs/Gywenne.png")
	get_node("NPCs/NPC20").AddSprite(SpriteFrameData)
	get_node("NPCs/NPC20").set_pos(Vector2(589,716))
	get_node("NPCs/NPC20").CommID = "Gywenne" #this will search for a Velrath.cfg in dialogs.
	get_node("NPCs/NPC20").CharacterName = "Gywenne"
	get_node("NPCs/NPC20").RemoveAnimatior()
	
	#Set the detection area2D
	var b = CircleShape2D.new()
	b.set_radius(60)

	get_node("NPCs/NPC20/Proximity_Area2D").add_shape(b)
	#/NPC20--------------------------------------------------------------

	#NPC21--------------------------------------------------------------
	var SpriteFrameData = preload("res://Textures/Characters/NPCs/ForestBodyGuard3.png")
	get_node("NPCs/NPC21").AddSprite(SpriteFrameData)
	get_node("NPCs/NPC21").set_pos(Vector2(2098,191))
	get_node("NPCs/NPC21").CommID = "Lox" #this will search for a Velrath.cfg in dialogs.
	get_node("NPCs/NPC21").CharacterName = "Lox"
	get_node("NPCs/NPC21").RemoveAnimatior()
	
	#Set the detection area2D
	var b = CircleShape2D.new()
	b.set_radius(60)

	get_node("NPCs/NPC21/Proximity_Area2D").add_shape(b)
	#/NPC21--------------------------------------------------------------

func ActivateIssmorSettings():
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
		
	#THis has to be after the effects set. because you have to set hte level before you turn it on..
	get_node("PlayerAndUI/UI/GameMenu")._on_EnviormentalEffects_toggled( get_node("/root/GameCore").Video_GameEffects )

#--------------- Scene specific timed sound functions ---------------------------------

#This states which thunder sample should be played.
var ThunderRumblingID = 0
var ThunderRumblingLibarySize = 3

#This states which bird sample should be played.
var BirdChirpID = 0
var BirdChirpIDLibarySize = 3

#This states which thunderclap sample should be played.
var ThunderID = 0
var ThunderLibarySize = 1


func _on_ThunderRumblig_Timer_timeout():
	get_node("Sounds/WorldSounds/TimedSounds/ThunderRumbling").play(str(ThunderRumblingID))
	ThunderRumblingID = ThunderRumblingID +1
	if ThunderRumblingID == ThunderRumblingLibarySize: 
		ThunderRumblingID = 0
	
	
	randomize()
	var randomNumber = randi() % (25) 
	randomNumber = randomNumber + 20 
	get_node("Sounds/WorldSounds/TimedSounds/ThunderRumbling/Timer").set_wait_time(randomNumber)
	get_node("Sounds/WorldSounds/TimedSounds/ThunderRumbling/Timer").start() #because it is oneshot we have to start it again.
	

	print("Next rumbling in : " + str(randomNumber) + " sec.")


func _on_Thunder_Timer_timeout():
	get_node("Sounds/WorldSounds/TimedSounds/Thunder").play(str(ThunderID))
	ThunderID = ThunderID +1
	if ThunderID == ThunderLibarySize: 
		ThunderID = 0
		
	#Show thunderlight
	for light in get_node("Lights/ThunderLights").get_children():
		light.set("visibility/visible",true)
	get_node("Lights/ThunderLights/Timer").start()
	
	
	randomize()
	var randomNumber = randi() % (25) 
	randomNumber = randomNumber + 45 
	get_node("Sounds/WorldSounds/TimedSounds/Thunder/Timer").set_wait_time(randomNumber)
	get_node("Sounds/WorldSounds/TimedSounds/Thunder/Timer").start() #because it is oneshot we have to start it again.

	print("Next thunder in : " + str(randomNumber) + " sec.")

#This turns off the thunderlights.
func _on_ThunderLight_Timer_timeout():
		for light in get_node("Lights/ThunderLights").get_children():
			light.set("visibility/visible",false)
