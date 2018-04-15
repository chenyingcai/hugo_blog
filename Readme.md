# 使用hugo来搭建博客

---
本文主要是基于[zuolan的hugo框架来实现的](https://github.com/izuolan/dockerfiles/tree/master/hugo)
---

## 1.  这里主要构建两个docker镜像, 一个是:`hugo`, 另一个是`hugo:minify`

---

**hugo**镜像是用来承载hugo运行环境, [zuolan](https://github.com/izuolan/)提供的构建方案占用空间比较小, 基于busybox. busybox 是集成了许多Linux命令的一个运行环境. 体积仅为几兆

**hugo:minify** 镜像是包含gulp插件的hugo运行环境, gulp可以打包静态页面的插件(nodejs写的?)

## 2.  在linux环境下, 这里有两个sh构建脚本: *`build_hugo.sh`* 和 *`build_hugo_minify.sh`*
---
我们来看一下这两个脚本代码:

- *`build_hugo.sh`*

```sh
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
echo -e "#! /bin/sh\nhugo server --baseURL=$BASE_URL --bind=0.0.0.0 --appendPort=false" > run.sh
echo "开始创建$DOCKER_NAME容器"
docker build -t $DOCKER_NAME -f Dockerfile_hugo
echo "删除临时文档"
rm -rf Dockerfile_hugo run.sh hugo_${HUGO_VERSION}_linux_amd64 hugo_${HUGO_VERSION}_Linux-64bit.tar.gz
echo "完成"
else
echo "已经安装$DOCKER_NAME"
fi
```

- *`build_hugo_minify.sh`*

```sh
#! /bin/sh
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
fi
```

通过这两个脚本,能够实现自动检测是否已经安装过相应的image 若没有则自动安装同时也自动下载和清理相应的临时文件

## 3. 我们再来看一下在两个容器中, 分别将要运行的run.sh文档

### 1. *`hugo`*的*`run.sh`*

```sh
#! /bin/sh
hugo server --baseURL=$BASE_URL --bind=0.0.0.0 --appendPort=false
```

- **baseURL=$BASE_URL**: baseURL 指定博客的基础文档地址
- **$BASE_URL**: 我们在构建文档DockerFile中用ENV命令指定了一个环境变量
- **\-\-bind**: -bind=0.0.0.0是绑定到所有端口的意思, 这可以使得docker宿主机(docker host)能够通到hugo这个镜像源的网页, 最后我们才能通过docker host宿主机到本地宿主机localhost:8000"

### 2. *`hugo_minify`*的*`run.sh`*

```sh
#!/bin/sh
if [ ! -n "/work/html" ]; then ln -s /hugo/public /work/html; fi
cd /hugo && hugo server --baseURL=$BASE_URL --bind=0.0.0.0 --appendPort=false > /tmp/hugo.log
tail -fn0 /tmp/hugo.log | \
while read line; do
echo "$line" | grep "total"
if [ "$?" = "0" ]; then
cd /work && npm run build
fi
done
```

- **baseURL=$BASE_URL**: baseURL 指定博客的基础文档地址
- **$BASE_URL**: 我们在构建文档DockerFile中用ENV命令指定了一个环境变量
- **\-\-bind**: -bind=0.0.0.0是绑定到所有端口的意思, 这可以使得docker宿主机(docker host)能够通到hugo这个镜像源的网页, 最后我们才能通过docker host宿主机到本地宿主机localhost:8000"
- **gulp** 是通过相关config文档和npm 构建运行在/work/html 中的, 这一点我们可以下DockerFile中COPY命令可见, 通过监控若public文档是否有文档发布来实时启动gulp(通过npm run build 命令启动)来压缩已经发布的静态网页文档

## 3. 基于hugo_minify创建新的博客demo

脚本命令启动并进行基础构建

```sh
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
docker run -it --rm --name hugoimg -v $PWD:/hugo/ -p -p 8000:1313  $DOCKER_NAME hugo new site $REPONAME
echo "下载主题"
wget https://github.com/kakawait/hugo-tranquilpeak-theme/archive/master.zip
unzip master.zip
mkdir -p $REPONAME/themes/Tranquilpeak
mv -f hugo-tranquilpeak-theme-master/* $REPONAME/themes/Tranquilpeak/
rm -rf hugo-tranquilpeak-theme-master master.zip
echo "往config.toml添加主题标注"
echo 'theme="Tranquilpeak"' >> $REPONAME/config.toml
echo -e 'docker run -it --rm -p 8000:1313 -v $PWD/$REPONAME:/hugo $DOCKER_NAME  通过上面的命令使得我们在本地浏览生成的博客 1. -p 8000:1313 在$DOCKER_NAME镜像里面, 启动server默认是挂载到 1313 端口的, 所以我们要将docker宿主(host)的端口发送到本地主机(local host)的指定端口上,这里指定8000, 所以我们在本地浏览器中输入localhost:8000就可以见到 2. -v $PWD/$REPONAME:/hugo : 挂载本地的hugo存放文件的目录$PWD/$REPONAME到docker镜像对应的hugo工作目录上,也即/hugo目录  3.在$DOCKER_NAME镜像中的run.sh中我们看到hugo server命令中的-bind=0.0.0.0是绑定到所有端口的意思, 这可以使得docker宿主机能够通到这个镜像$DOCKER_NAME源的网页, 最后我们才能通过docker host宿主机到本地宿主机localhost:8000'

```
通过`sudo /bin/bash new_site_project.sh` 构建一个新的blog, 我们可以看到在当前目录下看到一个名为demo的文件夹, 我们 **`cd demo`** 进入文件夹 然后通过下面的命令创建一个新的post
```sh
docker run -it --rm -p 8000:1313 --name hugoimg -v $PWD/$REPONAME:/hugo $DOCKER_NAME
# 注意 由于hugo server默认发布到1313端口, 我们需要将本地宿主机的8000端口映射docker 宿主机的1313端口, 最后通过相关的命令使得镜像image绑定到0.0.0.0使得我们通过 本地->docker host -> 镜像 查看相应的发布页面
docker exec hugoimg hugo new posts/my-first-post.md
```
我们甚至可以设置好 `alias hugo="docker exec hugoimg hugo"` 之后就可以把镜像的hugo当做一个命令使用. 例如之后创建一个新的post 只需要 `hugo new [路径]/[名字.md]` 如:`hugo new posts/the-new-one.md`即可创建一个新的post

## 4. 基于hugo_demo创建新的博客
---

这里我们运行`build_hugo_demo.sh`, 之后我们会创建一个`hugo_demo:v1`的镜像,如果之前没有构建`hugo:v1`镜像, 那么我们会自动的将其创建并构建我们上述需要的镜像, 其实这两个镜像之间的不同仅仅是, 我们`hugo_demo:v1`镜像增加了demo博客所需要的内容, 这里我们使用的博客样板是**[hugo-tranquilpeak-theme](https://tranquilpeak.kakawait.com/)**

### 4.1. 启动容器`hugo_demo:v1` 同时获取模板
创建完镜像之后我们通过下面的命令来启动容器, 在`hugo_demo:v1`镜像中我们还加入了一个`democopy.sh`命令, 通过这个命令将容器中存储的demo site 复制到容器的工作目录`/hugo/`并因为4.1. 中的启动容器的命令中所做的在创建容器的同时还挂载了工作目录到本地, 因而我们可以修改demo的内容.
```sh
docker run -itd --rm --name hugoimg -p 8000:1313 -v $PWD/$REPONAME:/hugo/ hugo_demo:v1 democopy.sh
```
# 注意: 
如果上述命令如果后面那一个democopy.sh没有加上, 容器很可能因为加上了选项`--rm`而容器在启动后立即就停止退出了

### 4.2 创建alias命令
我们通过alias命令定制我们会经常重复使用的docker exec 的命令
```sh
alias hugo= "docker exec hugoimg hugo"
```
这样, 我们就可以像在本地宿主机安装了hugo一样, 正常使用hugo进行各类操作了
