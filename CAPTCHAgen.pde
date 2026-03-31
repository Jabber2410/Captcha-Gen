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
  }
  tf_enter.setText("");
  genCapt();
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
  genCapt();
}

void refreshUI() {
  if (imgCaptAlt != null) {
    zeigeBildInGUI(imgCaptAlt);
  }
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
  PGraphics pg = createGraphics(600, 300);
  pg.beginDraw();
  pg.background(240); // Leichtes Grau statt hartem Weiß

  // 1. SCHRITT: Hintergrund-Rauschen (Punkte)
  for (int i = 0; i < 2000; i++) {
    pg.stroke(random(150, 255), 150); // Halbtransparente Punkte
    pg.point(random(pg.width), random(pg.height));
  }

  // 2. SCHRITT: Buchstaben zeichnen
  pg.textAlign(CENTER, CENTER);
  float charSpacing = pg.width / (text.length() + 1.0); 
  float baseSize = pg.height * 0.35;
  for (int i = 0; i < text.length(); i++) {
    pg.pushMatrix();
    
    // Variablere Positionen (enger zusammen für Überlappung)
    float x = charSpacing * (i + 0.5) + random(-pg.width * 0.02, pg.width * 0.02);
    float y = pg.height / 2 + random(-pg.width * 0.1 , pg.width * 0.1 );
    
    pg.translate(x, y);
    pg.rotate(random(-0.7, 0.7)); 
    
    // Zufällige Größe pro Buchstabe
    pg.textSize(random(baseSize * 0.7, baseSize * 1.3)); 
    
    // Zufällige Farbe mit Transparenz (Alpha)
    pg.fill(random(150), 220); 
    
    pg.text(text.charAt(i), 0, 0);
    pg.popMatrix();
  }
  
  // 3. SCHRITT: Komplexe Störformen
  float density = 5;
  float count = int((pg.width * pg.height) / 10000 * density);
  for (int i = 0; i < count; i++) {
    // Zufällige Graustufe und Transparenz
    pg.stroke(random(50, 180), random(100, 200)); 
    pg.strokeWeight(random(1, 4.2));
    pg.noFill();
    
    float x1 = random(pg.width);
    float y1 = random(pg.height);
    float size = random(20, 100);
    float shape = random(1);
    
    if (shape < 0.3) {
      pg.ellipse(x1, y1, size, size * random(0.5, 1.5));
    } else if(shape < 0.6) {
      pg.rect(x1, y1, size, size * random(0.5, 1.5));
    } else {
      pg.line(x1, y1, random(pg.width), random(pg.height));
    }
  } 
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
