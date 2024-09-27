import pandas as pd
import matplotlib.pyplot as plt

def read_asc(path) -> pd.DataFrame:
    """
    Reads a JULES output file into a pandas DataFrame.
    """

    # "\s+" matches any number of whitespace characters
    df = pd.read_table(path, sep=r"\s+", comment="#")

    return df

if __name__ == "__main__":
    from pathlib import Path
    test_input = Path(__file__).parent.parent / "workdir" / "output" / "joe-test.Hourly.asc"
    df = read_asc(test_input)
    print(df.head())


