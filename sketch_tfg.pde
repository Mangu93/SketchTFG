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
//TO-DO : ADD PUERTO ANTONIO
#define IP_ADDRESS "???.???.???.???"
#define REMOTE_PORT 8002
#define LOCAL_PORT 2000 //???

// Configuración del punto de acceso
/////////////////////////////////
#define ESSID "mi_punto_de_acceso"
#define AUTHKEY "mipass"
#define WEB_SERVER "antonio.com"
// define timeout for listening to messages
#define TIMEOUT 10000
char gps []= "36.7102897,-4.4668383,17z";
// variable to measure time
unsigned long previous;
//POST SENTENCE
char sentence[300];
uint8_t status;
/////////////////////////////////

void setup() {
  // put your setup code here, to run once:
  USB.begin();
  delay(100);
  //Enciende el sensor
  SensorCities.setBoardMode(SENS_ON);
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
    sprintf(sentence,"GET$/",value_message);
    USB.print("sentence:");
    USB.println(sentence);
    status = WIFI.getURL(IP,WEB_SERVER,sentence);
    if(status) {
      USB.println(F("\nPeticion OK."));
      USB.println(WIFI.answer);
    }
    else{
      USB.println(F("\nERROR PETICION")); 
    }
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
    // 1. Configura el protocolo a seguir. 
    WIFI.setConnectionOptions(HTTP|CLIENT_SERVER); 
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







