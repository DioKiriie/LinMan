extends Control

@export var downloads: Dictionary = {
	"https://github.com/ModOrganizer2/modorganizer/releases/download/v2.5.2/Mod.Organizer-2.5.2.exe": "ModOrganizer2.Setup.exe",
	"https://github.com/Nexus-Mods/Vortex/releases/download/v1.12.3/vortex-setup-1.12.3.exe": "Vortex.Setup.exe",
	"https://github.com/Nexus-Mods/NexusMods.App/releases/download/v0.6.0/NexusMods.App.x86_64.AppImage": "NexusMods.App.x86_64.AppImage",
	# Add more URLs and filenames here
}

@onready var http_request = $HTTPRequest
@onready var progress_bar = $ProgressBar

# Initialize state variables
var current_url: String = ""
var current_filename: String = ""
var is_downloading = false
var total_file_size: int = 0

func _ready() -> void:
	# Connect signals correctly
	http_request.connect("request_completed", Callable(self, "_on_http_request_request_completed"))

func _on_button_pressed() -> void:
	_start_download(0)

func _on_button_2_pressed() -> void:
	_start_download(1)

func _on_button_3_pressed() -> void:
	_start_download(2)

func _start_download(index: int) -> void:
	if not is_downloading:
		current_url = downloads.keys()[index]  # Get the URL by index
		current_filename = downloads[current_url]  # Get the corresponding filename
		progress_bar.visible = true
		progress_bar.value = 0
		http_request.request(current_url)
		is_downloading = true
		print("Starting download of ", current_filename, " from ", current_url)
	else:
		print("A download is already in progress.")

func _process(delta: float) -> void:
	if is_downloading:
		# Print downloaded bytes and total file size for debugging
		var downloaded_bytes = http_request.get_downloaded_bytes()
		total_file_size = http_request.get_body_size()
		print("Downloaded bytes: ", downloaded_bytes, " / Total file size: ", total_file_size)
		
		# Update progress bar
		progress_bar.value = downloaded_bytes
		progress_bar.max_value = total_file_size

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	progress_bar.visible = false
	is_downloading = false
	if response_code == 200:
		print("Download completed successfully for ", current_filename)
		var file_path = "user://" + current_filename
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		if file:
			file.store_buffer(body)
			file.close()
			print("File saved successfully as ", current_filename)
			
			# Verify file size after saving
			var saved_file_size = FileAccess.open(file_path, FileAccess.READ).get_len()
			if saved_file_size == total_file_size:
				print("File size verified successfully.")
				_change_scene("res://YourNextScene.tscn")  # Replace with your actual scene path
			else:
				print("File size mismatch. Expected: ", total_file_size, ", but got: ", saved_file_size)
		else:
			print("Failed to save file as ", current_filename)
	else:
		print("Download failed with response code: ", response_code)

func _change_scene(scene_path: String) -> void:
	# Load the new scene
	var new_scene = load(scene_path)
	if new_scene:
		get_tree().change_scene_to(new_scene)
	else:
		print("Failed to load scene: ", scene_path)


func _on_button_4_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main/initialisator.tscn")
