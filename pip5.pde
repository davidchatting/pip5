//David Chatting - 2nd March 2014
//===============================

import processing.serial.*;

Serial raspberryPi=null;
String login="pi";
String password="raspberry";

String stdout=null;
String workingLine=null;

void setup() {
  size(400, 400);
  raspberryPi=new Serial(this, findRaspberryPi(), 115200);
  raspberryPi.write(13);  //hit enter
  delay(50);

  println(sendCommand("cd ~",false));
  println(sendCommand("ls -lag",true));
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

String sendCommand(String command,boolean removeMarkUp){
  String result=null;
  
  while(!isPrompt(workingLine) && !isLogin(workingLine)){
    delay(50);
  }
  
  if(isLogin(workingLine)){
    sendLogin();
  }
  while(!isEmptyPrompt(workingLine)){
    delay(50);
  }
  
  raspberryPi.write(command+"\n");
  delay(300);  //wait for the command to be echoed back
  
  while(!isEmptyPrompt(workingLine)){
    delay(50);
  }
  result=removePrefix(removePrompt(stdout),command);
 
  if(removeMarkUp) result=removeBashMarkUp(result);
 
  return(result);
}

boolean looksLikeRaspberryPi(String s){
  //for different adapters you'll need to change this - this won't work on Windows where it's COM1 etc
  return(s.startsWith("/dev/tty.PL"));
}

boolean isPrompt(String s){
  return(getPrompt(s)!=null);
}

boolean isEmptyPrompt(String s){
  boolean result=false;
  
  if(s!=null){
    String prompt=getPrompt(s);
    if(prompt!=null){
      result=(s.trim().length()==prompt.trim().length());
    }
  }
  
  return(result);
}

boolean isLogin(String s){
  boolean result=false;
  
  if(s!=null){
    result=(s.trim()).startsWith("raspberrypi login:");
  }
  
  return(result);
}

boolean isPassword(String s){
  boolean result=false;
  
  if(s!=null){
    result=(s.trim()).startsWith("Password:");
  }
  
  return(result);
}

String getPrompt(String s){
  String result=null;
  
  if(s!=null){
    String[] m = match(s, "^(\\S*\\$)\\s");
    if(m!=null && m.length>0){
      result=new String(m[1]);
    }
  }
  
  return(result);
}

String removePrompt(String s){
  return(removePrefix(s,getPrompt(s)));
}

String removePrefix(String s,String prefix){
  String result=null;
  
  if(s!=null){
    result=new String(s);
     
    if(prefix!=null){
      int i=result.indexOf(prefix);
      result=result.substring(i+prefix.length(),s.length());
    }
    result=result.trim();
  }
  
  return(result);
}

void sendLogin(){
  raspberryPi.write(login+"\n");
  delay(500);
  raspberryPi.write(password+"\n");
}

void draw() {
  background(0);
}

void serialEvent(Serial serial) {
  char c=serial.readChar();
  
  if(workingLine==null) workingLine=new String();
  workingLine+=c;
  
  if(c==13){
    processLine(workingLine);
    workingLine=null;
  }
}

void processLine(String line){
  if(line!=null){
    if(stdout==null) stdout=new String();
    stdout+=line;
  }
}

String removeBashMarkUp(String s){
  String result=null;
  
  String bash="\\[(.*?)m";
  result=s.replaceAll(bash, "");
  
  return(result);
}

/*
void keyPressed() {
  raspberryPi.write(key);
}
*/

