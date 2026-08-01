
extends Node2D

var mainSize = Vector2( 300 , 250 )
var GameCore
var camera_correction = false

func _ready():
	GameCore = get_node("/root/GameCore")
	get_node("MainMenu/TabContainer/Main/Version").set_text(GameCore.Version)
	
	get_node("Camera2D").set("current",true)
	
	get_node("MainMenu/TabContainer/Settings/Video/Resolutions").add_item("800x600")
	get_node("MainMenu/TabContainer/Settings/Video/Resolutions").add_item("1366x768")
	get_node("MainMenu/TabContainer/Settings/Video/Resolutions").add_item("1920x1080")

	GameCore.AdjustFonts()
	
	#Settings Load ( only settings no player position, etc... )
	if( GameCore.CheckForConfigFile() ):
		GameCore.LoadSettingsFromConfigFile()
		ActivateSettingsInMainMenu()
	else:
		GameCore.GenerateDefaultConfigFile()
		GameCore.LoadSettingsFromConfigFile() #It needs to load settings to globals 'cos if you save in the same instance and not loaded it casuses errors
		ActivateSettingsInMainMenu()
	
	#StartMusic
	get_node("Sounds").StartSounds("MusicSounds")
	
func SetMainMenuLayout():
	#We set the base size for the class A window ( we need tmp or we override the original... )
	var tmp_mainSize = Vector2(mainSize.x + GameCore.Video_Resolution.x * 0.10 ,mainSize.y + GameCore.Video_Resolution.y * 0.10)
	#mainSize = Vector2(300 ,250)
	
	#We put the mother node to the middle.
	get_node("MainMenu/TabContainer").set_size(tmp_mainSize)

	GameCore.PutInTheMiddle( get_node("MainMenu") )

	GameCore.PutInTheMiddle( get_node("Camera2D") )
	
	GameCore.AdjustFonts()
	
	if GameCore.Video_Resolution.x == 800:
		var correction = Vector2(0,0)
		if camera_correction: 
			correction = Vector2(-85,12)
			
		get_node("Title").set_pos( Vector2( get_node("MainMenu").get_pos().x-10+correction.x,get_node("MainMenu").get_pos().y-get_node("Title").get_size().y-55+correction.y ) )
	elif GameCore.Video_Resolution.x == 1366:
		get_node("Title").set_pos( Vector2( get_node("MainMenu").get_pos().x-50,get_node("MainMenu").get_pos().y-get_node("Title").get_size().y-80 ) )

	elif GameCore.Video_Resolution.x == 1920:
		get_node("Title").set_pos( Vector2( get_node("MainMenu").get_pos().x-40,get_node("MainMenu").get_pos().y-get_node("Title").get_size().y-80 ) )


func ActivateSettingsInMainMenu():
	#Set resolution in main menu according to config file.
	if( GameCore.Video_Resolution == Vector2(800,600) ):
		get_node("MainMenu/TabContainer/Settings/Video/Resolutions").select(0)
		_on_Resolutions_item_selected(0)
	if( GameCore.Video_Resolution == Vector2(1366,768) ):
		get_node("MainMenu/TabContainer/Settings/Video/Resolutions").select(1)
		_on_Resolutions_item_selected(1)
	if( GameCore.Video_Resolution == Vector2(1920,1080) ):
		get_node("MainMenu/TabContainer/Settings/Video/Resolutions").select(2)
		_on_Resolutions_item_selected(2)
	
	#We set the fullscreen boolean to what is loaded from config file ( false/true )
	get_node("MainMenu/TabContainer/Settings/Video/FullScreen").set_pressed( GameCore.Video_FullScreen )
	_on_FullScreen_pressed() # this checks for the toggled mode  and applies the above.
	
	
	self.SetMasterVolume( get_node("/root/GameCore").Sound_MasterVolume )
	self.SetMusicVolume( get_node("/root/GameCore").Sound_MusicVolume )
	self.SetEnviormentalVolume( get_node("/root/GameCore").Sound_EnvironmentVolume )
	
func _on_FullScreen_pressed():
	var toggleMode= get_node("MainMenu/TabContainer/Settings/Video/FullScreen").is_pressed()
	if( toggleMode ):
		OS.set_window_fullscreen(true)
		
		#Correct the resolution ( The above only puts it in fullscreen in the native comp. resolution)
		var res = get_node("MainMenu/TabContainer/Settings/Video/Resolutions").get_selected()
		_on_Resolutions_item_selected( res )
		
		GameCore.Video_FullScreen = true
		
	else:
		OS.set_window_fullscreen(false)

		GameCore.Video_FullScreen = false
		


func _on_Resolutions_item_selected( ID ):
	if( ID == 0 ):
		print("Changing to 800x600")
		GameCore.Video_Resolution =  Vector2(800,600)
		get_tree().set_screen_stretch(true,true,GameCore.Video_Resolution)
		get_node("BackgroundLayers/Background").set_texture( load("res://Textures/Intro/IntroBackground_800x600.png") )
		SetCameraLimits(800,600)
		SetMainMenuLayout()
		
	if( ID == 1 ):
		print("Changing to 1366x768")
		GameCore.Video_Resolution =  Vector2(1366,768)
		get_tree().set_screen_stretch(true,true,GameCore.Video_Resolution)
		get_node("BackgroundLayers/Background").set_texture( load("res://Textures/Intro/IntroBackground_1366x768.png") )
		SetCameraLimits(1366,768)
		camera_correction = true #Needed for Godot camera bug. 
		SetMainMenuLayout()
		
	if( ID == 2 ):
		print("Changing to 1920x1080")
		GameCore.Video_Resolution =  Vector2(1920,1080)
		get_tree().set_screen_stretch(true,true,GameCore.Video_Resolution)
		get_node("BackgroundLayers/Background").set_texture( load("res://Textures/Intro/IntroBackground_1920x1080.png") )
		SetCameraLimits(1920,1080)
		camera_correction = true
		SetMainMenuLayout()

func _on_Exit_pressed():
	self.get_tree().quit()


func _on_Settings_pressed():
	self.get_node("MainMenu/TabContainer").set_current_tab(1)


func _on_Back_pressed():
	GameCore.SaveSettingsToConfigFile()
	self.get_node("MainMenu/TabContainer").set_current_tab(0)
	
#Unfortunatley here it is needed because of the camera adjustments.
#And we don't have the PlayerAndUI here, that has the camera limit functions
#And without this there would be camera view range problems.

func SetCameraLimits(x,y):
	get_node("Camera2D").set("limit/right",x)
	get_node("Camera2D").set("limit/bottom",y)


func _on_NewGame_pressed():
	
	#Indicate to CesferanSceneRoot to show tutorial.
	GameCore.ShowTutorial = true
	
	#Initialise player 
	GameCore.InitPlayer()
	GameCore.Player.SetFaction("Desil") #Needed for Next line.
	GameCore.Player.SetupDefaultStatistics()
	GameCore.Player.SetupStatisticsModifiers()
	GameCore.InitPlayerItems()
	#we use the intro scene here.	
	#First we need to load the default quest state
	get_node("/root/GameCore").LoadQuestDatabase(true)
	
	get_node("/root/GameCore").SetScene("res://Scenes/IntroScene.tscn")

func SetMasterVolume(value):
	self.get_node("MainMenu/TabContainer/Settings/Audio/MasterVolumeSlider").set_val(value)

func _on_MasterVolumeSlider_value_changed( value ):

	print("[*]Master Volume Slider Value changed to: " + str(value))
	
	#This sets the Master volume ( GameCore.Sounds_MasterVolume )
	self.get_node("Sounds").SetVolume(value)

func SetMusicVolume(value):
	self.get_node("MainMenu/TabContainer/Settings/Audio/MusicVolumeSlider").set_val(value)

func _on_MusicVolumeSlider_value_changed( value ):
	print("[*]Music Slider Value changed to: " + str(value))
	
	#This sets the Music volume ( GameCore.Sounds_MusicVolume )
	self.get_node("Sounds").SetVolume(value,"MusicSounds")
	
	
func _on_LoadGame_pressed():
	print("Load Game Pressed!")
	GameCore.LoadGame( get_node("/root/GameCore").saveFileRoute )

func SetEnviormentalVolume(value):
	self.get_node("MainMenu/TabContainer/Settings/Audio/EnvironmentVolumeSlider").set_val(value)

func _on_EnvironmentVolumeSlider_value_changed( value ):
	print("[*]Environment Slider Value changed to: " + str(value))
	
	#This sets the volumes ( GameCore.Sounds_MusicVolume )
	self.get_node("/root/SceneRoot/Sounds").SetVolume(value,"WorldSounds_ConstantSounds")
	self.get_node("/root/SceneRoot/Sounds").SetVolume(value,"WorldSounds_TimedSounds")


func _on_Credits_pressed():
	get_node("/root/GameCore").StartSceneTransition("res://Scenes/Credits.tscn")

