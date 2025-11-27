import 'package:flutter/material.dart';

class PnuLoader extends StatelessWidget {
  const PnuLoader({super.key, this.size = 140, this.logoSize = 100});

  final double size;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: size - 20,
              width: size - 20,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation(color.withValues(alpha: 0.85)),
              ),
            ),
            Image.asset('assets/images/pnu-logo.png', height: logoSize),
          ],
        ),
      ),
    );
  }
}
