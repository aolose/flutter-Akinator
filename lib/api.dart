import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'dart:convert' show UTF8, JSON;

class Apinator {
  String host = 'api-cn4.akinator.com';
  HttpClient client;
  String session;
  String signature;
  var onAsk;
  var onFound;
  int step = 0;

  Apinator() {
    client = new HttpClient();
    client.findProxy = null;
  }

  _getRes(String path, int num) async {
    if (num > 5) {
      this.onFound('链接失败!');
      return null;
    }
    HttpClientResponse res;
    num++;
    HttpClientRequest req = await client.get(this.host, 80, '/ws/' + path);
    req.headers.contentType = ContentType.JSON;
    try {
      res = await req.close();
    } catch (e) {
      return this._getRes(path, num);
    }
    return res;
  }

  get(String path) async {
    print("get: "+path);
    HttpClientResponse res = await this._getRes(path, 0);
    String s = "";
    await for (var contents in res.transform(UTF8.decoder)) {
      s += contents;
    }
    var r = await JSON.decode(s);
    print("r: "+r.toString());
    return r;
  }

  hello({onAsk, onFound}) async {
    this.onAsk = onAsk;
    this.onFound = onFound;
    this.step = 0;
    String player = (new Random().nextInt(10000)).toRadixString(36);
    Map data = await get('new_session?partner=1&player=' + player);
    this.session = data['parameters']['identification']['session'];
    this.signature = data['parameters']['identification']['signature'];
    data = this.extractQuestion(data);
    this.onAsk(data['question'], data['answers'],data['progression']);
  }

  sendAnswer(int id) async {
    int a = this.step;
    new Future.delayed(const Duration(milliseconds: 10000), (){
      if(this.step==a){
        print('time out!');
        a=-1;
        return this.sendAnswer(id);
      }
    });
    print("输入的ID： " + id.toString());
    var data = await get(
        'answer?session=' +
            this.session +
            '&signature=' +
            this.signature +
            '&step=' +
            this.step.toString() +
            '&answer=' + id.toString());
    if(a!=this.step)return;
    data = this.extractQuestion(data);
    if (data != null && data['last']) {
      this.getCharacters();
    } else
      this.onAsk(data['question'], data['answers'],data['progression']);
    this.step++;
  }

  getCharacters() async {
    String url = 'list?session=' +
        this.session +
        '&signature=' +
        this.signature +
        '&step=' +
        this.step.toString() +
        '&size=1&max_pic_width=256&max_pic_height=256&pref_photos=OK-FR&mode_question=0';
    print("Answer URL: " + url);
    var data = await get(url);
    var characters = [];
    for (var c in data['parameters']['elements']) {
      characters.insert(0, {
        'id': c['element']['id'],
        'name': c['element']['name'],
        'proba': c['element']['proba'],
        'pic':c['element']['absolute_picture_path']
      });
    }
    this.onFound(characters);
    this.step++;
  }

  extractQuestion(Map data) {
    Map parameters = data['parameters'];
    if (parameters['step_information'] != null)
      parameters = parameters['step_information'];
    var question = {
      'id': parameters['questionid'],
      'text': parameters['question'],
    };
    var answers = [];
    List r = parameters['answers'];
    if (r != null) {
      int n = 0;
      for (Map a in r) {
        answers.insert(0, {
          'id': n++,
          'text': a['answer']
        });
      }
    }
    return {
      'progression':parameters['progression'],
      'question': question,
      'answers': answers,
      'last': double.parse(parameters['progression']) >= 99.99
    };
  }
}

getMapValue(Map m, String str, {defaultValue = null}) {
  if (m == null) return defaultValue;
  var a = str.split('.');
  var r = m;
  for (var i in a) {
    r = r[i];
    if (r == null) return defaultValue;
  }
  return r;
}

//void main() {
//  var api = new Apinator();
//  api.hello(
//      onAsk: (q,a) {
//        int i = 4;
//        var qs = q;
//        if(qs!=null)qs=qs["text"];
//        var aw = a[i];
//        if(aw!=null)aw=aw["text"];
//        print('qs:${qs}  aw:${aw}');
//        if(aw!=null)api.sendAnswer(a[i]['id']);
//      },
//      onFound: (c) {
//        print(c);
//      }
//  );
//}