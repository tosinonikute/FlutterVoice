import 'package:flutter/material.dart';

class ExpandingFabMenu extends StatefulWidget {
  final List<FabMenuItem> items;
  final VoidCallback? onRecordPressed;

  const ExpandingFabMenu({
    super.key,
    required this.items,
    this.onRecordPressed,
  });

  @override
  State<ExpandingFabMenu> createState() => _ExpandingFabMenuState();
}

class _ExpandingFabMenuState extends State<ExpandingFabMenu> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _translateButtons;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _translateButtons = List.generate(
      widget.items.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: -1.0,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            0.5 + index * 0.1,
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.translationValues(
                  0.0,
                  _translateButtons[index].value * 80.0,
                  0.0,
                ),
                child: Opacity(
                  opacity: _isOpen ? 1.0 : 0.0,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton(
                heroTag: item.label,
                backgroundColor: item.backgroundColor ?? Theme.of(context).primaryColor,
                foregroundColor: item.foregroundColor ?? Colors.white,
                mini: true,
                onPressed: item.onPressed,
                child: Icon(item.icon),
              ),
            ),
          );
        }).toList(),
        FloatingActionButton(
          heroTag: 'main',
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          onPressed: _toggle,
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _animationController,
          ),
        ),
      ],
    );
  }
}

class FabMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  FabMenuItem({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });
} 