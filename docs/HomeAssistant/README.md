---
title: HomeAssistant Blueprints, Scripts, and Helpers
layout: page
permalink: /homeassistant/
---

- [Slideshow Blueprint](#slideshow-blueprint)
- [Firmware Update Script](#firmware-update-script)
- [Schedule Script](#schedule-script)
- [Schedule Blueprint](#schedule-blueprint)
- [File List REST Sensor](#file-list-rest-sensor)

## Slideshow Blueprint
The blueprint manages a slideshow for a collection of ePaper devices. 

[![Open your Home Assistant instance and show the blueprint import dialog with a specific blueprint pre-filled.](https://my.home-assistant.io/badges/blueprint_import.svg)](https://my.home-assistant.io/redirect/blueprint_import/?blueprint_url=https%3A%2F%2Fraw.githubusercontent.com%2Fjstebbins%2Fesphome-Spectra6-ePaper%2Frefs%2Fheads%2Fmain%2FHomeAssistant%2FePaper_Slideshow_Automation_Blueprint.yaml)

User inputs to the blueprint are:

- Play/Pause Entity (Optional)
    - This entity (if provided) pauses the slideshow. For example, you could connect a presence sensor here and only update the displays when presence is detected.
- ePaper Devices (Multiple)
    - These are the devices that images will be displayed on. Only devices with `manufacturer` `Stebbins` and `model` `ePaperDisplay` are permitted here. This ensures they have to required entities.
- Randomize Images (default On)
    - Picks a random image from the file list for each update
- Current Image Index (Optional)
    - Index of the last displayed image
- [File List Entity](#file-list-rest-sensor)
    - An entity that provides the URL of an image directory and a list of images. I provide a sample REST sensor yaml that creates the requred entity type. See below for details.

## Schedule Script
Waits for a collection of ePaper devices to wake from sleep and sets their wake-up schedules.

[Get it on GitHub](https://raw.githubusercontent.com/jstebbins/esphome-Spectra6-ePaper/refs/heads/main/HomeAssistant/ePaper_Schedule_Script.yaml)

This script uses a HomeAssistant schedule to populate the schedules of a collection of devices. Each entry of the HomeAssistant schedule is assigned to a device in a round-robin fashion. So one device will wake-up for each HomeAssistant schedule event.

User inputs to the script are:

- ePaper Devices (Multiple)
    - These are the devices that images will be displayed on. Only devices with `manufacturer` `Stebbins` and `model` `ePaperDisplay` are permitted here. This ensures they have to required entities.
- Schedule
    - A HomeAssistant schedule helper. The `from` time of each schedule entry specifies a wake-up time for a device.

## Schedule Blueprint
Same as above, but in blueprint form. Use this if you have a predetermined list of devices and a predetermined schedule helper and you want to trigger a schedule update from an automation.

[![Open your Home Assistant instance and show the blueprint import dialog with a specific blueprint pre-filled.](https://my.home-assistant.io/badges/blueprint_import.svg)](https://my.home-assistant.io/redirect/blueprint_import/?blueprint_url=https%3A%2F%2Fraw.githubusercontent.com%2Fjstebbins%2Fesphome-Spectra6-ePaper%2Frefs%2Fheads%2Fmain%2FHomeAssistant%2FePaper_Schedule_Script_Blueprint.yaml)


## Firmware Update Script
Waits for a collection of ePaper devices to wake from sleep and performs a firmware update.

[Get it on GitHub](https://raw.githubusercontent.com/jstebbins/esphome-Spectra6-ePaper/refs/heads/main/HomeAssistant/ePaper_Firmware_Update_Script.yaml)

User inputs to the script are:

- ePaper Devices (Multiple)
    - These are the devices that images will be displayed on. Only devices with `manufacturer` `Stebbins` and `model` `ePaperDisplay` are permitted here. This ensures they have to required entities.

## File List REST Sensor
The file list sensor is a REST sensor that provides information required by the above blueprint. The sensor fetches a JSON dictionary index of files. The JSON index is created with `tools/make_json_index.sh`

[Get it on GitHub](https://raw.githubusercontent.com/jstebbins/esphome-Spectra6-ePaper/refs/heads/main/HomeAssistant/sensors.yaml)

State:

The URL of the directory of files.

Attributes:

- title
    - provided by the `title` key of the json dictionary.
- description
    - provided by the `description` key of the json dictionary.
- filelist
    - provided by the `filelist` key of the json dictionary. This is an array of filenames.
- sha256sum
    - provided by the `sha256sum` key of the json dictionary. This is an sha256 of the combined data of all files. It can be used to detect when files have been modified.
