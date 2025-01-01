@tool
extends Node

signal change_scene(scene: Node)
signal queue_scene(scene: Node)
signal advance_scene_queue
#signal add_data(key: StringName, value: Variant)

# Area Events

signal garden_entered(garden: Garden)
signal race_entered(race: Race, first_waypoint: Waypoint)

#region Schedule

signal schedule_activity(activity: Activity)

#endregion Schedule

#region Race

signal race_started
signal race_finished(race: Race)

#endregion Race
