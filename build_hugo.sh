#! /bin/sh
DOCKER_NAME='chenyingcai/hugo_busybox:v1'
HUGO_VERSION=0.20.2
if [ "$(docker images -q $DOCKER_NAME 2> /dev/null)" == "" ]; then
  echo "没有找到$DOCKER_NAME容器"
  echo "----------------------------------------------"
  echo "下载相应的临时文件"
  curl -o Dockerfile_hugo https://raw.githubusercontent.com/chenyingcai/hugo_blog/master/buildfiles/Dockerfile_hugo
  wget https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz
  tar xf hugo_${HUGO_VERSION}_Linux-64bit.tar.gz
  mv hugo_${HUGO_VERSION}_linux_amd64/hugo_${HUGO_VERSION}_linux_amd64 hugo
  echo -e "#! /bin/sh\nhugo server --baseURL=$BASE_URL --bind=0DD0.0.0 --appendPort=false" > run.sh
  echo "开始创建$DOCKER_NAME容器"
  docker build -t $DOCKER_NAME -f Dockerfile_hugo
  echo "删除临时文档"
  rm -rf Dockerfile_hugo run.sh hugo_${HUGO_VERSION}_linux_amd64 hugo_${HUGO_VERSION}_Linux-64bit.tar.gz
  echo "完成"
else
  echo "已经安装$DOCKER_NAME"
fi