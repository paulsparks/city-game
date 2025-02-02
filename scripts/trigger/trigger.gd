extends Node3D
class_name Trigger
## Objects that extend Trigger can be interacted with by the player to perform some function.
## Override the perform_task function to give a trigger some functionality.
## Be sure that your CollisionObject3D is in layer 2 for this to work.


## Does nothing unless overridden.
## Override this function in a class extending Trigger to make an object do something on player interaction.
func perform_task() -> bool:
	return true
