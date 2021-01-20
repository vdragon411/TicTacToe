extends StaticBody

var board = null
var pos = Vector2()
var locked = false
var val = null

func link(brd):
	board = brd
	connect("mouse_entered",board,"tile_mouse_entered",[self])

func _process(delta):
	var p = get_viewport().get_camera().unproject_position(Vector3((pos.x-1)*2,(pos.y-1)*2,0))
	$Label.set_text(str(pos))
	$Label.rect_position = p

func _ready():
	$Cross/MeshInstance.material_override = $Cross/MeshInstance.material_override.duplicate()
	$Cross/MeshInstance2.material_override = $Cross/MeshInstance.material_override.duplicate()
	$Zero/CSGCombiner2/CSGTorus.material = $Zero/CSGCombiner2/CSGTorus.material.duplicate()


func cross():
	val=1
	$Zero.hide()
	$Cross.show()
	$Tween.interpolate_property($Cross/MeshInstance.material_override,":albedo_color:a",0,1,0.8,Tween.TRANS_BOUNCE,Tween.EASE_IN)
	$Tween.interpolate_property($Cross/MeshInstance2.material_override,":albedo_color:a",0,1,0.8,Tween.TRANS_BOUNCE,Tween.EASE_IN)
	$Tween.start()
	$Cross/Particles.emitting=true
func zero():
	val=2
	$Cross.hide()
	$Zero.show()
	$Tween.interpolate_property($Zero/CSGCombiner2/CSGTorus.material,":albedo_color:a",0,1,0.8,Tween.TRANS_BOUNCE,Tween.EASE_IN)
	$Tween.start()
	$Zero/Particles.emitting=true
func empty():
	val=0
	$Cross.hide()
	$Zero.hide()
