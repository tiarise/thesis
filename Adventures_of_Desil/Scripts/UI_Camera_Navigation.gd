
extends Navigation2D


var begin_camera=Vector2()
var end_camera=Vector2()
var camera_path=[]

const SPEED=120
var font = null

var closestPos = Vector2(0,0)

var Resolution 


func _ready():
	set_process(false) 
	Resolution = get_node("/root/GameCore").Video_Resolution
	font = load("res://Fonts/Comfortaa-Bold.ttf")
	
func _process(delta):

	if (camera_path.size()>1):
		
		
		var to_walk = delta*SPEED
		while(to_walk>0 and camera_path.size()>=2):
			var pfrom = camera_path[camera_path.size()-1]
			var pto = camera_path[camera_path.size()-2]
			var d = pfrom.distance_to(pto)
			
			
	
			
			if (d<=to_walk):
				camera_path.remove(camera_path.size()-1)
				to_walk-=d
				
			else:
				camera_path[camera_path.size()-1] = pfrom.linear_interpolate(pto,to_walk/d)
				to_walk=0
				

		var atpos = camera_path[camera_path.size()-1]	
		
		get_node("/root/SceneRoot/PlayerAndUI/Camera").set_pos(atpos)
		
		var ui_adjusted_pos = Adjusted_UI_Limit_Move(atpos, get_node("/root/SceneRoot/PlayerAndUI/Camera") )
		get_node("/root/SceneRoot/PlayerAndUI/UI").set_pos(ui_adjusted_pos)
		
		if (camera_path.size()<2):
			camera_path=[]
			set_process(false)
				
	else:
		set_process(false)

#This adjust the UI movement 
func Adjusted_UI_Limit_Move(var to_pos,var camera):
	
	var SceneSize = get_node("/root/SceneRoot").SceneSize
	
	if( CameraIsAtLimit_Right(camera) ):
		
		if( to_pos.x > SceneSize.x-(Resolution.x/2)):
			to_pos.x = SceneSize.x-(Resolution.x/2) 

	if( CameraIsAtLimit_Left(camera) ):
		
		if( to_pos.x < (Resolution.x/2)):
			to_pos.x = (Resolution.x/2)

	if( CameraIsAtLimit_Top(camera) ):
		
		if( to_pos.y < (Resolution.y/2)):
			to_pos.y = (Resolution.y/2)

	if( CameraIsAtLimit_Bottom(camera) ):
		
		if( to_pos.y > SceneSize.y-(Resolution.y/2)):
			to_pos.y = SceneSize.y-(Resolution.y/2)
	
	return to_pos
	
	
func _update_path(var end_pos):
	
	begin_camera=get_node("/root/SceneRoot/PlayerAndUI/Camera").get_pos()
	
	
	end_camera= end_pos



	var p = get_simple_path(begin_camera,end_camera,true)
	camera_path=Array(p) 
	camera_path.invert()
	

	
	set_process(true)
	
	
func halt_movement():
	camera_path = []
	set_process(false)
	
	


func CameraIsAtLimit_Right(var camera):


	var correction = Vector2()
	var SceneSize = get_node("/root/GameCore").CurrentScene.get_node("/root/SceneRoot").SceneSize


	
	if( Resolution.x == 800 and Resolution.y == 600):
		correction.x = 400
		correction.y = 300

	if( Resolution.x == 1366 and Resolution.y == 768):
		correction.x = 683
		correction.y = 384

	if( Resolution.x == 1920 and Resolution.y == 1080):
		correction.x = 960
		correction.y = 540


	var camera_pos = camera.get_pos()


	if( camera_pos.x + correction.x >= SceneSize.x):
		
		return true
	else:
		return false

func CameraIsAtLimit_Left(var camera):


	var correction = Vector2()
	var SceneSize = get_node("/root/GameCore").CurrentScene.get_node("/root/SceneRoot").SceneSize


	
	if( Resolution.x == 800 and Resolution.y == 600):
		correction.x = 400
		correction.y = 300

	if( Resolution.x == 1366 and Resolution.y == 768):
		correction.x = 683
		correction.y = 384

	if( Resolution.x == 1920 and Resolution.y == 1080):
		correction.x = 960
		correction.y = 540


	var camera_pos = camera.get_pos()


	if( camera_pos.x - correction.x <= 0):
		return true
	else:
		return false


func CameraIsAtLimit_Bottom(var camera):


	var correction = Vector2()
	var SceneSize = get_node("/root/GameCore").CurrentScene.get_node("/root/SceneRoot").SceneSize


	if( Resolution.x == 800 and Resolution.y == 600):
		correction.x = 400
		correction.y = 300

	if( Resolution.x == 1366 and Resolution.y == 768):
		correction.x = 683
		correction.y = 384

	if( Resolution.x == 1920 and Resolution.y == 1080):
		correction.x = 960
		correction.y = 540


	var camera_pos = camera.get_pos()


	if( camera_pos.y + correction.y >= SceneSize.y):
		
		return true
	else:
		return false

func CameraIsAtLimit_Top(var camera):


	var correction = Vector2()
	var SceneSize = get_node("/root/GameCore").CurrentScene.get_node("/root/SceneRoot").SceneSize


	
	if( Resolution.x == 800 and Resolution.y == 600):
		correction.x = 400
		correction.y = 300

	if( Resolution.x == 1366 and Resolution.y == 768):
		correction.x = 683
		correction.y = 384

	if( Resolution.x == 1920 and Resolution.y == 1080):
		correction.x = 960
		correction.y = 540


	var camera_pos = camera.get_pos()


	if( camera_pos.y - correction.y <= 0):
		return true
	else:
		return false