# Notes about the device

## Device Entities
### Controls

- Activity Timeout: Number in minutes
    - When a button is pressed on the device, sleep will be prevented for this amount of time
- Buzzer: Switch
    - Sounds the buzzer on the device
- Image URL: Text entry
    - The image URL to load when `Refresh Display` is pressed
- Landscape: Switch
    - Sets the frame to landscape display mode (default mode is Portrait)
- Onboard LED: Switch
    - Turns on the LED indicator on the back of the frame
- Refresh Display: Button
    - Initiates an update of the display using `Image URL`
- Sleep: Button
    - Requests that the device enter sleep mode. The device may not immediately enter sleep mode if it is updating it's display or there has been recent user activity.
- Wake At: Time HH:MM
    - Wall clock time for the wake up event. Enabled if `Wake Timer Type` is set to `Wake At`.
- Wake Duration: Number in minutes
    - The duration the device will stay awake if not manually put to sleep.
- Wake Every: Number in minutes
    - The run/sleep cycle time. Enabled if `Wake Timer Type` is set to `Wake Every`.
- Wake Timer Type: Selection
    - Determines what type of timer is used to cause the device to wake up.

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

## Hosting factory updates
I've designed the device so you can host your own 'factory' updates over http(s). This makes keeping devices up-to-date easier if you are maintining several devices that all run the same firmware. ESPHome Builder forces you to keep a unique yaml file for each device with a unique device `name` if you want to perform OTA updates.

To host your own factory updates, you will require an http(s) server. HomeAssistant happens to supply one. Just create a `www` directory under `config` on your HomeAssistant server. Files in `www` will be served under `http://homeassistant.local:8123/local` (assuming HomeAssistant is configured to use port 8123).

The files you need to host are `manifest.json`, `poster-seeed-e1004-firmware.factory.bin`, and `poster-seeed-e1004-firmware.ota.bin`. The layout must be, e.g.
```
www/
	firmware/
		e1004/
			manifest.json
			26.10.17.0/
				poster-seeed-e1004-firmware.factory.bin
				poster-seeed-e1004-firmware.ota.bin
```
Where `26.10.17.0` is the version number that must be set in `esphome_ePaperPoster.factory.yaml` prior to building the firmware.

`manifest.json` is created with the script `create_manifest.py`. This script reads the version number from `esphome_ePaperPoster.factory.yaml` and fills out the manifest for you. It sends output to stdout, so usage looks like
```
./create_manifest.py esphome_ePaperPoster.factory.yaml > manifest.json
```
To get this set up:

1. Flash your device with an initial factory firmware with an appropriate version number. I.e. set the version number in `esphome_ePaperPoster.factory.yaml` and run
```
esphome run --device /dev/ttyUSB0 esphome_ePaperPoster.factory.yaml
```
2. Create manifest.json. As a side effect, `create_manifest.py` copies the firmware files to the currnet working directory.
```
./create_manifest.py esphome_ePaperPoster.factory.yaml > manifest.json
```
3. Copy the required OTA update files to the locations described above on your http server.
```
scp poster-seeed-e1004-firmware.* root@homeassistant.local:config/www/firmware/e1004/26.10.17.0
scp manifest.json root@homeassistant.local:config/www/firmware/e1004
```

To perform an update:

- In HomeAssistant, find the device and enable the disabled Configuration entity `Update Manifest URL`
- Set the value of `Update Manifest URL` to your `manifest.json` location. E.g.
```
http://homeassistant.local:8123/local/firmware/e1004/manifest.json
```
- Replace step 1 above with
```
esphome compile esphome_ePaperPoster.factory.yaml
```
and do steps 2 - 3. Be sure to increment your version number.

The next time the device checks for updates, it should find a new update available.
