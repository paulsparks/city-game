extends Area3D
class_name Portal


@export_file("*.tscn") var destination: String

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		get_tree().call_deferred("change_scene_to_file", destination)
		
		for node in body.get_children():
			match node:
				node when node is WalletComponent:
					PlayerData.money = node.get_money()
