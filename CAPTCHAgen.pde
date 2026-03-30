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
  pg.background(240); // Leichtes Grau statt hartem Weiß

  // 1. SCHRITT: Hintergrund-Rauschen (Punkte)
  for (int i = 0; i < 2000; i++) {
    pg.stroke(random(150, 255), 150); // Halbtransparente Punkte
    pg.point(random(pg.width), random(pg.height));
  }

  // 2. SCHRITT: Buchstaben zeichnen
  pg.textAlign(CENTER, CENTER);
  for (int i = 0; i < text.length(); i++) {
    pg.pushMatrix();
    
    // Variablere Positionen (enger zusammen für Überlappung)
    float x = 60 + i * 65 + random(-15, 15);
    float y = pg.height / 2 + random(-30, 30);
    
    pg.translate(x, y);
    pg.rotate(random(-0.7, 0.7)); 
    
    // Zufällige Größe pro Buchstabe
    pg.textSize(random(50, 85)); 
    
    // Zufällige Farbe mit Transparenz (Alpha)
    pg.fill(random(150), random(150), random(150), 220); 
    
    pg.text(text.charAt(i), 0, 0);
    pg.popMatrix();
  }
  
  // 3. SCHRITT: Komplexe Störformen
  for (int i = 0; i < 40; i++) {
    // Zufällige Graustufe und Transparenz
    pg.stroke(random(50, 180), random(100, 200)); 
    pg.strokeWeight(random(1, 4));
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
      // Berechnet eine Wellenbewegung basierend auf der Sinus-Funktion
      int offsetX = (int) (sin(y * 0.1) * 5); 
      int newX = constrain(x + offsetX, 0, pg.width - 1);
      tempPixels[y * pg.width + x] = pg.pixels[y * pg.width + newX];
    }
  }
  arrayCopy(tempPixels, pg.pixels);
  pg.updatePixels();
  pg.endDraw();
  return pg.get();
}

/*PImage genCaptImg(String text) {
  PGraphics pg = createGraphics(400, 200);
  pg.beginDraw();
  pg.background(255);
  pg.textSize(60);
  pg.textAlign(CENTER, CENTER);

  for (int i = 0; i < text.length(); i++) {
    pg.pushMatrix();
    
    float x = 50 + i * 70 + random(-25, 25);
    float y = pg.height / 2 + random(-60, 60);
    
    pg.translate(x, y);
    pg.rotate(random(-0.6, 0.6)); 
    pg.fill(random(200), random(200), random(200)); 
    
    pg.text(text.charAt(i), 0, 0);
    pg.popMatrix();
  }
  
    for (int i = 0; i < 30; i++) {
    pg.stroke(random(100, 200)); 
    pg.strokeWeight(random(1, 3));
    pg.noFill(); // Verhindert, dass Kreise den Text mit Weiß/Farbe füllen
    
    float x1 = random(pg.width);
    float y1 = random(pg.height);
    float x2 = random(pg.width);
    float y2 = random(pg.height);
    float shape = random(1);
    
    if (shape < 0.3) {
      // Zeichne einen Kreis
      pg.ellipse(x1, y1, x2, x2);
    } else if(shape >= 0.3 && shape < 0.6) {
      // Zeichne ein kleines Rechteck, das auch leicht gedreht ist
      pg.rect(x1, y1, x2, y2);
    } else {
      pg.line(x1, y1, x2, y2);
    }
   } 

  pg.endDraw();
  return pg.get();
}*/
