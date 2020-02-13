def user_id(): return 'X' * 28
def plant_id(): return 'X' * 20
def auto_generated_id(): return 'X' * 20


def size_sum(data, multipliers, max_depth, depth_count = 0):
    if depth_count >= max_depth:
        return 0
    multiplier = multipliers[depth_count] if depth_count < len(multipliers) else 1
    level_sum = 0
    for pair in data.items():
        level_sum += (len(pair[0]) + size_sum(pair[1], multipliers, max_depth, depth_count+1))
    return level_sum * multiplier


def users_tree_size(entry_count):

    structure = {'users':
                    {user_id():
                        {'description':200,
                         'imageUrl':173, 
                         'name':20}}}

    multipliers = [1, entry_count, 1]

    return size_sum(structure, multipliers, 3)


def plants_tree_size(entry_count):

    structure = {'plants':
                    {'plant_id':
                        {'description':200,
                        'imageUrl':173,
                        'isPublic':5,
                        'moisture':5,
                        'name':20,
                        'ownerId':28,
                        'temperature':5,
                        'timeUpdated':13,
                        'utcTimeZone':2}}}

    multipliers = [1, entry_count, 1]

    return size_sum(structure, multipliers, 3)


def sensor_values_tree_size(entry_count):
    structure = {'sensorValues':
                    {plant_id():
                        {'YYYYMMDD':
                            {'hhmm':
                                {'moisture':5,
                                 'temperature':5}}}}}

    multipliers = [1, entry_count, 8, 48, 1]

    return size_sum(structure, multipliers, 5)

def qr_instances_tree_size(entry_count):
    structure = {'qrInstances':
                    {plant_id():
                        {auto_generated_id():17}}}
    
    multipliers = [1, entry_count, 1]

    return size_sum(structure, multipliers, 3)


def owned_plants_tree_size(user_count, plants_per_user):
    structure = {'ownedPlants':
                    {user_id():
                        {plant_id():
                            {auto_generated_id():20}}}}
    
    multipliers = [1, user_count, plants_per_user, 1]

    return size_sum(structure, multipliers, 4)


def following_plants_tree_size(user_count, plants_per_user):
    structure = {'followingPlants':
                    {user_id():
                        {plant_id():
                            {auto_generated_id():20}}}}
    
    multipliers = [1, user_count, plants_per_user]

    return size_sum(structure, multipliers, 4)


if __name__ == "__main__":

    owned_plants_per_user = 10
    following_plants_per_user = 10

    for i in range(0, 10):
        user_count = 10 ** i
        plant_count = i * owned_plants_per_user

        total_size = users_tree_size(user_count) + \
                     plants_tree_size(plant_count) + \
                     sensor_values_tree_size(plant_count) + \
                     qr_instances_tree_size(plant_count) + \
                     owned_plants_tree_size(user_count, following_plants_per_user) + \
                     following_plants_tree_size(user_count, following_plants_per_user)

        print("User Count: " + str(user_count))
        print(f'{total_size * 0.00000095367432} mb \n')
