import 'package:flutter/material.dart';
import '../features/handle_description_updates.dart';

class AnimatedDescriptionsList extends StatefulWidget {
  final List<String> descriptions;
  final VoidCallback onClose;

  final Function(String) onSelect;

  const AnimatedDescriptionsList({
    super.key,
    required this.descriptions,
    required this.onClose,
    required this.onSelect,
  });

  @override
  State<AnimatedDescriptionsList> createState() => _AnimatedDescriptionsListState();
}

class _AnimatedDescriptionsListState extends State<AnimatedDescriptionsList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Dialog(
              backgroundColor: const Color(0xFF2C2C2C),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Project Descriptions',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              _controller.reverse().then((_) => widget.onClose());
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.grey),
                    Flexible(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: widget.descriptions.length,
                        itemBuilder: (context, index) {
                          return TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 200 + (index * 50)),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: GestureDetector(
                              onTap: () {
                                final selectedDescription = widget.descriptions[index];
                                // Update the description through the handler
                                DescriptionUpdateHandler().updateDescription(selectedDescription);
                                widget.onSelect(selectedDescription);
                                widget.onClose();
                              },
                              child: Card(
                                color: const Color(0xFF3D3D3D),
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                child: ListTile(
                                  title: Text(
                                    widget.descriptions[index],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
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
  }
}
