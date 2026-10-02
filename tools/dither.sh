#! /bin/env bash

#-----------------------------------------------------------------------------
#
# Usage: $0 [ -d dither_dir ] [ -p preview_dir ] [ -l -r -h ]
# Options:
#   -d dither_dir  - Dithered files directory (default: ./Dither)
#   -p preview_dir - Preview files directory (default: None generated)
#   -l             - Landscape Image
#   -r             - Dry run. No output files generated
#   -h             - Show this message
#
#-----------------------------------------------------------------------------
# A little background into how and why this works.
#-----------------------------------------------------------------------------
#
# From the T133A01 spec sheet the measured colors represented by the display
# are the following in the CIELAB color space (L*, a*, b*)
#
# black  - lab(12,7,-11)
# white  - lab(66.5,-4,0)
# red    - lab(26.5,41,30)
# green  - lab(35,-22,15)
# blue   - lab(34,3.5,-37)
# yellow - lab(62,-11,65)
#
# These translate to the following in RGB
#
# black  - rgb( 33,  29,  47),
# white  - rgb(154, 164, 162),
# red    - rgb(123,  25,  19),
# green  - rgb( 52,  91,  58),
# blue   - rgb( 24,  82, 139),
# yellow - rgb(161, 153,   3),
#
# The esphome code that translates colors to color indexes:
#
#   bool r_on = (color.r > 128);
#   bool g_on = (color.g > 128);
#   bool b_on = (color.b > 128);
#  
#   if (r_on && g_on && !b_on)
#     return T133A01_YELLOW;
#   if (r_on && !g_on && !b_on)
#     return T133A01_RED;
#   if (!r_on && g_on && !b_on)
#     return T133A01_GREEN;
#   if (!r_on && !g_on && b_on)
#     return T133A01_BLUE;
#   // Handle mixed colors: map to nearest primary
#   if (!r_on && g_on && b_on)
#     return T133A01_GREEN;  // Cyan -> Green
#   if (r_on && !g_on)
#     return T133A01_RED;  // Magenta -> Red
#   if (r_on)
#     return T133A01_WHITE;
#   return T133A01_BLACK;
#
#   Notice that:
#       r_on is triggered by white and yellow
#       g_on is triggered by white and yellow
#       b_on is triggered by white and blue
#
#   Result:
#       'red'    rgb(123,  25,  19) gets rendered in T133A01_WHITE
#       'green'  rgb( 52,  91,  58) gets rendered in T133A01_BLACK
#       'blue'   rgb( 24,  82, 139) gets rendered in T133A01_BLUE
#       'yellow' rgb(161, 153,   3) gets rendered in T133A01_YELLOW
#
#   The Lesson:
#       This translation only works well for images that have
#       been pre-dithered to full saturation RGB values.
#
#       An undithered photo with full spectrum RGB values will look
#       really strange.
#
#       A photo dithered to the colors actually represented by the
#       ePaper panel will result in improperly mapped colors.
#
#       For best results, dither to colors represented by the ePaper
#       panel, *and then* remap those colors to full saturation RGB.

usage()
{
    cat <<EOF
Usage: $0 [ -d dither_dir ] [ -p preview_dir ] [ -l -r -h ]
Options:
  -d dither_dir  - Dithered files directory (default: ./Dither)
  -p preview_dir - Preview files directory (default: None generated)
  -l             - Landscape Image
  -r             - Dry run. No output files generated
  -h             - Show this message
EOF
}

control_c()
{
    echo "Brake!"
    exit 0
}

dither_dir="./Dither"
preview_dir=""
dry_run=0
run=""

# ePaper panel size
wp=1200
hp=1600


while getopts "d:p:lrh" opt; do
    case ${opt} in
        d)
            dither_dir=${OPTARG}
            ;;
        p)
            preview_dir=${OPTARG}
            ;;
        l)
            wp=1600
            hp=1200
            ;;
        r)
            dry_run=1
            run="echo"
            ;;
        h)
            usage
            exit 0
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done

trap control_c SIGINT

lastind=$((OPTIND-1))
last=${!lastind}
shift $((OPTIND-1))

# Generate the T133A01 ePaper palette (used below)
magick xc:"#000000" xc:"#FFFFFF" xc:"#7B1913" xc:"#345B3A" xc:"#18528B" xc:"#A19903" \
       +append -colorspace sRGB spectra6-palette.png

mkdir -p "${dither_dir}"
if [ "x${preview_dir}" != "x" ] ; then
    mkdir -p "${preview_dir}"
fi

for input in "$@"; do
    if [ ! -f "${input}" ]; then
        continue
    fi
    dir=$(dirname "${input}")
    iname=$(basename "${input}")
    #sanitized="$(echo "${iname}" | sed 's/[ :@/?&=#%]/_/g')"

    # HomeAssistant entity attributes have a size limit of 16384 bytes.
    # So shorten the file names to try to stay under this limit.
    oname="$(echo "${iname}" | sed 's/\.\(png\|jpg\|gif\|bmp\|tif\)$/\.png/I')"

    output="${dither_dir}/${oname}"

    echo ${iname}

    # Set this to the color of the ePaper frame bezel
    background="white"

    # Get image dimensions after resizing to panel dimensions
    wi=$(magick "${input}" -resize ${wp}x${hp} -format "%[fx:w]" info:)
    hi=$(magick "${input}" -resize ${wp}x${hp} -format "%[fx:h]" info:)

    # Calculate how much spread is needed to reach the bezel
    sw=$(( (${wp} - ${wi}) / 2 ))
    sh=$(( (${hp} - ${hi}) / 2 ))
    # spread is max(sw, sh)
    spread=$(( ${sw} > ${sh} ? ${sw} : ${sh} ))

    # Calculate dimensions of the 'spread' image
    ws=$(( ${wi} + 2 * ${spread} ))
    hs=$(( ${hi} + 2 * ${spread} ))

    # Scale to ePaper panel size
    # Fill borders with a "good" border color (chosen above)
    #   Borders are 'spread' from the image to smooth
    #   the transition to the bezel
    # Dither to the color palette of the ePaper display
    #   The color palette comes from the T133A01 Specifications.
    #   Look for the table containing L*, a*, and b*
    # Remap the ePaper colors to full saturation RGB because
    #   when the color isn't saturated enough, esphome makes
    #   funny choices. This makes the images look oversaturated
    #   when viewed with "correct" colors. But they look correct
    #   on the ePaper display.
    #
    # Preview images are also generated so you can view a
    # close approximation to what the images will look like
    # on the ePaper panel.
    #
    # Dithered images are placed in the directory './Dither/'
    # Preview images are placed in the directory './Preview/'
    #
    # Image processing steps:
    #
    # - Scale image up slightly larger than the target
    #   panel size and 'spread' it. This creates
    #   a pixelated version of the image that fades
    #   to the background color around the edges
    # - Crop the 'spread' version of the image to the
    #   target panel size
    # - Resize the original image to target panel size.
    #   This may result in an image that is smaller
    #   in one dimension
    # - Overlay the scaled image on the 'spread' image
    # - Dither the composted image using the panels
    #   native color palette
    # - Remap pixel values from the panels native color palette
    #   to fully saturated RGB
    #
    ${run} magick "${input}" \
        -resize ${ws}x${hs}\! \
        -background ${background} \
        -gravity center -extent ${ws}x${hs} \
        -interpolate bilinear \
        -virtual-pixel ${background} \
        -spread 60 \
        -crop ${wp}x${hp}+0+0 \
        "${input}" \
        -resize ${wp}x${hp} \
        -compose over -composite \
        -gravity center -extent ${wp}x${hp} \
        -dither FloydSteinberg \
        -remap spectra6-palette.png \
        -fill "#FF0000" -opaque "#7B1913" \
        -fill "#00FF00" -opaque "#345B3A" \
        -fill "#0000FF" -opaque "#18528B" \
        -fill "#FFFF00" -opaque "#A19903" \
        "${output}"

    if [ "x${preview_dir}" != "x" ] ; then
        preview="${preview_dir}/${oname}"
        ${run} magick "${input}" \
            -resize ${ws}x${hs}\! \
            -background ${background} \
            -gravity center -extent ${ws}x${hs} \
            -interpolate bilinear \
            -virtual-pixel ${background} \
            -spread ${spread} \
            -crop ${wp}x${hp}+0+0 \
            "${input}" \
            -resize ${wp}x${hp} \
            -compose over -composite \
            -gravity center -extent ${wp}x${hp} \
            -dither FloydSteinberg \
            -remap spectra6-palette.png \
            "${preview}"
    fi

    ((file_count+=1))
done
