//import 'package:app_minimizer/app_minimizer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScoreScreen extends StatefulWidget {
  final String team_A_name;
  final String team_B_name;
  final int team_game_over;

  const ScoreScreen({
    Key? key,
    required this.team_A_name,
    required this.team_B_name,
    required this.team_game_over,
  }) : super(key: key);

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  // Team A Variables
  int teamAScore = 0;
  List<ScoreBoard> scoreBoardListA = [];
  bool isAddOperationA = true; // true for add, false for subtract

  // Team B Variables
  int teamBScore = 0;
  List<ScoreBoard> scoreBoardListB = [];
  bool isAddOperationB = true; // true for add, false for subtract

  // Scroll Controllers for both teams
  final ScrollController _scrollControllerA = ScrollController();
  final ScrollController _scrollControllerB = ScrollController();

  // Number Buttons
  final List<int> numbers = [5, 7, 8, 9, 10, 11, 12, 13];

  // Flag to indicate if the game is over
  bool isGameOver = false;

  // Function to check for game over condition
  void checkForWin() {
    if (isGameOver) return; // If game is already over, do nothing

    if (teamAScore >= widget.team_game_over) {
      setState(() {
        isGameOver = true;
      });
      showWinningDialog(teamName: widget.team_A_name, score: teamAScore);
    } else if (teamBScore >= widget.team_game_over) {
      setState(() {
        isGameOver = true;
      });
      showWinningDialog(teamName: widget.team_B_name, score: teamBScore);
    }
  }

  // Function to show the winning dialog
  void showWinningDialog({required String teamName, required int score}) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents dialog from closing on tap outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              const Image(
                image: AssetImage("assets/winner.png"),
                width: 60,
                height: 60,
              ),
              const SizedBox(height: 10),
              const Text(
                "Congratulations!",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Winning Team: $teamName",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            "$teamName wins with a score of $score!",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
                ElevatedButton(
                  child: const Text(
                    "New Game",
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).pop(); // Close the ScoreScreen
                    // Optionally, you can reset the game or navigate away
                  },
                ),

              ],
            ),
          ],
        );
      },
    );
  }

  // Updating Team A score
  void updateTeamAScore(int number) {
    if (isGameOver) return; // Prevent score updates if game is over

    setState(() {
      int change = isAddOperationA ? number : -number;
      teamAScore += change;
      scoreBoardListA.add(ScoreBoard(DateTime.now(), change));
    });

    // Scroll to the bottom after adding an item
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollControllerA.hasClients) {
        _scrollControllerA.animateTo(
          _scrollControllerA.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Check if team A has won
    checkForWin();
  }

  // Updating Team B score
  void updateTeamBScore(int number) {
    if (isGameOver) return; // Prevent score updates if game is over

    setState(() {
      int change = isAddOperationB ? number : -number;
      teamBScore += change;
      scoreBoardListB.add(ScoreBoard(DateTime.now(), change));
    });

    // Scroll to the bottom after adding an item
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollControllerB.hasClients) {
        _scrollControllerB.animateTo(
          _scrollControllerB.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Check if team B has won
    checkForWin();
  }

  // Function to handle long-press delete with confirmation dialog
  void showDeleteConfirmation({
    required int index,
    required List<ScoreBoard> scoreList,
    required bool isTeamA,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Entry"),
          content: const Text("Do you want to delete this score entry?"),
          actions: [
            TextButton(
              child: const Text(
                "Cancel",
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text(
                "Delete",
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
              onPressed: () {
                setState(() {
                  final scoreEntry = scoreList[index];

                  if (isTeamA) {
                    // Update team A's main score when deleting
                    teamAScore -= scoreEntry.scoreChange;
                    scoreBoardListA.removeAt(index);
                  } else {
                    // Update team B's main score when deleting
                    teamBScore -= scoreEntry.scoreChange;
                    scoreBoardListB.removeAt(index);
                  }

                  // Reset game over flag if necessary
                  if (isGameOver) {
                    isGameOver = false;
                  }
                });

                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Widget to build each team's section
  Widget buildTeamSection({
    required String teamName,
    required int teamScore,
    required List<ScoreBoard> scoreList,
    required bool isAddOperation,
    required Function(int) onNumberPressed,
    required Function(bool) onOperationPressed,
    required Color teamColor,
    required Color gradientStart,
    required Color gradientEnd,
    required bool isTeamA, // Flag to identify Team A or B
    required ScrollController scrollController,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [gradientStart, gradientEnd],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Team Score Display
            Container(
              height: 70,
              width: 120,
              decoration: BoxDecoration(
                color: teamColor,
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$teamScore',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Team Name
            Container(
              height: 40,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white54,
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  teamName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Team Score List
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: scoreList.isEmpty
                    ? const Center(
                  child: Text(
                    "No Scores Yet",
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                )
                    : ListView.builder(
                  controller: scrollController,
                  itemCount: scoreList.length,
                  itemBuilder: (context, index) {
                    final scoreEntry = scoreList[index];
                    return Card(
                      color: scoreEntry.scoreChange >= 0
                          ? Colors.green[100]
                          : Colors.red[100],
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // Counter Number
                              Text(
                                '${index + 1}. ',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              // Score Change
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: scoreEntry.scoreChange >= 0
                                    ? Colors.green
                                    : Colors.red,
                                child: Text(
                                  '${scoreEntry.scoreChange >= 0 ? '+' : ''}${scoreEntry.scoreChange}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              // Time
                              Text(
                                DateFormat('hh:mm:ss a').format(scoreEntry.time),
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        onLongPress: () {
                          // Show the confirmation dialog on long press
                          showDeleteConfirmation(
                            index: index,
                            scoreList: scoreList,
                            isTeamA: isTeamA,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Operation Buttons (+ and -)
            Container(
              color: Colors.white70,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => onOperationPressed(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isAddOperation ? Colors.green : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Text(
                      '+',
                      style: TextStyle(fontSize: 28, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => onOperationPressed(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      !isAddOperation ? Colors.red : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Text(
                      '-',
                      style: TextStyle(fontSize: 28, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Number Buttons Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.6, // Adjust this for button size
              ),
              itemCount: numbers.length,
              itemBuilder: (context, index) {
                return ElevatedButton(
                  onPressed: () => onNumberPressed(numbers[index]),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '${numbers[index]}',
                    style:
                    const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollControllerA.dispose();
    _scrollControllerB.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Minimize the app when back button is pressed
        //FlutterAppMinimizer.minimize();
        return false; // Prevents the default back button behavior
      },
      child: Scaffold(
        backgroundColor: Colors.transparent, // To allow gradient background
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFFFAC99D),
                Color(0xFFFAF0D7),
              ],
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Team A Section
                buildTeamSection(
                  teamName: widget.team_A_name,
                  teamScore: teamAScore,
                  scoreList: scoreBoardListA,
                  isAddOperation: isAddOperationA,
                  onNumberPressed: updateTeamAScore,
                  onOperationPressed: (isAdd) {
                    setState(() {
                      isAddOperationA = isAdd;
                    });
                  },
                  teamColor: const Color(0xFF38ABD3),
                  gradientStart: const Color(0xFFF1ADAF),
                  gradientEnd: const Color(0xFF2CA830),
                  scrollController: _scrollControllerA,
                  isTeamA: true, // Pass true for Team A
                ),
                // Team B Section
                buildTeamSection(
                  teamName: widget.team_B_name,
                  teamScore: teamBScore,
                  scoreList: scoreBoardListB,
                  isAddOperation: isAddOperationB,
                  onNumberPressed: updateTeamBScore,
                  onOperationPressed: (isAdd) {
                    setState(() {
                      isAddOperationB = isAdd;
                    });
                  },
                  teamColor: const Color(0xFF38ABD3),
                  gradientStart: const Color(0xFF7BD77E),
                  gradientEnd: const Color(0xFFB95456),
                  scrollController: _scrollControllerB,
                  isTeamA: false, // Pass false for Team B
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ScoreBoard {
  DateTime time;
  int scoreChange;
  ScoreBoard(this.time, this.scoreChange);
}
