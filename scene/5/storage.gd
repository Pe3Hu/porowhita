extends MarginContainer


#region vars
@onready var aspects = $Aspects

var gameboard = null
var market = null
var subtypes = {}
var priorities = {}
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	gameboard = input_.gameboard
	
	init_basic_setting()


func init_basic_setting() -> void:
	init_aspects()


func init_aspects() -> void:
	for subtype in Global.arr.aspect:
		add_aspect(subtype)


func add_aspect(subtype_: String) -> void:
	var input = {}
	input.proprietor = self
	input.type = "aspect"
	input.subtype = subtype_
	input.value = 0

	var token = Global.scene.token.instantiate()
	aspects.add_child(token)
	token.set_attributes(input)
	
	subtypes[subtype_] = token
	priorities[subtype_] = 1
	Global.rng.randomize()
	priorities[subtype_] += Global.rng.randf_range(0, 1)
#endregion


func obtain_aspect(aspect_: MarginContainer) -> void:
	var aspect = subtypes[aspect_.subtype]
	var value = aspect_.get_value()
	aspect.change_value(value)


func reset() -> void:
	for aspect in aspects.get_children():
		aspect.set_value(0)


#region market
func merchandising() -> void:
	for card in market.cards.get_children():
		if card.selected:
			card.set_selected(false)
	
	var datas = []
	var budget = subtypes["gold"].get_value()
	var constituents = market.get_all_constituents(budget)
	
	for constituent in constituents:
		var data = {}
		data.constituent = constituent
		data.appraisal = 0
		
		for card in constituent:
			data.appraisal += evaluate_card(card)
		
		datas.append(data)
	
	if datas.size() > 0:
		datas.sort_custom(func(a, b): return a.appraisal > b.appraisal)
		var constituent = datas.front().constituent
		
		for card in constituent:
			card.set_selected(true)


func evaluate_card(card_: MarginContainer) -> float:
	var appraisal = 0.0
	
	for aspect in card_.aspects.get_children():
		var value = aspect.get_value() * priorities[aspect.subtype]
		appraisal += value
	
	return appraisal


func payment() -> void:
	var datas = []
	
	for card in market.cards.get_children():
		if card.selected:
			var data = {}
			data.card = card
			data.appraisal = evaluate_card(card) 
			datas.append(data)
	
	if datas.size() > 0:
		datas.sort_custom(func(a, b): return a.appraisal > b.appraisal)
		
		var options = []
		
		for data in datas:
			if datas.front().appraisal == data.appraisal:
				options.append(data.card)
		
		var card = options.pick_random()
		market.card_delivery(card, gameboard)
		var gold = subtypes["gold"]
		var value = -card.cost.get_value()
		gold.change_value(value)
#endregion


func onslaught() -> void:
	var value = subtypes["power"].get_value()
	var opponent = gameboard.god.pick_opponent()
	opponent.core.get_damage(value)
