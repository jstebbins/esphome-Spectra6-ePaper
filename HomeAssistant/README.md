- [Slideshow Blueprint](#Slideshow Blueprint)
- [Firmware Update Script](#Firmware Update Script)
- [Schedule Script](#Schedule Script)
- [Schedule Blueprint](#Schedule Blueprint)
- [File List REST Sensor](#File List REST Sensor)

## Slideshow Blueprint
The blueprint manages a slideshow for a collection of ePaper devices. 

User inputs to the blueprint are:

- Play/Pause Entity (Optional)
    - This entity (if provided) pauses the slideshow. For example, you could connect a presence sensor here and only update the displays when presence is detected.
- ePaper Devices (Multiple)
    - These are the devices that images will be displayed on. Only devices with `manufacturer` `Stebbins` and `model` `ePaperDisplay` are permitted here. This ensures they have to required entities.
- Randomize Images (default On)
    - Picks a random image from the file list for each update
- Current Image Index (Optional)
    - Index of the last displayed image
- File List Entity
    - An entity that provides the URL of an image directory and a list of images. I provide a sample REST sensor yaml that creates the requred entity type. See below for details.

## Schedule Script
Waits for a collection of ePaper devices to wake from sleep and sets their wake-up schedules.

This script uses a HomeAssistant schedule to populate the schedules of a collection of devices. Each entry of the HomeAssistant schedule is assigned to a device in a round-robin fashion, so the devices wake-up one at a time at the given HomeAssistant schedule events.

User inputs to the script are:

- ePaper Devices (Multiple)
    - These are the devices that images will be displayed on. Only devices with `manufacturer` `Stebbins` and `model` `ePaperDisplay` are permitted here. This ensures they have to required entities.
- Schedule
    - A HomeAssistant schedule helper. The `from` time of each schedule entry specifies a wake-up time for a device.

## Schedule Blueprint
Same as above, but in blueprint form. Use this if you have a predetermined list of devices and a predetermined schedule helper and you want to trigger a schedule update from an automation.

## Firmware Update Script
Waits for a collection of ePaper devices to wake from sleep and performs a firmware update.

User inputs to the script are:

- ePaper Devices (Multiple)
    - These are the devices that images will be displayed on. Only devices with `manufacturer` `Stebbins` and `model` `ePaperDisplay` are permitted here. This ensures they have to required entities.

## File List REST Sensor
The file list sensor is a REST sensor that provides information required by the above blueprint. The sensor fetches a JSON dictionary index of files. The JSON index is created with `tools/make_json_index.sh`

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