import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class ActivityChip extends StatelessWidget {
  const ActivityChip({
    super.key,
    required this.activity,
  });

  final String? activity;

  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;
    return FittedBox(
      child: Chip(
        labelStyle: const TextStyle(
          color: Color.fromARGB(255, 247, 247, 247),
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: activity == 'walking'
            ? Theme.of(context).colorScheme.primaryContainer
            : activity == 'driving'
                ? Theme.of(context).colorScheme.secondaryContainer
                : activity == 'stationary'
                    ? Theme.of(context).colorScheme.tertiaryContainer
                    : activity == 'cycling'
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : activity == 'running'
                            ? Theme.of(context).colorScheme.tertiaryContainer
                            : Theme.of(context).colorScheme.primaryContainer,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        visualDensity: VisualDensity.compact,
        label: Text(
          activity!.capitalize,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: brightness == Brightness.light
                ? Theme.of(context).textTheme.bodyLarge!.color
                : null,
          ),
        ),
        avatar: activity == 'walking'
            ? Icon(
                Icons.directions_walk_rounded,
                color: brightness == Brightness.light
                    ? Theme.of(context).textTheme.bodyLarge!.color
                    : null,
                size: 18.0,
              )
            : activity == 'driving'
                ? Icon(
                    Icons.drive_eta_rounded,
                    color: brightness == Brightness.light
                        ? Theme.of(context).textTheme.bodyLarge!.color
                        : null,
                    size: 18.0,
                  )
                : activity == 'stationary'
                    ? Icon(
                        Icons.pause,
                        size: 18.0,
                        color: brightness == Brightness.light
                            ? Theme.of(context).textTheme.bodyLarge!.color
                            : null,
                      )
                    : activity == 'cycling'
                        ? Icon(
                            Icons.directions_bike_rounded,
                            size: 18.0,
                            color: brightness == Brightness.light
                                ? Theme.of(context).textTheme.bodyLarge!.color
                                : null,
                          )
                        : activity == 'running'
                            ? Icon(
                                Icons.directions_run_rounded,
                                size: 18.0,
                                color: brightness == Brightness.light
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color
                                    : null,
                              )
                            : const SizedBox(),
      ),
    );
  }
}
