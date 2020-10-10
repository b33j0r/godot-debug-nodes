tool
extends DebugSpatial

const default_style = preload("res://addons/debug_nodes/styles/DebugArrowStyle_Default.tres")

export(Vector3) var vector = Vector3.FORWARD setget set_vector
export(float) var vector_scale = 1.0 setget set_vector_scale

export(Resource) var style setget set_style
export(Color) var color = Color.transparent setget set_color

onready var pivot: MeshInstance = $Pivot
onready var shaft: MeshInstance = $Pivot/Shaft
onready var tip: MeshInstance = $Pivot/Shaft/Tip

var _handle: Spatial
var enabled = false

func set_style(value):
	if style:
		style.disconnect("style_changed", self, "_on_style_changed")
	style = value
	if not style.is_connected("style_changed", self, "_on_style_changed"):
		style.connect("style_changed", self, "_on_style_changed")
	_on_style_changed()
	_update_deferred()

func set_vector(value):
	vector = value
	_update_deferred()

func set_vector_scale(value):
	vector_scale = value
	_update_deferred()

func _on_style_changed():
	_update_deferred()

func set_color(value):
	color = value
	_update_deferred()

func _ready():
	if not style:
		style = default_style
	._ready()

func _update():
	if not pivot:
		return
	_update_mesh()
	_update_transform()

func _update_mesh():
	if not style or not pivot:
		return
	var length = self.vector.length() * vector_scale
	var tip_height = style.tip_height * style.scale
	var shaft_height = max(0, length - tip_height)
	var shaft_radius = style.shaft_radius * style.scale
	var tip_radius = style.tip_radius * style.scale
	
	tip.mesh.height = tip_height
	shaft.mesh.height = shaft_height
	shaft.transform.origin.y = shaft_height / 2.0
	tip.transform.origin.y = (shaft_height + tip_height) / 2.0
	
	shaft.mesh.top_radius = shaft_radius
	shaft.mesh.bottom_radius = shaft_radius
	tip.mesh.bottom_radius = tip_radius
	pivot.mesh.radius = shaft_radius
	pivot.mesh.height = shaft_radius * 2.0
	
	var albedo_color = color if color != Color.transparent else style.color
	pivot.material_override.albedo_color = albedo_color
	shaft.material_override.albedo_color = albedo_color
	tip.material_override.albedo_color = albedo_color

func _update_transform():
	pivot.transform.basis = DebugNodes.look_along(vector)

func attach_handle(handle):
	if _handle:
		push_error("attach_handle called without detaching an existing handle first")
		return
	handle.transform.origin = vector * vector_scale
	handle.last_origin = handle.transform.origin
	handle.connect("origin_changed", self, "_on_handle_origin_changed")
	
	style.connect("style_changed", handle, "_on_style_changed")
	style.emit_signal("style_changed")
	
	_handle = handle

func detach_handle(handle):
	if _handle != handle:
		push_error("detach_handle called with a handle that was never attached")
		return
	handle.disconnect("origin_changed", self, "_on_handle_origin_changed")
	style.disconnect("style_changed", handle, "_on_style_changed")
	_handle = null

func _sync_handle():
	if not _handle:
		return
	_handle.set_block_signals(true)
	_handle.transform.origin = self.vector * vector_scale
	_handle.set_block_signals(false)

func _on_handle_origin_changed(origin):
	if _dirty or self.vector.is_equal_approx(origin):
		return
	self.vector = origin / vector_scale
