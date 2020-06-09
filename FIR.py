import matplotlib.pyplot as plt

# n = 2   # nth order
taps = 3    # number of multiplication operations
# h = [1, 2, 2, 1]    # filter coefficients

# x = [1, 2, 1]   # signal in discrete time

def FIR(n, h, x):
    y = []  # output list
    LTI = [0] * n   # memory to store in LTI data delay
    
    # iterate through the signal
    for i in x:
        LTI_sum = 0 
        
        # produce a summation of LTI delays times their corresponding filter coeff.
        for j in range(n):
            LTI_sum += (LTI[j] * h[j + 1])

        # add the product of the x[i] and the first coeff. with the LTI_sum
        output = (i * h[0]) + LTI_sum
        # add output at the end of the y[n] list
        y.append(output)

        # update LTI memory delays at the beginning of the LTI list
        LTI.insert(0, i)
        # delete the last memory delay
        del LTI[-1]
    
    return y

def main():
    # discrete time signal
    x = [112722,
        112749,
        112828,
        112878,
        112874,
        112840,
        112824,
        112838,
        112861,
        112865,
        112841,
        112860,
        112858,
        112784,
        112778,
        112784,
        112815,
        112854,
        112896,
        112884,
        112844,
        112835,
        112848,
        112903,
        112949,
        112930,
        112794,
        112761,
        112814,
        112880,
        112911,
        112891,
        112876,
        112865,
        112897,
        112909,
        112903,
        112893,
        112916,
        112866,
        112810,
        112816,
        112822,
        112872,
        112923,
        112959,
        112939,
        112903,
        112904,
        112932,
        112969,
        112995,
        112909,
        112789,
        112789,
        112861,
        112932,
        112952,
        112913,
        112898,
        112907,
        112933,
        112947,
        112935,
        112930,
        112948,
        112892,
        112879,
        112889,
        112910,
        112940,
        112968,
        112972,
        112941,
        112910,
        112915,
        112955,
        112992,
        112983,
        112844,
        112803,
        112860,
        112934,
        112981,
        112989,
        112939,
        112917,
        112937,
        112959,
        112960,
        112940,
        112955,
        112890,
        112869,
        112907,
        112927,
        112943,
        112974,
        112982,
        112970]
    
    # print the filtered output signal
    y = FIR(2, [1, -1.247, 0.320], x)
    xaxis = list(range(0, 98, 1))
    del y[0]
    del y[0]
    print(y)

    # plotting the points  
    plt.plot(xaxis, y) 
    
    # naming the x axis 
    plt.xlabel('x - axis') 
    # naming the y axis 
    plt.ylabel('y - axis') 
    
    # giving a title to my graph 
    plt.title('My first graph!') 
    
    # function to show the plot 
    plt.show() 
    

if __name__ == "__main__":
    main()
