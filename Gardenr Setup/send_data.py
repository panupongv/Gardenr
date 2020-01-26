import pyrebase
import os

from read_sensors import SensorReader

from datetime import datetime
from random import randint
from private import api_keys

def main():
    firebase = pyrebase.initialize_app(api_keys)
    print(os.path.dirname(os.path.realpath(__file__)))
    plant_id = None
    with open(str(os.path.dirname(os.path.realpath(__file__)))+ '/plant_id.txt') as f:
        plant_id = f.read()
        
    if plant_id != None:
        db = firebase.database()
        
        timestamp = datetime.now().strftime("%Y%m%d %H%M")
        
        reader = SensorReader()
        moisture, temperature = reader.read_sensors()

        date, time = timestamp.split()

        #delay(randint(0, 90) * 1000)

        db.child('plants').child(plant_id).child('moisture').set(moisture)
        db.child('plants').child(plant_id).child('temperature').set(temperature)
        db.child('plants').child(plant_id).child('timeUpdated').set(timestamp)
        db.child('sensorValues').child(plant_id).child(date).child(time).set({'moisture':moisture, 'temperature':temperature})

if __name__ == "__main__":
    main()