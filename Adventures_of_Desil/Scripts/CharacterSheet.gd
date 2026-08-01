
extends Node2D


var mainSize

var GameCore

func _ready():
	GameCore = get_node("/root/GameCore")

	SetSheetLayout()
	PopulateCharacterSheet()
	LoadSkills()
	
func SetSheetLayout():
	var Resolution = get_node("/root/GameCore").Video_Resolution
	
	if( Resolution.x == 800 ):
		mainSize = Vector2(470,355)

	elif( Resolution.x == 1366 ):
		mainSize = Vector2(470,385)
		
	
	elif( Resolution.x == 1920 ):
		mainSize = Vector2(600,600)



	get_node("CharacterSheet").set_size(Vector2(mainSize.x,mainSize.y))
	get_node("CharacterSheet/TabContainer").set_size(Vector2(mainSize.x,mainSize.y))
	


func PopulateCharacterSheet():
	get_node("CharacterSheet/TabContainer/Statistics").clear()
	var root = get_node("CharacterSheet/TabContainer/Statistics").create_item()
	get_node("CharacterSheet/TabContainer/Statistics").set_hide_root(true)
	
	var Level = get_node("CharacterSheet/TabContainer/Statistics").create_item(root)
	Level.set_text(0,"Level: " + str(GameCore.Player.GetIdentityLevel()) )
	
	var vitals = get_node("CharacterSheet/TabContainer/Statistics").create_item(root)
	vitals.set_text(0,"Vitals")
	var mainAttributes = get_node("CharacterSheet/TabContainer/Statistics").create_item(root)
	mainAttributes.set_text(0,"MainAttributes")
	var secondaryAttributes = get_node("CharacterSheet/TabContainer/Statistics").create_item(root)
	secondaryAttributes.set_text(0,"SecondaryAttributes")
	
	var newNode
	for statName in GameCore.Player.GetVitals():
		newNode = get_node("CharacterSheet/TabContainer/Statistics").create_item(vitals)
		newNode.set_text(0,statName + ": " + str( GameCore.Player.GetStatisticValue( statName ) ))
		if statName == "Health":
			newNode.set_icon(0, preload("res://Textures/Misc/Health.png") )

	for statName in GameCore.Player.GetMainAttributes():
		newNode = get_node("CharacterSheet/TabContainer/Statistics").create_item(mainAttributes)
		newNode.set_text(0,statName + ": " + str( GameCore.Player.GetStatisticValue( statName ) ))
		if statName == "Intelligence":
			newNode.set_icon(0, preload("res://Textures/Misc/Intelligence.png") )
		elif statName == "Dexterity":
			newNode.set_icon(0, preload("res://Textures/Misc/Dexterity.png") )
		elif statName == "Strength":
			newNode.set_icon(0, preload("res://Textures/Misc/Strength.png") )
		elif statName == "Willpower":
			newNode.set_icon(0, preload("res://Textures/Misc/Willpower.png") )

	for statName in GameCore.Player.GetSecondaryAttributes():
		newNode = get_node("CharacterSheet/TabContainer/Statistics").create_item(secondaryAttributes)
		if statName == "Experience":
			if GameCore.Player.GetIdentityLevel() != 5:
				newNode.set_text(0,statName + ": " + str( GameCore.Player.GetStatisticValue( statName ) - Core_Database.Levels[ GameCore.Player.GetIdentityLevel() ]["XP"] ) + "/" + str (Core_Database.Levels[ GameCore.Player.GetIdentityLevel()+1 ]["XP"]) )
			else:
				newNode.set_text(0,statName + ": Maximum" )
			newNode.set_icon(0, preload("res://Textures/Misc/Xp.png") )
		else:
			newNode.set_text(0,statName + ": " + str( GameCore.Player.GetStatisticValue( statName ) ))
			

func LoadSkills():
	get_node("CharacterSheet/TabContainer/SkillBook").clear()
	
	var SkillDatabase = []
	
	var SFile = File.new()
	var exists = SFile.file_exists("res://Configuration/skills.bcfg")
	
	var loadedSkillFile = ConfigFile.new()
	if ( exists ):
		loadedSkillFile.load("res://Configuration/skills.bcfg")
		var sections = loadedSkillFile.get_sections()
		for section in sections:
			
			var section_keys = loadedSkillFile.get_section_keys(section)
			
			#Create a skill and put it in the SkillsDatabase
			var Skill = { } #Dictionary
			Skill["Name"] = section 
			for skillData in section_keys:
				Skill[skillData] = loadedSkillFile.get_value(section,skillData)
			
			SkillDatabase.append(Skill)
	
	#Set skill treeroot
	var SkillTreeRoot = get_node("CharacterSheet/TabContainer/SkillBook").create_item()
	get_node("CharacterSheet/TabContainer/SkillBook").set_hide_root(true)
	get_node("CharacterSheet/TabContainer/SkillBook").set_columns(2)
	var Physical = get_node("CharacterSheet/TabContainer/SkillBook").create_item(SkillTreeRoot)
	Physical.set_text(0,"Physical skills")
	Physical.set_selectable(0,false)
	var Magic = get_node("CharacterSheet/TabContainer/SkillBook").create_item(SkillTreeRoot)
	Magic.set_text(0,"Magic skills")
	Magic.set_selectable(0,false)
	
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
			var Skill
			if skill["Type"] == "Magic":
					Skill = get_node("CharacterSheet/TabContainer/SkillBook").create_item(Magic)
					Skill.set_text(0,skill["Name"].replace("_"," ") )
					Skill.set_text(1,"Accuracy: " + str(skill["Accuracy"]) + "  Damage: " + str(skill["Damage"]) )
					Skill.set_selectable(0,false)
			elif skill["Type"] == "Physical":
					Skill = get_node("CharacterSheet/TabContainer/SkillBook").create_item(Physical)
					Skill.set_text(0,skill["Name"].replace("_"," ") )
					Skill.set_text(1,"Accuracy: " + str(skill["Accuracy"]) + "  Damage: " + str(skill["Damage"]) )
					Skill.set_selectable(0,false)