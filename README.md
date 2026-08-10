# APB UART Core

An RTL implementation of an APB-attached UART, accompanied by a SystemVerilog/UVM verification environment.

## Contents

- `rtl/` — APB UART design, including the APB interface, controller, baud generator, FIFOs, transmitter, and receiver.
- `apb_vip/`, `uart_vip/` — UVM verification IP for the APB and UART interfaces.
- `RAL/` — UVM register abstraction layer.
- `env/` — UVM environment, configuration, virtual sequencer, and scoreboard.
- `test/` — sequences and tests covering transmit, receive, configuration, loopback, register access, and interrupts.
- `tb/` — UVM testbench top.
- `sim/` — Questa/ModelSim run script (`run.do`). Generated simulation artefacts are ignored by Git.
- `specs/`, `Docs/` — design specification, verification plan, test plan, and bug tracker.

## Simulation

From `sim/`, launch Questa/ModelSim with:

```tcl
do run.do
```

The run script compiles the RTL and UVM environment, then starts `uart_tx_interrupt_test`. Change `+UVM_TESTNAME` in `sim/run.do` to select another test.

## Notes

The design specification describes the intended UART architecture and register set. The RTL is the executable source of truth; for example, its currently instantiated FIFO depths differ from the 32-entry depth described in the specification.
