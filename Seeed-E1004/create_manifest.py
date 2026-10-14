#! /usr/bin/env python

import hashlib, json, sys, os

base_firmware_name = "poster-seeed-e1004-firmware"
base_release_url = "https://github.com/jstebbins/esphome-Spectra6-ePaper/releases/tag/"

def usage(cmd):
    print("usage: %s <version string>" % os.path.basename(cmd))

def hash_it(m, fn):
    with open(fn, "rb") as f:
        chunk = f.read(8192)
        while chunk:
            m.update(chunk)
            chunk = f.read(8192)
    return m.hexdigest()

class Manifest:

    manifest = {
      "name": "Stebbins.ePaperDisplay",
      "version": "",
      "home_assistant_domain": "esphome",
      "new_install_prompt_erase": False,
      "builds": [
        {
          "chipFamily": "ESP32-S3",
          "ota": {
            "path": "",
            "md5": "",
            "sha256": "",
            "summary": "",
            "release_url": ""
          },
          "parts": [
            {
              "path": "",
              "offset": 0,
              "md5": "",
              "sha256": ""
            }
          ]
        }
      ]
    }

    def __init__(self, version):
        ota = self.manifest["builds"][0]["ota"]
        part = self.manifest["builds"][0]["parts"][0]

        self.manifest["version"] = version
        ota["path"] = version + "/" + base_firmware_name + ".ota.bin"
        ota["md5"] = hash_it(hashlib.md5(), base_firmware_name + ".ota.bin")
        ota["sha256"] = hash_it(hashlib.sha256(), base_firmware_name + ".ota.bin")
        ota["release_url"] = base_release_url + version

        part["path"] = version + "/" + base_firmware_name + ".factory.bin"
        part["md5"] = hash_it(hashlib.md5(), base_firmware_name + ".factory.bin")
        part["sha256"] = hash_it(hashlib.sha256(), base_firmware_name + ".factory.bin")

    def print(self):
        manifest_json = json.dumps(self.manifest, indent=2)
        print(manifest_json)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        usage(sys.argv[0])
        exit(2)
    manifest = Manifest(sys.argv[1])
    manifest.print()

