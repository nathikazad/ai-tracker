import 'dart:async';

import 'package:Logger/events.dart';
import 'package:Logger/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Observe and Log Events'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  static const platform = MethodChannel('com.improve/intents');
  ValueNotifier<bool> fetchEventsNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(_handleMethod);
    scheduleHourlyNotification();
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'logBreak':
        return "Received in Flutter: Break logged";
      case 'sendMessageToAi':
        convertMessageToEvent(call.arguments);
        break;
      default:
        throw MissingPluginException('notImplemented');
    }
  }

  Future<void> _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() async {
            if (val.finalResult) {
              _isListening = false;
              await convertMessageToEvent(_text);
              fetchEventsNotifier.value = true;
              setState(() => _text = 'Press the button and start speaking');
              // print(_text);
            } else {
              _text = val.recognizedWords;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Observe and Improve'),
    );
  }

  Widget _buildText() {
    return Text(
      _text,
      style: const TextStyle(
        fontSize: 24.0,
        color: Colors.black,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _startListening,
      child: Icon(_isListening ? Icons.stop : Icons.mic),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: _buildText(),
          ),
          _buildFloatingActionButton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [EventPage(fetchEventsNotifier)],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }
}
