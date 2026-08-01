extends Node2D

var AI
var GameCore
var Enemy
var SummaryScreen
var BattleLog
var Turn = 1 #1 or 2

var playerDamageDealt = 0
var enemyDamageDealt = 0
var playerAccuracy = 0.0 #This is a number, that is incremented at every successfull hit. Then this will be divided with overall turns.
var enemyAccuracy= 0.0
var overallTurns = 1.0
var GameEnded = false

var intelligenceBonusMultiplierPlayer = 1
var intelligenceBonusMultiplierEnemy = 1

func _ready():
	GameCore = get_node("/root/GameCore")
	SummaryScreen = get_node("/root/SceneRoot/SummaryScreen/BattleSummary")
	AI = get_node("/root/SceneRoot/Mechanics/AI")
	BattleLog = get_node("/root/SceneRoot/UI/BattleLog")
	
	BattleLog.newline()
	BattleLog.add_text("For more information about skills, hover over them!")
	BattleLog.newline()
	BattleLog.add_text("Battle commencing!")
	BattleLog.newline()
	
	#Generate Enemy Identity(C++ Framework)
	Enemy = Identity_Bridge.new()
	Enemy.SetName(Core_Database.BattleDetails["NPCName"])
	#For this config templates must be present in the project folder
	Enemy.SetFaction(Core_Database.BattleDetails["NPCName"])#Now the template is faction template
	Enemy.SetupDefaultStatistics()
	Enemy.SetupStatisticsModifiers()
	
	#Set health labels:
	var HealthValue = Enemy.GetStatisticValue("Health")
	var MaxHealthValue = Enemy.GetVitalMaxValue("Health")
	get_node("/root/SceneRoot/UI/EnemyHealthLabel").set_text(Enemy.GetName() + " Health: " + str(MaxHealthValue) + "/" + str(HealthValue) )
	
	HealthValue = GameCore.Player.GetStatisticValue("Health")
	MaxHealthValue = GameCore.Player.GetVitalMaxValue("Health")
	get_node("/root/SceneRoot/UI/PlayerHealthLabel").set_text("Desil Health: " + str(MaxHealthValue) + "/" + str(HealthValue) )
	
	#Check for intelligence bonus for each party
	if( Enemy.GetStatisticValue("Intelligence")*1.5 < GameCore.Player.GetStatisticValue("Intelligence") ):
		BattleLog.add_text("Desil has Intelligence bonus over "+ Core_Database.BattleDetails["NPCName"] + ", all damage is multiplied by 1.5!")
		intelligenceBonusMultiplierPlayer = 1.5
		BattleLog.newline()

	if( Enemy.GetStatisticValue("Intelligence") >  GameCore.Player.GetStatisticValue("Intelligence")*1.5 ):
		BattleLog.add_text(Core_Database.BattleDetails["NPCName"] +" has Intelligence bonus over Desil, all damage is multiplied by 1.5!")
		intelligenceBonusMultiplierEnemy = 1.5
		BattleLog.newline()
	
	
	BattleLog.newline()
	
	#Set Life bars
	get_node("/root/SceneRoot/UI/PlayerHealth").set_val(100)
	get_node("/root/SceneRoot/UI/EnemyHealth").set_val(100)
	
func _Skill_Pressed(SkillName):
	if( Turn == 1 ):
		#Update Turn label
		get_node("/root/SceneRoot/UI/TurnLabel").set_text("Turn: " + str(overallTurns))
		
		#Player will be displayed as Green.
		BattleLog.add_text("Player turn:") # this is still white.
		BattleLog.newline()
		BattleLog.push_color(Color(0,1,0,1))
		
		if( Enemy.GetStatisticValue("Dexterity") > GameCore.Player.GetStatisticValue("Dexterity")*2):
			BattleLog.add_text("Player Missed!(Dexterity far too low!)")
			BattleLog.newline()
		
		else:
			if ( AccuracyCheck(SkillName) ):
				#Adjust counters and apply damage.
				playerDamageDealt = playerDamageDealt + GetDataOfSkill(SkillName,"Damage")
				playerAccuracy = playerAccuracy +1
				ApplyDamage(SkillName)
			else:
				BattleLog.add_text("Player Missed!")
				BattleLog.newline()
		Turn = 2
		#We now delete the green color.
		BattleLog.pop()
		
		if !GameEnded:
			#We set the proces to true so the AI can react.
			set_process(true)
		
#Generates a random scenario where the skill may or may not hit based on it's accuracy.
func AccuracyCheck(SkillName):
	
	var accuracy = GetDataOfSkill(SkillName,"Accuracy")
	
	randomize()
	var randomNumber = randi() % (11) #0-10
	var corrected_randomNumber = randomNumber/10.0
	if  ( accuracy == 0.0 ):
		return false
	elif ( accuracy == 1.0 ):
		return true
	elif( corrected_randomNumber  <= accuracy  ): # 0.1-0.9
		return true
	else:
		return false
		
func GetDataOfSkill(SkillName,Data):
	var Database = get_node("/root/SceneRoot").SkillDatabase
	for skill in Database:
		if(skill["Name"] == SkillName):
			return skill[Data]
			
func ApplyDamage(SkillName):
	var intelligenceBonusActive = false
	
	if( Turn == 1):
		var dmg = GetDataOfSkill(SkillName,"Damage") * intelligenceBonusMultiplierPlayer
		
		Enemy.SetDamageToVital("Health",dmg)
		var HealthValue = Enemy.GetStatisticValue("Health")
		var MaxHealthValue = Enemy.GetVitalMaxValue("Health")
		var newEnemyPercentage = HealthValue/MaxHealthValue*100
		get_node("/root/SceneRoot/UI/EnemyHealth").set_value(newEnemyPercentage)
		get_node("/root/SceneRoot/UI/EnemyHealthLabel").set_text(Enemy.GetName() + " Health: " + str(MaxHealthValue) + "/" + str(HealthValue) )
		
		BattleLog.add_text("Player hit for " + str(dmg)  + " damage with " +  SkillName.replace("_"," ")  + " skill!")
		BattleLog.newline()
		CheckForEndGame()
		
	elif( Turn == 2):
		var dmg = GetDataOfSkill(SkillName,"Damage") *intelligenceBonusMultiplierEnemy
		
		
		GameCore.Player.SetDamageToVital("Health",dmg)
		var HealthValue = GameCore.Player.GetStatisticValue("Health")
		var MaxHealthValue = GameCore.Player.GetVitalMaxValue("Health")
		var newEnemyPercentage = HealthValue/MaxHealthValue*100
		get_node("/root/SceneRoot/UI/PlayerHealth").set_value(newEnemyPercentage)
		get_node("/root/SceneRoot/UI/PlayerHealthLabel").set_text("Desil Health: " + str(MaxHealthValue) + "/" + str(HealthValue) )
		
		get_node("/root/SceneRoot/UI/BattleLog").add_text("Enemy hit for " + str(dmg)  + " damage with " +  SkillName.replace("_"," ")  + " skill!")
		get_node("/root/SceneRoot/UI/BattleLog").newline()
		

func _process(delta):
	
	#If it's the AI's turn
	if( Turn == 2 ):
		var Skill
		
		BattleLog.add_text("Enemy Turn:")
		BattleLog.push_color(Color(1,0,0,1))
		BattleLog.newline()

		
		if( GameCore.Player.GetStatisticValue("Dexterity") > Enemy.GetStatisticValue("Dexterity")*2):
			BattleLog.add_text("Enemy Missed!(Dexterity far too low!)")
			BattleLog.newline()
			
		else:
			#AI choses a skill
			Skill = get_node("/root/SceneRoot/Mechanics/AI").Get_ReactSkill_DefaultAI()
			if ( AccuracyCheck(Skill["Name"]) ):
				#Adjust counters and apply damage.
				enemyDamageDealt = enemyDamageDealt + Skill["Damage"]
				enemyAccuracy = enemyAccuracy +1 #Increment the accuracy counter
				ApplyDamage(Skill["Name"])
			else:
				BattleLog.add_text("Enemy Missed!")
				BattleLog.newline()
		
		#Set turn number  and turn counter 
		overallTurns = overallTurns +1
		BattleLog.pop() # Remove red color.
		Turn = 1
		CheckForEndGame()
		set_process(false)

func CheckForEndGame():
	if ( get_node("/root/SceneRoot/UI/PlayerHealth").get_value() <=0 ):
		Core_Database.BattleDetails["BattleWon"] = false
		set_process(false)
		GameEnded = true
		ShowResults()

	elif( get_node("/root/SceneRoot/UI/EnemyHealth").get_value() <= 0 ):
		Core_Database.BattleDetails["BattleWon"] = true
		set_process(false)
		GameEnded = true
		GameCore.SetCurrentBattleToCompleted() #Set true for the corresponding dictionary setion.
		ShowResults()
		

func ShowResults():
	if Core_Database.BattleDetails["BattleWon"] == true:
		SummaryScreen.get_node("VBoxContainer/Result").set_text("Victory!")
	else:
		SummaryScreen.get_node("VBoxContainer/Result").set_text("Defeat!")
	
	SummaryScreen.get_node("VBoxContainer/Details/PlayerBattleStatistic/Name").set_text( "Name: " + GameCore.Player.GetName() )
	SummaryScreen.get_node("VBoxContainer/Details/PlayerBattleStatistic/DamageDealt").set_text( "Damage dealt: " + str(playerDamageDealt) )
	SummaryScreen.get_node("VBoxContainer/Details/PlayerBattleStatistic/Accuracy").set_text( "Overall accuracy: " + str( ((playerAccuracy/overallTurns)*100 )).substr(0,4) + " % " )
	
	SummaryScreen.get_node("VBoxContainer/Details/EnemyBattleStatistic/Name").set_text( "Name: " +  Enemy.GetName() )
	SummaryScreen.get_node("VBoxContainer/Details/EnemyBattleStatistic/DamageDealt").set_text( "Damage dealt: " + str(enemyDamageDealt))
	SummaryScreen.get_node("VBoxContainer/Details/EnemyBattleStatistic/Accuracy").set_text( "Overall accuracy: " +  str( ((enemyAccuracy/overallTurns)*100 )).substr(0,4) + " % " )
	
	GameCore.PutInTheMiddle(SummaryScreen) 
	SummaryScreen.grab_click_focus()
	SummaryScreen.grab_focus()
	SummaryScreen.popup()
	