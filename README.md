# EECS448 - Software Engineering: Project 3+4

## Team Wubba Lubba Dub Dub's Final Project

### Members
- <a href="https://github.com/DamianVu">Damian Vu</a>
- <a href="https://github.com/lanegramling">Lane Gramling</a>
- <a href="https://github.com/karic123">Kari Cieslak</a>
- <a href="https://github.com/dustinbingham">Dustin Bingham</a>

<img src="https://github.com/DamianVu/EECS448-FinalProject/blob/stable/Game/images/tilesets/SLASHNBASH.png" />

### Project Overview
Project 3 was a prototype for Project 4. The **master** branch contains our submission for Project 3. The **stable** branch contains our submission for Project 4. 

The four person team: Wubba Lubba Dub Dub decided to create a game from scratch. Our goals were to create a game using the least amount of libraries as possible in order to fully understand what goes into a game.

The game engine utilized was <a href="https://love2d.org/">LÖVE</a> and our game was primarily coded in Lua, with a couple of scripts coded in Python for the game server.

#### Achieved Goals
- Real time server-hosted multiplayer
  - UDP for connectionless, low latency gameplay
  - Lobby system and virtual spawning of game servers (Python)
- Gameplay
  - Character movement
  - Weapons
    - All weapons are ranged firing 1-20 projectiles with different rates of fire
    - Cone-shaped for multiple projectiles at once (up to 360 degrees around the player)
  - Enemies
    - 5 different types of enemies with varying speeds and damage
    - All enemies move towards player they were spawned in proximity to
- Character creation
  - Custom Sprites
  - Names and UIDs
- Randomly-generated enemies in proximity to players based on random seed generation
- Real-time collision-detection and correction
  - Stable AABB collision with support for non-square objects
  - Tested with 100,000+ concurrent collisions resulting in no drop in framerate
- Map editor/generator using our own mapping system.
  - Creation using tilesets and sprites
  - Camera functionality (Movement/Zoom)
  
#### Gameplay Pictures

Coming soon
