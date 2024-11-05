import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../sign_in_with_huawei.dart';

typedef OnViewCreated = Function(QuickLoginViewController);

class QuickLoginOhosView extends StatefulWidget {
  final OnViewCreated onViewCreated;
  final bool loading;
  const QuickLoginOhosView(this.onViewCreated, {Key? key,this.loading=true}) : super(key: key);

  @override
  State<QuickLoginOhosView> createState() => _QuickLoginOhosViewState();
}

class _QuickLoginOhosViewState extends State<QuickLoginOhosView> {
  late MethodChannel _channel;

  @override
  Widget build(BuildContext context) {
    return _getPlatformFaceView();
  }

  Widget _getPlatformFaceView() {
    return OhosView(
      viewType: 'com.fluttercandies/QuickLoginView',
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParams:  <String, dynamic>{'loading': widget.loading},
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('$kMessageChannel$id');
    final controller = QuickLoginViewController._(
      _channel,
    );
    widget.onViewCreated(controller);
  }
}

class QuickLoginViewController {
  final MethodChannel _channel;
  final StreamController<String> _controller = StreamController<String>();

  QuickLoginViewController._(
      this._channel,
      ) {
    _channel.setMethodCallHandler(
          (call) async {
        switch (call.method) {
          case 'getMessageFromOhosView':
          // 从native端获取数据
            final result = call.arguments as String;
            _controller.sink.add(result);
            break;
        }
      },
    );
  }

  Stream<String> get ohosDataStream => _controller.stream;
  // 发送数据给native
  Future<void> sendMessageToOhosView({bool loading=true}) async {
    await _channel.invokeMethod(
      'getMessageFromFlutterView',
      {
        "loading":loading
      },
    );
  }
}
