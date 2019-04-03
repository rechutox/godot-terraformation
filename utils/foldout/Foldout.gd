tool
extends Control

signal fold_changed(state)

#warning-ignore:unused_variable
export var title := "Untitled" setget set_title
export var is_folded := false setget set_folded

const CONTROL_NAME := "__FoldoutButton__"
var _is_ready := false


func set_title(text):
    title = text
    _update_controls()


func set_folded(value):
    is_folded = value
    _update_controls()
    emit_signal("fold_changed", is_folded)


func toggle() -> void:
    self.is_folded = !is_folded


func _ready() -> void:
    _is_ready = true
    yield(get_tree().create_timer(0.06), "timeout")
    _update_controls()


func _enter_tree() -> void:
    _update_controls()


func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if not event.pressed:
            var ctrl = get_node_or_null(CONTROL_NAME)
            if ctrl != null:
                if ctrl.get_rect().has_point(event.position):
                    toggle()


func _update_controls():
    if not Engine.editor_hint and not _is_ready: return
    var ctrl = get_node_or_null(CONTROL_NAME)
    if ctrl != null:
        ctrl.get_node_or_null("Title").text = title
        ctrl.get_node_or_null("IconFolded").visible = is_folded
        ctrl.get_node_or_null("IconUnfolded").visible = !is_folded
    for child in get_children():
        if child.name != CONTROL_NAME:
            child.visible = !is_folded
    #rect_size.y = get_minimum_size().y
    #var parent = get_parent_control()
    #if parent != null:
    #    if parent.size_flags_vertical != SIZE_EXPAND_FILL:
    #        parent.rect_size.y = parent.get_minimum_size().y
    #        parent = parent.get_parent_control()
