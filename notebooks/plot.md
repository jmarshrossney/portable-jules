---
jupyter:
  jupytext:
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.16.4
  kernelspec:
    display_name: Python 3 (ipykernel)
    language: python
    name: python3
---

```python
from pathlib import Path
from itertools import product

import pandas as pd
import matplotlib.pyplot as plt

DAY = 60 * 60 * 24
```

```python
path = Path.cwd().parent /  "workdir" / "output" / "joe-test.Hourly.asc"
assert path.exists()
```

```python
cols = [
    "t0",
    "t1",
    "t",
    "precip",
    "pstar",
    "rad_net",
    "tstar_1",
    "tstar_2",
    "tstar_3",
    "tstar_4",
    "tstar_5",
    "tstar_6",
    "tsoil_1",
    "tsoil_2",
    "tsoil_3",
    "tsoil_4",
    "cv",
    "gpp_1",
    "gpp_2",
    "gpp_3",
    "gpp_4",
    "gpp_5",
]
```

```python
df = pd.read_table(path, sep=r"\s+", comment="#", names=cols)
df.t /= DAY
```

```python
df.head()
```

```python
df.plot("t", [f"tsoil_{i}" for i in range(1, 5)])
```

```python
df.plot("t", [f"tstar_{i}" for i in range(1, 6)])
```

```python
df.plot("t", ["rad_net"])
```

```python
df.plot("t", [f"gpp_{i}" for i in range(1, 4)], logy=True)
```

```python

```
