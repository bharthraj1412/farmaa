"""Verify all Python files parse correctly."""
import ast
import os

files = [
    'main.py', 'auth.py', 'database.py', 'models.py', 'schemas.py', 'middleware.py',
    'routers/__init__.py', 'routers/auth_router.py', 'routers/crops_router.py',
    'routers/orders_router.py', 'routers/ai_router.py', 'routers/market_router.py',
]

passed = 0
failed = 0

for f in files:
    try:
        with open(f, encoding='utf-8') as fh:
            ast.parse(fh.read())
        print(f"  OK  {f}")
        passed += 1
    except SyntaxError as e:
        print(f"  FAIL  {f}: {e}")
        failed += 1
    except FileNotFoundError:
        print(f"  MISSING  {f}")
        failed += 1

print(f"\nResult: {passed}/{passed+failed} files OK")
if failed == 0:
    print("All backend Python files are valid!")
