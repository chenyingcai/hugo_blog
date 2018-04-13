#! /bin/sh
# 由于存在需要权限建立新的文件夹,以及移动文件等 建议使用sudo /bin/bash new_site_project.sh 启动此命令
DOCKER_NAME='chenyingcai/hugo_minify:v1'
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
  echo "建立一个新的project"
  REPONAME="demo"
  docker run -it --rm --name hugoimg -v $PWD:/hugo/ -p 1313:80 $DOCKER_NAME hugo new site $REPONAME
  echo "下载主题"
  wget https://github.com/kakawait/hugo-tranquilpeak-theme/archive/master.zip
  unzip master.zip
  mkdir -p $REPONAME/themes/Tranquilpeak
  mv -f hugo-tranquilpeak-theme-master/* $REPONAME/themes/Tranquilpeak/
  rm -rf hugo-tranquilpeak-theme-master master.zip
  echo "往config.toml添加主题标注"
  echo 'theme="Tranquilpeak"' >> $REPONAME/config.toml
fi