import 'package:flutter/material.dart';

class BouncingLoadingBar extends StatefulWidget {
  final Color color;

  const BouncingLoadingBar({
    super.key,
    this.color = Colors.pink,
  });

  @override
  State<BouncingLoadingBar> createState() => _BouncingLoadingBarState();
}

class _BouncingLoadingBarState extends State<BouncingLoadingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final barWidth = screenWidth / 5;

    return SizedBox(
      height: 2,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            color: Colors.white30,
          ),

          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final dx = _animation.value * (screenWidth - barWidth);
              return Positioned(
                left: dx,
                child: Container(
                  width: barWidth,
                  height: 2,
                  color: widget.color,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


