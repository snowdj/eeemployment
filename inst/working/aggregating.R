# understanding aggregate

df <- data.frame(col1 = 1:5, col2 = c("A", "B", "B", "A", "A"))
df <- data.frame(col1 = 1:5,
                  col2 = c("A", "B", "B", "A", "A"),
                  col3 = c("c", "c", "c", "d", "d"))
agg <- aggregate(df, FUN="sum")

agg <- aggregate(col1 ~ ., data = df, sum)
xtabs(col1 ~ ., data = agg)
