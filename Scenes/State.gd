extends Node
class_name State

signal transitioned ( state , new_state_name )

 # Executed once upon entering the state
func enter () -> void :
	pass

 # Executed once before leaving the state
func exit () -> void :
	pass

 # Frame - dependent updates ( Input polling )
func update ( _delta : float ) -> void :
	pass

 # Physics - dependent updates ( Vector math )
func physics_update ( _delta : float ) -> void :
	pass
