extends MarginContainer


#region var
@onready var bg = $BG

var planet = null
var grid = null
var type = null
var terrain = null
var veins = {}
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	planet = input_.planet
	grid = input_.grid
	type = input_.type
	
	init_basic_setting()


func init_basic_setting() -> void:
	custom_minimum_size = Global.vec.size.area
	var style = StyleBoxFlat.new()
	style.bg_color = Color.SLATE_GRAY
	bg.set("theme_override_styles/panel", style)


func set_terrain(terrain_: String) -> void:
	terrain = terrain_
	
	var style = bg.get("theme_override_styles/panel")
	style.bg_color = Global.color.terrain[terrain]

#endregion
