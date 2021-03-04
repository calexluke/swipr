#include <SoftwareSerial.h>

const int LED_0 = 3;
const int LED_1 = 4;
String message;

// Don't use the rx, tx pins on Arduino (0 and 1) - those are for hardware serial.
SoftwareSerial HM10(11, 12); // RX, TX


void setup() {
  
  Serial.begin(9600);
  HM10.begin(9600);
  pinMode(LED_0, OUTPUT);
  pinMode(LED_1, OUTPUT);
  
  Serial.println("Enter AT command here, or control device from phone.");
  Serial.println("Phone commands: 00, 01, 10, or 11.");
}


void loop() {

  // Read from HM-10 and send to Serial Monitor
  if (HM10.available()) {
    message = HM10.readStringUntil('\n');
    respondToMessage(message);
  }

  // Read from Serial Monitor and send to HM-10
  if (Serial.available()) {
    HM10.write(Serial.read());
  }
                      
}

// take action based on input
void respondToMessage(String message) {
  
  if (message.startsWith("OK")) {
    // status update from HM10
    Serial.println(message);
    
  } else if (message == "00") {
    Serial.println("Changing to state " + message);
    digitalWrite(LED_0, LOW);
    digitalWrite(LED_1, LOW);
    
  } else if (message == "01") {
    Serial.println("Changing to state " + message);
    digitalWrite(LED_0, LOW);
    digitalWrite(LED_1, HIGH);
    
  } else if (message == "10") {
    Serial.println("Changing to state " + message);
    digitalWrite(LED_0, HIGH);
    digitalWrite(LED_1, LOW);
    
  } else if (message == "11") {
    Serial.println("Changing to state " + message);
    digitalWrite(LED_0, HIGH);
    digitalWrite(LED_1, HIGH);
    
  } else {
    Serial.println(message + " is not a valid command.");
  }
}
