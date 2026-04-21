# Pixel Drill — Design & Implementation Notes

## What is pixel drill?

A pixel drill returns a **time series of values at a single lat/lon point** across multiple days. For example: "give me `ssta_mosaic` at lat=-33.8, lon=151.2 for every day in the last 30 days."

Target product: `IMOS/SRS/AusTemp/Marine-Heatwave/`
Variables of interest: `ssta_mosaic`, `dhd_mosaic`

---

## Data structure on S3

Files are stored as daily NetCDF files, organised by year:

```
s3://imos-data/IMOS/SRS/AusTemp/Marine-Heatwave/
  2025/
    20250101_IMOS_AusTemp-marine-heatwave_AUS_fv02.nc
    20250102_IMOS_AusTemp-marine-heatwave_AUS_fv02.nc
    ...
  2026/
    20260101_IMOS_AusTemp-marine-heatwave_AUS_fv02.nc
    ...
```

Each file contains:
- `time(1)` — one timestamp, units `seconds since 1981-01-01`
- `lat(2000)` — range -48 to -8 degrees
- `lon(3900)` — range 96 to 174 degrees
- Variables: `sst`, `ssta`, `sst_mosaic`, `ssta_mosaic`, `mosaic_age`, `dhd`, `dhdc`, `dhd_mosaic`, `dhdc_mosaic`, `MHW_category`, `MCS_category`, `MHW_category_mosaic`, `MCS_category_mosaic`, `l2p_flags`

---

## How THREDDS enables pixel drill

### Step 1 — NcML `joinExisting` aggregation

THREDDS cannot drill across separate files directly. First, multiple daily files must be joined into one virtual dataset using NcML `joinExisting` aggregation.

Each daily file has shape `(time=1, lat=2000, lon=3900)`. `joinExisting` reads the `time` value from each file, sorts them, and presents a virtual dataset with a continuous time axis:

```
20260101_*.nc   →   time=[t1],  ssta_mosaic[1, 2000, 3900]
20260102_*.nc   →   time=[t2],  ssta_mosaic[1, 2000, 3900]
20260103_*.nc   →   time=[t3],  ssta_mosaic[1, 2000, 3900]

         ↓  joinExisting  ↓

virtual:  time=[t1, t2, t3, ...]
          ssta_mosaic[N, 2000, 3900]
            → ssta_mosaic[0, :, :]  pulled from 20260101 file
            → ssta_mosaic[1, :, :]  pulled from 20260102 file
            → ssta_mosaic[2, :, :]  pulled from 20260103 file
```

The position in `time[]` and the first index of `ssta_mosaic[]` are always in sync — that is the NetCDF convention. No data is copied; THREDDS just maintains a map of `time index → file path`.

### Step 2 — NCSS point query

Once aggregated, THREDDS NCSS (NetCDF Subset Service) can extract a time series at a specific lat/lon:

```
GET /thredds/ncss/grid/AusTemp/marine-heatwave-agg
    ?var=ssta_mosaic&var=dhd_mosaic
    &latitude=-33.8
    &longitude=151.2
    &time_start=2026-03-01T00:00:00Z
    &time_end=2026-04-21T00:00:00Z
    &accept=csv
```

THREDDS:
1. Maps lat/lon → nearest grid indices, e.g. `lat[742], lon[2181]`
2. Looks up the index to find which files cover the requested time range
3. For each file, fetches only `ssta_mosaic[0, 742, 2181]` — one float per file
4. Assembles and returns the time series

---

## Cold scan and AggregationCache

### Cold scan

On first access, THREDDS scans the directory and opens each file — but reads **only the `time` coordinate variable**, not the data. For 111 files (~2026 to date):

```
open 20260101_*.nc  →  read time[0] = 1420070400  (discard rest)
open 20260102_*.nc  →  read time[0] = 1420156800  (discard rest)
...
```

The result is a small sorted index — 111 entries of `(timestamp, file path)`:

```
[
  (1420070400, "s3://.../20260101_*.nc"),
  (1420156800, "s3://.../20260102_*.nc"),
  ...
]
```

This is tiny and is saved to the `AggregationCache` on disk.

### After cold scan

- `recheckEvery="1 hour"` — THREDDS does a directory listing every hour to detect new files. Only new files (e.g. today's) are opened and added to the index. Existing files are never re-read.
- `AggregationCache maxAge=30 days` — the index expires after 30 days, triggering a full rescan. For 111 files within the same AWS region, this takes seconds.

---

## Current catalog.xml configuration

```xml
<!-- NCSS endpoint: /thredds/ncss/grid/AusTemp/marine-heatwave-agg
     ?var=ssta_mosaic&var=dhd_mosaic&latitude=LAT&longitude=LON
     &time_start=START&time_end=END&accept=csv -->
<dataset name="AusTemp Marine-Heatwave Aggregation" ID="austemp-mhw-agg"
         urlPath="AusTemp/marine-heatwave-agg">
  <metadata inherited="true">
    <serviceName>regGriddedServices</serviceName>
    <dataType>Grid</dataType>
  </metadata>
  <netcdf xmlns="http://www.unidata.ucar.edu/namespaces/netcdf/ncml-2.2">
    <aggregation dimName="time" type="joinExisting" recheckEvery="1 hour">
      <scan location="cdms3:imos-data?IMOS/SRS/AusTemp/Marine-Heatwave/2026/" suffix=".nc" />
    </aggregation>
  </netcdf>
</dataset>
```

Scanning only 2026 for now (~111 files, grows to 365 by year end). Add a `2027/` scan entry when the range needs to extend across the year boundary.

---

## Performance considerations

### Chunking

Each variable in the files is stored with chunk layout `(1, 20, 3900)`:

```
lon →  0                                    3900
       ┌────────────────────────────────────┐
lat  0 │         chunk 0  (20 rows)         │
    20 │         chunk 1  (20 rows)         │
    40 │         chunk 2  (20 rows)         │
       │              ...                   │
  1980 │         chunk 99 (20 rows)         │
       └────────────────────────────────────┘
total = 100 chunks per variable per file
```

### Impact on pixel drill

To read one pixel e.g. `lat[742], lon[2181]`, THREDDS must fetch the full chunk containing that row:

```
fetch chunk 37: lat[740–759], lon[0–3900]   ← 20 × 3900 = 78,000 values (~100–300KB compressed)
extract ssta_mosaic[742, 2181]              ← 1 value used, rest discarded
```

For a 30-day drill: 30 HTTP range requests to S3, each ~100–300KB.

```
30 requests × ~15ms (same AWS region) = ~450ms latency
+ decompression + THREDDS processing
= roughly 1–3 seconds total
```

### Why not faster?

The chunk layout `(1, 20, 3900)` is optimised for WMS map rendering (full-width lat slices), not pixel drill. Ideal pixel drill chunking would be small spatial tiles like `(1, 100, 100)`, reducing each fetch to ~40KB. However the files are produced upstream by IMOS so the chunking cannot be changed.

If sub-second performance is needed, caching pixel drill results at the application layer is the practical solution.
