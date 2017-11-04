#!/usr/local/bin/python3

user_input = "5,16,25,3,4,1"
user_numbers = user_input.split(",")
user_numbers_as_int = []
for number in user_numbers:
    user_numbers_as_int.append(int(number))
print(user_numbers_as_int)
