extends Node2D


func _ready():
	set_process(true) #To check all the time if animationplayer is playing
	
func _process(delta):
	if !get_node("AnimationPlayer").is_playing():
		get_node("AnimationPlayer").play("RotateSprite")
	if get_node("Sprite").is_visible():
		if get_node("Area2D").get_overlapping_bodies().size() > 0:
			
			#If you go into trap curse is triggered
			ApplyStatDebuff()
			get_node("/root/SceneRoot/PlayerAndUI/UI/CharacterSheet").LoadSkills()
			
			if GameCore.Player.GetEquipmentList().has("Magic Ring") == false: #If the magic ring is present.
				print("Detect")
				get_node("/root/SceneRoot/GameEffects/TrapLight").set("visibility/visible",true)
				get_node("/root/SceneRoot/GameEffects/TrapLight").set_pos( get_node("/root/SceneRoot/PlayerAndUI/Player").get_pos() )
				get_node("/root/GameCore").PlayerInTrap = true
				
				#we will simulate a click
				var trapDestination = InputEvent()
				trapDestination.type = InputEvent.MOUSE_BUTTON
				trapDestination.button_index = 2
				trapDestination.x = 0
				trapDestination.y = 0 
				get_node("/root/SceneRoot/NavigationSurfaces/PlayerNavigation")._input(trapDestination)

			else:
				print("Magic Ring detected! Trap physical effects nullified!")

func StartTrap(time):
	get_node("Timer").set_wait_time(time)
	get_node("Timer").start()
	

func ApplyStatDebuff():
	if !get_node("/root/SceneRoot/WorldEvents/QuestManager").IsQuestAtive("I. The curse"):
		get_node("/root/SceneRoot/WorldEvents/QuestManager").CheckForQuestActivationByAreaTrigger("I. The curse")
		get_node("/root/GameCore").Player.ChangeStatisticBaseValueBy("Health",-20)
		get_node("/root/SceneRoot/PlayerAndUI/UI/CharacterSheet").PopulateCharacterSheet()

func _on_Timer_timeout():
	if get_node("Sprite").is_visible():
		get_node("Sprite").set("visibility/visible",false)
		get_node("/root/SceneRoot/GameEffects/TrapLight").set("visibility/visible",false)
		get_node("/root/GameCore").PlayerInTrap = false
		get_node("Timer").start()
	else:
		get_node("Sprite").set("visibility/visible",true)
		get_node("Timer").start()
