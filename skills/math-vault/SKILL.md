---
name: math-vault
description: Search and navigate Pepe's Math Obsidian vault. Use when looking for theorems, definitions, or mathematical concepts from class notes.
---

# Math Vault - Obsidian Zettelkasten

This skill helps you search and use Pepe's math notes stored in an Obsidian vault.

## Vault Location

```
/Users/pepe/Library/Mobile Documents/iCloud~md~obsidian/Documents/Math
```

## Structure

| Folder | Contents |
|--------|----------|
| `Calculo I/` | Analysis: limits, continuity, sequences, theorems |
| `Algebra I/` | Linear algebra and abstract algebra |
| `Estadistica I/` | Statistics |
| `Fisica/` | Physics |
| `exercises/` | Problem sets and solutions |
| Root | General math concepts (divisibility, primes, etc.) |

## Searching the Vault

### Find a theorem or concept
```bash
# Search by name
ls "/Users/pepe/Library/Mobile Documents/iCloud~md~obsidian/Documents/Math/Calculo I/" | grep -i "bolzano"

# Search content across all notes
grep -r "valor intermedio" "/Users/pepe/Library/Mobile Documents/iCloud~md~obsidian/Documents/Math/"
```

### Common Calculo I files
- `Teorema de Bolzano.md` - Bolzano's theorem
- `Teorema de los valores intermedios.md` - Intermediate Value Theorem
- `Teorema de Weierstrass.md` - Extreme Value Theorem
- `Función continua.md` - Continuity definition and properties
- `Función monótona.md` - Monotone functions
- `Densidad de Q en R.md` - Density of rationals

## Note Format

Notes are in Spanish with:
- YAML frontmatter with tags (including `review` for flashcards)
- LaTeX math: `$...$` inline, `$$...$$` display
- Wiki-style links: `[[Other Note]]`
- Flashcards section at the end: `## 🃏 Flashcards`

### Example note structure
```markdown
---
tags:
  - analysis
  - theorem
  - review
---

# Teorema de Bolzano

## Enunciado
...

## Demostración
...

## Relaciones
- [[Función continua]]
- [[Teorema de los valores intermedios]]

---

## 🃏 Flashcards

Teorema de Bolzano
??
Si $f$ es continua en $[a,b]$ y $f(a) \cdot f(b) < 0$, existe $c \in (a,b)$ con $f(c) = 0$
```

## Source PDFs

Course materials are in iCloud Drive:

| Subject | Path |
|---------|------|
| Cálculo I | `/Users/pepe/Library/Mobile Documents/com~apple~CloudDocs/Math/Calculo-1/tema01.pdf` ... `tema10.pdf` |
| Álgebra I | `/Users/pepe/Library/Mobile Documents/com~apple~CloudDocs/Math/Algebra-1/tema1.pdf` ... `tema10.pdf` |
| Estadística I | `/Users/pepe/Library/Mobile Documents/com~apple~CloudDocs/Math/Estadistica/` |
| Física | `/Users/pepe/Library/Mobile Documents/com~apple~CloudDocs/Math/Fisica/tema01.pdf` ... `tema10.pdf` |

## Important Guidelines

1. **Language**: All notes are in Spanish with formal mathematical terminology
2. **Atomic notes**: One concept per file, keep notes concise
3. **Before creating**: Search first to avoid duplicates
4. **Flashcards**: Use `?` (one-way) or `??` (bidirectional) syntax
5. **Tags**: Keep in English in YAML frontmatter, include `review` if note has flashcards
