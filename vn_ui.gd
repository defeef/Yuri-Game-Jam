extends Control

var file
var lines = []
@onready var current_line = 0

@onready var label = $"MarginContainer/VBoxContainer/HudBar/RichTextLabel"
@onready var img1 = $"MarginContainer/VBoxContainer/Scene/VBoxContainer/TextureRect"
@onready var img2 = $"MarginContainer/VBoxContainer/Scene/VBoxContainer2/TextureRect"
const sprite_size = Vector2(128, 128)

func _ready():
	file = FileAccess.open("res://test_script.txt", 1)
	while not file.eof_reached():
		var line = file.get_line()
		lines.append(line)
	file.close()

var img1_org
var img2_org
var setup = false

var offset_vec = Vector2.ZERO
var img_frame_count = 0
var img_frame_total = 9
var img_fade_mult = 2

var curr_img
var curr_img_org

var chars = 0
func _process(delta):
	if (not setup):
		img1_org = img1.global_position
		img2_org = img2.global_position
		change_page(0)
		setup = true
	if (Input.is_action_just_pressed("next")):
		if (label.visible_ratio < 1.0):
			label.visible_ratio = 1
		else:
			change_page(1)
	if (Input.is_action_just_pressed("back")):
		change_page(-1)
	chars += ((5 if Input.is_action_pressed("next") else 1) * 20) * delta
	label.visible_characters = chars
	if (label.visible_ratio < 1.0):
		if (img_frame_count == 0):
			offset_vec = Vector2(randf_range(-1, 1), randf_range(-0.5, 1)).normalized() * 4
			curr_img.modulate.a = 1.0
		if (curr_img_org != null):
			if (img_frame_count < (img_frame_total / 3.0)):
				var offset = lerp(Vector2.ZERO, offset_vec, img_frame_count / (img_frame_total / 3.0))
				curr_img.global_position = curr_img_org + offset
			else:
				var offset = lerp(curr_img.global_position - curr_img_org, Vector2.ZERO, (img_frame_count - (img_frame_total / 3.0)) / (2.0 * img_frame_total / 3.0))
				curr_img.global_position = curr_img_org + offset
	#if (img_frame_count < 0):
		#curr_img.modulate.a = 
		#print(img_frame_count)
		#print(abs((2 * img_frame_count + img_frame_total * img_fade_mult) / float(img_frame_total)) / float(img_fade_mult))
		#print()
		#img_frame_count += 1
	#else:
		#img_frame_count = (img_frame_count + 1) % img_frame_total

func change_page(offset: int):
	if (current_line + offset < 0):
		return
	img_frame_count = 0
	chars = 0
	current_line += offset
	label.text = lines[current_line]
	if (label.text == "<<END>>"):
		current_line = 0
		label.text = lines[0]
	if (label.text[0] == "["):
		var end = label.text.find("]")
		update_sprite(label.text.substr(1, end - 1))

var characters_on_screen = [null, null]
func update_sprite(key: String):
	var info = key.split("-")
	
	var curr_side_is_left = true if (info[0] == "L") else false
	var character = info[1]
	var expression = info[2] if info.size() > 2 else "DEFAULT"
	
	var sheet = load("res://characters/" + character + ".png")
	
	curr_img = img1 if curr_side_is_left else img2
	curr_img_org = img1_org if curr_side_is_left else img2_org
	
	if (character not in characters_on_screen):
		print("new character")
		if (characters_on_screen[0 if curr_side_is_left else 1] == null):
			print("first time character")
			#img_frame_count = -img_frame_total * img_fade_mult / 2
		#else:
			#img_frame_count = -img_frame_total * img_fade_mult
	
	# STOP TRYING TO FADE IN/OUT
	characters_on_screen[0 if curr_side_is_left else 1] = character
	
	var curr_tex: AtlasTexture = curr_img.texture
	curr_tex.atlas = sheet
	curr_tex.region = Rect2(expression_lookup[expression] * sprite_size.x, 0, sprite_size.x, sprite_size.y)

const expression_lookup = {
	"DEFAULT": 0,
	"HAPPY": 1,
	"ANGRY": 2
}
