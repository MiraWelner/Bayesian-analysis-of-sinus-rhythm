import pyreadstat
import polars as pl
import itertools
import sys
import matplotlib
matplotlib.use("Qt5Agg")
import matplotlib.pyplot as plt


# Directly load the .dta file
df, _ = pyreadstat.read_dta("SHHS1_ECG_30sec_20200519_v2_selectedNSRR.dta", usecols=["shhs_id", "timefromepochbegin_tosleeponset_", "thisepochisduringorclosesttoslee", "awake", "non_REM", "REM"])
df = pl.from_pandas(df)
rows = df.to_dicts()
groups = [list(group) for key, group in itertools.groupby(rows, key=lambda x: x["shhs_id"])]
dfs = [pl.DataFrame(group) for group in groups]

new_labels = []
for data in dfs:
    indexed_data = data.with_columns(pl.arange(0, data.height).alias("row_idx"))
    try:
        first_sleep_onset = indexed_data.filter((pl.col("timefromepochbegin_tosleeponset_") == 0) & (pl.col("thisepochisduringorclosesttoslee") == 1)).select("row_idx").item()
    except:
        print(pl.col("thisepochisduringorclosesttoslee"))
        break

    final_waking_from_sleep = indexed_data.filter((pl.col("REM") != 0) | (pl.col("non_REM") != 0)).tail(1)["row_idx"].item()
    status_column = []
    for i, row in enumerate(data.iter_rows()):
        timefromepochbegin_tosleeponset_ = row[1]
        thisepochisduringorclosesttoslee = row[2]
        awake = row[3]
        non_rem = row[4]
        rem = row[5]

        #30-sec bin at least 5 mins before the first onset of sleep (i.e., timefromepochbegin_tosleeponset_ < -300)
        if thisepochisduringorclosesttoslee < -300:
            status_column.append(1)

        #30-sec bin just before the first onset of sleep (i.e., timefromepochbegin_tosleeponset_ < -30)
        elif timefromepochbegin_tosleeponset_ < -30:
            status_column.append(2)

        #30-sec bin during the first onset of sleep (i.e., I labeled this for you as follows: timefromepochbegin_tosleeponset_ == 0 and thisepochisduringorclosesttoslee == 1)
        elif timefromepochbegin_tosleeponset_ == 0 and thisepochisduringorclosesttoslee == 1:
            status_column.append(3)

        #30-sec bin right after the first onset of sleep (i.e., timefromepochbegin_tosleeponset_ > 0 and <=30)
        elif timefromepochbegin_tosleeponset_ > 0 and timefromepochbegin_tosleeponset_ <= 30:
            status_column.append(4)

        #30-sec bin when the person is awake any time after the first onset of sleepand before the final waking from sleep
        elif i > first_sleep_onset and i < final_waking_from_sleep and awake:
            status_column.append(5)

        #30-sec bin of non-REM sleep (i.e., non_REM==1)
        elif non_rem == 1:
            status_column.append(6)

        #30-sec bin of REM sleep (i.e., REM==1)
        elif rem == 1:
            status_column.append(7)

        #30-sec bin just before the final waking from sleep
        elif i == final_waking_from_sleep-1:
            status_column.append(8)

        #30-sec bin during final waking from sleep — you will need to determine this for each person by
        #looking backwards from the max value of timefromepochbegin_tosleeponset_ until the sleep state
        #changes from awake to REM or non-REM and label that last sleep state of REM or non-REM as during
        #final waking from sleep.
        elif i == final_waking_from_sleep:
            status_column.append(9)

        #30-sec bin right after the final waking from sleep
        elif i > final_waking_from_sleep  and i <  final_waking_from_sleep+10:
            status_column.append(10)

        elif i >= final_waking_from_sleep+10:
            status_column.append(11)

    new_labels.extend(status_column)
print(new_labels)
