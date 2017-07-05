import 'package:flutter/material.dart';
import './api.dart';

const _name = "Akinator";
final ai = new Apinator();
bool _aiLoaded = false;

void main() {
  runApp(new FriendlyChatApp());
}

class FriendlyChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: "网络天才Akinator",
        home: new ChatScreen()
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin {
  String message = "点击右下开始";
  String _progression="0.0000";
  List element = new List();
  AnimationController animationController;
  final List<AnswerButton> _answers = <AnswerButton>[];

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _handleAnswers(as,p) {
    _progression =p;
    _answers.clear();
    for (var i = 0, l = as.length; i < l; i++) {
      int id = i;
      _answers.add(new AnswerButton(as[l - 1 - i]['text'], () {
        setState(() {
          _answers.clear();
          message = '思考中...';
        });
        ai.sendAnswer(id);
      }));
    }
    setState(() {});
  }

  void _handleMessage(String text, {el}) {
    setState(() {
      message = text;
      element = el;
    });
    animationController.forward();
  }

  void start() {
    setState(() {
      message = '正在准备问题';
      _progression="0.0000";
      if(element!=null)element.clear();
      _answers.clear();
    });
    ai.hello(
        onAsk: (q, a, p) {
          var qs = q;
          if (qs != null) qs = qs["text"];
          _handleMessage(qs);
          _handleAnswers(a,p);

        },
        onFound: (c) {
          _handleMessage('', el: c);
        }
    );
  }

  @override
  Widget build(BuildContext ctx) {
    animationController = new AnimationController(
      duration: new Duration(milliseconds: 700),
      vsync: this,
    );
    animationController.forward();
    return new Scaffold(
        floatingActionButton: new FloatingActionButton(
            child: new Icon(Icons.add), onPressed: start),
        body:
        new Container(
            decoration: new BoxDecoration(
                image: new DecorationImage(
                    fit: BoxFit.contain,
                    alignment: FractionalOffset.centerLeft,
                    repeat: ImageRepeat.repeat,
                    image: new AssetImage('assets/bg.jpg')
                )),
            child: new Container(
                padding: const EdgeInsets.only(bottom: 50.0),
                decoration: new BoxDecoration(
                    image: new DecorationImage(
                        fit: BoxFit.contain,
                        alignment: FractionalOffset.bottomCenter,
                        image: new AssetImage('assets/tapis.png')
                    )),
                child: new Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      new Flexible(
                          flex: 1,
                          fit: FlexFit.loose,
                          child: new Stack(
                            overflow: Overflow.visible,
                            children: <Widget>[
                              new Positioned(
                                  right: -50.0,
                                  left: 10.0,
                                  top: 0.0,
                                  bottom: 0.0,
                                  child: new Flex(
                                      direction: Axis.vertical,
                                      children: <Widget>[
                                        new Flexible(
                                          flex: 1, child: new Container(
                                            padding: const EdgeInsets.only(top: 24.0),
                                          alignment: FractionalOffset.centerLeft,
                                            child: new Text(_progression,style: new TextStyle(color: Colors.white)),
                                        ),),
                                        new Flexible(
                                            flex: 3,
                                            child: new Container(
                                              decoration: new BoxDecoration(
                                                  image: new DecorationImage(
                                                      fit: BoxFit.fill,
                                                      alignment: FractionalOffset
                                                          .centerLeft,
                                                      repeat: ImageRepeat
                                                          .noRepeat,
                                                      image: new AssetImage(
                                                          'assets/bulle.png')
                                                  )),
                                              child: new ChatMessage(
                                                  message, element,
                                                  animationController
                                              ),
                                            )),
                                        new Flexible(
                                          fit: FlexFit.tight,
                                          flex: 3,
                                          child: new Column(
                                              children: _answers
                                          ),
                                        )
                                      ]
                                  ))
                            ],
                          )
                      ),
                      new Flexible(
                          flex: 1,
                          fit: FlexFit.loose,
                          child: new Image(
                            image: new AssetImage('assets/akinator_defi.png'),
                          )
                      )
                    ]
                )
            )
        )
    );
  }
}

class AnswerButton extends StatelessWidget {
  final onPress;
  final String text;

  AnswerButton(this.text, this.onPress);

  @override
  Widget build(BuildContext ctx) {
    return
      new Container(
          margin: const EdgeInsets.only(top: 8.0),
          decoration: new BoxDecoration(
              image: new DecorationImage(
                  fit: BoxFit.fill,
                  alignment: FractionalOffset.center,
                  image: new AssetImage('assets/bg-reponses.png')
              )),
          child: new FlatButton(
              onPressed: onPress,
              child: new Text(text, style: new TextStyle(fontSize: 13.0)))
      );
  }
}


class ChatMessage extends StatelessWidget {
  ChatMessage(this.text, this.element, this.animationController);

  final List element;
  final String text;
  final AnimationController animationController;

  @override
  Widget build(BuildContext ctx) {
    bool isAct = element!=null&&element.length >0;
    String title = isAct? element[0]['name']:'提问';
    Widget cd = !isAct ? new Container(
        padding: const EdgeInsets.only(left: 50.0, right: 50.0),
        alignment: FractionalOffset.center,
        child: new Text(text)
    ) : new Container(
        padding: const EdgeInsets.only(top: 80.0,bottom: 30.0, left: 45.0, right: 55.0),
        alignment: FractionalOffset.center,
        child: new Container(
          decoration: new BoxDecoration(
              borderRadius:new BorderRadius.all(new Radius.circular(5.0)),
            border: new Border.all(color: Colors.brown),

              image: new DecorationImage(
                  fit: BoxFit.contain,
                  alignment: FractionalOffset.center,
                  image: new NetworkImage(element[0]['pic']))),

        )
    );

    return new FadeTransition(
        opacity: new CurvedAnimation(
            parent: animationController,
            curve: Curves.easeOut
        ),
        child: new Stack(
          children: <Widget>[
            new Positioned(
                right: 10.0,
                left: 0.0,
                height: 24.0,
                top: 40.0,
                child: new Container(
                    alignment: FractionalOffset.center,
                    child: new Text(title, style: new TextStyle(
                      color: Colors.brown, fontSize: 20.0,)))),
            new Positioned(
                top: 0.0,
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: cd)
          ],
        )
    );
  }
}