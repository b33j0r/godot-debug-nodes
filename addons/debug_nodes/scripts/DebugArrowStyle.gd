tool
extends Resource
class_name DebugArrowStyle

signal style_changed()

export(Color) var color = Color.red setget set_color
export(float) var shaft_radius = 1 setget set_shaft_radius
export(float) var tip_radius = 2 setget set_tip_radius
export(float) var tip_height = 4 setget set_tip_height
export(float) var scale = 0.05 setget set_scale

var _parent: Spatial

func _ready():
	emit_signal("style_changed")

func set_color(value):
	color = value
	emit_signal("style_changed")

func set_shaft_radius(value):
	shaft_radius = value
	emit_signal("style_changed")

func set_tip_radius(value):
	tip_radius = value
	emit_signal("style_changed")

func set_tip_height(value):
	tip_height = value
	emit_signal("style_changed")

func set_scale(value):
	scale = value
	emit_signal("style_changed")
