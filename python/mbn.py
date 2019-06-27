from decimal import *
import collections
import time
from random import randint

# Mu Generator
def MuGenerator(b, n, mu, i, j,p):
    M = Decimal(b)/Decimal(10**n-mu)
    P = int((10**p)*M)
    R = (P%10**(i+j)-P%10**i)/10 ** i
    return R

#Count time
start_time = time.time()

#Parameters
b = 1
n = 8
mu =  7192
# mu = randint(1000, 9999)
p = 10000
i = 5877
# i = randint(1000, 9999)
j = 20
getcontext().prec = p

#Print result
print MuGenerator(b, n, mu, i, j,p)

#Print time
print("--- %s seconds ---" % (time.time() - start_time))
