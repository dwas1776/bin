#!/usr/local/bin/python3
age = input('Enter your age:   ')
print("You have lived for {} years or {} seconds."
      .format(age, int(age) * 365 * 24 * 60 * 60))

numbers = [1, 2, 3, 4, 5, 6, 7]
for x in numbers:
    x > 5
