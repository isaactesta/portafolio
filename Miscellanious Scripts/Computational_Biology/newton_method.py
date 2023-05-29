# Implementation of Newton's Method to find the minima
# Isaac Testa


import numpy as np
from numpy.linalg import inv
import matplotlib.pyplot as plt

def dst(x,y):
    X = np.power((x-1),2)
    Y = np.power((y-1),2)
    return np.sqrt(X+Y)

#def grad_F_x(x,y):
#    return -400*x*(y-np.power(x,2)) - 2*(1-x)

#def grad_F_y(x,y):
#    return  200*(y-np.power(x,2))

a = 0.1
x = [-2.5]
y = [2]

i = 0
dist = [dst(x[0],y[0])]

while dist[i] > 0.001:
    g_F = (-400*x[i]*(y[i]-np.power(x[i],2)) - 2*(1-x[i]),200*(y[i]-np.power(x[i],2)))
    grad_F = np.array(g_F)
    hessian = ([1200*x[i]**2-400*y[i]+2, -400*x[i]], [-400*x[i], 200])
    hes = np.array(hessian, dtype='float')
    inv_hes = inv(hes)
    change = a*np.matmul(inv_hes,grad_F)
    x.append(x[i] - change[0])
    y.append(y[i] - change[1])
    dist.append(dst(x[i+1],y[i+1]))
    i += 1

print(i)

plt.figure(1)
plt.plot(x,y, '-o')
plt.xlabel('X value')
plt.ylabel('Y Value')
plt.title("Scatter plot of trajectory using Newton's method")

plt.figure(2)
plt.plot(dist)
plt.title("Progress of algorithm using Netwon's method")
plt.ylabel('Distance to minimum point')
plt.xlabel('Point number')
plt.show()
