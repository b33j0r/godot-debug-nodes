tool
extends MeshInstance

signal handle_origin_changed(origin)

var parent: Spatial
var last_origin: Vector3 = Vector3.INF

func _enter_tree():
	if get_parent() is Viewport:
		parent = null
		return
	parent = get_parent()
	if not parent:
		return
	parent.style.connect("style_changed", self, "_on_style_changed")
	connect("handle_origin_changed", parent, "_on_handle_origin_changed")

func _exit_tree():
	if not parent:
		return
	parent.style.disconnect("style_changed", self, "_on_style_changed")
	disconnect("handle_origin_changed", parent, "_on_handle_origin_changed")

func _ready():
	if not parent:
		return
	transform.origin = parent.vector
	_on_style_changed()

func _process(_delta):
	if not parent or last_origin.is_equal_approx(transform.origin):
		return
	last_origin = transform.origin
	emit_signal("handle_origin_changed", transform.origin / parent.vector_scale)

func _on_style_changed():
	if not parent:
		return
	var style: DebugArrowStyle = parent.style
	self.scale = Vector3(style.scale, style.scale, style.scale)
