class_name Portal
extends Area3D

@export_file("*.tscn") var destination: String


func _on_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		get_tree().call_deferred("change_scene_to_file", destination)

		for node: Node in body.get_children():
			match node:
				node when node is WalletComponent:
					var wallet: WalletComponent = node
					PlayerData.money = wallet.get_money()
				node when node is InventoryComponent:
					var inventory: InventoryComponent = node
					PlayerData.inventory_items = inventory.get_inventory_ids()

		PlayerData.save()
