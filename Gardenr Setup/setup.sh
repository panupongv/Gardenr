# Python dependencies

pip install pyrebase
pip install pyqrcode
pip install pytz


# Overwrite validation (for repeated execution)

FILE="$(pwd)/python scripts/plant_id.txt"
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




#Run registration script

python python\ scripts/gardenr_register.py

# Schedule data uploads

touch temppathfile
currentPath="$(pwd)"
echo $currentPath > temppathfile
escapedPath="$(sed 's/ /\\ /g' temppathfile)"
rm temppathfile

touch tempfile
crontab -l > tempfile
echo "0 * * * * python $escapedPath/python\ scripts/gardenr_send_data.py" >> tempfile
echo "30 * * * * python $escapedPath/python\ scripts/gardenr_send_data.py" >> tempfile
crontab tempfile
rm tempfile


