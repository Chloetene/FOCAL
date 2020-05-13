E.setFlags({pretokenise:1});

//NOTE!!!
/* In order to use this library properly, this object must be declared in the main code...

var saturated_data = {
  n_spo2: 0,  //SPO2 value
  ch_spo2_valid: false,  //shows if the SPO2 calculation is valid
  n_heart_rate: 0, //heart rate value
  ch_hr_valid: false,
  temperature: 0
};
*/

const ST = 4;
const FS = 25;

const MAX_HR = 125;
const MIN_HR = 40;
const TYPICAL_HR = 60;

const BUFFER_SIZE = FS * ST;
const FS60 = FS * 60;
const INIT_INTERVAL = FS60/TYPICAL_HR;

const LOWEST_PERIOD = FS60/MAX_HR;
const HIGHEST_PERIOD = FS60/MIN_HR;
const mean_X = (BUFFER_SIZE-1)/2.0;
const min_autocorrelation_ratio = 0.5;
const min_pearson_correlation = 0.8;
const sum_X2 = 83325;


//object that holds all relavant register addresses on the MAX30102
const C = {
  //main address
  I2C_ADDR: 0b1010111,

  //register addresses
  REG_INTR_STATUS_1: 0x00,
  REG_INTR_STATUS_2: 0x01,
  REG_INTR_ENABLE_1: 0x02,
  REG_INTR_ENABLE_2: 0x03,
  REG_FIFO_WR_PTR: 0x04,
  REG_OVF_COUNTER: 0x05,
  REG_FIFO_RD_PTR: 0x06,
  REG_FIFO_DATA: 0x07,
  REG_FIFO_CONFIG: 0x08,
  REG_MODE_CONFIG: 0x09,
  REG_SPO2_CONFIG: 0x0A,
  REG_LED1_PA: 0x0C,
  REG_LED2_PA: 0x0D,
  REG_PILOT_PA: 0x10,
  REG_MULTI_LED_CTRL1: 0x11,
  REG_MULTI_LED_CTRL2: 0x12,
  REG_TEMP_INTR: 0x1F,
  REG_TEMP_FRAC: 0x20,
  REG_TEMP_CONFIG: 0x21,
  REG_PROX_INT_THRESH: 0x30,
  REG_REV_ID: 0xFE,
  REG_PART_ID: 0xFF
};


//object that holds all data to be used for HR/SpO2 functions
let register_data = {
  ir_buffer: new Array(BUFFER_SIZE),
  red_buffer: new Array(BUFFER_SIZE)
};


let processingData = {
  an_x: new Array(BUFFER_SIZE).fill(0),
  an_y: new Array(BUFFER_SIZE).fill(0),
  beta_ir: 0,
  beta_red: 0,
  f_y_ac: 0,
  f_x_ac: 0,
  f_ir_sumsq: 0,
  f_red_sumsq: 0,
  n_last_peak_interval: INIT_INTERVAL,
  ratio: 0,
  correl: 0
};


////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Main functions to communicate with MAX30102 via I2C


//creates software I2C port for Espruino devices
function MAX30102(i2c) {
    this.i2c = i2c;
    this.ad = C.I2C_ADDR;
}


//basic function to read 8 bits from MAX30102 from a specified register via i2c
MAX30102.prototype.read8 = function(reg) {
    this.i2c.writeTo(this.ad, reg);
    return this.i2c.readFrom(this.ad,1);
};



//basic function to write 8 bits to a specified register in the MAX30102 via i2c
MAX30102.prototype.write8 = function(reg, value) {
    this.i2c.writeTo(this.ad, reg, value);
};


//function to reset the MAX30102
//note: this should be called before initilzing the MAX30102 to clear all registers
MAX30102.prototype.reset = function(){
  this.write8(C.REG_MODE_CONFIG,0x40);
};

//function to put sensor in sleep mode
MAX30102.prototype.sleep = function(){
  this.write8(C.REG_MODE_CONFIG,0x83);
};

//initilizes the settings of the MAX30102 by writing a specific configuration to each desired register and also resets FIFO pointers
//note:to use different settings, change the value being written to the register that controls the setting (reference MAX30102 datasheet)
MAX30102.prototype.init = function(){
  
  this.write8(C.REG_INTR_ENABLE_1, 0xc0); // INTR setting  
  this.write8(C.REG_INTR_ENABLE_2, 0x02); // Add setting for temp reading
   
  this.write8(C.REG_FIFO_WR_PTR,0x00);  //FIFO_WR_PTR[4:0]
  this.write8(C.REG_OVF_COUNTER, 0x00);  //OVF_COUNTER[4:0]
  this.write8(C.REG_FIFO_RD_PTR, 0x00);  //FIFO_RD_PTR[4:0]
  
  this.write8(C.REG_FIFO_CONFIG, 0x4f);  //sample avg = 0, fifo rollover=false, fifo almost full = 3
  this.write8(C.REG_MODE_CONFIG,0x03);  //0x02 for Red only, 0x03 for SpO2 mode 0x07 multimode LED
  this.write8(C.REG_SPO2_CONFIG,0x27);  // SPO2_ADC range = 4096nA, SPO2 sample rate (100 Hz), LED pulseWidth (411uS)
    
  this.write8(C.REG_LED1_PA,0x24);  //Choose value for ~ 7mA for LED1
  this.write8(C.REG_LED2_PA,0x24);  // Choose value for ~ 7mA for LED2
  this.write8(C.REG_PILOT_PA,0x7f);   // Choose value for ~ 25mA for Pilot LED 
  
};


//reads data stores in FIFO register
//note:this data holds amount of reflected light, NOT the actual heart rate/SPo2.
//in order to get heart rate/SpO2, use this function to collect data and then send collected data to saturate_data
//let temp_data_array = new Uint32Array(100).fill(0);

MAX30102.prototype.read_fifo_data = function(digitalRead, interrupt_pin){
  
  let i = 0;
  let temp_data_array = new Array(BUFFER_SIZE);
  
  for(i=0;i<BUFFER_SIZE;i++){
    
    while(digitalRead(interrupt_pin)==1);
    
    this.i2c.writeTo(this.ad, C.REG_INTR_STATUS_1);
    this.i2c.readFrom(this.ad,1);
    
    this.i2c.writeTo(this.ad, C.REG_INTR_STATUS_2);
    this.i2c.readFrom(this.ad,1);
  
    this.i2c.writeTo(this.ad, C.REG_FIFO_DATA);
    temp_data_array[i] = this.i2c.readFrom(this.ad, 6);   
  }
  
  
  for(i=0;i<BUFFER_SIZE;i++){
    
    register_data.red_buffer[i] = 65536 * (temp_data_array[i][0]);
    register_data.red_buffer[i] += 256 * (temp_data_array[i][1]);
    register_data.red_buffer[i] += temp_data_array[i][2];

    register_data.ir_buffer[i] = 65536 * (temp_data_array[i][3]);
    register_data.ir_buffer[i] += 256 * (temp_data_array[i][4]);
    register_data.ir_buffer[i] += temp_data_array[i][5];
  }
    
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Functions for temperature reading


//sends an activate bit to MAX30102 to store a temperature reading
//note: this function needs to be called first, then call getTemperature to get the temperature reading
MAX30102.prototype.set_temperature_read = function(){
  heart_sensor.write8(C.REG_TEMP_CONFIG, 0x01);
};

//gets a temperature reading from the MAX30102
//note: set_temperature_read needs to be called first before using this function
MAX30102.prototype.getTemperature = function(saturated_data, unit){
  
  var temperature_int;
  var temperature_frac;
  var temperature;
  
  this.read8(C.REG_INTR_STATUS_1);
  this.read8(C.REG_INTR_STATUS_2);
 
  temperature_int = this.read8(C.REG_TEMP_INTR)[0];  
  temperature_frac = this.read8(C.REG_TEMP_FRAC)[0];
  
  temperature = temperature_int + (temperature_frac * 0.0625);
  
  if(unit == 0){
    saturated_data.temperature = temperature;
  }else{
    saturated_data.temperature = 1.80 * (temperature) + 32.00;
  }
  
};


////////////////////////////////////////////////////////////////////////////////////////////////////////////




////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Functions for HR/SpO2 calculation

MAX30102.prototype.data_saturation = function(saturated_data){
  
  var k = 0;
  var buffer_len = BUFFER_SIZE;
  var f_ir_mean = 0;
  var f_red_mean = 0;
  var xy_ratio = 0;
  var x = 0;
  var spo2 = 0;

  processingData.n_last_peak_interval = INIT_INTERVAL;

//calculate DC mean of ir and red buffers
  for(k=0; k<buffer_len; ++k){ 
    f_ir_mean = register_data.ir_buffer[k] + f_ir_mean;
    f_red_mean = register_data.red_buffer[k] + f_red_mean;
  }

  f_ir_mean = f_ir_mean/buffer_len;
  f_red_mean = f_red_mean/buffer_len;
  
//remove DC from both buffers
  for(k=0; k<buffer_len; ++k){
    processingData.an_x[k] = register_data.ir_buffer[k] - f_ir_mean;
    processingData.an_y[k] = register_data.red_buffer[k] - f_red_mean;
  }
  
//remove linear trend (baseline leveling)
  this.linear_regression_beta();
  for(k=0,x=-mean_X; k<buffer_len; ++k,++x){
    processingData.an_x[k] -= processingData.beta_ir * x;
    processingData.an_y[k] -= processingData.beta_red * x;
  }
  
//Calculate RMS of both AC signals
  this.rms(buffer_len);
  
//Calculate Pearson correlation between red and IR
  processingData.correl = (this.Pcorrelation(buffer_len)) / parseFloat(Math.sqrt(processingData.f_y_ac*processingData.f_x_ac));
  
  if(processingData.correl >= min_pearson_correlation){
    this.signal_periodicity(BUFFER_SIZE, LOWEST_PERIOD, HIGHEST_PERIOD, min_autocorrelation_ratio);
  }else processingData.n_last_peak_interval = 0 | 0;

  if(processingData.n_last_peak_interval != 0){
    saturated_data.n_heart_rate = Math.round(FS60/processingData.n_last_peak_interval);
    saturated_data.ch_hr_valid = 1;
  }else{
    processingData.n_last_peak_interval = FS;
    saturated_data.n_heart_rate = 0;  //invalid hr
    saturated_data.ch_hr_valid = 0;
    saturated_data.n_spo2_int = 0; //invalid spo2
    saturated_data.n_spo2_dec = 0;
    saturated_data.ch_spo2_valid = 0;
    return;
  }

  xy_ratio = (processingData.f_y_ac * f_ir_mean) / (processingData.f_x_ac * f_red_mean);
  
  if(xy_ratio>0.02 && xy_ratio<1.84){
    spo2 = (-45.060 * xy_ratio + 30.354) * xy_ratio + 94.845;
    saturated_data.n_spo2_int = Math.floor(spo2);
    saturated_data.n_spo2_dec = Math.floor((spo2 % 1) * 100);
    saturated_data.ch_spo2_valid = 1;
  }else{
    saturated_data.n_spo2_int = 0;  //invalid spo2
    saturated_data.n_spo2_dec = 0;
    saturated_data.ch_spo2_valid = 0;
  }
};



MAX30102.prototype.linear_regression_beta = function(){
  var x = 0;
  var beta = 0;
  var k = 0;

  for(x=-mean_X, k=0; x<=mean_X; ++x, ++k){
    beta += x * processingData.an_x[k];
  }
  processingData.beta_ir = beta/sum_X2;

  beta = 0 | 0;
  for(x=-mean_X, k=0; x<=mean_X; ++x, ++k){
    beta += x * processingData.an_y[k];
  }
  processingData.beta_red = beta/sum_X2;

};



MAX30102.prototype.autocorrelation = function(n_size, n_lag){

  var i = n_size - n_lag;
  var n_temp = n_size - n_lag;
  let sum = (0 >> 0);

  if(n_temp<=0) return sum;
  for(i=0; i<n_temp; ++i){
    sum += processingData.an_x[i] * processingData.an_x[i+n_lag];
  }
  return sum/n_temp;

};



MAX30102.prototype.rms = function(n_size){

  var i = 0;
  var r = 0;
  var sumsq = 0;
  
  for(i=0; i<n_size; ++i){
    r = processingData.an_x[i];
    sumsq += r * r;
  }
  sumsq /= n_size;
  processingData.f_ir_sumsq = parseFloat(Math.sqrt(sumsq));
  processingData.f_x_ac = parseFloat(processingData.f_ir_sumsq);

  r = 0;
  sumsq = 0;
  for(i=0; i<n_size; ++i){
    r = processingData.an_y[i];
    sumsq += r * r;
  }
  sumsq /= n_size;
  processingData.f_red_sumsq = parseFloat(Math.sqrt(sumsq));
  processingData.f_y_ac = parseFloat(processingData.f_red_sumsq);
};



MAX30102.prototype.Pcorrelation = function(n_size){

  var i = 0;
  var r = 0;

  for(i=0; i<n_size; ++i){
    r += processingData.an_x[i] * processingData.an_y[i];
  }

  return (r/n_size);

};


MAX30102.prototype.signal_periodicity = function(n_size, n_min_distance, n_max_distance, min_aut_ratio){

  var n_lag = 0;
  var aut = 0;
  var aut_left = 0;
  var aut_right= 0;
  var aut_save = 0;
  var left_limit_reached = false;
  
  n_lag = processingData.n_last_peak_interval;
  aut_save, aut = this.autocorrelation(n_size, n_lag);
  aut_left = aut;
  do{
    aut=aut_left;
    n_lag--;
    aut_left = this.autocorrelation(n_size, n_lag);
  } while(aut_left > aut && n_lag > n_min_distance);

  if(n_lag == n_min_distance){
    left_limit_reached = true;
    n_lag = processingData.n_last_peak_interval;
    aut = aut_save;
  }else n_lag++;

  if(n_lag == processingData.n_last_peak_interval){
    aut_right = aut;
    do{
      aut = aut_right;
      n_lag++;
      aut_right = this.autocorrelation(n_size, n_lag);
    } while(aut_right>aut && n_lag<n_max_distance);

    if(n_lag == n_max_distance) n_lag = 0;
    else n_lag--;
    if(n_lag == (processingData.n_last_peak_interval && left_limit_reached)) n_lag = 0;
  }

  processingData.ratio = aut / processingData.f_ir_sumsq;
  if(processingData.ratio < min_aut_ratio) n_lag = 0;
  processingData.n_last_peak_interval = n_lag;

};




////////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////////////////////////
//functions to connect library with espruino


exports.connect = function(i2c) {
  return new MAX30102(i2c);
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////
