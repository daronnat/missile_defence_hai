extends Popup

var lifetime = null
var i_delta = 0

func _ready():
	start(3,"testo")

func start(duration,text,color=Color(0,0,0,1)):
	$PopupPanel/Label.text  = text
	$PopupPanel/Label.set("custom_colors/font_color",color)
	lifetime = 5
	display_popup()

func _process(delta):
	if lifetime != null:
		i_delta+=delta
	elif i_delta > lifetime:
		lifetime = null
		delete_popup()

func display_popup():
	self.popup()
	$display.interpolate_property(self, "rect_scale",
		Vector2(0,0), self.rect_scale, 1,
		Tween.TRANS_EXPO, Tween.EASE_IN,0)
	$display.start()

func _on_display_tween_completed(object, key):
	pass

func delete_popup():
	$delete.interpolate_property(self, "rect_scale",
		self.rect_scale, Vector2(0,0), 1.5,
		Tween.TRANS_BACK, Tween.EASE_IN,0)
	$delete.start()

func _on_delete_tween_completed(object, key):
	queue_free()
