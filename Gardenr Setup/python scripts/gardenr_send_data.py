from private import api_keys

import pyrebase
import os

from gardenr_read_sensors import SensorReader

from time import sleep
from datetime import datetime, timedelta
from random import randint

days_before_expiring = 7

def main(delayed=True): 
    plant_id_path = os.path.expanduser('~') + '/gardenr/plant_id.txt' 
    
    if not os.path.exists(plant_id_path):
        return
    
    plant_id = None
    with open(plant_id_path) as f:
        plant_id = f.read()
        
    if plant_id != None:
        firebase = pyrebase.initialize_app(api_keys)
        db = firebase.database()
        
        time = datetime.now()
        time_to_remove = time - timedelta(days=days_before_expiring)
        
        timestamp = time.strftime("%Y%m%d %H%M")
        datestamp_to_remove = time_to_remove.strftime("%Y%m%d")
        
        check_exist = db.child('plants').child(plant_id).child('name').get()
        if check_exist == None:
            return
        
        reader = SensorReader()
        moisture, temperature = reader.read_sensors()

        date, time = timestamp.split()

        if delayed:
            sleep(randint(0, 30))

        db.child('plants').child(plant_id).child('moisture').set(moisture)
        db.child('plants').child(plant_id).child('temperature').set(temperature)
        db.child('plants').child(plant_id).child('timeUpdated').set(timestamp)
        db.child('sensorValues').child(plant_id).child(date).child(time).set({'moisture':moisture, 'temperature':temperature})
        db.child('sensorValues').child(plant_id).child(datestamp_to_remove).child(time).remove()
            
if __name__ == "__main__":
    main()
