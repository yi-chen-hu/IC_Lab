# Project Description

Midterm Project 要先透過 AXI4 去讀取 DRAM 裡的 data 當作 input

接著計算 GLCM 並將 output 透過 AXI4 寫回 DRAM

PATTERN.v 會去檢查 DRAM 當中的答案是否正確

# My Design

我的作法非常偷懶，我在一開始就 prefetch 所有 DRAM data 並存進我的 SRAM 當中

因此之後就不需要去讀 DRAM 了

但這樣的壞處就是需要很大面積的 SRAM

所以最後 performance 並不好，只拿到 rank 64 / 105

建議還是參考我 Final Project 的架構會好很多