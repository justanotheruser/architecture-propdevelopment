Настроить кластер:
```bash
$ ./setup.sh
```
Применить политики:
```bash
minikube kubectl -- apply -f network_policies/
```
Как проверить, что необходимые соединения работают, а остальные запрещены:
```bash
$ minikube kubectl -- exec -it deploy/some-back-end-api -- sh
# curl --connect-timeout 2 http://some-front-end-app
<!DOCTYPE html>
<html>
<head>
...
# curl --connect-timeout 2 http://admin-front-end-app       
curl: (28) Failed to connect to admin-front-end-app port 80 after 2001 ms: Timeout was reached
# curl --connect-timeout 2 http://admin-back-end-api        
curl: (28) Failed to connect to admin-back-end-api port 80 after 2001 ms: Timeout was reached
```

Аналогично для остальных контейнеров