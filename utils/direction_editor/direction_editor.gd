extends Control

signal value_changed

onready var angle_control = $HBox/Center/AngleSpinBox
onready var direction_control = $HBox/DirectionControl


func get_vector():  return direction_control.get_vector()
func get_radians(): return direction_control.get_radians()
func get_degrees(): return direction_control.get_degrees()

func _ready() -> void:
    angle_control.connect("value_changed", self, "_on_angle_value_changed")
    direction_control.connect("value_changed", self, "_on_direction_value_changed")

func _on_angle_value_changed(val):
    direction_control.angle = deg2rad(val)
    emit_signal("value_changed", direction_control.angle)

func _on_direction_value_changed(val):
    angle_control.value = rad2deg(val)
    emit_signal("value_changed", direction_control.angle)