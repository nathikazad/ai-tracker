import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// import 'package:flutter_sound/flutter_sound.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  static const platform = MethodChannel('com.improve/intents');

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    print("received on dart side ${call.method} ${call.arguments}");
    switch (call.method) {
      case 'logBreak':
        // Handle the 'logBreak' method
        print("Break logged from iOS");
        // Perform any action here. For example, updating the UI
        return "Received in Flutter: Break logged";
      case 'sendMessageToAi':
        convertMessageToEvent(call.arguments);
        break;
      default:
        throw MissingPluginException('notImplemented');
    }
  }

  static Future<void> logBreak() async {
    try {
      print("invoking from flutter side");
      await platform.invokeMethod('logBreak');
    } on PlatformException catch (e) {
      print("Failed to invoke native iOS intent: '${e.message}'.");
    }
  }

  Future<void> _startListening() async {
    convertMessageToEvent("I just did a 30 minute workout");
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.finalResult) {
              _isListening = false;
              // convertMessageToEvent(_text);
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Voice to Text'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _text,
                style: const TextStyle(
                  fontSize: 24.0,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
              ElevatedButton(
                onPressed: _startListening,
                child: Icon(_isListening ? Icons.mic_off : Icons.mic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> convertMessageToEvent(String query) async {
  const String url =
      'http://ai-tracker-server-613e3dd103bb.herokuapp.com/convertMessageToEvent'; // Change localhost to the appropriate IP if needed
  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'query': query, 'time': getTime()}),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    print('Server responded with: ${response.body}');
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    print('Failed to load data: ${response.statusCode}');
  }
}

String getTime() {
  DateTime now = DateTime.now();

  // Dart's DateTime object contains the local time zone offset as a Duration object
  String offsetSign = now.timeZoneOffset.isNegative
      ? "+"
      : "-"; // Invert sign because Dart's offset is positive if ahead of UTC
  int offsetHours = now.timeZoneOffset.inHours.abs();
  int offsetMinutes = now.timeZoneOffset.inMinutes.abs() % 60;

  // Format the current date and time
  String year = now.year.toString();
  String month = now.month.toString().padLeft(2, '0');
  String day = now.day.toString().padLeft(2, '0');
  int hour24 = now
      .hour; // No need to convert, Dart provides both .hour (0-23) and .hour12 (1-12)
  String hours = (hour24 % 12 == 0 ? 12 : hour24 % 12)
      .toString()
      .padLeft(2, '0'); // Convert 24h to 12h format
  String minutes = now.minute.toString().padLeft(2, '0');
  String seconds = now.second.toString().padLeft(2, '0');
  String ampm = hour24 >= 12 ? 'PM' : 'AM';

  // Construct the formatted date and time string with time zone offset
  String formattedDateTimeWithTimeZone =
      "$year-$month-$day, $hours:$minutes:$seconds $ampm ${offsetSign}${offsetHours.toString().padLeft(2, '0')}:${offsetMinutes.toString().padLeft(2, '0')}";

  return formattedDateTimeWithTimeZone;
}
