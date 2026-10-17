#! /usr/bin/env python

# Parses version number from a project yaml file
# produces md5 and sha256 hashes from compiled bin files which must be in CWD
# bin file names are hard-coded (see base_firmware_name)
# release_url is hard-coded (see base_release_url)
#
# Procedure:
#   1. Update version number in the yaml
#   2. esphome compile <yaml file>
#   3. cp .esphome/build/poster-seeed/build/firmware.factory.bin poster-seeed-e1004-firmware.factory.bin
#   4. cp .esphome/build/poster-seeed/build/firmware.ota.bin poster-seeed-e1004-firmware.ota.bin
#   5. ./create_manifest <yaml file>
#   6. Post bin files and manifest.json to your firmware updates location

import hashlib, json, sys, os, yaml, shutil, os

base_firmware_name = "poster-seeed-e1004-firmware"
base_release_url = "https://github.com/jstebbins/esphome-Spectra6-ePaper/releases/tag/"

def usage(cmd):
    print("usage: %s <yaml_file>" % os.path.basename(cmd))

def hash_it(m, fn):
    with open(fn, "rb") as f:
        chunk = f.read(8192)
        while chunk:
            m.update(chunk)
            chunk = f.read(8192)
    return m.hexdigest()

# constructor to parse non-standard '!include' yaml
# this does not pull in the included file, just the file's name
def constructor_include(loader, node):
    path = loader.construct_scalar(node)
    return path

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

    def __init__(self, factory_yaml):
        # Read the release version number from the provided yaml file
        yaml.add_constructor('!include', constructor_include, Loader=yaml.SafeLoader)
        with open(factory_yaml, "r") as f:
            try:
                fy = yaml.safe_load(f)
            except yaml.YAMLError as exc:
                print("Error in configuration file: %s", exc)

            version = fy["esphome"]["project"]["version"]
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
    # Copy the bin files we require
    os.system("cp %s %s" % ( ".esphome/build/poster-seeed/build/firmware.factory.bin", base_firmware_name + ".factory.bin"))
    os.system("cp %s %s" % ( ".esphome/build/poster-seeed/build/firmware.ota.bin", base_firmware_name + ".ota.bin"))
    # shutil.copyfile appears to be really slow in some cases.
    #shutil.copyfile(".esphome/build/poster-seeed/build/firmware.factory.bin", base_firmware_name + ".factory.bin")
    #shutil.copyfile(".esphome/build/poster-seeed/build/firmware.ota.bin", base_firmware_name + ".ota.bin")
    manifest = Manifest(sys.argv[1])
    manifest.print()

