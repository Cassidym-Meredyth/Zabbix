# Сеть: приватная 192.168.10.0/24, статические IP
# SSH: доступ по ключам включен, логин Vagrant с базовым ключем. Парольный вход в sshd запрещено провижнингом
# ОС - Ubuntu 22.04 (ubuntu\jammy64)


Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/jammy64"
    config.vm.boot_timeout = 600
    config.vm.synced_folder ".", "/vagrant", disabled: false

    common_bootstrap = <<-SHELL
        echo "=== Обновление и установка пакетов ==="
        sudo apt-get update -y
        sudo apt-get install -y curl gnupg lsb-release ca-certificates openssh-client rsyslog rsyslog-gnutls jq

        echo "=== Настройка ssh ==="
        sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
        sudo sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
        sudo sed -i 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config

        if grep -qE '^[#\s]*ListenAddress' /etc/ssh/sshd_config; then
            sudo sed -i 's/^[#\s]*ListenAddress.*/ListenAddress 0.0.0.0/' /etc/ssh/sshd_config
        else
            echo 'ListenAddress 0.0.0.0' | sudo tee -a /etc/ssh/sshd_config
        fi

        sudo systemctl restart ssh || sudo systemctl restart sshd

        echo "=== Генерация ключей vagrant и экспорт ==="
        sudo -u vagrant bash -c '
            mkdir -p ~/.ssh && chmod 700 ~/.ssh
            if [ ! -f ~/.ssh/id_ed25519 ]; then
                ssh-keygen -t ed25519 -C "lab-$(hostname)" -N "" -f ~/.ssh/id_ed25519
            fi
            touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys
            PUB=$(cat ~/.ssh/id_ed25519.pub)
            grep -qF "$PUB" ~/.ssh/authorized_keys || echo "$PUB" >> ~/.ssh/authorized_keys
        '
        sudo cp -f ~vagrant/.ssh/id_ed25519.pub /vagrant/.ssh-$(hostname).pub

    SHELL

    # VM1 (Docker/Compose + Zabbix)
    config.vm.define "vm1-test" do |vm1|
        vm1.vm.hostname = "monitoring"
        vm1.vm.network "private_network", ip: "192.168.10.10"
        vm1.vm.provider "virtualbox" do |vb|
            vb.name = "VM10-monitor"
            vb.memory = 4096
            vb.cpus = 2
        end

        vm1.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
        vm1.vm.network "forwarded_port", guest: 8080, host: 8180, auto_correct: true

        vm1.vm.provision "shell", inline: common_bootstrap

        vm1.vm.provision "shell", inline: <<-SHELL
            files="/vagrant/.ssh-host2.pub /vagrant/.ssh-host3.pub /vagrant/.ssh-monitoring.pub"
            deadline=$((SECONDS+60))

            echo "=== Ожидаем ключи (макс 60 cек): $files ==="
            for f in $files; do
                while [ ! -f "$f" ] && [ $SECONDS -lt $deadline ]; do
                echo "  - ждём $f ..."
                sleep 2
                done
                if [ ! -f "$f" ]; then
                echo "WARN: нет $f — идём дальше без него"
                fi
            done

            echo "=== Собираем общий authorized_keys ==="
            cat /vagrant/.ssh-*.pub 2>/dev/null | sort -u > /vagrant/.ssh-cluster-authorized_keys || true

            echo "=== Кладём ключи на VM1 ==="
            sudo -u vagrant bash -c '
                mkdir -p ~/.ssh && chmod 700 ~/.ssh
                touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys
                [ -s /vagrant/.ssh-cluster-authorized_keys ] && cat /vagrant/.ssh-cluster-authorized_keys >> ~/.ssh/authorized_keys || true
                sort -u ~/.ssh/authorized_keys -o ~/.ssh/authorized_keys
            '

            echo "=== /etc/hosts для имён ==="
            sudo bash -c 'cat >/etc/hosts <<EOF
            127.0.0.1 localhost
            192.168.10.10 monitor
            192.168.10.20 host2
            192.168.10.30 host3'

            hostnamectl set-hostname monitor

            echo "=== Проверка SSH на VM1 ==="
            ss -tulpen | grep ":22" || true

            # Docker Engine + Compose plugin
            if ! command -v docker >/dev/null 2>&1; then
                sudo install -m 0755 -d /etc/apt/keyrings
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
                echo \
                    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
                    $(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
                    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                sudo apt-get update -y
                sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                sudo usermod -aG docker vagrant
            fi

            # Перемещаем 99-forward-tls.conf в rsyslog.d
            cp /vagrant/monitor/99-forward-tls.conf /etc/rsyslog.d/99-forward-tml.conf

            # Пишем cron и делаем проверку, если уже создан
            cron_line="*/1 * * * * sh /vagrant/monitor/zabbix/curl_fail500.sh >/dev/null 2>&1"
            ( crontab -l -u vagrant 2>/dev/null | grep -Fv "$cron_line"; echo "$cron_line" ) | crontab -u vagrant -

            # Переходим в нужную директорию и создаем volume для контейнеров
            cd /vagrant/monitor/zabbix/zabbix-data

            echo "=== Создание Volume для БД ==="
            docker volume create zabbix_patroni1_data
            docker volume create zabbix_patroni2_data

            ./initial_db.sh

            echo "=== Выдача прав для volume БД ==="
            chmod 700 /var/lib/docker/volumes/zabbix_patroni1_data/_data
            chown -R 999:999 /var/lib/docker/volumes/zabbix_patroni1_data/_data

            mkdir -p /var/lib/docker/volumes/zabbix_patroni2_data/_data
            chmod 700 /var/lib/docker/volumes/zabbix_patroni2_data/_data
            chown -R 999:999 /var/lib/docker/volumes/zabbix_patroni2_data/_data

            # Запускаем контейнеры
            cd /vagrant/monitor/zabbix

            docker compose up -d --build
            
            echo "=== Развертка завершена ==="
            echo "=== Перезагрузка... ==="
            reboot
        SHELL
    end

    # VM2 (Zabbix agent)
    config.vm.define "vm2-test" do |vm2|
        vm2.vm.hostname = "host2"
        vm2.vm.network "private_network", ip: "192.168.10.20"
        vm2.vm.provider "virtualbox" do |vb|
            vb.name = "VM20-host2"
            vb.memory = 2048
            vb.cpus = 2
        end

        vm2.vm.provision "shell", inline: common_bootstrap

        vm2.vm.provision "shell", inline: <<-SHELL
            sudo apt-get install -y htop net-tools
            # Подтянуть общий authorized_keys, если он уже собран VM1
            if [ -f /vagrant/.ssh-cluster-authorized_keys ]; then
                sudo -u vagrant bash -c '
                    mkdir -p ~/.ssh && chmod 700 ~/.ssh
                    touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys
                    cat /vagrant/.ssh-cluster-authorized_keys >> ~/.ssh/authorized_keys
                    sort -u ~/.ssh/authorized_keys -o ~/.ssh/authorized_keys
                '
                sudo cp -f ~vagrant/.ssh/id_ed25519.pub /vagrant/.ssh-$(hostname).pub
            fi

            hostnamectl set-hostname host2

            # Docker Compose
            if ! command -v docker >/dev/null 2>&1; then
                sudo install -m 0755 -d /etc/apt/keyrings
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
                echo \
                    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
                    $(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
                    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                sudo apt-get update -y
                sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                sudo usermod -aG docker vagrant
            fi
            
            sudo bash -c 'cat >/etc/hosts <<EOF
            127.0.0.1 localhost
            192.168.10.10 monitor
            192.168.10.20 host2
            192.168.10.30 host3'

            # Перемещаем 99-forward-tls.conf в rsyslog.d
            cp /vagrant/host2/99-forward-tls.conf /etc/rsyslog.d/99-forward-tml.conf

            cd /vagrant/host2/
            
            echo "== Запуск контейнеров ==="
            # Запускаем контейнеры
            docker compose up -d --build

            echo "=== Развертка завершена ==="
            echo "=== Перезагрузка... ==="
            reboot
        SHELL
    end

    # VM3 (Zabbix agent)
    config.vm.define "vm3-test" do |vm3|
        vm3.vm.hostname = "host3"
        vm3.vm.network "private_network", ip: "192.168.10.30"
        vm3.vm.provider "virtualbox" do |vb|
            vb.name = "VM30-host3"
            vb.memory = 2048
            vb.cpus = 2
        end

        vm3.vm.provision "shell", inline: common_bootstrap

        vm3.vm.provision "shell", inline: <<-SHELL
            sudo apt-get install -y htop net-tools
            # Подтянуть общий authorized_keys, если он уже собран VM1
            if [ -f /vagrant/.ssh-cluster-authorized_keys ]; then
                sudo -u vagrant bash -c '
                    mkdir -p ~/.ssh && chmod 700 ~/.ssh
                    touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys
                    cat /vagrant/.ssh-cluster-authorized_keys >> ~/.ssh/authorized_keys
                    sort -u ~/.ssh/authorized_keys -o ~/.ssh/authorized_keys
                '
                sudo cp -f ~vagrant/.ssh/id_ed25519.pub /vagrant/.ssh-$(hostname).pub
            fi

            hostnamectl set-hostname host3

            # Docker Compose
            if ! command -v docker >/dev/null 2>&1; then
                sudo install -m 0755 -d /etc/apt/keyrings
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
                echo \
                    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
                    $(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
                    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                sudo apt-get update -y
                sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                sudo usermod -aG docker vagrant
            fi

            sudo bash -c 'cat >/etc/hosts <<EOF
            127.0.0.1 localhost
            192.168.10.10 monitor
            192.168.10.20 host2
            192.168.10.30 host3'

            # Перемещаем 99-forward-tls.conf в rsyslog.d
            cp /vagrant/host3/99-forward-tls.conf /etc/rsyslog.d/99-forward-tml.conf

            mkdir -p /var/log/nginx/
            touch /var/log/nginx/nginx-check.log

            echo "=== Запуск контейнеров ==="
            # Запускаем контейнеры
            cd /vagrant/host3 && docker compose up -d --build
            
            /vagrant/host3/nginx/nginx-check > /dev/null 2>&1 &
            echo "=== Развертка завершена ==="
            echo "=== Перезагрузка... ==="
            reboot
        SHELL
    end
end