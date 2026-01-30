# Il Dolo dell'Angelo: Eyes Wide Shot

<img width="1912" height="1074" alt="Screenshot From 2026-01-31 00-29-32" src="https://github.com/user-attachments/assets/7f3316c2-cf26-466b-9abc-5147522e7022" />

> *"What must we do to heal our sins?"*

**Global Game Jam 2026 Entry** **Theme:** Mask

---

## About The Game
**Il Dolo dell'Angelo: Eyes Wide Shot** is a tactical sniper arcade game set in a dystopian alternate reality known as *La Nuova Serenissima*.

A mysterious figure known only as **"The Angel"** tasks you with eliminating specific targets at a high-society masquerade party. You don't quite understand who these people are or why they must die, but you feel deep down that The Angel is the only one who can fix the corruption rotting your home country.

Keep completing missions to piece together the fragmented truth of what happened to your world.

<img width="1912" height="1074" alt="Screenshot From 2026-01-31 00-31-46" src="https://github.com/user-attachments/assets/c513ccfb-1d30-46fe-9aca-4590f80edf00" />

---

## Gameplay Mechanics

<img width="1912" height="1074" alt="Screenshot From 2026-01-31 00-29-57" src="https://github.com/user-attachments/assets/659a4d85-fe9e-42cd-9963-c845ff869f1b" />

Your goal is to identify and eliminate the target before time runs out. The crowd is dense, and everyone is hiding behind a mask.

### The Hunt
The game utilizes **procedural generation** for the NPCs. Every round, targets are assembled from a randomized pool of masks, accessories, and clothing. No two targets are the same.

* **Consult the Brief:** Hold `SPACE` to check your notebook. It contains the specific traits of your target (e.g., "Lunga Blue mask, wearing Jester Hat").
* **The Scope:** Use your sniper scope (implemented via a dual-camera render setup) to scan the crowd and identify the correct combination of traits.
* **Relocate:** The environment is complex. Hold `C` to teleport between different "nests" or vantage points to get a better angle on the crowd.

<img width="1912" height="1074" alt="Screenshot From 2026-01-31 00-30-09" src="https://github.com/user-attachments/assets/7c4a7d99-73f0-4b3e-af89-6e392cfb64ca" />


### Panic Mode
Accuracy is everything. If you fire and miss, or kill the wrong innocent partygoer:

1.  **Chaos Erupts:** The crowd enters **Panic Mode**, moving faster and erratically.
2.  **Time Fractures:** Your clock breaks—you can no longer track how much time you have left.
3.  **Last Chance:** The police (*Le Guardie*) are alerted. You have a very brief window to find and eliminate the real target before you are apprehended.

<img width="1912" height="1074" alt="Screenshot From 2026-01-31 00-31-20" src="https://github.com/user-attachments/assets/2a0a8def-d591-45f5-be34-eb54059d2e47" />


---

## ⌨Controls

| Key | Action |
| :--- | :--- |
| **Mouse** | Look / Aim |
| **Right Click (Hold)** | Scope Zoom (Aim) |
| **Left Click** | Shoot |
| **Space (Hold)** | Check Brief & Watch |
| **C (Hold)** | Teleport to next vantage point |

![Sniper Scope View](Screenshot%20From%202026-01-31%2000-31-20.jpg)

---

## Technology

* **Engine:** Godot 4
* **Art & UI:** Blender, Figma
* **Genre:** 2.5D / 3D Sniper Puzzle

---

## Installation

1.  Download the game `.zip` file.
2.  Extract the contents to a folder.
3.  **Important:** Ensure the `.exe`, `console.exe`, and `.pck` files are all in the same directory.
4.  Run `Il Dolo dell'Angelo.exe` to launch.

---

## The Team

<img width="1912" height="1074" alt="Screenshot From 2026-01-31 00-34-17" src="https://github.com/user-attachments/assets/3c1ae195-6c28-4f31-b034-50fa4edb78ca" />

Created by **Sting Entertainment** for GGJ 2026.

* **Stefano Emanuele Aldanese** - Programmer
* **Donato D'Ambrosio** - Programmer
* **Andrea Copellino** - Programmer & UI Designer
* **Gabriel Fiorotto** - 3D Artist
* **Tommaso Solustri** - 3D Artist

---

© 2026 Sting Entertainment. Protect La Serenissima.
