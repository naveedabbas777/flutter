import 'package:flutter/material.dart';
import 'gender_card.dart';
import 'value_card.dart';
import 'card_section.dart';

enum Gender { male, female }

void main() => runApp(const BMICalculator());

class BMICalculator extends StatefulWidget {
  const BMICalculator({super.key});

  @override
  State<BMICalculator> createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  // here is the use of ternary operator
  Gender? selectedGender;
  double height = 147;
  int weight = 60;
  int age = 20;

  void updateGender(Gender gender) {
    setState(() {
      selectedGender = gender;
    });
  }

  void updateWeight(bool increment) {
    setState(() {
      weight += increment ? 1 : -1;
    });
  }

  void updateAge(bool increment) {
    setState(() {
      age += increment ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("BMI Calculator")),
        backgroundColor: Colors.black,
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
                      onTap: () => updateGender(Gender.male),
                    ),
                    GenderCard(
                      icon: Icons.female,
                      label: 'FEMALE',
                      isSelected: selectedGender == Gender.female,
                      onTap: () => updateGender(Gender.female),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CardSection(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "HEIGHT",
                        style: TextStyle(color: Colors.white),
                      ),
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
                      onIncrement: () => updateWeight(true),
                      onDecrement: () => updateWeight(false),
                    ),
                    ValueCard(
                      label: "AGE",
                      value: age,
                      onIncrement: () => updateAge(true),
                      onDecrement: () => updateAge(false),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.red,
                height: 60,
                width: double.infinity,
                child: const Center(
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
