# Operating System (CC:Tweaked)

# Introduction
A modular operating system-style environment for CC:Tweaked.
The system provides a structured platform for building and running applications inside ComputerCraft computers. It includes a user authentication system, permission hierarchy, persistent user settings, logging and a keyboard-driven terminal UI framework.
Applications can be added on top of the system without modifying the core OS allowing the environment to be extended with new programs and tools

## Contents
- [Features](#features)
- [Admin Dashboard](#admin-dashboard)
- [Dev Tools](#dev-tools)
- [Settings](#settings)
- [App Store](#App-Store)
- [Roadmap](#roadmap)
- [Changelog](#changelog)
- [Known Issues](#known-issues)
- [Additional Notes](#additional-notes)
- [Installation](#installation)


## Features
- User login/register system
- Basic meta data handling (.json files)
- Dev -> Admin -> User hierarchy
- File I/O
- Admin dashboard
- Dev tools
- Settings
- App store
- Keyboard input (UI Navigation)
- UI Drawing and navigation
- Multiple menus
- Permission handling
- Per user data
- Custom scrolling
- Basic security features
  
### Admin Dashboard
- User deletion
- Ability to change user's passwords
- Ability to promote users to admins
- Ability to demote admins to users

### Dev Tools
- Ability to view logs
- Access native cc:tweaked terminal,
- Ability to demote devs to users and promote users to devs
- Ability to reset settings to defaults

### Settings
- Ability to change theme
- Ability to toggle clock
- Ability to change date format
- Ability to change with which keys navigation throughout the menu is done
- Ability to reset settings to default settings
- Ability to change password
- Ability to change username

### App Store
- allows users to install and uninstall games that are available

# Roadmap

### In progress
- fixes and slight installer changes
### Planned
- Updater
- Blackjack
- Guessing game
- Shop game
- UI refactoring
  
### Ideas (not 100% planned)
- Monitor support
- Pocket computer support
- Some application to send messages from computer to computer utilizing rednet
- Some custom games that utilize turtles and rednet
- File explorer 

## Changelog

### v1.7
- Terminate event is now being captured and evaluated for better security
- Input boxes now look better and function way better
- It is now possible to type and remove text inside input boxes and be able to return at the same time
- Text should be more centered
- Clock updating is now more efficient and should work everywhere 

### v1.6
- Changes to UI (mostly menu titles)
- Users can now install and uninstall apps via the app store

### v1.5 
- Users can now change their date format (e.g: DD/MM/YYYY)
- Users can now change with which keys they navigate the menu (e.g: WSAD to move forward, backward, left and right and F1 to return to previous menu)
- Users can now reset their settings to default
- Users can now change their password and username

### v1.4
- Users can now toggle clock to false or true 

### v1.3
- Users can now choose between dark, ash and light theme
- Devs can restore settings to defaults per user
- Viewing logs now uses custom scrolling mechanism
- Switching between main and power menu is now possible only with A/D, however going up/down still utilizes W/S 
- Some comments were cleared since they were redundant 

### v1.2
- Dev tools have been added
- Username is now saved to state instead of being passed along as a argument so that it can be used across modules
- Certain functions are now being logged to a .txt file (logging in for example)
- Messages module has been added to clear up code and make it more modular
- Guest account has been removed for the time being

### v1.1
- Admins and devs can now demote other admins to users
- Devs can now promote admins and users to devs
- Devs can now demote devs to users
- Devs have the same access as admins inside of the admin dashboard
- Admin dashboard now has dev specific options

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
- This code is NOT made for monitors, it is only made to be used on the terminal for now, though i intend to introduce monitor support later in the future

## Additional notes
- "Guest" account has been indefinitely removed
- Plans for file explorer have been scrapped indefinitely
- This project is still under active development and serves primarily as a learning exercise
- Expect incomplete features and bugs though i will try to lower the amount of bugs and try to fix most if not all before i release each version
- If you have any questions and/or suggestions on how i could change and/or improve the code feel free to contact me on discord at duolingo6954

### Installation 
Open the ingame PC and paste:
"pastebin get fMsiwmfh installer.lua"
when it tells you that it successfully saved the file as installer run "installer.lua"
this should automatically download all the files and reboot the computer which will make the startup file run which will result in the OS running


# Vending machine game
This program is currently inactive and not part of the OS but will be later introduced

## features
- User login system (for now)
- basic menu selection highlights with []
- Sell/buy functions
- basic file I/O like checking if user exists or writing transaction history or writing and checking balance
- presistent balance

 ## changelog
  
  ### v0.2
 - Sell/buy functions
 - Checking if balance exists
 - Logging history of buying/selling
 - Selected items are now highlighted in [] rather than making the user write the number of a item
 - User interface selection can now be moved with w and s keys

 ### v0.1
 - Basic user interface
 - Really bare bones
 - Checking if user exists
 - Buying items
