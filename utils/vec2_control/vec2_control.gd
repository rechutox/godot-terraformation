extends HBoxContainer
class_name Vec2Control, "./icon.svg"

signal value_changed(vector2)

#warning-ignore:unused_class_variable
export(Vector2) var value = Vector2(0.0, 0.0) setget set_value, get_value

export(NodePath) var x_control_node
export(NodePath) var y_control_node


func set_value(val: Vector2):
    var x_control = get_node(x_control_node)
    if x_control != null:
        x_control.value = val.x
    var y_control = get_node(y_control_node)
    if y_control != null:
        y_control.value = val.y


func get_value():
    var x_control = get_node(x_control_node)
    var y_control = get_node(y_control_node)
    if x_control != null and y_control != null:
        return Vector2(x_control.value, y_control.value)
    return Vector2()

func _ready() -> void:
    var x_control = get_node(x_control_node)
    var y_control = get_node(y_control_node)
    if x_control != null and y_control != null:
        x_control.connect("value_changed", self, "_on_value_changed")
        y_control.connect("value_changed", self, "_on_value_changed")
    else:
        assert("You must add two children and add them as controls!")

#warning-ignore:unused_argument
func _on_value_changed(val):
    emit_signal("value_changed", get_value())
