@tool
extends EditorScript


func _run() -> void:
	print("Running...")
	print("💤".unicode_at(0))
	var scene: Node = get_scene()
	print(scene.get_node("%Tweak").screen)
	#var name_label: Label = scene.name_label
	#for but: Node in scene.main_buttons.get_buttons():
		#but.remove_from_group(&"MainButton")
	#print(Signal(name_label, Animator.SIGNAL_FINISHED))
	#print(Tween.interpolate_value(Transform2D(), Transform2D(0.0, Vector2.ONE*2.0, 0.0, Vector2(100, 100)), 0.5, 1.0, Tween.TRANS_BACK, Tween.EASE_IN_OUT))
