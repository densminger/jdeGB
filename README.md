# jdeGB

## GameBoy emulator

A Gameboy emulator written in Swift.  Most of the inspiration to do this was based on javidx9's awesome YouTube series for creating a NES emulator in C (https://www.youtube.com/watch?v=nViZg02IMQo&list=PLrOv9FMX8xJHqMvSGB_9G9nZZ_4IgteYf).

![](images/Tetris.jpg)
![](images/Zelda.jpg)

## Running the emulator

You can run this from Xcode on macOS.  Be sure to select the Release scheme or it will run too slowly.

Right now, this looks at the "file" environment variable for the name of the ROM image to run.  So you need to edit the scheme and set up a file env variable to point to your rom.

## Keys

- Space - run / pause the emulator

- Enter - Start button
- Tab   - Select button
- Z     - B button
- X     - A button

- 1 - toggle display of CPU registers
- 2 - toggle display of Disassembly
- 3 - toggle display of tilesets
- 4 - toggle display of Tile Map + sprites + window (note that this displays in the same place as the main GB screen so you might want to toggle that off when you display this)
- 5 - toggle display of main Gameboy screen
- 6 - toggle mini-display of main Gameboy screen (usefull when Tile Map is displayed)

- D - reload disassembly
