E.setFlags({pretokenise:1});

//pin assignments
var interrupt_pin = 31;
var scl_pin = 2;
var sda_pin = 1;


//object that will contain calculated data that will be sent out via bluetooth
var saturated_data = {
  n_spo2: 0,  //SPO2 value
  ch_spo2_valid: false,  //shows if the SPO2 calculation is valid
  n_heart_rate: 0, //heart rate value
  ch_hr_valid: false,
  temperature: 0
};


var heart_sensor;
var i2c = new I2C();

pinMode(interrupt_pin, 'input'); //sets pin as input for interrupt from max30102 (logic low when MAX30102 is done converting data to FIFO register)


//setting up i2c port (software)
i2c.setup({ sda: sda_pin, scl: scl_pin });
pinMode(D1, 'opendrain');
pinMode(D2, 'opendrain');

heart_sensor = require("https://raw.githubusercontent.com/aklapisz/MAX30102_Puck.JS/master/maxim.js").connect(i2c);




//initializing heart sensor
heart_sensor.reset();
heart_sensor.read8(0x00);
heart_sensor.init();


setInterval(function() {
  heart_sensor.set_temperature_read();
  heart_sensor.getTemperature(saturated_data, 1);
  heart_sensor.read_fifo_data(digitalRead, interrupt_pin);
  heart_sensor.data_saturation(saturated_data);
  console.log("HR: " + saturated_data.n_heart_rate);
  console.log("SpO2: " + saturated_data.n_spo2);
  console.log("Temperature: " + saturated_data.temperature);
}, 1000);