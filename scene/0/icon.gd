extends MarginContainer


#region vars
@onready var bg = $BG
@onready var number = $Number
@onready var text = $Text
@onready var textureRect = $TextureRect

var type = null
var subtype = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	type = input_.type
	subtype = input_.subtype
	
	init_basic_setting()


func init_basic_setting() -> void:
	custom_minimum_size = Vector2(Global.vec.size.sixteen)
	var exceptions = ["number", "string"]
	
	if !exceptions.has(type):
		#custom_minimum_size = Vector2(Global.vec.size[type])
		update_image()
	
	match type:
		"number":
			textureRect.visible = false
			number.visible = true
			set_number(subtype)
		"string":
			textureRect.visible = false
			text.visible = true
			text.text = subtype
			custom_minimum_size = Vector2(Global.vec.size.number)


func update_image() -> void:
	if !textureRect.visible:
		number.visible = false
		textureRect.visible = true
	
	var path = "res://asset/png/"
	path += type + "/" + str(subtype) + ".png"
	textureRect.texture = load(path)
	
	#var style = StyleBoxFlat.new()
	#style.bg_color = Color.SLATE_GRAY
	#bg.set("theme_override_styles/panel", style)
#endregion


#region number treatment
func get_number() -> Variant:
	return subtype


func change_number(value_) -> void:
	subtype += value_
	var value = 0
	
	match typeof(subtype):
		TYPE_INT:
			value = int(subtype)
			var suffix = ""
			
			while value >= 1000:
				value /= 1000
				suffix = Global.dict.thousand[suffix]
			
			number.text = str(value) + suffix
		TYPE_FLOAT:
			value = float(subtype)
			value = snapped(value, 0.1)
			number.text = str(value)


func set_number(value_) -> void:
	subtype = value_
	var value = float(subtype) + 0
	
	match typeof(value_):
		TYPE_INT:
			var suffix = ""
			
			while value >= 1000:
				value /= 1000
				suffix = Global.dict.thousand[suffix]
			
			number.text = str(value) + suffix
		TYPE_FLOAT:
			value = snapped(value, 0.1)
			number.text = str(value)
#endregion

