<p align="center">
    <img src="logo.png" alt="Inflate Every Second" width="300px">
</p>

<p align="center">
    <img
        src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fgames.roblox.com%2Fv1%2Fgames%3FuniverseIds%3D8267596086&query=%24.data%5B0%5D.visits&label=Visits&colorA=2B2B31&colorB=9c1925&style=for-the-badge"
        alt="Visits"
    >
    <img
        src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fgames.roblox.com%2Fv1%2Fgames%3FuniverseIds%3D8267596086&query=%24.data%5B0%5D.favoritedCount&label=Favourites&colorA=2B2B31&colorB=ba8816&style=for-the-badge"
        alt="Favourites"
    >
</p>

A Roblox incremental simulator where players grow their heads over time, unlock upgrades, and progress through increasingly difficult areas.

## About

Originally completed in August 2025.

Converted into a Rojo project to enable version control and showcase the source code.

## Gameplay

- Your head grows bigger every second.
- The bigger your head, the higher you jump.
- Jump through rings to earn points.
- Increase multipliers from rebirths and other upgrades.
- Try to reach the secret area at the top.

## Preview

![Preview](screenshots/map.png)

## Link to Play

https://www.roblox.com/games/126016356585979/Inflate-Every-Second

## Features

- Persistent player data using Roblox DataStores
- Currency, upgrade, and rebirth progression systems
- Custom UI systems
- Global leaderboards
- Multiplayer gameplay loop

## Built With

- Roblox Luau
- Rojo
- Git

## Building from Source

To build the place from scratch, use:

```bash
rojo build -o "InflateEverySecond.rbxlx"
```

Next, open `InflateEverySecond.rbxlx` in Roblox Studio and start the Rojo server:

```bash
rojo serve
```

Built with [Rojo](https://github.com/rojo-rbx/rojo) 7.7.0.
