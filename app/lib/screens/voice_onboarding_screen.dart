import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../data/repository_provider.dart';
import '../l10n.dart';
import '../theme.dart';
import 'home_shell.dart';

/// Sprach-Onboarding: drei Fragen, Antworten per On-Device-Spracherkennung
/// (Audio verlässt das Gerät nicht). Transkript bleibt editierbar.
class VoiceOnboardingScreen extends StatefulWidget {
  const VoiceOnboardingScreen({super.key});

  @override
  State<VoiceOnboardingScreen> createState() => _VoiceOnboardingScreenState();
}

class _VoiceOnboardingScreenState extends State<VoiceOnboardingScreen> {
  final _speech = SpeechToText();
  final _answer = TextEditingController();
  final _answers = <String, String>{};
  bool _speechAvailable = false;
  bool _listening = false;
  int _step = 0;

  List<(String, String)> get _questions => [
        ('birth_year', t('In welchem Jahr bist du geboren?', 'What year were you born?')),
        (
          'family_status',
          t('Wie ist deine Lebenssituation – alleinstehend, Paar oder Familie?',
              'What is your family status – single, couple or family?')
        ),
        ('profession', t('Was arbeitest du?', 'What do you do for a living?')),
      ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      final ok = await _speech.initialize();
      if (mounted) setState(() => _speechAvailable = ok);
    } catch (_) {
      if (mounted) setState(() => _speechAvailable = false);
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _answer.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    setState(() => _listening = true);
    await _speech.listen(
      listenOptions:
          SpeechListenOptions(localeId: isEnglish ? 'en_US' : 'de_DE'),
      onResult: (result) {
        setState(() => _answer.text = result.recognizedWords);
      },
    );
  }

  Future<void> _next() async {
    await _speech.stop();
    _answers[_questions[_step].$1] = _answer.text.trim();
    _answer.clear();
    if (_step < _questions.length - 1) {
      setState(() {
        _step++;
        _listening = false;
      });
      return;
    }
    // Antworten in Profilfelder übersetzen (best effort).
    final profile = <String, dynamic>{};
    final year = RegExp(r'(19|20)\d{2}')
        .firstMatch(_answers['birth_year'] ?? '')
        ?.group(0);
    if (year != null) profile['birth_year'] = int.parse(year);
    final family = (_answers['family_status'] ?? '').toLowerCase();
    if (family.contains('familie') || family.contains('family')) {
      profile['family_status'] = 'familie';
    } else if (family.contains('paar') ||
        family.contains('couple') ||
        family.contains('partner')) {
      profile['family_status'] = 'paar';
    } else if (family.isNotEmpty) {
      profile['family_status'] = 'single';
    }
    if ((_answers['profession'] ?? '').isNotEmpty) {
      profile['profession'] = _answers['profession'];
    }
    try {
      await contractsRepository().saveProfile(profile);
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeShell()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.accentColor;
    final (_, question) = _questions[_step];
    return Scaffold(
      appBar: AppBar(
        title: Text(t('Erzähl es uns', 'Tell us'),
            style: const TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: _next,
            child: Text(t('Weiter', 'Next'),
                style: TextStyle(color: context.mutedColor)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('Frage ${_step + 1} von ${_questions.length}',
                  'Question ${_step + 1} of ${_questions.length}'),
              style: TextStyle(fontSize: 13, color: context.mutedColor),
            ),
            const SizedBox(height: 8),
            Text(question,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w600, height: 1.3)),
            const SizedBox(height: 24),
            Center(
              child: GestureDetector(
                onTap: _speechAvailable ? _toggleListening : null,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _listening ? accent : FinColors.greenSoft,
                  ),
                  child: Icon(
                    _listening ? Icons.stop : Icons.mic_none,
                    size: 36,
                    color: _listening ? Colors.white : FinColors.greenDark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                !_speechAvailable
                    ? t('Spracherkennung nicht verfügbar — bitte tippen.',
                        'Speech recognition unavailable — please type.')
                    : _listening
                        ? t('Ich höre zu…', 'Listening…')
                        : t('Tippe aufs Mikrofon und sprich.',
                            'Tap the microphone and speak.'),
                style: TextStyle(fontSize: 13, color: context.mutedColor),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _answer,
              decoration: InputDecoration(
                labelText: t('Deine Antwort', 'Your answer'),
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14))),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _next,
              child: Text(_step < _questions.length - 1
                  ? t('Weiter', 'Next')
                  : t('Fertig', 'Done')),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                t('Audio wird nur auf deinem Gerät verarbeitet.',
                    'Audio is processed on your device only.'),
                style: TextStyle(fontSize: 12, color: context.mutedColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
