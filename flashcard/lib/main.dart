import 'package:flutter/material.dart';
import 'db/flashcard_database.dart';
import 'models/flashcard.dart';

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
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  List<Flashcard> _flashcards = [];
  int _currentIndex = 0;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    final cards = await FlashcardDatabase.instance.readAll();
    setState(() => _flashcards = cards);
  }

  void _flipCard() {
    setState(() => _isFlipped = !_isFlipped);
  }

  void _nextCard() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _flashcards.length;
      _isFlipped = false;
    });
  }

  void _previousCard() {
    setState(() {
      _currentIndex =
          (_currentIndex - 1 + _flashcards.length) % _flashcards.length;
      _isFlipped = false;
    });
  }

  Future<void> _addFlashcard(String question, String answer) async {
    final flashcard = Flashcard(question: question, answer: answer);
    await FlashcardDatabase.instance.create(flashcard);
    _loadFlashcards();
  }

  Future<void> _deleteFlashcard(int id) async {
    await FlashcardDatabase.instance.delete(id);
    _loadFlashcards();
  }

  void _showAddDialog() {
    final questionController = TextEditingController();
    final answerController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Add Flashcard'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  decoration: const InputDecoration(labelText: 'Question'),
                ),
                TextField(
                  controller: answerController,
                  decoration: const InputDecoration(labelText: 'Answer'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  _addFlashcard(questionController.text, answerController.text);
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = _flashcards.isEmpty ? null : _flashcards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard App'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _showAddDialog),
          if (currentCard != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteFlashcard(currentCard.id!),
            ),
        ],
      ),
      body: Center(
        child:
            _flashcards.isEmpty
                ? const Text('No flashcards. Add some!')
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _flipCard,
                      child: FlashcardView(
                        key: ValueKey(
                          _isFlipped
                              ? 'back-${currentCard!.id}'
                              : 'front-${currentCard!.id}',
                        ),
                        text:
                            _isFlipped
                                ? currentCard!.answer
                                : currentCard!.question,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _previousCard,
                          child: const Text('Previous'),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: _nextCard,
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  ],
                ),
      ),
    );
  }
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
