#!/bin/bash

# 项目路径
PROJECT_DIR=/home/admin/vue-peach
BACKUP_DIR=/home/admin/vue-peach_backup
DEPLOY_DIR=/home/admin/vue-peach_new
NGINX_CONF=/etc/nginx/conf.d/vue-peach.conf

# 创建新的部署目录
echo "创建新的部署目录..."
rm -rf $DEPLOY_DIR
mkdir -p $DEPLOY_DIR
cp -r $PROJECT_DIR/* $DEPLOY_DIR

# 备份旧版本并替换为新版本
echo "备份旧版本并替换为新版本..."
rm -rf $BACKUP_DIR
if [ -d "$PROJECT_DIR" ]; then
    mv $PROJECT_DIR $BACKUP_DIR
fi
mv $DEPLOY_DIR $PROJECT_DIR

# 检查 Nginx 配置文件是否存在
if [ ! -f $NGINX_CONF ]; then
    echo "创建 Nginx 配置文件..."
    cat <<EOL > $NGINX_CONF
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
fi

# 检查 Nginx 是否安装并启动
if ! systemctl is-active --quiet nginx; then
    echo "Nginx 未运行，正在启动 Nginx..."
    systemctl start nginx
fi

# 重启 Nginx 服务
echo "重启 Nginx 服务..."
systemctl restart nginx

echo "部署完成！"
