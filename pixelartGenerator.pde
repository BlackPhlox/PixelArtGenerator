import java.util.regex.Matcher;
import java.util.regex.Pattern;

final String extractFilename = "(\\w+(?:\\.\\w+)*$)";
final String extractExt = "(\\.\\w+$)";
final Pattern extractFilenamePttn = Pattern.compile(extractFilename, Pattern.MULTILINE);
final Pattern extractExtPttn = Pattern.compile(extractExt, Pattern.MULTILINE);

NamedPImage img;
PGraphics processedImage = new PGraphics();

int selectorIndex = 0;

int variableMult = 8;

String[] options = new String[7];
int[] optionsVar = new int[options.length];
int imageX,imageY;

boolean helpPressed = false;
boolean showPreview = false;
boolean mouseCenter = true;

class NamedPImage {
  PImage img,ogImg;
  String filename;
  NamedPImage(String filename) {
    Matcher extMatcher = extractExtPttn.matcher(filename);
    String ext = "";
    while (extMatcher.find()){ext = extMatcher.group(0);}
    Matcher matcher = extractFilenamePttn.matcher(filename);
    while (matcher.find()) {this.filename = ""+matcher.group(0).replaceFirst(ext,"");}
    img = loadImage(filename);
    ogImg = loadImage(filename);
  }
}

void setup(){
  size(800,800);
  surface.setResizable(true);
  for(int i = 0; i < options.length; i++){
    options[i] = ""+i;
    optionsVar[i] = 0;
  }
  
  options[0] = "Spacing";
  optionsVar[0] = 20;
  
  options[1] = "Size";
  optionsVar[1] = 10;
  
  options[2] = "X Pixels";
  optionsVar[2] = 5;
  
  options[3] = "Y Pixels";
  optionsVar[3] = 5;
  
  resetImage();
}

void resetImage(){
  if(img != null){
    img.img.resize(width,height);
    imageX = 0; imageY = 0;
  }
  options[4] = "Image width";
  optionsVar[4] = width;
  options[5] = "Image height";
  optionsVar[5] = height;
  options[6] = "Image scale";
  optionsVar[6] = 0;
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    img = new NamedPImage(selection.getAbsolutePath());
    resetImage();
  }
}

void draw(){
  background(0);
  fill(255);
  textSize(12);
  imageMovement();
  if(img != null){
    image(img.img,imageX,imageY,optionsVar[4],optionsVar[5]);
  }
  for(int x = 0; x < optionsVar[2]; x++){
    for(int y = 0; y < optionsVar[3]; y++){
      if(mouseCenter){
        float totalWidth = optionsVar[0] * (optionsVar[2]-1) + optionsVar[1];
        rect(mouseX-totalWidth/2+x*optionsVar[0],mouseY-totalWidth/2+y*optionsVar[0],optionsVar[1],optionsVar[1]);
      } else {
        rect(mouseX+x*optionsVar[0],mouseY+y*optionsVar[0],optionsVar[1],optionsVar[1]);
      }
    }
  }
  String menuText = options[selectorIndex] + " " + optionsVar[selectorIndex];
  fill(0,0,0,100);
  noStroke();
  rect(0,0,menuText.length()*7,11);
  fill(255);
  text(menuText,0,10);
  
  if(showPreview && img != null){
    processImage();
    image(processedImage,0,15);
  }
  
  if(keyPressed){
    if(keyCode == java.awt.event.KeyEvent.VK_F1){
      displayHelp();
    }
  }
  if(!helpPressed){
    text("Press F1 for help",0,height-2);
  }
}

void displayHelp(){
  helpPressed = true;
  translate(20,20);
  rect(0,0,width-40,height-40);
  fill(0);
  translate(5,24);
  textSize(24);
  text("Pixelart Generator",0,0);
  textSize(12);
  text("Developed by Black Phlox 2018",0,12);
  textSize(16);
  text("How to use:",0,35);
  textSize(12);
  text("L : Load an image",0,50);
  text("S : Save processed image",0,50+15);
  text("R : Reset image",0,50+30);
  text("C : Toggle between mouse-selection in center or in the left corner",0,50+45);
  text("SHIFT: Multiply the scale of scrolling",0,50+60);
  text("ALT : Scale image by mouse scrolling",0,50+75);
  text("CTRL: Move the image",0,50+90);
  text("LMB : Decrease menu index",0,50+105);
  text("RMB : Increase menu index",0,50+120);
  text("MMB : Preview processed image",0,50+135);
}

void mouseClicked() {
  if (mouseButton == LEFT) {
    selectorIndex++;
  } else if (mouseButton == RIGHT){
    selectorIndex--;
  } else if (mouseButton == CENTER){
    //Create Image
    showPreview = !showPreview;
    if(optionsVar[1] != 0 && optionsVar[2] != 0 && optionsVar[3] != 0){
      processedImage = createGraphics(abs(optionsVar[2]*optionsVar[1]),abs(optionsVar[3]*optionsVar[1]));
    } //<>//
  }
  wrapSelector();
}

void wrapSelector(){
  if (selectorIndex > options.length-1) {
    selectorIndex = 0;
  } else if (selectorIndex < 0){
    selectorIndex = options.length-1;
  }
}

void processImage(){
  processedImage.beginDraw();
    //processedImage.background(102);
    for(int x = 0; x < optionsVar[2]; x++){
      for(int y = 0; y < optionsVar[3]; y++){
        PImage tempImg;
        if(mouseCenter){
          float totalWidth = optionsVar[0] * (optionsVar[2]-1) + optionsVar[1];
          tempImg = img.img.get(mouseX-floor(totalWidth/2)+x*optionsVar[0],mouseY-floor(totalWidth/2)+y*optionsVar[0],optionsVar[1],optionsVar[1]);
        } else {
          tempImg = img.img.get(mouseX+x*optionsVar[0],mouseY+y*optionsVar[0],optionsVar[1],optionsVar[1]);
        }
        processedImage.image(tempImg,x*optionsVar[1],y*optionsVar[1],optionsVar[1],optionsVar[1]);
      }
    }
    processedImage.endDraw();
    processedImage.smooth();
}

void keyPressed() {
  if((key == 's' || key == 'S') && img != null){
    String processedImageName = "pixified_"+img.filename+".png";
    processedImage.save(processedImageName);
    println("Saved as " + processedImageName);
  } else if(key == 'l' || key == 'L'){
    selectInput("Select a image to process:", "fileSelected");
  } else if(key == 'r' || key == 'R'){
    resetImage();
  } else if(key == 'c' || key == 'C'){
    mouseCenter = !mouseCenter;
  }
}

void mouseWheel(MouseEvent event) {
  if (keyPressed == true) {
    if (key == CODED) {
      if (keyCode == SHIFT) {
        changeOptionValue(event.getCount()*variableMult);
      } else if (keyCode == CONTROL) {
        imageX = mouseX;
        imageY = mouseY;
      }
    }
  } else {
    changeOptionValue(event.getCount());
  }
}

void imageMovement(){
  if (keyPressed == true) {
    if (key == CODED) {
      if (keyCode == CONTROL) {
        imageX = mouseX;
        imageY = mouseY;
      }
    }
  }
}

void changeOptionValue(float e){
  if(selectorIndex!=6){
    optionsVar[selectorIndex] += e;
  } else {
    optionsVar[4] += e;
    optionsVar[5] += e;
    optionsVar[selectorIndex] += e;
  }
}