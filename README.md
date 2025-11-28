# base_flutter 

# 初次运行或修改了需要生产的代码，需要先运行以下命令再运行服务
```bash
flutter pub run build_runner build --delete-conflicting-outputs
# 或
dart run build_runner build --delete-conflicting-outputs
```


# 启动代理以及web服务，访问地址kurama-server:14055
```bash
./start-web-dev.sh
# flutter run -d web-server --web-port 8080
```


# 编译成apk
```bash
flutter build apk
```

# 启动代理
```bash
dart ./lib/core/proxy.dart
```
