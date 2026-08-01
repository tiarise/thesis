extends Node2D

var QuestLines
var PlayerAndUI

func _ready():
	PlayerAndUI = get_node("/root/SceneRoot/PlayerAndUI")
	QuestLines = get_node("/root/GameCore").QuestLines

func CheckForQuestAdvancementInDialog(NPC,Answer):
	for questLine in QuestLines: # This checks "a file"
		for quest in questLine["Quests"]:
			if ( quest["CompletionType"] == "Talk" && quest["Completed"] != true ):
				if ( quest["CompleteNPC"] == NPC && quest["CompleteKeyLine"] == Answer ):
					var text = "You succesfully completed the quest: " + quest["Name"]
					PlayerAndUI.PopupNotification("Quest completed",text)
					quest["Completed"] = true
					quest["Started"] = true #This needs to be set. This means that it's possible to instantly complete a quest even if you didn't know you did it.
					PlayerAndUI.get_node("UI/Journal").DisplayQuestsOnJournal()
					CheckForAllPrimaryComplete()
					
					if quest.has("RewardItems"):
						for item in quest["RewardItems"]:
							var separator = item.find(" ")
							var base = item.substr(separator+1,item.length())
							var modifier = item.substr(0,separator)
							GameCore.Player.GenerateItem(base,modifier)
							
							PlayerAndUI.PopupNotification("Item aquired!","You aquired an item named: " + item)
							get_node("/root/SceneRoot/PlayerAndUI/UI/Inventory").ClearInventroy()
							get_node("/root/SceneRoot/PlayerAndUI/UI/Inventory").PopulateInventory()
							
					if quest.has("RewardStatistics"):
						for statistic in quest["RewardStatistics"].keys():
							GameCore.Player.ChangeStatisticBaseValueBy(statistic,quest["RewardStatistics"][statistic] )
						get_node("/root/SceneRoot/PlayerAndUI/UI/CharacterSheet").PopulateCharacterSheet()
							
					if quest.has("RewardExperience"):
						PlayerAndUI.PopupNotification("Experience gained!","You gained " + str( quest["RewardExperience"] ) + " experience!")
						GameCore.Player.ChangeStatisticBaseValueBy("Experience",quest["RewardExperience"] )
						GameCore.SetExperienceBar()

func CheckForQuestAdvancementInAreaTrigger(QuestName):
	for questLine in QuestLines:
		for quest in questLine["Quests"]:
			if ( quest["Name"] == QuestName ):
				if ( quest["CompletionType"] == "AreaTrigger" && quest["Completed"] != true ):
					PlayerAndUI.PopupNotification(quest["PopupText"],quest["CompletionText"])
					quest["Completed"] = true
					quest["Started"] = true
					PlayerAndUI.get_node("UI/Journal").DisplayQuestsOnJournal() #update journal...
					CheckForAllPrimaryComplete()
					
					if quest.has("RewardItems"):
						for item in quest["RewardItems"]:
							var separator = item.find(" ")
							GameCore.Player.GenerateItem(item.substr(separator+1,item.length()),item.substr(0,separator) )
							PlayerAndUI.PopupNotification("Item aquired!","You aquired an item named: " + item)
							get_node("/root/SceneRoot/PlayerAndUI/UI/Inventory").ClearInventroy()
							get_node("/root/SceneRoot/PlayerAndUI/UI/Inventory").PopulateInventory()
							
					if quest.has("RewardExperience"):
						PlayerAndUI.PopupNotification("Experience gained!","You gained " + str( quest["RewardExperience"] ) + " experience!")
						GameCore.Player.ChangeStatisticBaseValueBy("Experience",quest["RewardExperience"] )
						GameCore.SetExperienceBar()
			
func CheckForQuestActivationByDialog(NPC,Answer):
	for questLine in QuestLines: # This checks "a file"
		for quest in questLine["Quests"]:
			if ( quest["StartType"] == "Talk" && quest["Started"] != true ):
				if ( quest["StartNPC"] == NPC && quest["StartTriggerLine"] == Answer ):
					var text = "Quest started: " + quest["Name"]
					PlayerAndUI.PopupNotification("Quest started",text)
					quest["Started"] = true
					PlayerAndUI.get_node("UI/Journal").DisplayQuestsOnJournal()
	
func CheckForQuestActivationByAreaTrigger(QuestName):
	for questLine in QuestLines: # This checks "a file"
		for quest in questLine["Quests"]:
			if ( quest["Name"] == QuestName and quest["Started"] != true ):
					var text = "Quest started: " + quest["Name"]
					PlayerAndUI.PopupNotification("Quest started",text)
					quest["Started"] = true
					PlayerAndUI.get_node("UI/Journal").DisplayQuestsOnJournal()


func IsQuestAtive(QuestName):
	for questLine in QuestLines: # This checks "a file"
		for quest in questLine["Quests"]:
			if quest["Name"] == QuestName:
				if quest["Started"] == true:
					return true
				else:
					return false

func IsQuestComplete(QuestName):
	for questLine in QuestLines: # This checks "a file"
		for quest in questLine["Quests"]:
			if quest["Name"] == QuestName:
				if quest["Completed"] == true:
					return true
				else:
					return false
					
func CheckForAllPrimaryComplete():
	var allPrimaryComplete = true #Assume it's true
	
	for questLine in QuestLines: # This checks "a file"
		for quest in questLine["Quests"]:
				if quest["Completed"] == false && quest["Priority"] == "Primary":
					return
	ShowEndGame()

func ShowEndGame():
	PlayerAndUI.PopupNotification("Game complete!","Congratulations! You completed the game!")
	if  GameCore.ShowGameComplete == false:
		PlayerAndUI.ShowGameComplete()
		GameCore.ShowGameComplete = true
