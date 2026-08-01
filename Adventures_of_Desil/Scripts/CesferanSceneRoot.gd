
extends Node2D

var SceneSize = Vector2(3000,3000)

func _ready():
	#Set current scene
	get_node("/root/GameCore").CurrentSceneName = "Cesferan"
	
	#Load the protagonist
	var SpriteFramesData = preload("res://Textures/NPC1SpriteMap.tres")
	get_node("PlayerAndUI/Player").AddAnimatedSpriteFrames(SpriteFramesData)
	var b = CircleShape2D.new()
	b.set_radius(10)
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
	ActivateCesferanSettings()
	
	#Start music and sounds, must be after activate settings because it checks enviormental effect state
	get_node("Sounds").StartSounds() 
	
	#Load positions and saved assets
	if GameCore.LoadedFromPlayerSave == true:
		#Load from the quick save ( after battle )
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
	
	#If new game show Tutorial.
	if GameCore.ShowTutorial == true:
		get_node("PlayerAndUI").ShowTutorial()
		GameCore.ShowTutorial = false
	
func ActivateCesferanSettings():
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
	
	#NPC1--------------------------------------------------------------
	var SpriteFrameData = preload("res://Textures/Characters/NPCs/Velrath.png")
	get_node("NPCs/NPC1").AddSprite(SpriteFrameData)
	get_node("NPCs/NPC1").set_pos(Vector2(1371,1324))
	get_node("NPCs/NPC1").CommID = "Velrath" 
	get_node("NPCs/NPC1").CharacterName = "Velrath, traveling merchant"
	get_node("NPCs/NPC1").RemoveAnimatior()
	
	#Set the detection area2D
	var b = CircleShape2D.new()
	b.set_radius(60)

	get_node("NPCs/NPC1/Proximity_Area2D").add_shape(b)
	#/NPC1--------------------------------------------------------------
	
	#NPC2--------------------------------------------------------------
	var SpriteFrameData = preload("res://Textures/Characters/NPCs/Kejiri.png")
	get_node("NPCs/NPC2").AddSprite(SpriteFrameData)
	get_node("NPCs/NPC2").set_pos(Vector2(1287,1466))
	get_node("NPCs/NPC2").CommID = "Kejiri"
	get_node("NPCs/NPC2").CharacterName = "Kejiri"
	get_node("NPCs/NPC2").RemoveAnimatior()
	
	#Set the detection area2D
	var b = CircleShape2D.new()
	b.set_radius(60)

	get_node("NPCs/NPC2/Proximity_Area2D").add_shape(b)
	#/NPC2--------------------------------------------------------------

	#NPC3--------------------------------------------------------------
	var SpriteFrameData = preload("res://Textures/Characters/NPCs/ForestBodyGuard3.png")
	get_node("NPCs/NPC3").AddSprite(SpriteFrameData)
	get_node("NPCs/NPC3").set_pos(Vector2(1205,1597))
	get_node("NPCs/NPC3").CommID = "NPC-NON-COM"
	get_node("NPCs/NPC3").CharacterName = ""
	get_node("NPCs/NPC3").RemoveAnimatior()
	
	#Set the detection area2D
	var b = CircleShape2D.new()
	b.set_radius(60)

	get_node("NPCs/NPC3/Proximity_Area2D").add_shape(b)
	#/NPC3--------------------------------------------------------------
	
	#NPC4--------------------------------------------------------------
	var SpriteFrameData = preload("res://Textures/Characters/NPCs/Ulgrel.png")
	get_node("NPCs/NPC4").AddSprite(SpriteFrameData)
	get_node("NPCs/NPC4").set_pos(Vector2(1745,1485))
	get_node("NPCs/NPC4").CommID = "Ulgrel"
	get_node("NPCs/NPC4").CharacterName = "Ulgrel"
	get_node("NPCs/NPC4").RemoveAnimatior()
	
	#Set the detection area2D
	var b = CircleShape2D.new()
	b.set_radius(60)

	get_node("NPCs/NPC4/Proximity_Area2D").add_shape(b)
	#/NPC4--------------------------------------------------------------
	
	
	#NPC5--------------------------------------------------------------
	var SpriteFrameData = preload("res://Textures/Characters/NPCs/Roqzen.png")
	get_node("NPCs/NPC5").AddSprite(SpriteFrameData)
	get_node("NPCs/NPC5").set_pos(Vector2(1537,1557))
	get_node("NPCs/NPC5").CommID = "Roqzen"
	get_node("NPCs/NPC5").CharacterName = "Roqzen"
	get_node("NPCs/NPC5").RemoveAnimatior()
	
	#Set the detection area2D
	var b = CircleShape2D.new()
	b.set_radius(60)

	get_node("NPCs/NPC5/Proximity_Area2D").add_shape(b)
	#/NPC5--------------------------------------------------------------

	#NPC6--------------------------------------------------------------
	var SpriteFrameData = preload("res://Textures/Characters/NPCs/ForestBodyGuard1.png")
	get_node("NPCs/NPC6").AddSprite(SpriteFrameData)
	get_node("NPCs/NPC6").set_pos(Vector2(1354,1636))
	get_node("NPCs/NPC6").CommID = "NPC-NON-COM"
	get_node("NPCs/NPC6").CharacterName = ""
	get_node("NPCs/NPC6").RemoveAnimatior()

	#Set the detection area2D
	var b = CircleShape2D.new()
	b.set_radius(60)

	get_node("NPCs/NPC6/Proximity_Area2D").add_shape(b)
	#/NPC6--------------------------------------------------------------
	
	#NPC7--------------------------------------------------------------
	var SpriteFrameData = preload("res://Textures/Characters/NPCs/Inly.png")
	get_node("NPCs/NPC7").AddSprite(SpriteFrameData)
	get_node("NPCs/NPC7").set_pos(Vector2(2643,2389))
	get_node("NPCs/NPC7").CommID = "Inly"
	get_node("NPCs/NPC7").CharacterName = "Inly"
	get_node("NPCs/NPC7").RemoveAnimatior()
	
	#Set the detection area2D
	var b = CircleShape2D.new()
	b.set_radius(60)

	get_node("NPCs/NPC7/Proximity_Area2D").add_shape(b)
	#/NPC7--------------------------------------------------------------
	
	#NPC8--------------------------------------------------------------
	var SpriteFrameData = preload("res://Textures/Characters/NPCs/Fex.png")
	get_node("NPCs/NPC8").AddSprite(SpriteFrameData)
	get_node("NPCs/NPC8").set_pos(Vector2(2618,2432))
	get_node("NPCs/NPC8").CommID = "Fex"
	get_node("NPCs/NPC8").CharacterName = "Fex the mad"
	get_node("NPCs/NPC8").RemoveAnimatior()
	
	#Set the detection area2D
	var b = CircleShape2D.new()
	b.set_radius(30)

	get_node("NPCs/NPC8/Proximity_Area2D").add_shape(b)
	#/NPC8--------------------------------------------------------------

	#NPC10--------------------------------------------------------------
	var SpriteFrameData = preload("res://Textures/Characters/NPCs/Eyner.png")
	get_node("NPCs/NPC10").AddSprite(SpriteFrameData)
	get_node("NPCs/NPC10").set_pos(Vector2(202,2362))
	get_node("NPCs/NPC10").CommID = "Eyner"
	get_node("NPCs/NPC10").CharacterName = "Guard Captain Eyner"
	get_node("NPCs/NPC10").RemoveAnimatior()
	
	#Set the detection area2D
	var b = CircleShape2D.new()
	b.set_radius(60)

	get_node("NPCs/NPC10/Proximity_Area2D").add_shape(b)
	#/NPC10--------------------------------------------------------------

	#NPC11--------------------------------------------------------------
	var SpriteFrameData = preload("res://Textures/Characters/NPCs/Toliam.png")
	get_node("NPCs/NPC11").AddSprite(SpriteFrameData)
	get_node("NPCs/NPC11").set_pos(Vector2(2104,602))
	get_node("NPCs/NPC11").CommID = "Toliam"
	get_node("NPCs/NPC11").CharacterName = "Toliam, tower guard"
	get_node("NPCs/NPC11").RemoveAnimatior()
	
	#Set the detection area2D
	var b = CircleShape2D.new()
	b.set_radius(60)

	get_node("NPCs/NPC11/Proximity_Area2D").add_shape(b)
	#/NPC11--------------------------------------------------------------
	
	#NPC22--------------------------------------------------------------
	if ( !get_node("WorldEvents/QuestManager").IsQuestComplete("II. Convince Bozz to return") ):
		var SpriteFrameData = preload("res://Textures/Characters/NPCs/Bozz.png")
		get_node("NPCs/NPC22").AddSprite(SpriteFrameData)
		get_node("NPCs/NPC22").set_pos(Vector2(116,279))
		get_node("NPCs/NPC22").CommID = "Bozz" 
		get_node("NPCs/NPC22").CharacterName = "Bozz"
		get_node("NPCs/NPC22").RemoveAnimatior()
	
	#Set the detection area2D
	var b = CircleShape2D.new()
	b.set_radius(60)

	get_node("NPCs/NPC22/Proximity_Area2D").add_shape(b)
	#/NPC22--------------------------------------------------------------
	
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
	
	#Create a random number
	randomize()
	var randomNumber = randi() % (25) 
	randomNumber = randomNumber + 20 
	get_node("Sounds/WorldSounds/TimedSounds/ThunderRumbling/Timer").set_wait_time(randomNumber)
	get_node("Sounds/WorldSounds/TimedSounds/ThunderRumbling/Timer").start() 
	

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
	get_node("Sounds/WorldSounds/TimedSounds/Thunder/Timer").start() 

	print("Next thunder in : " + str(randomNumber) + " sec.")

#This turns off the thunderlights.
func _on_ThunderLight_Timer_timeout():
		for light in get_node("Lights/ThunderLights").get_children():
			light.set("visibility/visible",false)
