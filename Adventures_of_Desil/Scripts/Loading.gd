extends Node2D



func _ready():
	get_node("/root/GameCore").AdjustFonts()
	get_node("Label").set_text("Loading...")
	
	var Resolution = get_node("/root/GameCore").Video_Resolution
	if ( Resolution.x == 800 ):
		var bg = load("res:///Textures/Intro/IntroBackground_800x600.png")
		get_node("Sprite").set_texture(bg)

		
	elif ( Resolution.x == 1366 ):
		var bg = load("res:///Textures/Intro/IntroBackground_1366x768.png")
		get_node("Sprite").set_texture(bg)

		
	elif ( Resolution.x == 1920 ):
		var bg = load("res:///Textures/Intro/IntroBackground_1920x1080.png")
		get_node("Sprite").set_texture(bg)


	#If it is a simple scene change the skip this. ( Obviously )
	if GameCore.LoadedFromPlayerSave == true:
		#If this is a load from the quick save ( after battle )
		if  GameCore.LoadedFromCombat == true: # megy mert a scene root ready akkor fut le ha minden gyereke mar kesz
			#Here we don't need to load the database 'cos it was loaded already when game was loaded and correction to it
			#(Win secenario) was added in it in the battle solver, so no merge needed.
			pass
		else:
			#Load quest database
			GameCore.LoadQuestDatabase()
			
			#Set Dialog database
			get_node("/root/GameCore").LoadDialogDatabase()
			get_node("/root/GameCore").ReadDialogCompletions(get_node("/root/GameCore").saveFileRoute) #eleve battlebol ne mis lezs hasznalva a fg... a fenti miatt
			get_node("/root/GameCore").MergeDialogCompletionsWithDialogDatabase()

func _on_Timer_timeout():
	var NextScene = get_node("/root/GameCore").NextScene
	get_node("/root/GameCore").SetScene(NextScene)
