extends MarginContainer


#region vars
@onready var gods = $Gods

var cradle = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	cradle = input_.cradle
	
	init_gods()


func init_gods() -> void:
	for _i in 1:
		var input = {}
		input.pantheon = self
	
		var god = Global.scene.god.instantiate()
		gods.add_child(god)
		god.set_attributes(input)
#endregion
