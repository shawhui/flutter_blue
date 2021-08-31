import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(FlutterBlueApp());
}

class FlutterBlueApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // bool _canShow = await FlutterBlue.instance.state;
    return MaterialApp(color: Colors.lightBlue, home: FindDevicesScreen()
        // : StreamBuilder<BluetoothState>(
        //     stream: FlutterBlue.instance.state,
        //     initialData: BluetoothState.unknown,
        //     builder: (c, snapshot) {
        //       final state = snapshot.data;
        //       if (state == BluetoothState.on) {
        //         return FindDevicesScreen();
        //       }
        //       return BluetoothOffScreen(state: state);
        //     }),
        );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key key, this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: Theme.of(context).primaryTextTheme.subhead?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatefulWidget {
  @override
  _FindDevicesScreenState createState() => _FindDevicesScreenState();
}

class _FindDevicesScreenState extends State<FindDevicesScreen> {
  List _dataList = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 500)).then((value) {
      print("23456-----");
      FlutterBlue.instance.startScanBlutTooth(
          timeout: Duration(seconds: 1),
          scanResultsList: (List list) {
            setState(() {
              if (list != null) _dataList = list;
            });
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Devices'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                new FlatButton(
                  child: new Text('温度'),
                  onPressed: () {
                    FlutterBlue.instance.bluetoothGetTemperature(
                      onDiscovered: (value) async {
                        print("温度: $value");
                        // setStates(() {
                        //   _str = value.toString();
                        // });
                      },
                      onError: (map) async {
                        print("温度 error: $map");
                      },
                    );
                  },
                ),
                new FlatButton(
                  child: new Text('加速度'),
                  onPressed: () {
                    FlutterBlue.instance.bluetoothGetOther(
                      DeviceInfoType.displacement,
                      onDiscovered: (map) async {
                        print("map: $map");
                      },
                      onError: (map) async {
                        print("加速度 error: $map");
                      },
                    );
                  },
                ),
                new FlatButton(
                  child: new Text('速度'),
                  onPressed: () {
                    FlutterBlue.instance.bluetoothGetOther(
                      DeviceInfoType.speed,
                      onDiscovered: (map) async {
                        print("map: $map");
                      },
                      onError: (map) async {
                        print("速度 error: $map");
                      },
                    );
                  },
                ),
                new FlatButton(
                  child: new Text('位移'),
                  onPressed: () {
                    FlutterBlue.instance.bluetoothGetOther(
                      DeviceInfoType.displacement,
                      onDiscovered: (map) async {
                        print("map: $map");
                        print("map: ${(map['waves'] as List).length}");
                      },
                      onError: (map) async {
                        print("位移 error: $map");
                      },
                    );
                  },
                ),
              ],
            ),
            Row(
              children: <Widget>[
                new FlatButton(
                  child: new Text('是否链接'),
                  onPressed: () {
                    FlutterBlue.instance.isBluetoothConnected().then((value) {
                      print("**** ");
                      print(value);
                      print("**** ");
                    });
                  },
                ),
                new FlatButton(
                  child: new Text('链接设备'),
                  onPressed: () {
                    FlutterBlue.instance.bluetoothConnectedDevice().then((value) {
                      print("**** ");
                      print(value);
                      print("**** ");
                    });
                  },
                ),
                new FlatButton(
                  child: new Text('startScan'),
                  onPressed: () {
                    FlutterBlue.instance.isBluetoothStartScan();
                  },
                ),
                new FlatButton(
                  child: new Text('stopScan'),
                  onPressed: () {
                    FlutterBlue.instance.isBluetoothStopScan();
                  },
                ),
              ],
            ),
            Row(
              children: <Widget>[
                new FlatButton(
                  child: new Text('BtEnabled'),
                  onPressed: () {
                    FlutterBlue.instance.isBluetoothBtEnabled().then((value) {
                      print("**** ");
                      print(value);
                      print("**** ");
                    });
                  },
                ),
                new FlatButton(
                  child: new Text('PowerOff'),
                  onPressed: () {
                    FlutterBlue.instance.bluetoothPowerOff();
                  },
                ),
              ],
            ),
            if (_dataList != null)
              Column(
                children: _dataList.map(
                  (r) {
                    print(r);
                    return GestureDetector(
                      onTap: () async {
                        print("r: $r");
                        print("print start");
                        int _index = _dataList.indexOf(r);

                        print("_index: $_index");
                        var a = await FlutterBlue.instance.bluetoothSession(
                          onDiscovered: (map) async {
                            print("map: $map");
                          },
                          index: _index,
                        );
                        if (a != null && a is int && a == 1) {
                          print("*** a: $a");
                        }
                      },
                      child: Container(
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text("** ${r['name']} **"),
                      ),
                    );
                  },
                ).toList(),
              ),
            true
                ? Container()
                : StreamBuilder<List>(
                    stream: FlutterBlue.instance.scanResults,
                    initialData: [],
                    builder: (c, snapshot) => Column(
                      children: snapshot.data.map(
                        (r) {
                          print(r);
                          return GestureDetector(
                            onTap: () async {
                              print("r: $r");
                              print("print start");
                              int _index = snapshot.data.indexOf(r);

                              print("_index: $_index");
                              var a = await FlutterBlue.instance.bluetoothSession(
                                onDiscovered: (map) async {
                                  print("map: $map");
                                },
                                index: _index,
                              );
                              if (a != null && a is int && a == 1) {
                                print("*** a: $a");

                                // show(context);
                                //
                                // showDialog<Null>(
                                //   context: context,
                                //   barrierDismissible: false,
                                //   builder: (BuildContext context) {
                                //     return new AlertDialog(
                                //       title: new Text('标题'),
                                //       content: new SingleChildScrollView(
                                //         child: new ListBody(
                                //           children: <Widget>[
                                //             new Text('内容 1'),
                                //             new Text('内容 2'),
                                //           ],
                                //         ),
                                //       ),
                                //       actions: <Widget>[
                                //         new FlatButton(
                                //           child: new Text('确定'),
                                //           onPressed: () {
                                //             Navigator.of(context).pop();
                                //           },
                                //         ),
                                //       ],
                                //     );
                                //   },
                                // ).then((val) {
                                //   print(val);
                                // });
                              }
                            },
                            child: Container(
                              color: Colors.transparent,
                              alignment: Alignment.center,
                              margin: EdgeInsets.symmetric(vertical: 10),
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text("-- ${r['name']} --"),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data ?? false) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () async {
                  var value = await FlutterBlue.instance.startScanBlutTooth(timeout: Duration(seconds: 1));
                  // print("value:$value");
                });
          }
        },
      ),
    );
  }
}
