#!/bin/bash

# 输入文件和输出文件定义
input_file="$1"
output_file="$2"
region=${3:-US}
batch_size=100

# 清空输出文件（如果存在）
>$output_file
>tmpgeoips

# 获取文件总行数
total_lines=$(wc -l < "$input_file")

# 计算需要处理的批次数
batches=$(( (total_lines + batch_size - 1) / batch_size ))

for (( i=1; i<=batches; i++ ))
do
    start_line=$(( (i-1)*batch_size + 1 ))
    end_line=$(( i*batch_size ))

    echo "Processing batch $i of $batches"

    # 提取50行（或剩余的所有行，如果不足50行）
    payload=$(sed -n "${start_line},${end_line}p" "$input_file" | jq -R -s 'split("\n") | map(select(length > 0))')

    # 发送请求到 API
    curl -s http://ip-api.com/batch --data "$payload" | \
    jq -r '.[] | [.query, .countryCode, .as] | join("<,>")' >> tmpgeoips
    # 可选：在批次之间添加延迟，以避免过于频繁的API调用
    # sleep 1
done

cat tmpgeoips | grep "$region" | awk -F'<,>' '{print $1}' >> "$output_file"

echo "Processing complete. checkout $region. Results saved in $output_file"

# # 输入文件和输出文件定义
# input_file="$1"
# output_file="$2"
# region=${3:-US}
# max_concurrent=10  # 最大并发数
# timeout=2

# # 清空输出文件（如果存在）
# >$output_file

# count=0
# # 读取输入文件的每一行 IP 地址
# for ip in $(cat "$input_file"| grep -v '^$')
# do  
#     {
        
#         # 使用 curl 发起请求，设置超时为 1 秒，保存成功的 IP 到输出文件
#         if curl -s -m $timeout  http://ip-api.com/json/${ip} | grep ${region} >>/dev/null; then
#             echo "$ip" >>$output_file
#             echo "[info] checkout ${region} ip: $ip ok"
#         fi
#     } &

#     # 增加任务计数器
#     count=$((count + 1))

#     # 等待当前并发任务数达到最大限制
#     if [ $count -eq $max_concurrent ]; then
#         wait    # 等待所有后台任务完成
#         count=0 # 重置计数器
#     fi

# done 
# wait
# echo "[info] All requests completed."
