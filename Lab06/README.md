# 學習如何寫 soft IP

利用 generate 與 if - else 把不同 bit 數的 soft IP 都寫出來

接著引用自己寫的 soft IP 到 top module 內並完成剩餘的設計

下面是這次 Lab 要運算的部分，其中
$x_P$、
$x_Q$、
$y_P$、
$y_Q$、
$p$、
$a$ 為 input
$$x_R = s^2 - x_P - x_Q \ mod \ p$$ $$y_R = s(x_P - x_R) - y_P \ mod \ p$$
where
$$s = \frac{y_Q \ - \ y_P}{x_Q \ - \ x _P} \ mod \ p $$

我在省資源時下了很多功夫

我自己在想架構時列出了每個 operator 在每個 cycle 做了什麼運算

最後只使用了下表的資源去運算上面的數學式

| Operator | Amount |
| :------: | :----: |
| mult     | 1      |
| mod      | 2      |
| sub      | 1      |
| add      | 2      |
| soft IP  | 1      |

我最終是 rank 5 / 105