import 'package:flutter/material.dart';

class WeatherInfoBox extends StatelessWidget {
  final String label;
  final String value;

  const WeatherInfoBox({
    required this.label,
    required this.value,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.080,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 152, 154, 155),
            Color.fromARGB(146, 55, 60, 62),
          ],
          begin: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Text(
            '$label: $value',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
