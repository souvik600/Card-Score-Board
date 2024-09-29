import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScoreScreen extends StatefulWidget {
  final String team_A_name;
  final String team_B_name;

  const ScoreScreen({
    Key? key,
    required this.team_A_name,
    required this.team_B_name,
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
  final List<int> numbers = [5, 7, 8, 9, 10,11 ,12 , 13];

  void checkForWin() {
    if (teamAScore >= 60) {
      showWinningDialog(teamName: widget.team_A_name, score: teamAScore);
    } else if (teamBScore >= 60) {
      showWinningDialog(teamName: widget.team_B_name, score: teamBScore);
    }
  }

  void showWinningDialog({required String teamName, required int score}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              const Image(
                image: AssetImage("assets/winner.png"),
                width: 60, // Adjust the width as needed
                height: 60, // Adjust the height as needed
              ),
              const SizedBox(width: 10), // Add space between the icon and title
              const Text("Congratulations!",style: TextStyle(color: Colors.green,fontWeight: FontWeight.w600),),
              SizedBox(height: 20,),
              Text("Win Team : $teamName",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 18),)
            ],
          ),
          content: Text("$teamName wins with a score of $score!"),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }


  void updateTeamAScore(int number) {
    setState(() {
      int change = isAddOperationA ? number : -number;
      teamAScore += change;
      scoreBoardListA.add(ScoreBoard(DateTime.now(), change));
    });

    // Scroll to the bottom after adding an item
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollControllerA.animateTo(
        _scrollControllerA.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // Check if team A has won
    checkForWin();
  }

  void updateTeamBScore(int number) {
    setState(() {
      int change = isAddOperationB ? number : -number;
      teamBScore += change;
      scoreBoardListB.add(ScoreBoard(DateTime.now(), change));
    });

    // Scroll to the bottom after adding an item
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollControllerB.animateTo(
        _scrollControllerB.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                setState(() {
                  final scoreEntry = scoreList[index];

                  if (isTeamA) {
                    // Update team A's main score when deleting
                    if (scoreEntry.scoreChange > 0) {
                      teamAScore -= scoreEntry.scoreChange;
                    } else {
                      teamAScore += (-scoreEntry.scoreChange);
                    }
                    scoreBoardListA.removeAt(index);
                  } else {
                    // Update team B's main score when deleting
                    if (scoreEntry.scoreChange > 0) {
                      teamBScore -= scoreEntry.scoreChange;
                    } else {
                      teamBScore += (-scoreEntry.scoreChange);
                    }
                    scoreBoardListB.removeAt(index);
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
        ),
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Container(
              height: 70,
              width: 120,
              decoration: BoxDecoration(
                color: teamColor,
                border: Border.all(color: Colors.white, width: 2),
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
            const SizedBox(height: 5),
            // Team Name
            Container(
              height: 40,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white54,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  teamName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            // Team Score List
            Expanded(
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(border: Border.all(
                  color: Colors.white,width: 2, // Change this to any color you like
                   // Border width
                ), color: Colors.white.withOpacity(0.5)),
                //color: Colors.green.withOpacity(.4),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: scoreList.length,
                  itemBuilder: (context, index) {
                    final scoreEntry = scoreList[index];
                    return Card(
                      child: ListTile(
                        title: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // Counter Number
                              Text(
                                '${index + 1}. ', // Counter Number
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              // Button Count Number
                              CircleAvatar(
                                radius: 16,  // Set the size of the CircleAvatar (increase/decrease as needed)
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
                          
                              const SizedBox(width: 1),
                              // Time
                              // Inside the ListTile for displaying the time
                              Text(
                                DateFormat('hh:mm:ss a').format(scoreEntry.time), // Time in 12-hour format with AM/PM
                                style: const TextStyle(fontSize: 10),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => onOperationPressed(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAddOperation ? Colors.green : Colors.grey,
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
                      backgroundColor: !isAddOperation ? Colors.red : Colors.grey,
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
                return Container(
                  height: 100, // Increased height for better visibility
                  child: ElevatedButton(
                    onPressed: () => onNumberPressed(numbers[index]),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(.6),
                      padding: const EdgeInsets.symmetric(vertical: 5), // Increased vertical padding
                      elevation: 5, // Optional: add elevation for better visibility
                    ),
                    child: Text(
                      '${numbers[index]}', // Display the number on the button
                      style: const TextStyle(fontSize: 20, color: Colors.black), // Increased font size
                    ),
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
  Widget build(BuildContext context) {
    return Scaffold(
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
              teamColor:  Color(0xFF38ABD3),
              gradientStart: Color(0xFFF1ADAF),
              gradientEnd: Color(0xFF2CA830),
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
              teamColor:  Color(0xFF38ABD3),
              gradientStart: Color(0xFF7BD77E),
              gradientEnd: Color(0xFFB95456),


              isTeamA: false, // Pass false for Team B
              scrollController: _scrollControllerB,
            ),
          ],
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
