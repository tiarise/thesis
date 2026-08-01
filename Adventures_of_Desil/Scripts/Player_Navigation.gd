
extends Navigation2D

var begin=Vector2()
var end=Vector2()
var path=[]

const SPEED=120

var clickPosition = Vector2(0,0)

var drawPath = true

var closestPos = Vector2(0,0) #If path cant be drawn to the desired position.

var player
var animationPlayer
var Resolution 

var font = null

var camera

func _ready():
	set_process_input(true)
	set_process(false)
	player = get_node("/root/SceneRoot/PlayerAndUI/Player")
	animationPlayer = get_node("/root/SceneRoot/PlayerAndUI/Player/KinematicBody2D/AnimatedSprite/AnimationPlayer")
	animationPlayer.set_speed(1.5)
	Resolution = get_node("/root/GameCore").Video_Resolution
	font = load("res://Fonts/Comfortaa-Bold.ttf")
	
	camera = get_node("/root/SceneRoot/PlayerAndUI/Camera")

func _draw():
	if(drawPath):
		if ( path.size() > 1 ):
			for i in range(path.size()):
				draw_string(font,Vector2(path[i].x,path[i].y -20),str(i+1)) 
				draw_circle(path[i],8,(Color(1,1,1)))
				
func _input(event):
	
	if( UIOpen() ):
		path=[] #reset path here
		set_process(false) 
		get_parent().get_node("UIAndCameraNavigation").halt_movement() #Halt the UI_Camera movement too.
		return
	
	if ( event.type == InputEvent.MOUSE_BUTTON ):
		if(event.button_index == 2 ):
			
			#Camera-Correction ( It calculates the pos from (0,0) we add the camera pos to that... )
			var correctionX 
			var correctionY
			
			if( camera.get_pos().x <  Resolution.x/2):
				correctionX = camera.get_pos().x			
			elif ( camera.get_pos().x <  get_node("/root/SceneRoot").SceneSize.x - Resolution.x/2):
				correctionX = Resolution.x/2				
			else:
				correctionX = camera.get_pos().x - ( get_node("/root/SceneRoot").SceneSize.x - Resolution.x )
				
			
			if( camera.get_pos().y <  Resolution.y/2):
				correctionY = camera.get_pos().y		
			elif ( camera.get_pos().y <  get_node("/root/SceneRoot").SceneSize.y - Resolution.y/2):
				correctionY = Resolution.y/2				
			else:
				correctionY = camera.get_pos().y - ( get_node("/root/SceneRoot").SceneSize.y - Resolution.y )
				
			event.x = event.x + camera.get_pos().x - correctionX
			event.y = event.y + camera.get_pos().y - correctionY
			
			#We need extra twist if player s in a trap
			if get_node("/root/GameCore").PlayerInTrap == true:
				event.x = 1842
				event.y = 2288
			
			
			#Camera-Correction ( It calculates the pos from (0,0) we add the camera pos to that... )
			
			
			path = get_simple_path(player.get_pos(),Vector2(event.x,event.y))
			update()
			

			
			begin=player.get_pos()
			#mouse to local navigation cords
			end=event.pos - get_pos()
			_update_path()
			
			
			get_parent().get_node("UIAndCameraNavigation")._update_path(end)
			
			
func _process(delta):
	
	if( UIOpen() ):
		path=[] #reset path here
		set_process(false) #obviously, this only runs if there was an input event..
		get_parent().get_node("UIAndCameraNavigation").halt_movement()
		return
		
	
	if (path.size()>1):
		GameCore.PlayerMoving = true 
		var to_walk = delta*SPEED
		while(to_walk>0 and path.size()>=2):
			var point_from = path[path.size()-1]
			var point_to = path[path.size()-2]
			var distance = point_from.distance_to(point_to)
			
			if (distance<=to_walk):
				path.remove(path.size()-1)
				to_walk-=distance
				
				#Stop the animation with the appropriate stop.
				if( animationPlayer.get_current_animation() == "WalkUp"):
					animationPlayer.stop()
					animationPlayer.play("StopUp")
				elif( animationPlayer.get_current_animation() == "WalkDown"):
					animationPlayer.stop()
					animationPlayer.play("StopDown")
				elif( animationPlayer.get_current_animation() == "WalkRight"):
					animationPlayer.stop()
					animationPlayer.play("StopRight")
				elif( animationPlayer.get_current_animation() == "WalkLeft"):
					animationPlayer.stop()
					animationPlayer.play("StopLeft")
				
			else:
				path[path.size()-1] = point_from.linear_interpolate(point_to,to_walk/distance)
				to_walk=0
				
					
				var vec = (point_to - point_from).normalized() #normalization -> 0-1 between values :)
					
				#if abs(x)>abs(y )and x>0
				#if 5* abs(x)>abs(y )and x>0  nagyobb sullyal veszi figyelembe az iranyt
				if( 2*abs(vec.x) > abs(vec.y) and vec.x > 0  ):
					if(  !animationPlayer.is_playing() or  (animationPlayer.get_current_animation() != "WalkRight") ):
						animationPlayer.stop()
						animationPlayer.play("WalkRight")
				elif( 2*abs(vec.x) >= abs(vec.y) and vec.x <= 0 ):
					if(  !animationPlayer.is_playing() or  (animationPlayer.get_current_animation() != "WalkLeft") ):
						animationPlayer.stop()
						animationPlayer.play("WalkLeft")
				elif( 2*abs(vec.x) <= abs(vec.y)  and vec.y < 0 ):
					if(  !animationPlayer.is_playing() or  (animationPlayer.get_current_animation() != "WalkUp") ):
						animationPlayer.stop()
						animationPlayer.play("WalkUp")
				elif( 2*abs(vec.x) <= abs(vec.y)   and vec.y >= 0 ): #vec y = 0 if click on player itself.
					if(  !animationPlayer.is_playing() or  (animationPlayer.get_current_animation() != "WalkDown") ):
						animationPlayer.stop()
						animationPlayer.play("WalkDown")
							
		var atpos = path[path.size()-1]	
		player.set_pos(atpos)
		
		if (path.size()<2):
			path=[]
			set_process(false)
			GameCore.PlayerMoving = false 
			
	else:
		set_process(false)
		GameCore.PlayerMoving = false 

func _update_path():

	var p = get_simple_path(begin,end,true)
	path=Array(p) 
	path.invert()
	
	set_process(true)
	

func UIOpen():
	var PlayerAndUI = get_node("/root/SceneRoot/PlayerAndUI")
	
	if( PlayerAndUI == null):
		return
	
	if ( PlayerAndUI.get_node("UI/GameMenu/GameMenu").is_visible() ):
		return true
	if ( PlayerAndUI.get_node("UI/Inventory/Inventory").is_visible() ):
		return true
	if ( PlayerAndUI.get_node("UI/Journal/Journal").is_visible() ):
		return true
	if ( PlayerAndUI.get_node("UI/CharacterSheet/CharacterSheet").is_visible() ):
		return true		
	if ( PlayerAndUI.get_node("UI/Map/Map").is_visible() ):
		return true		
	if ( PlayerAndUI.get_node("UI/Tutorial/TutorialWindow").is_visible() ):
		return true		
	if ( PlayerAndUI.get_node("UI/GameComplete/GameComplete").is_visible() ):
		return true		
	return false
	
func halt_movement():
	path = []
	set_process(false)