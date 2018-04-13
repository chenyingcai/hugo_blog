#! /bin/sh
DOCKER_NAME='chenyingcai/hugo_busybox_minify:v1'
if [ "$(docker images -q $DOCKER_NAME 2> /dev/null)" == "" ]; then
  echo "没有找到$DOCKER_NAME容器"
  echo "----------------------------------------------"
  echo "下载相应的临时文件"
  wget https://github.com/chenyingcai/hugo_blog/archive/master.zip
  unzip master.zip
  MAIN_DIR=$PWD
  cd hugo_blog-master/buildfiles/minify
  echo "开始创建$DOCKER_NAME容器"
  docker build -t $DOCKER_NAME -f Dockerfile_hugo_minify .
  cd $MAIN_DIR
  echo "删除临时文档"
  rm -rf hugo_blog-master master.zip
  echo "完成"
else
  echo "已经安装$DOCKER_NAME"
fi