import java.util.Collections;
import java.net.URLEncoder;
import java.io.UnsupportedEncodingException;
import ddf.minim.*;

Minim minim;
AudioInput in;

boolean dark = true;


ArrayList<WordNode> inferenceResult = new ArrayList<WordNode>();
ArrayList<ArrayList<WordNode>> inferenceResultRandom = new ArrayList<ArrayList<WordNode>>();
ArrayList<ArrayList<WordNode>> inferenceResultRandomDark = new ArrayList<ArrayList<WordNode>>();
String[] vocabs_ori;
ArrayList<String> vocabs = new ArrayList<String>();

ArrayList<ArrayList<WordNode>> makeWordRandomNodes(String json, String personaType) {
  ArrayList<ArrayList<WordNode>> result = new ArrayList<ArrayList<WordNode>>();
  JSONObject jsonObj = parseJSONObject(json);
  JSONObject persona = jsonObj.getJSONObject(personaType);
  JSONArray tokens = persona.getJSONArray("tokens");
  for (int i = 0; i < tokens.size(); i++) {
    ArrayList<WordNode> innerResult = new ArrayList<WordNode>();
    JSONObject tokenObj = parseJSONObject(tokens.get(i).toString());
    int tokenId = tokenObj.getInt("token_id");
    JSONArray utterences = tokenObj.getJSONArray("utterences");
    float max_score = 0;
    int max_rank = 0;
    for (int j = 0; j < utterences.size(); j++) {
      JSONObject utterencesObj = parseJSONObject(utterences.get(j).toString());
      String label = utterencesObj.getString("vocab_text");
      label = label.replace("▁", "");
      if (label.equals("")) {
        label = "\" \"";
      }
      float score = utterencesObj.getFloat("vocab_score") * 1.1;
      int rank = utterencesObj.getInt("rank");
      int selected = 0;
      if (rank == 0) {
        selected = 1;
        if (tokenId == tokens.size()-1) {
          label = "<end>";
        }
      }
      WordNode wordNode = new WordNode(label, tokenId, rank, score, selected);
      innerResult.add(wordNode);
      if (rank == 0) {
        max_score = score;
      }
      max_rank = rank + 1;
    }
    for (int k = 0; k < 15 - utterences.size(); k++) {
      String randLabel = vocabs.get(int(random(0, vocabs.size()-1))).replace("▁", "");
      WordNode wordNode = new WordNode(randLabel, tokenId, max_rank, 0.001, 2);
      innerResult.add(wordNode);
      max_rank += 1;
    }
    Collections.shuffle(innerResult);
    result.add(innerResult);
  }
  return result;
}


PFont myFont;
int fontSize = 30;
float lastTime = 0;
int charCnt = 1;
//int tokenCnt = 0;

String inputSent = "오늘 날씨 참 좋지 않니?";
char[] inputSentChars = inputSent.toCharArray();

int phaseFlag = 0;
int movingBox = 0;

boolean startFlag = false;



String URLEncode(String string) {
  String output = new String();
  try {
    byte[] input = string.getBytes("UTF-8");
    for (int i=0; i<input.length; i++) {
      if (input[i]<0)
        output += '%' + hex(input[i]);
      else if (input[i]==32)
        output += '+';
      else
        output += char(input[i]);
    }
  }
  catch(UnsupportedEncodingException e) {
    e.printStackTrace();
  }
  return output;
}

void setup() {
  fullScreen(2);
  background(25, 25, 25);

  myFont = createFont("맑은 고딕 Bold", fontSize);
  vocabs_ori = loadStrings("vocab.txt");
  for (int i = 0; i < vocabs_ori.length; i++) {
    vocabs.add(vocabs_ori[i].split("\t")[1]);
  }
  String encodedInput = URLEncode(inputSent);
  String[] data = loadStrings("http://127.0.0.11:9090/visualization?question=" + encodedInput);
  inferenceResultRandom = makeWordRandomNodes(data[0], "void");
  textFont(myFont);
  
}

void draw() {
  frameRate(120);
  background(25, 25, 25);
  
  if(startFlag == true){
  for (int tokenCnt = 0; tokenCnt < inferenceResultRandom.size(); tokenCnt++) {
    for (int i = 0; i < inferenceResultRandom.get(tokenCnt).size(); i++) {
      float x = 20 + inferenceResultRandom.get(tokenCnt).get(i).tokenId * 150;
      float y = 100 + i * 30;
      String label = inferenceResultRandom.get(tokenCnt).get(i).label;
      float score = inferenceResultRandom.get(tokenCnt).get(i).score;
      int selected = inferenceResultRandom.get(tokenCnt).get(i).selected;
      if (selected == 1) {
        
        float fromX = x + textWidth(label);
        float fromY = y;
        if (tokenCnt + 1 < inferenceResultRandom.size()) {
          float toX = 20 + inferenceResultRandom.get(tokenCnt + 1).get(i).tokenId * 150;
          for (int j = 0; j < inferenceResultRandom.get(tokenCnt + 1).size(); j++) {
            float toY = 100 + j * 30;
            if (inferenceResultRandom.get(tokenCnt+1).get(j).selected == 1) {
              strokeWeight(5);
              if(dark){
                stroke(255, 223, 125);
              } else{
                stroke(51, 253, 223);
              }
            } else if (inferenceResultRandom.get(tokenCnt+1).get(j).selected == 0) {
              strokeWeight(3);
              if(dark){
                stroke(255, 244, 210);
              } else{
                stroke(1, 155, 188);
              }
            } else {
              strokeWeight(1);
              stroke(200, 200, 200);
            }
            line(fromX, fromY, toX, toY);
          }
        }
        if(dark){
          fill(255, 223, 125);
        } else{
          fill(51, 253, 223);
        }
        textSize(fontSize * score + 20);
      } else if (selected == 0) {
        if(dark){
          fill(255, 244, 210);
        } else{
          fill(1, 155, 188);
        }
      } else {
        fill(200, 200, 200);
      }
      textAlign(LEFT);
      textSize(fontSize * score + 20);
      text(label, x, y);
    }
  }
  fill(25, 25, 25);
  noStroke();
  rect(frameCount * 30, 0, width, height);
  }
  fill(255, 255, 255);
  textSize(50);
  textAlign(CENTER);
  text(inputSent, width/2, 50);
}

void mouseClicked(){
  startFlag = true;
  frameCount = 0;
  if(dark == true){
    dark = false;
    String encodedInput = URLEncode(inputSent);
    String[] data = loadStrings("http://127.0.0.1:9090/visualization?question=" + encodedInput);
    inferenceResultRandom = makeWordRandomNodes(data[0], "void");
  } else{
    dark = true;
    String encodedInput = URLEncode(inputSent);
    String[] data = loadStrings("http://127.0.0.1:9090/visualization?question=" + encodedInput);
    inferenceResultRandom = makeWordRandomNodes(data[0], "void");
  }
  
}
