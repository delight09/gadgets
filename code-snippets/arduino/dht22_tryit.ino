#include <dht.h>

dht DHT;

#define DHT22_PIN 6

void setup()
{
  Serial.begin(115200);
  pinMode(13, OUTPUT); // Disable 13th led
  // Serial.print("LIBRARY VERSION: ");
  // Serial.println(DHT_LIB_VERSION);
}

void loop()
{
  // READ DATA
  // Serial.print("DHT22, \t");
  int chk = DHT.read22(DHT22_PIN);
  switch (chk)
  {
    case DHTLIB_OK:  
    // DISPLAY DATA
    Serial.print(DHT.humidity, 1);
    Serial.print(",");
    Serial.println(DHT.temperature, 1);
    break;
    case DHTLIB_ERROR_CHECKSUM: 
    // Serial.print("Checksum error,\t"); 
    break;
    case DHTLIB_ERROR_TIMEOUT: 
    // Serial.print("Time out error,\t"); 
    break;
    default: 
    // Serial.print("Unknown error,\t"); 
    break;
  }

  delay(30000); // 30 seconds

}
//
// END OF FILE
//

