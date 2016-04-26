/*
FlipDots example1: mouse follow
Draws a filled rectangle 5px X 5px at the point of the cursor on screen


This method uses the PGraphics engine in processing to create and analyze graphics in realtime to output the image
to an AlFA ZETA flipdot display.
All operations are done within the graphic (in this example called dots) so that the color value of each of the pixels can be 
queried, packaged, and sent to the panel.

In this example   the address of the top panel is set to 0x1 from the jumpers (ON OFF OFF OFF OFF OFF)
                  the address of the bottom panel is set to 0x2 from the jumpers (OFF ON OFF OFF OFF OFF)
                  
Connection to the board is made via a USB to RS485 converter https://www.sparkfun.com/products/9822                  

*/

import processing.serial.*;

Serial dotPort;
PGraphics dots;

int panelAddress1 = 0x1;
int panelAddress2 = 0x2;

int panelSizeX = 28;
int panelSizeY = 14;



void setup() 
{
  dotPort = new Serial(this, Serial.list()[9], 57600);//adjust based on your serial port and baud rate(set via jumpers on the board)  
  size(28, 14);
  noSmooth();
  dots = createGraphics(panelSizeX,panelSizeY);  
}

void draw() {

  
dots.beginDraw();
  dots.background(0);
  dots.fill(255);
  dots.stroke(255);
  dots.rect(mouseX,mouseY,5,5);
dots.endDraw();
  
updateDotPanel(panelAddress1,panelAddress2);
  
image(dots, 0, 0); 

}


void updateDotPanel(int address1, int address2)
{
/*
Protocol
Start Byte:         0x80
Refresh Command:    0x83
Board Address:      set with the jumpers on the back of board  ON OFF OFF OFF OFF OFF = 0x1 , OFF ON OFF OFF OFF OFF = 0x2, 
                    0XFF = send same message to all panel sections
Control Bytes, Panel (28 X 7 pixels) is divided into columns of 7 dots.
Each control byte is determined by a 7 number binary string that is then converted to hex. (the binary string starts at the top of the column going down)
                    For example:
                    0000000 -> 0x0   all dots in the column are black
                    1000000 -> 0x1   top dot white other six black
                    1111000 -> 0xF   top four white, three black

End Byte:           0x8F          
*/

//top half of panel  
dotPort.write(0x80);
dotPort.write(0x83);
dotPort.write(address1); 

//sample the image, build the binary strings, send them to the panel
    for(int px=(panelSizeX-1);px>=0;px--)
    {
    String binVal = ""; 
      for(int py=0;py<(panelSizeY/2);py++)
      {
       int loc = int(px + py*panelSizeX); 
       color cColor = dots.pixels[loc];     
       binVal += str(constrain(int(brightness(cColor)),0,1));    
      }   
      int ub = unbinary(binVal);
      dotPort.write(ub);  
    }
dotPort.write(0x8F);
//bottom half of the panel
/////////////////////////////////////////////
dotPort.write(0x80);
dotPort.write(0x83);
dotPort.write(address2); 

//sample the image, build the binary strings, send them to the panel
  for(int px=(panelSizeX-1);px>=0;px--)
  {
  String binVal = ""; 
    for(int py=(panelSizeY/2);py<panelSizeY;py++)
    {
     int loc = int(px + py*panelSizeX); 
     color cColor = dots.pixels[loc];     
     binVal += str(constrain(int(brightness(cColor)),0,1));  
    }   
    int ub = unbinary(binVal);
    dotPort.write(ub);   
  }
dotPort.write(0x8F);
////////////////////////////
}