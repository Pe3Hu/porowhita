extends MarginContainer


#region var
@onready var pantheons = $Pantheons

var sketch = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	sketch = input_.sketch
	
	init_basic_setting()


func init_basic_setting() -> void:
	
	init_pantheons()


func init_pantheons() -> void:
	for _i in 1:
		var input = {}
		input.cradle = self
	
		var pantheon = Global.scene.pantheon.instantiate()
		pantheons.add_child(pantheon)
		pantheon.set_attributes(input)
#endregion
