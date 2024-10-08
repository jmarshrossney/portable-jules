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

import netCDF4
import pandas as pd
import matplotlib.pyplot as plt

DAY = 60 * 60 * 24
```

```python
path = Path.cwd().parent /  "run" / "point" / "outputs" / "joe-test.Hourly.nc"
assert path.exists()
```

```python
with netCDF4.Dataset(path, "r") as file:
    #print(file)
    #print(file.dimensions)
    #print(file.variables)
    var = file.variables["tstar"]
    print(var)
    data = var[:]

data.shape
```

```python
plt.plot(data[:, :-1, ...].squeeze())
```

```python
import xarray as xr

dataset = xr.open_dataset(path)

dataset
```

```python
dataset["tstar"]
```

```python
dataset["tstar"].values.shape, dataset["tstar"].squeeze().values.shape
```

```python
# These are equivalent I think
a = dataset["tstar"].squeeze()[:, :-1]
b = dataset["tstar"].squeeze().isel(tile=slice(0, -1))
(a == b).all()
```

```python
# Nice that the axes are labelled automatically!
dataset["tstar"].squeeze()[:, :-1].plot.line(x="time")
```

```python
df = dataset["tstar"].squeeze().to_dataframe()
df
```

```python
tile = df.xs(4, level="tile")
tile
```

```python
tile["tstar"].rolling(window=24).mean()
```

```python
# Problem because I chose a 360 day calendar like a noob, so it doesn't trivially convert to a datetime object
# Instead just set it to the number of days since initialisation.
tile.index = [i / 24 for i in range(len(tile.index))]

fig, ax = plt.subplots(figsize=(12, 4))
tile["tstar"].plot(ax=ax, label="raw")

# NOTE: daily average is meaningless in this experiment because the meteo driving data is constant in time... :P
tile["tstar"].rolling(window=10).mean().plot(ax=ax, label="daily average")
ax.legend()
```

```python

```

```python

```
