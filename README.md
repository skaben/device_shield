# smart_tester

основа для умного девайса.

- [ ] все Boilerplate переименуйте в желаемое имя устройства.
- [ ] опишите логику работы внутри `device.py`
- [ ] опишите минимальный конфиг внутри `config.py`
- [ ] перед стартом необходимо сказать `./pre-run.sh` для создания виртуального окружения и копирования системного конфига.
- [ ] не стоит забывать про виртуальное окружение, которое не активируется по умолчанию, `source ./venv/bin/activate`
- [ ] `python app.py` запустит приложение.

компоненты:

### device

содержит интерфейс с локальным конфигурационным файлом и отправки сообщений на сервер.

```
    state_reload -> загрузить текущий локальный конфиг из файла
    state_update(data -> dict) -> записать данные в локальный конфиг и послать на сервер
    send_message(data -> any) -> отправить сообщение без записи в локальный конфиг
```

### config

- системный конфиг генерируется из `system_config.yml.template`, в процессе работы приложения не изменяется, хранится в `conf/system.yml`.
- конфиг устройства (приложения) изменяется в ходе работы, при первом запуске минимальный конфиг, описанный в `config.ESSENTIAL` будет записан в файл `conf/device.yml`

## примеры

скажем, для устройства `Door`, имеющего параметр `closed`:

##### templates

правим темплейт в `templates/system_config.yml.template`
```
dev_type: <name>  # это определяет канал, который будет слушать устройство name/MAC-address
broker_ip: <broker ip address>
username: <optional mqtt username>
password: <optional mqtt password>
iface: ${iface}  # определит внешний интерфейс автоматически в процессе работы ./pre-run.sh
```
запускаем `./pre-run.sh`

##### config.py

здесь должны быть значения по умолчанию, без которых устройство не сможет запуститься.

```
ESSENTIAL = {
    "key": 'val'
}
```

##### device.py

Создаем класс с желаемым именем, не забываем поправить имя класса конфига.

```
class CloseDevice(BaseDevice)

    config_class = CloseConfig

    def __init__(self, system_config, device_config, **kwargs):
        super().__init__(system_config, device_config)
        self.running = None
```
описываем поведение устройства
```
    def run(self):
        super().run()
        self.running = True
        while self.running:
            status = self.check_status()
```
сохраняем состояние
```
            if status == "closed":
                self.state_update({"closed": True})
```
или отправляем любое сообщение о событии
```
            elif status == "touched":
                self.send_message("I was touched")
```
