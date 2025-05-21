extends Node

# Mock Debug Manager for testing - provides reliable properties that work with duck typing

var full_view_mode = false
var camera = null

func setup_mock(is_full_view: bool, mock_camera = null):
	full_view_mode = is_full_view
	camera = mock_camera