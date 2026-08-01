
extends Node2D

var Resolution 
var textNumber = 0 # Which line we are at.
var IntroText =[ { "Text" : "Once upon a time in a small village in the middle of nowhere..." , "TimeOnScreen" : 3} , 
				 { "Text" : "A young boy named Desil was practising his magic skills under a tree." , "TimeOnScreen" : 3},
				 { "Text" : "But the rain started to fall." , "TimeOnScreen" : 2},
				 { "Text" : "So he decides to go and see his teacher in the chapel." , "TimeOnScreen" : 3}
			   ]
var FadeIn = true #If false it's fade out we have to do.
var GoToNextScene = false

func _ready():
	set_process(true)
	set_process_input(true)
	Resolution = get_node("/root/GameCore").Video_Resolution
	get_node("/root/GameCore").AdjustFonts()
	SetIntroLayout()
	
	#Set Dialog database
	get_node("/root/GameCore").LoadDialogDatabase()
	
	#Set Skip.
	get_node("Tooltip").set_pos(Vector2(0,0))
	
	if ( Resolution.x == 800 ):
		var bg = load("res:///Textures/Intro/IntroBackground_800x600.png")
		get_node("BackgroundLayers/Background").set_texture(bg)
		get_node("Text").set_pos(Vector2(0,530))
		
		
	elif ( Resolution.x == 1366 ):
		var bg = load("res:///Textures/Intro/IntroBackground_1366x768.png")
		get_node("BackgroundLayers/Background").set_texture(bg)
		get_node("Text").set_pos(Vector2(0,650))
		
		
	elif ( Resolution.x == 1920 ):
		var bg = load("res:///Textures/Intro/IntroBackground_1920x1080.png")
		get_node("BackgroundLayers/Background").set_texture(bg)
		get_node("Text").set_pos(Vector2(0,950))
		
		
	PlayTextFade()
		
func _process(delta):
	
	#Always adjust the size of the textbox.
	get_node("Text").set_pos( Vector2(Resolution.x/2 - get_node("Text").get_size().x/2, get_node("Text").get_pos().y ) )
	
	if(Input.is_key_pressed(KEY_SPACE)):
		GoToNextScene = true
		PlayTextFade()


func SetIntroLayout():
	self.get_node("Text").set_size(Vector2(0,Resolution.y*0.15))
	
func PlayTextFade():
	
	if GoToNextScene :
		get_node("TextSwitchTimer").stop()
		get_node("Text/AnimationPlayer").stop_all()
		get_node("Text").set_opacity(1) # we set it to 1 
		get_node("Text").set_text("Loading...")
		get_node("SupportTimer").start()
		return
	
	if FadeIn:
		var textArrraySize = self.IntroText.size()
		if textNumber <= textArrraySize-1 :
			get_node("Text").set_text(IntroText[textNumber]["Text"])
			#We wait for the fade ( 3 sec) + additional secs given in array to remain on screen.
			get_node("TextSwitchTimer").set_wait_time(3 + IntroText[textNumber]["TimeOnScreen"] )
			get_node("TextSwitchTimer").start()
			get_node("Text/AnimationPlayer").play("TextFadeIn")
			FadeIn =false
			textNumber = textNumber +1
		else:
			#This means we are at the end of the intro texts.
			GoToNextScene = true
			PlayTextFade() #Launch the change one more time.
	else:
		get_node("Text/AnimationPlayer").play("TextFadeOut")
		get_node("TextSwitchTimer").set_wait_time(3)
		get_node("TextSwitchTimer").start()
		FadeIn =true

func _on_SupportTimer_timeout():
	#Here a little "cheating" because you can load in two ways.
	#First by savegame then the playerpos is in that.
	#Secondy by world events that we use StartSceneTransition(toScene,playerpos)
	#The second is a little different.
	#We dont set it in the main menu we set it in the specialized intro scene.
	#We cant use StartSceneTransition 'cos that would throw us into the loadigscen and that is 
	#not needed now.
	get_node("/root/GameCore").LoadedFromPlayerSave = false #We don't want this to cause to load the positions from the save file
	get_node("/root/GameCore").playerPosition = Vector2(1587,2776)
	get_node("/root/GameCore").SetScene("res://Scenes/Cesferan.tscn")
