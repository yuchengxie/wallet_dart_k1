import 'package:flutter/material.dart';
import 'package:nbc_wallet/pages/tabpages/assetPage.dart';
import 'package:nbc_wallet/pages/tabpages/findPage.dart';
import 'package:nbc_wallet/pages/tabpages/marketPage.dart';
import 'package:nbc_wallet/pages/tabpages/personalPage.dart';

class Tabs extends StatefulWidget {
  Tabs({Key key}) : super(key: key);

  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int _currentIndex = 0;
  // List _list = [AssetPage(), MarketPage(), FindPage(), PersonalPage()];
  List _list = [AssetPage(), PersonalPage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _list[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation:0,
        selectedFontSize: 13,
        unselectedFontSize: 13,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.web_asset, color: Colors.black),
              title: Text('资产', style: TextStyle(color: Colors.black))),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                color: Colors.black,
              ),
              title: Text(
                '我',
                style: TextStyle(color: Colors.black),
              )),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
