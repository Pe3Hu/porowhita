extends MarginContainer


#region vars
@onready var season = $HBox/Season
@onready var phase = $HBox/Phase
@onready var lap = $HBox/Lap
@onready var order = $HBox/Order

var planet = null
var god = null
var pause = false
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	planet = input_.planet
	
	init_basic_setting()


func init_basic_setting() -> void:
	init_phases()


func init_phases() -> void:
	var input = {}
	input.proprietor = self
	input.type = "season"
	input.subtype = Global.dict.season.phase.keys().back()
	season.set_attributes(input)
	
	input.type = "phase"
	input.subtype = Global.dict.season.phase[season.subtype].back()
	phase.set_attributes(input)
	
	input.type = "moon"
	input.subtype = "lap"
	input.value = 0
	lap.set_attributes(input)
	
	input.subtype = "order"
	order.set_attributes(input)
#endregion


#region phase
func skip_all_phases() -> void:
	for _i in Global.num.phase.n:
		follow_phase()


func follow_phase() -> void:
	if planet.loser == null and !pause:
		next_phase()
		
		var func_name = phase.subtype + "_" + "phase"
		call(func_name)


func next_phase() -> void:
	var phases = Global.dict.season.phase[season.subtype]
	var index = (phases.find(phase.subtype) + 1) % phases.size()
	
	if index == 0:
		next_season()
	else:
		phase.set_subtype(phases[index])


func next_season() -> void:
	var seasons = Global.dict.season.phase.keys()
	var index = (seasons.find(season.subtype) + 1) % seasons.size()
	season.set_subtype(seasons[index])
	
	var phases = Global.dict.season.phase[season.subtype]
	index = 0
	phase.set_subtype(phases[index])
	
	if season.subtype == seasons.front():
		next_order()


func next_order() -> void:
	order.change_value(1)
	
	if planet.gods.size() == (order.get_value() - 1):
		order.set_value(1)
		lap.change_value(1)
	
	var index = order.get_value() - 1
	god = planet.gods[index]


func set_season_and_phase(season_: String, phase_: String) -> void:
	season.set_subtype(season_)
	phase.set_subtype(phase_)


func incoming_phase() -> void:
	god.gameboard.fill_storage()
	#follow_phase()


func selecting_phase() -> void:
	god.gameboard.storage.merchandising()
	follow_phase()


func outcoming_phase() -> void:
	god.gameboard.storage.payment()
	
	if planet.market.get_selected_cards_count() > 0:
		var _season = "spring"
		var _phase = Global.dict.season.phase[_season].back()
		set_season_and_phase(_season, _phase)
	
	follow_phase()


func wounding_phase() -> void:
	god.gameboard.storage.onslaught()
	follow_phase()


func wilting_phase() -> void:
	god.gameboard.discard_hand()
	god.gameboard.storage.reset()
	follow_phase()


func sowing_phase() -> void:
	god.gameboard.refill_hand()
	follow_phase()
#endregion
