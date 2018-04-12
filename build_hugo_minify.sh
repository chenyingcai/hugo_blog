#! /bin/sh
DOCKER_NAME='chenyingcai/hugo_busybox_minify:v1'
HUGO_VERSION=0.20.2
if [ "$(docker images -q $DOCKER_NAME 2> /dev/null)" == "" ]; then
  echo "没有找到$DOCKER_NAME容器"
  echo "----------------------------------------------"
  echo "下载相应的临时文件"
  wget https://github.com/chenyingcai/hugo_blog/master/buildfiles/minify
  cd minify
  curl -o Dockerfile_hugo_minify https://raw.githubusercontent.com/chenyingcai/hugo_blog/master/buildfiles/Dockerfile_hugo_minify
  echo "开始创建$DOCKER_NAME容器"
  docker build -t $DOCKER_NAME -f Dockerfile_hugo
  cd ..
  echo "删除临时文档"
  rm -rf minify
  echo "完成"
else
  echo "已经安装$DOCKER_NAME"
fi