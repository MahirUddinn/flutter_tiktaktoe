import 'dart:math';
import 'package:flutter/material.dart';

class ComputerPlayerScreen extends StatefulWidget {
  const ComputerPlayerScreen({super.key});

  @override
  _ComputerPlayerScreenState createState() => _ComputerPlayerScreenState();
}

class _ComputerPlayerScreenState extends State<ComputerPlayerScreen> {
  late List<String> _board;
  late String _currentPlayer;
  late String _winner;
  late bool _isDraw;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      _board = List.filled(9, '');
      _currentPlayer = 'X';
      _winner = '';
      _isDraw = false;
    });
  }

  void _makeMove(int index) {
    if (_board[index] == '' && _winner == '') {
      setState(() {
        _board[index] = _currentPlayer;
        _checkWinner();
        if (_winner == '') {
          _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
          _checkDraw();
          if (_currentPlayer == 'O' && _winner == '' && !_isDraw) {
            _computerMove();
          }
        }
      });
    }
  }

  void _computerMove() {
    int bestScore = -1000;
    int bestMove = -1;

    for (int i = 0; i < _board.length; i++) {
      if (_board[i] == '') {
        _board[i] = 'O';
        int score = _minimax(_board, 'X');
        _board[i] = '';
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }

    if (bestMove != -1) {
      _makeMove(bestMove);
    }
  }

  int _minimax(List<String> board, String player) {
    if (_checkWinnerForMinimax(board, 'O')) {
      return 1;
    } else if (_checkWinnerForMinimax(board, 'X')) {
      return -1;
    } else if (_isBoardFull(board)) {
      return 0;
    }

    List<int> emptyCells = _getEmptyCells(board);
    if (player == 'O') {
      int bestScore = -1000;
      for (int cell in emptyCells) {
        board[cell] = 'O';
        int score = _minimax(board, 'X');
        board[cell] = '';
        bestScore = max(bestScore, score);
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int cell in emptyCells) {
        board[cell] = 'X';
        int score = _minimax(board, 'O');
        board[cell] = '';
        bestScore = min(bestScore, score);
      }
      return bestScore;
    }
  }

  bool _checkWinnerForMinimax(List<String> board, String player) {
    const List<List<int>> winningCombinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
      [0, 4, 8], [2, 4, 6], // diagonals
    ];

    for (final combination in winningCombinations) {
      final a = board[combination[0]];
      final b = board[combination[1]];
      final c = board[combination[2]];

      if (a == player && b == player && c == player) {
        return true;
      }
    }
    return false;
  }

  bool _isBoardFull(List<String> board) {
    return !board.contains('');
  }

  List<int> _getEmptyCells(List<String> board) {
    final emptyCells = <int>[];
    for (var i = 0; i < board.length; i++) {
      if (board[i] == '') {
        emptyCells.add(i);
      }
    }
    return emptyCells;
  }

  void _checkWinner() {
    const List<List<int>> winningCombinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
      [0, 4, 8], [2, 4, 6], // diagonals
    ];

    for (final combination in winningCombinations) {
      final a = _board[combination[0]];
      final b = _board[combination[1]];
      final c = _board[combination[2]];

      if (a != '' && a == b && b == c) {
        setState(() {
          _winner = a;
        });
        return;
      }
    }
  }

  void _checkDraw() {
    if (!_board.contains('')) {
      setState(() {
        _isDraw = true;
      });
    }
  }

  Widget _buildBoard() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _makeMove(index),
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Text(
                  _board[index],
                  key: ValueKey<String>(_board[index]),
                  style: TextStyle(
                    fontSize: 48.0,
                    color: _board[index] == 'X' ? Colors.blue : Colors.red,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatus() {
    String status;
    if (_winner != '') {
      status = 'Winner: $_winner';
    } else if (_isDraw) {
      status = 'Draw';
    } else {
      status = 'Current Player: $_currentPlayer';
    }

    return Text(
      status,
      style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tic Tac Toe - Vs Computer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatus(),
            const SizedBox(height: 20.0),
            _buildBoard(),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _startNewGame,
              child: const Text('New Game'),
            ),
          ],
        ),
      ),
    );
  }
}
