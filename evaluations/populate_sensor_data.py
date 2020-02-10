from private import api_keys

import sys
import pyrebase
from random import random


def tune_value():
    global moisture_acc
    global temperature_acc

    if moisture_acc < 0: moisture_acc = 0
    if moisture_acc > 100: moisture_acc = 100
    if temperature_acc < 0: temperature_acc = 0
    if temperature_acc > 40: temperature_acc = 40

def generate_data_point(time_string):
    global moisture_acc
    global temperature_acc

    moisture = moisture_acc
    temperature = temperature_acc

    moisture_acc += (random() - 0.5) * 12
    temperature_acc += (random() - 0.5) * 3

    tune_value()

    return time_string,{'moisture':round(moisture, 2),
                         'temperature':round(temperature, 2)}

def position_int_to_time(x):
    return format(x//2, "02d") + ( "00" if x % 2 == 0 else "30")

def generate_keys():
    return [position_int_to_time(x) for x in range(48)]

def main():
    if len(sys.argv) < 3:
        print("Plant Id and Data needed as arguments")
        return

    plant_id = sys.argv[1]
    date_stamp = sys.argv[2]

    firebase = pyrebase.initialize_app(api_keys)
    db = firebase.database()

    times = generate_keys()
    data_points = dict([generate_data_point(x) for x in times])

    db.child('sensorValues').child(plant_id).child(date_stamp).set(data_points)

moisture_acc = 30.0
temperature_acc = 15.0

if __name__ == "__main__":
    main()