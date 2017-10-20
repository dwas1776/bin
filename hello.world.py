#!/usr/local/bin/python3

def hello(name):
    print('Hello ' + name)


def add(a, b):
    return a + b


hello('Alice')
hello('Joe')
print(add(1,2))
print(add(1,2) + add(3,4))

del_whitespace = "   remove extra whitespace    ".strip()
print(del_whitespace)

name = input("What is your name? ")
# method chaining
print("Hello " + name.strip().capitalize() + "!")
