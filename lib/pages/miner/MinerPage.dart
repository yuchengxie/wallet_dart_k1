import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nbc_wallet/api/miner.dart';

class MinerPage extends StatefulWidget {
  MinerPage({Key key}) : super(key: key);

  _MinerPageState createState() => _MinerPageState();
}

class _MinerPageState extends State<MinerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('123'),
      ),
      body: Container(
        margin: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    child: Text('开始挖矿'),
                    onPressed: () {
                      startMiner();
                      print('start miner');
                    },
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    child: Text('停止挖矿'),
                    onPressed: () {
                      // startMiner();
                      stopMiner();
                      print('stop miner');
                    },
                  ),
                )
              ],
            )
            // Expanded(
            //   child: Row(
            //     children: <Widget>[
            //       RaisedButton(
            //         child: Text('开始挖矿'),
            //         onPressed: () {
            //           startMiner();
            //           print('start miner');
            //         },
            //       ),
            //     ],
            //   ),
            // )

            // RaisedButton(
            //   child: Text('开始挖矿'),
            //   onPressed: () {
            //     startMiner();
            //     print('start miner');
            //   },
            // ),
            // RaisedButton(
            //   child: Text('停止挖矿'),
            //   onPressed: () {
            //     print('stop miner');
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
