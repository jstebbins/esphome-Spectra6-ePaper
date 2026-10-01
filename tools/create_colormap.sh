# Colors: black #000000, white #FFFFFF, red #FF0000, green #00FF00, blue #0000FF, yellow #FFFF00
# From the spec sheet CIELAB color space colors (L*, a*, b*)
#
# black  - lab(12,7,-11)
# white  - lab(66.5,-4,0)
# red    - lab(26.5,41,30)
# green  - lab(35,-22,15)
# blue   - lab(34,3.5,-37)
# yellow - lab(62,-11,65)
#
# RGB
#
# black  - #211D2F
# white  - #9AA4A2
# red    - #7B1913
# green  - #335B3A
# blue   - #18528B
# yellow - #A19903
#
# I am using full black and white because doing otherwise results in
# very washed out looking results.
# magick xc:"#211D2F" xc:"#9AA4A2" xc:"#7B1913" xc:"#335B3A" xc:"#18528B" xc:"#A19903" +append -colorspace sRGB spectra6-palette.png
magick xc:"#000000" xc:"#FFFFFF" xc:"#7B1913" xc:"#335B3A" xc:"#18528B" xc:"#A19903" +append -colorspace sRGB spectra6-palette.png
