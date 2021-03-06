#! /bin/sh
DOCKER_NAME='chenyingcai/hugo_busybox:v1'
REPONAME='demo'
BASE_URL='localhost:8000'
SPERA="===================================================="
HUGO_VERSION=0.20.2
if [ "$(docker images -q $DOCKER_NAME 2> /dev/null)" == "" ]; then
  echo "没有找到$DOCKER_NAME容器"
  echo $SPERA
  echo "下载相应的临时文件"
  curl -o Dockerfile_hugo https://raw.githubusercontent.com/chenyingcai/hugo_blog/master/buildfiles/Dockerfile_hugo
  wget https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz
  tar xf hugo_${HUGO_VERSION}_Linux-64bit.tar.gz
  mv hugo_${HUGO_VERSION}_linux_amd64/hugo_${HUGO_VERSION}_linux_amd64 hugo
  echo -e "#! /bin/sh\nhugo server --baseURL=\$BASE_URL --bind=0.0.0.0 --appendPort=false" > run.sh
  echo "开始创建$DOCKER_NAME容器"
  docker build -t $DOCKER_NAME -f Dockerfile_hugo .
  echo "删除临时文档"
  rm -rf Dockerfile_hugo run.sh hugo_${HUGO_VERSION}_linux_amd64 hugo_${HUGO_VERSION}_Linux-64bit.tar.gz hugo
  echo "完成"
  echo $SPERA
else
  echo "已经安装$DOCKER_NAME"
  echo $SPERA
fi
echo "下载主题"
echo "注意: 使用SVN可以下载指定文件夹而不用克隆整个项目"
svn checkout https://github.com/chenyingcai/hugo_blog/trunk/tranquilpeak $PWD/resource/tranquilpeak
echo "下载demo文档"
svn checkout https://github.com/chenyingcai/hugo_blog/trunk/exampleSite $PWD/resource/exampleSite
echo "创建copy样本shell文件"
echo -e "#! /bin/sh\ncp -rf /example/* /hugo/" > democopy.sh
echo "创建DockerFile:Dockerfile_${REPONAME}"
echo """FROM chenyingcai/hugo_busybox:v1
ENV BASE_URL=$BASE_URL
RUN hugo new site /example && mkdir -p /example/build
COPY . /example/build/
RUN cp -rf /example/build/resource/tranquilpeak /example/themes/ && \\
    cp -rf /example/build/resource/exampleSite/* /example/ && \\
    chmod a+x /example/build/democopy.sh && \\
    cp -rf /example/build/democopy.sh /bin/ && \\
    rm -rf /example/build 

WORKDIR /hugo
VOLUME [/hugo/]
EXPOSE 1313
CMD [run.sh]""" > Dockerfile_${REPONAME}
echo "创建chenyingcai/hugo_${REPONAME}:v1镜像"
docker build -t chenyingcai/hugo_${REPONAME}:v1 -f Dockerfile_${REPONAME} .
echo "删除临时文档"
rm -rf Dockerfile_${REPONAME} resource democopy.sh
echo "done"
echo $SPERA
echo -e "使用方法:\n 1. docker run -itd --rm --name hugoimg -p 8000:1313 -v \$PWD/$REPONAME:/hugo/ chenyingcai/hugo_${REPONAME}:v1\n 2. 使用alias hugo= \"docker exec hugoimg hugo\"赋值hugo命令, 之后使用hugo直接使用其他操作命令\n 3. 使用docker exec hugoimg democopy.sh获取样板网页以修改创建自己的网页"
