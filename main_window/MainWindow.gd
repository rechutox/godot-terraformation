extends PanelContainer

onready var _file_dialog = $FileDialog


func _ready() -> void:
    $FileDialog.access = FileDialog.ACCESS_FILESYSTEM
    $FileDialog.filters = [ "*.json ; JSON project definition" ]
    $VBox/MarginContainer/HBoxContainer/FileMenuButton.get_popup().connect("id_pressed", self, "_on_file_menu_id_pressed")
    $VBox/MarginContainer/HBoxContainer/HelpMenuButton.get_popup().connect("id_pressed", self, "_on_help_menu_id_pressed")


func _on_file_menu_id_pressed(id) -> void:
    match id:
        0:
            $ConfirmationDialog.dialog_text = "Are you sure? All unsaved changes will be lost."
            $ConfirmationDialog.popup_centered()
            yield($ConfirmationDialog, "confirmed")
            get_tree().reload_current_scene()
        1:
            save_project()
        2:
            load_project()
        4:
            get_tree().quit()


func _on_help_menu_id_pressed(id) -> void:
    match id:
        0: $AboutDialog.popup_centered()


func save_project() -> void:
    # Ensure the projects dir exists
    #var dir = Directory.new()
    #if !dir.dir_exists("user://projects"):
    #    dir.open("user://")
    #    dir.make_dir("user://projects")

    #$FileDialog.current_dir = "user://projects"
    $FileDialog.mode = FileDialog.MODE_SAVE_FILE
    $FileDialog.popup_centered_ratio()

    var path = yield($FileDialog, "file_selected")
    prints("Save filepath:", path)

    var data = {
        graph_data = $VBox/HSplitContainer/Graph.get_data_dict()
       }

    var file = File.new()
    file.open(path, File.WRITE)
    file.store_string(JSON.print(data, " "))

func load_project():
    #$FileDialog.current_dir = "user://projects"
    $FileDialog.mode = FileDialog.MODE_OPEN_FILE
    $FileDialog.popup_centered_ratio()

    var path = yield($FileDialog, "file_selected")
    prints("Load file path:", path)

    var file = File.new()
    var err = file.open(path, File.READ)
    if err != OK:
        push_error("Can't open the file: %.0f" % err)
        return

    var parse_result = JSON.parse(file.get_as_text())
    if parse_result.error != OK:
        push_error(parse_result.error_string)
        return

    var data = parse_result.result

    $VBox/HSplitContainer/Graph.load_data(data.graph_data)