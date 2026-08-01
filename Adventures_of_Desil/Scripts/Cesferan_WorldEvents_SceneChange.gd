extends Node2D

var loadGuard = false

func _on_Issmor_body_enter( body ):
	get_node("/root/SceneRoot").get_node("PlayerAndUI").CreateInteractionButton("To Iss'mor",self,"_on_Issmor_Enter_Button_pressed")


func _on_Issmor_body_exit( body ):
	if !loadGuard:
		if(  get_node("/root/SceneRoot/PlayerAndUI") != null  ):
			get_node("/root/SceneRoot/PlayerAndUI").ResetInteraction()

func _on_Issmor_Enter_Button_pressed(SourceButton):
	print("Iss'mor enter Button Pressed")
	loadGuard =true
	get_node("/root/GameCore").StartSceneTransition("res://Scenes/Iss'mor.tscn",Vector2(90,2456))

func _on_Chapel_body_enter( body ):
	get_node("/root/SceneRoot").get_node("PlayerAndUI").CreateInteractionButton("To Chapel",self,"_on_Chapel_Enter_Button_pressed")



func _on_Chapel_body_exit( body ):
	if !loadGuard:
		if(  get_node("/root/SceneRoot/PlayerAndUI") != null  ): 
			get_node("/root/SceneRoot/PlayerAndUI").ResetInteraction()
	
func _on_Chapel_Enter_Button_pressed(SourceButton):
	print("Chapel enter Button Pressed")
	loadGuard =true
	get_node("/root/GameCore").StartSceneTransition("res://Scenes/ChapelInside.tscn",Vector2(1259,818))

func _on_House1_body_enter( body ):
	get_node("/root/SceneRoot").get_node("PlayerAndUI").CreateInteractionButton("To Home",self,"_on_House1_Enter_Button_pressed")

func _on_House1_body_exit( body ):
	if !loadGuard:
		if(  get_node("/root/SceneRoot/PlayerAndUI") != null  ): 
			get_node("/root/SceneRoot/PlayerAndUI").ResetInteraction()

func _on_House1_Enter_Button_pressed(SourceButton):
	print("House2 enter Button Pressed")
	loadGuard =true
	get_node("/root/GameCore").StartSceneTransition("res://Scenes/HouseInside2.tscn",Vector2(987,605))

