/* 
    Constructor
    Input parameters:
    n       nth order
    a       second LTI set filter coefficients
    b       first LTI set filter coefficients
    x1      input signal in discrete time
    x2      previous input signal in discrete time
*/
function inputSignal(n, a, b, x1, x2) {
    this.n = n;
    this.a = a;
    this.b = b;
    this.x1 = x1;
    this.x2 = x2;
}

/*
    Function: Create an array of size n
    Return: array of size n
*/
function createList(n) {
    var arr = [], i;
    for (i = 0; i < n; i++) {
        arr.push(i);
    }
    return arr;
}

/*
    Function: Inherit inputSignal parameters. Use parameters to run an implementation
              of a normalized digital biquad IIR filter, form 1. See https://www.wikiwand.com/en/Digital_biquad_filter
              for more info. 
    Return: An IIR filtered signal, y, as an array
*/
inputSignal.prototype.IIR = function() {
    var y = [];     // output list
    var b_LTI = createList(this.n);     // memory to store in the first IIR set of LTI data delay
    var a_LTI = createList(this.n);     // memory to store in the second IIR set of LTI data delay
    var output = 0;     // output placeholder for each iteration

    // iterate through the two signals (x1, x2)
    for (i = 0; i < this.x1.length; i++) {
        var b_LTI_sum = 0;      
        var a_LTI_sum = 0;
        var b_tentative_IIR = 0;

        // produce a summation for both sets of LTI delays times their corresponding filter coeff.
        for (j = 0; j < this.n; j++) {
            b_LTI_sum = b_LTI_sum + (b_LTI[j] * this.b[j + 1]);
            
            // skip second LTI set during initial iteration
            if (j == 0) {
                continue;
            }

            a_LTI_sum = a_LTI_sum + (a_LTI[j] * this.a[j + 1]);
        }

        // produce the single output from the first LTI set
        b_tentative_IIR = (x1[i] * b[0]) + b_LTI_sum;

        // produce the summation from input signal x1 and previous signal x2
        output = b_tentative_IIR + a_LTI_sum;
        // add output at the end of the y[n] list
        y.push(output);
        
        // update LTI memory delays at the beginning of the LTI list
        b_LTI.unshift(this.x1[i]);
        a_LTI.unshift(this.x2[i]);
        // delete the last memory delay
        b_LTI.pop();
        a_LTI.pop();
    }
    return y
};
