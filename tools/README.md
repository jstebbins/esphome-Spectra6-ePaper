- [Dither](#dither)
- [Make JSON Index](#make-json-index)
- 
## Dither
The ePaper panel used by the Seeed Studio reTerminal E1004 is a T133A01. The colors it reproduces are documented in it's [specifications](https://files.seeedstudio.com/wiki/Other_Display/1330-E6-epaper/13.3_E6_eInk_Display_module_Datasheet.pdf) in the CIELAB color space.

|color|LAB|RGB|
|-----|---|---|
|black|12, 7, -11|33,  29,  47|
|white|66.5, -4, 0|154, 164, 162|
|red|26.5, 41, 30|123,  25,  19|
|green|35, -22, 15|52,  91,  58|
|blue|34, 3.5, -37|24,  82, 139|
|yellow|62, -11, 65|161, 153,   3|

To obtain a good representation of the original image, you need to dither the image to the above RGB colors (with the exception of black and white which I'll explain later).

But it's not quite that simple. ESPHome has color selection logic that does not know about the actual colors reproduced by the panel. It selects based on how close each pixel's color is to a fully saturated red, green, or blue value.  This results in incorrect mapping of the panel's green and red values to white and black repectively. To work around this, after dithering with the panels true colors, you must remap those colors to fully saturated RGB values.

The script `dither.sh` performs the dither and color remapping required. It has an option to also produce a preview image that does not have the remapping step (so you can preview the images on a properly calibrated display).

Usage:
```
Usage: dither.sh [ -d dither_dir ] [ -p preview_dir ] [ -l -r -h ]
Options:
  -d dither_dir  - Dithered files directory (default: ./Dither)
  -p preview_dir - Preview files directory (default: None generated)
  -l             - Landscape Image
  -r             - Dry run. No output files generated
  -h             - Show this message
```

What the script does

- Resizes the input to 1200x1600 (portrait) or 1600x1200 (landscape). The aspect ratio is kept, so result image may be narrower or wider.
- Creates a `spread` image that fills the 1200x1600 frame and overlays the resized image over it. This provides a nice transitional border for images that do not scale to perfectly fit 1200x1600.
- Performs Floyd Steinberg dithering of the image
- Remaps dithered colors to fully saturated RGB values

## Make JSON Index
The HomeAssistant automation blueprint I provide for creating a slideshow across multiple E1004 devices requires a list of files to serve to the device. The script takes a list of files on the command line and generates a JSON representation of the file list.

The generated file `index.json` is used by the File List REST Sensor I provide to create a sensor that can be queried for the list of files.

The script is pretty basic, and if you want to change the `title` or `description` you'll have to edit the script.

Example List:
```
{
  "title" : "Movie Posters",
  "description" : "Dithered movie posters for display on ePaper",
  "count" : 2415,
  "sha256sum" : "ad468e226299db541d334b023dbc2ae9a6118b9f4b4b2512224d9f6ebfaeda5b",
  "filelist" : [
    "Image1.png",
    "Image2.png",
    "Image3.png"
  ] 
}   
```
Example Usage:
```
make_json_index.sh DitheredPhotos/*.png
```
