extends Node

#Default resolution is 800x600
var Version = "Stable Release v1.0"
var Player #This is where the C++ Framework connects.

var PlayerMoving = false #Needed for detection
var PlayerInTrap = false #Needed for pathfinding and set by trap.gd

var UIFontType
var MainTextsFontType
var TitleFontType

#Next scene variables
var NextScene #This is not used in the new game load.
var CurrentScene = null #Don't use this, this is not text, this is for loading scenes
var playerPosition #This is needed when a new scene is loaded, with this we set the player position.(Scene-to-scene not load!)
var LoadedFromPlayerSave = false #This s needed for the scene root to know, that a world event thown the player here or a loading 
						 #This is imortant so we know where to put the player and if we need to load positions on a map.
var LoadedFromCombat = false #This is needed because if this is true, then quicksave will be loaded in SceneRoots ( this is set in CombatScene_Root )

#GameSettings
var GameConfigFile = "Configuration/config.cfg"
var QuestsFolder = "res://Quests/"
var Sound_MasterVolume
var Sound_MusicVolume
var Sound_EnvironmentVolume
var Video_Resolution = Vector2(800,600)
var Video_FullScreen
var Video_GameEffects
var Video_GameEffectsLevel
var Video_Show_FPS

#ShowTutorialCheck
var ShowTutorial = false #This set true by new game click and then set to false in cesferan SceneRoot.
#ShowGameCompleteCheck
var ShowGameComplete= false

#Save file related
var CurrentSceneName
var saveFileRoute = "Save/save.cfg"
#This is needed because if player saves in main squere then goes to NPC and starts a battle
#and it would be saved to main save you would lose your save before and that we don't want.
var beforeBattleQuickSaveRoute = "Save/quick_save.cfg" 

#Quests related
var QuestLines = []

var Core_Database 

func _ready():
	
	
	Core_Database = get_node("/root/Core_Database")
	
	#Load the fonts dynamicly ( Since Godot 2.1 )
	UIFontType = DynamicFont.new()
	var FontData_UI = DynamicFontData.new()
	FontData_UI.set_font_path("res://Fonts/Sansation_Bold.ttf")
	UIFontType.set_font_data(FontData_UI)
	
	
	MainTextsFontType = DynamicFont.new()
	var FontData_Text = DynamicFontData.new()
	FontData_Text.set_font_path("res://Fonts/Comfortaa-Bold.ttf")
	MainTextsFontType.set_font_data(FontData_Text)
	
	TitleFontType = DynamicFont.new()
	var FontData_Text = DynamicFontData.new()
	FontData_Text.set_font_path("res://Fonts/Carnevalee-Freakshow.ttf")
	TitleFontType.set_font_data(FontData_Text)
	

	#Set the current scene, this is needed for backgrround loading.
	var root = get_tree().get_root()
	CurrentScene = root.get_child( root.get_child_count() -1 )
	
	InitPlayer()

func InitPlayer():
	#Set the player trought the C++ Framework.
	Player = Identity_Bridge.new()
	Player.SetName("Desil")
	Player.SetIdentityLevel(1)
	

func InitPlayerItems():
	GameCore.Player.GenerateItem("LeatherCap","Simple")
	GameCore.Player.EquipItem("Simple LeatherCap")
	
	GameCore.Player.GenerateItem("LeatherChest","Simple")
	GameCore.Player.EquipItem("Simple LeatherChest")
	
	GameCore.Player.GenerateItem("LeatherGloves","Simple")
	GameCore.Player.EquipItem("Simple LeatherGloves")
	
	GameCore.Player.GenerateItem("TextilTrousers","Simple")
	GameCore.Player.EquipItem("Simple TextilTrousers")
	
	GameCore.Player.GenerateItem("LeatherBoots","Simple")
	GameCore.Player.EquipItem("Simple LeatherBoots")
	

func SetExperienceBar():
	if Player.GetIdentityLevel() != 5:
		var ExperienceTreshold = Core_Database.Levels[ Player.GetIdentityLevel()+1 ]["XP"]
		if Player.GetStatisticValue("Experience")  >= ExperienceTreshold:
			Player.SetIdentityLevel( Player.GetIdentityLevel()+1 )
			Player.ChangeStatisticBaseValueBy("Strength",10)
			Player.ChangeStatisticBaseValueBy("Intelligence",10)
			Player.ChangeStatisticBaseValueBy("Dexterity",10)
			Player.ChangeStatisticBaseValueBy("Willpower",10)
			get_node("/root/SceneRoot/PlayerAndUI").PopupNotification("LevelUp!","Congratulations! Desil is now level " + str( Player.GetIdentityLevel() ) )
			get_node("/root/SceneRoot/PlayerAndUI/UI/CharacterSheet").LoadSkills()
			
		get_node("/root/SceneRoot/PlayerAndUI/").ExperienceLabelSet()
		
		var percentage
		#Adjustment is needed if you are above LVL 1 to corretly show percentage.
		if Player.GetIdentityLevel() > 1 and Player.GetIdentityLevel() < 5:
			var relative_what_u_got = Player.GetStatisticValue("Experience") - Core_Database.Levels[ GameCore.Player.GetIdentityLevel() ]["XP"]
			percentage = relative_what_u_got / Core_Database.Levels[ GameCore.Player.GetIdentityLevel()+1 ]["XP"]
			get_node("/root/SceneRoot/PlayerAndUI").SetExperienceBarValue(percentage*100)
			get_node("/root/SceneRoot/PlayerAndUI/UI/CharacterSheet").PopulateCharacterSheet()
			
		elif Player.GetIdentityLevel() == 1:
			percentage = Player.GetStatisticValue("Experience") / Core_Database.Levels[ GameCore.Player.GetIdentityLevel()+1 ]["XP"]
			get_node("/root/SceneRoot/PlayerAndUI").SetExperienceBarValue(percentage*100)
			get_node("/root/SceneRoot/PlayerAndUI/UI/CharacterSheet").PopulateCharacterSheet()
		
		elif Player.GetIdentityLevel() == 5:
			get_node("/root/SceneRoot/PlayerAndUI").SetExperienceBarValue(100)
			get_node("/root/SceneRoot/PlayerAndUI/UI/CharacterSheet").PopulateCharacterSheet()
	else:
		#SO it was five all along
		get_node("/root/SceneRoot/PlayerAndUI").SetExperienceBarValue(100)
		get_node("/root/SceneRoot/PlayerAndUI/UI/CharacterSheet").PopulateCharacterSheet()

func ReadDialogCompletions(saveFileRoute):
	Core_Database.CompletedDialogNodes.clear()
	var SFile = File.new()
	var exists = SFile.file_exists(saveFileRoute)
	
	var loadedSaveFile = ConfigFile.new()
	if ( exists ):
		loadedSaveFile.load(saveFileRoute)
		
		if (loadedSaveFile.has_section("CompletedDialogNodes")):
			for elementKey in loadedSaveFile.get_section_keys("CompletedDialogNodes"):
				var keyValue = loadedSaveFile.get_value("CompletedDialogNodes", elementKey)
				var newDictionary = {}
				newDictionary["NPCName"] = elementKey 
				newDictionary["Data"] = keyValue
				Core_Database.CompletedDialogNodes.append(newDictionary)
				
func SetCurrentBattleToCompleted():
	for dialog in Core_Database.DialogDatabase:
		if dialog["Name"] == Core_Database.BattleDetails["NPCName"]:
			for dialogLine in dialog["DialogLines"]:
				if dialogLine["ID"] == Core_Database.BattleDetails["DialogNode"]:
					dialogLine["Battle_Complete"] = true
					print("<*>Found a battle scenario that was completed :")
					print("-NPCName : " + Core_Database.BattleDetails["NPCName"])
					print("-DialogNode : " + Core_Database.BattleDetails["DialogNode"])
					

func MergeDialogCompletionsWithDialogDatabase(): 
	for element in Core_Database.CompletedDialogNodes:
		for dialog in Core_Database.DialogDatabase:
			#Search for the same NPC name for merge...
			if element["NPCName"] == dialog["Name"]:
				#Merge the condition completions:
				for condCompleteNodeID in element["Data"]["ConditionPassed"]:
					for dialogLine in dialog["DialogLines"]:
						if condCompleteNodeID == dialogLine["ID"]: # if we find an ID match in both database set the stuff to true
							dialogLine["Condition_Already_Passed"] = true 
				#Merge batte completions:
				for condCompleteNodeID in element["Data"]["CombatPassed"]:
					for dialogLine in dialog["DialogLines"]:
						if condCompleteNodeID == dialogLine["ID"]: # if we find an ID match in both database set the stuff to true
							dialogLine["Battle_Complete"] = true 


func LoadDialogDatabase():
	#DeleteDatabase(For safety)
	Core_Database.DialogDatabase.clear()
	
	#We gather all file names from the DialogFolder to an array.
	var dialog_file_names = []
	var dialogs_dir = Directory.new()
	dialogs_dir.open(Core_Database.DialogFolder)
	dialogs_dir.list_dir_begin()
	
	#Get the list of dialog files
	while true:
		var file = dialogs_dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.extension() == "bcfg":
			dialog_file_names.append(file)
	dialogs_dir.list_dir_end()
	

	#Build Array Dictionary from files(DialogDatabase)
	for dialogFileName in dialog_file_names:
		var FileRoute = Core_Database.DialogFolder + dialogFileName
		var dialogFile = ConfigFile.new()
	
		dialogFile.load(FileRoute)
		
		var Dialog = { } #Create an empty dictionary ( for each npc that's why it is in a cycle)
		
		#We strip the file type from the name
		var dot_marker = dialogFileName.find(".")
		var dialogNameTrimmed = dialogFileName.substr(0,dot_marker)
		
		Dialog["Name"] = dialogNameTrimmed #We set the dialog line name.
		
		#We apped the dialog lines into tthe dialog then put the whole into the database.
		var DialogLines = [] # This contains the dialog nodes (id-1,id-2..., those are disctionaries.)
		
		
		var sections = dialogFile.get_sections() #Get the list of Sections
		
		for section in sections:
			#Create the dialog line
			var DialogLine = { }
			DialogLine["ID"] = section 
			
			
			var section_keys = dialogFile.get_section_keys(section) # these are the sectio ndata for example Conditional
			
			for dialogLineData in section_keys:
				DialogLine[dialogLineData] = dialogFile.get_value(section,dialogLineData)
				
				#If it is a conditional dialogline if you passed the condition once you will always pass it.
				#ONLY if it is a statistical condition for items this is not going to work that you will have to keep at yourself.
				if( dialogLineData == "Condition_Type" and DialogLine[dialogLineData] == "Statistic" ):
					DialogLine["Condition_Already_Passed"] = false
				
				#If it is a Battle starter line we put an addendum so you cant fight the same person twice.
				if( dialogLineData == "Battle" and DialogLine[dialogLineData] == true ):
					DialogLine["Battle_Complete"] = false
					
			#Append the built dialog line to the list
			DialogLines.append(DialogLine)
		
		#Put dialog lines ( array ) into the dialog itself
		Dialog["DialogLines"] = DialogLines
		#Put quest Line into Global array.
		Core_Database.DialogDatabase.append(Dialog)


func AdjustFonts():
	if( Video_Resolution.x == 800 and Video_Resolution.y == 600):
		MainTextsFontType.set_size(10)
		UIFontType.set_size(10)
		TitleFontType.set_size(56)

	if( Video_Resolution.x == 1366 and Video_Resolution.y == 768):
		MainTextsFontType.set_size(17)
		UIFontType.set_size(17)
		TitleFontType.set_size(80)

	if( Video_Resolution.x == 1920 and Video_Resolution.y == 1080):
		MainTextsFontType.set_size(18)
		UIFontType.set_size(18)
		TitleFontType.set_size(80)


	var ToChange = get_tree().get_nodes_in_group("MainTextsFontType")
	for i in ToChange:
		i.set("custom_fonts/font",self.MainTextsFontType)
		#special for richtext
		i.set("custom_fonts/normal_font",self.MainTextsFontType)
		
	var ToChange = get_tree().get_nodes_in_group("UIFontType")
	for i in ToChange:
		i.set("custom_fonts/font",self.UIFontType)
		#special for richtext
		i.set("custom_fonts/normal_font",self.UIFontType)
		
	var ToChange = get_tree().get_nodes_in_group("TitleFontType")
	for i in ToChange:
		i.set("custom_fonts/font",self.TitleFontType)
		#special for richtext
		i.set("custom_fonts/normal_font",self.TitleFontType)
		
#Don't use this, we will use the StartSceneTransition which is a wrapper around this. ( Shows loadign screen. )
#And loading scene is using this.
func SetScene(scene):
	#Set the current scene name( scene is a full path to the scene.)
	var last_separator = scene.find_last("/")
	var last_dot = scene.find_last(".")
	#dot-sep-1 is the filename without .tscn
	var trimmedSceneFile = scene.substr(last_separator+1,last_dot - last_separator-1 )
	#This is needed for the save files, they need to know what to load.
	CurrentSceneName = trimmedSceneFile
	
	#Clean up the current scene
	CurrentScene.queue_free()
	#Without renamingthe  scene can't find root in next scene...
	CurrentScene.set_name( CurrentScene.get_name() + "_deleted" )
	
	#Load the file passed in as the param "scene"
	var newScene = ResourceLoader.load(scene)
	
	#Now that we loaded it to memory we need to create it.
	CurrentScene = newScene.instance()
	
	#Add scene to root
	get_tree().get_root().add_child(CurrentScene)
	
	#get_tree().change_scene("res://levels/level2.scn") Don't do this.
	
#Put into middle if null then resolution..
func PutInTheMiddle(window,parent = null):

	#get object type
	var windowSize
	var object_1_Type = window.get_type()
	if( object_1_Type == "Node2D" ):
		if( window.get_child(0).get_type() == "TabContainer" ):
			windowSize = window.get_child(0).get("rect/size")
		else:
			#It has no dimensions
			windowSize = Vector2(0,0)
	elif( object_1_Type == "Camera2D" ):
		windowSize = Vector2(0,0)


	else:
		#Get dimensions of the window
		windowSize = window.get("rect/size")

	#Calculate the middle position for the window using resolution
	var parent_Pos
	if( parent == null ):  #We need to set to the center to be working.
		parent_Pos = self.Video_Resolution
		parent_Pos.x = parent_Pos.x/2
		parent_Pos.y = parent_Pos.y/2
	elif( parent.get_type() == "Node2D" ):
			parent_Pos = parent.get_pos()
	else:
		parent_Pos = parent.get_pos()

	var middlePosForWindow_X = 	parent_Pos.x - ( windowSize.x/2 )
	var middlePosForWindow_Y = 	parent_Pos.y - ( windowSize.y/2 )

	var pos = Vector2(middlePosForWindow_X,middlePosForWindow_Y)

	window.set_pos(pos)
	
	
#This is called from the Scene's WorldEvents.gd where you set the params.
func StartSceneTransition(var nextScene,var playerPosition = Vector2(-1,-1) ):
	#Make the scene transition now
	#Set next scene variable in globals,and player pos.
	#First is for the loading screen, next is for the new scene to set.
	self.NextScene = nextScene
	if playerPosition != Vector2(-1,-1):
		self.playerPosition = playerPosition # this is only needed if world event callls
	self.SetScene("res://Scenes/Loading.tscn")
	
	
#Configuration files save/load section

func SaveSettingsToConfigFile():
	var configFileRoute = self.GameConfigFile
	var configFile = ConfigFile.new()

	if( CheckForConfigFile() ):
		print("[*]Config file detected!")
		configFile.load(configFileRoute)

		configFile.set_value("Sound","MasterVolume", self.Sound_MasterVolume )
		configFile.set_value("Sound","MusicVolume", self.Sound_MusicVolume )
		configFile.set_value("Sound","EnvironmentVolume", self.Sound_EnvironmentVolume )
		configFile.set_value("Video","Resolution", self.Video_Resolution )
		configFile.set_value("Video","FullScreen", self.Video_FullScreen )
		configFile.set_value("Video","GameEffects", self.Video_GameEffects )
		configFile.set_value("Video","GameEffectsLevel", self.Video_GameEffectsLevel )
		configFile.set_value("Video","ShowFPS", self.Video_Show_FPS )
		configFile.save(configFileRoute)


	else:
		
		GenerateDefaultConfigFile()
		

func CheckForConfigFile():
	var configFileRoute = self.GameConfigFile
	var configFile = File.new() #Here we load is as a file, 'cos only that can be checked for existence.
	var exists = configFile.file_exists(configFileRoute)

	if( exists ):
		return true

	else:
		return false
		
		
func LoadSettingsFromConfigFile():
	var configFileRoute = self.GameConfigFile
	var configFile = ConfigFile.new()

	if( CheckForConfigFile()):
		print("[*]Config file detected!")
		configFile.load(configFileRoute)

		if (configFile.has_section_key("Sound", "MasterVolume")):
			self.Sound_MasterVolume = configFile.get_value("Sound", "MasterVolume")
		if (configFile.has_section_key("Sound", "MusicVolume")):
			self.Sound_MusicVolume = configFile.get_value("Sound", "MusicVolume")
		if (configFile.has_section_key("Sound", "EnvironmentVolume")):
			self.Sound_EnvironmentVolume = configFile.get_value("Sound", "EnvironmentVolume")
		if (configFile.has_section_key("Video", "Resolution")):
			self.Video_Resolution = configFile.get_value("Video", "Resolution")
		if (configFile.has_section_key("Video", "FullScreen")):
			self.Video_FullScreen = configFile.get_value("Video", "FullScreen")
		if (configFile.has_section_key("Video", "GameEffects")):
			self.Video_GameEffects = configFile.get_value("Video", "GameEffects")
		if (configFile.has_section_key("Video", "GameEffectsLevel")):
			self.Video_GameEffectsLevel = configFile.get_value("Video", "GameEffectsLevel")
		if (configFile.has_section_key("Video", "ShowFPS")):
			self.Video_Show_FPS = configFile.get_value("Video", "ShowFPS")
	else:
		print("[*]Config file not found!")
		
		
		
func GenerateSaveFile(saveFileRoute,excludeDialog = true):
	
	var saveFile = ConfigFile.new()
	
	var SavePosition = get_tree().get_nodes_in_group("SaveGame_Positions")
	print("[*]Generating save file!") 

	#Save the current scene name.
	saveFile.set_value("SceneSpecifics", "SceneName" , self.CurrentSceneName )
	
	#Save all the object positions who are in SaveGame_Pos group
	for i in SavePosition:
		
		var objectName = i.get_name()
		var objectPos = i.get_pos()
		saveFile.set_value("Positions",objectName,objectPos)
		
	#Save the quest advancements ( QuestStarted and QuestsCompleted )
	for questLine in QuestLines:
		var QuestLineName = questLine["Name"]
		var QuestsStarted = []
		var QuestsCompleted = []
		
		#We create the arrays to export.
		for quest in questLine["Quests"]:
			#Here we know the fact that in the program all quest have an added entry started and completed.
			#In the file they are not present.
			if quest["Started"] == true:
				QuestsStarted.append( quest["Name"] );
			if quest["Completed"] == true:
				QuestsCompleted.append( quest["Name"] );
		
		#Now we export the arrays:
		saveFile.set_value("QuestsStarted",QuestLineName,QuestsStarted)
		saveFile.set_value("QuestsCompleted",QuestLineName,QuestsCompleted)
	
	#Save Dialog details
	var inDialog = get_node("/root/SceneRoot/PlayerAndUI").IsInteractionOngoing()
	
	if excludeDialog == false && inDialog == true:
		saveFile.set_value("DialogState","InDialog",true)
	else:
		saveFile.set_value("DialogState","InDialog",false)
		inDialog = false #We have to owerride inDialog here if excludeDialog is true because inDialog must be False then.
	
	if inDialog:
		#If we are in a dialog:
		#What kind of dialog we are in and at what node
		var dialog_to = get_node("/root/SceneRoot/WorldEvents/DialogManager").CurrentDialog["Name"]
		
		#We should set this to null if exit pressed in dialog.
		var currentDialogLines = get_node("/root/SceneRoot/WorldEvents/DialogManager").CurrentDialogLines

		saveFile.set_value("DialogState","InDialog",inDialog)
		saveFile.set_value("DialogState","CurrentDialogNPC",dialog_to)
		saveFile.set_value("DialogState","CurrentDialogLines",currentDialogLines)
		
	#Save DialogCompletions
	for dialog in Core_Database.DialogDatabase: 
		var dialogName = dialog["Name"]
		var dialogConditionCompletes = []
		var dialogBattleCompletes = []
		
		for dialogLine in dialog["DialogLines"]:
			if dialogLine.has("Battle_Complete"):
				if dialogLine["Battle_Complete"] == true:
					dialogBattleCompletes.append(dialogLine["ID"])
			#There is no conditional battle so no if just elif 
			elif dialogLine.has("Condition_Already_Passed"):
				if dialogLine["Condition_Already_Passed"] == true:
					dialogConditionCompletes.append(dialogLine["ID"])
		var Data = { "ConditionPassed" : dialogConditionCompletes, "CombatPassed" : dialogBattleCompletes  } 
		saveFile.set_value("CompletedDialogNodes",dialogName,Data)
					
	saveFile.save(saveFileRoute)
	print("[*]Save File created!") # this is for the consol
	get_node("/root/SceneRoot/PlayerAndUI").PopupNotification("Save file created!","Your save file was successfully created!")


func GenerateDefaultConfigFile():
		var configFileRoute = self.GameConfigFile
		var configFile = ConfigFile.new()
		
		print("[*]Config file not found!")
		print("[*]Auto generating default config file!")
		# Add values to file
		configFile.set_value("Sound","MasterVolume",100)
		configFile.set_value("Sound","MusicVolume",100)
		configFile.set_value("Sound","EnvironmentVolume",100)
		configFile.set_value("Video","Resolution",Vector2(1366,768))
		configFile.set_value("Video","FullScreen",true)
		configFile.set_value("Video","GameEffects",true)
		configFile.set_value("Video","GameEffectsLevel","Medium")
		configFile.set_value("Video","ShowFPS",false)
		configFile.save(configFileRoute)


func LoadGame(saveFileRoute): 

	#Reset game complete 
	ShowGameComplete = false

	#We set the LoadedFromPlayerSave to true indicating that we intend to load the scene with a save file.
	get_node("/root/GameCore").LoadedFromPlayerSave = true

	#set the next scene by checking.
	var SFile = File.new()
	var exists = SFile.file_exists(saveFileRoute)
	
	var loadedSaveFile = ConfigFile.new()

	if ( exists ):
		if GameCore.LoadedFromCombat == false: #If it is loaded from menu
			InitPlayer() #To reset stat
			GameCore.Player.LoadStatistics()
			GameCore.Player.LoadItemsState()
			GameCore.Player.SetupStatisticsModifiers()
		
		loadedSaveFile.load(saveFileRoute)
		if (loadedSaveFile.has_section_key("SceneSpecifics", "SceneName")):
			var nextScene =  "res://Scenes/" + loadedSaveFile.get_value("SceneSpecifics", "SceneName" ) + ".tscn"
			self.StartSceneTransition(nextScene) #Player pos not needed it will be loaded form savefile.
	else:
		print("[!] Save file does not exists!")
		
		
func LoadPositionsDataToCurrentScene(saveFileRoute):
	var SFile = File.new()
	var exists = SFile.file_exists(saveFileRoute)
	
	var loadedSaveFile = ConfigFile.new()
	if ( exists ):
		loadedSaveFile.load(saveFileRoute)
		var SavePosition = get_tree().get_nodes_in_group("SaveGame_Positions")
		for i in SavePosition:
			if (loadedSaveFile.has_section_key("Positions", i.get_name())):
				i.set_pos( loadedSaveFile.get_value("Positions", i.get_name() ) )
		
		
#This loads the dialog if player was in a dialog when saved.
func LoadDialogDataToCurrentScene(saveFileRoute):
	var SFile = File.new()
	var exists = SFile.file_exists(saveFileRoute)
	
	var loadedSaveFile = ConfigFile.new()
	if ( exists ):
		loadedSaveFile.load(saveFileRoute)
		
		#If player save was in the middle of a dialog
		if loadedSaveFile.get_value("DialogState","InDialog") == true:
			
			var ToNPC
			var DialogLinesIDs # The dialog map what was shown before battle.
		
			if (loadedSaveFile.has_section_key("DialogState","CurrentDialogNPC")):
					ToNPC = loadedSaveFile.get_value("DialogState","CurrentDialogNPC")
			if (loadedSaveFile.has_section_key("DialogState","CurrentDialogLines")):
					DialogLinesIDs = loadedSaveFile.get_value("DialogState","CurrentDialogLines")
	
			#null cos no source button, cos of dialogLinesIDs are populated, the dialogmanager will load those 
			get_node("/root/SceneRoot/WorldEvents/DialogManager").CreateDialog(null,ToNPC,DialogLinesIDs)
			
func GetPlayerQuestProgress(saveFileRoute):
	var SFile = File.new()
	var exists = SFile.file_exists(saveFileRoute)
	
	var loadedSaveFile = ConfigFile.new()
	if ( exists ):
		loadedSaveFile.load(saveFileRoute)
		var QuestLinesProgress = []
		
		#A quest can be started and completed so, we will merge those too.
		#We load the QuestsStarted section array and add those to the array we build.
		var section_keys = loadedSaveFile.get_section_keys("QuestsStarted")
		
		#We go trought the quest lines in Section QuestsStarted
		#Example " Discoveries= ["The Market","Stuff 2"] " is a questLine and the completed quest(s) in it.
		for questLine in section_keys: 
				
				var QuestLine = {}
				QuestLine["Name"] = questLine; #We set the name, as the section key is the line name.
				QuestLine["Quests"] = []
				
				#We go trought the quest line quests
				#See upper example "The Market" and "Stuff 2"
				for quest in loadedSaveFile.get_value("QuestsStarted",questLine):
					var Quest = {};
					Quest["Name"] = quest;
					Quest["Started"] = true;
					Quest["Completed"] = false; 
					QuestLine["Quests"].append(Quest);
				
				#We append the currently made quest line progress to the array.	
				QuestLinesProgress.append(QuestLine);
				
				
		#Now we set the completed ones.
		#Only those can be completed that has been started soo:
		var completed_section_keys = loadedSaveFile.get_section_keys("QuestsCompleted")
		
		for completed_questLine in completed_section_keys: 
			#Now we have to merge this information to the started array
			for questLine in QuestLinesProgress:
				#We search for the quest line in the database we are building
				if questLine["Name"] == completed_questLine:
					#Now we merge the quest in the completed and  the progress databases.
					for completed_quest in loadedSaveFile.get_value("QuestsCompleted",completed_questLine):
						for progess_quest in questLine["Quests"]:
							if completed_quest == progess_quest["Name"]:
								progess_quest["Completed"] = true;
			
		
		return QuestLinesProgress;
	else:
		return [];


#IMPORTANT : This merges the save file ( if exists ) with the template quest files 
#Because from save file it will add the copleted not completed entry to the quests
#If newgame true the database loader ignores the player save file. ( As it would merge progression otherwise )
func LoadQuestDatabase(Newgame = false):

	#Get player progession array from save file if exists:
	#The array contains questLines with quest in it with special attrubtes see documentation.
	var PlayerProgression = GetPlayerQuestProgress( saveFileRoute );
	
	#DeleteGlobalQuestLinesDatabase:
	QuestLines.clear()
	
	var questLines = []
	var questLines_dir = Directory.new()
	questLines_dir.open(QuestsFolder)
	questLines_dir.list_dir_begin()
	
	#Get the list of questlines(filenames in quests folder)
	while true:
		var file = questLines_dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.extension() == "bcfg":
			questLines.append(file)
	questLines_dir.list_dir_end()
	
	#Build Array Dictionary from files(Quests database)
	for questLineName in questLines:
		var FileRoute = "res://Quests" + "/" + questLineName
		var questLineFile = ConfigFile.new()

		questLineFile.load(FileRoute)
		var sections = questLineFile.get_sections()
		
		var QuestLine = { } #Empty dictionary
		
		#We strip the file type from the name
		var dot_marker = questLineName.find(".")
		var questLineNameTrimmed = questLineName.substr(0,dot_marker)
		
		QuestLine["Name"] = questLineNameTrimmed #We set the quest line name.
		
		#We apped the quests into this then put this into the QuestLine.
		var QuestLineArray = []
		
		#One section is one quest
		for section in sections:
			#Section keys are the quest datas(section is the quest)
			var section_keys = questLineFile.get_section_keys(section)
			
			#Create the quest
			var Quest = { }
			Quest["Name"] = section #Set quest name
			
			Quest["Started"] = false #Crreate the two new enty with default values.
			Quest["Completed"] = false
			
			for questData in section_keys:
				Quest[questData] = questLineFile.get_value(section,questData)
				
			#If newgame is true we should ignore the progression so far
			if Newgame != true:
				#Here we check if player is started and/or completed this quest and append two new questData entry:
				for progressionQuestLine in PlayerProgression:
					#First we search out the quest line in question
					var a = progressionQuestLine["Name"]
					if QuestLine["Name"] == progressionQuestLine["Name"]:
						#If we found the questline we search for the quest in question
						for progressionQuest in progressionQuestLine["Quests"]:
							#If we found the quest we set the completed/started values.
							if progressionQuest["Name"] == Quest["Name"]:
								Quest["Started"] = progressionQuest["Started"]
								Quest["Completed"] = progressionQuest["Completed"]
			
			#If still false,false that means player not started the quest in question.
			#If this quest is "always on" we need to set it started regardless of progression 
			#Yes this is a small overhead override. ( This is a must when starting a new game )
			if Quest["StartType"] == "AlwaysOn":
						Quest["Started"] = true;
					
			
			#Apped the built quest to the list
			QuestLineArray.append(Quest)
		
		#Put quest list into the quest line
		QuestLine["Quests"] = QuestLineArray
		#Put quest Line into Global array.
		QuestLines.append(QuestLine)