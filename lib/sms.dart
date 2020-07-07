import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:http/http.dart' as http;

class MyInbox extends StatefulWidget {
  @override
  State createState() {
    return MyInboxState();
  }
}

class MyInboxState extends State {
  String urlSaveSMS = "https://vvinoa.vvin.com/api/tng.php";
  SmsQuery query = new SmsQuery();
  List messages = new List();
  bool ready = false;
  List<Details> detailsList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SMS Inbox"),
        backgroundColor: Colors.pink,
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          RaisedButton(child: Text('Send data to API'), onPressed: fetchSMS),
          SizedBox(
            height: 10,
          ),
          (ready == false)
              ? Container()
              : Flexible(
                  child: SingleChildScrollView(
                    physics: ScrollPhysics(),
                    child: Column(
                      children: _list(),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  List<Widget> _list() {
    List widgetList = <Widget>[];
    for (var i = 0; i < detailsList.length; i++) {
      Widget widget1;
      widget1 = Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(20.0),
                  width: 20,
                  height: 20,
                  child: Icon(
                    Icons.markunread,
                    color: Colors.pink,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Amount: ' + detailsList[i].money,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Name: ' + detailsList[i].name,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Time: ' + detailsList[i].time,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Reference: ' + detailsList[i].reference,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(),
        ],
      );
      widgetList.add(widget1);
    }
    return widgetList;
  }

  fetchSMS() async {
    messages = await query.querySms(address: '63001');
    detailsList.clear();
    for (var message in messages) {
      if (message.body.toString().substring(0, 22) ==
          'RM0.00 TNG eWallet: RM') {
        String data = message.body;
        List amount = data.split(' has been');
        List amount1 = amount[0].split('eWallet: ');
        String money = amount1[1];
        List person = amount[1].split(' on ');
        String name = person[0].toString().substring(9);
        List dateTime = person[1].split('. ');
        String time = dateTime[0];
        List referenceList = data.split('Transaction reference: ');
        String reference = referenceList[1];
        Details detail = Details(
          money: money,
          name: name,
          time: time,
          reference: reference,
        );
        detailsList.add(detail);
      }
    }
    setState(() {
      ready = true;
    });
    for (var message in detailsList) {
      http.post(urlSaveSMS, body: {
        "amount": message.money,
        "name": message.name,
        "time": message.time,
        "reference": message.reference,
      }).then((res) {});
    }
  }
}

class Details {
  String money, name, time, reference;
  Details({this.money, this.name, this.time, this.reference});
}
