@tool
class_name ActivityResult extends RefCounted

var outcome: int = -1

var fatigue_delta: int = -999
var deltas: Dictionary[String, int] = {}

func get_outcome_string() -> String:
	match outcome:
		1: "Success"
		2: "Failure"
	return ""
