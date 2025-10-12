import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wie viel krieg ich?',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
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
      ),
      home: TwelveInputFields(),
    );
  }
}

enum Monat {
  januar,
  februar,
  maerz,
  april,
  mai,
  juni,
  juli,
  august,
  september,
  oktober,
  november,
  dezember,
}

extension MonatExtension on Monat {
  String get name {
    switch (this) {
      case Monat.januar:
        return 'Januar';
      case Monat.februar:
        return 'Februar';
      case Monat.maerz:
        return 'März';
      case Monat.april:
        return 'April';
      case Monat.mai:
        return 'Mai';
      case Monat.juni:
        return 'Juni';
      case Monat.juli:
        return 'Juli';
      case Monat.august:
        return 'August';
      case Monat.september:
        return 'September';
      case Monat.oktober:
        return 'Oktober';
      case Monat.november:
        return 'November';
      case Monat.dezember:
        return 'Dezember';
    }
  }

  int get nummer => index + 1; // Januar = 1, Dezember = 12
}

class TwelveInputFields extends StatefulWidget {
  const TwelveInputFields({super.key});

  @override
  _TwelveInputFieldsState createState() => _TwelveInputFieldsState();
}

class _TwelveInputFieldsState extends State<TwelveInputFields> {
  final List<TextEditingController> _controllers = List.generate(
    12,
    (index) => TextEditingController(text: '0'),
  );

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _copyValueDown(int index) {
    if (index < _controllers.length - 1) {
      setState(() {
        _controllers[index + 1].text = _controllers[index].text;
      });
    }
  }

  void _clearField(int index) {
    setState(() {
      _controllers[index].text = '0';
    });
  }

  void _handleSubmit() {
    List<int?> values = _controllers
        .map((controller) => int.tryParse(controller.text))
        .toList();
    List<int> income_values;

    bool hasNull = values.contains(null);
    if (hasNull) {
      return;
    } else {
      income_values = values.cast<int>();
    }

    int x = income_values.reduce((a, b) => a + b); // Sum of all values
    x = x.floor(); // Round down to full Euro

    double tax = 0;

    if (x <= 12096) {
      tax = 0;
    } else if (x >= 12097 && x <= 17443) {
      double y = (x - 12096) / 10000;
      tax = (932.30 * y + 1400) * y;
    } else if (x >= 17444 && x <= 68480) {
      double z = (x - 17443) / 10000;
      tax = (176.64 * z + 2397) * z + 1015.13;
    } else if (x >= 68481 && x <= 277825) {
      tax = 0.42 * x - 10911.92;
    } else if (x >= 277826) {
      tax = 0.45 * x - 19246.67;
    }

    tax = tax.floorToDouble(); // Round down to nearest Euro

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Einkommenssteuerprognose'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('${tax.toStringAsFixed(0)} €')],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trage dein jeweiliges Bruttoeinkommen in € in die Monate ein.',
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ...List.generate(12, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    // Expanded TextField
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        controller: _controllers[index],
                        decoration: InputDecoration(
                          labelText: Monat.values[index].name,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    // Down arrow button (if not the last input)
                    if (index < _controllers.length - 1)
                      IconButton(
                        icon: Icon(Icons.arrow_downward),
                        tooltip: 'Copy to next field',
                        onPressed: () => _copyValueDown(index),
                      ),
                    // Clear button
                    IconButton(
                      icon: Icon(Icons.clear),
                      tooltip: 'Clear field',
                      onPressed: () => _clearField(index),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: 24),
            ElevatedButton(onPressed: _handleSubmit, child: Text('Submit')),
          ],
        ),
      ),
    );
  }
}
