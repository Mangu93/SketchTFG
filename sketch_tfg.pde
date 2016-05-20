// Libreria para el micrófono
#include <WaspSensorCities.h>
//Libreria para la conectividad WiFi
#include <WaspWIFI.h>
//Libreria para modificar strings
#include<string.h>
//Socket para la conexion WiFi
uint8_t socket=SOCKET0;
// Variable para guardar el valor del microfono
float value;
char value_message[100];

//Dirección IP y puertos
#define IP_ADDRESS "???.???.???.???"
#define REMOTE_PORT 8002
#define LOCAL_PORT 2000 //???

// Configuración del punto de acceso
/////////////////////////////////
#define ESSID "mi_punto_de_acceso"
#define AUTHKEY "mipass"

// define timeout for listening to messages
#define TIMEOUT 10000
char gps []= "36.7102897,-4.4668383,17z";
// variable to measure time
unsigned long previous;
/////////////////////////////////

void setup() {
  // put your setup code here, to run once:
  USB.ON();
  delay(100);
  //Enciende el sensor
  SensorCities.ON();
  //Enciende el reloj
  RTC.ON();
  //Activa la conexion Wifi
  wifi_setup();
  value = 30; //Umbral de ruido
}


void loop() {
  // put your main code here, to run repeatedly:
  // 1. Enciende el modulo WiFi
  SensorCities.setSensorMode(SENS_ON, SENS_CITIES_AUDIO);
  delay(2000);
  //value = SensorCities.readValue(SENS_CITIES_AUDIO);
  sprintf(value_message,"%f",value);
  strcat(value_message,",");
  strcat(value_message,gps);
  WIFI.ON(socket);
  if (WIFI.join(ESSID))  {
    USB.println(F("Conexión con el AP establecida"));
    // 3. Llama a la funcion para establecer el cliente 
    if (WIFI.setTCPclient(IP_ADDRESS, REMOTE_PORT, LOCAL_PORT)) {
      USB.println(F("Conexion con el cliente establecido"));
      WIFI.send(value_message);
      USB.println(F("Cierra socket"));
      WIFI.close(); 
    }
    WIFI.leave();
  }
  else {
    USB.println(F("Conexión fallida"));
  }


  SensorCities.setSensorMode(SENS_OFF, SENS_CITIES_AUDIO);
  delay(1000*60); //cambiar por modo ahorro
}

/*************************************
 *
 *  wifi_setup 
 *  funcion para configurar la conexión WiFi 
 *
 ************************************/

void wifi_setup() {
  // Encender el módulo WiFi en el socket deseeado
  if( WIFI.ON(socket) == 1 ){
    USB.println(F("WiFi encendido"));
    // 1. Configura el protocolo a seguir. CLIENT = Cliente TCP 
    WIFI.setConnectionOptions(CLIENT); 
    // 2. Configura como obtener la IP.
    WIFI.setDHCPoptions(DHCP_ON);    
    // 3. Configura como conectarte al AP
    WIFI.setJoinMode(MANUAL); 
    // 4. Configurar modo de autenticación.
    WIFI.setAuthKey(WPA1,AUTHKEY); 

    // 5. Guardar cambios
    WIFI.storeData();
  }
  else {
    USB.println(F("WiFi no funcionando"));
  }


}






