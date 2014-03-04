import processing.core.PApplet;
import processing.serial.Serial;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class RaspberryPi {
  private Serial serial=null;
  
  private String login="pi";
  private String password="raspberry";

  private String stdout=null;
  private String workingLine=null;
  
  public RaspberryPi(PApplet pApplet, String port, int baudRate) {
    serial=new Serial(pApplet, port, baudRate);
  }

  void write(int i){
    serial.write(i);
  }

  void write(char c){
    serial.write(c);
  }

  void write(byte b){
    serial.write(b);
  }
  
  void write(String s){
    serial.write(s);
  }

  String sendCommand(String command) {
    return(sendCommand(command, false));
  }

  String sendCommand(String command, boolean removeMarkUp) {
    String result=null;

    write(13);  //hit enter
    delay(50);

    while (!isPrompt (workingLine) && !isLogin(workingLine)) {
      delay(50);
    }

    if (isLogin(workingLine)) {
      sendLogin();
    }
    while (!isEmptyPrompt (workingLine)) {
      delay(50);
    }

    this.write(command+"\n");
    delay(300);  //wait for the command to be echoed back

    while (!isEmptyPrompt (workingLine)) {
      delay(50);
    }
    result=removePrefix(removePrompt(stdout), command);

    if (removeMarkUp) result=removeBashMarkUp(result);

    return(result);
  }

  void sendLogin() {
    this.write(login+"\n");
    delay(500);
    this.write(password+"\n");
  }

  void processLine(String line) {
    if (line!=null) {
      if (stdout==null) stdout=new String();
      stdout+=line;
    }
  }

  String removeBashMarkUp(String s) {
    String result=null;

    System.out.println("removeBashMarkUp");

    String bash="(?)\\[(.*?)m";
    result=s.replaceAll(bash, "");

    return(result);
  }

  boolean isPrompt(String s) {
    return(getPrompt(s)!=null);
  }

  boolean isEmptyPrompt(String s) {
    boolean result=false;

    if (s!=null) {
      String prompt=getPrompt(s);
      if (prompt!=null) {
        result=(s.trim().length()==prompt.trim().length());
      }
    }

    return(result);
  }

  boolean isLogin(String s) {
    boolean result=false;

    if (s!=null) {
      result=(s.trim()).startsWith("raspberrypi login:");
    }

    return(result);
  }

  boolean isPassword(String s) {
    boolean result=false;

    if (s!=null) {
      result=(s.trim()).startsWith("Password:");
    }

    return(result);
  }

  String getPrompt(String s) {
    String result=null;

    if (s!=null) {   
      String[] m = PApplet.match(s, "^(\\S*\\$)\\s");
      if (m!=null && m.length>0) {
        result=new String(m[1]);
      }
    }

    return(result);
  }

  String removePrompt(String s) {
    return(removePrefix(s, getPrompt(s)));
  }

  String removePrefix(String s, String prefix) {
    String result=null;

    if (s!=null) {
      result=new String(s);

      if (prefix!=null) {
        int i=result.indexOf(prefix);
        result=result.substring(i+prefix.length(), s.length());
      }
      result=result.trim();
    }

    return(result);
  }
  
  void serialEvent(Serial serial) {
    char c=serial.readChar();
    
    if (workingLine==null) workingLine=new String();
    workingLine+=c;

    if (c==13) {
      processLine(workingLine);
      workingLine=null;
    }
  }
  
  void delay(int ms){
    try{
      Thread.sleep(ms);
    }
    catch(InterruptedException e){
    }
  }
}

