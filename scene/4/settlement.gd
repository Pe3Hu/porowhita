extends Node2D


#region vars
var mainland = null
var area = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	mainland = input_.mainland
	area = input_.area

	init_basic_setting()


func init_basic_setting() -> void:
	area.color = Color.BLACK
	area.settlement = self
	area.region.settlements.append(self)
