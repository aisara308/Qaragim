import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:qaragim/ui/settings/forward_button.dart';

class SettingsItem extends StatelessWidget {
  const SettingsItem({
    super.key,
    required this.name,
    required this.definition,
    required this.icon,
    required this.iconBGColor,
    this.onPressed,
    required this.iconColor,
  });
  final String name;
  final String definition;
  final IoniconsData icon;
  final Color iconColor;
  final Color iconBGColor;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBGColor,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 20),
          Text(
            name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: const Color.fromRGBO(48, 37, 62, 1),
            ),
          ),
          const Spacer(),
          Text(
            definition,
            style: TextStyle(
              fontSize: 16,
              color: const Color.fromRGBO(48, 37, 62, 0.7),
            ),
          ),
          const SizedBox(width: 10),
          forward_button(onPressed: onPressed),
        ],
      ),
    );
  }
}
