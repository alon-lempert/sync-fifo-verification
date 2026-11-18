# Verification Plan – Synchronous FIFO

## 1. DUT Overview
`sync_fifo` is a parameterized, single-clock FIFO.

| Port | Dir | Width | Description |
|---|---|---|---|
| `clk` | in | 1 | Clock (rising edge) |
| `rst_n` | in | 1 | Asynchronous active-low reset |
| `wr_en` | in | 1 | Write request |
| `wr_data` | in | `WIDTH` | Write data |
| `rd_en` | in | 1 | Read request |
| `rd_data` | out | `WIDTH` | Read data (registered) |
| `full` | out | 1 | FIFO full flag |
| `empty` | out | 1 | FIFO empty flag |

Parameters: `WIDTH` (data width), `DEPTH` (number of entries).

## 2. Design Assumptions & Spec Decisions
- `DEPTH` must be a power of 2.
- Full/empty detection uses pointers with an extra wrap bit (MSB).
- Read latency: `rd_data` is updated on the clock edge that samples `rd_en`; data is valid one cycle after the request. `rd_data` holds its value when no read occurs.
- Write while `full=1` is ignored (no overwrite). Read while `empty=1` is ignored.
- Simultaneous read & write when empty: only the write is performed (no bypass).
- Simultaneous read & write when full: only the read is performed.
- Reset clears pointers and `rd_data`; memory contents are not reset.

## 3. Verification Strategy
Class-based SystemVerilog environment (no UVM): transaction, generator, driver, monitor, scoreboard with a queue-based reference model, SVA, and functional coverage. Directed tests for corner cases, constrained-random tests for stress.

## 4. Feature List

| ID | Feature | Scenario | Check | Coverage |
|---|---|---|---|---|
| F1 | Reset | (a) Power-on reset. (b) Write several entries, assert `rst_n`, then write/read new data and verify old data is never returned. | Directed check + SVA (`empty=1`, `full=0`, `rd_data=0`); model flushed on reset | Reset asserted when FIFO empty / partial / full |
| F2 | Data ordering & integrity | (a) Write `DEPTH`, read `DEPTH`. (b) Interleaved: write some, read some, write again, drain. | Scoreboard | ≥ `DEPTH` consecutive reads; interleaved wr/rd sequence |
| F3 | `empty` flag | Assert after reset and after draining. Deassert after first write. | SVA + model-predicted flags | `empty` transitions 0→1 and 1→0 |
| F4 | `full` flag | Assert after `DEPTH` writes. Deassert after one read from full; reset while full. | SVA + model-predicted flags | `full` transitions 0→1 and 1→0 |
| F5 | Overflow protection | Fill, attempt one and several writes while `full=1`, drain and verify exactly `DEPTH` entries in order. | Scoreboard + SVA | cross: `wr_en=1` × `full=1` |
| F6 | Underflow protection | Drain, attempt one and several reads while `empty=1`; `rd_data` unchanged; write one entry and read it back. | Scoreboard + SVA | cross: `rd_en=1` × `empty=1` |
| F7 | Simultaneous read & write | `wr_en=1` & `rd_en=1` in the same cycle when partial / empty / full; sustained simultaneous traffic. | Scoreboard + SVA | cross: (`wr_en` & `rd_en`) × {empty, full, partial} |
| F8 | Pointer wrap-around | Multiple fill/drain cycles; partial patterns so pointers wrap at different offsets. | Scoreboard; optional white-box SVA on pointers | Pointer MSB toggled ≥ 2 times; wrap while partial |
| F9 | Read latency | Single-cycle `rd_en`; idle cycles; back-to-back reads. | SVA (`rd_data` stable when no read) + scoreboard | Back-to-back reads; idle cycle right after a read |
| F10 | Parameterization | Run the suite on `DEPTH` = 2, 4, 16 and `WIDTH` = 1, 8, 32. | Full environment per configuration | All configurations in regression list executed |
| F11 | Random traffic stress | Long constrained-random `wr_en`/`rd_en` sequence with random data, back-to-back and idle cycles. | Scoreboard + SVA + coverage | Occupancy bins: 0, 1, mid, `DEPTH-1`, `DEPTH` |

## 5. Completion Criteria
- All tests pass on all configurations in F10.
- 100% functional coverage of the coverage model above (exclusions documented).
- Zero assertion failures.
