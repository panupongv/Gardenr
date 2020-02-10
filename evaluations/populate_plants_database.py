from private import api_keys

import sys
import pyrebase
from random import random

def add_plant(db, user_id, plant_name):
    mock_data = {'name':plant_name, 
            'description':'for performance evaluation', 
            'imageUrl':'', 
            'isPublic':True,
            'moisture':random() * 100,
            'temperature':random() * 40,
            'ownerId':user_id,
            'timeUpdated':'20200206 1500',
            'utcTimeZone':0}
    plant_id = db.child('plants').push(mock_data)['name']
    return plant_id

def add_to_garden(db, user_id, plant_id):
    db.child('ownedPlants').child(user_id).push(plant_id)

def add_to_following_list(db, user_id, plant_id):
    db.child('followingPlants').child(user_id).push(plant_id)

def main():
    if len(sys.argv) < 4:
        print("Needs user id, plant count and name prefix as arguments")
        return

    user_id = sys.argv[1]
    count = int(sys.argv[2])
    prefix = sys.argv[3]

    firebase = pyrebase.initialize_app(api_keys)
    db = firebase.database()

    for i in range(count):
        plant_name = prefix+str(i)
        plant_id = add_plant(db, user_id, plant_name)
        add_to_garden(db, user_id, plant_id)

if __name__ == "__main__":
    main()


