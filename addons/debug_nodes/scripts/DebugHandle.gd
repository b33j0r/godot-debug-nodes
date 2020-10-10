tool
extends MeshInstance

signal origin_changed(origin)

var parent: Spatial
var last_origin: Vector3 = Vector3.INF

func _ready():
	if get_parent() is Viewport:
		parent = null
		return
	parent = get_parent()
	if not parent.has_method("attach_handle"):
		push_warning((
			"%s %s must be a child of a DebugSpatial " +
			"(parent %s %s has no %s method)"
			) % [name, self, parent.name, parent, "attach_handle"]
		)
		return
	parent.attach_handle(self)

func _exit_tree():
	if not parent:
		return
	if not parent.has_method("detach_handle"):
		push_warning((
			"%s %s must be a child of a DebugSpatial " +
			"(parent %s %s has no %s method)"
			) % [name, self, parent.name, parent, "detach_handle"]
		)
		return
	parent.detach_handle(self)
	parent = null

func _process(_delta):
	if (
		not parent or
		last_origin.is_equal_approx(transform.origin)
	):
		return
	last_origin = transform.origin
	emit_signal("origin_changed", transform.origin)

func _on_style_changed():
	if not parent:
		return
	var style: DebugArrowStyle = parent.style
	self.scale = Vector3(style.scale, style.scale, style.scale)
