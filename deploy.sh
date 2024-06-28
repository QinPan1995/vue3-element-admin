#!/bin/bash

NGINX_CONF=/etc/nginx/conf.d/vue-peach.conf

# 检查 Nginx 配置文件是否存在
if [ -f $NGINX_CONF ]; then
    echo "Nginx 配置文件已存在，清空旧配置文件内容..."
    sudo truncate -s 0 $NGINX_CONF
else
    echo "Nginx 配置文件不存在，创建新配置文件..."
fi

# 创建（或重写）新的 Nginx 配置文件
echo "写入新的 Nginx 配置..."
sudo cat <<EOL > $NGINX_CONF
server {
    listen 80;
    server_name 120.76.206.153;

    location / {
                        root /home/admin/vue-peach/dist;
                        index index.html index.htm;
        }
        # 反向代理配置
        location /prod-api/ {
            # vapi.youlai.tech 替换后端API地址，注意保留后面的斜杠 /
            proxy_pass http://172.20.196.121:8081/peach/;
        }
}
EOL

# 检查 Nginx 是否安装并启动
if ! systemctl is-active --quiet nginx; then
    echo "Nginx 未运行，正在启动 Nginx..."
    systemctl start nginx
fi

# 重启 Nginx 服务
echo "重启 Nginx 服务..."
systemctl restart nginx

echo "部署完成！"
