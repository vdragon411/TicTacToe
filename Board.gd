extends Spatial

var block = preload("res://Block.tscn")
var tiles = {}

var winning_patterns = [
	[Vector2(0,0),Vector2(1,0),Vector2(2,0)],
	[Vector2(0,1),Vector2(1,1),Vector2(2,1)],
	[Vector2(0,2),Vector2(1,2),Vector2(2,2)],
	
	[Vector2(0,0),Vector2(0,1),Vector2(0,2)],
	[Vector2(1,0),Vector2(1,1),Vector2(1,2)],
	[Vector2(2,0),Vector2(2,1),Vector2(2,2)],
	
	[Vector2(0,0),Vector2(1,1),Vector2(2,2)],
	[Vector2(2,0),Vector2(1,1),Vector2(0,2)],
]

func _ready():
	$RetryButton.hide()
	#OS.window_fullscreen=true
	$StateLabel.set_text(" ")
	$StateLabel.set_text("Your Turn")
	for x in range(0,3):
		for y in range(0,3):
			var b = block.instance()
			tiles[Vector2(x,y)] = b
			b.empty()
			b.pos = Vector2(x,y)
			add_child(b)
			b.link(self)
			b.translation = Vector3(x-1,y-1,0)*2.4


func check_full():
	for v in tiles.values():
		if not v.val:
			return false
	return true

func check_win():
	var which=0
	var index=0
	for wp in winning_patterns:
		var flag=false
		for i in range(1,3):
			if (tiles[wp[0]].val == tiles[wp[1]].val) and (tiles[wp[1]].val == tiles[wp[2]].val) and (tiles[wp[0]].val==i):
				flag=true
				which=i
				break
		if flag:
			index = winning_patterns.find(wp)
			break
	if which:
		print(which," won!")
	return [which,index]

func play(pos):
	if turn == 1:
		tiles[pos].cross()
	else:
		tiles[pos].zero()
	toggle_turn()


func ai_play():
	var opponent
	if turn==1:
		opponent=2
	else:
		opponent=1
	var pos
	var flag = true
	
	####OFFENSE DEFENSE
	var offensive=false
	for i in range(1,3):
		if i==2:
			offensive=true
		if not flag:
			break
		for wp in winning_patterns:
			if (tiles[wp[1]].val == tiles[wp[0]].val) and tiles[wp[1]].val!=0:
				if not tiles[wp[2]].val:
					if not offensive and tiles[wp[1]].val==opponent:
						continue
					pos = wp[2]
					flag=false
					if tiles[wp[1]].val==opponent:
						print("offense",pos)
					else:
						print("def",pos)
					break
			elif (tiles[wp[1]].val == tiles[wp[2]].val) and tiles[wp[1]].val!=0:
				if not tiles[wp[0]].val:
					if not offensive and tiles[wp[1]].val==opponent:
						continue
					pos = wp[0]
					flag=false
					if tiles[wp[1]].val==opponent:
						print("offense",pos)
					else:
						print("def",pos)
					break
			elif (tiles[wp[0]].val == tiles[wp[2]].val) and tiles[wp[0]].val!=0:
				if not tiles[wp[1]].val:
					if not offensive and tiles[wp[0]].val==opponent:
						continue
					pos = wp[1]
					flag=false
					if tiles[wp[0]].val==opponent:
						print("offense",pos)
					else:
						print("def",pos)
					break
	####NEAREST
	while flag:
		randomize()
		var t = []
		for x in range(0,3):
			for y in range(0,3):
				t.append(Vector2(x,y))
		var tt = []
		var tile
		for k in tiles.keys():
			if tiles[k].val==1:
				tt.empty()
				var f = false
				for x in range(-1,2):
					for y in range(-1,2):
						var v = k+Vector2(x,y)
						if tiles.keys().has(v):
							if not tiles[v].val:
								tt.append(v)
								f=true
							else:
								print(v, " is not empty")
				if f:
					var r = randi()%tt.size()
					flag=false
					print(tt)
					pos = tt[r]
					break
	###RANDOM
	while flag:
		randomize()
		var r = randi()%tiles.values().size()
		pos = tiles.keys()[r]
		if not tiles[pos].val:
			flag=false
			print("rand")
	if not flag:
		play(pos)
	else:
		print("oof")

var pos_hover=null
func tile_mouse_entered(block):
	pos_hover=block.pos
	#block.cross()
var turn = 1
func toggle_turn():
	if turn==1:
		turn=2
	else:
		turn=1

func reset():
	turn=1
	gameover=false
	$StateLabel.set_text("Your Turn")
	for v in tiles.values():
		v.empty()


var ai_playing=false
var gameover=false
func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode==KEY_R:
			reset();
	if event is InputEventMouseButton:
		if event.pressed and (not check_full()) and (not ai_playing) and (not tiles[pos_hover].val) and not gameover:
			$StateLabel.set_text("Your Turn")
			#print("State ",pos_hover," ",turn)
			if not tiles[pos_hover].val:
				play(pos_hover)
				#print("player ",pos_hover)
			var w = check_win()
			if w[0]==1:
				$StateLabel.set_text("You Win!")
				$RetryButton.show();
				gameover=true
			elif w[0]==2:
				$StateLabel.set_text("You Lost :c")
				gameover=true
				$RetryButton.show();
			else:
				if check_full():
					$StateLabel.set_text("StaleMate")
					$RetryButton.show();
			if not w[0]>0 and not check_full():
				ai_playing=true
				$StateLabel.set_text("Waiting...")
				yield(get_tree().create_timer(1),"timeout")
				ai_play()
				w = check_win()
				if w[0]==1:
					$StateLabel.set_text("You Win!")
					$RetryButton.show();
					gameover=true
				elif w[0]==2:
					$StateLabel.set_text("You Lost :c")
					$RetryButton.show();
					gameover=true
				else:
					$StateLabel.set_text("Your Turn")
				ai_playing=false



func _process(delta):
	#$StateLabel.set_text(str(pos_hover))
	pass


func _on_RetryButton_pressed():
	reset();
	$RetryButton.hide()
