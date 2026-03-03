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
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple);

    return MaterialApp(
      title: 'Flashcard App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: Colors.transparent,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: colorScheme.primary,
          contentTextStyle: const TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
        ),
      ),
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
    if (!mounted) return;

    setState(() {
      _flashcards = cards;

      if (_flashcards.isEmpty) {
        _currentIndex = 0;
        _isFlipped = false;
        return;
      }

      if (_currentIndex >= _flashcards.length) {
        _currentIndex = _flashcards.length - 1;
      }
      _isFlipped = false;
    });
  }

  void _flipCard() {
    setState(() => _isFlipped = !_isFlipped);
  }

  void _nextCard() {
    if (_flashcards.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _flashcards.length;
      _isFlipped = false;
    });
  }

  void _previousCard() {
    if (_flashcards.isEmpty) return;
    setState(() {
      _currentIndex =
          (_currentIndex - 1 + _flashcards.length) % _flashcards.length;
      _isFlipped = false;
    });
  }

  Future<bool> _addFlashcard(String question, String answer) async {
    final trimmedQuestion = question.trim();
    final trimmedAnswer = answer.trim();

    if (trimmedQuestion.isEmpty || trimmedAnswer.isEmpty) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both question and answer.')),
      );
      return false;
    }

    final flashcard = Flashcard(
      question: trimmedQuestion,
      answer: trimmedAnswer,
    );
    await FlashcardDatabase.instance.create(flashcard);
    await _loadFlashcards();

    if (!mounted) return false;
    setState(() {
      _currentIndex = _flashcards.isEmpty ? 0 : _flashcards.length - 1;
      _isFlipped = false;
    });
    return true;
  }

  Future<void> _deleteFlashcard(int id) async {
    await FlashcardDatabase.instance.delete(id);
    await _loadFlashcards();

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Flashcard deleted')));
  }

  void _showAddDialog() {
    final questionController = TextEditingController();
    final answerController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Create Flashcard'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  decoration: const InputDecoration(
                    labelText: 'Question',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: answerController,
                  decoration: const InputDecoration(
                    labelText: 'Answer',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final created = await _addFlashcard(
                    questionController.text,
                    answerController.text,
                  );
                  if (created && context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCards = _flashcards.isNotEmpty;
    final currentCard = hasCards ? _flashcards[_currentIndex] : null;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Flashcard App',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton.filledTonal(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Add flashcard',
          ),
          const SizedBox(width: 8),
          if (currentCard != null)
            IconButton.filledTonal(
              onPressed: () => _deleteFlashcard(currentCard.id!),
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete current card',
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.45),
              colorScheme.secondaryContainer.withValues(alpha: 0.5),
              colorScheme.tertiaryContainer.withValues(alpha: 0.45),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child:
                    !hasCards
                        ? _EmptyState(onAddPressed: _showAddDialog)
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Chip(
                              avatar: const Icon(
                                Icons.style_outlined,
                                size: 18,
                              ),
                              label: Text(
                                'Card ${_currentIndex + 1} of ${_flashcards.length}',
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: _flipCard,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 280),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: ScaleTransition(
                                      scale: Tween<double>(
                                        begin: 0.96,
                                        end: 1,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
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
                                  isFlipped: _isFlipped,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              _isFlipped
                                  ? 'Answer side • Tap card to see question'
                                  : 'Question side • Tap card to see answer',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FilledButton.tonalIcon(
                                  onPressed: _previousCard,
                                  icon: const Icon(Icons.arrow_back_rounded),
                                  label: const Text('Previous'),
                                ),
                                const SizedBox(width: 12),
                                FilledButton.icon(
                                  onPressed: _nextCard,
                                  icon: const Icon(Icons.arrow_forward_rounded),
                                  label: const Text('Next'),
                                ),
                              ],
                            ),
                          ],
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FlashcardView extends StatelessWidget {
  final String text;
  final bool isFlipped;

  const FlashcardView({super.key, required this.text, required this.isFlipped});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 620),
      child: Card(
        elevation: 14,
        shadowColor: colorScheme.primary.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          height: 290,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  isFlipped
                      ? [
                        colorScheme.secondaryContainer,
                        colorScheme.tertiaryContainer,
                      ]
                      : [
                        colorScheme.primaryContainer,
                        colorScheme.secondaryContainer,
                      ],
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isFlipped ? 'ANSWER' : 'QUESTION',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Center(
                child: Icon(
                  Icons.touch_app_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddPressed;

  const _EmptyState({required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                Icons.auto_stories_rounded,
                size: 34,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No flashcards. Add some!',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first card and start practicing instantly.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Add your first flashcard'),
            ),
          ],
        ),
      ),
    );
  }
}
