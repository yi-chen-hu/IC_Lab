# 學習使用 Memory Compiler 生成 SRAM

SRAM 需要的三個參數
 - number of words in SRAM
 - number of bits for each word
 - mux width e.g. 4-to-1 mux, 8-to-1 mux, 16-to-1 mux
 
這次 Lab 讓我意識到上面三個參數對 SRAM 面積的影響非常大

最好是符合 Lecture 所說的 (bit × Mux Width) ≈ (Words ÷ Mux Width)

這樣面積會最小

我就是因為沒有好好照著上面的公式去設計我的 SRAM，所以面積很大

導致最終是 rank 59 / 105