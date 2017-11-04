#!/usr/local/bin/python3

#   numbers = [1, 2, 3, 4, 5, 6]
#   for numbers in numbers:
#       if numbers > 3:
#           print(numbers)

#############################

#   magic_numbers = [3, 9]
#   user_number = int(input("Pick a number between 0 and 10.   "))
#   if user_number in magic_numbers:
#       print("You win!")
#   if user_number not in magic_numbers:
#       print("Wrong, try again.")
#
#   print("The magic numbers were:  ", magic_numbers)

#############################

#   magic_numbers = [3, 9]
#   chances = 3
#   for attempt in range(chances):
#       user_number = int(input("Pick a number between 0 and 10.   "))
#       if user_number in magic_numbers:
#           print("You win!")
#       if user_number not in magic_numbers:
#           print("Wrong, try again.")
#
#   print("The magic numbers were:  ", magic_numbers)

#############################

#   magic_numbers = [3, 9]
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

#############################

import random

magic_numbers = [random.randint(0,9), random.randint(0,9)]
chances = 3
for attempt in range(chances):
    print("This is attempt {}.".format(attempt))
    user_number = int(input("Pick a number between 0 and 10.   "))
    if user_number in magic_numbers:
        print("You win!")
    if user_number not in magic_numbers:
        print("Wrong, try again.")

print("The magic numbers were:  ", magic_numbers)
