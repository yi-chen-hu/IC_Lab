# 學習 System Verilog

System Verilog 相較於 Verilog 多了很多 high level 語法可以使用

這次 Lab 就有使用到:
- interface
    - INF.sv
    - Encapsulate I/O port
- package
    - Usertype_OS.sv
    - To enable sharing a user-defined type definition across multiple modules
- enum
    - Usertype_OS.sv
- typedef
    - Usertype_OS.sv
- struct
    - Usertype_OS.sv
    - Group related signals to enhance readability
- union
    - Usertype_OS.sv
    - Allows a single piece of storage to be represented in different ways

此外，這次 Lab 一樣要用 AXI4 protocol 去讀取或寫入 DRAM

我最終是 rank 21 / 105