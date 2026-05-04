import 'package:share_plus/share_plus.dart';
import '../models/game_state.dart';

class ShareService {
  static String buildShareText(GameState state) {
    final buffer = StringBuffer();
    final impostors = state.impostors;
    final civiliansWin = state.civiliansWin;
    final voteResults = state.voteResults;

    buffer.writeln('🕵️ IMPOSTOR CRUCEÑO - Resultados 🕵️');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln();

    if (civiliansWin) {
      buffer.writeln('🎉 ¡GANARON LOS CIVILES! 🎉');
    } else {
      buffer.writeln('😈 ¡GANÓ EL IMPOSTOR! 😈');
    }
    buffer.writeln();

    final impostorNames = impostors.map((i) => i.name).join(', ');
    buffer.writeln('🎭 Impostor: $impostorNames');
    buffer.writeln('📝 Palabra: ${state.secretWord}');
    buffer.writeln('📂 Categoría: ${state.selectedCategory.icon} ${state.selectedCategory.name}');
    buffer.writeln();

    buffer.writeln('📊 Votos:');
    final sortedPlayers = List.of(state.players)
      ..sort((a, b) =>
          (voteResults[b.id] ?? 0).compareTo(voteResults[a.id] ?? 0));

    for (final p in sortedPlayers) {
      final votes = voteResults[p.id] ?? 0;
      final bar = '█' * votes + '░' * (state.players.length - 1 - votes);
      final marker = p.isImpostor ? ' *' : '';
      buffer.writeln('  ${p.name}$marker: $bar $votes');
    }

    buffer.writeln();
    buffer.writeln('👥 ${state.players.length} jugadores | '
        '⏱ ${state.roundTimeSeconds}s | '
        '🔄 ${state.totalRounds} rondas');
    buffer.writeln();
    buffer.writeln('Descargá Impostor Cruceño y jugá con tus amigos! 🇧🇴');

    return buffer.toString();
  }

  static Future<void> shareResult(GameState state) async {
    final text = buildShareText(state);
    await SharePlus.instance.share(
      ShareParams(text: text),
    );
  }
}
