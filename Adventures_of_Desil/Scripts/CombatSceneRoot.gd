extends Node2D

var SkillDatabase = []
var EnemySkillSet = [] #This is a subset of the skill database
var GameCore

var summaryScreen = Vector2(800,600)

var PopupCounter = 1

func _ready():
	GameCore = get_node("/root/GameCore")
	Position_UI()
	BattleSummarySetup()

	get_node("Sounds").StartSounds("MusicSounds")
	get_node("Sounds").SetVolume(get_node("/root/GameCore").Sound_MusicVolume,"MusicSounds")
	
	Load_Skills()
	

func Position_UI():
		var Resolution = GameCore.Video_Resolution
		var bg

		GameCore.AdjustFonts()

		if Resolution.x == 800:
			bg = preload("res://Textures/Combat/CombatLayers/battle_background_800x600.jpg")
		if Resolution.x == 1366:
			bg = preload("res://Textures/Combat/CombatLayers/battle_background_1366x768.jpg")
		if Resolution.x == 1920:
			bg = preload("res://Textures/Combat/CombatLayers/battle_background_1920x1080.jpg")
			
		get_node("BackgroundLayers/Bg").set_texture(bg)

		#Action Bar(UI itself)
		get_node("UI/TabContainer").set_size(Vector2(Resolution.x*0.4,Resolution.y*0.2))
		get_node("UI/TabContainer").set_pos(Vector2((Resolution.x/2)-((get_node("UI/TabContainer").get_size().x)/2),Resolution.y*0.8))
		
		#Player Health
		get_node("UI/PlayerHealth").set_size(Vector2(Resolution.x*0.2,Resolution.y*0.1))
		get_node("UI/PlayerHealth").set_pos(Vector2(Resolution.x*0.05,Resolution.y*0.7))
		
		#Player Health Label
		get_node("UI/PlayerHealthLabel").set_pos(Vector2(Resolution.x*0.05,get_node("UI/PlayerHealth").get_pos().y-get_node("UI/PlayerHealthLabel").get_size().y))
		
		
		#Enemy Health
		get_node("UI/EnemyHealth").set_size(Vector2(Resolution.x*0.2,Resolution.y*0.1))
		get_node("UI/EnemyHealth").set_pos(Vector2(Resolution.x*0.05,Resolution.y*0.1))
		
		#Enemy Health Label
		get_node("UI/EnemyHealthLabel").set_pos(Vector2(Resolution.x*0.05,get_node("UI/EnemyHealth").get_pos().y-get_node("UI/EnemyHealthLabel").get_size().y))
		
		#Battle Log
		get_node("UI/BattleLog").set_size(Vector2(Resolution.x*0.2,Resolution.y*0.6))
		get_node("UI/BattleLog").set_pos(Vector2(Resolution.x*0.75,Resolution.y*0.1))
		get_node("UI/BattleLog").set_scroll_follow(true)
		
		#Turn label
		get_node("UI/TurnLabel").set_text("Turn: 1")
		var labelSize = get_node("UI/TurnLabel").get_size()
		if Resolution.x == 800:
			get_node("UI/TurnLabel").set_pos(Vector2(Resolution.x/2-50,Resolution.y/2))
		else:
			get_node("UI/TurnLabel").set_pos(Vector2(Resolution.x/2-100,Resolution.y/2))

func Load_Skills():
	var SFile = File.new()
	var exists = SFile.file_exists("res://Configuration/skills.bcfg")
	
	var loadedSkillFile = ConfigFile.new()
	if ( exists ):
		loadedSkillFile.load("res://Configuration/skills.bcfg")
		var sections = loadedSkillFile.get_sections()
		for section in sections:
			#Section keys are the quest datas
			var section_keys = loadedSkillFile.get_section_keys(section)
			
			#Create a skill and put it in the SkillsDatabase
			var Skill = { } #Dictionary
			Skill["Name"] = section 
			for skillData in section_keys:
				Skill[skillData] = loadedSkillFile.get_value(section,skillData)
			
			SkillDatabase.append(Skill)
			
	
	#Set PlayerSkillset
	var availableSkill
	for skill in SkillDatabase:
		availableSkill = false #Set to false initially
		
		if ( skill["DependencyType"] == "Self" ): 
			availableSkill = true
			
		elif ( skill["DependencyType"] == "Item" ): 
			for item in GameCore.Player.GetEquipmentList():
				if item == skill["DependencyName"]:
					availableSkill = true


		elif ( skill["DependencyType"] == "AttributeLevel" ): 
			var AttribName = skill["DependencyName"]
			var AttribLevel = skill["DependencyLevel"]
			if ( get_node("/root/GameCore").Player.GetStatisticValue(AttribName) >= AttribLevel ):
				availableSkill = true

		#If skill is available then add it.
		if availableSkill:
			var SkillButton = Button.new()
			SkillButton.set_text(skill["Name"].replace("_"," "))
			SkillButton.set_tooltip( "Accuracy: " + str(skill["Accuracy"]) + "  Damage: " + str(skill["Damage"]) )
			SkillButton.connect("pressed",get_node("Mechanics/BattleSolver"),"_Skill_Pressed",[skill["Name"]])
			SkillButton.add_to_group("UIFontType")
				
			if skill["Type"] == "Magic":
				get_node("UI/TabContainer/Magic").add_child(SkillButton)
			elif skill["Type"] == "Physical":
				get_node("UI/TabContainer/Physical").add_child(SkillButton)
			
	GameCore.AdjustFonts()
	
	#Set EnemySkillset ( Here dependecies are not checked on purpose! )
	for skill in SkillDatabase:
		for enemySkillName in Core_Database.EnemySkillDatabase[Core_Database.BattleDetails["NPCName"]]: #Array for that npc with skills.
			#We load the enemy skills from database but only those that the enemy has.
			for skill in SkillDatabase:
				if  skill["Name"] == enemySkillName:
					EnemySkillSet.append(skill) #We store that skill in the enemydatabase.

func BattleSummarySetup():
	
	if GameCore.Video_Resolution.x == 800:
		summaryScreen = Vector2(320,255) #On 800x600 the summary screen needs to be scaled down.
		
	get_node("SummaryScreen/BattleSummary/").set_size(summaryScreen)
	get_node("SummaryScreen/BattleSummary/VBoxContainer").set_size(summaryScreen)
	get_node("SummaryScreen/BattleSummary/VBoxContainer/Title").set_size(Vector2(summaryScreen.x,summaryScreen.y*0.2))
	get_node("SummaryScreen/BattleSummary/VBoxContainer/Title").set_text("Battle Summary")
	get_node("SummaryScreen/BattleSummary/VBoxContainer/Result").set_size(Vector2(summaryScreen.x,summaryScreen.y*0.3))
	get_node("SummaryScreen/BattleSummary/VBoxContainer/Details").set_size(Vector2(summaryScreen.x,summaryScreen.y*0.4))
	get_node("SummaryScreen/BattleSummary/VBoxContainer/Details/PlayerBattleStatistic").set_size(Vector2(summaryScreen.x/2,summaryScreen.y*0.4))
	get_node("SummaryScreen/BattleSummary/VBoxContainer/Details/PlayerBattleStatistic/Name").set_size(Vector2(summaryScreen.x/2,summaryScreen.y*0.1))
	get_node("SummaryScreen/BattleSummary/VBoxContainer/Details/PlayerBattleStatistic/DamageDealt").set_size(Vector2(summaryScreen.x/2,summaryScreen.y*0.1))
	get_node("SummaryScreen/BattleSummary/VBoxContainer/Details/PlayerBattleStatistic/Accuracy").set_size(Vector2(summaryScreen.x/2,summaryScreen.y*0.1))
	
	get_node("SummaryScreen/BattleSummary/VBoxContainer/Details/EnemyBattleStatistic").set_size(Vector2(summaryScreen.x/2,summaryScreen.y*0.4))
	get_node("SummaryScreen/BattleSummary/VBoxContainer/Details/EnemyBattleStatistic/Name").set_size(Vector2(summaryScreen.x/2,summaryScreen.y*0.1))
	get_node("SummaryScreen/BattleSummary/VBoxContainer/Details/EnemyBattleStatistic/DamageDealt").set_size(Vector2(summaryScreen.x/2,summaryScreen.y*0.1))
	get_node("SummaryScreen/BattleSummary/VBoxContainer/Details/EnemyBattleStatistic/Accuracy").set_size(Vector2(summaryScreen.x/2,summaryScreen.y*0.1))
	
	get_node("SummaryScreen/BattleSummary/VBoxContainer/ExitButton").set_size(Vector2(summaryScreen.x,summaryScreen.y*0.1))



func _on_ExitButton_pressed():
	print("Exit from battle Button Pressed")
	
	#This indicates for the loaded SceneRoot that is loaded positions and everything else from the quick save.
	GameCore.LoadedFromCombat = true
	
	GameCore.Player.ResetDamageToVital("Health")
	get_node("/root/GameCore").LoadGame( get_node("/root/GameCore").beforeBattleQuickSaveRoute )


func _on_BattleSummary_hide():
	if PopupCounter == 1:
			#This indicates for the loaded SceneRoot that is loaded positions and everything else from the quick save.
			GameCore.LoadedFromCombat = true
			GameCore.Player.SetDamageToVital("Health", -get_node("Mechanics/BattleSolver").enemyDamageDealt)
			get_node("/root/GameCore").LoadGame( get_node("/root/GameCore").beforeBattleQuickSaveRoute )
	else:
		PopupCounter =  PopupCounter +1
