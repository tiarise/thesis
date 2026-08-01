extends Node2D


func _on_MarketDiscovery_body_enter( body ):
	get_node("/root/SceneRoot/WorldEvents/QuestManager").CheckForQuestAdvancementInAreaTrigger("The_Market")
