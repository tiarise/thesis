
extends Node2D


var mainSize 

var selected_item

#ItemTypes
var Helmet = 0
var Chest = 1
var Gloves = 2
var Trousers = 4
var Boots = 5
var Weapons = 8
var Misc = 11
var Ring = 7

#Tree node types
var B_HelmetRoot
var B_ChestRoot
var B_GlovesRoot
var B_TrousersRoot
var B_BootsRoot
var B_WeaponsRoot
var B_RingsRoot
var B_MiscRoot  #MIsc not equipable ( quest items usually )

var E_HelmetRoot
var E_ChestRoot
var E_GlovesRoot
var E_TrousersRoot
var E_BootsRoot
var E_WeaponsRoot
var E_RingsRoot

func _ready():
	SetInventoryLayout()
	PopulateInventory()

func SetInventoryLayout():
	var Resolution = get_node("/root/GameCore").Video_Resolution
	
	if( Resolution.x == 800 ):
		mainSize = Vector2(480,355)

	elif( Resolution.x == 1366 ):
		mainSize = Vector2(500,385)
		
	
	elif( Resolution.x == 1920 ):
		mainSize = Vector2(600,600)
		
	get_node("Inventory").set_size(Vector2(mainSize.x,mainSize.y))
	get_node("Inventory/TabContainer").set_size(Vector2(mainSize.x,mainSize.y-20))
	get_node("Inventory/Label").set_size(Vector2(mainSize.x,20))
	get_node("Inventory/Label").set_pos(Vector2(0,mainSize.y-20))

func ClearInventroy():
	get_node("Inventory/TabContainer/Bag").clear()
	get_node("Inventory/TabContainer/Equipment").clear()

func PopulateInventory():
	var BagTreeRoot = get_node("Inventory/TabContainer/Bag").create_item()
	var EquipmentTreeRoot = get_node("Inventory/TabContainer/Equipment").create_item()
	get_node("Inventory/TabContainer/Bag").set_hide_root(true)
	get_node("Inventory/TabContainer/Bag").set_columns(2)
	get_node("Inventory/TabContainer/Equipment").set_hide_root(true)
	get_node("Inventory/TabContainer/Equipment").set_columns(2)
	
	#Prepare Bag Tree
	B_HelmetRoot = get_node("Inventory/TabContainer/Bag").create_item(BagTreeRoot)
	B_HelmetRoot.set_text(0,"Helmets")
	B_HelmetRoot.set_icon(0, preload("res://Textures/Misc/Cap.png") )
	B_HelmetRoot.set_selectable(0,false)
	B_HelmetRoot.set_selectable(1,false)
	B_ChestRoot = get_node("Inventory/TabContainer/Bag").create_item(BagTreeRoot)
	B_ChestRoot.set_text(0,"Chests")
	B_ChestRoot.set_icon(0, preload("res://Textures/Misc/Chest.png") )
	B_ChestRoot.set_selectable(0,false)
	B_ChestRoot.set_selectable(1,false)
	B_GlovesRoot = get_node("Inventory/TabContainer/Bag").create_item(BagTreeRoot)
	B_GlovesRoot.set_text(0,"Gloves")
	B_GlovesRoot.set_icon(0, preload("res://Textures/Misc/Gloves.png") )
	B_GlovesRoot.set_selectable(0,false)
	B_GlovesRoot.set_selectable(1,false)
	B_TrousersRoot = get_node("Inventory/TabContainer/Bag").create_item(BagTreeRoot)
	B_TrousersRoot.set_text(0,"Trousers")
	B_TrousersRoot.set_icon(0, preload("res://Textures/Misc/Trousers.png") )
	B_TrousersRoot.set_selectable(0,false)
	B_TrousersRoot.set_selectable(1,false)
	B_BootsRoot = get_node("Inventory/TabContainer/Bag").create_item(BagTreeRoot)
	B_BootsRoot.set_text(0,"Boots")
	B_BootsRoot.set_icon(0, preload("res://Textures/Misc/Boots.png") )
	B_BootsRoot.set_selectable(0,false)
	B_BootsRoot.set_selectable(1,false)
	B_WeaponsRoot = get_node("Inventory/TabContainer/Bag").create_item(BagTreeRoot)
	B_WeaponsRoot.set_text(0,"Weapons")
	B_WeaponsRoot.set_icon(0, preload("res://Textures/Misc/Sword.png") )
	B_WeaponsRoot.set_selectable(0,false)
	B_WeaponsRoot.set_selectable(1,false)
	B_RingsRoot = get_node("Inventory/TabContainer/Bag").create_item(BagTreeRoot)
	B_RingsRoot.set_text(0,"Rings")
	B_RingsRoot.set_icon(0, preload("res://Textures/Misc/Ring.png") )
	B_RingsRoot.set_selectable(0,false)
	B_RingsRoot.set_selectable(1,false)
	B_MiscRoot = get_node("Inventory/TabContainer/Bag").create_item(BagTreeRoot)
	B_MiscRoot.set_text(0,"Misc")
	B_MiscRoot.set_icon(0, preload("res://Textures/Misc/Misc.png") )
	B_MiscRoot.set_selectable(0,false)
	B_MiscRoot.set_selectable(1,false)
	
	#Prepare Equipement tree
	E_HelmetRoot = get_node("Inventory/TabContainer/Equipment").create_item(EquipmentTreeRoot)
	E_HelmetRoot.set_text(0,"Helmets")
	E_HelmetRoot.set_icon(0, preload("res://Textures/Misc/Cap.png") )
	E_HelmetRoot.set_selectable(0,false)
	E_HelmetRoot.set_selectable(1,false)
	E_ChestRoot = get_node("Inventory/TabContainer/Equipment").create_item(EquipmentTreeRoot)
	E_ChestRoot.set_text(0,"Chests")
	E_ChestRoot.set_icon(0, preload("res://Textures/Misc/Chest.png") )
	E_ChestRoot.set_selectable(0,false)
	E_ChestRoot.set_selectable(1,false)
	E_GlovesRoot = get_node("Inventory/TabContainer/Equipment").create_item(EquipmentTreeRoot)
	E_GlovesRoot.set_text(0,"Gloves")
	E_GlovesRoot.set_icon(0, preload("res://Textures/Misc/Gloves.png") )
	E_GlovesRoot.set_selectable(0,false)
	E_GlovesRoot.set_selectable(1,false)
	E_TrousersRoot = get_node("Inventory/TabContainer/Equipment").create_item(EquipmentTreeRoot)
	E_TrousersRoot.set_text(0,"Trousers")
	E_TrousersRoot.set_icon(0, preload("res://Textures/Misc/Trousers.png") )
	E_TrousersRoot.set_selectable(0,false)
	E_TrousersRoot.set_selectable(1,false)
	E_BootsRoot = get_node("Inventory/TabContainer/Equipment").create_item(EquipmentTreeRoot)
	E_BootsRoot.set_text(0,"Boots")
	E_BootsRoot.set_icon(0, preload("res://Textures/Misc/Boots.png") )
	E_BootsRoot.set_selectable(0,false)
	E_BootsRoot.set_selectable(1,false)
	E_WeaponsRoot = get_node("Inventory/TabContainer/Equipment").create_item(EquipmentTreeRoot)
	E_WeaponsRoot.set_text(0,"Weapons")
	E_WeaponsRoot.set_icon(0, preload("res://Textures/Misc/Sword.png") )
	E_WeaponsRoot.set_selectable(0,false)
	E_WeaponsRoot.set_selectable(1,false)
	E_RingsRoot = get_node("Inventory/TabContainer/Equipment").create_item(EquipmentTreeRoot)
	E_RingsRoot.set_text(0,"Rings")
	E_RingsRoot.set_icon(0, preload("res://Textures/Misc/Ring.png") )
	E_RingsRoot.set_selectable(0,false)
	E_RingsRoot.set_selectable(1,false)

	#Prepare Inventory list.
	var inv = GameCore.Player.GetInventoryList()
	var eqip = GameCore.Player.GetEquipmentList()
	
	for i in inv:
		if !GameCore.Player.GetEquipmentList().has(i): #only put it in bag if it is not equipped.
			AddToCorrectPosition(i,"Bag")
	
	for b in eqip:
		AddToCorrectPosition(b,"Equipment")
	
	var a = 1

func AddToCorrectPosition(var itemName, var whereToPut):
		var separator = itemName.find(" ")
		var modifierName = itemName.substr(0,separator )
		var baseItem = itemName.substr(separator+1,itemName.length() )
		
		var whatItModifies = GameCore.Player.GetItemModification(baseItem,modifierName)
		var byHowMuch = GameCore.Player.GetItemModificationValue(baseItem,modifierName)
		
		var numberSign
		if byHowMuch >= 0:
			numberSign = "+"
		else:
			numberSign = ""
		
		
		var type = GameCore.Player.GetItemTypeID(baseItem,modifierName)
		var newNode
		if type == Helmet:
				if whereToPut == "Equipment":
					newNode = get_node("Inventory/TabContainer/Equipment").create_item(E_HelmetRoot)
				else:
					newNode = get_node("Inventory/TabContainer/Bag").create_item(B_HelmetRoot)
				newNode.set_text(0,itemName )
				newNode.set_text(1,"Modifies: " + whatItModifies  + " by " + numberSign + str(byHowMuch))
				newNode.set_selectable(1,false)
			
		elif type == Chest:
				if whereToPut == "Equipment":
					newNode = get_node("Inventory/TabContainer/Equipment").create_item(E_ChestRoot)
				else:
					newNode = get_node("Inventory/TabContainer/Bag").create_item(B_ChestRoot)
				newNode.set_text(0,itemName )
				newNode.set_text(1,"Modifies: " + whatItModifies  + " by " + numberSign + str(byHowMuch))
				newNode.set_selectable(1,false)
			
		elif type == Gloves:
				if whereToPut == "Equipment":
					newNode = get_node("Inventory/TabContainer/Equipment").create_item(E_GlovesRoot)
				else:
					newNode = get_node("Inventory/TabContainer/Bag").create_item(B_GlovesRoot)
				newNode.set_text(0,itemName )
				newNode.set_text(1,"Modifies: " + whatItModifies  + " by " + numberSign + str(byHowMuch))
				newNode.set_selectable(1,false)
			
		elif type == Trousers:
				if whereToPut == "Equipment":
					newNode = get_node("Inventory/TabContainer/Equipment").create_item(E_TrousersRoot)
				else:
					newNode = get_node("Inventory/TabContainer/Bag").create_item(B_TrousersRoot)
				newNode.set_text(0,itemName )
				newNode.set_text(1,"Modifies: " + whatItModifies  + " by " + numberSign + str(byHowMuch))
				newNode.set_selectable(1,false)
			
		elif type == Boots:
				if whereToPut == "Equipment":
					newNode = get_node("Inventory/TabContainer/Equipment").create_item(E_BootsRoot)
				else:
					newNode = get_node("Inventory/TabContainer/Bag").create_item(B_BootsRoot)
				newNode.set_text(0,itemName )
				newNode.set_text(1,"Modifies: " + whatItModifies  + " by " + numberSign + str(byHowMuch))
				newNode.set_selectable(1,false)
			
		elif type == Weapons:
				if whereToPut == "Equipment":
					newNode = get_node("Inventory/TabContainer/Equipment").create_item(E_WeaponsRoot)
				else:
					newNode = get_node("Inventory/TabContainer/Bag").create_item(B_WeaponsRoot)
				newNode.set_text(0,itemName )
				newNode.set_text(1,"Modifies: " + whatItModifies  + " by " + numberSign + str(byHowMuch))
				newNode.set_selectable(1,false)
			
		elif type == Misc:
				if whereToPut == "Equipment":
					print("Misc can't be equipped")
				else:
					newNode = get_node("Inventory/TabContainer/Bag").create_item(B_MiscRoot)
				newNode.set_text(0,itemName )
				newNode.set_text(1,"Modifies: " + whatItModifies  + " by " + numberSign + str(byHowMuch))
				newNode.set_selectable(1,false)
					
		elif type == Ring:
				if whereToPut == "Equipment":
					newNode = get_node("Inventory/TabContainer/Equipment").create_item(E_RingsRoot)
				else:
					newNode = get_node("Inventory/TabContainer/Bag").create_item(B_RingsRoot)
				newNode.set_text(0,itemName )
				newNode.set_text(1,"Modifies: " + whatItModifies  + " by " + numberSign + str(byHowMuch))
				newNode.set_selectable(1,false)
				

func _on_Bag_item_activated():
	var item  = get_node("Inventory/TabContainer/Bag").get_selected()
	if item != null: #No filter like Helpmet is selectable so this is null if not valid item sleceted.
		var item_id  = get_node("Inventory/TabContainer/Bag").get_selected_column()
		#item.deselect(item_id) EZT NE
		selected_item = item
		
		get_node("Inventory/ConfirmationDialog").connect("confirmed",self,"_on_Equip_confirmed")
		get_node("Inventory/ConfirmationDialog").set_text("Will you equip this item?")
		GameCore.PutInTheMiddle( get_node("Inventory/ConfirmationDialog"), get_node("/root/SceneRoot/PlayerAndUI/UI") )
		get_node("Inventory/ConfirmationDialog").set("visibility/visible",true)


func _on_Equip_confirmed():
	var item_name = selected_item.get_text(0) #Layered LeatherChest
	var separator = item_name.find(" ")
	var item_modifier = item_name.substr(0,separator)
	var item_base = item_name.substr(separator+1,item_name.length())


	print("Confirmed Dialog! Equippping: " + item_name)
	

	if GameCore.Player.GetItemLevelRequirement(item_base,item_modifier) <= GameCore.Player.GetIdentityLevel():
		GameCore.Player.EquipItem(item_name)
	else:
		print("Player level too low for item.")
		get_node("Inventory/Label").set_text("Player level is too low!")
		get_node("Inventory/Label").set("custom_colors/font_color",Color(0,1,1,1))
		get_node("WarningTimer").start()
	
	ClearInventroy()
	PopulateInventory()
	get_node("/root/SceneRoot/PlayerAndUI/UI/CharacterSheet").PopulateCharacterSheet()
	get_node("/root/SceneRoot/PlayerAndUI/UI/CharacterSheet").LoadSkills()
	
	get_node("Inventory/ConfirmationDialog").disconnect("confirmed",self,"_on_Equip_confirmed")

func _on_Equipment_item_activated():
	var item  = get_node("Inventory/TabContainer/Equipment").get_selected()
	if item != null:
		var item_id  = get_node("Inventory/TabContainer/Equipment").get_selected_column()
		#item.deselect(item_id)
		selected_item = item
	
		get_node("Inventory/ConfirmationDialog").connect("confirmed",self,"_on_Dequip_confirmed")
		get_node("Inventory/ConfirmationDialog").set_text("Will you dequip this item?")
		GameCore.PutInTheMiddle( get_node("Inventory/ConfirmationDialog"), get_node("/root/SceneRoot/PlayerAndUI/UI") )
		get_node("Inventory/ConfirmationDialog").set("visibility/visible",true)
	
func _on_Dequip_confirmed():
	var item_name = selected_item.get_text(0)

	
	print("Confirmed Dialog! Dequippping: " + item_name)
	

	var boolfordequip = GameCore.Player.DequipItem(item_name)
	
	
	ClearInventroy()
	PopulateInventory()
	get_node("/root/SceneRoot/PlayerAndUI/UI/CharacterSheet").PopulateCharacterSheet()
	get_node("/root/SceneRoot/PlayerAndUI/UI/CharacterSheet").LoadSkills()
	get_node("Inventory/ConfirmationDialog").disconnect("confirmed",self,"_on_Dequip_confirmed")

func _on_WarningTimer_timeout():
	get_node("Inventory/Label").set_text("Click on item for equipping it.")
	get_node("Inventory/Label").set("custom_colors/font_color",Color(1,1,1,1))
	