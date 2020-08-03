E.setFlags({pretokenise:1});

//pin assignments
var interrupt_pin = 31;
var scl_pin = 2;
var sda_pin = 1;


//object that will contain calculated data that will be sent out via bluetooth
var saturated_data = {
  temperature: 0
};


var temp_sensor;
var i2c = new I2C();

pinMode(interrupt_pin, 'input'); //sets pin as input for interrupt from max30102 (logic low when MAX30102 is done converting data to FIFO register)


//setting up i2c port (software)
i2c.setup({ SDA: sda_pin, SCL: scl_pin }); //names of pins 1-sda, 2-scl
pinMode(D1, 'opendrain');
pinMode(D2, 'opendrain'); //hrs datasheet

temp_sensor = require("https://raw.githubusercontent.com/aklapisz/MAX30102_Puck.JS/master/maxim.js").connect(i2c);
//is the path the same for HR and Temp? I kept it the same as the HR code - chloe



//initializing heart sensor
temp_sensor.initialize();

setInterval(function() {
  temp_sensor.getTemperature_two(saturated_data, 1); //return saturated_data.temperature
  //temp_sensor.data_saturation(saturated_data); //dont need for temperature sensor MAX30205
  console.log("Temperature: " + saturated_data.temperature);
}, 1000);