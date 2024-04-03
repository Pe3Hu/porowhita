extends MarginContainer


@onready var cradle = $HBox/Cradle
@onready var universe = $HBox/Universe


func _ready() -> void:
	var input = {}
	input.sketch = self
	cradle.set_attributes(input)
	universe.set_attributes(input)
	
	var planet = universe.planets.get_child(0)
	
	var god = cradle.pantheons.get_child(0).gods.get_child(0)
	planet.add_god(god)
	
	#god = cradle.pantheons.get_child(1).gods.get_child(0)
	#planet.add_god(god)
	
	planet.start_race()
