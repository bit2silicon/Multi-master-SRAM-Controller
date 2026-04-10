# Multi-Master SRAM Controller

This project is an SRAM Controller which contains

- arbiter for managing bus contention when both the masters are requesting for the bus access
- ECC Encoder to encode the 32-bit input data and encode it to 39-bit output data to SRAM memory
- SRAM memory to store 39-bit encoded input data from encoder during a write operation and send 39-bit encoded data to ECC Decoder for extracting 32-bit data
- ECC Decoder to decode data from encoded data while correcting single-bit error and detecting double-bit errors

## Arbiter

Arbiter uses round-robin method to grant access to master during bus contention

- clk, rstn are global signals
- req is a 2-bit input where req[1] = master-1 requested and req[0] = master-0 requested
- grant is an active-high 2-bit output signal where grant[1] = master-1 got memory access and grant[0] = master-0 got memory access - valid only when gnt_valid is high
- gnt_valid is an active-high 1-bit output signal which determines grant signals are valid or not

## ECC Encoder

Encoder encodes 32-bit data into 39-bit data where 32-bit message bits + 6 hamming parity bits + 1 overall parity bit
This is completely a combinational logic block

- data_in is a 32-bit input data signal which needs to be encoded
- enc_out is 39-bit output data signal, it is the encoded data
  It encodes data based on Hamming code algorithm, parity bits are positioned at powers of 2
  Positions are 1, 2, 4, 8, 16, 32 and 39 (overall parity bit)
  Parity bits coverage set is determined using power of 2 and with data bit position - non-zero means covered in the set and zero means ignore that data bit
  eg: 2 in binary = 000010
  let data bit position is 10 = 001010
  000010 & 001010 = 000010 -> non-zero value - so it is in P2 coverage set

      let data bit position is 9 = 001001
      000010 & 001001 = 000000 -> zero value - so out of P2 coverage set
