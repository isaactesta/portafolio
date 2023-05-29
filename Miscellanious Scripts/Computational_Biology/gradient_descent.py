# Implementation of Gradient Descent Method to find the minima
# Isaac Testa


import numpy as np
import matplotlib.pyplot as plt

def dst(x,y):
    X = np.power((x-1),2)
    Y = np.power((y-1),2)
    return np.sqrt(X+Y)

def grad_F_x(x,y):
    return -400*x*(y-np.power(x,2)) - 2*(1-x)

def grad_F_y(x,y):
    return  200*(y-np.power(x,2))

a = 0.001
x = [-2.5]
y = [2]

i = 0
dist = [dst(x[0],y[0])]

while dist[i] > 0.001:
    x.append(x[i] - a*grad_F_x(x[i],y[i]))
    y.append(y[i] - a*grad_F_y(x[i],y[i]))
    dist.append(dst(x[i+1],y[i+1]))
    i += 1


plt.figure(1)
plt.plot(x,y, '-o')
plt.xlabel('X value')
plt.ylabel('Y Value')
plt.title('Scatter plot of trajectory using Gradient Descent')

plt.figure(2)
plt.plot(dist)
plt.title('Progress of algorithm using Gradient Descent')
plt.ylabel('Distance to minimum point')
plt.xlabel('Point number')
plt.show()
