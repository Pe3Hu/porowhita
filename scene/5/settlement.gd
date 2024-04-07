extends MarginContainer


#region vars
@onready var index = $Index

var policy = null
var community = null
var area = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	policy = input_.policy
	area = input_.area

	init_basic_setting()


func init_basic_setting() -> void:
	init_tokens()
	area.settlement = self
	area.region.settlements.append(self)
	area.index.visible = true


func init_tokens() -> void:
	var input = {}
	input.proprietor = self
	input.type = "index"
	input.subtype = "settlement"
	input.value = area.index.get_value()
	index.set_attributes(input)
#endregion
