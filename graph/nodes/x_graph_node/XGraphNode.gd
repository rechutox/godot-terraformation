extends GraphNode
class_name XGraphNode, "./x_graph_node_icon.svg"

signal output_changed(slot, value)

var SHADER_WAIT_TIME := 0.1

"""
TODO
The node will send a signal with port_changed to the GraphEdit
and it will call _on_input_changed() on every connected
node with from_port = port_changed
"""


# Retuns the slot return value.
# Usually this will be:
# return $viewport.get_texture()
#warning-ignore:unused_argument
func get_slot_value(slot: int) -> Object:
    assert(false)
    return null


# Returns the serialized data to save
func get_data_dict() -> Dictionary:
    return {
        node_offset = var2str(offset)
       }


# Load the serialized data
func load_data(data: Dictionary) -> void:
    offset = str2var(data.node_offset)


# Send parameters to the shader and update the viewport
# Notifying changes after a short delay
func _apply_changes() -> void:
    _update_viewport()
    yield(_wait_for_shader(), "completed")
    _notify_changes()

# Utility to connect several control to it
# You can leave it and fetch the control values in _apply_changes()
# or do other things and cache the values.
# You cam connect them as follow:
# control.connect("value_changed", self, "_on_control_value_changed", [control])
#warning-ignore:unused_argument
func _on_control_value_changed(value: Object, control: Node = null) -> void:
    _apply_changes()


# Implement this!
# Matching function with the output_changed signal
# Basically, you check what slot has changed and do something
# with the value. You probably need to cache the value here
# and use it in _apply_cahnges().
#warning-ignore:unused_argument
func _on_input_changed(slot: int, value: Object = null) -> void:
    _apply_changes()


# This will be called when a slot is disconected.
# This is used to update the node and the children.
# You can leave it as it for root type nodes.
#warning-ignore:unused_argument
func _input_disconnected(slot: int) -> void:
    _apply_changes()

# This will be called when a new connection is created on an
# output slot. This is used to update the connected node.
# You can leave it as it.
#warning-ignore:unused_argument
func _output_connected(slot: int) -> void:
    _notify_changes(slot, get_slot_value(slot))

# This helper emit the signal to update the connected node
# on the specified slot
func _notify_changes(slot: int = 0, value: Object = null) -> void:
    if value == null: value = get_slot_value(slot)
    emit_signal("output_changed", slot, value)

# This must update the viewport.
# Usually for performance reasons, the viewport will be configured with
# render_target_update_mode = Viewport.UPDATE_ONCE
# So here you fetch your viewport and do something like this:
# $viewport.render_target_update_mode = Viewport.UPDATE_ONCE
# This will trigger the rendering in the shader and update the
# preview viewport_texture.
func _update_viewport() -> void:
    assert(false)


# Utility to wait for the shader to update the texture.
# Depending on the complexity of the shader you can decrease
# or increment the SHADER_WAIT_TIME value to keep the outputs
# in sync.
func _wait_for_shader() -> void:
    yield(get_tree().create_timer(SHADER_WAIT_TIME), "timeout")
