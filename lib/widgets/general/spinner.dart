import "package:flutter/material.dart";

import 'loading_shapes/loading_shapes.dart';
import 'loading_shapes/loading_shapes_style.dart';

/// Indefinite waiting indicator
class Spinner extends StatelessWidget {
  final bool center;

  const Spinner({super.key, this.center = false});
  const Spinner.center({super.key}) : center = true;

  @override
  Widget build(BuildContext context) {
    final child = LoadingShapes(
      style: LoadingShapesStyle(
        size: 40,
        color: Theme.of(context).colorScheme.primary,
      ),
    );

    if (center) {
      return Center(child: child);
    }

    return child;
  }
}
