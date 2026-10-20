# HomeAssistant Blueprint
The blueprint manages a slideshow for a collection of ePaper devices. 

User inputs to the blueprint are:

- Automation Trigger Entity
    - This starts the automation and controls when it is running. I've chosen to run this automation in a loop. It does not exit till this entity is 'off'. I've chosen to do this because there are a couple of persistent variables required and there is no easy way to store this data between automation invocations.  All such methods require additional user configuration. So I am storing this data in variables local to the automation and keeping the automation running.
- Play/Pause Entity (Optional)
    - This entity (if provided) pauses the slideshow. For example, you could connect a presence sensor here and only update the displays when presence is detected.
- ePaper Devices (Multiple)
    - These are the devices that images will be displayed on. Only devices with `manufacturer` `Stebbins` and `model` `ePaperDisplay` are permitted here. This ensures they have to required entities.
- Slideshow Schedule
    - This schedule entity is used to schedule the wake-up times of the ePaper devices. In a round-robin fashion, the ePaper devices are assigned a wake-up time from the schedule. When the device wakes, the next image is displayed and the next time slot in the schedule is assigned to the device.
- File List Entity
    - An entity that provides the URL of an image directory and a list of images. I provide a sample REST sensor yaml that creates the requred entity type. See below for details.

# File List Sensor
The file list sensor is a REST sensor that provides information required by the above blueprint. The sensor fetches a json dictionary index of files. The json index is created with `tools/make_json_index.sh`

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