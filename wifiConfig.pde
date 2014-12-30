//David Chatting - 24th December 2014
//RaspberryPi.java needs to be in this project (same directory)
//Requires controlP5: http://www.sojamo.de/libraries/controlP5/
//*** Will destroy and replace existing wpa_supplicant.conf file ***
//===================================

import controlP5.*;
import processing.serial.*;
import java.util.HashSet;

ControlP5 cp5;
DropdownList ssidDropDownList;
String selectedSSID=null;
String password=null;

RaspberryPi pi=null;

void setup() {
  size(400, 400);
  cp5 = new ControlP5(this);
  //cp5.setAutoDraw(false);
  pi=new RaspberryPi(this, findRaspberryPi(), 115200);
  
  ssidDropDownList = cp5.addDropdownList("Select Network").setPosition(100, height/2).setWidth(100).setBarHeight(20);
  ssidDropDownList.captionLabel().style().marginTop = 5;
  cp5.addTextfield("password")
     .setPosition(200,(height/2)-20)
     .setSize(200,40)
     .setFocus(false)
     .setPasswordMode(false)
     .setHeight(20)
     .setWidth(100)
     ;
   
  makeSSIDList();
}

void makeSSIDList(){
  try{
    String ssidList[]=split(pi.sendCommand("iwlist wlan0 scan | grep ESSID",false),'\n');
    
    HashSet<String> ssidHashSet = new HashSet<String>(ssidList.length);
    for(int n=0;n<ssidList.length;++n){
      ssidList[n]=ssidList[n].substring(ssidList[n].indexOf('"')+1,ssidList[n].lastIndexOf('"'));
      ssidHashSet.add(ssidList[n]);
    }
    
    int n=0;
    for(String ssid:ssidHashSet) {
      ssidDropDownList.addItem(ssid,n++);
    }
  }
  catch(Exception e){
  }
}

void setUpWifi(String ssid,String password){
  pi.sendCommand("sudo ifdown wlan0");
  saveWifiPasswordFile(ssid,password);
  pi.sendCommand("sudo ifup wlan0");
  
  exit();
}

void saveWifiPasswordFile(String ssid,String password){
  String lines[]={"ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev",
                  "update_config=1",
                  "network={",
                  "  ssid=\""+ssid+"\"",
                  "  proto=RSN",
                  "  key_mgmt=WPA-PSK",
                  "  pairwise=CCMP TKIP",
                  "  psk=\""+password+"\"", 
                  "}"};
                  
  saveFileOnRaspberryPi("/etc/wpa_supplicant/wpa_supplicant.conf",lines);
}

void saveFileOnRaspberryPi(String filename,String lines[]){
  pi.sendCommand("sudo -s");
  
  pi.sendCommand("rm "+filename);
  
  for(int n=0;n<lines.length;++n){
    pi.sendCommand("echo '"+lines[n]+"' >> " + filename);
  }
  
  pi.sendCommand("exit");
}

String findRaspberryPi(){
  String device=null;
  
  for(int n=0;n<Serial.list().length && device==null;++n){
    if(looksLikeRaspberryPi(Serial.list()[n])){
      device = Serial.list()[n];
    }
  }
  println("Found: " + device);
  
  return(device);
}

boolean looksLikeRaspberryPi(String s){
  //for different adapters you'll need to change this - this won't work on Windows where it's COM1 etc
  return(s.startsWith("/dev/tty.PL"));
}

void draw() {
  background(0);
}

void serialEvent(Serial serial) {
  if(pi!=null) pi.serialEvent(serial);
}

void controlEvent(ControlEvent theEvent) {
  if(theEvent.isAssignableFrom(Textfield.class)) {
    password=new String(theEvent.getStringValue());
   
    if(selectedSSID!=null) setUpWifi(selectedSSID,password);
  }
  else if(theEvent.isAssignableFrom(DropdownList.class)) {
    if (theEvent.isGroup()) {
      int i=(int)theEvent.getGroup().getValue();
      selectedSSID=new String(ssidDropDownList.getItem(i).getName());
      if(password!=null) setUpWifi(selectedSSID,password);
    }
  }
}
