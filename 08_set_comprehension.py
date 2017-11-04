#!/usr/local/bin/python3

# You can define an empty list or an empty set with parenthisis:
letters = list()
type(letters)


numbers = set()
type(letters)

numbers.add(3)
print(numbers)
numbers.add(3)
print(numbers)
numbers.add(3)
print(numbers)

numbers.add(56)
numbers.add(8)
print(numbers)

lottery_values = {3, 5, 17, 6}
user_values = {3, 5, 11, 2}
lottery_user_intersection = lottery_values.intersection(user_values)
print(lottery_user_intersection)
user_lottery_intersection = user_values.intersection(lottery_values)
print(user_lottery_intersection)
