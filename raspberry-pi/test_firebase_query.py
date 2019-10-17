from private import database_key
from firebase import firebase

db = firebase.FirebaseApplication(database_key, None)


all_plants_all_data = db.get('/plants', None)
print("\nWhole plant collection")
print(all_plants_all_data, '\n')

plant_123 = db.get('plants/123', None)
print("Plant 123")
print(plant_123, '\n')

plant_123_time_series = db.get('sensor_values/123/20191013', None)
print("Time series data")
print(plant_123_time_series, '\n')
