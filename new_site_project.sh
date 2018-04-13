#! /bin/sh
# 由于存在需要权限建立新的文件夹,以及移动文件等 建议使用sudo /bin/bash new_site_project.sh 启动此命令
DOCKER_NAME='chenyingcai/hugo_minify:v1'
REPONAME="demo"
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
echo "建立一个新的project"
docker run -it --rm --name hugoimg -v $PWD:/hugo/ -p 8000:1313 $DOCKER_NAME hugo new site $REPONAME
echo "下载主题"
wget https://github.com/kakawait/hugo-tranquilpeak-theme/archive/master.zip
unzip master.zip
mkdir -p $REPONAME/themes/Tranquilpeak
mv -f hugo-tranquilpeak-theme-master/* $REPONAME/themes/Tranquilpeak/
rm -rf hugo-tranquilpeak-theme-master master.zip
echo "往config.toml添加主题标注"
echo 'theme="Tranquilpeak"' >> $REPONAME/config.toml
echo -e "docker run -it --rm -p 8000:1313 -v \$PWD/$REPONAME:/hugo $DOCKER_NAME \n 通过上面的命令使得我们在本地浏览生成的博客\n 1. -p 8000:1313 在$DOCKER_NAME镜像里面, 启动server默认是挂载到 1313 端口的, 所以我们要将docker宿主(host)的端口发送到本地主机(local host)的指定端口上,这里指定8000, 所以我们在本地浏览器中输入localhost:8000就可以见到\n 2. -v \$PWD/$REPONAME:/hugo : 挂载本地的hugo存放文件的目录\$PWD/$REPONAME到docker镜像对应的hugo工作目录上,也即/hugo目录 \n 3.在$DOCKER_NAME镜像中的run.sh中我们看到hugo server命令中的-bind=0.0.0.0是绑定到所有端口的意思, 这可以使得docker宿主机能够通到这个镜像$DOCKER_NAME源的网页, 最后我们才能通过docker host宿主机到本地宿主机localhost:8000"
