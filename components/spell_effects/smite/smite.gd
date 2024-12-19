class_name Smite extends Node2D

@export var animation_player: AnimationPlayer

signal hit_collided

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("cast")

func emit_hit_collided():
	hit_collided.emit()
