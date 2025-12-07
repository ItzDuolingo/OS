Recent changes:

- function whoIsPlaying() got new table entries
- functions buy() and sell() modified to now accept s and w keys to move [] up and down to select options instead of typing out a number
- function opts() changed to navigate() with same functions as buy() and sell() functions
- function transactionHistory(user, text) now logs if the person bought/sold what and for how much into their designated .txt file named after their username in "Operating_System/stats/balance/"
- function loadBalance() now opens a .txt file named after the user and checks the very last line for a positive digit, converts into number and stores into newBalance which then replaces local balance if the user has some transaction history

new functions:

- transactionHistory(user, text)
- loadBalance(user)
- inventory(user)
- loadInventory(user)
- navigate()


That's all for now, more to come soon
