import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'bluetooth/blueservice.dart';
import 'utils/bytes.dart';
import 'utils/utils.dart';

var SELECT = '00A404000ED196300077130010000000020101';
var cmd_pubAddr = '80220200020000';
var cmd_pubkey = '8022000000';
var cmd_pubkeyHash = '8022010000';
Timer _heartTimer;

var mine_hostname = 'user1-node.nb-chain.net';
var mine_port = 30302;
var pseudoWallet;
List<InternetAddress> addressArray;
PoetClient gPoetClient;

initialize() {}

// main() {
//   int i = "poetinfo".compareTo("poetinfo");
//   print("poetinfo" == "poetinfo");
//   print(i);
// }

stopMiner() {
  if (_heartTimer != null) {
    _heartTimer.cancel();
  }
}

startMiner() async {
  addressArray = await InternetAddress.lookup(mine_hostname);
  // PoetClient gPoetClient = PoetClient(socket: datagramSocket);
  // String pub_keyhash = 'abc1239fabc1239fabc1239fabc1239fabc1239fabc1239fabc1239fabc1239f'; //蓝牙接口获得
  print('startMiner pub_keyhash:${gPseudoWallet.pubHash}');
  if (gPseudoWallet.pubHash == null || gPseudoWallet.pubHash == "") {
    print("蓝牙连接异常,返回");
    return;
  }
  ;
  String pub_keyhash = gPseudoWallet.pubHash;
  List<int> b_pub_keyhash = hexStrToBytes(pub_keyhash);
  TeeMiner tee = new TeeMiner(b_pub_keyhash);
  //配置参数
  RawDatagramSocket socket =
      await RawDatagramSocket.bind(InternetAddress.ANY_IP_V4, 0);
  gPoetClient = PoetClient(
      // miners, link_no, coin, name = ''
      miners: [tee], link_no: 0, coin: '', name: 'client1');
  gPoetClient.PEER_ADDR_ = [addressArray.first.address, mine_port];
  gPoetClient.last_peer_addr = gPoetClient.PEER_ADDR_;
  PoetClient.socket = socket;
  // gPoetClient.socket = socket;
  //开始挖矿
  // gPoetClient.set_peer(gPoetClient.PEER_ADDR_);
  gPoetClient._onSocketlisten();
  gPoetClient.start();
}

class PoetClient {
  String address;
  int port;
  int POET_POOL_HEARTBEAT = 5 * 1000;
  List PEER_ADDR_ = [];
  bool active = false;
  List<TeeMiner> miners = [];
  String name = '';
  int link_no = 0;
  String coin;
  var last_peer_addr = [];
  List<int> recv_buffer;
  var last_rx_time = 0;
  var last_pong_time = 0;
  int reject_count = 0;
  int last_taskid = 0;
  var time_taskid = 0;
  List compete_src = [];
  // var socket;
  static var socket;

// miners, link_no, coin, name = ''
  PoetClient(
      {this.PEER_ADDR_,
      // this.socket,
      this.miners,
      this.link_no,
      this.coin,
      this.name,
      this.address,
      this.port});
  // PoetClient(
  //     {this.POET_POOL_HEARTBEAT,
  //     this.PEER_ADDR_,
  //     this.socket,
  //     this.active,
  //     this.name,
  //     this.coin,
  //     this.last_peer_addr,
  //     this.recv_buffer,
  //     this.last_rx_time,
  //     this.last_pong_time,
  //     this.reject_count,
  //     this.time_taskid,
  //     this.last_taskid,
  //     this.compete_src});

  static Future<PoetClient> of(String _address, int _port) async {
    socket = await RawDatagramSocket.bind(InternetAddress.ANY_IP_V4, 0);
    return PoetClient(address: _address, port: _port);
  }

  void start() {
    this.active = true;
    _heartTimer =
        Timer.periodic(Duration(milliseconds: POET_POOL_HEARTBEAT), (timer) {
      if (this.active) {
        try {
          // String s =
          //     'f96e6274706f65747461736b000000000c000000ee9b92e3000000000000000000000000';
          // gPoetClient.sendMessage(hexStrToBytes(s), gPoetClient.PEER_ADDR_);
          _heartbeat();
        } catch (error) {
          print('heartbeat error:$error');
          timer.cancel();
          // socketListen.cancel();
        }
      }
    });
  }

  _heartbeat() async {
    if (this.PEER_ADDR_.length == 0) return;
    int now = timest(); //单位毫秒，10位时间戳
    if ((now - this.time_taskid) > 1800) {
      this.time_taskid = 0;
    }
    if (this.reject_count > 120) {
      this.reject_count = 0;
      this.last_taskid = 0;
    }
    if ((now - this.last_rx_time) > 1800 && this.last_peer_addr.length != 0) {
      try {
        // var sock = RawDatagramSocket.bind(InternetAddress.LOOPBACK_IP_V4, 0);
        // socket.close();
        // socket = sock;
        // this.socket.close();
        // this.socket = sock;
        // this.set_peer(this.last_peer_addr);
      } catch (error) {
        print('renew socket err:$error');
      }
    }

    List compete_src = this.compete_src;
    if (compete_src.length == 6) {
      var miners = this.miners;
      var sn = compete_src[0];
      var block_hash = compete_src[1];
      var bits = compete_src[2];
      var txn_num = compete_src[3];
      var link_no = compete_src[4];
      var hi = compete_src[5];
      TeeMiner succ_miner;
      String succ_sig = '';
      for (TeeMiner miner in miners) {
        String sig =
            await miner.check_elapsed(block_hash, bits, txn_num, now, "00", hi);
        print(">>> 接收到签名:$sig");
        if (sig != "") {
          succ_miner = miner;
          succ_sig = sig;
        }
      }
      if (succ_miner != null) {
        //wait next mining loop
        this.compete_src = [];
        var msg = PoetResult(
            link_no: link_no,
            curr_id: sn,
            miner: succ_miner.pub_keyhash,
            sig_tee: succ_sig);
        List<int> payload = getPoetResultPayload(msg);
        List<int> msg_buf = wholePayload(payload, "poetresult");
        //向服务递交数据,写入链
        print("发送写入链:${bytesToHexStr(msg_buf)}");
        this._sendMessage(msg_buf, this.PEER_ADDR_);
        print(
            '${this.name} success mining:link=${link_no},height=${hi},sn=${sn},miner=${bytesToHexStr(succ_miner.pub_keyhash)}');
        sleep(Duration(milliseconds: this.POET_POOL_HEARTBEAT));
      }
    }
    if (now >= (this.last_rx_time + this.POET_POOL_HEARTBEAT / 1000)) {
      GetPoetTask msg = GetPoetTask(
          link_no: this.link_no,
          curr_id: this.last_taskid,
          timestamp: this.time_taskid);
      List<int> payload = getPoetTaskPayload(msg);
      String command = 'poettask';
      List<int> msgBuf = wholePayload(payload, command);
      gPoetClient._sendMessage(msgBuf, this.PEER_ADDR_);
    }
  }

  _sendMessage(List<int> msg, List peer_Addr) {
    InternetAddress internetAddress = InternetAddress(peer_Addr[0]);
    print(
        '[${DateTime.now()}]发送数据:${bytesToHexStr(msg)}-${bytesToHexStr(msg).length}');
    PoetClient.socket.send(msg, internetAddress, mine_port);
  }

  // StreamSubscription socketListen;
  _onSocketlisten() {
    // StreamSubscription socketListen = this.socket.listen((RawSocketEvent evt) {
    StreamSubscription socketListen =
        PoetClient.socket.listen((RawSocketEvent evt) {
      if (evt == RawSocketEvent.READ) {
        Datagram packet = socket.receive();
        String data = bytesToHexStr(packet.data);
        print('[${DateTime.now()}]接收数据:$data-${data.length}');
        this._handle_message(packet.data);
      }
    });
  }

  _handle_message(List<int> payload) {
    String s = bytesToHexStr(payload);
    List<int> bCmd = payload.sublist(4, 16);
    int index = bCmd.indexOf(0);
    bCmd = bCmd.sublist(0, index);
    String sCmd = Latin1Decoder().convert(bCmd);
    print('接收到的消息类型:$sCmd');
    payload = payload.sublist(24);
    if (sCmd == "poetinfo") {
      PoetInfo poetInfo = getPoetInfoMsg(payload);
      if (poetInfo.curr_id > this.last_taskid) {
        this.compete_src = [
          poetInfo.curr_id,
          poetInfo.block_hash,
          poetInfo.bits,
          poetInfo.txn_num,
          poetInfo.link_no,
          poetInfo.height
        ];
        this.last_taskid = poetInfo.curr_id;
        this.time_taskid = this.last_rx_time;
        this.reject_count = 0;
        print(
            ">>>(${this.name} receive a task):link=${poetInfo.link_no},height=${poetInfo.height},sn=${poetInfo.curr_id}");
      }
    } else if (sCmd == 'poetreject') {
      PoetReject reject = getPoetRejectMsg(payload);
      if (reject.timestamp == this.time_taskid) {
        // if (reject.reason == "missed" && this.last_taskid == reject.sequence) {
        // } else {
        //   //invalid
        //   this.compete_src = [];
        //   this.reject_count += 1;
        // }
        this.compete_src = [];
        this.reject_count += 1;
      }
      this.last_pong_time = this.last_rx_time;
    } else if (sCmd == "pong") {
      // print('>>> sCmd:$sCmd');
      this.last_pong_time = this.last_rx_time;
    }
  }

  set_peer(List peer_addr) {
    this.PEER_ADDR_ = peer_addr;
    this.last_peer_addr = peer_addr;
    // String ip = peer_addr[0];
    // int port = peer_addr[1];
    //判断IP地址是否合法，不合法，则重新计算一次，并赋值
    //主机对应的地址发生改变时候，变更
  }
}

class TeeMiner {
  int SUCC_BLOCKS_MAX = 256;
  List succ_blocks = [];
  List<int> pub_keyhash;

  TeeMiner(this.pub_keyhash);
  Future<String> check_elapsed(
      block_hash, bits, txn_num, curr_tm, sig_flag, hi) async {
    print("curr_tm:$curr_tm");
    if (curr_tm == null) curr_tm = timest();
    try {
      String sCmd = '8023' + sig_flag + '00';
      List<int> sCmdBytes = hexStrToBytes(sCmd);
      List<int> pack1 = pack('<II', [bits, txn_num]);
      List<int> sBlockInfo = List.from(block_hash)..addAll(pack1);
      List<int> pack2 = pack('<IB', [curr_tm, sBlockInfo.length]);
      List<int> sData = List.from(pack2)..addAll(sBlockInfo);
      List<int> pack3 = pack('<B', [sData.length]);
      sCmdBytes = List.from(sCmdBytes)..addAll(pack3)..addAll(sData);
      sCmd = bytesToHexStr(sCmdBytes);
      print('发送请求签名:$sCmd-${sCmd.length}');
      //蓝牙通讯---todo
      String res = await transmit(sCmd);
      print("返回蓝牙签名结果:$res-${res.length}");
      if (res.length > 128) {
        this.succ_blocks.add([curr_tm, hi]);
        if (this.succ_blocks.length > this.SUCC_BLOCKS_MAX) {
          //todo
          this
              .succ_blocks
              .removeRange(this.SUCC_BLOCKS_MAX, this.succ_blocks.length);
        }
        return res + sig_flag;
      }
      return "";
    } catch (e) {
      return "";
    }
  }

  //模拟蓝牙
  // Future<String> transmit(String cmd) async {
  //   sleep(Duration(seconds: 3));
  //   return 'abc123afabc123afabc123afabc123afabc123afabc123afabc123afabc123afabc123afabc123afabc123afabc123afabc123afabc123afabc123afabc123af00';
  // }
  // transmit() async{
  //   return "30303030";
  // }
}

class PoetResult {
  int link_no;
  int curr_id;
  List<int> miner;
  String sig_tee;
  PoetResult({
    this.link_no,
    this.curr_id,
    this.miner,
    this.sig_tee,
  });
}

List<int> pack(String str, List args) {
  if (str.length <= 1) {
    print('pack data invalid');
    return null;
  }
  if (str.length - 1 != args.length) {
    print('pack data invalid');
  }
  ByteDataWriter writer = ByteDataWriter();
  if (str[0] == '<') {
    for (int i = 0; i < args.length; i++) {
      var r = str[i + 1];
      if (r == 'I') {
        writer.writeUint32(args[i]);
      }
      if (r == 'B') {
        writer.writeUint8(args[i]);
      }
      if (r == 'H') {
        writer.writeUint16(args[i]);
      }
    }
  } else {
    //大端todo
  }
  return writer.toBytes();
}

int timest() {
  return int.parse(DateTime.now()
      .millisecondsSinceEpoch
      .toString()
      .substring(0, 10)); //单位毫秒，10位时间戳
}

final _magic = [0xf9, 0x6e, 0x62, 0x74];

List<int> getPoetTaskPayload(GetPoetTask poetTask) {
  if (poetTask == null) return null;
  ByteDataWriter writer = new ByteDataWriter();
  writer.writeUint32(poetTask.link_no);
  writer.writeUint32(poetTask.curr_id);
  writer.writeUint32(poetTask.timestamp);
  return writer.toBytes();
}

List<int> getPoetResultPayload(PoetResult poetResult) {
  if (poetResult == null) return null;
  ByteDataWriter writer = ByteDataWriter();
  writer.writeUint32(poetResult.link_no);
  writer.writeUint32(poetResult.curr_id);
  writer.write(poetResult.miner);
  String sig_tee = poetResult.sig_tee;
  List<int> b_sig_tee = hexStrToBytes(sig_tee);
  int len = b_sig_tee.length;
  writer.writeUint8(len);
  writer.write(b_sig_tee);
  return writer.toBytes();
}

PoetInfo getPoetInfoMsg(List<int> payload) {
  PoetInfo poetInfo = PoetInfo();
  ByteDataReader reader = ByteDataReader();
  reader.add(payload);
  poetInfo.link_no = reader.readUint32();
  poetInfo.curr_id = reader.readUint32();
  poetInfo.block_hash = reader.read(32);
  poetInfo.bits = reader.readUint32();
  poetInfo.height = reader.readUint32();
  poetInfo.prev_time = reader.readUint64();
  poetInfo.curr_time = reader.readUint64();
  poetInfo.txn_num = reader.readUint32();
  return poetInfo;
}

PoetReject getPoetRejectMsg(List<int> payload) {
  PoetReject poetReject = PoetReject();
  ByteDataReader reader = ByteDataReader();
  reader.add(payload);
  poetReject.sequence = reader.readUint32();
  poetReject.timestamp = reader.readUint32();
  int length = reader.readUint8();
  List<int> t = reader.read(length);
  String reason = Latin1Decoder().convert(t);
  poetReject.reason = reason;
  return poetReject;
}

List<int> wholePayload(List<int> payload, String command) {
  ByteDataWriter w = ByteDataWriter();
  //0-4 magic
  w.write(_magic);
  //4-16
  final _command = strToBytes(command, length: 12);
  w.write(_command);
  //16-20
  w.writeUint32(payload.length);
  //20-24
  final checksum =
      sha256.convert(sha256.convert(payload).bytes).bytes.sublist(0, 4);
  w.write(checksum);
  w.write(payload);
  return w.toBytes();
}

class GetPoetTask {
  final int link_no;
  final int curr_id;
  final int timestamp;

  GetPoetTask({this.link_no, this.curr_id, this.timestamp});
}

class PoetInfo {
  int link_no;
  int curr_id;
  List<int> block_hash;
  int bits;
  int height;
  int prev_time;
  int curr_time;
  int txn_num;
  PoetInfo(
      {this.link_no,
      this.curr_id,
      this.block_hash,
      this.bits,
      this.height,
      this.prev_time,
      this.curr_time,
      this.txn_num});
}

class PoetReject {
  int sequence;
  int timestamp;
  String reason;
  PoetReject({this.sequence, this.timestamp, this.reason});
}
