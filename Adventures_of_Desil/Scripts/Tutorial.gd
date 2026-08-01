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



	get_node("TutorialWindow").set_size(Vector2(mainSize.x,mainSize.y))
	get_node("TutorialWindow/RichTextLabel").set_size(Vector2(mainSize.x,mainSize.y))
	
func Populate():
	get_node("TutorialWindow/RichTextLabel").newline()
	get_node("TutorialWindow/RichTextLabel").push_align(1)
	get_node("TutorialWindow/RichTextLabel").push_color(Color(0,1,0,1))
	get_node("TutorialWindow/RichTextLabel").add_text( "Tutorial message:" )
	get_node("TutorialWindow/RichTextLabel").pop()
	get_node("TutorialWindow/RichTextLabel").pop()
	get_node("TutorialWindow/RichTextLabel").newline()
	get_node("TutorialWindow/RichTextLabel").newline()
	get_node("TutorialWindow/RichTextLabel").add_text( "Dear player! Welcome to the game!" )
	get_node("TutorialWindow/RichTextLabel").newline()
	get_node("TutorialWindow/RichTextLabel").newline()
	get_node("TutorialWindow/RichTextLabel").add_text( "Your first main quest is to find your teacher in the Chapel." )
	get_node("TutorialWindow/RichTextLabel").newline()
	get_node("TutorialWindow/RichTextLabel").add_text( "The rest, you will have to find yourself. You are not obligated to take side quests, " )
	get_node("TutorialWindow/RichTextLabel").add_text( "however, you are highly advised to do so. This way, not only will you gain more experience points, " )
	get_node("TutorialWindow/RichTextLabel").add_text( "but you will have access to powerful items which will help you to overcome your obstacles. " )
	get_node("TutorialWindow/RichTextLabel").add_text( "You should always check the journal for more information about the discovered quests." )
	get_node("TutorialWindow/RichTextLabel").newline()
	get_node("TutorialWindow/RichTextLabel").newline()
	get_node("TutorialWindow/RichTextLabel").push_align(1)
	get_node("TutorialWindow/RichTextLabel").push_color(Color(0,1,0,1))
	get_node("TutorialWindow/RichTextLabel").add_text( "Controls:" )
	get_node("TutorialWindow/RichTextLabel").pop()
	get_node("TutorialWindow/RichTextLabel").pop()
	get_node("TutorialWindow/RichTextLabel").newline()
	get_node("TutorialWindow/RichTextLabel").newline()
	get_node("TutorialWindow/RichTextLabel").add_text( "Click with left mouse button to destination." )
	get_node("TutorialWindow/RichTextLabel").newline()
	get_node("TutorialWindow/RichTextLabel").add_text( "Press escape to open the game menu." )
	get_node("TutorialWindow/RichTextLabel").newline()
	get_node("TutorialWindow/RichTextLabel").newline()
	get_node("TutorialWindow/RichTextLabel").push_align(1)
	get_node("TutorialWindow/RichTextLabel").newline()
	get_node("TutorialWindow/RichTextLabel").newline()
	get_node("TutorialWindow/RichTextLabel").add_text( "Take care, and good luck!" )
	
