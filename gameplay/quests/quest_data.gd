class_name QuestData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var objectives: Array[String] = []
@export var rewards: Array[ItemData] = []
