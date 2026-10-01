# 14_SOLID_Principles

Five design rules that keep classes small, easy to change, and easy to test. Senior interviews ask you to explain each one with a real iOS example — and spot violations in code.

**Branch:** `feature/ios`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_SRP_Single_Responsibility` | One reason to change, splitting a Massive View Controller | ⬜ |
| 02 | `02_OCP_Open_Closed` | Extend with new types, not by editing `switch` statements | ⬜ |
| 03 | `03_LSP_Liskov_Substitution` | Subtypes must work wherever the parent works, Rectangle/Square trap | ⬜ |
| 04 | `04_ISP_Interface_Segregation` | Small focused protocols, no empty "fat protocol" methods | ⬜ |
| 05 | `05_DIP_Dependency_Inversion` | Depend on protocols, not concrete classes — applied via DI | ⬜ |

**0 / 5 topics**

Each folder: `Principle.swift` (runnable playground: ❌ violation → ✅ fix) + `Principle_Notes.txt` (concept notes).

## SOLID at a Glance

| Letter | Principle | One-liner |
|:------:|-----------|-----------|
| **S** | Single Responsibility | A type should have one reason to change |
| **O** | Open / Closed | Open for extension, closed for modification |
| **L** | Liskov Substitution | Subtypes must be usable in place of their parent |
| **I** | Interface Segregation | Many small protocols beat one big one |
| **D** | Dependency Inversion | Depend on abstractions, not concrete types |

> DIP is the **principle** — Dependency Injection (`13_Design_Patterns/05`) is the **technique** that applies it.

## Status

- [ ] 01_SRP_Single_Responsibility
- [ ] 02_OCP_Open_Closed
- [ ] 03_LSP_Liskov_Substitution
- [ ] 04_ISP_Interface_Segregation
- [ ] 05_DIP_Dependency_Inversion
