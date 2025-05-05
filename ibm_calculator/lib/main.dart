import 'package:flutter/material.dart';

void main() => runApp(const BMICalculator());

class BMICalculator extends StatelessWidget {
  const BMICalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("BMI Calculator")),
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    GenderCard(icon: Icons.male, label: 'MALE'),
                    GenderCard(icon: Icons.female, label: 'FEMALE'),
                  ],
                ),
              ),
              Expanded(
                child: CardSection(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("HEIGHT", style: TextStyle(color: Colors.white)),
                      Text(
                        "147 cm",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Slider(
                        value: 147.0,
                        min: 100.0,
                        max: 220.0,
                        divisions: 120,
                        label: '147 cm',
                        onChanged: (val) {},
                        activeColor: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    ValueCard(label: "WEIGHT", value: 60),
                    ValueCard(label: "AGE", value: 20),
                  ],
                ),
              ),
              Container(
                color: Colors.red,
                height: 60,
                width: double.infinity,
                child: Center(
                  child: Text(
                    "CALCULATE",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GenderCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const GenderCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CardSection(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.white),
            SizedBox(height: 10),
            Text(label, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// this gives the value and label of the age and weight
class ValueCard extends StatelessWidget {
  final String label;
  final int value;

  const ValueCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CardSection(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(color: Colors.white)),
            Text('$value', style: TextStyle(color: Colors.white, fontSize: 30)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  child: Icon(Icons.remove, color: Colors.white),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CardSection extends StatelessWidget {
  final Widget child;

  const CardSection({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
