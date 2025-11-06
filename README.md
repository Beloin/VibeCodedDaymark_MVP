# daymark

An app based on a calendar, checkmarks for dates, a way to track what have you done daily. It can create new fields for each new Daymark that I want to add.

Something like showing a calendar with the dates that can be inserted:

| Study Programming |
| -------------     |
| [X] [0] [x] [0] [0] [0] |


| Run |
| -------------     |
| [X] [x] [x] [0] [0] [0] |


and so on showing almost like a calendar of dates

1. the main screen should only show thies minimized cards.
2. There should have a button to checkmark that day
2. Cards could be opened and be read, all check that day that was forgotten
3. Services shuould be created and create abstract call to a driver that saves current state. The first driver implementation will be a IO driver, 
but later we will implement an API driver.
4. Should follow flutter folder structutre, also services shgould be inside lib/services

