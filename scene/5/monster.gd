extends MarginContainer


#region vars
@onready var omen = $VBox/HBox/Omen
@onready var mouth = $VBox/HBox/Mouth
@onready var rank = $VBox/HBox/Rank
@onready var nucleus = $VBox/Nucleus

var borderland = null
var embodiment = null
var aspects = []
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	borderland = input_.borderland
	embodiment = input_.embodiment

	init_basic_setting(input_)


func init_basic_setting(input_: Dictionary) -> void:
	init_tokens(input_)
	var description = Global.dict.monster.embodiment[embodiment]
	aspects.append_array(description.aspect) 
	aspects.shuffle()
	
	var input = {}
	input.monster = self
	omen.set_attributes(input)
	init_nucleus()


func init_tokens(input_: Dictionary) -> void:
	var input = {}
	input.proprietor = self
	input.type = "alphabet"
	input.subtype = input_.rank
	rank.set_attributes(input)
	
	input.type = "age"
	input.subtype = input_.age
	input.value = input_.month
	mouth.set_attributes(input)


func init_nucleus() -> void:
	var description = Global.dict.growth.rank[rank.subtype]
	var ages = Global.dict.mount.age[mouth.get_value()]
	var points = 0
	points += description.birth
	points += description.mouth * mouth.get_value()
	points += description.age * ages.size()
	
	var input = {}
	input.proprietor = self
	input.priorities = {}
	
	for aspect in Global.arr.aspect:
		input.priorities[aspect] = 1
	
	input.priorities[aspects.front()] += 2
	input.priorities[aspects.back()] += 1
	
	nucleus.set_attributes(input)
	
	var leftovers = 0
	
	for subtype in nucleus.priorities:
		var value = floor(nucleus.priorities[subtype] * points)
		leftovers += value
		nucleus.change_aspect(subtype, value)
	
	points -= leftovers
	nucleus.change_aspect(aspects.front(), points) 
	
	#while points > 0:
		#Global.rng.randomize()
		#var min = int(max(1, points * 0.25))
		#var max = int(points * 0.5)
		#var value = Global.rng.randi_range(min, max)
		#value = min(points, value)
		#
		#points -= value
		#var subtype = Global.get_random_key(nucleus.priorities)
		#nucleus.change_aspect(subtype, value)
