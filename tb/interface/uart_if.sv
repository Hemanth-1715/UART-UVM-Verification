// =============================================================================
// INTERFACE: uart_if
// =============================================================================
interface uart_if (input logic clk);

  // Signal Declarations
  logic       rx, rxEn;
  logic       txEn, txStart;
  logic [7:0] in;
  logic       tx;
  logic [7:0] out;
  logic       rxDone, rxBusy, rxErr;
  logic       txDone, txBusy;

  // TX Clocking Block
  clocking tx_cb @(posedge clk);
    default input #1step output #1;
    output txEn, txStart, in;
    input  txDone, txBusy, tx;
  endclocking

  // RX Clocking Block
  clocking rx_cb @(posedge clk);
    default input #1step output #1;
    output rxEn, rx;
    input  rxDone, rxBusy, rxErr, out;
  endclocking

  // Monitor Clocking Block
  clocking mon_cb @(posedge clk);
    default input #1step;
    input txEn, txStart, in, txDone, txBusy, tx;
    input rxEn, rx, rxDone, rxBusy, rxErr, out;
  endclocking

endinterface : uart_if