MTRX2700 Lab1 Group1
Members:
Jack Allsopp
James Calfas
Yujiao Cao


Exercise 1: Memory and pointers
commited by: Jack Allsopp, James Calfas, Yujiao Cao

In this exercise we need to alter the case of the characters of a pre-defined string stored in memory. All the tasks are combined in one file named “Exercise 1”. In the ASCII table we can check that the difference between an uppercase character and a lowercase character is $20, which is: Upper - $20 = Lower. And the middle value for checking if it is higher or lower is $60, space character is $20 and a full stop is $56.
Task 1 & 2
In Task 1, the character that has an ASCII value less than $60 (meaning that it’s upper case) will be passed to a function called “makeLower”. Likewise, in Task 2, upper case character will be passed to “makeHigher”. Afterwards, they will be stored into “output_string”.
Task 3
By checking the first latter then every letter after space, the lowercase letter will be capitalised. (assuming there is always a space character before a word)
Task 4
A full stop is $56, and whenever the value in the register is $56, will be branching to check if there is a space after that, then add one if there’s none. After the space, will be the character that needs to be capitalised.

  1.	Main functions:
ONELowerCase --- Checking if the character is in upper case, if yes, branches to makeLower
TWOmakeHigher --- Checking if the character is in lower case, if yes, branches to makeHigher
THREEfirstLetter --- To capitalise the first letter of a word
FOURNormalText --- Make the First letter of each sentence uppercase
And throughout these functions, they are always checking for the space and full stop character since we do not want to change them, so they will be passed to the “comeBack” to be stored.
  2.	Other functions:
innerLoop --- load the next character to the register. 
comeBack --- store the changed/unchanged character, then branches to innerLoop to load the next character 
checkForSpace --- Check the next letter for a space and add one if none            
space_after_fullstop --- If there is no space character after a full stop, go on to make a space in output
newWord --- Make the first letter after a space an Uppercase letter
nextCharacter -- Quick store in output string without returning to start
finish --- to end the programme
  3.	Instructions:
At the end of the “innerLoop”, choose the desired routine from the four main functions: ONELowerCase, TWOmakeHigher, THREEfirstLetter, FOURNormalText


Exercise 2: Digital Input/Output
commited by: James Calfas, Yujiao Cao

This exercise configures the 7-segment display on the board to display desired information.
The 5 tasks are interpretated in separate files: 
Exercise 2.1, Exercise 2.2, Exercise 2.3, Exercise 2.4, Exercise 2.5
Task 1
To light up all the 4 numerical characters, the process is to enable the first 7-Seg and write the first ASCII value into PORTB, then delay for 0.5ms, then moves on to display the second number on the second 7-Seg, and when all of the 4 numbers have been displayed, the programme goes back to repeat the process so that a longer displaying session is performed.
  1.	Main Functions
first_digit --- to display the first number on the first 7-Seg
second_digit --- to display the second number on the second 7-Seg
third_digit --- to display the third number on the third 7-Seg
fourth_digit--- to display the fourth number on the fourth 7-Seg
delay --- delay for 0.5ms before writes the next value into PORTB

Task 2
A look up table is made for the 7-Seg to loop through 0 to 9. Since PORTB is connected to the 7-Seg and the LEDs, while displaying the number on the 7-Seg the corresponding byte of the HEX value should enable the LEDs
1.	Main Functions
send_led --- loads the look up table and loop through to display all the numbers in the lookup table
delay --- a 1 second delay to allow the numbers and byte pattern to be clearly seen.

Task 3
The 7-Seg is enabled by the push button SW 5, which is the far right one on the board. Port H is connecting to the DIP Switches and push buttons, in order to enable the push button, all the DIP switches must be turned on.
  1.	Main Functions
first_digit --- to display the first number on the first 7-Seg
second_digit --- to display the second number on the second 7-Seg
third_digit --- to display the third number on the third 7-Seg
fourth_digit--- to display the fourth number on the fourth 7-Seg
forever --- always checking PH0 to see if the user has pushed SW5 (the far right push button)
  2.	Other Functions
new_function --- loop through the main functions so that all 4 of the numbers can be seen.
  3.	Instructions
(a)	Before running the programme, make sure that all the DIP Switches are turned on to enable the push button
(b)	After running the programme, hold on to SW5, the numbers should be displayed while holding, and vanish after letting go of the push button.

Task 4
A stack frame was built to take the pointer to the string of 4 ASCII numbers and get them displayed on the 7-Seg.
1.	Main Functions
mainloop --- configures the 7-Seg and building the stack frame
print --- loading the string and length of string to registers
send-digit --- send the current character that Register X is pointing to, and increment to point to the next number.
delay --- delay for 0.5ms before writes the next value into PORTB

Task 5
This task requires scrolling the string that is longer than the number of 7-Segs on the board. The intended displaying logic is to display the first four numbers at a time, then increment by one digit, and print the next 4 numbers again.
i.e. for numbers 0,1,2,3,4, the displaying sequence should be 0123  1234  2340  3401  4012  0123
After printing the first sequence, increment “buffer” by 1 and then we update the starting number array position pointer that we are going to use for the next sequence. If the buffer reaches the length of the number array, it is reset to zero, and the starting number array position pointer points to the beginning.
Repeat each sequence for 1000 times to make sure the 7-Seg displays long enough for the user to see.
  1.	Main Functions
mainloop --- configures the 7-Seg and building the stack frame
repetition_loop – resets the number and segment arrays and counters; loops through each pattern 1000 times
send_digit --- loops through 4 time; each time turns on one of the segments with a specific number
reset_routine --- resets the stack pointer to point to the start of the number array if the max. number is reached
stack_pointer_start_position – increments the position that the number array stack pointer points to for the next pattern to be displayed; also increments the buffer
  2.	Instructions
Under the function “check_number_array_position”, after command “cmpb”, input the first number in the number array.


Exercise 3: Serial Input/Output
commited by: Jack Allsopp

This section focuses on the SCI1 of the board and the interaction between the Terminal (User Input) and the board. All the tasks are combined in on file called “Exercise 3”
Task 1
Output the string in memory to the serial port at the rate one per second, send a carriage return after completing transmission.
  1.	Main Functions
writeStringStart --- configures the baud rate and clear the registers SCI1CR1 and SCI1CR2
writeString --- polls the TDRE flag and load the string character by character to SCI1DRL
pushString --- after receiving the data, enable transmit bit in SCI1CR2
finishWrite --- finish the programme by sending a carriage return to the serial.
  2.	Instructions
Input the desired string into variable “string” before running the programme

Task 2 & 3
Polls the serial port to read the incoming character until a carriage return is detected.
  1.	Main Functions
readStringStart --- configures baud rate, and SCI1CR1 and enable receiver bit in SCI1CR2
readStringPoll --- polls the serial port, if the RDRF is set, data is received in SCIDRL/H
readString --- store the incoming character to the “new_string”
  2.	Instructions
If writing to the serial port is desired, input “writeStringStart” after “BRA” command below the “_Startup” label.
If reading from the serial port is desired, input “readStringStart” after “BRA” command below the “_Startup” label.


Exercise 4: Integration Task
commited by: Jack Allsopp, James Calfas, Yujiao Cao

This section takes the string input from the serial port, and polls the PH0 to choose the desired routine, whether to change all the letters to uppercase or only the letters after a space.
If PH0 is 1 (DIP 8 on), the routine will be to capitalise the letter after a space; If PH0 is 0 (DIP 8), the routine will be to capitalise every letter.
  1.	Main Functions
PortH_state --- polls the PH0 value to see which routine the user chooses
convert_lower --- convert all the characters to lower case
convert_upper_space --- check for space character and capitalise the next character 
come_Back (come_Back2) --- stores the converted character into “Output String

  2.	Instructions
(a)	Make sure all the DIP switches are off to correctly choose the routine.
(b)	For converting all the characters to uppercase, make sure DIP 8 (PH0) is off
(c)	For capitalising the letter after a space character, turn DIP 8 on.
(d)	Input the string into the terminal and wait for the results.











