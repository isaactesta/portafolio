# Modelling of Random Walks of Biological Organism
# this model explored the Spread and Behaviour in Self Avoiding Walks
# Isaac Testa

import numpy as np
import matplotlib.pyplot as plt

np.random.seed(150)

def distance_centroid(x,y,h,g):
    x_dst = (x[-1]-np.mean(x))**2
    y_dst = (y[-1]-np.mean(y))**2
    return np.sqrt(x_dst + y_dst)

def distance_origin(x,y):
    return np.sqrt(x[-1]**2 + y[-1]**2)

x = []
y = []
dst = []
ls_d = []
def random_walk(x,y,dst):
    self_interactions = 0
    x = []
    y = []
    dst = []
    g = 0 # index for x
    h = 0 # index for y
    counts1,counts2,counts3,counts4 = 0,0,0,0
    x_value,y_value = 0, 0
    for i in range(14):
        a = np.random.randint(1,5)
        if a == 1:
            y_value += 1
            y.append(y_value)
            x.append(x_value)
            counts1 +=1
        if a == 2:
            y_value -= 1
            y.append(y_value)
            x.append(x_value)
            counts2 += 1
        if a == 3:
            x_value += 1
            x.append(x_value)
            y.append(y_value)
            counts3 +=1
        if a == 4:
            x_value -= 1
            x.append(x_value)
            y.append(y_value)
            counts4 += 1
        if y[h] == y[h-1]:
            self_interactions += 1
        if x[g] == x[g-1]:
            self_interactions += 1
        g += 1
        h += 1
        dst.append(distance_centroid(x,y,h,g))
    ls_d = distance_origin(x,y)
    return  np.mean(dst), self_interactions, ls_d


distances,self_interactions,last_d = np.zeros(10000),np.zeros(10000),np.zeros(10000)
for i in range(10000):
        distances[i],self_interactions[i],last_d[i] = random_walk(x,y,dst)

f1 = plt.figure(1)
plt.hist(last_d, bins=25)
plt.title('Distances of last point to origin')
f2 = plt.figure(2)
plt.hist(distances, bins=40)
plt.title('Averages of euclidian distances to centroid')
plt.show()
