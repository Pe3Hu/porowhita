extends MarginContainer


#region var
@onready var planets = $Planets

var sketch = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	sketch = input_.sketch
	
	init_basic_setting()


func init_basic_setting() -> void:
	init_planets()


func init_planets() -> void:
	for _i in 1:
		var input = {}
		input.universe = self
	
		var planet = Global.scene.planet.instantiate()
		planets.add_child(planet)
		planet.set_attributes(input)
#endregion
