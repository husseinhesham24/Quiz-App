import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quiz_app/styles/AnswerButton.dart';
import 'package:quiz_app/styles/HeadingText.dart';
import 'package:quiz_app/styles/QuestionText.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:quiz_app/voice-recognition/speech.dart';


import 'ques.dart';

//APP CONSTANTS
var _THEME_COLOUR_ = const Color(0xff0A3D62);

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isListening = false;
  String text = "";
  int totalQues = 3;
  int solvedQues = 0;
  String nextQue = "";
  String quiz_status = "START";
  String score = "";
  String op1, op2, op3, op4, answer;
  bool isQuizStarted = false;
  int finalScore = 0;
  List<int> solvedQuesIndexes = [];

  void check_ans(String value) {
    //print("ans: " + value);
    setState(() {
      solvedQues += 1;
      if ((value.toLowerCase() == answer) || (text.toLowerCase() == answer)) {
        finalScore += 1;
        print("ans: " + value.toLowerCase() +" ----> "+answer);
      }
      else{
        print("ans: " + value.toLowerCase() +" ----> "+answer);
      }
      if (solvedQues == 3) {
        isQuizStarted = false;
        score = "SCORE: $finalScore/$totalQues";
        nextQue = "";
        op1 = "";
        op2 = "";
        op3 = "";
        //op4 = "";
      } else {
        var index = Random().nextInt(QUES.length);
        while (solvedQuesIndexes.contains(index)) {
          index = Random().nextInt(QUES.length);
        }
        solvedQuesIndexes.add(index);
        List<String> ans = QUES[index]['answers'];
        nextQue = QUES[index]['question'];
        op1 = ans[0];
        op2 = ans[1];
        op3 = ans[2];
        //op4 = ans[3];
        answer = ans[QUES[index]['correctIndex']];
      }
    });
  }

  void start_quiz() {
    print("In");
    setState(() {
      finalScore = 0;
      solvedQues = 0;
      isQuizStarted = true;
      score = "";
      quiz_status = "RESTART";
      solvedQuesIndexes = [];
      var index = Random().nextInt(QUES.length);
      while (solvedQuesIndexes.contains(index)) {
        index = Random().nextInt(QUES.length);
      }
      solvedQuesIndexes.add(index);
      List<String> ans = QUES[index]['answers'];
      nextQue = QUES[index]['question'];
      op1 = ans[0];
      op2 = ans[1];
      op3 = ans[2];
      //op4 = ans[3];
      answer = ans[QUES[index]['correctIndex']];
    });
  }

  // String nextque = "Whats is the scientific name of a butterfly?";
  @override
  Widget build(BuildContext context) {
    double screen_width = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _THEME_COLOUR_,
        title: Text(
          "QUIZ",
          style: TextStyle(
            fontSize: 24.0,
          ),
        ),
        centerTitle: true,
      ),
      // backgroundColor: _THEME_BG_COLOUR_,
      body: ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  HeadingText(
                    "Questions: $solvedQues/$totalQues".toUpperCase(),
                  ),
                  QuestionText("$nextQue", screen_width),
                  //Answer Button
                  Column(
                    children: <Widget>[
                      AnswerButton(op1, isQuizStarted, check_ans, screen_width),
                      AnswerButton(op2, isQuizStarted, check_ans, screen_width),
                      AnswerButton(op3, isQuizStarted, check_ans, screen_width),
                    ],
                  ),
                  HeadingText("$score".toUpperCase()),
                ],
              ),
            ],
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: isListening,
        endRadius: 75,
        glowColor: Theme.of(context).primaryColor,
        child: FloatingActionButton(
          child: Icon(isListening ? Icons.mic : Icons.mic_none, size: 36),
          onPressed: toggleRecording,
        ),
      ),
    );
  }

  Future toggleRecording() => SpeechApi.toggleRecording(
        onResult: (text) => setState(() => this.text = text),
        onListening: (isListening) {
          setState(() => this.isListening = isListening);

          if (!isListening) {
            Future.delayed(Duration(seconds: 1), () {
              String start = "start";
              String restart = "restart";

              if (text.contains(start) || text.contains(restart)) {
                start_quiz();
              } else {
                check_ans(text);
              }
            });
          }
        },
      );
}
