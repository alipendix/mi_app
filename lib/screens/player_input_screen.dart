import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/player.dart';
import 'player_list_screen.dart';

class PlayerInputScreen extends StatefulWidget {
  const PlayerInputScreen({super.key});

  @override
  State<PlayerInputScreen> createState() => _PlayerInputScreenState();
}

class _PlayerInputScreenState extends State<PlayerInputScreen> {
  late final List<TextEditingController> _controllers;
  bool _isLoading = true;
  bool _isSaving = false;

  late Box<Player> _playersBox;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(18, (_) => TextEditingController());
    _openBoxAndLoadPlayers();

    for (var controller in _controllers) {
      controller.addListener(_onTextChanged);
    }
  }

  Future<void> _openBoxAndLoadPlayers() async {
    _playersBox = await Hive.openBox<Player>('playersBox');
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final players = _playersBox.values.toList();
      for (int i = 0; i < players.length && i < _controllers.length; i++) {
        _controllers[i].text = players[i].name;
      }
    } catch (e) {
      debugPrint('Error cargando jugadores de Hive: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savePlayers() async {
    if (_isSaving) return;
    _isSaving = true;

    try {
      await _playersBox.clear();

      final players = _controllers
          .map((c) => Player(c.text.trim()))
          .where((p) => p.name.isNotEmpty)
          .toList();

      await _playersBox.addAll(players);
    } catch (e) {
      debugPrint('Error guardando jugadores en Hive: $e');
    } finally {
      _isSaving = false;
    }
  }

  void _onTextChanged() {
    _savePlayers();
  }

  void _goToPlayerList() async {
    await _savePlayers();

    final players = _controllers
        .map((c) => Player(c.text.trim()))
        .where((p) => p.name.isNotEmpty)
        .toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerListScreen(players: players),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.removeListener(_onTextChanged);
      controller.dispose();
    }
    _playersBox.close();
    super.dispose();
  }

  InputDecoration _inputDecoration(int index, ThemeData theme) {
    return InputDecoration(
      hintText: 'Jugador ${index + 1}',
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.orange.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.orange.shade400, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(color: Colors.orange.shade300.withOpacity(0.7)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.orangeAccent)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Plantilla',
          style: TextStyle(
            color: Colors.orangeAccent,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Introduce los nombres de los jugadores:',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade300,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _controllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: TextField(
                      controller: _controllers[index],
                      decoration: _inputDecoration(index, theme),
                      style: const TextStyle(color: Colors.white),
                      textInputAction: TextInputAction.next,
                      cursorColor: Colors.orange.shade300,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _savePlayers,
                    icon: const Icon(Icons.save),
                    label: const Text("Guardar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade400,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _goToPlayerList,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text("Ir a Lista"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade400,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
