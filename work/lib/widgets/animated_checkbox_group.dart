import 'package:flutter/material.dart';

class AnimatedCheckboxGroup extends StatefulWidget {
  final List<String> labels;
  final void Function(String label, bool value) onChanged;
  final Map<String, bool> values;

  const AnimatedCheckboxGroup({
    super.key,
    required this.labels,
    required this.onChanged,
    required this.values,
  });

  @override
  State<AnimatedCheckboxGroup> createState() => _AnimatedCheckboxGroupState();
}

class _AnimatedCheckboxGroupState extends State<AnimatedCheckboxGroup> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: widget.labels.map((label) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 200),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.values[label] == true
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      widget.onChanged(label, !(widget.values[label] ?? false));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: widget.values[label] == true
                                  ? Theme.of(context).primaryColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: widget.values[label] == true
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            width: 20,
                            height: 20,
                            child: widget.values[label] == true
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: widget.values[label] == true
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: widget.values[label] == true
                                  ? Theme.of(context).primaryColor
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}