extends CharacterBody3D

const SPEED = 5.0

enum State { IDLE, WAITING_TO_MOVE, MOVE }
var state: State = State.IDLE

var idle_wait_time: float = 1.0
var idle_timer_count: float = 0.0

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var target = $"../Target"

func _physics_process(delta):
	
	#custom move
	#var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#velocity = Vector3(input_dir.x, 0, input_dir.y) * 3
	
	#if !is_on_floor():
		#velocity += get_gravity() * delta
	#else:
		#velocity.y = 0
	
	match state:
		State.IDLE:
			_on_idle()
		State.WAITING_TO_MOVE:
			_on_waiting_to_move(delta)
		State.MOVE:
			_on_move()
	
	#print("velocity ", velocity)
	move_and_slide()


func _on_idle():
	print("IDLE")
	velocity = Vector3.ZERO
	idle_timer_count = idle_wait_time
	state = State.WAITING_TO_MOVE


func _on_waiting_to_move(delta: float):
	print("WAITING_TO_MOVE")
	idle_timer_count -= delta
	if idle_timer_count <= 0.0:
		#find a "safe" position on the map but can be unreachable if isolated
		var nav_map = navigation_agent_3d.get_navigation_map()
		var safe_target = NavigationServer3D.map_get_closest_point(nav_map, target.position)
		#inform target to change position as safe one
		GlobalSignals.new_target_location.emit(safe_target)
		
		navigation_agent_3d.set_target_position(safe_target)
		
		state = State.MOVE


func _on_move():
	print("MOVE")
	var current_position = global_position
	var next_position = navigation_agent_3d.get_next_path_position()
	var direction = (next_position - current_position)
	direction = direction.normalized()
	var velocity_to_reach = direction * SPEED
	navigation_agent_3d.set_velocity(velocity_to_reach)


func _on_navigation_agent_3d_target_reached():
	print("Target reached !")


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3):
	#print("Velocity computed ", safe_velocity)
	#if is_on_floor():
	velocity = safe_velocity


func _on_navigation_agent_3d_navigation_finished():
	print("_on_navigation_agent_3d_navigation_finished")
	target.set_new_random_location()
	state = State.IDLE


func _on_navigation_agent_3d_waypoint_reached():
	print("_on_navigation_agent_3d_waypoint_reached")
