#ifndef Network_H_
#define Network_H_

#include <WiFi.h>
#include <Firebase_ESP_Client.h>
class Network{
public:
  String USER_EMAIL;
  String USER_PASSW;
  String PLANT_ID;
  FirebaseData fbdo;
  FirebaseAuth auth;
  FirebaseConfig config;

  void firebaseInit();
  friend void WiFiEventConnected(WiFiEvent_t event, WiFiEventInfo_t info);
  friend void WiFiEventGotIP(WiFiEvent_t event, WiFiEventInfo_t info);
  friend void WiFiEventDisconnected(WiFiEvent_t event, WiFiEventInfo_t info);
  friend void FirestoreTokenStatusCallback(TokenInfo info);

  Network();
  void initWiFi();
  void firestoreDataUpdate(double temp, double humidity, double light, double soil, String comfort);
};

#endif