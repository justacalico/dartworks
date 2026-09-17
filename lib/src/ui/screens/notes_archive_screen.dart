import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../data/catalog.dart';
import '../../data/notes.dart';
import '../../theme.dart';
import '../widgets/neon_panel.dart';
import '../widgets/void_backdrop.dart';

/// Codex of every recovered MonoChat clipboard. Unfound notes stay
/// redacted so the archive doubles as a completion checklist.
class NotesArchiveScreen extends StatelessWidget {
  const NotesArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = AppScope.progressOf(context);
    final found = progress.foundNotes;

    return Scaffold(
      body: VoidBackdrop(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: DwColors.textDim),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    const Text('MONOCHATS // RECOVERED DATA',
                        style: DwText.h2),
                    const Spacer(),
                    Text(
                      '${found.length}/${kNotes.length}',
                      style: DwText.h3.copyWith(color: DwColors.neonCyan),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: kNotes.length,
                  itemBuilder: (context, i) {
                    final note = kNotes[i];
                    return found.contains(note.id)
                        ? _NoteCard(note: note)
                        : _RedactedCard(note: note);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final NoteInfo note;

  @override
  Widget build(BuildContext context) {
    final level = levelById(note.levelId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: NeonPanel(
        accent: DwColors.neonCyan,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(note.title, style: DwText.h3),
                ),
                Text(
                  level?.title ?? note.levelId.toUpperCase(),
                  style: DwText.caption,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'FROM: ${note.author}',
              style: DwText.caption.copyWith(color: DwColors.voidPurple),
            ),
            const SizedBox(height: 10),
            Text(note.body, style: DwText.bodyDim),
          ],
        ),
      ),
    );
  }
}

class _RedactedCard extends StatelessWidget {
  const _RedactedCard({required this.note});

  final NoteInfo note;

  @override
  Widget build(BuildContext context) {
    final level = levelById(note.levelId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: NeonPanel(
        accent: DwColors.textFaint,
        child: Row(
          children: [
            const Icon(Icons.lock_outline,
                size: 16, color: DwColors.textFaint),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '[DATA FRAGMENT] - located in ${level?.title ?? note.levelId}',
                style: DwText.bodyDim.copyWith(color: DwColors.textFaint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
