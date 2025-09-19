import 'dart:developer';
import 'dart:io';
import 'package:facelivenessdetection/facelivenessdetection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageCaptureExample extends StatefulWidget {
  const ImageCaptureExample({super.key});

  @override
  State<ImageCaptureExample> createState() => _ImageCaptureExampleState();
}

class _ImageCaptureExampleState extends State<ImageCaptureExample> {
  final List<Rulesets> _completedRuleset = [];
  final List<_CapturedImage> _capturedImages = [];
  final TextStyle _textStyle = const TextStyle();
  int _session = 0; // used to remount FaceDetectorView
  bool _isResetting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Detection with Image Capture'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Reset',
            icon: _isResetting ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ) : const Icon(Icons.refresh),
            onPressed: _isResetting ? null : _resetSession,
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final bool isWide = width >= 800;

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: isWide ? 720 : 560),
                        child: _isResetting 
                          ? const Center(child: CircularProgressIndicator())
                          : FaceDetectorView(
                              key: ValueKey(_session),
                          cameraSize: const Size(200, 200),
                          onSuccessValidation: (validated) {
                            // Do not show dialog automatically; keep UX unobtrusive
                            log('Face verification completed: $validated', name: 'Validation');
                          },
              onValidationDone: (controller) {
                return const Center(
                  child: Text(
                    'All rules completed!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                );
              },
              // Enable image capture
              enableImageCapture: true,
              onImageCaptured: (imagePath, rule) {
                setState(() {
                  _capturedImages.add(_CapturedImage(path: imagePath, rule: rule));
                });
                log('Image captured for ${_getRuleName(rule)}: $imagePath', name: 'ImageCapture');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Image captured for ${_getRuleName(rule)}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              onImageCaptureError: (error) {
                log('Image capture error: $error', name: 'ImageCapture');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Image capture error: $error'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
                          child: ({required countdown, required state, required hasFace}) => Column(
                            children: [
                              const SizedBox(height: 20),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    hasFace ? Icons.face : Icons.face_retouching_off,
                                    color: hasFace ? Colors.green : Colors.red,
                                    size: isWide ? 36 : 28,
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: AnimatedSize(
                                      duration: const Duration(milliseconds: 150),
                                      child: Text(
                                        hasFace ? 'User face found' : 'User face not found',
                                        style: _textStyle.copyWith(
                                          color: hasFace ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.w400,
                                          fontSize: isWide ? 14 : 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                getHintText(state),
                                textAlign: TextAlign.center,
                                style: _textStyle.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: isWide ? 22 : 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (countdown > 0)
                                Text.rich(
                                  textAlign: TextAlign.center,
                                  TextSpan(children: [
                                    const TextSpan(text: 'IN\n'),
                                    TextSpan(
                                      text: countdown.toString(),
                                      style: _textStyle.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: isWide ? 24 : 20,
                                      ),
                                    ),
                                  ]),
                                  style: _textStyle.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isWide ? 18 : 16,
                                  ),
                                )
                              else ...[
                                const SizedBox(height: 40),
                                const CupertinoActivityIndicator(),
                              ]
                            ],
                          ),
              onRulesetCompleted: (ruleset) {
                if (!_completedRuleset.contains(ruleset)) {
                  setState(() {
                    _completedRuleset.add(ruleset);
                  });
                }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Captured Images (${_capturedImages.length})',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (_capturedImages.isNotEmpty)
                          TextButton.icon(
                            onPressed: () => setState(() => _capturedImages.clear()),
                            icon: const Icon(Icons.delete_sweep_outlined),
                            label: const Text('Clear all'),
                          ),
                      ],
                    ),
                  ),
                ),
                if (_capturedImages.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text('No images captured yet', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = _capturedImages[index];
                          return _CapturedTile(
                            file: File(item.path),
                            label: _getRuleName(item.rule),
                            onDelete: () => setState(() => _capturedImages.removeAt(index)),
                          );
                        },
                        childCount: _capturedImages.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 160,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String getHintText(Rulesets state) {
    switch (state) {
      case Rulesets.smiling:
        return 'Please Smile';
      case Rulesets.blink:
        return 'Please Blink';
      case Rulesets.tiltUp:
        return 'Please Look Up';
      case Rulesets.tiltDown:
        return 'Please Look Down';
      case Rulesets.toLeft:
        return 'Please Look Left';
      case Rulesets.toRight:
        return 'Please Look Right';
    }
  }

  String _getRuleName(Rulesets rule) {
    switch (rule) {
      case Rulesets.smiling:
        return 'Smile';
      case Rulesets.blink:
        return 'Blink';
      case Rulesets.tiltUp:
        return 'Look Up';
      case Rulesets.tiltDown:
        return 'Look Down';
      case Rulesets.toLeft:
        return 'Look Left';
      case Rulesets.toRight:
        return 'Look Right';
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success!'),
        content: Text('Face verification completed successfully!\n\nCaptured ${_capturedImages.length} images.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetSession();
            },
            child: const Text('Start Over'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetSession() async {
    if (_isResetting) return;
    
    setState(() {
      _isResetting = true;
      _completedRuleset.clear();
      _capturedImages.clear();
    });
    
    // Wait for camera to dispose completely
    await Future.delayed(const Duration(milliseconds: 2000));
    
    setState(() {
      _session++;
      _isResetting = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session reset')),
      );
    }
  }
}

class _CapturedImage {
  final String path;
  final Rulesets rule;
  _CapturedImage({required this.path, required this.rule});
}

class _CapturedTile extends StatelessWidget {
  const _CapturedTile({required this.file, required this.label, required this.onDelete});

  final File file;
  final String label;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Use smaller cached dimensions for perf on thumbnails
          Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFFE0E0E0), child: Icon(Icons.broken_image)),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                radius: 14,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onDelete,
                  icon: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: Colors.black54,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
