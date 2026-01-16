import '../models/quote.dart';

class MockData {
  static const categories = ['All', 'Motivation', 'Wisdom', 'Love', 'Success', 'Humor'];

  static final quotes = <Quote>[
    const Quote(id: 1, text: 'Progress beats perfection.', author: 'Unknown', category: 'Motivation', liked: true),
    const Quote(id: 2, text: 'Wisdom is knowing what to ignore.', author: 'Unknown', category: 'Wisdom'),
    const Quote(id: 3, text: 'Love is built, not found.', author: 'Unknown', category: 'Love'),
    const Quote(id: 4, text: 'Focus is the new IQ.', author: 'Unknown', category: 'Success'),
    const Quote(id: 5, text: 'I’m not lazy. I’m in energy-saving mode.', author: 'Unknown', category: 'Humor'),
    const Quote(id: 6, text: 'Start messy.', author: 'Unknown', category: 'Motivation'),
    const Quote(id: 7, text: 'A calm mind is a competitive advantage.', author: 'Unknown', category: 'Wisdom', liked: true),
    const Quote(id: 8, text: 'Choose tenderness.', author: 'Unknown', category: 'Love'),
    const Quote(id: 9, text: 'Results love repetition.', author: 'Unknown', category: 'Success'),
    const Quote(id: 10, text: 'Running late is my cardio.', author: 'Unknown', category: 'Humor'),
  ];
}