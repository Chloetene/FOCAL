''' Input parameters:
    n       nth order
    a       second LTI set filter coefficients
    b       first LTI set filter coefficients
    x1      input signal in discrete time
    x2      previous input signal in discrete time

    Returns an IIR filtered signal, y
'''
def IIR(n, a, b, x1, x2):
    y = []  # output list
    b_LTI = [0] * n     # memory to store in the first IIR set of LTI data delay
    a_LTI = [0] * n     # memory to store in the second IIR set of LTI data delay
    
    # iterate through the two signals (x1, x2)
    for i in range(len(x1)):
        b_LTI_sum = 0
        a_LTI_sum = 0
        b_tentative_IIR = 0
        
        # produce a summation for both sets of LTI delays times their corresponding filter coeff.
        for j in range(n):
            b_LTI_sum += (b_LTI[j] * b[j + 1])
            
            # skip second LTI set during initial iteration
            if (j == 0):
                continue
            
            a_LTI_sum += (a_LTI[j] * a[j + 1])
        
        # produce the single output from the first LTI set
        b_tentative_IIR = (x1[i] * b[0]) + b_LTI_sum
        
        # produce the summation from input signal x1 and previous signal x2
        output = b_tentative_IIR + a_LTI_sum
        # add output at the end of the y[n] list
        y.append(output)
        
        # update LTI memory delays at the beginning of the LTI list
        b_LTI.insert(0, x1[i])
        a_LTI.insert(0, x2[i])
        # delete the last memory delay
        del b_LTI[-1]
        del a_LTI[-1]

    return y
