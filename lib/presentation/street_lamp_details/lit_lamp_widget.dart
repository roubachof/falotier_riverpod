import 'package:falotier/domain/street_lamps/providers.dart';
import 'package:falotier/presentation/common/loading_states_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FlameAction { idle, turningOn, turningOff }

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
  FlameAction _action = FlameAction.idle;

  static const _turnOnFadeDuration = Duration(seconds: 5);
  static const _turnOnScaleDuration = Duration(seconds: 20);
  static const _turnOffDuration = Duration(seconds: 2);
  static const _pulseDuration = Duration(seconds: 2);

  @override
  Widget build(BuildContext context) {
    final isTransitioning = _action != FlameAction.idle;
    final showFlame = widget.isLit || isTransitioning;

    if (!showFlame) {
      return InkWell(
        onTap: _onTap,
        child: const SizedBox(
          height: 100,
          width: 80,
        ),
      );
    }

    return Transform.translate(
      offset: const Offset(20, 0),
      child: Opacity(
        opacity: 0.7,
        child: InkWell(
          onTap: isTransitioning ? null : _onTap,
          child: _buildFlame(),
        ),
      ),
    );
  }

  Widget _buildFlame() {
    final container = Container(
      height: 120,
      width: 120,
      decoration: _buildFlameDecoration(),
    );

    return switch (_action) {
      FlameAction.idle => container
          .animate(
            key: const Key('flame'),
            onPlay: (controller) => controller.loop(count: null, reverse: true),
          )
          .fade(
            duration: _pulseDuration,
            begin: 1.0,
            end: 0.7,
          )
          .scale(
            duration: _pulseDuration,
            begin: const Offset(0.5, 0.5),
            end: const Offset(1, 1),
          ),
      FlameAction.turningOn => container
          .animate(key: const Key('on'))
          .fade(
            duration: _turnOnFadeDuration,
            begin: 1.0,
            end: 0.2,
          )
          .scale(
            duration: _turnOnScaleDuration,
            begin: const Offset(0.2, 0.2),
            end: const Offset(10, 10),
          ),
      FlameAction.turningOff => container
          .animate(key: const Key('off'))
          .fade(
            duration: _turnOffDuration,
            begin: 1.0,
            end: 0.2,
          )
          .scale(
            duration: _turnOffDuration,
            begin: const Offset(1, 1),
            end: const Offset(0.2, 0.2),
          ),
    };
  }

  Future<void> _onTap() async {
    Feedback.forTap(context);
    setState(() {
      _action =
          widget.isLit ? FlameAction.turningOff : FlameAction.turningOn;
    });
    try {
      await ref
          .read(streetLampStoreProvider.notifier)
          .toggle(widget.id);
    } catch (e, t) {
      handleCommandError(context, e, t);
    } finally {
      if (mounted) {
        setState(() => _action = FlameAction.idle);
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
