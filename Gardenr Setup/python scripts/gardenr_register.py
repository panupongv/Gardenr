from private import api_keys

import os
import pyrebase
import pyqrcode as qr
from pytz import timezone
from datetime import datetime

def main():
    
    firebase = pyrebase.initialize_app(api_keys)

    db = firebase.database()

    local_time = datetime.now()
    utc_time = local_time.replace(tzinfo=timezone('UTC'))

    utc_time_zone = local_time.hour-utc_time.hour


    new_plant_id = db.child('plants').push({'name':''})['name']

    hashValue = utc_time.strftime("%Y%m%d%H%M%S%f")[:-3]

    key = db.child('qrInstances').child(new_plant_id).push(hashValue).values()[0]

    separator = '%%'

    qr_actual_content = new_plant_id + separator + key + separator + hashValue

    print(qr.create(qr_actual_content).terminal(quiet_zone=1))

    db.child('plants').child(new_plant_id).child('utcTimeZone').set(utc_time_zone)
    db.child('plants').child(new_plant_id).child('timeUpdated').set(local_time.strftime("%Y%m%d %H%M"))
                
    home_dir = os.path.expanduser('~') + '/gardenr'
    if not os.path.exists(home_dir):
        os.mkdir(home_dir)
    with open(home_dir + '/plant_id.txt', 'w') as f:
        f.write(new_plant_id)
        
if __name__ == "__main__":
    main()


