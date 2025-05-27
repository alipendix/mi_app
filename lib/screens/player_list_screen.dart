import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/player.dart';

class PlayerListScreen extends StatefulWidget {
  final List<Player> players;

  const PlayerListScreen({super.key, required this.players});

  @override
  State<PlayerListScreen> createState() => _PlayerListScreenState();
}

class _PlayerListScreenState extends State<PlayerListScreen> {
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  void _pauseTimer() {
    _isRunning = false;
    _timer?.cancel();
  }

  void _resetTimer() {
    _pauseTimer();
    setState(() {
      _secondsElapsed = 0;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _buildEventSummary(Player player) {
    List<String> events = [];

    if (player.goalMinutes.isNotEmpty) {
      final golesMinutos = player.goalMinutes.map((m) => "${m}'").join(', ');
      final plural = player.goalMinutes.length > 1 ? 'es' : '';
      events.add('⚽ gol$plural $golesMinutos');
    }

    if (player.hasYellowCard) {
      final min = player.substitutedMinute ?? (_secondsElapsed ~/ 60);
      events.add('🟨 amarilla ${min}\'');
    }

    if (player.hasRedCard) {
      final min = player.substitutedMinute ?? (_secondsElapsed ~/ 60);
      events.add('🟥 roja ${min}\'');
    }

    if (player.substitutedMinute != null) {
      events.add('🔄 cambio ${player.substitutedMinute}\'');
    }

    return events.join(', ');
  }

  Future<void> _exportCsv() async {
  List<List<String>> rows = [
    ['Nombre', 'Goles (minutos)', 'Tarjeta Amarilla', 'Tarjeta Roja', 'Minuto Cambio']
  ];

  for (var player in widget.players) {
    rows.add([
      player.name,
      player.goalMinutes.map((m) => m.toString()).join('-'),
      player.hasYellowCard ? 'Si' : 'No',
      player.hasRedCard ? 'Si' : 'No',
      player.substitutedMinute?.toString() ?? '',
    ]);
  }

  final csvData = const ListToCsvConverter(fieldDelimiter: '|').convert(rows);

  final status = await Permission.manageExternalStorage.request(); // asegúrate de usar este permiso

  if (!status.isGranted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Permiso de almacenamiento denegado')),
    );
    return;
  }

  final directory = Directory('/storage/emulated/0/Documents');
  final filename = 'informe_partido_${DateTime.now().millisecondsSinceEpoch}.csv';
  final path = '${directory.path}/$filename';

  final file = File(path);
  await file.writeAsString(csvData);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Informe guardado en: $path')),
  );
}

  Widget _buildTimerControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _startTimer,
          icon: const Icon(Icons.play_arrow),
          label: const Text("Iniciar"),
        ),
        ElevatedButton.icon(
          onPressed: _pauseTimer,
          icon: const Icon(Icons.pause),
          label: const Text("Pausar"),
        ),
        ElevatedButton.icon(
          onPressed: _resetTimer,
          icon: const Icon(Icons.refresh),
          label: const Text("Resetear"),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(Player player) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.black87,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ExpansionTile(
          title: Row(
            children: [
              const Icon(Icons.sports_soccer, color: Colors.deepOrangeAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  player.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          children: [
            Row(
              children: [
                const Icon(Icons.sports_soccer, color: Colors.orangeAccent),
                const SizedBox(width: 6),
                const Text('Goles:',
                    style: TextStyle(fontSize: 16, color: Colors.white70)),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                  onPressed: () {
                    setState(() {
                      if (player.goalMinutes.isNotEmpty) {
                        player.goalMinutes.removeLast();
                      }
                    });
                  },
                ),
                Text(
                  player.goals.toString(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.greenAccent),
                  onPressed: () {
                    setState(() {
                      player.goalMinutes.add(_secondsElapsed ~/ 60);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: player.hasYellowCard,
            activeColor: Colors.deepOrangeAccent,
            onChanged: (value) {
              setState(() {
                player.hasYellowCard = value ?? false;
              });
            },
          ),
          const Text('🟨', style: TextStyle(fontSize: 18, color: Colors.white70)),
          const SizedBox(width: 12),
        ],
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: player.hasRedCard,
            activeColor: Colors.deepOrangeAccent,
            onChanged: (value) {
              setState(() {
                player.hasRedCard = value ?? false;
              });
            },
          ),
          const Text('🟥', style: TextStyle(fontSize: 18, color: Colors.white70)),
          const SizedBox(width: 12),
        ],
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: player.substitutedMinute != null,
            activeColor: Colors.deepOrangeAccent,
            onChanged: (value) {
              setState(() {
                if (value == true && player.substitutedMinute == null) {
                  player.substitutedMinute = _secondsElapsed ~/ 60;
                } else if (value == false) {
                  player.substitutedMinute = null;
                }
              });
            },
          ),
          const Text('🔄', style: TextStyle(fontSize: 18, color: Colors.white70)),
        ],
      ),
    ],
  ),
),

            const SizedBox(height: 12),
            Text(
              _buildEventSummary(player),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 Lista de Jugadores'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: _exportCsv,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer, color: Colors.deepOrangeAccent),
                const SizedBox(width: 8),
                Text(
                  'Tiempo de juego: ${_formatTime(_secondsElapsed)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrangeAccent,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.players.length,
              itemBuilder: (context, index) {
                return _buildPlayerCard(widget.players[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildTimerControls(),
          ),
        ],
      ),
    );
  }
}
