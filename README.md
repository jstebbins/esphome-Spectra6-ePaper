# This is a work in progress
Introduction

- [What is it?](#what-is-it)
- [What does it do?](#what-does-it-do)
- [HomeAssistant Interaction](#homeassistant-interaction)
- [Tools Summary](#tools-summary)

[Seeed-E1004](Seeed-E1004/README.md)

- [Device Entities](Seeed-E1004/README.md#device-entities)
- [Code](Seeed-E1004/README.md#code)
- [Build](Seeed-E1004/README.md#build)
- [Hosting factory updates](Seeed-E1004/README.md#hosting-factory-updates)

[HomeAssistant](HomeAssistant/README.md)

- [Slideshow Blueprint](HomeAssistant/README.md#slideshow-blueprint)
- [Firmware Update Script](HomeAssistant/README.md#firmware-update-script)
- [Schedule Script](HomeAssistant/README.md#schedule-script)
- [Schedule Blueprint](HomeAssistant/README.md#schedule-blueprint)
- [File List REST Sensor](HomeAssistant/README.md#file-list-rest-sensor)

[Tools](tools/README.md)

- [Dither](tools/README.md#dither)
- [Make JSON Index](tools/README.md#make-json-index)


## What is it?

It's a picture frame. It can download pre-formatted images from a web server and display them.

My personal use case is for display of movie posters in my theater. I don't want to be recharging batteries all the time, so
I've designed the interactions to allow the device to sleep as much as possible. The blueprint uses a schedule entity
to schedule image updates, so it is easy to disable updates and keep the device sleeping during times it is unlikely
to be looked at. For example, I don't perform updates between the hours of 10pm and 8am. I haven't done exhaustive testing yet,
but I've had a device running for over a week now on a 1 hour update interval and it currently indicates 89.4% battery remaining.

## What does it do?

- HTTP Image download
- Sleep cycle controls
- Landscape/Portrait orientation control
- Play RTTTL jingles through the buzzer
- LED control

## HomeAssistant Interaction

- Blueprint for automating an image slideshow
- Script to assist with firmware updates
- Script to assist with loading sleep cycle schedules
- Blueprint to assist with loading sleep cycle schedules
- Example REST sensor for creating a file list entity

## 3D-Print

- A wall hanging bracket

## Tools Summary

- dither.sh
    - Scales, beautifies borders, dithers, and remaps colors for best image quality on T133A01 display.
- make_json_index.sh
    - Creates a json index of images used by HomeAssistant REST sensor.
- make_html_index.sh
    - Creates an html index of images. Useful for preview of images in a browser.
