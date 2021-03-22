#include <SoftwareSerial.h>

// assign output pins for relays
const int RELAY_0 = 8;
const int RELAY_1 = 7;

// message to be recieved over BlueTooth
String message;

// Pass in pins to use as RX and TX on arduino.
// Don't use the labeled RX, TX pins on Arduino (0 and 1) - those are for hardware serial.
// Arduino RX connects to HM10 TX, Arduino TX connects to HM10 RX.
// Need Voltage divider for HM10 RX, which runs on 3.4V - arduino sends out 5V signal.
// Use 1kOhm and 2kOhm resistors for the voltage divider.
SoftwareSerial HM10(3, 4);

void setup() {
  
  Serial.begin(9600);
  HM10.begin(9600);
  pinMode(RELAY_0, OUTPUT);
  pinMode(RELAY_1, OUTPUT);
  
  Serial.println("Enter AT command here, or control device from phone.");
  Serial.println("Phone commands: 00, 01, 10, or 11.");
}


void loop() {

  // Read from HM-10 and react to the incoming message
  if (HM10.available()) {
    message = HM10.readStringUntil('\n');
    respondToMessage(message);
  }

  // Read from Serial Monitor and send to HM-10
  // Use for AT commands to configure HM-10 (see HM-10 datasheet)
  if (Serial.available()) {
    HM10.write(Serial.read());
  }
                      
}

// take action based on input
void respondToMessage(String message) {
  
  if (message.startsWith("OK")) {
    // status message from HM10
    Serial.println(message);
    
  } else if (message == "00") {
    // turn off both relays
    Serial.println("Changing to state " + message);
    digitalWrite(RELAY_0, LOW);
    digitalWrite(RELAY_1, LOW);
    
  } else if (message == "01") {
    // turn on relay 1, turn off relay 0
    Serial.println("Changing to state " + message);
    digitalWrite(RELAY_0, LOW);
    digitalWrite(RELAY_1, HIGH);
    
  } else if (message == "10") {
    // turn on relay 0, turn off relay 1
    Serial.println("Changing to state " + message);
    digitalWrite(RELAY_0, HIGH);
    digitalWrite(RELAY_1, LOW);
    
  } else if (message == "11") {
    // turn on both relays
    Serial.println("Changing to state " + message);
    digitalWrite(RELAY_0, HIGH);
    digitalWrite(RELAY_1, HIGH);
    
  } else {
    Serial.println(message + " is not a valid command.");
  }
}
