#include "Network.h"
#include "addons/TokenHelper.h"
#include <WiFiManager.h>
#include <WiFi.h>

#define API_KEY "AIzaSyCfzk2sl27KFQ_3HFqxRa7xHs_d0agM5vg"
#define FIREBASE_PROJECT_ID "soil-moisture6"

static Network *instance = NULL;

Network::Network(){
  instance = this;
}

void WiFiEventConnected(WiFiEvent_t event, WiFiEventInfo_t info){
  Serial.println("WIFI CONNECTED! BUT WAIT FOR THE LOCAL IP ADDR");
}

void WiFiEventGotIP(WiFiEvent_t event, WiFiEventInfo_t info){
  Serial.print("LOCAL IP ADDRESS: ");
  Serial.println(WiFi.localIP());
}

void WiFiEventDisconnected(WiFiEvent_t event, WiFiEventInfo_t info){
  Serial.println("WIFI DISCONNECTED!");
  WiFiManager wfm;
  //wm.resetSettings();
  bool res;
  res = wfm.autoConnect("BonsAI"); // password protected ap

  if(!res) {
    Serial.println("Failed to connect");
    //ESP.restart();
  } 
}

void FirestoreTokenStatusCallback(TokenInfo info){
  Serial.printf("Token Info: type = %s, status = %s\n", getTokenType(info), getTokenStatus(info));
  Serial.printf("Token error: %s\n", getTokenError(info).c_str());
}

void Network::initWiFi(){
  WiFi.disconnect();
  WiFi.onEvent(WiFiEventConnected, ARDUINO_EVENT_WIFI_STA_CONNECTED);
  WiFi.onEvent(WiFiEventGotIP, ARDUINO_EVENT_WIFI_STA_GOT_IP);
  WiFi.onEvent(WiFiEventDisconnected, ARDUINO_EVENT_WIFI_STA_DISCONNECTED);
  //WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  WiFi.mode(WIFI_STA); // explicitly set mode, esp defaults to STA+AP
  WiFiManager wfm;
  wfm.resetSettings();
  // Define a text box, 20 characters maximum
  // Add custom parameter
  WiFiManagerParameter user_text_box("user", "BonsAI Email", "Email", 20);
  wfm.addParameter(&user_text_box);

  WiFiManagerParameter pass_text_box("pass", "BonsAI Password", "Password", 20);
  wfm.addParameter(&pass_text_box);

  WiFiManagerParameter plant_text_box("plant", "BonsAI Plant ID", "Plant_ID", 10);
  wfm.addParameter(&plant_text_box);
  
  bool res;
  std::vector<const char *> menu = {"wifi"};
  wfm.setMenu(menu);
  res = wfm.autoConnect("BonsAI"); // password protected ap

  if(!res) {
    Serial.println("Failed to connect");
    //ESP.restart();
  } 
  // Connected!
  Serial.println("WiFi connected");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  // Print custom text box value to serial monitor  
  USER_EMAIL = String(user_text_box.getValue());
  USER_PASSW = String(pass_text_box.getValue());
  PLANT_ID = String(plant_text_box.getValue());
  Serial.print("User: ");
  Serial.println(USER_EMAIL);
  Serial.print("Pass: ");
  Serial.println(USER_PASSW);
  Serial.print("Plant_ID: ");
  Serial.println(PLANT_ID);
  instance->firebaseInit();
}

void Network::firebaseInit(){
  config.api_key = API_KEY;

  auth.user.email = USER_EMAIL.c_str();
  auth.user.password = USER_PASSW.c_str();

  config.token_status_callback = FirestoreTokenStatusCallback;

  Firebase.begin(&config, &auth);
}

void Network::firestoreDataUpdate(double temp, double humidity, double light, double soil, String comfort){
  if(WiFi.status() == WL_CONNECTED && Firebase.ready()){
    String documentPath = "/Users/"+String(USER_EMAIL)+"/Plants/"+String(PLANT_ID);
    
    FirebaseJson content;

    content.set("fields/temperature/doubleValue", String(temp).c_str());
    content.set("fields/humidity/doubleValue", String(humidity).c_str());
    content.set("fields/light_level/doubleValue", String(light).c_str());
    content.set("fields/soil_moisture/doubleValue", String(soil).c_str());
    content.set("fields/comfort_level/stringValue", String(comfort).c_str());

    if(Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", documentPath.c_str(), content.raw(), "temperature,humidity,light_level,soil_moisture,comfort_level")){
      Serial.printf("ok\n%s\n\n", fbdo.payload().c_str());
      return;
    }else{
      Serial.println(fbdo.errorReason());
    }

    if(Firebase.Firestore.createDocument(&fbdo, FIREBASE_PROJECT_ID, "", documentPath.c_str(), content.raw())){
      Serial.printf("ok\n%s\n\n", fbdo.payload().c_str());
      return;
    }else{
      Serial.println(fbdo.errorReason());
    }
  }
}