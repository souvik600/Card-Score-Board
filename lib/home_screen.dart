import 'package:card_score_board/score_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  // Controllers to capture user input for team names.
  final TextEditingController _teamAController = TextEditingController();
  final TextEditingController _teamBController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFFF8F3EF),
                Color(0xFFF6D2D2),
              ]),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0,right: 16,top: 100),
            child: Column(
              children: [
                // Input for Team A Name
                TextField(
                  controller: _teamAController,
                  decoration: const InputDecoration(
                    labelText: 'Team A Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                // Input for Team B Name
                TextField(
                  controller: _teamBController,
                  decoration: const InputDecoration(
                    labelText: 'Team B Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 40),
                // "OK" Button to navigate to ScoreScreen
                ElevatedButton(
                  onPressed: () {
                    String teamA = _teamAController.text.trim();
                    String teamB = _teamBController.text.trim();

                    // Validate that both team names are entered
                    if (teamA.isEmpty || teamB.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter both team names.'),
                        ),
                      );
                      return;
                    }

                    // Navigate to ScoreScreen with entered team names
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScoreScreen(
                          team_A_name: teamA,
                          team_B_name: teamB,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}