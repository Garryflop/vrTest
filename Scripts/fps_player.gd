extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera: Camera3D = $Camera3D
@onready var raycast: RayCast3D = $Camera3D/RayCast3D

func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * 0.005)
        camera.rotate_x(-event.relative.y * 0.005)
        camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
        
    if event.is_action_pressed("ui_cancel"):
        if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        else:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
            
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
            return
            
        interact()

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta

    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # Simple WASD handling without defining new Input Map actions
    var dir = Vector2.ZERO
    if Input.is_key_pressed(KEY_W): dir.y -= 1
    if Input.is_key_pressed(KEY_S): dir.y += 1
    if Input.is_key_pressed(KEY_A): dir.x -= 1
    if Input.is_key_pressed(KEY_D): dir.x += 1
    dir = dir.normalized()

    var direction = (transform.basis * Vector3(dir.x, 0, dir.y)).normalized()
    if direction:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)

    move_and_slide()

func interact() -> void:
    if raycast.is_colliding():
        var col = raycast.get_collider()
        
        if col.has_method("_on_xr_pointer_pressed"):
            col._on_xr_pointer_pressed(raycast.get_collision_point())
            return
            
        # Navigate upwards to check for specific nodes like our Button3D or components
        var p = col
        while p != null:
            if p is Button3D:
                p.button_pressed.emit()
                return
            if p.has_method("toggle"):
                p.toggle()
                return
            p = p.get_parent()
