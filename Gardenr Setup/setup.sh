# Python dependencies

pip3 install pyrebase
pip3 install pyqrcode
pip3 install pytz


# Overwrite validation (for repeated execution)

FILE="$HOME/gardenr/plant_id.txt"
if test -f "$FILE"; 
then
  while true; do
    read -p "Overwrite old the plant id? (sensor data will no long be updated) [y/n] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
fi



# Clean crontab 

touch tempfile
crontab -l > tempfile
echo "$(sed "/gardenr_send_data/d" tempfile)" > tempfile
crontab tempfile
rm tempfile


# Get full directory

touch temppathfile
SCRIPT=$(readlink -f "$0")
currentPath=$(dirname "$SCRIPT")
echo $currentPath > temppathfile

escapedPath="$(sed 's/ /\\ /g' temppathfile)"

rm temppathfile


#Run registration script

python3 "$currentPath/python scripts/gardenr_register.py"

# Schedule data uploads

touch tempfile
crontab -l > tempfile
echo "*/30 * * * * python3 $escapedPath/python\ scripts/gardenr_send_data.py" >> tempfile
crontab tempfile
rm tempfile


