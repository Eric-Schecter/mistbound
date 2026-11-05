"""Exact route search including driftwood, currents and chart collection."""
import ast
import collections
import re
from pathlib import Path

DIRECTIONS = {'>': (1, 0), '<': (-1, 0), '^': (0, -1), 'v': (0, 1)}

try:
    from tools.audit_routes import solve
except ModuleNotFoundError:
    from audit_routes import solve

if __name__ == '__main__':
    source = (Path(__file__).parents[1] / 'scripts/game.gd').read_text()
    maps = ast.literal_eval(re.search(r'const MAPS := (\[.*?\n\])', source, re.S)[1])
    cells = ast.literal_eval(re.sub(r"Vector2i\(([^)]+)\)", r"(\1)", re.search(r"const PIRATE_CELLS := (.*)", source)[1]))
    headings = ast.literal_eval(re.sub(r"Vector2i\(([^)]+)\)", r"(\1)", re.search(r"const PIRATE_HEADINGS := (.*)", source)[1]))
    facing = {v: k for k, v in DIRECTIONS.items()}
    for index, rows in enumerate(maps, 1):
        assert len(rows) == 9 and all(len(row) == 12 for row in rows)
        enemies = [(x, y, facing[tuple(d)]) for (x, y), d in zip(cells[index-1], headings[index-1])]
        route = solve(rows, enemies)
        assert route, f'Level {index} has no three-chart route'
        print(f'Island {index}: {route} / {len(route)} voyages')

        if index >= 3:
            unguarded = solve(rows)
            assert unguarded and len(unguarded) < len(route), "Guard must close a shorter route"
            for y, row in enumerate(rows):
                for x, cell in enumerate(row):
                    if cell not in DIRECTIONS: continue
                    changed = rows[:]
                    changed[y] = row[:x] + '.' + row[x+1:]
                    alternative = solve(changed, enemies)
                    assert alternative is None or len(alternative) > len(route), "Every current must improve or enable the route"
            print("  PASS meaningful currents and guarded shortcut")
