@tool
class_name StatsHandler extends Node

var stats: Stats

func init(stats: Stats) -> StatsHandler:
	self.stats = stats
	stats.connect_signal("fatigue", "points", _on_fatigue_change)
	stats.connect_signal("stress", "points", _on_stress_change)
	stats.connect_signal("hunger", "points", _on_hunger_change)
	return self



func _on_fatigue_change(stat: StringName, delta: int) -> void:
	pass

func _on_stress_change(stat: StringName, delta: int) -> void:
	pass

func _on_hunger_change(stat: StringName, delta: int) -> void:
	pass
