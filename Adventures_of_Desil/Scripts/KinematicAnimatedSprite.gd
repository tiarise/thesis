
extends Node2D


#This is an abstract class.
#This can be used as a base for moving object, with kinematic uses.( Collision )
#Also this is usually used with a NavigationSurface(Navigation2D).

var CommID # Example : NPC1
var CharacterName

var PlayerAndUI 

func _ready():
	PlayerAndUI = get_node("/root/SceneRoot/PlayerAndUI")

#Add an the spriteframes(Usually this means one resource file :) )
func AddAnimatedSpriteFrames(var resource):
	get_node("KinematicBody2D/AnimatedSprite").set_sprite_frames(resource)
	get_node("KinematicBody2D/AnimatedSprite").set_frame(0)
	
#Add a simple sprite if the character is only stationary ( no animation neeeded )
func AddSprite(var resource):
	get_node("KinematicBody2D/Sprite").set_texture(resource)
	
#Add an animation to the Animation player for our character.(Usually you will add more than one.)
func AddAnimation(var animationName,var resource):
	get_node("KinematicBody2D/AnimatedSprite/AnimationPlayer").add_animation(animationName,resource)
	
#This should be called from the navpoligon.
func PlayAnimation():
	pass # The Player_navigation  is still usng the animation player directly

func _on_Proximity_Area2D_body_enter( body ):
	if(  PlayerAndUI != null  ):
		PlayerAndUI.CreateInteractionButton("Talk",get_node("/root/SceneRoot/WorldEvents/DialogManager"),"CreateDialog",[CommID] )
	


func _on_Proximity_Area2D_body_exit( body ):
	if(  PlayerAndUI != null  ):
		PlayerAndUI.ResetInteraction()

func RemoveAnimatior():
	get_node("KinematicBody2D/AnimatedSprite").queue_free()