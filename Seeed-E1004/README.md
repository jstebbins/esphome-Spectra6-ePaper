- [Device Entities](#device-entities)
- [Code](#code)
- [Build](#build)
- [Self-Hosting Firmware](#self-hosting-firmware)

# Notes about the device

This is my first ESPHome device. So feel free to point out my errors or any failure to follow commonly accepted practices.

## Device Entities
### Controls

- Activity Timeout: Number in minutes
    - When a button is pressed on the device, sleep will be prevented for this amount of time
- Image URL: Text entry
    - The image URL to load when `Refresh Display` is pressed
- Landscape: Switch
    - Sets the frame to landscape display mode (default mode is Portrait)
- Onboard LED: Switch
    - Turns on the LED indicator on the back of the frame
- Play RTTTL: Button
    - Plays the RTTTL (Ring Tone Text Transfer Language) script in the `RTTL Song` entity
- Refresh Display: Button
    - Initiates an update of the display using `Image URL`
- RTTTL Song: Text entry
    - An RTTTL script to play through the buzzer when `Play RTTTL` is pressed
- Sleep: Button
    - Requests that the device enter sleep mode. The device may not immediately enter sleep mode if it is updating it's display or there has been recent user activity.
- Wake Duration: Number in minutes
    - The duration the device will stay awake if not manually put to sleep.
- Wake Every: Number in minutes
    - The run/sleep cycle time. Enabled if `Wake Timer Type` is set to `Wake Every`.
- Wake Timer Type: Selection
    - Determines what type of timer is used to cause the device to wake up.
	    - Schedule - Wake at scheduled times. Schedule loaded via `set_schedule` action
	    - Wake Every - Wake on an interval determined by `Wake Every` entity

### Sensors

- Battery Level
- Battery Voltage
- Relative Humitidy
- SD Card Detected
- Temperature

### Events

- Actions
    - sleep_timeout
    - wake_at_timeout
        - The ESP23 internal RTC used for sleep timeout drifts by minutes per hour because it is not connected to a crystal in this device. There is a second external RTC that keeps accurate time. I want the `Wake At` timer type to be accurate. So after waking up, the more accurate external RTC time is checked and `wake_at_timout` is sent at the appropriate time.
    - refresh_button_press
    - left_button_press
    - right_button_press
    - refresh_button_double_press
    - left_button_double_press
    - right_button_double_press

### Configuration

- Update
    - Indicates when updates are available
- Update Manifest URL (disabled by default)
    - Where to retrieve factory OTA updates from
- Restart (disabled by default)
    - Restart the device

### Diagnostic

- API Connection
    - Indicates when the device has connected to HomeAssistant

### Actions
- show_image
    - Downloads and displays the image given by `image_url`

    |Parameter|Type|
	|----------|----|
    |image_url|string|
- play_kazoo
    - Plays the RTTTL formatted jingle give by `song_str`

    |Parameter|Type|
	|----------|----|
    |song_str|string|
    - Example `scale_up:d=32,o=5,b=100:c,c#,d#,e,f#,g#,a#,b`
- set_schedule
    - Sets the schedule used by `Schedule` wake timer type
   
    |Parameter|Type|
	|----------|----|
    |schedule|JSON|
    - Example `{"days" : [{ "events": ["14:00", ...]}, ...]}`, days[0] is Sunday
- get_schedule
    - Returns the current schedule used by `Schedule` wake timer type

## Code

Most of the device code is in `esphome_ePaperPoster.yaml`. If you want to takeover a one-off of this device with ESPHome Builder,
then this is the file you need. The file `esphome_ePaperPoster.factory.yaml` contains the bits needed to perform factory OTA updates
for a fleet of devices.

There are 2 images that get compiled in to the firmware. These are `setup.png` and `setup_complete.png`. They are converted to C header files and included in
```
esphome:
	includes:
```
To create the header files, I use e.g.
```
xxd -i setup.png setup_image.h
```
Then I make the data const so it stays in read-only memory and adjust the data type (diff)
```
-unsigned char setup_png[] = {
+const uint8_t setup_png[] = {
```
This is all necessary in order to store compressed images in read-only memory and only decompress them when they are needed. ESPHome does not currently have a built-in way to do this.

## Build
I use ESPHome CLI tools. ESPHome Builder is really not suitable for a project more complex than one yaml file. To build the factory and OTA bin files:
```
esphome compile esphome_ePaperPoster.factory.yaml
```
The bin files get deposited in `.esphome/build/poster-seeed/build/firmware.ota.bin` and `.esphome/build/poster-seeed/build/firmware.factory.bin`.

## Self-Hosting Firmware
I've designed the device so you can host your own 'factory' installs and OTA updates over http(s). This makes keeping devices up-to-date easier if you are maintining several devices that all run the same firmware.

To host your own firmware, you will require an http(s) server. HomeAssistant happens to supply one. Just create a `www` directory under `config` on your HomeAssistant server. Files in `www` will be served under `http://homeassistant.local:8123/local` (assuming HomeAssistant is configured to use port 8123).

### Prepare the web server
The files you need to host are `index.html`, `manifest.json`, `poster-seeed-e1004-firmware.factory.bin`, and `poster-seeed-e1004-firmware.ota.bin`. The layout must be, e.g.
```
www/
    firmware/
        e1004/
			index.html
            manifest.json
            26.10.17.0/
                poster-seeed-e1004-firmware.factory.bin
                poster-seeed-e1004-firmware.ota.bin
```
Where `26.10.17.0` is the version number that must be set in `esphome_ePaperPoster.factory.yaml` prior to building the firmware.

A basic version of `index.html` is supplied in `Seeed-E1004`. It provides a button to invoke the [ESP Web Tools Installer](https://esphome.github.io/esp-web-tools/). You can use this to install the initial factory firmware to the device from your PC over USB.

`manifest.json` is created with the script `create_manifest.py`. This script reads the version number from `esphome_ePaperPoster.factory.yaml` and fills out the manifest for you. It sends output to stdout, so usage looks like
```
./create_manifest.py esphome_ePaperPoster.factory.yaml > manifest.json
```
### Prepare firmware binaries and manifest:

1. Compile the firmware or obtain it from [Releases](https://github.com/jstebbins/esphome-Spectra6-ePaper/releases). If you are compiling from source, be sure to first set an appropriate version number in `esphome_ePaperPoster.factory.yaml`.
```
esphome compile esphome_ePaperPoster.factory.yaml
```
2. Create manifest.json or obtain it from [Releases](https://github.com/jstebbins/esphome-Spectra6-ePaper/releases). As a side effect, `create_manifest.py` copies the firmware files to the currnet working directory.
```
./create_manifest.py esphome_ePaperPoster.factory.yaml > manifest.json
```
3. Copy the required files to the locations described above on your http server.
```
scp poster-seeed-e1004-firmware.* root@homeassistant.local:config/www/firmware/e1004/26.10.17.0
scp manifest.json root@homeassistant.local:config/www/firmware/e1004
scp index.html root@homeassistant.local:config/www/firmware/e1004
```
### Flashing the initial firmware

There are several ways to do this. 

1. The easiest is to use the web installer. Open `http://homeassistant.local:8123/local/firmware/e1004/index.html` in a supported browser and press the `Connect` button to start the process. Supported browsers are Firefox and Chrome based browsers.
2. Use ESPHome CLI
```
esphome upload --device /dev/ttyUSB0 --file poster-seeed-e1004-firmware.factory.bin esphome_ePaperPoster.factory.yaml
```
3. Use esptool
```
esptool --port /dev/ttyUSB write-flash 0 poster-seeed-e1004-firmware.factory.bin
```


### Performing OTA updates

- In HomeAssistant, find the device and enable the disabled Configuration entity `Update Manifest URL`
- Set the value of `Update Manifest URL` to your `manifest.json` location. E.g.
```
http://homeassistant.local:8123/local/firmware/e1004/manifest.json
```
- [Prepare firmware binaries and manifest](#prepare-firmware-binaries-and-manifest)

The next time the device checks for updates, it should find a new update available.

If you have multiple devices (as I do), it can be a PITA to wake each, one at a time, to perform multiple updates. One of the scripts I've provided assists with this [Firmware Update Script](../HomeAssistant/README.md#firmware-update-script).