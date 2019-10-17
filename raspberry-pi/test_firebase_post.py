from private import database_key
from firebase import firebase

db = firebase.FirebaseApplication(database_key, None)

plant_id = 123
moisture = 999
temperature = 999
date = 20191013
time = 2330


data = {'temperature':temperature,
        'moisture':moisture}

res = db.put('sensor_values/%d/%d' % (plant_id, date), str(time), data)
print(res)


plant_display_data = {'time_updated': date * 10000 + time,
                      'moisture': moisture,
                      'temperature': temperature}


res1 = db.put('plants/%d/' % plant_id, 'display_values', plant_display_data)
print(res1)