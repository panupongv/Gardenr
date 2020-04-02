import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

def split_to_datapoints(tasks, raw_string, ios_user):
    res = []
    counter = 0
    tag = "iOS" if ios_user else "Non iOS"
    if ios_user is None:
        tag = "Combined"
    for line in raw_string.split('\n'):
        
        for val in line.split('\t'):
            res.append([tasks[counter], tag, round(float(val))])
        counter += 1
    return res

non_ios = """5	5	5	4	5	3	5	5
5	4	2.5	2	5	5	5	4
5	4	4	1	5	4	4	3
4	4	5	2	5	5	4	4
5	4	5	4	5	4	4	4
5	5	5	4	5	5	4	4
3.5	4	5	1	5	2	3.5	2
5	4	4.5	3	5	5	4	2
5	4	5	5	5	3	5	2"""

ios = """5	5	5	5	4	5	5
5	5	4	4	5	3	4
2	5	5	4	4	4	3.5
4	5	5	5	5	4	4
4	5	5	5	4	5	4
3	5	5	4	4	4	4
5	3	5	2	2	3	3
3	5	5	4	5	5	4
4	5	5	5	5	5	3.5"""

raw_tasks = """ Access a plant using a search bar
     Access the owner profile of a plant
     Access the shareable code of a plant
     Edit plant information
     Edit user information
     Inspect a graph in full-screen mode
     Inspect a graph from a different date
     Logout
     Unsubscribe to a plant"""
tasks = [x.strip() for x in raw_tasks.split('\n')]

data_rows = []
data_rows.extend(split_to_datapoints([str(x) for x in range(1, len(tasks)+1)], non_ios, False))
data_rows.extend(split_to_datapoints([str(x) for x in range(1, len(tasks)+1)], ios, True))

# data_rows.extend(split_to_datapoints(["Average" for x in tasks], non_ios, False))
# data_rows.extend(split_to_datapoints(["Average" for x in tasks], ios, True))


# data_rows.extend(split_to_datapoints(tasks, non_ios, None))
# data_rows.extend(split_to_datapoints(tasks, ios, None))

colors = ["#3597b0", "#008a45", "#444444"]
# colors = ["#008a45"]

data_frame = pd.DataFrame(data_rows)
data_frame.columns = ['Task', 'User Type', 'Usability Rating']

boxplot = sns.boxplot(x='Task', y='Usability Rating', hue='User Type',
data=data_frame, palette=sns.color_palette(colors),
medianprops={'color':'red'}, showmeans=True,
meanprops={"marker":"x","markerfacecolor":"yellow", "markeredgecolor":"yellow"})

handles=boxplot.get_legend_handles_labels()
boxplot.legend(handles, ["Mean"])
# boxplot.set_xticklabels(boxplot.get_xticklabels(), rotation=-45)

# print(data_rows)

# df = [[0, 0, 0, 0, 0] for x in tasks]
# for line in data_rows:
#     task_index = tasks.index(line[0])
#     df[task_index][line[2]-1] += 1

# sns.heatmap(np.flip(np.transpose(np.array(df))), annot=True, cmap=sns.color_palette("BuGn_r"))

plt.show()


