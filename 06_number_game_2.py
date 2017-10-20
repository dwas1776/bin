#!/usr/local/bin/python3
#   import random
#
#   magic_numbers = [random.randint(0, 9), random.randint(0, 9)]
#   chances = 3
#   for attempt in range(chances):
#       print("This is attempt {}.".format(attempt))
#       user_number = int(input("Pick a number between 0 and 10.   "))
#       if user_number in magic_numbers:
#           print("You win!")
#       if user_number not in magic_numbers:
#           print("Wrong, try again.")
#
#   print("The magic numbers were:  ", magic_numbers)

########################################

import random
magic_numbers = [random.randint(0, 5), random.randint(0, 5)]


def ask_check_num():
    user_guess = int(input("Enter number from 0 to 5:  "))
    if user_guess in magic_numbers:
        return "You win!\n\n\n"
    if user_guess not in magic_numbers:
        return "Sorry, you guessed wrong.\n"


def run_program_x_times(chances):
    for attempt in range(chances):
        # print("This is attempt {}".format(attempt), end = " ")
        print("This is attempt {}".format(attempt))
        print(ask_check_num())

user_chances = int(input("Enter the number of chances you want:  "))
run_program_x_times(user_chances)

print("The magic numbers were {}.".format(magic_numbers))
