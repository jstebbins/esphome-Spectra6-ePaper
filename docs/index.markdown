---
title: Seeed Studio reTerminal E1004 ESPHome Firmware
layout: home
cover: true
---

### Introduction

- [What is it?](#what-is-it)
- [What does it do?](#what-does-it-do)
- [HomeAssistant Interaction](#homeassistant-interaction)
- [Tools Summary](#tools-summary)

### [Seeed-E1004](device/)

- [Device Entities](device/#device-entities)
- [Code](device/#code)
- [Build](device/#build)
- [Self-Hosting Firmware](device/#self-hosting-firmware)

### [HomeAssistant](homeassistant/)

- [Slideshow Blueprint](homeassistant/#slideshow-blueprint)
- [Firmware Update Script](homeassistant/#firmware-update-script)
- [Schedule Script](homeassistant/#schedule-script)
- [Schedule Blueprint](homeassistant/#schedule-blueprint)
- [File List REST Sensor](homeassistant/#file-list-rest-sensor)

### [Tools](tools/)

- [Dither](tools/#dither)
- [Make JSON Index](tools/#make-json-index)


## What is it?

It's a picture frame. It can download pre-formatted images from a web server and display them.

I've designed the firmware to allow tuning for maximum battery life. When used with the provided HomeAssistant slideshow
blueprint, the device will remain in deep sleep when not actively updating the display with a new image. One of the provided
scripts permits downloading detailed schedules to devices, so they can be programmed to wake only at specific times. E.g. 
there is no point in updating in the middle of the night in most cases.

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
