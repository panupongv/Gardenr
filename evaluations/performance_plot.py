import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

s_0 = [119,131, 173, 174,179]
s_5 = [134,153, 202, 291,2220]
s_10 = [261,305, 353, 439,895]
s_20 = [130,156, 263, 343,1300] 
s_50 = [147,309, 484, 871,4750]


xs = [0, 5, 10, 20, 50]
data = [s_0, s_5, s_10, s_20, s_50]
df = []

for pair in zip(xs, data):
    x, ys = pair
    
    df.append([x, 25, ys[0]])
    df.append([x, 50, ys[1]])
    df.append([x, 75, ys[2]])

df = pd.DataFrame(df)
df.columns = ["Size", "Percentile", "Duration"]


# ax = plt.plot(data=df, x="Size",y="Duration",hue="Percentile")
for d in range(5):
    plt.plot(xs, [x[d] for x in data])
# plt.fill_between(x=xs, y1=[y[0] for y in data], y2=[y[2] for y in data])
plt.show()