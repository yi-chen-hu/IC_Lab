# 學習寫 Testbench 和 Pattern

從 Lab3 開始要求同學自己寫 Testbench 和 Pattern

# Design

我在 input 跟 output 都用了 shift register 去省面積

此外，這次 Lab 的 input 雖然長達 64 個 cycle

但其實不需要等到所有 input 都進來之後才開始計算

可以很早就開始計算，這樣可以減少很多 latency

同時搭配 shift register 進一步讓計算變得簡單

變成只需要讀取特定的 DFF 的值即可計算

# Rank

我原本是 rank 31 / 105

但因為我在移動人物的演算法設計的不錯，cost 低於助教設定的 threshold

所以我最後有拿到 bonus，變成 rank 17 / 105
