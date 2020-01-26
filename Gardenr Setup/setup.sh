#Python dependencies
pip install pyrebase
pip install pyqrcode
pip install pytz

#Run registration script
python register.py

#Schedule data uploads
touch tempfile
crontab -l > tempfile
echo "0 * * * * python $(pwd)/send_data.py" >> tempfile
echo "30 * * * * python $(pwd)/send_data.py" >> tempfile
crontab tempfile
rm tempfile


