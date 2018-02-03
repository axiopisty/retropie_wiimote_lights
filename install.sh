#!/bin/bash

cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Ask if they have an internal or external Bluetooth Dongle
clear
echo "WELCOME TO retropie_wiimote_lights - LET'S MAKE YOUR WIIMOTE LIGHTS WORK RIGHT!"
echo "==============================================================================="
echo "If you have an external bluetooth controller, many emulators will reverse";
echo "the order of your controllers."
echo
echo "Also, you may choose whether to light up a single light on each controller";
echo "corresponding with that input # or show 2 lights for 2nd controller, 3 for";
echo "the 3rd, 4 for the 4th, etc.  multiple lights is the typical choice.";
echo
options=( "Internal Bluetooth Controller - multiple lights on" \
	  "External Bluetooth Controller - multiple lights on" \
          "Internal Bluetooth Controller - single light" \
          "External Bluetooth Controller - single light" )

select which in "${options[@]}"; do
     case $which in
	"${options[0]}")
		filname="wii-lights-bt-internal.sh"
		break;;
	"${options[1]}")
		filname="wii-lights-bt-external.sh"
		break;;
	"${options[2]}")
		filname="wii-lights-bt-internal-one.sh"
		break;;
	"${options[3]}")
		filname="wii-lights-bt-external-one.sh"
		break;;
     esac
done

# Now we know what which one to use, let's symlink that one:
rm -f ./wii-lights.sh
ln -s "versions/$filname" wii-lights.sh
echo "Linking in script $filname"

# First backup some old configs that we are going to replace
cp /opt/retropie/configs/all/retroarch/autoconfig/Nintendo\ Wii\ Remote\ Pro\ Controller.cfg /opt/retropie/configs/all/retroarch/autoconfig/Nintendo\ Wii\ Remote\ Pro\ Controller.cfg.bak 2> /dev/null
cp /opt/retropie/configs/daphne/dapinput.ini /opt/retropie/configs/daphne/dapinput.ini.bak 2> /dev/null
cp /opt/retropie/configs/n64/InputAutoCfg.ini /opt/retropie/configs/n64/InputAutoCfg.ini.bak 2> /dev/null
cp /opt/retropie/configs/n64/mupen64plus.cfg /opt/retropie/configs/n64/mupen64plus.cfg.bak 2> /dev/null

# Configure the controllers for several emulators to use our custom configs
cp configs/Nintendo\ Wii\ Remote\ Pro\ Controller.cfg /opt/retropie/configs/all/retroarch/autoconfig/Nintendo\ Wii\ Remote\ Pro\ Controller.cfg
cp configs/dapinput.ini /opt/retropie/configs/daphne/dapinput.ini
cp configs/InputAutoCfg.ini /opt/retropie/configs/n64/InputAutoCfg.ini
pushd /opt/retropie/configs/n64 && (sed 's/Joy Mapping Stop =.*/Joy Mapping Stop = "J0B8\/B9"/g;s/Joy Mapping Save State =.*/Joy Mapping Save State = "J0B8\/B5"/g;s/Joy Mapping Load State =.*/Joy Mapping Load State = "J0B8\/B4"/g' mupen64plus.cfg.rp-dist > mupen64plus.cfg); popd

# Install the service to light up the wiimote lights correctly
sudo cp wii-controller.service /etc/systemd/system/
sudo systemctl enable wii-controller.service
sudo systemctl start wii-controller.service
echo "All Done.  Have fun !"
