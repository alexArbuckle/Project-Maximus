# import <
import RPi.GPIO as GPIO
from sys import (exit, argv)

# >


# environment <
pinIsCharging = int(argv[1])
pinLowVoltage = int(argv[2])

# >


# setup GPIO mode <
# setup GPIO pins <
GPIO.setmode(GPIO.BCM)
GPIO.setup(pinIsCharging, GPIO.IN)
GPIO.setup(pinLowVoltage, GPIO.IN)

# >


# get charging state <
# get low voltage state <
stateIsCharging = GPIO.input(pinIsCharging)
stateLowVoltage = GPIO.input(pinLowVoltage)

# >


# cleanup board #
GPIO.cleanup()


exit(1 if (stateIsCharging and not stateLowVoltage) else 0)