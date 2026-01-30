# Operating System (CC:Tweaked)
A mock operating system project for cc:tweaked
It focuses on user data, user permissions, basic hierarchy (Dev -> Admin -> User), user authentication, file presistance and it serves primaly as a learning project

## Features
- User login/register system
- Basic meta data handling (.json files)
- Dev -> Admin -> User hierarchy
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
- Initial usable version 
- User login/register system
- Basic meta data handling
- Dev -> Admin -> User hierarchy
- File I/O
- Admin dashboard
- Keyboard input (UI Navigation)
- UI Drawing and navigation
- Date and time for UI
- Multiple menus
- Permission handling

### Known issues
- When the read event is triggered during registration/login you can't use F1 to return, fix not found yet
- The clock won't update during login/register due to the read event being triggered
- There is some issue while using A/D to switch between normal and power menu with the [example] highlight not being visible, so far didn't find a fix
- I haven't made a function to centerlize text so if someone's username is long and you wish to delete them using the admin dashboard for example, it will put the text off balance
- This code is NOT made for monitors, it is only made to be used on the terminal for now tho i intend to introduce monitor support later in the future
- SECURITY WARNING: "terminate" event is not being handled so far so be aware that anyone even basic user can terminate the code at any time and access cc:tweaked terminal  

## Additional notes
- This project is still under active development and serves primarily as a learning exercise
- Expect incomplete features and bugs tho i will try to lower the amount of bugs and try to fix most if not all before i release each version
- If you have any questions and/or suggestions on how i could change and/or improve the code feel free to contact me on discord at duolingo6954

### Installation steps
1. Download all files from this repository
2. Copy them into your game files, if you don't know where your game files are reference to the guide below
3. Run "menuMain.lua" in the ingame terminal
For the time being this code does NOT have pastebin, tho future versions (hopefully v1.1) will have pastebin

How to find your game files: (modrinth)
1. Press windows + r on your keyboard
2. A "run" window should popup, type "%appdata% this should open your file explorer
3. Find a folder labeled "ModrinthApp" then open it
4. Inside of the folder find another folder called "profiles" then open it
5. Inside of this folder find the name of your profile then open it
6. Inside of this folder find the folder called "saves" then open it
7. Inside of this folder find the name of your save on which you wish to have this code then open it
8. Now find a folder called "computercraft" open it and then open the folder called "computer"
9. Find the ID of the computer you want it to exist on then paste all the files into that folder

How to find your game files: (Normal launcher)
1. Press windows + r on your keyboard
2. A "run" window should popup, type "%appdata% this should open your file explorer
3. Find a folder called ".minecraft" and open it
4. Look for a folder called "saves" and open it
5. Find a folder with the name of your save and open it
6. Find a folder called "computercraft" and open it
7. Open the folder with the ID of your computer then paste all the files inside 

# Vending machine game
This program is currently a standalone and not a part of the OS

## features
- User login system (for now)
- basic menu selection highlights with []
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
   
   
 
