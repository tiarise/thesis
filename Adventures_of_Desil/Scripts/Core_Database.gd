extends Node

#--------Dialog section--------
var DialogDatabase = [] #Dialog database
var CompletedDialogNodes =  [] 
var BattleDetails = {} # Example: NPCName : NPC-1, DialogNode : ID-6 , BattleWon : true, false
var DialogFolder = "res://Dialogs/"

#--------Dialog section--------


# Experience thresholds.
var Levels =  { 1: { "XP" : 0 },  2:  { "XP" : 45 }, 3 :  { "XP" : 100 }, 4:  { "XP" : 160 }, 5 :  { "XP" : 225 } }

#Unfortunatley Gd-Script doesn't support multiple line commands.
var EnemySkillDatabase = {  "Bozz":  ["Punch","Body_slam","Sword_swing"] , "Velrath":  ["Punch","Puncture_with_dagger","Sword_swing"] , "Belkor":  ["Spark","Energy_ball","Ignite"], "Gywenne":  ["Rift_cut","Flame_tornado","Mind_break"]   }
