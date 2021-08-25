// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_example/widgets.dart';

void main() {
  runApp(FlutterBlueApp());
}

class FlutterBlueApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return FindDevicesScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
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

class FindDevicesScreen extends StatelessWidget {
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
                    FlutterBlue.instance.bluetoothConnectedDevice().then((value){
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
            // StreamBuilder<List<BluetoothDevice>>(
            //   stream: Stream.periodic(Duration(seconds: 2)).asyncMap((_) => FlutterBlue.instance.connectedDevices),
            //   initialData: [],
            //   builder: (c, snapshot) {
            //     print("snapshot:${snapshot.data}");
            //     return Column(
            //       children: snapshot.data!
            //           .map((d) => ListTile(
            //                 title: Text(d.name),
            //                 subtitle: Text(d.id.toString()),
            //                 trailing: StreamBuilder<BluetoothDeviceState>(
            //                   stream: d.state,
            //                   initialData: BluetoothDeviceState.disconnected,
            //                   builder: (c, snapshot) {
            //                     if (snapshot.data == BluetoothDeviceState.connected) {
            //                       return RaisedButton(
            //                         child: Text('OPEN'),
            //                         onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => DeviceScreen(device: d))),
            //                       );
            //                     }
            //                     return Text(snapshot.data.toString());
            //                   },
            //                 ),
            //               ))
            //           .toList(),
            //     );
            //   },
            // ),
            StreamBuilder<List>(
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
                        child: Text("${r['name']}"),
                      ),
                    );
                    // return ScanResultTile(
                    //   result: r,
                    //   onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    //     r.device.connect();
                    //     return DeviceScreen(device: r.device);
                    //   })),
                    // );
                  },
                ).toList(),
              ),
              // {
              // List _list = snapshot.data!;
              // List<Widget> columnChildren = [];
              // for (int i = 0; i < _list.length; i++) {
              //   Map _map = _list[i];
              //   columnChildren.add(GestureDetector(
              //     onTap: () {
              //       print("r: $_map, index: $i");
              //     },
              //     child: Container(
              //       child: Text("${_map['name']}"),
              //     ),
              //   ));
              // }
              // true
              //                       ? columnChildren
              //                       :

              //   return Column(
              //     children:  snapshot.data!.map(
              //             (r) {
              //               print(r);
              //               return GestureDetector(
              //                 onTap: () {
              //                   print("r");
              //                 },
              //                 child: Container(
              //                   child: Text("${r['name']}"),
              //                 ),
              //               );
              //               return ScanResultTile(
              //                 result: r,
              //                 onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              //                   r.device.connect();
              //                   return DeviceScreen(device: r.device);
              //                 })),
              //               );
              //             },
              //           ).toList(),
              //   );
              // },
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
                  var value = await FlutterBlue.instance.startScan(timeout: Duration(seconds: 1));

                  print("value:$value");
                });
          }
        },
      ),
    );
  }
}

// class DeviceScreen extends StatelessWidget {
//   const DeviceScreen({Key key, @required this.device}) : super(key: key);
//
//   final BluetoothDevice device;
//
//   List<int> _getRandomBytes() {
//     final math = Random();
//     return [math.nextInt(255), math.nextInt(255), math.nextInt(255), math.nextInt(255)];
//   }
//
//   List<Widget> _buildServiceTiles(List<BluetoothService> services) {
//     return services
//         .map(
//           (s) => ServiceTile(
//             service: s,
//             characteristicTiles: s.characteristics
//                 .map(
//                   (c) => CharacteristicTile(
//                     characteristic: c,
//                     onReadPressed: () => c.read(),
//                     onWritePressed: () async {
//                       await c.write(_getRandomBytes(), withoutResponse: true);
//                       await c.read();
//                     },
//                     onNotificationPressed: () async {
//                       await c.setNotifyValue(!c.isNotifying);
//                       await c.read();
//                     },
//                     descriptorTiles: c.descriptors
//                         .map(
//                           (d) => DescriptorTile(
//                             descriptor: d,
//                             onReadPressed: () => d.read(),
//                             onWritePressed: () => d.write(_getRandomBytes()),
//                           ),
//                         )
//                         .toList(),
//                   ),
//                 )
//                 .toList(),
//           ),
//         )
//         .toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(device.name),
//         actions: <Widget>[
//           StreamBuilder<BluetoothDeviceState>(
//             stream: device.state,
//             initialData: BluetoothDeviceState.connecting,
//             builder: (c, snapshot) {
//               VoidCallback onPressed;
//               String text;
//               switch (snapshot.data) {
//                 case BluetoothDeviceState.connected:
//                   onPressed = () => device.disconnect();
//                   text = 'DISCONNECT';
//                   break;
//                 case BluetoothDeviceState.disconnected:
//                   onPressed = () => device.connect();
//                   text = 'CONNECT';
//                   break;
//                 default:
//                   onPressed = null;
//                   text = snapshot.data.toString().substring(21).toUpperCase();
//                   break;
//               }
//               return FlatButton(
//                   onPressed: onPressed,
//                   child: Text(
//                     text,
//                     style: Theme.of(context).primaryTextTheme.button?.copyWith(color: Colors.white),
//                   ));
//             },
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: <Widget>[
//             StreamBuilder<BluetoothDeviceState>(
//               stream: device.state,
//               initialData: BluetoothDeviceState.connecting,
//               builder: (c, snapshot) => ListTile(
//                 leading: (snapshot.data == BluetoothDeviceState.connected) ? Icon(Icons.bluetooth_connected) : Icon(Icons.bluetooth_disabled),
//                 title: Text('Device is ${snapshot.data.toString().split('.')[1]}.'),
//                 subtitle: Text('${device.id}'),
//                 trailing: StreamBuilder<bool>(
//                   stream: device.isDiscoveringServices,
//                   initialData: false,
//                   builder: (c, snapshot) => IndexedStack(
//                     index: (snapshot.data ?? false) ? 1 : 0,
//                     children: <Widget>[
//                       IconButton(
//                         icon: Icon(Icons.refresh),
//                         onPressed: () => device.discoverServices(),
//                       ),
//                       IconButton(
//                         icon: SizedBox(
//                           child: CircularProgressIndicator(
//                             valueColor: AlwaysStoppedAnimation(Colors.grey),
//                           ),
//                           width: 18.0,
//                           height: 18.0,
//                         ),
//                         onPressed: null,
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             StreamBuilder<int>(
//               stream: device.mtu,
//               initialData: 0,
//               builder: (c, snapshot) => ListTile(
//                 title: Text('MTU Size'),
//                 subtitle: Text('${snapshot.data} bytes'),
//                 trailing: IconButton(
//                   icon: Icon(Icons.edit),
//                   onPressed: () => device.requestMtu(223),
//                 ),
//               ),
//             ),
//             StreamBuilder<List<BluetoothService>>(
//               stream: device.services,
//               initialData: [],
//               builder: (c, snapshot) {
//                 return Column(
//                   children: _buildServiceTiles(snapshot.data),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// show(context) {
//   String _str = "内容 1";
//   showDialog<Null>(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext context) {
//       return new AlertDialog(
//         title: new Text('测试'),
//         content: new SingleChildScrollView(
//           child: new ListBody(
//             children: <Widget>[
//               new Text('$_str'),
//               new Text('内容 2'),
//             ],
//           ),
//         ),
//         actions: <Widget>[
//           new FlatButton(
//             child: new Text('温度'),
//             onPressed: () {
//               FlutterBlue.instance.bluetoothGetTemperature(
//                 onDiscovered: (value) async {
//                   print("温度: $value");
//                   // setStates(() {
//                   //   _str = value.toString();
//                   // });
//                 },
//                 onError: (map) async {
//                   print("温度 error: $map");
//                 },
//               );
//             },
//           ),
//           new FlatButton(
//             child: new Text('加速度'),
//             onPressed: () {
//               FlutterBlue.instance.bluetoothGetOther(
//                 DeviceInfoType.displacement,
//                 onDiscovered: (map) async {
//                   print("map: $map");
//                 },
//                 onError: (map) async {
//                   print("加速度 error: $map");
//                 },
//               );
//             },
//           ),
//           new FlatButton(
//             child: new Text('速度'),
//             onPressed: () {
//               FlutterBlue.instance.bluetoothGetOther(
//                 DeviceInfoType.speed,
//                 onDiscovered: (map) async {
//                   print("map: $map");
//                 },
//                 onError: (map) async {
//                   print("速度 error: $map");
//                 },
//               );
//             },
//           ),
//           new FlatButton(
//             child: new Text('位移'),
//             onPressed: () {
//               FlutterBlue.instance.bluetoothGetOther(
//                 DeviceInfoType.displacement,
//                 onDiscovered: (map) async {
//                   print("map: $map");
//                   print("map: ${(map['waves'] as List).length}");
//                 },
//                 onError: (map) async {
//                   print("位移 error: $map");
//                 },
//               );
//             },
//           ),
//           new FlatButton(
//             child: new Text('测试'),
//             onPressed: () {
//               FlutterBlue.instance.bluetoothGetOther(
//                 DeviceInfoType.displacement,
//                 onDiscovered: (map) async {
//                   print("map: $map");
//                 },
//                 onError: (map) async {
//                   print("位移 error: $map");
//                 },
//               );
//             },
//           ),
//         ],
//       );
//     },
//   ).then((val) {
//     print(val);
//   });
// }
