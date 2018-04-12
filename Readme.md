# 使用hugo来搭建博客

---
本文主要是基于[zuolan的hugo框架来实现的](https://github.com/izuolan/dockerfiles/tree/master/hugo)
---

## 这里主要构建两个docker镜像, 一个是:`hugo`, 另一个是`hugo:minify`

---

**hugo**镜像是用来承载hugo运行环境, [zuolan](https://github.com/izuolan/)提供的构建方案占用空间比较小, 基于busybox. busybox 是集成了许多Linux命令的一个运行环境. 体积仅为几兆

**hugo:minify** 镜像是包含gulp插件的hugo运行环境, gulp可以打包静态页面的插件(nodejs写的?)

---