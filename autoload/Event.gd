@tool
extends Node


signal interaction_started(pet: Pet)
signal interaction_ended

# Area Events

signal garden_entered(garden: Garden)
signal race_entered(race: Race, first_waypoint: Waypoint)

#region Schedule

signal schedule_activity(activity: Exercise)

#endregion Schedule

#region Race

signal race_started
signal race_finished(race: Race)

#endregion Race
