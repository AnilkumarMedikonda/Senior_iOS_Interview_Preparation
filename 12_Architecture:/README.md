# 12_Architecture

How to structure an iOS app so it stays testable and easy to change — who owns state, where business logic lives, and how screens navigate. Senior interviews ask you to compare these and justify your choice for a real app.

**Branch:** `feature/ios`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_MVC` | Model–View–Controller, reusable API Client, Massive View Controller | ✅ |
| 02 | `02_MVVM` | ViewModel state, Repository, binding, DI, mock testing | ✅ |
| 03 | `03_Coordinator` | MVVM-C, ViewModel events, Coordinator owns screens + navigation | ✅ |
| 04 | `04_VIPER` | View, Interactor, Presenter, Entity, Router, Module Builder wiring | ✅ |
| 05 | `05_Clean_Architecture` | Presentation / Domain / Data, UseCase rules, DTO → Entity, dependency rule | ✅ |

**5 / 5 topics** ✅

## Extras

| File | What it shows |
|------|---------------|
| `Architecture_Map.swift` | Same feature built in all 5 architectures — where each responsibility lives |
| `Architecture_API_Flow_Example.swift` | One end-to-end example: MVVM-C + Clean layers + API flow + extension helpers |
| `Architecture_Diagrams/` | Colour diagrams with per-layer notes (PNG + SVG) |
| `Architecture_Posters/` | One-page posters per architecture: diagram, flow, structure, code, pros/cons (PNG + SVG) |

## Quick Comparison

| | MVC | MVVM | MVVM-C | VIPER | Clean |
|---|:-:|:-:|:-:|:-:|:-:|
| Complexity | Low | Medium | Medium | High | High |
| Testability | Low | Good | Good | Very good | Very good |
| Navigation | VC | VC | Coordinator | Router | Coordinator |
| Best for | Small screens | Most apps | Multi-screen apps | Huge teams | Large, long-lived apps |

> Senior default: **MVVM-C**, adding **Clean** layers (UseCases, Repositories) when business logic is complex.

## Architecture vs Pattern vs Principle

| Term | What it is | Example |
|------|------------|---------|
| Architecture | Overall app structure | MVVM, VIPER, Clean |
| Design pattern | Reusable solution to one problem | Repository, Dependency Injection (`13_Design_Patterns`) |
| Principle | A design rule | Dependency Inversion (`14_SOLID/05_DIP`) |

## File Format

- One `.swift` playground per topic — concept → code → inline output
- Interview Questions with one-line answers at the end
- Interview-level concepts only

## Status

- [x] 01_MVC
- [x] 02_MVVM
- [x] 03_Coordinator
- [x] 04_VIPER
- [x] 05_Clean_Architecture
