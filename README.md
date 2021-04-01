# Matching Game
Simple matching game on the BASYS 3 development board

This game creates a pattern on the 7 seg displays on the BASYS 3 board that the players have to match by pressing the center button. 
The switches on the board are the inputs to the game and control the assigned 7 seg displays for that player.
After the player flips all the switches to create the pattern, they must press their assigned button to enter their answer.
The LED strip on the board acts as a timer.
The round ends when either both players have entered their answer or the timer runs out.
It then finds if the first player to enter is correct, and if so, adds a point to their score.
If the first player to enter is not correct, it checks the second player's entry and adds a point if correct. 
It then displays each player's score on the 7 seg displays.
Press center button again to play a new round. 
The first player to 10 points wins.
