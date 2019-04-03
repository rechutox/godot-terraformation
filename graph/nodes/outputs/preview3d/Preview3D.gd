extends XGraphNode

var _input = null


#warning-ignore:unused_argument
func get_slot_value(slot: int) -> Object:
    return _input


func _ready() -> void:
    _apply_changes()


func _apply_changes() -> void:
    _notify_changes()

func _on_control_value_changed(value: Object, control: Node = null) -> void:
    _apply_changes()

#warning-ignore:unused_argument
func _input_disconnected(slot: int) -> void:
    _input = Texture.new()
    _apply_changes()


#warning-ignore:unused_argument
func _on_input_changed(slot: int, value: Object = null) -> void:
    _input = value
    _apply_changes()


func _update_viewport() -> void:
    return
