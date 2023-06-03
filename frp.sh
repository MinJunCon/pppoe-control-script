#!/bin/bash


#需要前置FRPC 搭配另外一个VPS做反向代理
#这台服务器需要再装个代理服务器软件 并通过FRPC 反向代理端口到 另外一个静态服务器的FRPS上面

function Start() { #影子科技 PPPOE MGR
    echo ip....
    curl ip.sb
    #systemctl restart wg-quick@wg0
    systemctl restart frpc

   # systemctl status wg-quick@wg0
    systemctl status frpc
}

function network() {
    #超时时间
    local timeout=4
    #目标网站
    local target=example.com
    #获取响应状态码
    local ret_code=$(curl -I -s --connect-timeout ${timeout} ${target} -w %{http_code} | tail -n1)

    if [ "x$ret_code" = "x200" ]; then
        #网络畅通
        echo "ok!"
        return 1
    else
        #网络不畅通
        echo "no!"
        return 0
    fi

    return 0
}

while true; do
    echo "影子科技 拨号服务器控制脚本 V:q2861727311 "
    rm /root/status #删除志位 由AUTOSSH检测
    systemctl stop frpc #关闭frpc
    echo 'Start switching VPS IP....'
    pppoe-stop
    sleep 1
    pppoe-start
    for num in {1..5}; do
        echo $num
        network
        if [ $? -eq 1 ]; then
            echo "网络畅通，你可以上网冲浪！"
            Start
            echo ok > /root/status #写标志位 由AUTOSSH检测
            exit -1
        fi
        sleep 1
    done
    echo "网络不通继续重试中..."
done

exit 0