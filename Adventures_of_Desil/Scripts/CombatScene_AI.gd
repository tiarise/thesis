extends Node2D

var AISkillDatabase
var GameCore

func _ready():
	GameCore = get_node("/root/GameCore")
	Set_SkillDatabase()

func MaxSearchInSkillArrayByAccuracy(Skill_A,Skill_B):
	
	if Skill_A["Accuracy"] < Skill_B["Accuracy"]:
		return true
	else:
		false
		
func MaxSearchInSkillArrayByDamage(Skill_A,Skill_B):

	if Skill_A["Damage"] < Skill_B["Damage"]:
		return true
	else:
		false


func Set_SkillDatabase():
	AISkillDatabase = get_node("/root/SceneRoot").EnemySkillSet
	

func Get_ReactSkill_DefaultAI():
	
	#Nuke tactic ( If player can be one hitted by any skill, this will activate )
	#This will be chosen if is is a viable tactic 
	var PotentialSkillToUse = [] #Here we gather all the skills that would oneshot the player.
	for skill in AISkillDatabase:
		if skill["Damage"] >= GameCore.Player.GetStatisticValue("Health"):
			PotentialSkillToUse.append(skill)
		
	if PotentialSkillToUse.size() > 0: #So if there is a skill that would kill the player...
		var MaxAccuracySkill = PotentialSkillToUse
		MaxAccuracySkill.sort_custom(self,"MaxSearchInSkillArrayByAccuracy")
		
		print("[*] Nuke policy chosen by the AI in this turn.")
		print("[*] AI chosen " + MaxAccuracySkill[MaxAccuracySkill.size()-1]["Name"] + " skill!")
		return MaxAccuracySkill[MaxAccuracySkill.size()-1] #We get the last in the array so the biggest damage value skill.
	
	#If nuke tactic can't be chosen, choose from the other presets.
	else:
		
		randomize()
		var randomNumber = randi() % (9) #0-9
		
		#This will be chosen in 60% of the time.
		if randomNumber >= 0 and randomNumber<= 5:
			print("[*] Accuracy policy chosen by the AI in this turn.")
			
			var MaxAccuracySkill = AISkillDatabase
			MaxAccuracySkill.sort_custom(self,"MaxSearchInSkillArrayByAccuracy")
			
			print("[*] AI chosen " + MaxAccuracySkill[MaxAccuracySkill.size()-1]["Name"] + " skill!")
			return MaxAccuracySkill[MaxAccuracySkill.size()-1]
						
		#This will be chosen with 30% probability.
		elif randomNumber > 5 and randomNumber<= 8:
			print("[*] Random skill policy chosen by the AI in this turn.")
			#Chose a random skill from SillPool
			randomize()
			var randomNumber = randi() % (AISkillDatabase.size()) 
			
			print("[*] AI chosen " + AISkillDatabase[randomNumber]["Name"] + " skill!")
			return AISkillDatabase[randomNumber]
		
		#This will be chosen with 10% probability.
		elif randomNumber == 9:
			print("[*] Highest damage policy chosen by the AI in this turn.")
			#Choose the biggest damage skill from the skillpool.
			var MaxDamageSkill = AISkillDatabase
			MaxDamageSkill.sort_custom(self,"MaxSearchInSkillArrayByDamage")
			
			print("[*] AI chosen " + MaxDamageSkill[MaxDamageSkill.size()-1]["Name"] + " skill!")
			return MaxDamageSkill[MaxDamageSkill.size()-1]
			
		else:
			print("[!] Random number error in Battle_AI_Template")