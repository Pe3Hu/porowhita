extends MarginContainer


#region vars
@onready var gameboard = $HBox/VBox/Gameboard

var pantheon = null
var planet = null
var opponents = []
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	pantheon = input_.pantheon
	
	init_basic_setting()


func init_basic_setting() -> void:
	var input = {}
	input.god = self
	gameboard.set_attributes(input)
#endregion


func pick_opponent() -> MarginContainer:
	var opponent = opponents.pick_random()
	return opponent


func concede_defeat() -> void:
	planet.loser = self
