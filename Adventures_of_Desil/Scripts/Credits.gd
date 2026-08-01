extends Node2D

var Resolution
var Stage = 1
var currentFades = []
onready var Left = get_node("Left")
onready var Right = get_node("Right")
onready var Bottom = get_node("Bottom")
var exited = false

func _ready():
	set_process_input(true)
	Resolution = get_node("/root/GameCore").Video_Resolution
	
	#Setup the screen
	get_node("Left").set_pos(Vector2(Resolution.x*0.1,Resolution.y*0.1))
	get_node("Left").set_size(Vector2(Resolution.x*0.35,Resolution.y*0.6))
	
	get_node("Right").set_pos(Vector2(Resolution.x*0.55,Resolution.y*0.1))
	get_node("Right").set_size(Vector2(Resolution.x*0.35,Resolution.y*0.6))
	
	
	get_node("Bottom").set_pos(Vector2(Resolution.x*0.25,Resolution.y*0.7))
	get_node("Bottom").set_size(Vector2(Resolution.x*0.5,Resolution.y*0.3))
	
	var Bg
	if GameCore.Video_Resolution.x == 800:
		Bg = preload("res://Textures/Misc/CredtisBg_800x600.png")
	if GameCore.Video_Resolution.x == 1366:
		Bg = preload("res://Textures/Misc/CredtisBg_1366x768.png")
	if GameCore.Video_Resolution.x == 1920:
		Bg = preload("res://Textures/Misc/CredtisBg_1920x1080.png")
	
	get_node("Background").set_texture(Bg)
	
	ShowCredits()
	GameCore.AdjustFonts()
	get_node("Sounds").StartSounds("MusicSounds")
	get_node("Sounds").SetVolume(get_node("/root/GameCore").Sound_MusicVolume,"MusicSounds")

func _input(Event):
	
	if exited:
		return

	if(Input.is_key_pressed(KEY_ESCAPE)):
		
		exited = true
		get_node("/root/GameCore").StartSceneTransition("res://Scenes/MainMenu.tscn")

func ShowCredits():
	Left.add_text("Dear Reader: ")
	Left.newline()
	Left.add_text("This game was made made by Adam Banoczki, as a degree project for Eötvös Loránd University.")
	Left.newline()
	Left.newline()
	Left.add_text("Tools used:")
	Left.newline()
	Left.add_text("Godot Game Engine v2.1.2")
	Left.newline()
	Left.add_text("Gimp 2.8")
	Left.newline()
	Left.add_text("My own C++ Framework")
	
	Bottom.add_text("Special thanks:")
	Bottom.newline()
	Bottom.add_text("My thanks to the OpenGameArt community where I cound located several graphics elements for the game including:")
	Bottom.newline()
	Bottom.newline()
	Bottom.add_text("- LPC medieval fantasy character sprites.")
	Bottom.newline()
	Bottom.add_text("- LPC Tile Atlas")
	Bottom.newline()
	Bottom.add_text("- LPC Tile Atlas2")
	Bottom.newline()
	Bottom.newline()
	Bottom.add_text("All links to the assets can be found in the documentation.")

	Right.add_text("My heartfelt thanks to the testers who were immensly helpful during the development.")
	Right.add_text(" Their insights helped a great deal.")
	