//David Chatting - 4th March 2014
//===============================

import processing.serial.*;

RaspberryPi pi=null;

void setup() {
  size(400, 400);
  
  pi=new RaspberryPi(this, findRaspberryPi(), 115200);
  println(pi.sendCommand("ls",true));
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
