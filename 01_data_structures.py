#!/usr/local/bin/python3

message = "Hello Python world!"
print(message)

first_name = "david"
last_name = "wasmer"
middle_initial = "a"
full_name = first_name+" "+middle_initial+" "+last_name
print(full_name.title())
# calc = 1/3
# print(calc)

print("\nAdding strings 2 and 2 gives this result:\n\t", "2" + "2")
print("\nMultiplying string by number: \"2\" * 3 =\n\t",
      "2" * 3)
print("BUT adding a string to a number gives error: \n\"2\" + 2 \n\
      Traceback (most recent call last): \n\
      File \"/home/dwasmer/Python_Proj/data_structures.py\", \n\
      line 18, in <module> \"2\" + 2\) \n\
      TypeError: Can\'t convert \'int\' object to str implicitly \n\
      ")

'''
####################################
    T U P L E S
       a n d
    L I S T S

  1. Strings use quotes (class)
  2. Tuple use commas
  3. Lists use brackets
  4. Sets use braces
  5. Dict use braces for key:value pairs

    Access a single element with brackets

####################################
# Add comments with the...
#   1. hashtag
#   2. hash
#   3. number
#   4. pound
#   5. sharp
#   6. octothorpe
#
'''

bike_string = 'trek'
bicycles_tuple = 'trek', 'redline', 'specialized', 'connondale'
bicycles_list = ['trek', 'redline', 'specialized', 'connondale']
bicycles_set = {'trek', 'redline', 'specialized', 'connondale'}
bicyles_dict = {'trek': 'red', 'redline': 'blue', 'specialized': 'green'}

# playing with lists
bicycles_list = ['trek', 'redline', 'specialized', 'connondale']
colors = ['brown', 'green', 'blue', 'red', 'gold']

# Complex code
print("My bike is a", colors[-2], bicycles_list[0].title(), "\b.")

# Simple code
mybike = bicycles_list[0]
mycolor = colors[-2]
print("My bike is a", mycolor, mybike.title(), "\b.")

# more fun with lists
pet = ['dog']
spelling = list(pet[0])
print("pet is ", pet)
print("pet is spelled...", spelling)

print("\nL I S T S \n#################")
mylist = ['zero', 'one', 'two', 'three', 'four',
          'five', 'six', 'seven', 'eight']
print('print even numbers')
print(mylist[::2])
print('print 1 and 4')
print(mylist[1:6:3])

mylist = ['zero', 'one', 'two', 'three',
          'four', 'five', 'six', 'seven', 'eight']

glocks = ['Glock 20', 'Glock 27', 'Glock 30']
print("\nGlocks list.\n\t", glocks)

glocks.insert(0, 'Glock 17')
print("\nInsert Glock 17.\n\t", glocks)

glocks.pop(-1)
print("\nPop last item in Glock List.\n\t", glocks)

'''
###########################
    D I C T I O N A R Y
###########################
'''
print("\nD I C T I O N A R Y\n#####################")
signals = {'Green': 'Go.',
           'Yellow': 'Go faster!',
           'Red': 'Smile for the camera.'
           }
print("Dict keys\n\t", signals.keys())
print("\nDict values\n\t", signals.values())
# Add Blue key and value to dict
signals['Blue'] = 'You must be trippin.'
print("\nAdd Blue to dict.\n\t", signals)
# Change value of Red key
signals['Red'] = 'Stop.'
print("\nShow entire dict.\n\t", signals)
# Delete dict entry for Blue (key and value)
del signals['Blue']
print("\nDelete Blue from Dict.\n\t", signals)
signals.get('Red')
print("\nGet Red.\n\t", signals)
print("\nGet Orange.\n\t", signals.get('Orange', 'Not in Dict'))
