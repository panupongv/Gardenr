
while true; do
    read -p "Deactivate Gardenr device? (sensor data will no long be updated) [y/n] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac

# Remove plant id

rm -rf "$HOME/gardenr"


# Clean crontab 

touch tempfile
crontab -l > tempfile
echo "$(sed "/gardenr_send_data/d" tempfile)" > tempfile
crontab tempfile
rm tempfile