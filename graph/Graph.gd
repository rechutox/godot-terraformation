extends GraphEdit

export(NodePath) var view3d_node


var _available_nodes = {
    Inputs = [
        "res://graph/nodes/inputs/image_file/Input.tscn",
        "res://graph/nodes/inputs/simplex_noise/Input.tscn",
        "res://graph/nodes/inputs/cellular_noise/Input.tscn",
    ],
    Filters = [
        "res://graph/nodes/filters/blend/Filter.tscn",
        "res://graph/nodes/filters/adjust/Filter.tscn",
        "res://graph/nodes/filters/curve/Filter.tscn",
        "res://graph/nodes/filters/blur/Filter.tscn",
        "res://graph/nodes/filters/invert/Filter.tscn",
        "res://graph/nodes/filters/mask/Filter.tscn",
        "res://graph/nodes/filters/flatten_area/Filter.tscn",
        "res://graph/nodes/filters/select_height/Filter.tscn",
    ],
    Outputs = [
        "res://graph/nodes/outputs/export_image/Output.tscn",
    ],
   }

var _nodes := {}
var _popup_offset := Vector2()
var _view3d


func _ready() -> void:
    _view3d = get_node(view3d_node)
    _populate_popup_menu()
    connect("popup_request", self, "_open_popup")
    connect("connection_request", self, "_on_connection_requested")
    connect("disconnection_request", self, "_on_disconnection_requested")
    $Preview3D.connect("output_changed", self, "_on_preview3d_output_changed")
    $Preview3D.offset = rect_size * 0.5
    $PopupMenu.connect("id_pressed", self, "_popup_id_pressed")


func _populate_popup_menu():
    var popup = $PopupMenu
    var index = 0
    for section_name in _available_nodes:
        var section = _available_nodes[section_name]
        popup.add_separator(section_name)
        index += 1
        for i in range(section.size()):
            var pack = load(section[i])
            _nodes[index] = pack
            popup.add_item(pack.get_state().get_node_name(0), index)
            index += 1


func _on_connection_requested(from: String, from_slot: int, to: String, to_slot: int) -> void:
    add_connection(from, from_slot, to, to_slot)


func _on_disconnection_requested(from: String, from_port: int, to: String, to_port: int) -> void:
    remove_connection(from, from_port, to, to_port)


func add_connection(from: String, from_port: int, to: String, to_port: int) -> void:
    var err = connect_node(from, from_port, to, to_port)
    if err == OK:
        var node_from = get_node(from) as XGraphNode
        node_from._output_connected(from_port)


func remove_connection(from: String, from_port: int, to: String, to_port: int) -> void:
    disconnect_node(from, from_port, to, to_port)
    var node_from = get_node(from) as XGraphNode
    var node_to = get_node(to) as XGraphNode
    node_to._input_disconnected(to_port)


func add_node(node: XGraphNode) -> void:
    add_child(node, true)
    node.set_owner(self)
    node.connect("output_changed", self, "_on_node_output_changed")
    node.connect("close_request", self, "_on_close_node_requested", [node])


func remove_node(node: XGraphNode) -> void:
    for conn in get_connection_list():
        if conn.from == node.name:
            disconnect_node(conn.from, conn.from_port, conn.to, conn.to_port)
    node.queue_free()


func node_has_connection_to(from: String, to: String) -> bool:
    for conn in get_connection_list():
        if conn.from == from:
            if conn.to == to:
                return true
    return false


func clear_nodes() -> void:
    clear_connections()
    for child in get_children():
        var node = child as XGraphNode
        if node != null:
            node.free()


func _on_node_output_changed(from, from_port, value):
    for conn in get_connection_list():
        if conn.from == from:
            if conn.from_port == from_port:
                var node_to = get_node(conn.to)
                node_to._input_changed(conn.to_port, value)


func _on_preview3d_output_changed(from, from_port, texture):
    _view3d.set_heightmap(texture)


func _open_popup(pos: Vector2) -> void:
    _popup_offset = get_local_mouse_position()
    $PopupMenu.rect_position = pos
    $PopupMenu.popup()


func _popup_id_pressed(id: int) -> void:
    var node = _nodes[id].instance() as XGraphNode
    if node != null:
        add_node(node)
        node.offset = _popup_offset + scroll_offset


func _on_close_node_requested(node: XGraphNode) -> void:
    remove_node(node)


func get_data_dict() -> Dictionary:
    var data = {}

    data.scroll_offset = var2str(scroll_offset)
    data.zoom = zoom
    data.use_snap = use_snap
    data.snap_distance = snap_distance
    data.connections = get_connection_list()

    data.nodes = {}
    for child in get_children():
        var node = child as XGraphNode
        if node != null:
            var node_data = {}
            node_data.name = node.name
            node_data.filename = node.filename
            node_data.config = node.get_data_dict()
            data.nodes[node.name] = node_data

    return data


func load_data(data: Dictionary) -> void:
    clear_nodes()

    scroll_offset = str2var(data.scroll_offset)
    zoom = data.zoom
    use_snap = data.use_snap
    snap_distance = data.snap_distance

    var instanced_nodes = {}
    for connection in data.connections:
        # Instance them
        if not connection.from in instanced_nodes:
            var node_data = data.nodes[connection.from]
            var node = load(node_data.filename).instance() as XGraphNode
            node.name = node_data.name
            node.call_deferred("load_data", node_data.config)
            instanced_nodes[connection.from] = node
            add_node(node)

        if not connection.to in instanced_nodes:
            var node_data = data.nodes[connection.to]
            var node = load(node_data.filename).instance() as XGraphNode
            node.name = node_data.name
            node.call_deferred("load_data", node_data.config)
            instanced_nodes[connection.to] = node
            add_node(node)

        # Connect them
        add_connection(connection.from, connection.from_port, connection.to, connection.to_port)

    # instance orphan nodes
    for node_name in data.nodes:
        if not node_name in instanced_nodes:
            var node_data = data.nodes[node_name]
            var node = load(node_data.filename).instance() as XGraphNode
            node.call_deferred("load_data", node_data.config)
            instanced_nodes[node_name] = node
            add_node(node)

    # Connect the preview3d output node
    $Preview3D.connect("output_changed", self, "_on_preview3d_output_changed")
