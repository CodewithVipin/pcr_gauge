import 'package:flutter/material.dart';

void main() => runApp(const PCRTradingApp());

class PCRTradingApp extends StatelessWidget {
  const PCRTradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PCR Trading Suggestions',
      theme: ThemeData(
        primaryColor: Colors.brown[800],
        scaffoldBackgroundColor: Colors.brown[50],
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.brown[800],
          secondary: Colors.brown[600],
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.brown),
          bodyMedium: TextStyle(color: Colors.brown),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.brown[800],
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.brown[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.brown[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.brown[600]!),
          ),
          labelStyle: TextStyle(color: Colors.brown[700]),
        ),
      ),
      home: const TradingSuggestionPage(),
    );
  }
}

class TradingSuggestionPage extends StatefulWidget {
  const TradingSuggestionPage({super.key});

  @override
  _TradingSuggestionPageState createState() => _TradingSuggestionPageState();
}

class _TradingSuggestionPageState extends State<TradingSuggestionPage> {
  final TextEditingController _callOiController = TextEditingController();
  final TextEditingController _putOiController = TextEditingController();
  final FocusNode _callOiFocus = FocusNode();
  final FocusNode _putOiFocus = FocusNode();
  String _suggestion = '';
  double? _pcrValue; // PCR value variable
  final String _emaMessage =
      'Always watch the 20-50 EMA crossover for market flow.';

  void _calculateSuggestion() {
    final double? callOiChange = double.tryParse(_callOiController.text);
    final double? putOiChange = double.tryParse(_putOiController.text);

    if (callOiChange == null || putOiChange == null || callOiChange == 0) {
      setState(() {
        _suggestion =
            'Please enter valid non-zero values for Call and Put OI Change.';
        _pcrValue = null; // Reset PCR value if input is invalid
      });
      return;
    }

    double pcr = putOiChange / callOiChange;
    _pcrValue = pcr; // Store the PCR value

    if (pcr < 0.5) {
      _suggestion =
          'Suggest: Buy Put\nReason: Extremely bullish sentiment may reverse.';
    } else if (pcr >= 0.5 && pcr < 1) {
      _suggestion =
          'Suggest: Buy Call\nReason: Bullish sentiment with potential for uptrend continuation.';
    } else if (pcr >= 1 && pcr <= 1.1) {
      _suggestion =
          'Wait - Market is in Balance Zone.\nReason: Neutral market sentiment.';
    } else if (pcr > 1.1 && pcr <= 1.3) {
      _suggestion =
          'Suggest: Buy Put\nReason: Mild bearish sentiment, may indicate slight downside potential.';
    } else if (pcr > 1.3 && pcr <= 2.0) {
      _suggestion =
          'Suggest: Buy Put\nReason: Strong bearish sentiment, market could continue downtrend.';
    } else if (pcr > 2.0) {
      _suggestion =
          'Suggest: Buy Call\nReason: Extreme bearish sentiment, market may be oversold, potential for bounce.';
    } else {
      _suggestion = 'Invalid PCR range.';
    }

    setState(() {});
  }

  @override
  void dispose() {
    _callOiController.dispose();
    _putOiController.dispose();
    _callOiFocus.dispose();
    _putOiFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PCR Trading Suggestions'),
        backgroundColor: Colors.brown[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Text(
              _isTradingTime()
                  ? "It's Good time to Go!"
                  : "Hey! Vipin, Don't Trade Please!!",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _callOiController,
                    focusNode: _callOiFocus,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Call OI Change'),
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_putOiFocus);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _putOiController,
                    focusNode: _putOiFocus,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Put OI Change'),
                    onSubmitted: (_) {
                      _calculateSuggestion();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_pcrValue != null) // Check if PCR value is not null
              Text(
                'PCR Value: ${_pcrValue!.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.brown[100],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                _suggestion,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _emaMessage,
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.brown[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isTradingTime() {
    final currentTime = DateTime.now();
    return (currentTime.hour == 11 && currentTime.minute >= 30) ||
        (currentTime.hour == 12) ||
        (currentTime.hour == 13) ||
        (currentTime.hour == 14 && currentTime.minute <= 40);
  }
}
