# Sensory Monitor System

This repository is for the development of our ENEL 500 Capstone project. It consists of the code for our Arduino Nano 33 BLE Sense Rev 2, and our Connect IQ app for a Garmin Venu 2.

## Project Description

The Sensory Monitor system helps caregivers become more alert to potential sensory triggers of their charge (person under their care) with sensory processing issues. Our Sensory Monitor is a compact and portable device that is carried by the charge. The device sends visual and vibration notifications to the caregiver through a smartwatch when volume or temperature levels in the charge’s environment exceeds certain thresholds set by the caregiver. Our device also notifies caregivers when their charge is out of proximity. This device enhances the level of care in support work by helping caregivers remain vigilant of environmental conditions that pose risks for sensory overload which may otherwise go unnoticed. These notifications allow caregivers to take preventative action before sensory overload occurs. Additionally, having access to data on the charge’s environment as well as observing their reaction to it will help the caregiver better learn the unique sensory sensitivities of their charge. Moreover, with notifications alerting caregivers to potential triggers or if their charge has ventured a considerable distance, they can grant the individual greater independence which is the ultimate goal of care.

## Team Members
- Alex Argenal
- Liana Goodman
- Jenna McCormick
- Athena McNeil-Roberts
- Harrison Mondragon

## How To Run
1. Flash an Arduino Nano 33 BLE with the sketch `arduino_device\device_latest.ino` by using the Arduino IDE
2. Flash a Garmin Venu 2 with the Connect IQ App `CIQ_app\Latest Build\CIQ.prg`
3. Ensure both devices are setup
    - The arduino LED is green
    - The watch is on and the CIQ app is visually present
4. Enter the Connect IQ app on the Venu 2
5. The devices should automatically connect, and after some time a home screen should be visible that displays current sensor readings

## Features
- The Connect IQ app will automatically update as the Arduino Nano updates its BLE Characteristics for the sensor values
- If sensor values surpass thresholds, dismissable notifications will occur on the Connect IQ app
- Thresholds for maximum and minimum temperature, and maximum sound level can be adjusted by swiping down on the Connect IQ app
