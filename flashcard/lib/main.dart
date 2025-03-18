import 'package:flutter/material.dart';

void main() {
  runApp(const FlashcardApp());
}

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const FlashcardScreen(),
    );
  }
}

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  FlashcardScreenState createState() => FlashcardScreenState();
}

class FlashcardScreenState extends State<FlashcardScreen> {
  // List of flashcards (you can add more)
  final List<Flashcard> _flashcards = [
    Flashcard(
      question: 'What is Flutter?',
      answer: 'A UI toolkit for building natively compiled applications.',
    ),
    Flashcard(
      question: 'What is Dart?',
      answer: 'The programming language used by Flutter.',
    ),
    Flashcard(
      question: 'What is a Widget?',
      answer: 'The basic building block of a Flutter UI.',
    ),
    Flashcard(
      question: 'What is Hot Reload?',
      answer:
          'A feature that allows you to see the changes you make to your code in real time.',
    ),
    Flashcard(
      question: 'What is a Stateful Widget?',
      answer: 'A widget that can change its state.',
    ),
    Flashcard(
      question: 'What is a Stateless Widget?',
      answer: 'A widget that cannot change its state.',
    ),
  ];

  int _currentIndex = 0;
  bool _isFlipped = false;

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _nextCard() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _flashcards.length;
      _isFlipped = false; // Reset flip state when moving to a new card
    });
  }

  void _previousCard() {
    setState(() {
      _currentIndex =
          (_currentIndex - 1 + _flashcards.length) % _flashcards.length;
      _isFlipped = false; // Reset flip state when moving to a new card
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flashcard App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: _flipCard,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final rotate = Tween(begin: 0.0, end: 1.0).animate(animation);
                  return AnimatedBuilder(
                    animation: rotate,
                    builder: (context, child) {
                      final isFront =
                          child?.key ==
                          ValueKey(
                            '${_flashcards[_currentIndex].question}-front',
                          );
                      var tilt = (animation.value - 0.5).abs() * 0.5;
                      tilt *= isFront ? -1.0 : 1.0;
                      final transform = Matrix4.rotationY(3.14 * rotate.value);
                      return Transform(
                        transform: transform,
                        alignment: Alignment.center,
                        child: child,
                      );
                    },
                    child: child,
                  );
                },
                child:
                    _isFlipped
                        ? FlashcardView(
                          key: ValueKey(
                            '${_flashcards[_currentIndex].question}-back',
                          ), // Unique key for each flashcard's back
                          text: _flashcards[_currentIndex].answer,
                        )
                        : FlashcardView(
                          key: ValueKey(
                            '${_flashcards[_currentIndex].question}-front',
                          ), // Unique key for each flashcard's front
                          text: _flashcards[_currentIndex].question,
                        ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _previousCard,
                  child: const Text('Previous'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(onPressed: _nextCard, child: const Text('Next')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Flashcard {
  final String question;
  final String answer;

  Flashcard({required this.question, required this.answer});
}

class FlashcardView extends StatelessWidget {
  final String text;

  const FlashcardView({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        width: 300,
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
