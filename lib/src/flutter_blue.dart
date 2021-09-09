// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of flutter_blue;

typedef BluetoothCallback = Future<void> Function(Map map);
typedef BluetoothCallbackDouble = Future<void> Function(double value);
typedef BluetoothErrorCallback = Future<void> Function(Map map);

class FlutterBlue {
  final MethodChannel _channel = const MethodChannel('$NAMESPACE/methods');

  final MethodChannel _channel2 = const MethodChannel('$NAMESPACE/methods2');
  final EventChannel _stateChannel = const EventChannel('$NAMESPACE/state');
  final StreamController<MethodCall> _methodStreamController = new StreamController.broadcast(); // ignore: close_sinks
  Stream<MethodCall> get _methodStream => _methodStreamController.stream; // Used internally to dispatch methods from platform.
  Stream<MethodCall> get _methodStream1 => _methodStreamController.stream; // Used internally to dispatch methods from platform.

  /// Singleton boilerplate
  FlutterBlue._() {
    _channel.setMethodCallHandler((MethodCall call) async => _methodStreamController.add(call));
    _channel2.setMethodCallHandler(_handleMethodCall);
    _setLogLevelIfAvailable();
  }

  static FlutterBlue _instance = new FlutterBlue._();

  static FlutterBlue get instance => _instance;

  /// Log level of the instance, default is all messages (debug).
  LogLevel _logLevel = LogLevel.debug;

  LogLevel get logLevel => _logLevel;

  /// Checks whether the device supports Bluetooth
  Future<bool> get isAvailable => _channel.invokeMethod('isAvailable').then<bool>((d) => d);

  BehaviorSubject<bool> _isScanning = BehaviorSubject.seeded(false);

  Stream<bool> get isScanning => _isScanning.stream;

  BehaviorSubject<List> _scanResults = BehaviorSubject.seeded([]);

  /// Returns a stream that is a list of [ScanResult] results while a scan is in progress.
  ///
  /// The list emitted is all the scanned results as of the last initiated scan. When a scan is
  /// first started, an empty list is emitted. The returned stream is never closed.
  ///
  /// One use for [scanResults] is as the stream in a StreamBuilder to display the
  /// results of a scan in real time while the scan is in progress.
  Stream<List> get scanResults => _scanResults.stream;
  Function _scanResultsList;
  BluetoothCallback _onDiscovered;
  BluetoothCallback _onCallBackMap;
  BluetoothCallbackDouble _onCallBackTemperature;
  BluetoothErrorCallback _onError;

  Future<int> bluetoothSession({
    BluetoothCallback onDiscovered,
    // Set<NfcPollingOption> pollingOptions,
    int index,
    String alertMessage = "msg",
    BluetoothErrorCallback onError,
  }) async {
    _onDiscovered = onDiscovered;
    _onError = onError;
    return _channel2.invokeMethod('StartBluetoothContent', {"index": index ?? -1, 'pollingOptions': "aaa", 'alertMessage': alertMessage});
  }

  Future<double> bluetoothGetTemperature({BluetoothCallbackDouble onDiscovered, BluetoothErrorCallback onError}) async {
    _onCallBackTemperature = onDiscovered;
    _onError = onError;

    return _channel2.invokeMethod('BluetoothGetDeviceInfo', {"index": 1});
  }

  Future bluetoothGetOther(DeviceInfoType type, {BluetoothCallback onDiscovered, BluetoothErrorCallback onError}) async {
    // if (type == DeviceInfoType.temperature) {
    //   return bluetoothGetTemperature(onDiscovered: onDiscovered);
    // }
    _onError = onError;

    int index = 1;
    if (type == DeviceInfoType.acceleration) {
      index = 2;
    }
    if (type == DeviceInfoType.speed) {
      index = 3;
    }
    if (type == DeviceInfoType.displacement) {
      index = 4;
    }
    _onCallBackMap = onDiscovered;

    return _channel2.invokeMethod('BluetoothGetDeviceInfo', {"index": index});
  }

  Future isBluetoothConnected() async {
    return _channel2.invokeMethod('isBluetoothConnected');
  }

  Future bluetoothConnectedDevice() async {
    return _channel2.invokeMethod('isBluetoothConnectedDevice');
  }

  Future isBluetoothStopScan() async {
    // 停止扫描
    return _channel2.invokeMethod('isBluetoothStopScan');
  }

  Future isBluetoothStartScan() async {
    // 开始扫描
    return _channel2.invokeMethod('isBluetoothStartScan');
  }

  Future changeBluetoothSampValues(SAMPFREQValue sampFreq, SAMPLENGTHValue sampLength) async {
    // sampFreq: 125, 250, 500, 1250, 2500, 4000, 5000, 10000, 20000, 25000,50000
    // sampLength: 1024,2048,4096,8192,16384,32768,32768

    return _channel2.invokeMethod('changeSampValues', {
      "sampFreq": _getSampFreqValues(sampFreq),
      "sampLength": _getSampLengthValues(sampLength),
    });
  }

  int _getSampFreqValues(SAMPFREQValue sampFreq) {
    // sampFreq: 125, 250, 500, 1250, 2500, 4000, 5000, 10000, 20000, 25000,50000
    switch (sampFreq) {
      case SAMPFREQValue.s_125:
        return 125;
      case SAMPFREQValue.s_250:
        return 250;

      case SAMPFREQValue.s_500:
        return 500;
      case SAMPFREQValue.s_1250:
        return 1250;

      case SAMPFREQValue.s_2500:
        return 2500;
      case SAMPFREQValue.s_4000:
        return 4000;

      case SAMPFREQValue.s_5000:
        return 5000;
      case SAMPFREQValue.s_10000:
        return 10000;
      case SAMPFREQValue.s_20000:
        return 20000;

      case SAMPFREQValue.s_25000:
        return 25000;
      case SAMPFREQValue.s_50000:
        return 50000;
    }

    return 0;
  }

  int _getSampLengthValues(SAMPLENGTHValue sampLength) {
    // sampLength: 1024,2048,4096,8192,16384,32768,32768
    switch (sampLength) {
      case SAMPLENGTHValue.l_1024:
        return 1024;
      case SAMPLENGTHValue.l_2048:
        return 2048;
      case SAMPLENGTHValue.l_4096:
        return 4096;
      case SAMPLENGTHValue.l_8192:
        return 8192;
      case SAMPLENGTHValue.l_16384:
        return 16384;
      case SAMPLENGTHValue.l_32768:
        return 32768;
    }
    return 0;
  }

  Future bluetoothPowerOff() async {
    return _channel2.invokeMethod('bluetoothPowerOff');
  }

  Future bluetoothHoldOn() async {
    return _channel2.invokeMethod('bluetoothHoldOn');
  }

  Future isBluetoothPowerOn() async {
    return _channel2.invokeMethod('isBluetoothPowerOn');
  }

  Future isBluetoothBtEnabled() async {
    return _channel2.invokeMethod('isBluetoothBtEnabled');
  }

// _handleMethodCall
  Future<void> _handleMethodCall(MethodCall call) async {
    print("*** 10010");
    switch (call.method) {
      case 'onDiscovered':
        _handleOnDiscovered(call);
        break;
      case 'callBackTemperature':
        _handleOnCallBackTemperature(call);
        break;
      case 'callBackOther':
        _handleOnCallBackOther(call);
        break;
      case 'bluetoothOnError':
        _handleOnError(call);
        break;
      case 'ScanResult1':
        _showResult(call);
        break;
      default:
        throw ('Not implemented: ${call.method}');
    }
  }

  _showResult(MethodCall call) async {
    print("23456");
    _scanResultsList(call.arguments);
  }

  _handleOnError(MethodCall call) async {
    if (_onError != null) {
      await _onError(Map.from(call.arguments));
    }
  }

// _handleOnDiscovered
  void _handleOnDiscovered(MethodCall call) async {
    print("*******1");
    // final tag = $GetNfcTag(Map.from(call.arguments));
    if (_onDiscovered != null) {
      print("call *** : $call");
      await _onDiscovered(Map.from(call.arguments));
    }
    // await _disposeTag(tag.handle);
  }

  void _handleOnCallBackOther(MethodCall call) async {
    if (_onCallBackMap != null) {
      await _onCallBackMap(Map.from(call.arguments));
    }
  }

  void _handleOnCallBackTemperature(MethodCall call) async {
    String _value = call.arguments.toString();
    double _doubleValue = -1.0;
    try {
      _doubleValue = double.parse(_value);
    } catch (e) {}
    if (_onCallBackTemperature != null) {
      if (_onCallBackTemperature is BluetoothCallbackDouble) {
        await _onCallBackTemperature(_doubleValue);
      }
    }
    if (_onCallBackMap != null) {
      await _onCallBackMap({"value": _doubleValue});
    }
  }

  PublishSubject _stopScanPill = new PublishSubject();

  /// Gets the current state of the Bluetooth module
  Future<bool> get state async {
    return await _channel
        .invokeMethod('state'); //.then((buffer) => new protos.BluetoothState.fromBuffer(buffer)).then((s) => BluetoothState.values[s.state.value]);
    // yield await _channel.invokeMethod('state').then((buffer) => new protos.BluetoothState.fromBuffer(buffer)).then((s) => BluetoothState.values[s.state.value]);
    //
    // yield* _stateChannel
    //     .receiveBroadcastStream()
    //     .map((buffer) => new protos.BluetoothState.fromBuffer(buffer))
    //     .map((s) => BluetoothState.values[s.state.value]);
  }

  /// Retrieve a list of connected devices
  Future<List<BluetoothDevice>> get connectedDevices {
    return _channel
        .invokeMethod('getConnectedDevices')
        .then((buffer) => protos.ConnectedDevicesResponse.fromBuffer(buffer))
        .then((p) => p.devices)
        .then((p) => p.map((d) => BluetoothDevice.fromProto(d)).toList());
  }

  _setLogLevelIfAvailable() async {
    if (await isAvailable) {
      // Send the log level to the underlying platforms.
      setLogLevel(logLevel);
    }
  }

  /// Starts a scan for Bluetooth Low Energy devices and returns a stream
  /// of the [ScanResult] results as they are received.
  ///
  /// timeout calls stopStream after a specified [Duration].
  /// You can also get a list of ongoing results in the [scanResults] stream.
  /// If scanning is already in progress, this will throw an [Exception].
  Stream scan({
    ScanMode scanMode = ScanMode.lowLatency,
    List<Guid> withServices = const [],
    List<Guid> withDevices = const [],
    Duration timeout,
    bool allowDuplicates = false,
    bool isAndroid = true,
  }) async* {
    if (isAndroid) {
      await _channel.invokeMethod('startScan');
    } else {
      print("****123456");
      var settings = protos.ScanSettings.create()
        ..androidScanMode = scanMode.value
        ..allowDuplicates = allowDuplicates
        ..serviceUuids.addAll(withServices.map((g) => g.toString()).toList());

      // if (_isScanning.value == true) {
      //   throw Exception('Another scan is already in progress.');
      // }

      // Emit to isScanning
      _isScanning.add(true);

      final killStreams = <Stream>[];
      killStreams.add(_stopScanPill);
      if (timeout != null) {
        killStreams.add(Rx.timer(null, timeout));
      }

      // Clear scan results list
      _scanResults.add([]);

      try {
        await _channel.invokeMethod('startScan', settings.writeToBuffer());
      } catch (e) {
        print('Error starting scan.');
        _stopScanPill.add(null);
        _isScanning.add(false);
        throw e;
      }

      yield* FlutterBlue.instance._methodStream
          .where((m) => m.method == "ScanResult")
          .map((m) => m.arguments)
          .takeUntil(Rx.merge(killStreams))
          .doOnDone(stopScan)
          .map((buffer) => new protos.ScanResult.fromBuffer(buffer))
          .map((p) {
        final result = new ScanResult.fromProto(p);
        final list = _scanResults.value ?? [];
        // if (result.device.name != "") {
        int index = list.indexOf(result);
        if (index != -1) {
          list[index] = result;
        } else {
          list.add(result);
        }
        _scanResults.add(list);
        // }
        return result;
      });
      yield* FlutterBlue.instance._methodStream1.where((m) => m.method == "ScanResult1").map((m) => m.arguments).map((p) {
        print("****1111");
        final list = _scanResults.value ?? [];

        int index = list.indexOf(p);
        if (index != -1) {
          list[index] = p;
        } else {
          _scanResults.add(p);
        }
        // _scanResults.add(p);
        print("map: $p");

        return p;
      });
    }
  }

  /// Starts a scan and returns a future that will complete once the scan has finished.
  ///
  /// Once a scan is started, call [stopScan] to stop the scan and complete the returned future.
  ///
  /// timeout automatically stops the scan after a specified [Duration].
  ///
  /// To observe the results while the scan is in progress, listen to the [scanResults] stream,
  /// or call [scan] instead.
  Future startScanBlutTooth({
    ScanMode scanMode = ScanMode.lowLatency,
    List<Guid> withServices = const [],
    List<Guid> withDevices = const [],
    Duration timeout,
    Function scanResultsList,
    bool allowDuplicates = false,
    bool isAndroid = true,
  }) async {
    _scanResultsList = scanResultsList;
    await scan(
            scanMode: scanMode, withServices: withServices, withDevices: withDevices, timeout: timeout, isAndroid: isAndroid, allowDuplicates: allowDuplicates)
        .drain();

    return _scanResults.value;
  }

  Future startScan1({
    ScanMode scanMode = ScanMode.lowLatency,
    List<Guid> withServices = const [],
    List<Guid> withDevices = const [],
    Duration timeout,
    bool allowDuplicates = false,
  }) async {
    await scan(scanMode: scanMode, withServices: withServices, withDevices: withDevices, timeout: timeout, allowDuplicates: allowDuplicates).drain();
    return _scanResults.value;
  }

  /// Stops a scan for Bluetooth Low Energy devices
  Future stopScan() async {
    await _channel.invokeMethod('stopScan');
    _stopScanPill.add(null);
    _isScanning.add(false);
  }

  /// The list of connected peripherals can include those that are connected
  /// by other apps and that will need to be connected locally using the
  /// device.connect() method before they can be used.
//  Stream<List<BluetoothDevice>> connectedDevices({
//    List<Guid> withServices = const [],
//  }) =>
//      throw UnimplementedError();

  /// Sets the log level of the FlutterBlue instance
  /// Messages equal or below the log level specified are stored/forwarded,
  /// messages above are dropped.
  void setLogLevel(LogLevel level) async {
    await _channel.invokeMethod('setLogLevel', level.index);
    _logLevel = level;
  }

  void _log(LogLevel level, String message) {
    if (level.index <= _logLevel.index) {
      print(message);
    }
  }
}

/// Log levels for FlutterBlue
enum LogLevel {
  emergency,
  alert,
  critical,
  error,
  warning,
  notice,
  info,
  debug,
}

/// Log levels for FlutterBlue
enum DeviceInfoType {
  temperature,
  speed,
  acceleration,
  displacement,
}

/// State of the bluetooth adapter.
enum BluetoothState { unknown, unavailable, unauthorized, turningOn, on, turningOff, off }

class ScanMode {
  const ScanMode(this.value);

  static const lowPower = const ScanMode(0);
  static const balanced = const ScanMode(1);
  static const lowLatency = const ScanMode(2);
  static const opportunistic = const ScanMode(-1);
  final int value;
}

class DeviceIdentifier {
  final String id;

  const DeviceIdentifier(this.id);

  @override
  String toString() => id;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(other) => other is DeviceIdentifier && compareAsciiLowerCase(id, other.id) == 0;
}

class ScanResult {
  ScanResult.fromProto(protos.ScanResult p)
      : device = new BluetoothDevice.fromProto(p.device),
        advertisementData = new AdvertisementData.fromProto(p.advertisementData),
        rssi = p.rssi;

  final BluetoothDevice device;
  final AdvertisementData advertisementData;
  final int rssi;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ScanResult && runtimeType == other.runtimeType && device == other.device;

  @override
  int get hashCode => device.hashCode;

  @override
  String toString() {
    return 'ScanResult{device: $device, advertisementData: $advertisementData, rssi: $rssi}';
  }
}

class AdvertisementData {
  final String localName;
  final int txPowerLevel;
  final bool connectable;
  final Map<int, List<int>> manufacturerData;
  final Map<String, List<int>> serviceData;
  final List<String> serviceUuids;

  AdvertisementData.fromProto(protos.AdvertisementData p)
      : localName = p.localName,
        txPowerLevel = (p.txPowerLevel.hasValue()) ? p.txPowerLevel.value : null,
        connectable = p.connectable,
        manufacturerData = p.manufacturerData,
        serviceData = p.serviceData,
        serviceUuids = p.serviceUuids;

  @override
  String toString() {
    return 'AdvertisementData{localName: $localName, txPowerLevel: $txPowerLevel, connectable: $connectable, manufacturerData: $manufacturerData, serviceData: $serviceData, serviceUuids: $serviceUuids}';
  }
}
// sampFreq: 125, 250, 500, 1250, 2500, 4000, 5000, 10000, 20000, 25000,50000
// sampLength: 1024,2048,4096,8192,16384,32768,32768

enum SAMPFREQValue { s_125, s_250, s_500, s_1250, s_2500, s_4000, s_5000, s_10000, s_20000, s_25000, s_50000 }

enum SAMPLENGTHValue { l_1024, l_2048, l_4096, l_8192, l_16384, l_32768 }
