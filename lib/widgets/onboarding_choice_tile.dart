import 'package:flutter/material.dart';

class OnboardingChoiceTile extends StatelessWidget {
  const OnboardingChoiceTile({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
    this.compact = false,
    this.leading,
    this.selectedColor = const Color(0xFFFF668B),
    this.selectedBackgroundColor = const Color(0xFFFFE6EE),
    this.unselectedBackgroundColor = const Color(0xFFF6F2F4),
  });

  final String label;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;
  final Widget? leading;
  final Color selectedColor;
  final Color selectedBackgroundColor;
  final Color unselectedBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      color: isSelected ? selectedColor : Colors.black,
      fontSize: compact ? 16 : 19,
      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
    );
    final labelColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, overflow: TextOverflow.visible, style: labelStyle),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(
              color: Color(0xFF676767),
              fontSize: 13,
            ),
          ),
        ],
      ],
    );

    return AnimatedScale(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      scale: isSelected ? 1.02 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: compact ? null : double.infinity,
          constraints: compact
              ? const BoxConstraints(minHeight: 52, minWidth: 128)
              : const BoxConstraints(minHeight: 64),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 16 : 18,
            vertical: compact ? 14 : 18,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? selectedBackgroundColor
                : unselectedBackgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? selectedColor : const Color(0xFFE9DCE2),
              width: 1.5,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: selectedColor.withValues(alpha: 0.16),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 10),
              ],
              if (compact) labelColumn else Expanded(child: labelColumn),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: isSelected
                    ? Padding(
                        key: const ValueKey('selected'),
                        padding: EdgeInsets.only(left: compact ? 8 : 12),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: selectedColor,
                          size: 22,
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingChoiceWrap extends StatelessWidget {
  const OnboardingChoiceWrap({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: children,
    );
  }
}

class OnboardingChoiceList extends StatelessWidget {
  const OnboardingChoiceList({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index != children.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}
