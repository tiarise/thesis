
extends Node2D



var mainSize

func _ready():
		SetJournalLayout()
		DisplayQuestsOnJournal()


func SetJournalLayout():
	if GameCore.Video_Resolution.x == 800:
		mainSize = Vector2(620,300)
	else:
		mainSize = Vector2(1050,450)

	self.get_node("Journal").set_size(mainSize)
	self.get_node("Journal/TabContainer").set_size(mainSize)
	
	self.get_node("Journal/TabContainer/Ongoing").set_size(mainSize)
	self.get_node("Journal/TabContainer/Ongoing").set_columns(2)
	self.get_node("Journal/TabContainer/Ongoing").add_to_group("UIFont")
	self.get_node("Journal/TabContainer/Ongoing").set_light_mask(20)
	
	self.get_node("Journal/TabContainer/Completed").set_size(mainSize)
	self.get_node("Journal/TabContainer/Completed").set_columns(2)
	self.get_node("Journal/TabContainer/Completed").add_to_group("UIFont")
	self.get_node("Journal/TabContainer/Completed").set_light_mask(20)

		
func ClearQuestTab():
		self.get_node("Journal/TabContainer/Ongoing").clear()
		self.get_node("Journal/TabContainer/Completed").clear()

#A quest line is active if you find at least one quest that is started
func CheckIfQuestLineIsActive(QuestLine):
	for quest in QuestLine["Quests"]:
		if( quest["Started"] == true ):
			return true
	return false

#If all quests are completed.
func CheckIfQuestLineIsCompleted(QuestLine):
	for quest in QuestLine["Quests"]:
		if quest["Completed"] == false:
			return false
	return true

func CheckIfQuestIsActive(Quest):
	if( Quest["Started"] == true ):
		return true
	return false
	

func DisplayQuestsOnJournal():
	ClearQuestTab()
	
	#We create the root node ( can't be seen ) 
	var OngoingTreeRoot = get_node("Journal/TabContainer/Ongoing").create_item()
	var CompletedTreeRoot = get_node("Journal/TabContainer/Completed").create_item()
	get_node("Journal/TabContainer/Ongoing").set_hide_root(true)
	get_node("Journal/TabContainer/Completed").set_hide_root(true)
	
	for questLine in get_node("/root/GameCore").QuestLines:
		
		#We need a quest line node to relate to.
		var QuestLineNode
		var WhereToPut
		var WhatTab
		
		#If not active it is not shown.
		if self.CheckIfQuestLineIsActive(questLine):
			
			if CheckIfQuestLineIsCompleted(questLine):
				WhereToPut = CompletedTreeRoot
				WhatTab = get_node("Journal/TabContainer/Completed")
			else:
				#Now the pop:
				WhereToPut = OngoingTreeRoot
				WhatTab = get_node("Journal/TabContainer/Ongoing")
			
			QuestLineNode = WhatTab.create_item(WhereToPut)
			
			var questLineCorrected = questLine["Name"].replace("_"," ")
			QuestLineNode.set_text(0,questLineCorrected)
			QuestLineNode.set_selectable(0,false)
			QuestLineNode.set_selectable(1,false)
				
			#Now we go trought the quests.
			for quest in questLine["Quests"]:
				if quest["Started"] == true: 
					
					#Because priority in quistlines are the same [0] is valid.
					QuestLineNode.set_text(1,quest["Priority"])
					
					if( quest["Completed"] == true ):
						
						var questName = quest["Name"].replace("_"," ")
						
						var child_ongoing = WhatTab.create_item(QuestLineNode)
						child_ongoing.set_text(0, questName)
						child_ongoing.set_text(1, quest["CompletionText"])
						child_ongoing.set_icon(0, preload("res://Textures/Misc/Quest_Complete.png") )
						child_ongoing.set_selectable(0,false)
						child_ongoing.set_selectable(1,false)
			
						get_node("/root/GameCore").AdjustFonts()
							
					#If quest is not completed
					else:
							var questName = quest["Name"].replace("_"," ")
							
							var child_completed = WhatTab.create_item(QuestLineNode)
							child_completed.set_text(0, questName)
							child_completed.set_text(1, quest["Description"])
							child_completed.set_icon(0, preload("res://Textures/Misc/Quest_Active.png") )
							child_completed.set_selectable(0,false)
							child_completed.set_selectable(1,false)
							
							get_node("/root/GameCore").AdjustFonts()