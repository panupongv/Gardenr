import time
import smbus
import spidev

class SensorReader:
    def __init__(self):
        i2c_ch = 1

        # TMP102 address on the I2C bus
        self.i2c_address = 0x48

        # Register addresses
        self.reg_temp = 0x00
        self.reg_config = 0x01
        
        
        # Initialize I2C (SMBus)
        self.bus = smbus.SMBus(i2c_ch)
        
        self.spi = spidev.SpiDev()
        self.spi.open(0, 0)
        
        self.sample_size = 10
    
    def _twos_complement(self, val, bits):
        if (val & (1 << (bits - 1))) != 0:
            val = val - (1 << bits)
        return val
    
    def _read_temperature(self):

        # Read temperature registers
        val = self.bus.read_i2c_block_data(self.i2c_address, self.reg_temp, 2)
        temp_c = (val[0] << 4) | (val[1] >> 5)

        # Convert to 2s complement (temperatures can be negative)
        temp_c = self._twos_complement(temp_c, 12)

        # Convert registers value to temperature (C)
        temp_c = temp_c * 0.0625

        return temp_c
    
    def _analog_input(self, channel):
        self.spi.max_speed_hz = 1350000
        adc = self.spi.xfer2([1,(8+channel)<<4,0])
        data = ((adc[1]&3) << 8) + adc[2]
        return data
    
    def _interpolate(self, analog_value):
        print(analog_value)
        x0, x1 = 0.0, 1023.0
        y0, y1 = 100.0, 0.0
        return y0 + ((y1 - y0)/(x1 - x0)) * (analog_value - x0)

    def read_sensors(self):
        
        moistures, temperatures = [], []
        
        for i in range(self.sample_size):
            moisture_analog = self._analog_input(0)
            moisture_percentage = self._interpolate(moisture_analog)
            temperature = self._read_temperature()
            
            moisture_percentage = round(moisture_percentage, 2)
            temperature = round(temperature, 2)
            
            moistures.append(moisture_percentage)
            temperatures.append(temperature)
            
            print("zMoisture:", moisture_percentage)
            print("Temperature: " + str(temperature) + ' C\n') 
            
            time.sleep(0.5)
        
        median_index = self.sample_size//2
        return moistures[median_index], temperatures[median_index]


if __name__ == "__main__":
    x = SensorReader()
    moisture_percentage, temperature = x.read_sensors()
    print("Final")
    print("Moisture:", moisture_percentage)
    print("Temperature: " + str(temperature) + ' C\n') 
   
