import 'dart:math';
import 'package:flutter/material.dart';

// A global ValueNotifier to manage the theme state across the app.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// --- Data Model ---
class Player {
  String name;
  int score;
  Player({required this.name, this.score = 0});
}

// --- Main App Entry ---
void main() => runApp(const LudoApp());

class LudoApp extends StatelessWidget {
  const LudoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Ludo Fun!',
          theme: ThemeData(
            brightness: Brightness.light,
            colorSchemeSeed: Colors.deepPurple,
            fontFamily: 'Poppins',
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.deepPurple,
            fontFamily: 'Poppins',
            useMaterial3: true,
          ),
          themeMode: currentMode,
          debugShowCheckedModeBanner: false,
          home: const LudoScreen(),
        );
      },
    );
  }
}

// --- Main Game Screen ---
class LudoScreen extends StatefulWidget {
  const LudoScreen({super.key});

  @override
  State<LudoScreen> createState() => _LudoScreenState();
}

class _LudoScreenState extends State<LudoScreen> {
  final List<Player> _players = [];
  final _diceKey = GlobalKey<DiceWidgetState>();
  int _currentPlayerIndex = 0;

  void _addPlayer(String name) {
    if (name.isNotEmpty && _players.length < 4) {
      setState(() {
        _players.add(Player(name: name));
      });
    }
  }

  void _handleRoll() {
    if (_players.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add at least one player to start.')),
      );
      return;
    }
    _diceKey.currentState?.roll();
  }

  void _onRollComplete(int rolledValue) {
    setState(() {
      _players[_currentPlayerIndex].score += rolledValue;
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? const [Color(0xFF240046), Color(0xFF5a189a)]
                    : const [Color(0xFF6A1B9A), Color(0xFFF9A825)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      ScreenHeader(onSettingsTap: _showThemeDialog),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      if (_players.length < 4)
                        PlayerInput(onAddPlayer: _addPlayer),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05),
                      TurnIndicator(
                          players: _players, currentIndex: _currentPlayerIndex),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      DiceWidget(
                          key: _diceKey, onRollComplete: _onRollComplete),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      RollButton(
                          isRolling: _diceKey.currentState?.isRolling ?? false,
                          onPressed: _handleRoll),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05),
                      if (_players.isNotEmpty) Scoreboard(players: _players),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(mode.name[0].toUpperCase() + mode.name.substring(1)),
              value: mode,
              groupValue: themeNotifier.value,
              onChanged: (value) {
                if (value != null) themeNotifier.value = value;
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

// --- WIDGETS ---

class DiceWidget extends StatefulWidget {
  final Function(int) onRollComplete;
  const DiceWidget({super.key, required this.onRollComplete});

  @override
  State<DiceWidget> createState() => DiceWidgetState();
}

class DiceWidgetState extends State<DiceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _diceImagePath = 'assets/images/dice_default.png';
  bool isRolling = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _controller.addListener(() {
      if (_controller.isAnimating) {
        setState(() {
          _diceImagePath = 'assets/images/dice_${Random().nextInt(6) + 1}.png';
        });
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        final finalRoll = Random().nextInt(6) + 1;
        setState(() {
          isRolling = false;
          _diceImagePath = 'assets/images/dice_$finalRoll.png';
        });
        widget.onRollComplete(finalRoll);
      }
    });
  }

  void roll() {
    if (!isRolling) {
      setState(() => isRolling = true);
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diceSize = min(MediaQuery.of(context).size.width * 0.4, 200.0);

    return RotationTransition(
      turns: Tween(begin: 0.0, end: 2.0).animate(_controller),
      child: ScaleTransition(
        scale: TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
        ]).animate(_controller),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            _diceImagePath,
            height: diceSize,
            width: diceSize,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: diceSize,
              width: diceSize,
              decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20)),
              child: const Center(
                  child: Text('Dice Image\nNot Found',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70))),
            ),
          ),
        ),
      ),
    );
  }
}

class ScreenHeader extends StatelessWidget {
  final VoidCallback onSettingsTap;
  const ScreenHeader({super.key, required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Ludo Fun!',
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2),
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white, size: 28),
          onPressed: onSettingsTap,
        ),
      ],
    );
  }
}

class PlayerInput extends StatefulWidget {
  final Function(String) onAddPlayer;
  const PlayerInput({super.key, required this.onAddPlayer});

  @override
  State<PlayerInput> createState() => _PlayerInputState();
}

class _PlayerInputState extends State<PlayerInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onAddPlayer(_controller.text.trim());
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Player Name',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            onSubmitted: (_) => _submit(),
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: 'Enter player name',
              filled: true,
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Player'),
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8E24AA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TurnIndicator extends StatelessWidget {
  final List<Player> players;
  final int currentIndex;
  const TurnIndicator(
      {super.key, required this.players, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final text = players.isEmpty
        ? "Add a player to start!"
        : "It's ${players[currentIndex].name}'s Turn!";
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
                blurRadius: 10.0,
                color: Colors.black45,
                offset: Offset(2.0, 2.0))
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class RollButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isRolling;
  const RollButton(
      {super.key, required this.onPressed, required this.isRolling});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.casino_outlined, size: 24),
      label: Text(isRolling ? 'Rolling...' : 'Roll Dice'),
      onPressed: isRolling ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        foregroundColor: Theme.of(context).colorScheme.primary,
        disabledBackgroundColor: Colors.grey.shade400,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        elevation: 5,
      ),
    );
  }
}

class Scoreboard extends StatelessWidget {
  final List<Player> players;
  const Scoreboard({super.key, required this.players});

  static const _playerColors = [
    Color(0xFFd90429),
    Color(0xFF0077b6),
    Color(0xFF2d6a4f),
    Color(0xFFfca311),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Scoreboard',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: _playerColors[index % _playerColors.length],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(player.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  Text('${player.score}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
