import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class VoiceRecorderWidget extends StatefulWidget {
  final Function(File? audioFile) onAudioRecorded;

  const VoiceRecorderWidget({
    super.key,
    required this.onAudioRecorded,
  });

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget> {
  // Recorder and Player instances
  late final AudioRecorder _audioRecorder;
  late final AudioPlayer _audioPlayer;

  // Recording State
  bool _isRecording = false;
  int _recordDuration = 0;
  Timer? _recordTimer;
  String? _recordedFilePath;

  // Playback State
  bool _isPlaying = false;
  Duration _playbackPosition = Duration.zero;
  Duration _playbackDuration = Duration.zero;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();

    // Set up player listeners
    _positionSubscription = _audioPlayer.onPositionChanged.listen((pos) {
      setState(() {
        _playbackPosition = pos;
      });
    });

    _durationSubscription = _audioPlayer.onDurationChanged.listen((dur) {
      setState(() {
        _playbackDuration = dur;
      });
    });

    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Helper to format duration to mm:ss
  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Helper to format Duration object
  String _formatDurationObj(Duration duration) {
    return _formatDuration(duration.inSeconds);
  }

  // Start Audio Recording
  Future<void> _startRecording() async {
    try {
      // Explicitly request microphone permission (required on real iOS devices)
      final hasPermission = await _audioRecorder.hasPermission();

      if (!hasPermission) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Microphone Access Required'),
            content: const Text(
              'This app needs microphone access to record a voice note. '
              'Please enable it in Settings → Privacy & Security → Microphone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final path =
          '${tempDir.path}/service_request_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // Configure recorder
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      setState(() {
        _isRecording = true;
        _recordDuration = 0;
        _recordedFilePath = null;
      });

      // Notify parent that no file is ready yet
      widget.onAudioRecorded(null);

      // Timer to count up to 60 seconds
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordDuration++;
        });

        if (_recordDuration >= 60) {
          _stopRecording();
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting recording: $e')),
      );
    }
  }

  // Stop Audio Recording
  Future<void> _stopRecording() async {
    _recordTimer?.cancel();
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordedFilePath = path;
      });

      if (path != null) {
        widget.onAudioRecorded(File(path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error stopping recording: $e')),
      );
    }
  }

  // Cancel/Discard Recording while recording
  Future<void> _cancelRecording() async {
    _recordTimer?.cancel();
    try {
      await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordDuration = 0;
        _recordedFilePath = null;
      });
      widget.onAudioRecorded(null);
    } catch (_) {}
  }

  // Discard Recorded Audio
  Future<void> _deleteRecording() async {
    await _stopPlayback();
    if (_recordedFilePath != null) {
      try {
        final file = File(_recordedFilePath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }
    setState(() {
      _recordedFilePath = null;
      _playbackPosition = Duration.zero;
      _playbackDuration = Duration.zero;
    });
    widget.onAudioRecorded(null);
  }

  // Playback Control
  Future<void> _togglePlayback() async {
    if (_recordedFilePath == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(DeviceFileSource(_recordedFilePath!));
    }
  }

  Future<void> _stopPlayback() async {
    await _audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    // State 1: We have a recorded file ready
    if (_recordedFilePath != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            // Play / Pause Button
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                color: primaryColor,
                size: 38,
              ),
              onPressed: _togglePlayback,
            ),
            const SizedBox(width: 4),
            // Progress Bar / Slider
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      activeTrackColor: primaryColor,
                      inactiveTrackColor: Colors.grey.shade200,
                      thumbColor: primaryColor,
                      trackHeight: 3.0,
                    ),
                    child: Slider(
                      min: 0.0,
                      max: _playbackDuration.inMilliseconds.toDouble() > 0
                          ? _playbackDuration.inMilliseconds.toDouble()
                          : 1.0,
                      value: _playbackPosition.inMilliseconds.toDouble().clamp(
                            0.0,
                            _playbackDuration.inMilliseconds.toDouble() > 0
                                ? _playbackDuration.inMilliseconds.toDouble()
                                : 1.0,
                          ),
                      onChanged: (val) async {
                        await _audioPlayer.seek(Duration(milliseconds: val.toInt()));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDurationObj(_playbackPosition),
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                        ),
                        Text(
                          _formatDurationObj(_playbackDuration),
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 24),
              onPressed: _deleteRecording,
            ),
          ],
        ),
      );
    }

    // State 2: Actively recording
    if (_isRecording) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            // Pulse Red Dot
            const _BlinkingRedDot(),
            const SizedBox(width: 12),
            // Timer
            Text(
              _formatDuration(_recordDuration),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '/ 01:00',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            // Cancel Recording
            TextButton(
              onPressed: _cancelRecording,
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(width: 8),
            // Stop & Save Button
            ElevatedButton(
              onPressed: _stopRecording,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
                backgroundColor: Colors.red,
              ),
              child: const Icon(Icons.stop_rounded, color: Colors.white, size: 20),
            ),
          ],
        ),
      );
    }

    // State 3: Neutral state (Tap to record)
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _startRecording,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(Icons.mic_none_rounded, size: 36, color: primaryColor),
            const SizedBox(height: 10),
            const Text(
              'Tap to Record Voice Note',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Upto 1 minute recording allowed',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlinkingRedDot extends StatefulWidget {
  const _BlinkingRedDot();

  @override
  State<_BlinkingRedDot> createState() => _BlinkingRedDotState();
}

class _BlinkingRedDotState extends State<_BlinkingRedDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
