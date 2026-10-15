# This is a work in progress

# What is it?

It's a picture frame. It can download pre-formatted images from a web server and display them.

My personal use case is for display of movie posters in my theater. I don't want to be recharging batteries all the time, so
I've designed the interactions to allow the device to sleep as much as possible. The blueprint uses a schedule entity
to schedule image updates, so it is easy to disable updates and keep the device sleeping during times it is unlikely
to be looked at. For example, I don't perform updates between the hours of 10pm and 8am. I haven't done exhaustive testing yet,
but I've had a device running for over a week now on a 1 hour update interval and it currently indicates 89.4% battery remaining.

# ESPHome 6 Color ePaper Device

- HTTP Image download
- Sleep cycle controls
- Landscape/Portrait orientation control
- Buzzer & LED control

# HomeAssistant Interaction

- Blueprint for automating an image slideshow
- Example REST sensor for creating a file list entity

# 3D-Print

- A wall hanging bracket

# Tools

- dither.sh scales, beautifies borders, dithers, and remaps colors for best image quality on T133A01 display.
- make_json_index.sh creates a json index of images used by HomeAssistant REST sensor.
- make_html_index.sh creates an html index of images. Useful for preview of images in a browser.
