# Implementation of Monte Carlo Method to find the minima
# Isaac Testa


import numpy as np
from scipy import special
import matplotlib.pyplot as plt


def dst(x,y):
    X = np.power((x-1),2)
    Y = np.power((y-1),2)
    return np.sqrt(X+Y)

def F(x,y):
    return 100*np.power((y-np.power(x,2)),2) + np.power((1-x),2)

a = 0.001
x = [-2.5]
y = [2]

i = 0
j = 0
dist = [dst(x[0],y[0])]
T = 0.00001
count = [dst(x[0],y[0])]
x_trial,y_trial = 0,0

while dist[i] > 0.001:
     b = np.random.uniform(0, 2*np.pi)
     x_trial = x[i] - a*np.cos(b)
     y_trial = y[i] - a*np.sin(b)
     p = np.random.uniform(0,1)
     exp = (F(x_trial,y_trial)-F(x[i],y[i]))/T
     test = special.expit(-exp)
     if p < test:
         x.append(x_trial)
         y.append(y_trial)
         dist.append(dst(x_trial,y_trial))
         i += 1
     j +=1
     count.append(dist[-1])



plt.figure(1)
plt.plot(x,y, '-o')
plt.xlabel('X value')
plt.ylabel('Y Value')
plt.title('Scatter plot of trajectory using Monte Carlo')

plt.figure(2)
plt.plot(count)
plt.title('Progress of algorithm using Monte Carlo')
plt.ylabel('Distance to minimum point')
plt.xlabel('Number of point that passed test')
plt.show()
