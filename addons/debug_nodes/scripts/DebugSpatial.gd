tool
extends Spatial
class_name DebugSpatial

var _dirty = false

func _ready():
	_update_deferred()

func _update_deferred():
	_sync_handle()
	if _dirty:
		return
	_dirty = true
	call_deferred("_update_and_clear_dirty")

func _update_and_clear_dirty():
	if not _dirty:
		return
	_update()
	_dirty = false

func _update():
	pass

func _sync_handle():
	pass
