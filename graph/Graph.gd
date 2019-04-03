extends GraphEdit

export(NodePath) var view3d_node

onready var _preview3d_output = $Preview3D

var _available_nodes = {
    Inputs = [
        "res://graph/nodes/inputs/image_file/ImageFile.tscn",
        "res://graph/nodes/inputs/simplex_noise/SimplexNoise.tscn",
        "res://graph/nodes/inputs/cellular_noise/CellularNoise.tscn",
    ],
    Filters = [
        "res://graph/nodes/filters/template/FilterTemplate.tscn",
        "res://graph/nodes/filters/mix/MixFilter.tscn",
    ]
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
    _preview3d_output.connect("output_changed", self, "_on_preview3d_output_changed")
    $PopupMenu.connect("id_pressed", self, "_popup_id_pressed")
    $Toolbar/FileMenuButton.get_popup().connect("id_pressed", self, "_file_menu_id_pressed")


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


func _on_disconnection_requested(from: String, from_slot: int, to: String, to_slot: int) -> void:
    disconnect_node(from, from_slot, to, to_slot)
    var node_from = get_node(from) as XGraphNode
    var node_to = get_node(to) as XGraphNode
    # check if is last connection
    if not node_has_connection_to(from, to):
        node_from.disconnect("output_changed", node_to, "_on_input_changed")
    node_to._input_disconnected(to_slot)


func node_has_connection_to(from: String, to: String) -> bool:
    for conn in get_connection_list():
        if conn.from == from:
            if conn.to == to:
                return true
    return false


func _on_connection_requested(from: String, from_slot: int, to: String, to_slot: int) -> void:
    add_connection(from, from_slot, to, to_slot)


func _open_popup(pos: Vector2) -> void:
    _popup_offset = get_local_mouse_position()
    $PopupMenu.rect_position = pos
    $PopupMenu.popup()


func _popup_id_pressed(id: int) -> void:
    var node = _nodes[id].instance() as XGraphNode
    if node != null:
        add_node(node)
        node.offset = _popup_offset + scroll_offset


func _file_menu_id_pressed(id: int) -> void:
    match id:
        0:
            save_project()
        1:
            load_project()


func _on_preview3d_output_changed(slot, texture):
    _view3d.set_heightmap(texture)


func add_node(node: XGraphNode) -> void:
    add_child(node, true)
    node.connect("close_request", self, "_on_close_node_requested", [node])
    node.set_owner(self)

var _cache = {}

func add_connection(from: String, from_port: int, to: String, to_port: int) -> void:
    var err = connect_node(from, from_port, to, to_port)
    if err == OK:
        var node_from = get_node(from) as XGraphNode
        var node_to = get_node(to) as XGraphNode
        if not from in _cache:
            _cache[from] = {}
        if not from_port in _cache[from]:
            _cache[from][from_port] = {}
        if not to in _cache[from][from_port]:
            _cache[from][from_port][to] = []
        _cache[from][from_port][to].append(to_port)
        node_from.connect("output_changed", self, "_on_node_output_changed")
        #node_from._output_connected(from_port)

func _on_node_output_changed(from, from_port, value):
    for to in _cache[from][from_port]:
        var node_to = get_node(to) as XGraphNode
        node_to._input_changed(from_port, value)
    pass

func save_project() -> void:
    print("Saving...")

    var dir = Directory.new()
    if !dir.dir_exists("user://projects"):
        dir.open("user://")
        dir.make_dir("user://projects")

    var file = File.new()
    file.open("user://projects/save_test.project", File.WRITE)

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

    file.store_string(JSON.print(data, " "))

    print("Saved!")


func load_project() -> void:
    print("Loading...")

    var file = File.new()
    var err = file.open("user://projects/save_test.project", File.READ)
    if err != OK:
        push_error("Can't open the file: %.0f" % err)
        return

    var parse_result = JSON.parse(file.get_as_text())
    if parse_result.error != OK:
        push_error(parse_result.error_string)
        return

    clear_nodes()

    var data = parse_result.result
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

    print("Loaded!")


func clear_nodes() -> void:
    clear_connections()
    for child in get_children():
        var node = child as XGraphNode
        if node != null:
            node.free()


func _on_close_node_requested(node: XGraphNode) -> void:
    node.queue_free()
    update()
