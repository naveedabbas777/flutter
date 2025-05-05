import 'package:flutter/material.dart';
import 'gender_card.dart';
import 'value_card.dart';
import 'card_section.dart';
import 'result_screen.dart';

enum Gender { male, female }

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  Gender? selectedGender;
  double height = 147;
  int weight = 60;
  int age = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("BMI Calculator")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  GenderCard(
                    icon: Icons.male,
                    label: 'MALE',
                    isSelected: selectedGender == Gender.male,
                    onTap: () => setState(() => selectedGender = Gender.male),
                  ),
                  GenderCard(
                    icon: Icons.female,
                    label: 'FEMALE',
                    isSelected: selectedGender == Gender.female,
                    onTap: () => setState(() => selectedGender = Gender.female),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CardSection(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("HEIGHT", style: TextStyle(color: Colors.white)),
                    Text(
                      "${height.round()} cm",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: height,
                      min: 100.0,
                      max: 220.0,
                      divisions: 120,
                      label: '${height.round()} cm',
                      onChanged: (val) => setState(() => height = val),
                      activeColor: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  ValueCard(
                    label: "WEIGHT",
                    value: weight,
                    onIncrement: () => setState(() => weight++),
                    onDecrement: () => setState(() => weight--),
                  ),
                  ValueCard(
                    label: "AGE",
                    value: age,
                    onIncrement: () => setState(() => age++),
                    onDecrement: () => setState(() => age--),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.red,
              height: 60,
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  double heightInM = height / 100;
                  double bmi = weight / (heightInM * heightInM);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(bmi: bmi),
                    ),
                  );
                },
                child: const Text(
                  "CALCULATE",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
