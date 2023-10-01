extends VBoxContainer

var height_from

func _ready():
	height_from = get_parent().get_node("VBoxContainer/Scene")

func _process(delta):
	size.y = height_from.size.y
