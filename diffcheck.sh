#!/bin/bash
FILE1="$1"
FILE2="$2"
# 移除重复行并排序
SORTED_FILE1=$(cat "$FILE1" | grep -v '^$' | sort | uniq)
SORTED_FILE2=$(cat "$FILE2" | grep -v '^$' | sort | uniq)

# 比较文件内容
if cmp -s <(echo "$SORTED_FILE1") <(echo "$SORTED_FILE2") &> /dev/null; then
echo "diff ok"
else
echo "diff error"
exit 1
fi
