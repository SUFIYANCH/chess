import 'package:chess/screens/game_board.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/homeimg.jpg",
            height: MediaQuery.sizeOf(context).height,
            fit: BoxFit.cover,
          ),
          Positioned(
            right: 30,
            left: 30,
            top: 100,
            child: Text(
              "\"Chess is war over the board. The object is to crush the opponent’s ego\"",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            right: 40,
            left: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffc19553),
                  foregroundColor: Colors.black,
                  fixedSize: Size(500, 45)),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameBoard(),
                    ),
                    (route) => false);
              },
              child: const Text(
                'New Game',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
