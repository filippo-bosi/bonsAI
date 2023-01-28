#include "Network.h"
#include "DHTesp.h"
#include <Ticker.h>
#include <ESP32Servo.h>

#ifndef ESP32
#pragma message(THIS CODE IS FOR ESP32 ONLY!)
#error Select ESP32 board.
#endif

#define AOUT_PIN_SOIL 34
#define AOUT_PIN_LIGHT 35
#define ALARMDRYTHRESHOLD 1700
#define ALARMWETTHRESHOLD 2450

double soil = 0;
int alarmstatus = 0;

//Servo servoMotor;
DHTesp dht;
Network *network;

void tempTask(void *pvParameters);
bool getTemperature();
void triggerGetTemp();

/** Task handle for the light value read task */
TaskHandle_t tempTaskHandle = NULL;
/** Ticker for temperature reading */
Ticker tempTicker;
/** Comfort profile */
ComfortState cf;
/** Flag if task should run */
bool tasksEnabled = false;
/** Pin number for DHT11 data pin */
int dhtPin = 33;

/**
 * initTemp
 * Setup DHT library
 * Setup task and timer for repeated measurement
 * @return bool
 *    true if task and timer are started
 *    false if task or timer couldn't be started
 */

bool initTemp() {
  byte resultValue = 0;
  // Initialize temperature sensor
	dht.setup(dhtPin, DHTesp::DHT22);
	Serial.println("DHT initiated");

  // Start task to get temperature
	xTaskCreatePinnedToCore(
			tempTask,                       /* Function to implement the task */
			"tempTask ",                    /* Name of the task */
			100000,                          /* Stack size in words */
			NULL,                           /* Task input parameter */
			5,                              /* Priority of the task */
			&tempTaskHandle,                /* Task handle. */
			1);                             /* Core where the task should run */

  if (tempTaskHandle == NULL) {
    Serial.println("Failed to start task for temperature update");
    return false;
  } else {
    // Start update of environment data every 20 seconds
    tempTicker.attach(20, triggerGetTemp);
  }
  return true;
}

/**
 * triggerGetTemp
 * Sets flag dhtUpdated to true for handling in loop()
 * called by Ticker getTempTimer
 */

void triggerGetTemp() {
  if (tempTaskHandle != NULL) {
	   xTaskResumeFromISR(tempTaskHandle);
  }
}

/**
 * Task to reads temperature from DHT11 sensor
 * @param pvParameters
 *    pointer to task parameters
 */
void tempTask(void *pvParameters) {
	Serial.println("tempTask loop started");
	while (1) // tempTask loop
  {
    if (tasksEnabled) {
      // Get temperature values
			getTemperature();
		}
    // Got sleep again
		vTaskSuspend(NULL);
	}
}

/**
 * getTemperature
 * Reads temperature from DHT11 sensor
 * @return bool
 *    true if temperature could be aquired
 *    false if aquisition failed
*/
bool getTemperature() {
	// Reading temperature for humidity takes about 250 milliseconds!
	// Sensor readings may also be up to 2 seconds 'old' (it's a very slow sensor)
  TempAndHumidity newValues = dht.getTempAndHumidity();
	// Check if any reads failed and exit early (to try again).
	if (dht.getStatus() != 0) {
		Serial.println("DHT22 error status: " + String(dht.getStatusString()));
		return false;
	}

	float heatIndex = dht.computeHeatIndex(newValues.temperature, newValues.humidity);
  float dewPoint = dht.computeDewPoint(newValues.temperature, newValues.humidity);
  float cr = dht.getComfortRatio(cf, newValues.temperature, newValues.humidity);

  String comfortStatus;
  switch(cf) {
    case Comfort_OK:
      comfortStatus = "OK";
      break;
    case Comfort_TooHot:
      comfortStatus = "Too Hot";
      break;
    case Comfort_TooCold:
      comfortStatus = "Too Cold";
      break;
    case Comfort_TooDry:
      comfortStatus = "Too Dry";
      break;
    case Comfort_TooHumid:
      comfortStatus = "Too Humid";
      break;
    case Comfort_HotAndHumid:
      comfortStatus = "Hot And Humid";
      break;
    case Comfort_HotAndDry:
      comfortStatus = "Hot And Dry";
      break;
    case Comfort_ColdAndHumid:
      comfortStatus = "Cold And Humid";
      break;
    case Comfort_ColdAndDry:
      comfortStatus = "Cold And Dry";
      break;
    default:
      comfortStatus = "Unknown:";
      break;
  };
  double soil = analogRead(AOUT_PIN_SOIL);
  double light = analogRead(AOUT_PIN_LIGHT);
  
  Serial.println(" T:" + String(newValues.temperature) + " H:" + String(newValues.humidity) + " L:" + String(light) + " S:" + String(soil) + " " + comfortStatus);
	
  if (soil < ALARMDRYTHRESHOLD) {
    // dry warning
    Serial.println("Warning: soil dry!");
    alarmstatus = 1;
  }
  else if (soil > ALARMWETTHRESHOLD) {
    // wet warning
    Serial.println("Warning: soil too wet!");
    alarmstatus = 2;
  }
  else {
    // ok, no warning
    Serial.println("Soil ok.");
    alarmstatus = 0;
  }

  // update sensor readings on Firestore Database
  network->firestoreDataUpdate(newValues.temperature, newValues.humidity, light, soil, comfortStatus);
  return true;
}

void setup()
{
  Serial.begin(115200);
  Serial.println();
  Serial.println("DHT ESP32 example with tasks");
  // init LEDs
  pinMode(21, OUTPUT);
  pinMode(22, OUTPUT);
  pinMode(23, OUTPUT);
  initNetwork();
  delay(10000);
  initTemp();
  // Signal end of setup() to tasks
  tasksEnabled = true;
}

void loop() {
  if (!tasksEnabled) {
    // Wait 2 seconds to let system settle down
    delay(2000);
    // Enable task that will read values from the DHT sensor
    tasksEnabled = true;
    if (tempTaskHandle != NULL) {
			vTaskResume(tempTaskHandle);
		}
  }
  yield();

  soil = analogRead(AOUT_PIN_SOIL);

  // dry warning
  if (alarmstatus == 1) {
    digitalWrite(21, HIGH);   
    delay(200);
    digitalWrite(22, HIGH);   
    delay(200);
    digitalWrite(23, HIGH);   
    delay(200);
    digitalWrite(21, LOW);
    delay(200);
    digitalWrite(22, LOW);
    delay(200);
    digitalWrite(23, LOW);
    delay(200);
  }
}

void initNetwork(){
  network = new Network();
  network->initWiFi();
}
