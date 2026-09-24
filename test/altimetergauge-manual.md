# Metric altimeter regression checks

Display `TAltimeterGauge` at its default size (400 x 200) and at the size used
by the main form. Set its `Altitude` property in feet to the values below.
The values are rounded to three decimals; the gauge rounds converted meters.

| Altitude (meters) | `Altitude` (feet) | Metric short needle |
| --- | --- | --- |
| 0 | 0 | 12 o'clock, at 20 |
| 5,000 | 16404.199 | 3 o'clock, between 4 and 6 |
| 10,000 | 32808.399 | 6 o'clock, at 10 |
| 15,000 | 49212.598 | 9 o'clock, between 14 and 16 |
| 20,000 | 65616.798 | 12 o'clock, at 20 |

- Check that the metric inner ring reads clockwise: 20, 2, 4, 6, 8, 10,
  12, 14, 16, 18. Labels should remain legible without overlap.
- Check that the metric outer ring still reads 0 through 9 and its long needle
  points up for every table row (one revolution per 1,000 meters).
- At `Altitude = 820.210` feet (250 meters), check that the metric long needle
  points right while its short needle is just clockwise of the top.
- Compare the left imperial dial and pressure windows with the previous build
  at the same altitude and pressure: their appearance and readings should match.
