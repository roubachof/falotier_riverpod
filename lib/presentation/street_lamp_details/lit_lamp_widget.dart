import 'package:falotier/presentation/common/loading_states_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

class LitLampWidget extends ConsumerStatefulWidget {
  const LitLampWidget({
    super.key,
    required this.id,
    required this.isLit,
  });

  final String id;
  final bool isLit;

  @override
  ConsumerState<LitLampWidget> createState() => _LitLampWidgetState();
}

class _LitLampWidgetState extends ConsumerState<LitLampWidget> {
  bool _isLoading = false;
  bool _isTurningOff = false;
  bool _isTurningOn = false;

  @override
  Widget build(BuildContext context) {
    if (_isLoading || widget.isLit) {
      return Transform.translate(
        offset: const Offset(20, 0),
        child: Opacity(
          opacity: 0.7,
          child: InkWell(
            onTap: !_isLoading ? _onTap : null,
            child: _getAnimatedContainer(),
          ),
        ),
      );
    }

    return InkWell(
      onTap: _onTap,
      child: const SizedBox(
        height: 100,
        width: 80,
      ),
    );
  }

  _getAnimatedContainer() {
    final container = Container(
      height: 120,
      width: 120,
      decoration: _buildFlameDecoration(),
    );

    if (_isTurningOff) {
      return container
          .animate(key: const Key('off'))
          .fade(
            duration: const Duration(milliseconds: 2000),
            begin: 1.0,
            end: 0.2,
          )
          .scale(
            duration: const Duration(milliseconds: 2000),
            begin: const Offset(1, 1),
            end: const Offset(0.2, 0.2),
          );
    }

    if (_isTurningOn) {
      return container
          .animate(key: const Key('on'))
          .fade(
            duration: const Duration(milliseconds: 5000),
            begin: 1,
            end: 0.2,
          )
          .scale(
            duration: const Duration(milliseconds: 20000),
            begin: const Offset(0.2, 0.2),
            end: const Offset(10, 10),
          );
    }

    return container
        .animate(
            key: const Key('flame'),
            onPlay: (controller) => controller.loop(count: null, reverse: true))
        .fade(
          duration: const Duration(milliseconds: 2000),
          begin: 1.0,
          end: 0.7,
        )
        .scale(
          duration: const Duration(milliseconds: 2000),
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
        );
  }

  _onTap() async {
    Feedback.forTap(context);
    try {
      if (widget.isLit) {
        _isTurningOff = true;
      } else {
        _isTurningOn = true;
      }

      setState(() {
        _isLoading = true;
      });

      await ref.read(lampDetailsProvider(lampId: widget.id).notifier).toggle();
    } catch (e, t) {
      handleCommandError(context, e, t);
    } finally {
      _isTurningOff = _isTurningOn = false;
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  BoxDecoration _buildFlameDecoration() {
    return BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(60)),
        gradient: RadialGradient(
          radius: 0.5,
          focal: const Alignment(0, 0.5),
          colors: [
            const Color(0xFFF9EFA9).withOpacity(0.8),
            const Color(0xFFF9EFA9).withOpacity(0.6),
            const Color(0xFFFFFFDF).withOpacity(0.2),
            const Color(0xFFFFFFDF).withOpacity(0.05),
          ],
          stops: const [
            0.20,
            0.50,
            0.80,
            0.9,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFD69455),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ]);
  }
}
