export APP_NAME=umami
export TAG := $(shell cat VERSION)
export BUILD_DATE := $(shell date +'%Y%m%d')

help: ## this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## 构建镜像
	docker build --build-arg VERSION=$(TAG) \
		--build-arg IS_CHINA="true" \
		--build-arg DATABASE_TYPE="mysql" \
		--build-arg DATABASE_URL="mysql://root:pass4Umami@localhost:3306/umami" \
		-t hub.qucheng.com/app/$(APP_NAME):$(TAG)-$(BUILD_DATE) -f Dockerfile .

build-public: ## 国外构建镜像
	docker build --build-arg VERSION=$(VERSION) --build-arg IS_CHINA="false" -t easysoft/$(APP_NAME):$(TAG) -f Dockerfile .
	docker tag easysoft/$(APP_NAME):$(TAG) easysoft/$(APP_NAME)

push: ## push 镜像到 hub.qucheng.com
	docker push hub.qucheng.com/app/$(APP_NAME):$(TAG)-$(BUILD_DATE)

push-public: ## push 镜像到 hub.docker.com
	docker push easysoft/$(APP_NAME):$(TAG)
	docker push easysoft/$(APP_NAME):latest

push-sync-tcr: push-public ## 同步到腾讯镜像仓库
	curl http://i.haogs.cn:3839/sync?image=easysoft/$(APP_NAME):$(TAG)
	curl http://i.haogs.cn:3839/sync?image=easysoft/$(APP_NAME):latest

run: ## 运行
	export TAG=$(TAG)-$(BUILD_DATE) ;docker-compose -f docker-compose.yml up -d

ps: ## 运行状态
	docker-compose -f docker-compose.yml ps

stop: ## 停服务
	docker-compose -f docker-compose.yml stop
	docker-compose -f docker-compose.yml rm -f

restart: build clean ps ## 重构

clean: stop ## 停服务
	docker-compose -f docker-compose.yml down
	docker volume prune -f

logs: ## 查看运行日志
	docker-compose -f docker-compose.yml logs
