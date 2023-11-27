# Project Description

這次 Final Project 是寫一個 RISC

但不同的是 instruction 及 memeory data 都要透過 AXI4 從 DRAM 讀取或寫入

所以要盡可能少去讀取或寫入 DRAM ，否則 latency 會很大，這時候 SRAM 的設計就很重要

# SRAM Design

Spec 有說存在 data dependence，其範圍是 (current address - 64 + 2) 到 (current address + 64)

所以我 SRAM 是設計成有 128 words 且每個 word 為 16 bit

整個設計會用到兩個 SRAM，分別存 instruction 跟 memeory data

此外，instruction 跟 memeory data 都有其各自的 AXI4 interface

所以我的寫法是 instruction 及 memeory data 各寫一個 module

然後在 module 內部寫 SRAM、FSM 及 AXI4 interface

透過 in_valid、out_valid 與 top module 溝通

這樣做的好處是會有非常好的 readability 及 maintainability

# Multi-Cycle CPU

我這次 Final Project 是實作 Multi-Cycle CPU 而不是 Pipelined CPU

理由是實作 Pipelined CPU 的話 cycle time 不好壓

# Rank

我最終是 rank 24 / 105