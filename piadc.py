import spidev
import RPi.GPIO as GPIO
import time

# --- GPIO pin setup ---
CONVST = 4    # Start conversion
RESET = 22    # Reset ADC
BUSY = 27     # ADC busy status

GPIO.setmode(GPIO.BCM)
GPIO.setup(CONVST, GPIO.OUT)
GPIO.setup(RESET, GPIO.OUT)
GPIO.setup(BUSY, GPIO.IN)

# --- SPI setup ---
spi = spidev.SpiDev()
spi.open(0, 0)              # Bus 0, Device 0
spi.max_speed_hz = 1000000  # 1 MHz
spi.mode = 1                # CPOL=0, CPHA=1

# --- ADC functions ---
def reset_adc():
    GPIO.output(RESET, GPIO.HIGH)
    time.sleep(0.01)
    GPIO.output(RESET, GPIO.LOW)
    time.sleep(0.01)

def read_single_channel(channel=1):
    """Read a single channel (1-8) from AD7606-18"""
    # Start conversion pulse
    GPIO.output(CONVST, GPIO.HIGH)
    time.sleep(0.000001)
    GPIO.output(CONVST, GPIO.LOW)

    # Wait until BUSY goes low
    while GPIO.input(BUSY):
        time.sleep(0.000001)

    # Read 24 bytes (8 channels × 3 bytes each)
    raw_data = spi.readbytes(24)

    # Calculate raw value for selected channel
    i = (channel - 1) * 3
    val = (raw_data[i] << 16) | (raw_data[i + 1] << 8) | raw_data[i + 2]
    val >>= 6  # Keep 18 MSBs

    # Sign-extend 18-bit two's complement
    if val & (1 << 17):
        val -= (1 << 18)

    return val, raw_data[i:i+3]

def convert_to_voltage(raw_val, vref=5.0):
    """Convert 18-bit ADC code to voltage (±vref)"""
    return (raw_val / (2**17 - 1)) * vref

# --- Main ---
reset_adc()
time.sleep(0.1)

try:
    while True:
        raw_val, raw_bytes = read_single_channel(channel=2)  # V2+
        voltage = convert_to_voltage(raw_val, vref=5.0)      # JP4 = ±5V

        print(f"Raw bytes: {raw_bytes}")
        print(f"Raw integer: {raw_val}")
        print(f"Voltage: {voltage:.3f} V")
        print("-" * 30)

        time.sleep(0.5)

except KeyboardInterrupt:
    spi.close()
    GPIO.cleanup()
