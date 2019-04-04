extends XGraphNode

onready var _preview = $PreviewFoldout/Preview
onready var _load_button = $LoadButton

var _file_path: String
var _texture := ImageTexture.new()
var _open_file_dialog := FileDialog.new()
var _ext_filters = [
    "*.png;PNG Image",
    "*.jpg;JPG Image",
]


#warning-ignore:unused_argument
func get_port_value(port: int):
    return _texture


func get_data_dict() -> Dictionary:
    return {
        node_offset = var2str(offset),
        file_path = _file_path,
       }


func load_data(data: Dictionary) -> void:
    offset = str2var(data.node_offset)
    _file_path = data.file_path
    _apply_changes()


func _ready() -> void:
    _open_file_dialog.window_title = "Select an image file"
    _open_file_dialog.resizable = true
    _open_file_dialog.filters = _ext_filters
    _open_file_dialog.mode = FileDialog.MODE_OPEN_FILE
    _open_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
    get_tree().root.add_child(_open_file_dialog)

    _load_button.connect("pressed", self, "_on_load_button_pressed")
    $PreviewFoldout.connect("fold_changed", self, "_on_foldout_changed")
    _apply_changes()


func _exit_tree() -> void:
    get_tree().root.remove_child(_open_file_dialog)


func _apply_changes():
    var img = Image.new()
    var err = img.load(_file_path)
    if err == OK:
        _texture.create_from_image(img)
    _update_viewport()
    _notify_changes()


func _on_load_button_pressed():
    _open_file_dialog.popup_centered_ratio()
    _file_path = yield(_open_file_dialog, "file_selected")
    _apply_changes()


func _update_viewport():
    _preview.texture = _texture


func _on_foldout_changed(is_folded):
    rect_size.y = 0
