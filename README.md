👉 : у пальца - ОТВЕТЫ, РЕШНИЯ
# Дипломный практикум в Yandex.Cloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;  
(👉Выбрал подешевле standard-v2)
- Следует использовать последнюю стабильную версию [Terraform](https://www.terraform.io/).  
(👉Ок. Они еще под санкции повернулись как избушка, к лесу передом)

Предварительная подготовка к установке и запуску Kubernetes кластера.  
(<font color=red><b>👉Нашел заготовку розлива к8с на яндекс поправил под задачу</b></font>)
1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
(👉пользователь admin)
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: [Terraform Cloud](https://app.terraform.io/)  
   б. Альтернативный вариант: S3 bucket в созданном ЯО аккаунте  
   (👉выбираю б:)
3. Настройте [workspaces](https://www.terraform.io/docs/language/state/workspaces.html)  
   а. Рекомендуемый вариант: создайте два workspace: *stage* и *prod*. В случае выбора этого варианта все последующие шаги должны учитывать факт существования нескольких workspace.  
   б. Альтернативный вариант: используйте один workspace, назвав его *stage*. Пожалуйста, не используйте workspace, создаваемый Terraform-ом по-умолчанию (*default*).  
  ![image](https://user-images.githubusercontent.com/30965391/170765085-1625b02f-28f3-4aee-9ecc-37614db47030.png)
4. Создайте VPC с подсетями в разных зонах доступности.
(👉так и работает)
5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
(👉 cluster_install.sh и ./cluster_destroy.sh)
6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
 👉в Папке diplom/1.Инфраструктура/kubespray_terraform_yandex_cloud/**kubespray_terraform_yandex_cloud.zip** находится сконфигурированный куберспрей.  Нужно вписать свои реквизиты яндекса  
 1.Инфраструктура/kubespray_terraform_yandex_cloud/terraform/private.auto.tfvars  
 👉  
 ![image](https://user-images.githubusercontent.com/30965391/170766845-dd5cf67d-304b-4408-ad13-db1bcf5b40ba.png)  
👉  
 и поменять для букета тоже свое поставить в k8s-cluster.tf  
 ![image](https://user-images.githubusercontent.com/30965391/170766738-d165cfeb-c9fc-4139-818c-5b352933b92b.png)  

 и запустить cluster_install.sh - развернетутся сервера, и на них разольется кластер кубера. Нашел это в интернетах, подправил скоипты, т.к. в оригинале разворачивались по 3 инстанса нод. если не больше. + поменял ямл указав тип продукта подешевле ну и можно его еще ужать для экономии.
Развернется кластер, по одной ноде из:контрол,воркер,ингресс.

2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.    
👉 cluster_install.sh работает норм: при зачистке под себя, удалил ингресс развертку, потом добавил в ямлы, аут-пут варс и запустил скрипт, развернулось только то что нехватало, ну как и работает терраформ, правда время ушло минут 5-10  
  ![image](https://user-images.githubusercontent.com/30965391/170764376-7bd180f4-2ffc-48fc-8485-93624a9b409a.png)  

---
### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray]
   (https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)   
   👉этот вариант 
   
   ![image](https://user-images.githubusercontent.com/30965391/170765439-376d518a-cd5a-4a1f-b233-3e37a0cea884.png)  

   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать региональный мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.  
 ![image](https://user-images.githubusercontent.com/30965391/170765566-d4242a50-fae3-43b1-a48b-5ac36b0d0294.png)  

3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.  
![image](https://user-images.githubusercontent.com/30965391/170765643-14276e78-1695-413c-94b7-0d8b7db28720.png)  

---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
   👉 Этот вариант
   
```
   FROM python:3.6.0-alpine
   ADD static/ /src
   WORKDIR /src
   EXPOSE  8080
   ENTRYPOINT ["python3", "-m", "http.server", "8080"]
```
   index.html:  
   
```
        <html>
         <head>
          <meta charset="utf-8">
          <title>Учение - свет </title>
         </head>
         <H1>Привет, человек! я сервис версии 0.1diplom-prepare</H1>
```
   
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.  
👉В процессе...
2. Регистр с собранным docker image. В качестве регистра может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.  

👉У меня есть свой репозиторий. я пробросил его в интернет(пока бери кто хочешь) и использую его в кубере для деплоев. Планирую использовать его в gitlab для CI-CD    
![image](https://user-images.githubusercontent.com/30965391/170768613-309a8221-19ca-4596-88fa-ae96ff3852b4.png)

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Рекомендуемый способ выполнения:
1. Воспользовать пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). При желании можете собрать все эти приложения отдельно.  

👉СМ файл helm.txt в папке 3 monitoring  
![image](https://user-images.githubusercontent.com/30965391/170775562-1e9a84fd-8661-41e4-84dd-b42213de63a3.png)

2. Для организации конфигурации использовать [qbec](https://qbec.io/), основанный на [jsonnet](https://jsonnet.org/). Обратите внимание на имеющиеся функции для интеграции helm конфигов и [helm charts](https://helm.sh/)  
👉непонял зачем
3. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте в кластер [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры.

Альтернативный вариант:
1. Для организации конфигурации можно использовать [helm charts](https://helm.sh/)
👉так и сделал  
Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
СМ файл helm.txt в папке 3 monitoring  
2. Http доступ к web интерфейсу grafana.  
👉http://51.250.29.120:30674/  
admin  
prom-operator  
3. Дашборды в grafana отображающие состояние Kubernetes кластера.  
👉  
![image](https://user-images.githubusercontent.com/30965391/170775932-fed562d5-e347-4d80-a94a-ce30a1bbfc18.png)  
![image](https://user-images.githubusercontent.com/30965391/170838695-42f22690-bafb-4a49-8e10-ddc5e022c2bb.png)  


4. Http доступ к тестовому приложению. 
👉  
![image](https://user-images.githubusercontent.com/30965391/170776296-d12dab89-0283-457a-8b5c-6dab8c5f77e4.png)  

![image](https://user-images.githubusercontent.com/30965391/170776257-4624f370-3316-4f44-a0be-7b2dd0aa48eb.png)  





👉Остальное после проверки, ок? движемся дальше, есть замечания?




---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
👉 Делаю так: комитим со строкой "**Autostart job.**", запускается джоб.
2. Автоматический деплой нового docker образа.  
👉
![image](https://user-images.githubusercontent.com/30965391/170844794-9c868d46-427a-4b92-8795-acd1c0fbd9ae.png)


![image](https://user-images.githubusercontent.com/30965391/170844782-adadcc2a-a1b5-400b-a860-7ec72455d46b.png)


Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/) либо [gitlab ci](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/)

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.  
👉Не понял зачем.  
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.  
👉работает.  
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистр, а также деплой соответствующего Docker образа в кластер Kubernetes.  
👉Сделал так: если тег начинается с v*, то тогда происходит деплой, имя тега пробрасывается  в index.php  
![image](https://user-images.githubusercontent.com/30965391/170864617-a512ff16-f97f-4702-bc43-bab7c60d8c10.png)  
![image](https://user-images.githubusercontent.com/30965391/170864705-47bf1dcb-4734-4215-966e-6e5551ab6ca2.png)  


👉Вот файл .gitlab-ci.yml:  
```
  test: 
    stage: test

    image:
      name: gcr.io/kaniko-project/executor:debug
      entrypoint: [""]
    script:
      - mkdir -p /kaniko/.docker
      - echo "{\"auths\":{\"${CI_REGISTRY}\":{\"auth\":\"$(printf "%s:%s" "${CI_REGISTRY_USER}" "${CI_REGISTRY_PASSWORD}" | base64 | tr -d '\n')\"}}}" > /kaniko/.docker/config.json
      - >-
        /kaniko/executor
        --context "${CI_PROJECT_DIR}"
        --dockerfile "${CI_PROJECT_DIR}/Dockerfile"
        --destination "${CI_REGISTRY_IMAGE}:test${CI_COMMIT_TAG}"
    rules:
    - if: '$CI_COMMIT_MESSAGE != "" && $CI_COMMIT_TAG !~ /^v/'
      when: always



  build:
    stage: build
    image:
      name: gcr.io/kaniko-project/executor:debug
      entrypoint: [""]
    script:
      - mkdir -p /kaniko/.docker
      - echo "{\"auths\":{\"${CI_REGISTRY}\":{\"auth\":\"$(printf "%s:%s" "${CI_REGISTRY_USER}" "${CI_REGISTRY_PASSWORD}" | base64 | tr -d '\n')\"}}}" > /kaniko/.docker/config.json
      - echo "<br>TAG ${CI_COMMIT_TAG}" >> "${CI_PROJECT_DIR}"/static/index.html
      - >-
        /kaniko/executor
        --context "${CI_PROJECT_DIR}"
        --dockerfile "${CI_PROJECT_DIR}/Dockerfile"
        --destination "${CI_REGISTRY_IMAGE}:${CI_COMMIT_TAG}"
    rules:
    - if: '$CI_COMMIT_MESSAGE != ""'
      when: always

  deploy:
    stage: deploy
    rules:
    - if: '$CI_COMMIT_TAG =~ /^v/'
      when: always
    image:
      name: bitnami/kubectl:latest
      entrypoint: ['']
    script:
      - kubectl config get-contexts
      - kubectl config use-context lyambdazond/diplom:yandex
      - kubectl apply -f https://gitlab.com/lyambdazond/diplom/-/raw/"${CI_COMMIT_TAG}"/app.yaml
      - kubectl set image deployment/front front=registry.gitlab.com/lyambdazond/diplom:"${CI_COMMIT_TAG}" -n prod
      - kubectl rollout restart deployment/front -n prod

```
👉Исправил косяк в сервисе:  
![image](https://user-images.githubusercontent.com/30965391/170865083-7fa7d589-3a6a-4b56-9f76-644d5de8d864.png)  
теперь работает без трюка kubectl patch svc front-svc --namespace prod  -p '{"spec":{"externalIPs":["51.250.29.120"]}}'  
![image](https://user-images.githubusercontent.com/30965391/170865058-a1c6b62a-a208-47db-9437-1ee3eb3f72b6.png)  


---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.  
👉УФФ я готов))  
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud.  
👉 снимки с экрана яндекса и фаил-архив для развертывания куберспреем  
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.  
👉аналогично  
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.  
👉https://gitlab.com/lyambdazond/diplom/-/tree/main  
https://registry.gitlab.com/lyambdazond/diplom:v.9.9.9  
при деплое сначала деплоится latest, и тут же апдейтетится на абослют строку:  
![image](https://user-images.githubusercontent.com/30965391/170865484-6a66e982-2903-43fb-8d35-97fe8ed07db1.png)  

5. Репозиторий с конфигурацией Kubernetes кластера.  
👉это все в зип архиве куберспрея  https://github.com/wonderphp/diplom/tree/main/1.%D0%98%D0%BD%D1%84%D1%80%D0%B0%D1%81%D1%82%D1%80%D1%83%D0%BA%D1%82%D1%83%D1%80%D0%B0#:~:text=kubespray_terraform_yandex_cloud.zip
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.  
👉http://51.250.29.120:30674/d/ECrCV4rnz/isaev-diplom-yandexcloud?orgId=1&refresh=10s&from=now-5m&to=now  
admin  
prom-operator  
обновил веб страницу тестовго приложения множество раз ctrl+r, график "обогатился":  
![image](https://user-images.githubusercontent.com/30965391/170865610-fd60d542-a904-4ecd-aa2a-efa724b8e18d.png)
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)  
👉все что наработал лежит в репо гит**хаб** https://github.com/wonderphp/diplom/, что то стало неактуально, мб есть мусор.Файлы тестового приклада изменились до актуала и лежат в гит**лабе**  

---
## Как правильно задавать вопросы дипломному руководителю?

Что поможет решить большинство частых проблем:

1. Попробовать найти ответ сначала самостоятельно в интернете или в 
  материалах курса и ДЗ и только после этого спрашивать у дипломного 
  руководителя. Скилл поиска ответов пригодится вам в профессиональной 
  деятельности.
2. Если вопросов больше одного, то присылайте их в виде нумерованного 
  списка. Так дипломному руководителю будет проще отвечать на каждый из 
  них.
3. При необходимости прикрепите к вопросу скриншоты и стрелочкой 
  покажите, где не получается.

Что может стать источником проблем:

1. Вопросы вида «Ничего не работает. Не запускается. Всё сломалось». 
  Дипломный руководитель не сможет ответить на такой вопрос без 
  дополнительных уточнений. Цените своё время и время других.
2. Откладывание выполнения курсового проекта на последний момент.
3. Ожидание моментального ответа на свой вопрос. Дипломные руководители работающие разработчики, которые занимаются, кроме преподавания, 
  своими проектами. Их время ограничено, поэтому постарайтесь задавать правильные вопросы, чтобы получать быстрые ответы :)
