
extends Node2D



func _ready():
	set_process(true)
	set_process_input(true)  
	get_node("UI/DialogBox/DialogScreen").set_scroll_follow(true)
	ExperienceLabelSet()
	
func _process(delta):
	self.get_node("UI/InstanceInfo/FPS").set("text","FPS: " + str(OS.get_frames_per_second()))


#Camera Functrions
func PositionCamera():
	get_node("Camera/Camera2D").set("current",true) 
	var playerPos= get_node("Player").get_pos()
	get_node("Camera").set_pos(playerPos) 
	
func SetCameraLimits( Resolution ):
	get_node("Camera/Camera2D").set("limit/left",0)
	get_node("Camera/Camera2D").set("limit/top",0)
	get_node("Camera/Camera2D").set("limit/right",Resolution.x)
	get_node("Camera/Camera2D").set("limit/bottom",Resolution.y)
	
	
#UI functions

func PopupNotification(var notificationString,var DisplayRichText):
	var notif = Button.new()
	notif.set_text(notificationString)
	var size = get_node("UI/NotificationContainer").get("rect/size")
	notif.set("rect/size",Vector2(size.x,5))
	notif.add_to_group("UIFontType")
	

	notif.connect("pressed",self,"_Notification_Pressed",[notif,DisplayRichText])


	get_node("UI/NotificationContainer").add_child(notif)
	notif.set_light_mask(20)
	

	get_node("/root/SceneRoot/Sounds").StartSound("Popup","MiscSounds",true,"notification")
	
	
	GameCore.AdjustFonts()


func _Notification_Pressed(notif_button,DisplayText):
	print("Notification pressed")
	
	if ( IsInteractionOngoing() ):
		AddTextToDialogScreen( DisplayText,true )
	else:
		get_node("UI/DialogBox/DialogScreen").clear() #this solves the too much click problem
		AddTextToDialogScreen( DisplayText,false )
		get_node("UI/DialogBox/DialogButtons/ExitDialog").set("visibility/visible",true)
		get_node("UI/DialogBox/DialogScreen").set("visibility/visible",true)
	
	notif_button.queue_free() #delete button

#If we have the at least one button in the interaction container
#This is needed by the _Notification_Pressed function.
#SaveGame checks this for interaction dialog save.
func IsInteractionOngoing():
	if( get_node("/root/SceneRoot/WorldEvents/DialogManager").InDialog == true ):
		return true 
	else:
		return false 

#This is needed by the DialogManager
func CreateInteractionButton(button_text,node_to_connect_to,in_node_function_name, parameterArray = []):


	var button = Button.new()
	button.set_text(button_text)
	var size = get_node("UI/InteractionContainer").get("rect/size")
	button.set("rect/size",Vector2(size.x,5)) 
	button.add_to_group("UIFontType")

	#create the parameter array: first the sourse_button then the function parameters
	var sendArray = [button]
	for entry in parameterArray:
		sendArray.append(entry)

	button.connect("pressed",node_to_connect_to,in_node_function_name,sendArray)

	get_node("UI/InteractionContainer").add_child(button)
	button.set_light_mask(20)
	get_node("/root/GameCore").AdjustFonts()



func AddTextToDialogScreen( text,isNotifInInteraction = false ):
	if ( isNotifInInteraction ):
		get_node("UI/DialogBox/DialogScreen").newline()
		get_node("UI/DialogBox/DialogScreen").push_color(Color(0,1,0,1))
		get_node("UI/DialogBox/DialogScreen").add_text( "[ " + text + " ]" )
		get_node("UI/DialogBox/DialogScreen").pop()
	else:
		get_node("UI/DialogBox/DialogScreen").add_text( text )

func NewLineToDialogScreen():
	get_node("UI/DialogBox/DialogScreen").newline()

func ClearDialogScreen():
	get_node("UI/DialogBox/DialogScreen").clear()
	
#Dialog manager uses this.
func DialogScreenVisibility( visibility ):
	get_node("UI/DialogBox/DialogScreen").set("visibility/visible",visibility)
	get_node("UI/DialogBox/DialogButtons/ExitDialog").set("visibility/visible",visibility)
	


func ExperienceLabelSet():
	get_node("UI/MainUIContainer/ExperienceLabel").set_text("Level " + str(GameCore.Player.GetIdentityLevel()) + " / progress to next level:")


#Delete all buttons in the interaction container
func ClearInteractionContainer():
	var interaction_list = get_node("UI/InteractionContainer").get_children()
	for i in interaction_list:
		i.queue_free()
	


func ResetInteraction():
	ClearInteractionContainer()
	#Also remove the Start Battle button cos you can't battle if you're away.
	#That is a oneshot connection
	get_node("UI/DialogBox/DialogButtons/StartBattle").set("visibility/visible",false)


func PositionUI():
	var Resolution = get_node("/root/GameCore").Video_Resolution
	var playerPos = get_node("Player").get_pos()
	
	#This is the parent of the whole UI tree 
	#( this will follow the player and on top of the player is the camera  also)
	self.get_node("UI").set_pos(playerPos)
	
	var Version = get_node("/root/GameCore").Version
	self.get_node("UI/InstanceInfo/Version").set_text(Version)
	
	#For the following to wok everything has to be in the (0,0) includeing the UI.
	if( Resolution.x == 800 ):
		get_node("UI/DialogBox/DialogButtons").set_size( Vector2(120,400) )
		get_node("UI/DialogBox/DialogButtons").set_pos( Vector2 (-400,-280) )
		get_node("UI/DialogBox/DialogButtons/ExitDialog").set("visibility/visible",false)
		get_node("UI/DialogBox/DialogButtons/StartBattle").set("visibility/visible",false)
		
		
		get_node("UI/DialogBox/DialogScreen").set_size( Vector2(480,120) )
		get_node("UI/DialogBox/DialogScreen/Panel").set_size( Vector2(480,120) )
		
		var middle_position_correction = get_node("UI/DialogBox/DialogScreen").get_size().x/2
		get_node("UI/DialogBox/DialogScreen").set_pos( Vector2( -middle_position_correction, -300 ))
		get_node("UI/DialogBox/DialogScreen").set("visibility/visible",false)
		
		get_node("UI/InteractionContainer").set("rect/pos",Vector2 ( get_node("UI/DialogBox/DialogScreen").get_pos().x , get_node("UI/DialogBox/DialogScreen").get_pos().y+ get_node("UI/DialogBox/DialogScreen").get_size().y +1 ) ) 
		get_node("UI/InteractionContainer").set("rect/size",Vector2(480,120))
		
		get_node("UI/InstanceInfo").set("rect/size",Vector2(120,60))
		get_node("UI/InstanceInfo").set("rect/pos",Vector2(400-get_node("UI/InstanceInfo").get_size().x,-300))
		
		get_node("UI/NotificationContainer").set("rect/size",Vector2(120,260))
		get_node("UI/NotificationContainer").set("rect/pos",Vector2(400-get_node("UI/NotificationContainer").get_size().x-14,-400+150))

		#MainUIContainer
		get_node("UI/MainUIContainer").set_size( Vector2(160,30) )
		
		var middle_correction = get_node("UI/MainUIContainer").get_size().x/2
		get_node("UI/MainUIContainer").set_pos( Vector2( -middle_correction, 300 - get_node("UI/MainUIContainer").get_size().y ))
		get_node("UI/MainUIContainer").set("visibility/visible",true)
		
		#In the main ui set the sizes.
		get_node("UI/MainUIContainer/ExperienceLabel").set_size( Vector2( get_node("UI/MainUIContainer").get_size().x, get_node("UI/MainUIContainer").get_size().y*0.4))
		get_node("UI/MainUIContainer/Experience").set_size( Vector2( get_node("UI/MainUIContainer").get_size().x, get_node("UI/MainUIContainer").get_size().y*0.4))
		get_node("UI/MainUIContainer/Buttons").set_size( Vector2( get_node("UI/MainUIContainer").get_size().x, get_node("UI/MainUIContainer").get_size().y*0.4))

	if( Resolution.x == 1366 ):

		get_node("UI/DialogBox/DialogButtons").set_size( Vector2(250,678) )
		get_node("UI/DialogBox/DialogButtons").set_pos( Vector2 (-683,-364) )
		get_node("UI/DialogBox/DialogButtons/ExitDialog").set("visibility/visible",false)
		get_node("UI/DialogBox/DialogButtons/StartBattle").set("visibility/visible",false)
		

		get_node("UI/DialogBox/DialogScreen").set_size( Vector2(820,150) )
		get_node("UI/DialogBox/DialogScreen/Panel").set_size( Vector2(820,150) )
		
		var middle_position_correction = get_node("UI/DialogBox/DialogScreen").get_size().x/2
		get_node("UI/DialogBox/DialogScreen").set_pos( Vector2( -middle_position_correction, -384 ))
		get_node("UI/DialogBox/DialogScreen").set("visibility/visible",false)
		
		

		get_node("UI/InteractionContainer").set("rect/pos",Vector2 ( get_node("UI/DialogBox/DialogScreen").get_pos().x , get_node("UI/DialogBox/DialogScreen").get_pos().y+ get_node("UI/DialogBox/DialogScreen").get_size().y +1 ) ) 
		get_node("UI/InteractionContainer").set("rect/size",Vector2(820,150))
		
		

		get_node("UI/InstanceInfo").set("rect/size",Vector2(205,78))
		get_node("UI/InstanceInfo").set("rect/pos",Vector2(683-get_node("UI/InstanceInfo").get_size().x,-384))
		

		get_node("UI/NotificationContainer").set("rect/size",Vector2(205,460))
		get_node("UI/NotificationContainer").set("rect/pos",Vector2(683-get_node("UI/NotificationContainer").get_size().x,-384+153))


		get_node("UI/MainUIContainer").set_size( Vector2(820,45) )
		
		var middle_correction = get_node("UI/MainUIContainer").get_size().x/2
		get_node("UI/MainUIContainer").set_pos( Vector2( -middle_correction, 384 - get_node("UI/MainUIContainer").get_size().y ))
		get_node("UI/MainUIContainer").set("visibility/visible",true)
		

		get_node("UI/MainUIContainer/ExperienceLabel").set_size( Vector2( get_node("UI/MainUIContainer").get_size().x, get_node("UI/MainUIContainer").get_size().y*0.4))
		get_node("UI/MainUIContainer/Experience").set_size( Vector2( get_node("UI/MainUIContainer").get_size().x, get_node("UI/MainUIContainer").get_size().y*0.4))
		get_node("UI/MainUIContainer/Buttons").set_size( Vector2( get_node("UI/MainUIContainer").get_size().x, get_node("UI/MainUIContainer").get_size().y*0.4))

	if( Resolution.x == 1920 ):

		get_node("UI/DialogBox/DialogButtons").set_size( Vector2(288,960) )
		get_node("UI/DialogBox/DialogButtons").set_pos( Vector2 (-960,-520) )
		get_node("UI/DialogBox/DialogButtons/ExitDialog").set("visibility/visible",false)
		get_node("UI/DialogBox/DialogButtons/StartBattle").set("visibility/visible",false)
		
		
		get_node("UI/DialogBox/DialogScreen").set_size( Vector2(1152,216) )
		get_node("UI/DialogBox/DialogScreen/Panel").set_size( Vector2(1152,216) )
		
		var middle_position_correction = get_node("UI/DialogBox/DialogScreen").get_size().x/2
		get_node("UI/DialogBox/DialogScreen").set_pos( Vector2( -middle_position_correction, -540 ))
		get_node("UI/DialogBox/DialogScreen").set("visibility/visible",false)
		
		get_node("UI/InteractionContainer").set("rect/pos",Vector2 ( get_node("UI/DialogBox/DialogScreen").get_pos().x , get_node("UI/DialogBox/DialogScreen").get_pos().y+ get_node("UI/DialogBox/DialogScreen").get_size().y +1 ) ) 
		get_node("UI/InteractionContainer").set("rect/size",Vector2(1152,216))
		
		get_node("UI/InstanceInfo").set("rect/size",Vector2(288,108))
		get_node("UI/InstanceInfo").set("rect/pos",Vector2(960-get_node("UI/InstanceInfo").get_size().x,-540))
		
		get_node("UI/NotificationContainer").set("rect/size",Vector2(288,648))
		get_node("UI/NotificationContainer").set("rect/pos",Vector2(960-get_node("UI/NotificationContainer").get_size().x,-540+216))


		get_node("UI/MainUIContainer").set_size( Vector2(1152,54) )
		
		var middle_correction = get_node("UI/MainUIContainer").get_size().x/2
		get_node("UI/MainUIContainer").set_pos( Vector2( -middle_correction, 540 - get_node("UI/MainUIContainer").get_size().y ))
		get_node("UI/MainUIContainer").set("visibility/visible",true)
		

		get_node("UI/MainUIContainer/ExperienceLabel").set_size( Vector2( get_node("UI/MainUIContainer").get_size().x, get_node("UI/MainUIContainer").get_size().y*0.4))
		get_node("UI/MainUIContainer/Experience").set_size( Vector2( get_node("UI/MainUIContainer").get_size().x, get_node("UI/MainUIContainer").get_size().y*0.4))
		get_node("UI/MainUIContainer/Buttons").set_size( Vector2( get_node("UI/MainUIContainer").get_size().x, get_node("UI/MainUIContainer").get_size().y*0.4))
		
		
	CheckForWorldEdgeCorrection() 
	GameCore.SetExperienceBar()
	
func CheckForWorldEdgeCorrection():
	var Resolution = GameCore.Video_Resolution
	var UI = get_node("UI")
	
	var PlayerPos = get_node("Player").get_pos()
	if PlayerPos.x < Resolution.x/2:
		UI.set_pos(Vector2(Resolution.x/2,UI.get_pos().y)) 
	if PlayerPos.y < Resolution.y/2:
		UI.set_pos(Vector2(UI.get_pos().x,Resolution.y/2)) 
			
	if PlayerPos.x > get_node("/root/SceneRoot").SceneSize.x - Resolution.x/2:
		UI.set_pos(Vector2(get_node("/root/SceneRoot").SceneSize.x - Resolution.x/2 ,UI.get_pos().y)) 
	if PlayerPos.y > get_node("/root/SceneRoot").SceneSize.y - Resolution.y/2:
		UI.set_pos(Vector2(UI.get_pos().x,get_node("/root/SceneRoot").SceneSize.y - Resolution.y/2)) 

func _on_Inventory_pressed():
	if get_node("UI/Inventory/Inventory").get("visibility/visible") == false :
		get_node("UI/Inventory/Inventory").set("visibility/visible",true)
		
		get_node("/root/GameCore").PutInTheMiddle( get_node("UI/Inventory/Inventory"),get_node("UI") )
	else:
		get_node("UI/Inventory/Inventory").set("visibility/visible",false)


func _on_Character_Sheet_pressed():
	if get_node("UI/CharacterSheet/CharacterSheet").get("visibility/visible") == false :
		get_node("UI/CharacterSheet/CharacterSheet").set("visibility/visible",true)
		get_node("/root/GameCore").PutInTheMiddle( get_node("UI/CharacterSheet/CharacterSheet"),get_node("UI") )
	else:
		get_node("UI/CharacterSheet/CharacterSheet").set("visibility/visible",false)


func _on_Journal_pressed():
	if get_node("UI/Journal/Journal").get("visibility/visible") == false :
		get_node("UI/Journal/Journal").set("visibility/visible",true)
		get_node("/root/GameCore").PutInTheMiddle( get_node("UI/Journal/Journal"),get_node("UI") )
	else:
		get_node("UI/Journal/Journal").set("visibility/visible",false)


func _on_Map_pressed():
	if get_node("UI/Map/Map").get("visibility/visible") == false :
		get_node("UI/Map/Map").set("visibility/visible",true)
		get_node("/root/GameCore").PutInTheMiddle( get_node("UI/Map/Map"),get_node("UI") )
	else:
		get_node("UI/Map/Map").set("visibility/visible",false)


func _on_ExitDialog_pressed():
	
	get_node("/root/SceneRoot/WorldEvents/DialogManager").InDialog = false
	
	self.DialogScreenVisibility(false)
	ClearDialogScreen()
	ResetInteraction()

func SetExperienceBarValue(var value):
	get_node("UI/MainUIContainer/Experience").set_value(value)
	
	
func ShowTutorial():
	GameCore.PutInTheMiddle( get_node("UI/Tutorial/TutorialWindow"), get_node("UI") )
	get_node("UI/Tutorial/TutorialWindow").set("visibility/visible",true)
	
func ShowGameComplete():
	GameCore.PutInTheMiddle( get_node("UI/GameComplete/GameComplete"), get_node("UI") )
	get_node("UI/GameComplete/GameComplete").set("visibility/visible",true)
