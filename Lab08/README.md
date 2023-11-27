# 學習寫 Low Power Design

寫 Low power design 要注意的是不要使用 shift register

因為 shift register 在每次 posedge clk 時都會 trigger 所有的 DFF

比較好的做法是每個 DFF 都用 clock gating

這樣每次 input 時只會 trigger 一個 DFF

output 也是同樣的作法

再更 aggresive 一點可以把用不到的 combinational circuit 都拉成定值

我最終是 rank 14 / 105