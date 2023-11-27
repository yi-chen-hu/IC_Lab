# 學習使用 DesignWare IP

下表是我使用的資源，都是 DesignWare IP

| Operator    | Amount |
| :---------: | :----: |
| DW_fp_mult  | 3      |
| DW_fp_add   | 3      |
| DW_fp_exp   | 1      |
| DW_fp_recip | 1      |

這次 Lab 我沒在 exp 跟 recip 之間切 pipeline

這導致我的 critical path 很長，clock period 很大

我覺得非常可惜，因為我的面積其實在全班算是很小，但被 clock period 拖垮了

最終是 rank 46 / 105

這也讓我在之後的 Lab 很注意 pipeline 有沒有切均勻

避免被 critical path 拖垮了整體的運算速度