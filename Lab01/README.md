# 學習寫 Combinational Circuit

這次 Lab 是很經典的 sorting problem

唯一要注意的就是 swap 的時候要利用 mux 而不是寫成像下面這樣

```
temp = a;
a = b;
b = temp;
```