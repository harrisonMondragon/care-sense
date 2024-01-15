#include <Arduino.h>
#include <PDM.h>
#include <math.h>

// buffer to read samples into, each sample is 16-bits
short sampleBuffer[256];

// number of samples read
volatile int samplesRead;

// timer variables
unsigned long lastTime;
const unsigned long interval = 1000; // 1 second interval

// Threshold for considering a signal as noise
const double noiseThreshold = 80.0; // Adjust this value based on your environment


void onPDMdata();

void setup() {
  Serial.begin(9600);
  while (!Serial);

  // configure the data receive callback
  PDM.onReceive(onPDMdata);

  // initialize PDM with:
  // - one channel (mono mode)
  // - a 16 kHz sample rate
  if (!PDM.begin(1, 16000)) {
    Serial.println("Failed to start PDM!");
    while (1);
  }

  // initialize lastTime
  lastTime = millis();
}

void loop() {
  // check if 1 second has passed
  if (millis() - lastTime >= interval) {
    // wait for samples to be read
    if (samplesRead) {
      // calculate the RMS amplitude
      double sumSquared = 0.0;
      for (int i = 0; i < samplesRead; i++) {
        sumSquared += pow(sampleBuffer[i], 2);
      }
      double rmsAmplitude = sqrt(sumSquared / samplesRead);

      // print the RMS amplitude to the serial monitor
      // Serial.println("RMS amp:" + String(rmsAmplitude) );

      // Amplitude to dBFS
      float dBfs = 20 * log10(abs(rmsAmplitude));

      // dBFS to Positive dB Scale 
      // -26 +- 1 dBFS is reference for 0 dB
      float dB = dBfs + 25;
      Serial.println("DB reading:" + String(dB));

      // Compare dB against the noise threshold
      if (dB > noiseThreshold) {
        Serial.println("Loud noise detected!");
      } else {
        Serial.println("Quiet environment.");
      }

      // clear the read count
      samplesRead = 0;

      // update lastTime
      lastTime = millis();
    }
  }
}

void onPDMdata() {
  // query the number of bytes available
  int bytesAvailable = PDM.available();

  // read into the sample buffer
  PDM.read(sampleBuffer, bytesAvailable);

  // 16-bit, 2 bytes per sample
  samplesRead = bytesAvailable / 2;
}
