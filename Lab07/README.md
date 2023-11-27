# 學習處理 CDC 問題

有別於以往使用 double DFF 去傳輸 data

這次的 Lab 是要求我們使用 FIFO

我的作法是 input 一進來就用 FIFO 傳到另一個 clock domain，然後在那計算出 output

但其實比較好的作法是 input 進來先計算出答案，再用 FIFO 傳到另一個 clock domain 輸出 output

這樣做的好處是可以省下很多 FIFO 的面積

這也是導致我最終是 rank 75 / 105 的主因，沒省到 FIFO 面積

此外，因為 FIFO 內有兩個方向的 synchronizer

所以 .sdc file 裡要寫下

set_false_path -from clk2 -to clk1

set_false_path -from clk1 -to clk2