import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';

class SettingsSwitch extends StatelessWidget {
  const SettingsSwitch({
    super.key,
    required this.name,
    required this.icon,
    required this.iconBGColor,
    required this.onPressed,
    required this.iconColor,
    required this.value,
  });
  final String name;
  final IoniconsData icon;
  final bool value;
  final Color iconColor;
  final Color iconBGColor;
  final void Function(bool value) onPressed;
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
          // Text(
          //   value ? "Бар" : "Жоқ",
          //   style: TextStyle(
          //     fontSize: 16,
          //     color: Color.fromARGB(255, 126, 124, 124),
          //   ),
          // ),
          const SizedBox(width: 10),
          CupertinoSwitch(value: value, onChanged: onPressed),
        ],
      ),
    );
  }
}
