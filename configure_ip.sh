#!/bin/bash

# 设置静态IP的函数
set_static_ip() {
    # 默认值
    default_ip="192.168.1.100"
    default_subnet_mask="255.255.255.0"
    default_gateway="192.168.1.1"
    default_dns="8.8.8.8"

    # 提示输入IP地址，默认值为$default_ip
    read -p "请输入静态IP地址（默认：$default_ip）:" ip_address
    ip_address=${ip_address:-$default_ip}

    # 提示输入子网掩码，默认值为$default_subnet_mask
    read -p "请输入子网掩码（默认：$default_subnet_mask）:" subnet_mask
    subnet_mask=${subnet_mask:-$default_subnet_mask}

    # 提示输入网关，默认值为$default_gateway
    read -p "请输入网关（默认：$default_gateway）:" gateway
    gateway=${gateway:-$default_gateway}

    # 提示输入DNS，默认值为$default_dns
    read -p "请输入DNS服务器（默认：$default_dns）:" dns
    dns=${dns:-$default_dns}

    # 列出网络接口并提示输入接口名称
    echo "可用的网络接口如下："
    ip link show | awk -F: '$1 !~ "lo|vir|br|wl|^[^0-9]"{print $2}'

    # 提示输入网络接口名称
    read -p "请输入网络接口名称：" interface_name

    # 备份当前网络配置文件
    cp /etc/sysconfig/network-scripts/ifcfg-$interface_name /etc/sysconfig/network-scripts/ifcfg-$interface_name.bak

    # 写入新的配置
    cat > /etc/sysconfig/network-scripts/ifcfg-$interface_name <<EOL
DEVICE=$interface_name
BOOTPROTO=none
ONBOOT=yes
IPADDR=$ip_address
NETMASK=$subnet_mask
GATEWAY=$gateway
DNS1=$dns
EOL

    # 重启网络服务以应用更改
    systemctl restart network

    echo "静态IP配置已成功应用。"
}

# 设置动态IP（DHCP）的函数
set_dynamic_ip() {
    # 列出网络接口并提示输入接口名称
    echo "可用的网络接口如下："
    ip link show | awk -F: '$1 !~ "lo|vir|br|wl|^[^0-9]"{print $2}'

    # 提示输入网络接口名称
    read -p "请输入网络接口名称：" interface_name

    # 备份当前网络配置文件
    cp /etc/sysconfig/network-scripts/ifcfg-$interface_name /etc/sysconfig/network-scripts/ifcfg-$interface_name.bak

    # 写入新的DHCP配置
    cat > /etc/sysconfig/network-scripts/ifcfg-$interface_name <<EOL
DEVICE=$interface_name
BOOTPROTO=dhcp
ONBOOT=yes
EOL

    # 重启网络服务以应用更改
    systemctl restart network

    echo "动态IP配置已成功应用。"
}

# 主脚本逻辑
read -p "是否设置静态IP？(yes/no): " choice

if [ "$choice" == "yes" ]; then
    set_static_ip
else
    set_dynamic_ip
fi
