"""Finder layout written directly by dmgbuild/ds_store; no AppleScript."""
from pathlib import Path

staging = Path(defines["staging"])
app_name = defines["app_name"]
format = "UDZO"
filesystem = "HFS+"
files = [str(staging / (app_name + ".app")), str(staging / "Installation Guide.txt")]
symlinks = {"Applications": "/Applications"}
background = defines["background"]  # unique temporary TIFF -> .background.tiff
icon = str(staging / (app_name + ".icns"))
window_rect = ((160, 120), (720, 460))
default_view = "icon-view"
show_status_bar = False
show_tab_view = False
show_toolbar = False
show_pathbar = False
show_sidebar = False
sidebar_width = 0
arrange_by = None
grid_offset = (0, 0)
grid_spacing = 100
scroll_position = (0, 0)
icon_size = 108
text_size = 11
label_pos = "bottom"
include_icon_view_settings = True
include_list_view_settings = False
hide_extensions = []
icon_locations = {
    app_name + ".app": (196, 148),
    "Applications": (524, 148),
    "Installation Guide.txt": (360, 313),
}
