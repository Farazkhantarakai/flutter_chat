import 'package:flutter/material.dart';

class NoWidget extends StatelessWidget {
  const NoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: GestureDetector(
            onTap: () {},
            child: const Icon(
              Icons.add,
              color: Colors.grey,
              size: 50,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const Text(
          'To Create new Groups Click on the plus button ',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
