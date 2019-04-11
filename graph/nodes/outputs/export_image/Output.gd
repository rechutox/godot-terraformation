extends XGraphNode

onready var _preview = $PreviewFoldout/Preview
onready var _dialog_button = $ExportButton

var _file_dialog = FileDialog.new()
var _input: Texture = null


func _ready() -> void:
    _file_dialog.mode = FileDialog.MODE_SAVE_FILE
    _file_dialog.filters = [ "*.png ; PNG file" ]
    _file_dialog.access = FileDialog.ACCESS_FILESYSTEM
    _dialog_button.connect("pressed", self, "_on_export_button_pressed")
    get_tree().root.add_child(_file_dialog)
    _apply_changes()


func _on_export_button_pressed():
    _file_dialog.popup_centered_ratio()
    yield(_file_dialog, "confirmed")
    _input.get_data().save_png(_file_dialog.current_path)

func _apply_changes() -> void:
    _update_viewport()
    yield(_wait_for_shader(), "completed")
    _notify_changes()


#warning-ignore:unused_argument
func _input_disconnected(port: int) -> void:
    _input = null
    _apply_changes()


#warning-ignore:unused_argument
func _input_changed(port: int, value: Object = null) -> void:
    _input = value
    _apply_changes()


func _update_viewport() -> void:
    _preview.texture = _input


func get_data_dict() -> Dictionary:
    return {
        node_offset = var2str(offset),
        preview_folded = $PreviewFoldout.is_folded,
       }


func load_data(data: Dictionary) -> void:
    offset = str2var(data.node_offset)
    $PreviewFoldout.is_folded = data.preview_folded
