import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:provider/provider.dart';
import '../../api/provider/stateModel.dart';

class PersonalPage extends StatelessWidget {
  const PersonalPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // StateModel _stateModel = Provider.of<StateModel>(context);
    // Color headcolor = _stateModel.walletTheme.brightness == Brightness.dark
    //     ? null
    //     : Colors.cyan;
    // Color headcolor = Colors.white;
    return Scaffold(
      appBar: AppBar(
        title: Text('我'),
        elevation: 0.0,
        backgroundColor: Colors.black,
      ),
      // drawer: Drawer(
      //     child: Column(
      //   children: <Widget>[
      //     UserAccountsDrawerHeader(
      //       currentAccountPicture: CircleAvatar(backgroundColor: Colors.cyan),
      //       accountEmail: Text('xxxxxxx@163.com'),
      //       accountName: Text('hzf'),
      //     )
      //   ],
      // )),
      body: Column(
        children: <Widget>[
          Container(
            height: 200,
            // margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
            // color: headcolor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.folder_shared,
                            size: 36,
                            color: Colors.black,
                          ),
                          onPressed: () {},
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          '管理钱包',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.alarm,
                            size: 36,
                            color: Colors.black,
                          ),
                          onPressed: () {},
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          '交易记录',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                )
                // Expanded(
                // child: Image.network(
                //   'https://www.itying.com/images/flutter/3.png',
                //   fit: BoxFit.cover,
                // )
                // )
              ],
            ),
          ),
          Divider(
            height: 1,
          ),
          // ListTile(
          //   leading: Icon(Icons.theaters, size: 30),
          //   title: Text('切换主题'),
          //   subtitle: Text('切换主题，夜间模式，白天模式'),
          //   trailing: Icon(Icons.keyboard_arrow_right),
          //   onTap: () {
          //     // this.changeTheme(_stateModel);
          //   },
          // ),
          // Divider(
          //   height: 1,
          // ),
          // ListTile(
          //   leading: Icon(Icons.system_update_alt, size: 30),
          //   title: Text('系统设置'),
          //   trailing: Icon(Icons.keyboard_arrow_right),
          //   onTap: () {},
          // ),
          // Divider(
          //   height: 1,
          // ),
          ListTile(
            // leading: Icon(Icons.bluetooth, size: 25,color: Colors.black,),
            title: Text('蓝牙连接',style: TextStyle(color: Colors.black),),
            // subtitle: Text('蓝牙协议，数据通讯'),
            // trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.pushNamed(context, '/blue');
            },
          ),
          Divider(
            height: 1,
          ),
          ListTile(
            // leading: Icon(Icons.pan_tool, size: 25,color: Colors.black,),
            title: Text('挖矿',style: TextStyle(color: Colors.black),),
            // subtitle: Text('SIM卡蓝牙挖矿，请保持蓝牙连接'),
            // trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.pushNamed(context, '/miner');
            },
          ),
          Divider(
            height: 1,
          ),
          // ListTile(
          //   leading: Icon(Icons.update, size: 25),
          //   title: Text('升级版本'),
          //   subtitle: Text('当前版本v1.0.0,可更新至于v1.0.1'),
          //   trailing: Icon(Icons.keyboard_arrow_right),
          //   onTap: () {},
          // ),
          // Divider(
          //   height: 1,
          // ),
        ],
      ),
    );
  }

  // void changeTheme(StateModel model) {
  //   WalletTheme _theme = WalletTheme();
  //   _theme.brightness = model.walletTheme.brightness == Brightness.light
  //       ? Brightness.dark
  //       : Brightness.light;
  //   // _theme.appBarbackColor = model.walletTheme.appBarbackColor == Colors.cyan
  //   //     ? Colors.black12
  //   //     : Colors.cyan;
  //   model.updateTheme(_theme);
  // }
}
