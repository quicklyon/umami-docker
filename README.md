<!-- 该文档是模板生成，手动修改的内容会被覆盖，详情参见：https://github.com/quicklyon/template-toolkit -->
# QuickOn umami 应用镜像

## 快速参考

- 通过 [渠成软件百宝箱](https://umami.is/docs/install) 一键安装 **umami**
- [Dockerfile 源码](https://github.com/quicklyon/umami-docker)
- [umami 源码](https://github.com/umami-software/umami)
- [umami 官网](https://<homepage>/)

## 一、关于 umami

[Umami](https://umami.is/)Umami 是一个开源的、注重保护隐私、可以替代谷歌分析的自托管的网站分析解决方案。

### 尊重数据隐私

Umami 让您在尊重用户隐私的同时收集所需的数据。Umami 不收集任何个人信息，不使用 cookie，不跨网站跟踪用户，并且符合 GDPR。

最重要的是，您不需要显示烦人的 cookie 通知。

### 匿名收集数据

Umami 可帮助您遵守不断变化的数据隐私法。收集的所有数据都是匿名的，因此无法识别任何个人用户。请放心，您的数据安全地掌握在您手中。

### 简单易用

Umami 易于使用和理解，无需运行复杂的报告。Umami 只收集您关心的指标，所有内容都放在一个页面上。

### 代码开源

Umami 致力于开源开发。让您对完全透明、经过实战测试和社区支持的产品充满信心。

umami官网：[https://<homepage>/](https://<homepage>/)


<!-- 这里写应用的【附加信息】 -->

<!-- 示例

### 1.1 特性

- 批量执行: 主机命令在线批量执行
- 在线终端: 主机支持浏览器在线终端登录
- 文件管理: 主机文件在线上传下载
- 任务计划: 灵活的在线任务计划
- 发布部署: 支持自定义发布部署流程
- 配置中心: 支持 KV、文本、json 等格式的配置
- 监控中心: 支持站点、端口、进程、自定义等监控
- 报警中心: 支持短信、邮件、钉钉、微信等报警方式
- 优雅美观: 基于 Ant Design 的 UI 界面
- 开源免费: 前后端代码完全开源

-->

## 二、支持的版本(Tag)

由于版本比较多,这里只列出最新的5个版本,更详细的版本列表请参考:[可用版本列表](https://hub.docker.com/r/easysoft/umami/tags/)

<!-- 这里是应用的【Tag】信息，通过命令维护，详情参考：https://github.com/quicklyon/doc-toolkit -->
- [latest](https://github.com/umami-software/umami/releases/tags)
- [1.36.1](https://github.com/umami-software/umami/releases/tag/v1.36.1)
- [1.36.0](https://github.com/umami-software/umami/releases/tag/v1.36.0)

## 三、获取镜像

推荐从 [Docker Hub Registry](https://hub.docker.com/r/easysoft/umami) 拉取我们构建好的官方Docker镜像。

```bash
docker pull easysoft/umami:latest
```

如需使用指定的版本，可以拉取一个包含版本标签的镜像，在Docker Hub仓库中查看 [可用版本列表](https://hub.docker.com/r/easysoft/umami/tags/)

```bash
docker pull easysoft/umami:[TAG]
```

## 四、持久化数据

如果你删除容器，所有的数据都将被删除，下次运行镜像时会重新初始化数据。为了避免数据丢失，你应该为容器提供一个挂在卷，这样可以将数据进行持久化存储。

为了数据持久化，你应该挂载持久化目录：

- /data 持久化数据

如果挂载的目录为空，首次启动会自动初始化相关文件

```bash
$ docker run -it \
    -v $PWD/data:/data \
docker pull easysoft/umami:latest
```

或者修改 docker-compose.yml 文件，添加持久化目录配置

```bash
services:
  umami:
  ...
    volumes:
      - /path/to/gogs-persistence:/data
  ...
```

## 五、环境变量

| 变量名                 | 默认值        | 说明                             |
| ----------------       | ------------- | -------------------------------- |
| MYSQL_HOST             | 127.0.0.1     | MySQL 主机地址                   |
| MYSQL_PORT             | 3306          | MySQL 端口                       |
| MYSQL_DATABASE         | umami         | umami 数据库名称                 |
| MYSQL_USER             | root          | MySQL 用户名                      |
| MYSQL_PASSWORD         | pass4Spug     | MySQL 密码                        |
| DEFAULT_ADMIN_USER     | admin         | 默认管理员名称             |
| DEFAULT_ADMIN_PASSWORD | umami         | 默认管理员密码 |

## 六、运行

### 6.1 单机Docker-compose方式运行

```bash
# 启动服务
make run

# 查看服务状态
make ps

# 查看服务日志
docker-compose logs -f gogs

```

<!-- 这里写应用的【make命令的备注信息】位于文档最后端 -->
<!-- 示例
**说明:**

- 启动成功后，打开浏览器输入 `http://<你的IP>:8080` 访问管理后台
- 默认用户名：`admin`，默认密码：`spug.dev`
- [VERSION]({{APP_GIT_URL}}/blob/main/VERSION) 文件中详细的定义了Makefile可以操作的版本
- [docker-compose.yml]({{APP_GIT_URL}}/blob/main/docker-compose.yml)
-->

**说明:**

- 启动成功后，打开浏览器输入 `http://<你的IP>:3000` 访问服务。
- 默认用户名：`admin`，默认密码：`umami`。
