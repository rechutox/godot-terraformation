extends MarginContainer

export(NodePath) var view3d_node

onready var _terrain_size_control = $VBox/Grid/TerrainSizeControl
onready var _terrain_subdivisions_control = $VBox/Grid/TerrainSubdivisionsControl

var _view3d


func _ready() -> void:
    _view3d = get_node(view3d_node)
    _terrain_size_control.connect("value_changed", self, "_on_terrain_size_changed")
    _terrain_subdivisions_control.connect("value_changed", self, "_on_terrain_subdivisions_changed")


func _on_terrain_size_changed(value):
    _view3d.set_terrain_size(value)


func _on_terrain_subdivisions_changed(value):
    _view3d.set_terrain_subdivisions(value)
