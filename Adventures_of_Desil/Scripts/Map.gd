
extends Node2D



var mainSize = Vector2(600,600)
var resolution

func _ready():
	resolution = get_node("/root/GameCore").Video_Resolution
	ChooseMap(resolution)
	
	
func ChooseMap(resolution):
	get_node("Map/Position").set("visibility/visible",true)
	

	var Map
	if resolution.x == 800:
		if GameCore.CurrentSceneName  == "Cesferan":
			Map = preload("res://Textures/Cesferan/CesferanMap_800x600.png")
		elif GameCore.CurrentSceneName  == "Iss'mor":
			Map = preload("res://Textures/Iss'mor/Iss'morMap_800x600.png")
		else:
			Map = preload("res://Textures/Misc/UnavailableMap_800x600.png")
			get_node("Map/Position").set("visibility/visible",false)
			
		get_node("Map").set_size(Vector2(350,350))

	elif resolution.x == 1366:
		if GameCore.CurrentSceneName  == "Cesferan":
			Map = preload("res://Textures/Cesferan/CesferanMap_1366x768.png")
		elif GameCore.CurrentSceneName  == "Iss'mor":
			Map = preload("res://Textures/Iss'mor/Iss'morMap_1366x768.png")
		else:
			Map = preload("res://Textures/Misc/UnavailableMap_1366x768.png")
			get_node("Map/Position").set("visibility/visible",false)
			
		get_node("Map").set_size(Vector2(600,600))

	elif resolution.x == 1920:
		if GameCore.CurrentSceneName  == "Cesferan":
			Map = preload("res://Textures/Cesferan/CesferanMap_1920x1080.png")
		elif GameCore.CurrentSceneName  == "Iss'mor":
			Map = preload("res://Textures/Iss'mor/Iss'morMap_1920x1080.png")
		else:
			Map = preload("res://Textures/Misc/UnavailableMap_1920x1080.png")
			get_node("Map/Position").set("visibility/visible",false)
			
		get_node("Map").set_size(Vector2(950,950))
	
	get_node("Map/World").set_texture(Map)


func _process(delta):
	var player_pos =  get_parent().get_parent().get_node("Player").get_pos()

	if resolution.x == 800:
		player_pos.x = player_pos.x * 0.116 #adjustment to minimap
		player_pos.y = player_pos.y * 0.116 #adjustment to minimap	

	if resolution.x == 1366:
		player_pos.x = player_pos.x * 0.195 #adjustment to minimap
		player_pos.y = player_pos.y * 0.2   #adjustment to minimap	

	if resolution.x == 1920:
		player_pos.x = player_pos.x * 0.316 #adjustment to minimap
		player_pos.y = player_pos.y * 0.316 #adjustment to minimap	
		
	#Adjust for the image( it must point with its bottom)
	player_pos.y = player_pos.y -35
	get_node("Map/Position").set_pos(player_pos)



#This watches if the window is open, 'cos if not, it does not update the position info.
#This frees up some resources, noticable only on low end computers.
func _on_Map_visibility_changed():
	if self.get_node("Map").is_visible() :
		set_process(true)
	else:
		set_process(false)