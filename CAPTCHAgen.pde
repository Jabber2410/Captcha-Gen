import processing.javafx.*;
import javafx.application.Platform;
import javafx.embed.swing.JFXPanel;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.paint.Color;

// === GUI ELEMENTS ===
@FXML
imp.PictureViewer pv_captcha;
@FXML
Button bt_gen;
@FXML
Button bt_enter;
@FXML
TextField tf_enter;
@FXML
Label lb_feedback;


PImage imgCapt, imgRobot, imgWebsite;
int lengthCapt=5, sCount=0;
String txtCapt;

void setup() {
  size(200, 100);
  imgRobot = loadImage("robot.png");
  imgWebsite = loadImage("website.png"); 
  thread("starteJavaFX");
}


// === EVENT-HANDLER ===
@FXML
void handleGeneratePress() {
  genCapt();
}

@FXML
void handleEnterPress() {
 String value = tf_enter.getText().toUpperCase();
  if(value.equals(txtCapt)) { 
    sCount ++;
    lb_feedback.setText("You are maybe not a Robot: " + sCount + " solved");
    lb_feedback.setTextFill(Color.GREEN);
    
  } else {
    lb_feedback.setText("Help, you are a Robot");
    lb_feedback.setTextFill(Color.RED);
    showImgInGUI(imgRobot);
    sCount = -1;
  }
  if(sCount == -1) {
    sCount = 0;
  }else if(sCount < 3) {
    genCapt();
  }else if(sCount == 3) {
    showImgInGUI(imgWebsite);
    lb_feedback.setText("You are not a Robot");
  }else if(sCount > 3) {
    lb_feedback.setText("Succes streak: " + sCount);
  }
  tf_enter.setText("");
}

// === JAVAFX SETUP ===

void starteJavaFX() {
  new JFXPanel();
  Platform.runLater(() -> {
    try {
      Stage stage = new Stage();
      FXMLLoader loader = new FXMLLoader();
      java.io.File fxmlFile = new java.io.File(dataPath("gui.fxml"));
      loader.setLocation(fxmlFile.toURI().toURL());
      
      loader.setController(this); 
      
      Parent root = loader.load();
      stage.setScene(new Scene(root));
      stage.setTitle("CAPTCHA Generator");
      stage.setResizable(false);
      
      stage.show();
    } catch (Exception e) {
      e.printStackTrace();
    }
  });
  genCapt();
}



void showCaptImgInGUI(PImage pimg) {
  String tempPath = dataPath("temp_img.png");
  pimg.save(tempPath);
  imp.Picture impBild = new imp.Picture(tempPath);
  
  if (pv_captcha != null) {
    Platform.runLater(() -> pv_captcha.setImage(impBild, true));
    
  }
}

void showImgInGUI(PImage pimg) {
 PGraphics canvas = createGraphics(600, 300);
  
  canvas.beginDraw();
  canvas.background(255); 
  canvas.imageMode(CENTER); 
  
  canvas.image(pimg, canvas.width/2, canvas.height/2);
  canvas.endDraw();
  
  String tempPath = dataPath("temp_result_img.png");
  canvas.save(tempPath);
  
  imp.Picture impBild = new imp.Picture(tempPath);
  if (pv_captcha != null) {
    Platform.runLater(() -> pv_captcha.setImage(impBild, true));
  }
}
void genCapt() {
  imgCapt = genCaptImg(genTxt());
  showCaptImgInGUI(imgCapt);
    Platform.runLater(() -> tf_enter.requestFocus());
}

String genTxt () {
  String alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // No O, 0, 1, I (Too similar) --> Idea Gemini
  txtCapt = "";
  for (int i = 0; i < lengthCapt; i++) {
    txtCapt += alphabet.charAt(floor(random(alphabet.length())));
  }
  return txtCapt;
}

PImage genCaptImg(String text) {
  PGraphics pg = createGraphics(600, 300);
  pg.beginDraw();
  pg.background(240); 

  // Background dots --> Idea Gemini
  for (int i = 0; i < 25000; i++) {
    pg.stroke(random(150, 255), 150); 
    pg.point(random(pg.width), random(pg.height)); 
  }

 
  pg.textAlign(CENTER, CENTER);
  float charSpacing = pg.width / (text.length() + 1.0); 
  float baseSize = pg.height * 0.35;
  for (int i = 0; i < text.length(); i++) {
    pg.pushMatrix();
    
    // Random position
    float x = charSpacing * (i + 0.5) + random(-pg.width * 0.02, pg.width * 0.02);
    float y = pg.height / 2 + random(-pg.width * 0.1 , pg.width * 0.1 );
    
    pg.translate(x, y);
    pg.rotate(random(-0.7, 0.7)); 
    
    // Random size
    pg.textSize(random(baseSize * 0.7, baseSize * 1.3)); 
    
    // Random color
    pg.fill(random(150), 220); 
    
    pg.text(text.charAt(i), 0, 0);
    pg.popMatrix();
  }
  
  // Different shapes
  float density = 7;
  float count = int((pg.width * pg.height) / 10000 * density);
  for (int i = 0; i < count; i++) {
    
    pg.stroke(random(50, 180), random(100, 200)); 
    pg.strokeWeight(random(1, 4.2));
    pg.noFill();
    
    float x = random(pg.width);
    float y = random(pg.height);
    float size = random(20, 100);
    float shape = random(1);
    
    if (shape < 0.3) {
      pg.ellipse(x, y, size, size * random(0.5, 1.5));
    } else if(shape < 0.6) {
      pg.rect(x, y, size, size * random(0.5, 1.5));
    } else {
      pg.line(x, y, random(pg.width), random(pg.height));
    }
  } 
  
  // Wave filter --> Idea and formula: Gemini 
  pg.loadPixels();
  int[] tempPixels = new int[pg.pixels.length];
  for (int y = 0; y < pg.height; y++) {
    for (int x = 0; x < pg.width; x++) {
      
      int offsetX = (int) (sin(y * 0.1) * 7); 
      int newX = constrain(x + offsetX, 0, pg.width - 1);
      tempPixels[y * pg.width + x] = pg.pixels[y * pg.width + newX];
    }
  }
  arrayCopy(tempPixels, pg.pixels);
  pg.updatePixels();
  pg.endDraw();
  return pg.get();
}
