extends Node2D

var CurrentDialog 
var DialogAtEnd 

var CurrentDialogLines = { } #Empty dictionary, will contain the most current ID-s on from the tree, 
                             #and this shows all the displayed text in order by ID.

var PlayerAndUI 
var QuestManager
var DialogDatabase
var InDialog 
var ConditionalReationLock = false

var NPCName

func _ready():
	InDialog = false
	PlayerAndUI = get_node("/root/SceneRoot/PlayerAndUI")
	QuestManager = get_node("/root/SceneRoot/WorldEvents/QuestManager")
	DialogDatabase = get_node("/root/Core_Database").DialogDatabase
	
	if GameCore.LoadedFromPlayerSave == true:

		if  GameCore.LoadedFromCombat == true: 
			get_node("/root/GameCore").ReadDialogCompletions(get_node("/root/GameCore").beforeBattleQuickSaveRoute)
		else:
			get_node("/root/GameCore").ReadDialogCompletions(get_node("/root/GameCore").saveFileRoute)




func CreateDialog(SourceButton,TalkTo, currentDialogLines =  {  "Threads":  []  , "DialogIDTrackList": [] } ,DialogAtEnd = false): #Talkto like NPC5

	#Little delay for the scene, to catch up.
	var t = Timer.new()
	t.set_wait_time(0.1)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	
	
	InDialog = true

	if(SourceButton != null):
		SourceButton.queue_free() #Delete the interaction start button.

	#Set the Current Dialog based on the TalkTo varable which is a name of the npc( NPC-1 for example )
	for Dialog in DialogDatabase:
		if( TalkTo == Dialog["Name"] ): #Check the first element in ListEntry(name)
			CurrentDialog = Dialog 
			CurrentDialogLines = currentDialogLines
			if Dialog["Name"] != "NPC-NON-COM":
				#Set npc name to Character name. ( Dialog["Name"] is the file name )
				for npc in get_node("/root/SceneRoot/NPCs").get_children():
					if npc.CommID == TalkTo: 
						NPCName = npc.CharacterName + " : " 
			else:
				NPCName = ""

	#Set up  the display.
	PlayerAndUI.ClearDialogScreen()
	PlayerAndUI.DialogScreenVisibility(true)
	

	#Load all previous talks if needed.
	if( currentDialogLines["DialogIDTrackList"] != [] ):
		LoadPreviousTalkAndAnswers()
		return # After loading the nessecery lines and answers we exit, we have no further work to do.
	else:
		Core_Database.BattleDetails.clear() #We have to clear the prevous battle details.
		
	#If we did not have to load anything we proceeed.
	#Create dialog only works with dialogline what is a reaction.(See manual.)
	var FirstDialogLine = CurrentDialog["DialogLines"][0] #We read the first line of the dialog it has to be an ID-1 or an ID-END. ( both reaction )
	
	if( FirstDialogLine["ID"] == "ID-END" ): #If the npc just says something to us and that's it, we can't ask...
		if( FirstDialogLine["Reaction"] == true ): # create dalog only works with reactions.
			PlayerAndUI.AddTextToDialogScreen( NPCName +  FirstDialogLine["Answer"] )
			PlayerAndUI.NewLineToDialogScreen()
		else:
			print("Create dialog only works with dialogline what is a reaction.(See manual.)")
			return
		
	elif( FirstDialogLine["ID"] == "ID-1"):
		if( FirstDialogLine["Reaction"] == true ): # create dalog only works with reactions.
			PlayerAndUI.AddTextToDialogScreen( NPCName + FirstDialogLine["Answer"] )
			CreateAvailableAnswerButtons(FirstDialogLine,CurrentDialog)
				
			#This updates the tracker. Since this is the first entry, the "Zeroth Line" is a placeholder, the below command
			#will push ID-1 to the tracer that is empty at this point.
			UpdateDialogTracker("Zeroth Line","ID-1") 
		else:
			print("Create dialog only works with dialogline what is a reaction.(See manual.)")
			return
				
	else:
		print("Wrong dialog format!")
		
	QuestManager.CheckForQuestAdvancementInDialog(CurrentDialog["Name"],FirstDialogLine["Answer"])
	QuestManager.CheckForQuestActivationByDialog(CurrentDialog["Name"],FirstDialogLine["Answer"])
		
func AdvanceDialog(SourceButton,currentLineID,nextLineID): # a query a nexline id queryje

	var answer_button_text
	if( SourceButton != null):
		#If there was a button we need the text on if for quest advancement check.
		answer_button_text = SourceButton.get_text()
		SourceButton.queue_free()
		#If we given an answer show it on screen.
		PlayerAndUI.NewLineToDialogScreen()
		PlayerAndUI.AddTextToDialogScreen( "Desil: " + answer_button_text)
		
		#Check if the button we pressed s the query was a trigger
		QuestManager.CheckForQuestAdvancementInDialog(CurrentDialog["Name"],answer_button_text)
		QuestManager.CheckForQuestActivationByDialog(CurrentDialog["Name"],answer_button_text)
	
	RemoveCounterLines(nextLineID) 
	
	UpdateDialogTracker(currentLineID,nextLineID) # This updates the tracker.
	
	for dialogLine in CurrentDialog["DialogLines"]: # we get the second element what is an array with dictionaries
		if( dialogLine["ID"] == nextLineID ): # we got the line we need.( this line query was shown on the button that we pressed)

				if dialogLine["Conditional"] == true :
					var Lead
					var CondBool
					if CheckForConditionSuccess(dialogLine):
						Lead = "Condition_Success_Leads"
						CondBool = true
					else:
						Lead = "Condition_Fail_Leads"
						CondBool = false
						
					if IfNextLineIsConditionalReaction(dialogLine,CurrentDialog,Lead):
						pass
					else:
						if IfNextLineIsWonBattle(dialogLine,CurrentDialog,Lead):
							pass
						else:
							if IfNextLineIsPureReaction(dialogLine,CurrentDialog,Lead):
								pass                 
							else: #Simple non reaction condition
								if CondBool:
									for Condition_Success_Leads_ID in dialogLine["Condition_Success_Leads"]:
										UpdateDialogTracker(dialogLine["ID"],Condition_Success_Leads_ID) # This updates the tracker.
										AdvanceDialog(null,dialogLine["ID"],Condition_Success_Leads_ID)
								else:
									for Condition_Fail_Leads_ID in dialogLine["Condition_Fail_Leads"]:
										UpdateDialogTracker(dialogLine["ID"],Condition_Fail_Leads_ID)
										AdvanceDialog(null,dialogLine["ID"],Condition_Fail_Leads_ID)
				else:
                   
					if IfNextLineIsConditionalReaction(dialogLine,CurrentDialog,"Leads"):
						pass
					else:
						if IfNextLineIsWonBattle(dialogLine,CurrentDialog,"Leads"):
							pass
						else:
							if IfNextLineIsPureReaction(dialogLine,CurrentDialog,"Leads"):
								pass                 
							else: #Simple node
								PlayerAndUI.NewLineToDialogScreen()
								PlayerAndUI.AddTextToDialogScreen( NPCName + dialogLine["Answer"] )
								CreateAvailableAnswerButtons(dialogLine,CurrentDialog,"Leads") # ez vihet batte/sima ba.
								
								#Check if the button we pressed was a trigger or not.
								QuestManager.CheckForQuestAdvancementInDialog(CurrentDialog["Name"],dialogLine["Answer"])
								QuestManager.CheckForQuestActivationByDialog(CurrentDialog["Name"],dialogLine["Answer"])




#Lead types : "Leads" thats de default,Condition_Success_Leads,Condition_Fail_Leads
func CreateAvailableAnswerButtons(dialogLine,CurrentDialog,Leadtype = "Leads"):
	if( dialogLine["ID"] != "ID-END" ): #If it is the end of the dialog we are not serching for next queries.
		for nextLineID in dialogLine[Leadtype]: #this shons where this line leads, nextLineID is an ID-*
			#so we iterate trought the dictionary list once more searching for the next line Query entry
			for nextDialogLine in CurrentDialog["DialogLines"]:
				if( nextDialogLine["ID"] == nextLineID):  #if we found thre next line we need
					if( nextDialogLine["Reaction"] == false ): # can't be a reaction
						#Ha csatába visz
						if( nextDialogLine["Battle"] == true ):
								#Let's check if player defated this npc before
								if( nextDialogLine["Battle_Complete"] == false ):
									PlayerAndUI.CreateInteractionButton(nextDialogLine["Query"],self,"BattleTransition",[dialogLine["ID"],nextLineID])
						else:
							PlayerAndUI.CreateInteractionButton(nextDialogLine["Query"],self,"AdvanceDialog",[dialogLine["ID"],nextLineID])

func LoadPreviousTalkAndAnswers():
		#This is needed 'cos without this "Talk" will be there 'cos it has benn triggered by puting the character there in load.
		PlayerAndUI.ClearInteractionContainer()
		
		for id in CurrentDialogLines["DialogIDTrackList"]: #These are the dialogs lines that have been shown in order :) 
			for dialogLine in CurrentDialog["DialogLines"]:  #Go trought dialoglines and search for listed ID
				if( dialogLine["ID"] == id):
					if( dialogLine.has("Query") ): # if there is a query in the node.. display it ( reaction nodes have no query )
						PlayerAndUI.AddTextToDialogScreen( "Desil: " + dialogLine["Query"] )
						PlayerAndUI.NewLineToDialogScreen()
					if( dialogLine.has("Answer") ): # if there is an answer in the node.. display it ( conditional nodes have no answer )
						PlayerAndUI.AddTextToDialogScreen( NPCName + dialogLine["Answer"] )
						PlayerAndUI.NewLineToDialogScreen()

						
		#Advance dialog, 'cos we need the available buttons.
		for threadCurrentID in CurrentDialogLines["Threads"]:
			for dialogLine in CurrentDialog["DialogLines"]:
				if( dialogLine["ID"] == threadCurrentID):

					if dialogLine["Battle"] == true:  
				
						if !Core_Database.BattleDetails.empty():
							if dialogLine["Battle_Complete"] == true:
								#This can lead to several nodes.
								for Battle_Success_Leads_IDs in dialogLine["Battle_Success_Leads"]:
									AdvanceDialog(null,threadCurrentID,Battle_Success_Leads_IDs)
							else: # We lost the battle
								for Battle_Fail_Leads_IDs in dialogLine["Battle_Fail_Leads"]:
									AdvanceDialog(null,threadCurrentID,Battle_Fail_Leads_IDs)
									
					
						else:
							BattleTransition(null,"DUMMY-ID",threadCurrentID,true) #Current id won't be used so dummy is good.
					else: # if this is just a normal non battle node.
						CreateAvailableAnswerButtons(dialogLine,CurrentDialog)

		
func UpdateDialogTracker(currentLineID,nextLineID):
	#Append dictionary in the correct way.
	var foundLead = false  #If not found, that means there is a new thread cos the old one got updated by the first junction.
	for index in range(0,self.CurrentDialogLines["Threads"].size()):
		if( CurrentDialogLines["Threads"][index] == currentLineID ):
			#If there is an existent lead from that leaf update it.
			self.CurrentDialogLines["Threads"][index] = nextLineID
			foundLead = true
			
	if( foundLead == false):
		#Gotot has a bug with appending arrays inside Dictionaries. We have to work around that.
		var tArrray = CurrentDialogLines["Threads"]
		tArrray.push_back(nextLineID)
		self.CurrentDialogLines["Threads"] = tArrray
	
	var tArrray = CurrentDialogLines["DialogIDTrackList"]
	tArrray.push_back(nextLineID)
	self.CurrentDialogLines["DialogIDTrackList"] = tArrray



func CheckForConditionSuccess(dialogLine):
	if ( dialogLine["Condition_Type"] == "Statistic" ):
		var statisticValueInQuestion = get_node("/root/GameCore").Player.GetStatisticValue(dialogLine["Condition_Name"])
		if( statisticValueInQuestion >= dialogLine["Condition_Value"] ):
			return true
		else:
			return false
		
	if ( dialogLine["Condition_Type"] == "QuestIsActive" ):
		return get_node("/root/SceneRoot/WorldEvents/QuestManager").IsQuestAtive(dialogLine["Condition_Name"])
	if ( dialogLine["Condition_Type"] == "QuestIsComplete" ):
		return get_node("/root/SceneRoot/WorldEvents/QuestManager").IsQuestComplete(dialogLine["Condition_Name"])
	
	else:
		print("[!] Illegal Dialog condition type!")
		


func IfNextLineIsConditionalReaction(dialogLine,CurrentDialog, Leadtype):
	if( dialogLine["ID"] != "ID-END" ):
		for nextLineID in dialogLine[Leadtype]:
			#We search for this next line we need 
			for nextDialogLine in CurrentDialog["DialogLines"]:
				if( nextDialogLine["ID"] == nextLineID):
					if( nextDialogLine["Reaction"] == true ):
						if( nextDialogLine["Conditional"] == true ):
							
							#Guard for scenario where reaction is after a conditional reaction and after that there is a conditional reation.
							if( dialogLine["Reaction"] == true ):
								PlayerAndUI.NewLineToDialogScreen()
								PlayerAndUI.AddTextToDialogScreen( NPCName + dialogLine["Answer"] )
								
								
								QuestManager.CheckForQuestAdvancementInDialog(CurrentDialog["Name"],dialogLine["Answer"])
								QuestManager.CheckForQuestActivationByDialog(CurrentDialog["Name"],dialogLine["Answer"])
								#Update dialog tracker 'cos we will leap trought a node so it has to be registered.
								UpdateDialogTracker(dialogLine["ID"],nextDialogLine["ID"]) # This updates the tracker.
								
							if( dialogLine["Conditional"] == true ):
								UpdateDialogTracker(dialogLine["ID"],nextDialogLine["ID"]) 
							
							if CheckForConditionSuccess(nextDialogLine):
								for Condition_Success_Leads_ID in nextDialogLine["Condition_Success_Leads"]:
									AdvanceDialog(null,nextDialogLine["ID"],Condition_Success_Leads_ID)
									return true
							else:
								for Condition_Fail_Leads_ID in nextDialogLine["Condition_Fail_Leads"]:
									AdvanceDialog(null,nextDialogLine["ID"],Condition_Fail_Leads_ID)
								return true
	return false


func IfNextLineIsWonBattle(dialogLine,CurrentDialog, Leadtype):
	if( dialogLine["ID"] != "ID-END" ):
		for nextLineID in dialogLine[Leadtype]:
			#We search for this next line we need 
			for nextDialogLine in CurrentDialog["DialogLines"]:
				if( nextDialogLine["ID"] == nextLineID):
					if( nextDialogLine["Battle"] == true ):
						if( nextDialogLine["Battle_Complete"] == true ):
							for Battle_Success_Leads_IDs in nextDialogLine["Battle_Success_Leads"]:
								AdvanceDialog(null,dialogLine["ID"],Battle_Success_Leads_IDs)
							return true
	return false

func IfNextLineIsPureReaction(dialogLine,CurrentDialog, Leadtype):
	if( dialogLine["ID"] != "ID-END" ):
		for nextLineID in dialogLine[Leadtype]:
			#We search for this next line we need 
			for nextDialogLine in CurrentDialog["DialogLines"]:
				if( nextDialogLine["ID"] == nextLineID):
					if( nextDialogLine["Reaction"] == true ):
						
						if dialogLine["Conditional"] == false:   
							PlayerAndUI.NewLineToDialogScreen()
							PlayerAndUI.AddTextToDialogScreen( NPCName + dialogLine["Answer"] )
						
						if dialogLine.has("Answer"):
							QuestManager.CheckForQuestAdvancementInDialog(CurrentDialog["Name"],dialogLine["Answer"])
							QuestManager.CheckForQuestActivationByDialog(CurrentDialog["Name"],dialogLine["Answer"])
						UpdateDialogTracker(dialogLine["ID"],nextLineID) # This updates the tracker.
						
						#Let's check where it leads.
						if IfNextLineIsConditionalReaction(nextDialogLine,CurrentDialog,"Leads"):
							return true
						elif IfNextLineIsWonBattle(nextDialogLine,CurrentDialog,"Leads"):
							return true
						else: #If it is a normal node..
							#We should display the reaction answer
							PlayerAndUI.NewLineToDialogScreen()
							PlayerAndUI.AddTextToDialogScreen( NPCName + nextDialogLine["Answer"])
							
							
							QuestManager.CheckForQuestAdvancementInDialog(CurrentDialog["Name"],nextDialogLine["Answer"])
							QuestManager.CheckForQuestActivationByDialog(CurrentDialog["Name"],nextDialogLine["Answer"])
							
							#Create answers for this.
							CreateAvailableAnswerButtons(nextDialogLine,CurrentDialog,"Leads")
							
							return true
	return false
	

func BattleTransition(SourceButton,currentLineID,nextLineID,DoNotTrackAndNoAnswer = false):
	if(SourceButton != null):
		SourceButton.queue_free() #Delete the interaction start button.
	
	if !DoNotTrackAndNoAnswer:
		UpdateDialogTracker(currentLineID,nextLineID) # This updates the tracker.
	PlayerAndUI.NewLineToDialogScreen()
	
	for dialogLine in CurrentDialog["DialogLines"]: # We get the second element what is a dictionary
		if( dialogLine["ID"] == nextLineID ): #We got the line we need.( this line query was shown on the button that we pressed)
				if dialogLine["Battle_Complete"] == true:
					AdvanceDialog(null,dialogLine["ID"],"Battle_Success_Leads")
					return # Don't go forward just exit here.
				#If battle was not completed.
				else:
					if !DoNotTrackAndNoAnswer: #This is needed because in LoadPreviousTalkAndAnswers we written the answer already.
						PlayerAndUI.AddTextToDialogScreen(  NPCName + dialogLine["Answer"] )
			
	#This is a button on the UI, that is not connected to anyone here we connect it to our world event.
	#Also the ResetInteractions hides this button cos if you go away from the NPC you cant battle.
	#But the interaction text and the exit remains on screen as intended.
	
	var node_to_connect_to = get_node("/root/SceneRoot/WorldEvents/SceneChange")
	var in_node_function_name = "_on_Start_Battle_Button_Pressed"
	
	#We pass the button the current line id. ( Indicating what is the source ( what node ) of the battle. )
	PlayerAndUI.get_node("UI/DialogBox/DialogButtons/StartBattle").connect("pressed",self,in_node_function_name,[CurrentDialog["Name"],nextLineID],CONNECT_ONESHOT)
	PlayerAndUI.get_node("UI/DialogBox/DialogButtons/StartBattle").set("visibility/visible",true)
	

#This was not auto generated: 
func _on_Start_Battle_Button_Pressed(NPCName,DialogNode):
	print("Battle Button Pressed")
	
	#Save Battle details
	var data = {}
	data["NPCName"] = NPCName
	data["DialogNode"] = DialogNode
	data["BattleWon"] = false
	get_node("/root/Core_Database").BattleDetails = data
	
	#New save stuff would be needed.
	GameCore.GenerateSaveFile( get_node("/root/GameCore").beforeBattleQuickSaveRoute,false)

	#Transition into battle.
	get_node("/root/GameCore").StartSceneTransition("res://Scenes/Combat.tscn")
	
func RemoveCounterLines(lineId):
	for dialogLine in CurrentDialog["DialogLines"]: 
		if( dialogLine["ID"] == lineId ):
			if dialogLine.has("RemovesQuery"):
				for toRemove in dialogLine["RemovesQuery"]:
					for answerButton in get_node("/root/SceneRoot/PlayerAndUI/UI/InteractionContainer").get_children():
						if answerButton.get_text() == toRemove:
							answerButton.queue_free()