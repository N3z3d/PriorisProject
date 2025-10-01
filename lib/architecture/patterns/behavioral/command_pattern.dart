/// Command Pattern Implementation
///
/// Behavioral pattern that encapsulates requests as objects, allowing
/// parametrization, queuing, logging, and undoable operations.

abstract class Command {
  Future<void> execute();
  Future<void> undo();
  String get description;
}

/// Composite command for batch operations
class CompositeCommand extends Command {
  final List<Command> _commands = [];
  final String _description;

  CompositeCommand(this._description);

  void addCommand(Command command) {
    _commands.add(command);
  }

  @override
  Future<void> execute() async {
    for (final command in _commands) {
      await command.execute();
    }
  }

  @override
  Future<void> undo() async {
    // Execute undo in reverse order
    for (int i = _commands.length - 1; i >= 0; i--) {
      await _commands[i].undo();
    }
  }

  @override
  String get description => _description;
}

/// Command invoker with history for undo/redo
class CommandInvoker {
  final List<Command> _history = [];
  int _currentIndex = -1;

  Future<void> execute(Command command) async {
    // Remove any commands after current index when executing new command
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    await command.execute();
    _history.add(command);
    _currentIndex++;
  }

  Future<void> undo() async {
    if (canUndo()) {
      final command = _history[_currentIndex];
      await command.undo();
      _currentIndex--;
    }
  }

  Future<void> redo() async {
    if (canRedo()) {
      _currentIndex++;
      final command = _history[_currentIndex];
      await command.execute();
    }
  }

  bool canUndo() => _currentIndex >= 0;
  bool canRedo() => _currentIndex < _history.length - 1;

  void clearHistory() {
    _history.clear();
    _currentIndex = -1;
  }

  List<String> get historyDescriptions =>
      _history.map((cmd) => cmd.description).toList();
}