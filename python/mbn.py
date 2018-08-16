def Mbn(b, n, mu, i, j,p):
    M = Decimal(b)/Decimal(10**n-mu)
    SCF = int((10**p)*M)
    RCF = (SCF%10**(i+j)-SCF%10**i)/10 ** i
    return RCF

from decimal import *
import collections
import time
from random import randint

start_time = time.time()
b = 1
n = 8
mu = randint(1000, 9999)
p = 10000
i = randint(1000, 9999)
j = 20
getcontext().prec = p

print Mbn(b, n, mu, i, j,p)


print("--- %s seconds ---" % (time.time() - start_time))