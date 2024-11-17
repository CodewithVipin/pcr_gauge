// ignore_for_file: library_private_types_in_public_api, unused_field

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  String _suggestion = '';
  double? _pcrValue;

  String _reason = '';

  final List<Map<String, dynamic>> _pcrSuggestions = [];

  void _calculateSuggestion() {
    final double? callOiChange = double.tryParse(_callOiController.text);
    final double? putOiChange = double.tryParse(_putOiController.text);

    if (callOiChange == null || putOiChange == null || callOiChange == 0) {
      setState(() {
        _suggestion =
            'Please enter valid non-zero values for Call and Put OI Change.';
        _pcrValue = null;
      });
      return;
    }

    double pcr = putOiChange / callOiChange;
    _pcrValue = pcr;

    String newSuggestion = '';
    String newReason = '';

    if (pcr < 0.5) {
      newSuggestion = 'Buy Put';
      newReason =
          'PCR is very low, indicating strong selling pressure in calls.';
    } else if (pcr >= 0.5 && pcr < 1) {
      newSuggestion = 'Buy Call';
      newReason =
          'PCR is moderate, suggesting potential call buying opportunity.';
    } else if (pcr >= 1 && pcr <= 1.1) {
      newSuggestion = 'Balance Zone';
      newReason = 'PCR is near 1.0, indicating a balanced market sentiment.';
    } else if (pcr > 1.1 && pcr <= 1.3) {
      newSuggestion = 'Buy Put';
      newReason = 'PCR above 1.1 suggests rising bearish sentiment.';
    } else if (pcr > 1.3 && pcr <= 2.0) {
      newSuggestion = 'Buy Put';
      newReason = 'High PCR indicates strong bearish sentiment.';
    } else if (pcr > 2.0) {
      newSuggestion = 'Buy Call';
      newReason = 'PCR very high, potential reversal signal to bullish.';
    } else {
      newSuggestion = 'Invalid PCR range';
      newReason = 'PCR is out of expected range for trading suggestions.';
    }

    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('d MMMM, yyyy hh:mm a').format(now);

    setState(() {
      // Add the new entry to the list, including callOiChange and putOiChange
      _pcrSuggestions.add({
        'pcr': _pcrValue,
        'suggestion': newSuggestion,
        'callOiChange': callOiChange,
        'putOiChange': putOiChange,
        'timestamp': formattedDate,
      });

      // Update suggestion and reason
      _suggestion = newSuggestion;
      _reason = newReason;

      // Clear text fields
      _callOiController.clear();
      _putOiController.clear();
    });
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
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _callOiController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Call OI Change'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _putOiController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Put OI Change'),
                    onSubmitted: (_) => _calculateSuggestion(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 10),
            Text(
              'Reason: $_reason',
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.brown,
                  fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _pcrSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _pcrSuggestions.reversed.toList()[index];
                  return Card(
                    elevation: 4,
                    color: Colors.brown[100],
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    child: ListTile(
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 0.5,
                                        color: Colors.green.shade400),
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.green.withOpacity(0.2)),
                                child: Row(
                                  children: [
                                    Text(
                                      'Call OI Change:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[800],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      " ${suggestion['callOiChange']}",
                                      style: TextStyle(
                                          color: Colors.green[800],
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 0.5, color: Colors.red.shade400),
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.red.withOpacity(0.2)),
                                child: Row(
                                  children: [
                                    Text(
                                      'Put OI Change: ',
                                      style: TextStyle(
                                          color: Colors.red[800],
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "${suggestion['putOiChange']}",
                                      style: TextStyle(
                                          color: Colors.red[800],
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: suggestion.toString().contains("Call")
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.2),
                              border: Border.all(
                                  width: 0.5,
                                  color: suggestion.toString().contains("Call")
                                      ? Colors.green.shade400
                                      : Colors.red.shade400),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Suggestion: ',
                                  style: TextStyle(
                                      color:
                                          suggestion.toString().contains("Put")
                                              ? Colors.red[800]
                                              : Colors.green[800],
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${suggestion['suggestion']}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: suggestion.toString().contains("Put")
                                        ? Colors.red[800]
                                        : Colors.green[800],
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(width: 0.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  suggestion['timestamp'],
                                  style: const TextStyle(color: Colors.brown),
                                ),
                                Text(
                                  'PCR: ${suggestion['pcr'].toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
