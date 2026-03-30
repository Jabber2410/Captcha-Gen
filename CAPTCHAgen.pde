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
import javafx.scene.paint.Color; // Achtung: JavaFX Color vs Processing color

// === GUI ELEMENTE ===
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

// === Bild-Variablen ===
PImage imgCaptAlt, imgRobot;
int lengthCapt = 5;
String txtcapt;

void setup() {
  size(200, 100);
  thread("starteJavaFX");
  //imgRobot = loadImage("robot.png"); 
  genCapt();
}


// === EVENT-HANDLER ===
@FXML
void handleGenerate() {
  genCapt();
}

@FXML
void handleEnter() {
 String value = tf_enter.getText().toUpperCase();
  if(value.equals(txtcapt)) { 
    lb_feedback.setText("You are not a Robot");
    lb_feedback.setTextFill(Color.GREEN);
  } else {
    lb_feedback.setText("Help a Robot");
    lb_feedback.setTextFill(Color.RED);
    //zeigeBildInGUI(imgRobot);
  }
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
      
      loader.setController(this); // Dieser Sketch ist der Controller
      
      Parent root = loader.load();
      stage.setScene(new Scene(root));
      stage.setTitle("CAPTCHA Generator");
      stage.setResizable(false);
      stage.show();
    } catch (Exception e) {
      e.printStackTrace();
    }
  });
}


void zeigeBildInGUI(PImage pimg) {
  String tempPath = dataPath("temp_img.png");
  pimg.save(tempPath);
  imp.Picture impBild = new imp.Picture(tempPath);
  
  if (pv_captcha != null) {
    Platform.runLater(() -> pv_captcha.setImage(impBild, true));
  }
}

void genCapt() {
  imgCaptAlt = genCaptImg(genTxt());
  zeigeBildInGUI(imgCaptAlt);
}

String genTxt () {
  String alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // Ohne 0, O, I, 1 (Verwechslungsgefahr)
  txtcapt = "";
  for (int i = 0; i < lengthCapt; i++) {
    txtcapt += alphabet.charAt(floor(random(alphabet.length())));
  }
  return txtcapt;
}
PImage genCaptImg(String text) {
  PGraphics pg = createGraphics(400, 200);
  pg.beginDraw();
  pg.background(255);
  pg.textSize(60);
  pg.textAlign(CENTER, CENTER);

  for (int i = 0; i < text.length(); i++) {
    pg.pushMatrix();
    
    float x = 50 + i * 70;
    float y = pg.height / 2 + random(-20, 20);
    
    pg.translate(x, y);
    pg.rotate(random(-0.5, 0.5)); 
    pg.fill(random(100), random(100), random(100)); 
    
    pg.text(text.charAt(i), 0, 0);
    pg.popMatrix();
  }
  
  // Optional: Ein paar Stör-Linien hinzufügen
  for (int i = 0; i < 5; i++) {
    pg.stroke(random(150));
    pg.line(random(pg.width), random(pg.height), random(pg.width), random(pg.height));
  }

  pg.endDraw();
  return pg.get();
}
