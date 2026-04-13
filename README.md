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
- eg:
  &nbsp;&nbsp;&nbsp;&nbsp;2 in binary = 000010
  &nbsp;&nbsp;&nbsp;&nbsp;let data bit position is 10 = 001010
  &nbsp;&nbsp;&nbsp;&nbsp;000010 & 001010 = 000010 -> non-zero value - so it is in P2 coverage set

&nbsp;&nbsp;&nbsp;&nbsp;let data bit position is 9 = 001001
&nbsp;&nbsp;&nbsp;&nbsp;000010 & 001001 = 000000 -> zero value - so out of P2 coverage set

## SRAM Memory

SRAM takes in 39-bit data_in to write at 8-bit address in write operation and outputs 39-bit data_out read from 8-bit address

- memory is initially initialised with an empty memory of 0x0
- we is an input signal which indicates read(we=0) and write(we=1) operations
- data_in is an input signal given by encoder in write operation
- data_out is an output signal given to decoder in read operation
- address is an input signal which governs the location of the memory where read and write operations needs to be performed
  Memory is a single port SRAM - at a time either read or write operation can happen

## ECC Decoder

Decoder decodes 39-bit enc_in into 32-bit data_out, this is completely a combinational logic block

- enc_in is a 39-bit input signal which is the encoded data stored in memory
- data_out is a 32-bit output signal which is extracted from enc_in and given as an output to master
- sec_corrected is a 1-bit output signal. It goes high only when it detects and corrects single bit error in enc
- ded_error is a 1-bit output signal. It goes high only when it detects 2-bit errors

Decoder calculates parities based on the data and parity bits, also the overall parity bit
The calculated parity bits excluding overall parity bit makes up syndrome = {P32,P16,P8,P4,P2,P1}

Decoder can have the following four cases:

- syndrome=0 and overall parity bit=0 --> No Error at all
- syndrome=0 and overall parity bit=1 --> Data is fine, error in overall parity bit
- syndrome!=0 and overall parity bit=1 --> Single bit error detected
  - single bit error is corrected by flipping bit at syndrome location
  - sec_corrected = 1
- syndrome!=0 and overall parity bit=0 --> Double bit error detected
  - data cannot be corrected
  - ded_error = 1
