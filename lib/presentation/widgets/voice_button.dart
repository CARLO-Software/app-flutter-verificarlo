import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:app_flutter_verificarlo/core/constants/app_colors.dart';

class VoiceButton extends StatefulWidget {
  final ValueChanged<String> onResult;
  final ValueChanged<String>? onPartialResult;
  final ValueChanged<bool>? onListeningChanged;

  const VoiceButton({
    super.key,
    required this.onResult,
    this.onPartialResult,
    this.onListeningChanged,
  });

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton> {
  final _speech = SpeechToText();
  bool _isListening = false;

  Future<void> _toggle() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      widget.onListeningChanged?.call(false);
      return;
    }

    final available = await _speech.initialize();
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Micrófono no disponible. Cierre la llamada e intente de nuevo.')),
        );
      }
      return;
    }

    setState(() => _isListening = true);
    widget.onListeningChanged?.call(true);
    await _speech.listen(
      listenOptions: SpeechListenOptions(localeId: 'es_PE'),
      onResult: (result) {
        if (result.finalResult) {
          widget.onResult(result.recognizedWords);
          setState(() => _isListening = false);
          widget.onListeningChanged?.call(false);
        } else {
          widget.onPartialResult?.call(result.recognizedWords);
        }
      },
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isListening ? Icons.mic : Icons.mic_none,
        color: _isListening ? AppColors.error : AppColors.textSecondary,
      ),
      onPressed: _toggle,
      tooltip: 'Dictado por voz',
      iconSize: 20,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: EdgeInsets.zero,
    );
  }
}
