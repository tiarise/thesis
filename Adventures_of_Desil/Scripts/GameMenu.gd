
extends Node2D

var tooltips = [ "Never underestimate your opponent!","With Shift + Esc you can instantly quit.","Resolution can only be changed in main menu!","If you have a quest updated, talk to the NPCs.","Save often!","Intelligence is very important!"]

#This is a State A window.
var mainSize
var GameCore
var PlayerAndUI

func _ready():
	GameCore = get_node("/root/GameCore")
	PlayerAndUI = get_node("/root/SceneRoot/PlayerAndUI")
	set_process_input(true)
	SetGameMenuLayout()
	SetupChangelog()
	GameCore.AdjustFonts()


func SetGameMenuLayout():
	var Resolution = get_node("/root/GameCore").Video_Resolution
	
	if( Resolution.x == 800 ):
		mainSize = Vector2(455,365)
	elif( Resolution.x == 1366 ):
		mainSize = Vector2(555,465)
	elif( Resolution.x == 1920 ):
		mainSize = Vector2(655,565)
	
	get_node("GameMenu").set_size(Vector2(mainSize.x,mainSize.y))
	get_node("GameMenu/TabContainer").set_size(Vector2(mainSize.x,mainSize.y))

func ResetToolTip():
	 randomize()
	 var randomNumber = randi() % (tooltips.size())
	 self.get_node("GameMenu/TabContainer/Main/Tooltip").set_text("Tooltip : "+ tooltips[randomNumber])


func _input(Event):

	if(Input.is_key_pressed(KEY_ESCAPE)):
		
		if ( ! self.get_node("GameMenu").get("visibility/visible") ):
			self.get_node("GameMenu").set("visibility/visible",true)
			GameCore.PutInTheMiddle( self.get_node("GameMenu"),get_node("/root/SceneRoot/PlayerAndUI/UI") )
			ResetToolTip()
		
	if(Input.is_key_pressed(KEY_ESCAPE)):
		if(Input.is_key_pressed(KEY_SHIFT)): 
			self.get_tree().quit()


func _on_SaveGame_pressed():
	
	GameCore.Player.SaveStatisics()
	GameCore.Player.SaveItemsState()
	
	print("Save Game Pressed!")

	GameCore.GenerateSaveFile( GameCore.saveFileRoute)
	
func _on_LoadGame_pressed():
	print("Load Game Pressed!")
	GameCore.LoadGame( GameCore.saveFileRoute )
	



func _on_ExitToMain_pressed():
	GameCore.SetScene("res://Scenes/MainMenu.tscn")


func _on_ExitGame_pressed():
	self.get_tree().quit()

func SetMasterVolume(value):
	self.get_node("GameMenu/TabContainer/Sound/MasterVolumeSlider").set_val(value)

func _on_MasterVolumeSlider_value_changed( value ):

	print("[*]Master Volume Slider Value changed to: " + str(value))
	
	#This sets the Master volume ( GameCore.Sounds_MasterVolume )
	self.get_node("/root/SceneRoot/Sounds").SetVolume(value)


#This triggers the slider change.
func SetMusicVolume(value):
	self.get_node("GameMenu/TabContainer/Sound/MusicVolumeSlider").set_val(value)

#THis is triggered by slider change.
func _on_MusicVolumeSlider_value_changed( value ):
	print("[*]Music Slider Value changed to: " + str(value))
	
	#This sets the Music volume ( GameCore.Sounds_MusicVolume )
	self.get_node("/root/SceneRoot/Sounds").SetVolume(value,"MusicSounds")
	
	
func _on_GameMenu_hide():
	GameCore.SaveSettingsToConfigFile()
	
	
func _on_EffectsSlider_value_changed( value ):
	
	self.get_node("GameMenu/TabContainer/Video/EffectsSlider").set_val(value)
	
	if ( value == 1 ):
		self.get_node("GameMenu/TabContainer/Video/Effects").set_text("Effects Detail: Low")
		
		#Global setting save
		GameCore.Video_GameEffectsLevel = "Low"
		
		
		if ( get_node("GameMenu/TabContainer/Video/EnviormentalEffects").is_pressed() ):
			get_tree().call_group(0,"Rain","set_emitting",true)
			get_tree().call_group(0,"RainBig","set_emitting",false)
			get_tree().call_group(0,"RainGiga","set_emitting",false)
		

		
	elif ( value == 2 ):
		self.get_node("GameMenu/TabContainer/Video/Effects").set_text("Effects Detail: Medium")
		
		#Global setting save
		GameCore.Video_GameEffectsLevel = "Medium"
		
		
		if ( get_node("GameMenu/TabContainer/Video/EnviormentalEffects").is_pressed() ):
			get_tree().call_group(0,"Rain","set_emitting",true)
			get_tree().call_group(0,"RainGiga","set_emitting",false)
			
	elif ( value == 3 ):
		self.get_node("GameMenu/TabContainer/Video/Effects").set_text("Effects Detail: High")
		
		#Global setting save
		GameCore.Video_GameEffectsLevel = "High"
		
		
		if ( get_node("GameMenu/TabContainer/Video/EnviormentalEffects").is_pressed() ):
			get_tree().call_group(0,"Rain","set_emitting",true)	


func _on_EnviormentalEffects_toggled( pressed ):
	if( pressed ):
		var value = self.get_node("GameMenu/TabContainer/Video/EffectsSlider").get_val()
		
		
		get_node("/root/SceneRoot/Sounds").StartEnviormentalEffectSounds()
		
		#Set it on the ui(this is needed if this is loaded from config file )
		self.get_node("GameMenu/TabContainer/Video/EnviormentalEffects").set("is_pressed",true)
		
		#Global setting save
		GameCore.Video_GameEffects = true
		
		
		_on_EffectsSlider_value_changed( value ) 
	else:
		get_tree().call_group(0,"Rain","set_emitting",false)
		get_node("/root/SceneRoot/Sounds").StopEnviormentalEffectSounds()
		
		#Set it on the ui(this is needed if this is loaded from config file )
		self.get_node("GameMenu/TabContainer/Video/EnviormentalEffects").set("is_pressed",false)
		
		#Global setting save
		GameCore.Video_GameEffects = false


func _on_ShowFPS_toggled( pressed ):
	if( pressed ):
		PlayerAndUI.get_node("UI/InstanceInfo/FPS").set("visibility/visible",true)
		
		#Set it on the ui(this is needed if this is loaded from config file )
		self.get_node("GameMenu/TabContainer/Video/ShowFPS").set("is_pressed",true)
		
		#Global setting save
		GameCore.Video_Show_FPS = true
		
	else:
		PlayerAndUI.get_node("UI/InstanceInfo/FPS").set("visibility/visible",false)
		
		#Set it on the ui(this is needed if this is loaded from config file )
		self.get_node("GameMenu/TabContainer/Video/ShowFPS").set("is_pressed",false)
		
		#Global setting save
		GameCore.Video_Show_FPS = false

func SetupChangelog():
	var line 
	var file = File.new()
	file.open("res://Configuration/Changelog.txt", file.READ)
	if file.is_open():
		
			get_node("GameMenu/TabContainer/Changelog").clear()
			var root = get_node("GameMenu/TabContainer/Changelog").create_item()
			get_node("GameMenu/TabContainer/Changelog").set_hide_root(true)
			
			var Parent_Date
			var Child_Log
			
			line = file.get_line()
			while not file.eof_reached():
				if line.substr(0,3) == "***":
						Parent_Date = get_node("GameMenu/TabContainer/Changelog").create_item(root)
						Parent_Date.set_text(0,line.substr(3,line.length()))
						Parent_Date.set_selectable(0,false)
				else: #This is a log to the given date
						Child_Log = get_node("GameMenu/TabContainer/Changelog").create_item(Parent_Date)
						Child_Log.set_text(0,line)
						Child_Log.set_selectable(0,false)
				line = file.get_line()
			file.close()

func SetEnviormentalVolume(value):
	#This sets the slider.
	self.get_node("GameMenu/TabContainer/Sound/EnvironmentVolumeSlider").set_val(value)

#This triggers on slider change.
func _on_EnvironmentVolumeSlider_value_changed( value ):
	print("[*]Environment Slider Value changed to: " + str(value))
	
	#This sets the volumes ( GameCore.Sounds_MusicVolume )
	self.get_node("/root/SceneRoot/Sounds").SetVolume(value,"WorldSounds_ConstantSounds")
	self.get_node("/root/SceneRoot/Sounds").SetVolume(value,"WorldSounds_TimedSounds")
