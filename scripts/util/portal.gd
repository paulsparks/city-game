extends Area3D
class_name Portal


@export_file("*.tscn") var destination: String

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		get_tree().call_deferred("change_scene_to_file", destination)
