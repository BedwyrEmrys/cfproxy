#!/bin/bash

# 输入文件和输出文件定义
input_file="$1"
output_file="$2"
max_concurrent=10 # 最大并发数
timeout=2

# 清空输出文件（如果存在）
>$output_file

count=0
# 读取输入文件的每一行 IP 地址
for ip in $(cat "$input_file" | grep -v '^$'); do
    {

        # 使用 curl 发起请求，设置超时为 1 秒，保存成功的 IP 到输出文件
        if curl -s -m $timeout --resolve "cftest.vivy.eu.org:443:$ip" https://cftest.vivy.eu.org/ | grep cf200 >>/dev/null; then
            echo "$ip" >>$output_file
            echo "[info] check ip: $ip ok"
        else
            sleep $timeout
            if curl -s -m $timeout --resolve "cftest.vivy.eu.org:443:$ip" https://cftest.vivy.eu.org/ | grep cf200 >>/dev/null; then
                echo "$ip" >>$output_file
                echo "[info] check ip: $ip ok"
            else
                echo "[error] check ip: $ip failed"
            fi

        fi
    } &

    # 增加任务计数器
    count=$((count + 1))

    # 等待当前并发任务数达到最大限制
    if [ $count -eq $max_concurrent ]; then
        wait    # 等待所有后台任务完成
        count=0 # 重置计数器
    fi

done
wait
echo "[info] All requests completed."
