import argparse
import json
import os
import sys

parser = argparse.ArgumentParser(
    description='Updates output settings file based on a default file',
)

parser.add_argument(
    'input_file',
    type=str,
    help='Path to default settings json file',
)

parser.add_argument(
    'output_file',
    type=str,
    help='Path to output settings json file',
)

args = parser.parse_args()
default_settings = args.input_file
sabnzbd_settings = args.output_file

# Fail if default settings file doesnt exist.
if not os.path.isfile(default_settings):
    sys.exit(
        'Invalid arguments, default settings file{file} does not exist'.format(
            file=default_settings,
        ),
    )


# Define which file to base the config on
if os.path.isfile(sabnzbd_settings):
    configuration_baseline = sabnzbd_settings
    print('Using existing sabnzbd.ini for Sabnzbd', sabnzbd_settings)
else:
    configuration_baseline = default_settings
    print('Generating sabnzbd.ini for Sabnzbd from environment and defaults', default_settings)

# Read config base
with open(configuration_baseline, 'r') as input_file:
    settings_lines = input_file.readlines()


def setting_as_env(setting: str) -> str:
    """Get a sabnzbd settings environment variable name."""
    return 'SABNZBD_{setting}'.format(
        setting=setting.upper().replace('-', '_'),
    )


# For each setting, check if an environment variable is set to override it
settings_replacement = ""
for index, line in enumerate(settings_lines):
    # if it contains [ skip it
    if line.find('[') != -1:
        settings_replacement = settings_replacement + line + "\n"
    else:
        setting = line.split(' = ')[0]
        value = line.split(' = ')[1]
        setting_env_name = setting_as_env(setting)
        # if setting exists
        if setting_env_name in os.environ:
            env_value = os.environ.get(setting_env_name)
            settings_replacement = settings_replacement + setting_env_name + " = " + env_value + "\n"
        else:
            settings_replacement = settings_replacement + line + "\n"

# Dump resulting settings to file
with open(sabnzbd_settings, 'w') as fp:
    fp.write(settings_replacement)
