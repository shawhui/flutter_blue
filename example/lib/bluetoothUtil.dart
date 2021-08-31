// StatefulWidget
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

// ignore: must_be_immutable
class BluetoothShow extends StatefulWidget {
  BluetoothShow({Key key, @required this.dataList, this.callBack, this.type = DeviceInfoType.temperature}) : super(key: key);
  List dataList;
  DeviceInfoType type;
  Function callBack;

  @override
  BluetoothShowState createState() => BluetoothShowState();
}

class BluetoothShowState extends State<BluetoothShow> {
  List _listData;

  @override
  void initState() {
    _listData = widget.dataList;
    super.initState();
  }

  updateView(List list) {
    setState(() {
      _listData = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: _listData == null
          ? []
          : _listData.map(
            (r) {
          print(r);
          return GestureDetector(
            onTap: () async {
              {
                FlutterBlue.instance.isBluetoothStopScan();
                // SVProgressHUD.show("");
                int _index = _listData.indexOf(r);
                var a = await FlutterBlue.instance.bluetoothSession(
                  onDiscovered: (map) async {
                    print("map: $map");
                    // SVProgressHUD.dismiss();
                  },
                  index: _index,
                );
                if (a != null && a is int && a == 1) {
                  print("*** a: $a");

                  Navigator.of(context).pop();
                  if (widget.type == DeviceInfoType.temperature) {
                    // 测温
                    BluetoothUtil.temperature(widget.callBack);
                  } else if (widget.type == DeviceInfoType.speed) {
                    // 速度
                    BluetoothUtil.speed(widget.callBack);
                  } else if (widget.type == DeviceInfoType.acceleration) {
                    // 加速度
                    BluetoothUtil.acceleration(widget.callBack);
                  } else if (widget.type == DeviceInfoType.displacement) {
                    // 位移
                    BluetoothUtil.displacement(widget.callBack);
                  }
                } else {
                  // SVProgressHUD.dismiss();
                  // toastInfo(msg: "蓝牙连接失败, 请稍后重试");
                }
              }
            },
            child: Container(
              color: Colors.transparent,
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.symmetric(vertical: 5),
              // child: Text("** ${r['name']} **"),
              child: Text("${r['name'] ?? ""}"),
            ),
          );
        },
      ).toList(),
    );
  }
}

class BluetoothUtil {
  static show(BuildContext context, Function callBack, Key key, dataList, {DeviceInfoType type = DeviceInfoType.temperature}) {
    Scaffold.of(context).showBottomSheet(
          (c) {
        return Container(
          width: double.infinity,
          child: SingleChildScrollView(
              child: BluetoothShow(
                key: key,
                dataList: dataList,
                callBack: callBack,
                type: type,
              )),
          height: 400,
        );
      },
    );
  }

  static speed(Function callBack) {
    // 速度
    measureOther(DeviceInfoType.speed, "速度", callBack);
  }

  static acceleration(Function callBack) {
    // 加速度
    measureOther(DeviceInfoType.acceleration, "加速度", callBack);
  }

  static displacement(Function callBack) {
    // 位移
    measureOther(DeviceInfoType.displacement, "位移", callBack);
  }

  static measureOther(DeviceInfoType type, String typeName, Function callBack) {
    // SVProgressHUD.show("正在测量$typeName");
    // ignore: missing_return
    FlutterBlue.instance.bluetoothGetOther(type, onDiscovered: (Map map) {
      print("value: $map");
      // SVProgressHUD.dismiss();
      callBack(map);
    }, onError: (Map map) {
      print("error map: $map");
      Future.delayed(Duration(seconds: 15)).then((value) async {
        FlutterBlue.instance.bluetoothGetOther(type, onDiscovered: (Map value1) {
          print("value1: $value1");
          // SVProgressHUD.dismiss();
          callBack(value1);
          return null;
        }, onError: (Map map1) {
          print("error map1: $map1");
          // SVProgressHUD.dismiss();
          // toastInfo(msg: "$typeName测量${map1['error']},请稍后重试");
          return null;
        });
      });
      return null;
    });
  }

  static temperature(Function callBack) {
    // SVProgressHUD.show("正在测温");
    // ignore: missing_return
    FlutterBlue.instance.bluetoothGetTemperature(onDiscovered: (double value) {
      print("value: $value");
      // SVProgressHUD.dismiss();
      callBack(value);
    }, onError: (Map map) {
      print("error map: $map");
      Future.delayed(Duration(seconds: 15)).then((value) async {
        FlutterBlue.instance.bluetoothGetTemperature(onDiscovered: (double value1) {
          print("value1: $value1");
          // SVProgressHUD.dismiss();
          callBack(value1);
          return null;
        }, onError: (Map map1) {
          print("error map1: $map1");
          // SVProgressHUD.dismiss();
          // toastInfo(msg: "测温${map1['error']},请稍后重试");
          return null;
        });
      });
      return null;
    });
  }

  static GlobalKey<BluetoothShowState> _bluetoothShowStateGlobalKey = GlobalKey<BluetoothShowState>(debugLabel: "APPPageBluetoothShowStateGlobalKey");
  static List _dataList;

  static clickToTemperatureMeasurement(BuildContext context, Function callBack, DeviceInfoType type) async {
    print(context);
    FlutterBlue.instance.isBluetoothStopScan();
    // bool _isPermanentlyDenied = await Permission.location.isPermanentlyDenied;
    // bool _isUndetermined = await Permission.location.isUndetermined;
    // bool _isGranted = await Permission.location.isGranted;
    // bool _isDenied = await Permission.location.isDenied;
    // if (_isUndetermined) {
    //   Permission.location.request();
    //   return;
    // }
    // if (_isUndetermined) return;
    //
    // if (!_isGranted && !_isUndetermined) {
    //   toastInfo(msg: "请先获取位置权限");
    //   return;
    // }
    bool _state = await FlutterBlue.instance.state;
    if (_state) {
      if (await FlutterBlue.instance.isBluetoothConnected()) {
        if (DeviceInfoType.speed == type) {
          speed(callBack);
        } else if (DeviceInfoType.acceleration == type) {
          acceleration(callBack);
        } else if (DeviceInfoType.displacement == type) {
          displacement(callBack);
        } else if (DeviceInfoType.temperature == type) {
          temperature(callBack);
        }
      } else {
        show(context, (value) {
          callBack(value);
        }, _bluetoothShowStateGlobalKey, [], type: type);
        Future.delayed(Duration(milliseconds: 500)).then((value) {
          print("23456-----");
          FlutterBlue.instance.startScanBlutTooth(
              timeout: Duration(seconds: 1),
              scanResultsList: (List list) {
                if (list != null) _dataList = list;
                _bluetoothShowStateGlobalKey.currentState.updateView(_dataList);
              });
        });
      }
    } else {
      // showCustomToast(context, msg: "请先开启蓝牙");
    }
  }
}
