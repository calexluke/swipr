
#include <SoftwareSerial.h>

const int LED_0 = 3;
const int LED_1 = 4;
String command;
// Don't use the rx, tx pins on Arduino (0 and 1) - those are for hardware serial.
SoftwareSerial HM10(11, 12); // RX, TX

void setup() {
  
  Serial.begin(9600);
  HM10.begin(9600);  
  pinMode(LED_0, OUTPUT);
  pinMode(LED_1, OUTPUT);
  
  Serial.println("Enter AT commands here, or control device from phone.");
  Serial.println("Phone commands: 00, 01, 10, or 11.");
}


void loop() { 

  // Read from HM-10 and send to Serial Monitor
  if (HM10.available()) { 
    command = HM10.readStringUntil('\n');
    respondToCommand(command);
  }

  // Read from Serial Monitor and send to HM-10
  if (Serial.available()) { 
    HM10.write(Serial.read());
  }
                      
}

void respondToCommand(String command) {
  
  // take action based on input
  if (command.startsWith("OK")) {
    // status update from HM10
    Serial.println(command);
    
  } else if (command == "00") {
    Serial.print("Changing to state ");
    Serial.println(command);
    digitalWrite(LED_0, LOW);
    digitalWrite(LED_1, LOW);
    
  } else if (command == "01") {
    Serial.print("Changing to state ");
    Serial.println(command);
    digitalWrite(LED_0, LOW);
    digitalWrite(LED_1, HIGH);
    
  } else if (command == "10") {
    Serial.print("Changing to state ");
    Serial.println(command);
    digitalWrite(LED_0, HIGH);
    digitalWrite(LED_1, LOW);
    
  } else if (command == "11") {
    Serial.print("Changing to state ");
    Serial.println(command);
    digitalWrite(LED_0, HIGH);
    digitalWrite(LED_1, HIGH);
    
  } else {
    Serial.print(command);
    Serial.println(" is not a valid command.");
  }
}
