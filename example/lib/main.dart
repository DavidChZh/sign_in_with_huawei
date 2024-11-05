import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:sign_in_with_huawei/sign_in_with_huawei.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }


  Future<void> loginWithHuaweiId() async {
    final response = await SignInWithHuawei.instance.authById();
    setState(() {
      receivedData = response.toString();
    });
  }

  Future<void> setStyle() async {
    final response = await SignInWithHuawei.instance.getAnonymousPhone();
    setState(() {
      receivedData = response.toString();
    });
  }

  String receivedData = '';
  QuickLoginViewController? _controller;

  void _onCustomOhosViewCreated(QuickLoginViewController controller) {
    _controller = controller;
    _controller?.ohosDataStream.listen((data) {
      //接收到来自OHOS端的数据
      setState(() {
        receivedData = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: loginWithHuaweiId,
              child: const Text('Login With Huawei ID'),
            ),
            ElevatedButton(
              onPressed: setStyle,
              child: const Text('获取匿名手机号'),
            ),
            Container(
              height: 100,
              child: QuickLoginOhosView(_onCustomOhosViewCreated,loading: false,),
            ),
            Text(receivedData),
          ],
        ),
      ),
    );
  }
}
