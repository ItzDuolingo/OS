# Operating System

## Features
- User login/register system
- Basic meta data handling
- Dev -> Admin -> User hiearchy
- File I/O
- Admin dashboard
- Keyboard input (UI Navigation)
- UI Drawing and navigation
- Multiple menus
- Permission handling

### Admin Dashboard
- User deletion
- Ability to change user's passwords
- Ability to promote users to admins

## Changelog

### v1.0
- User login/register system
- Basic meta data handling
- Dev -> Admin -> User hiearchy
- File I/O
- Admin dashboard
- Keyboard input (UI Navigation)
- UI Drawing and navigation
- Date and time for UI
- Multiple menus
- Permission handling

### Known issues
- When the read event is triggered during registration/login you can't use F1 to return, for now i don't know how to fix this
- The clock won't update during login/register due to the read event being triggered
- There is some issue while using A/D to switch between normal and power menu with the [example] highlight not being visible, so far didn't find a fix
- I haven't made a function to centerlize text so if someone's username is long and you wish to delete them using the admin dashboard for example, it will put the text off balance
- This code is NOT made for monitors, it is only made to be used on the terminal for now tho i intend to introduce monitor support later in the future

## Additional notes
- This code is still in work, it serves as a learning project for me to get to know coding therfore use it at your own risk and don't hate on me, please
- If you have any questions and/or suggestions on how i could change and/or improve the code feel free to contact me on discord at duolingo6954
- the Vending machine game that is stated below is NOT accesable trough the OS so far
  



# Vending machine game

## features
- User login system (for now)
- basic menu selection highlits with []
- Sell/buy functions
- basic file I/O like checking if user exists or writing transaction history or writing and checking balance
- presistent balance

 ## changelog

 ### v0.1
 - basic user interface
 - really bare bones
 -  checking if user exists
 -  buying items

 ### v0.2
 - sell/buy functions
 - checking if balance exists
 - logging history of buying/selling
 - selected items are now highlited in [] rather than making the user write the number of a item
 - user interface selection can now be moved with w and s keys
   
   
 
