extends Node2D


var mainSize

func _ready():
	SetSheetLayout()
	Populate()

func SetSheetLayout():
	var Resolution = GameCore.Video_Resolution
	
	if( Resolution.x == 800 ):
		mainSize = Vector2(451,355)

	elif( Resolution.x == 1366 ):
		mainSize = Vector2(451,385)
		
	
	elif( Resolution.x == 1920 ):
		mainSize = Vector2(600,600)



	get_node("GameComplete").set_size(Vector2(mainSize.x,mainSize.y))
	get_node("GameComplete/RichTextLabel").set_size(Vector2(mainSize.x,mainSize.y))
	
func Populate():
	get_node("GameComplete/RichTextLabel").newline()
	get_node("GameComplete/RichTextLabel").push_align(1)
	get_node("GameComplete/RichTextLabel").push_color(Color(0,1,0,1))
	get_node("GameComplete/RichTextLabel").add_text( "Main quests completed!" )
	get_node("GameComplete/RichTextLabel").pop()
	get_node("GameComplete/RichTextLabel").pop()
	get_node("GameComplete/RichTextLabel").newline()
	get_node("GameComplete/RichTextLabel").newline()
	get_node("GameComplete/RichTextLabel").add_text( "Dear player! Thank you for playing the game!" )
	get_node("GameComplete/RichTextLabel").newline()
	get_node("GameComplete/RichTextLabel").newline()
	get_node("GameComplete/RichTextLabel").add_text( "I hope you had a geat time! You completed the main questlines of the game. " )
	get_node("GameComplete/RichTextLabel").add_text( "If you didn't complete all side quest feel free to do so. " )
	get_node("GameComplete/RichTextLabel").newline()
	get_node("GameComplete/RichTextLabel").newline()
	get_node("GameComplete/RichTextLabel").push_align(1)
	get_node("GameComplete/RichTextLabel").push_color(Color(0,1,0,1))
	get_node("GameComplete/RichTextLabel").add_text( "Special thanks:" )
	get_node("GameComplete/RichTextLabel").pop()
	get_node("GameComplete/RichTextLabel").pop()
	get_node("GameComplete/RichTextLabel").newline()
	get_node("GameComplete/RichTextLabel").newline()
	get_node("GameComplete/RichTextLabel").add_text( "My heartfelt thanks for all the help I got from the testers! Their help was much appreciated and won't be forgotten. " )
	get_node("GameComplete/RichTextLabel").add_text( "Also my thanks for several assets for the game that I got from OpenGameArt. All links are in the documentation." )
	get_node("GameComplete/RichTextLabel").newline()
	get_node("GameComplete/RichTextLabel").newline()
	get_node("GameComplete/RichTextLabel").push_align(1)
	get_node("GameComplete/RichTextLabel").newline()
	get_node("GameComplete/RichTextLabel").newline()
	get_node("GameComplete/RichTextLabel").add_text( "Take care!" )
	
