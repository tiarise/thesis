extends Node2D

var loadGuard = false

func _on_ToCesferan_body_enter( body ):
	get_node("/root/SceneRoot").get_node("PlayerAndUI").CreateInteractionButton("To Cesferan",self,"_on_Cesferan_Enter_Button_pressed")


func _on_ToCesferan_body_exit( body ):
	if !loadGuard:
		if(  get_node("/root/SceneRoot/PlayerAndUI") != null): 
			get_node("/root/SceneRoot/PlayerAndUI").ResetInteraction()

#This is hand made.
func _on_Cesferan_Enter_Button_pressed(SourceButton):
	print("Cesferan enter Button Pressed")
	loadGuard =true
	get_node("/root/GameCore").StartSceneTransition("res://Scenes/Cesferan.tscn",Vector2(2463,77))