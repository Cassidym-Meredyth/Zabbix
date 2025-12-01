package main

import (
	"log"
	"net/http"
	"os"
	"os/exec"
	"time"
)

const (
	nginxURL = "http://192.168.10.30/"
	interval = 30 * time.Second
)

func main() {
	f, err := os.OpenFile("/var/log/nginx/nginx-check.log",
		os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Fatalf("cannot open log file: %v", err)
	}
	defer f.Close()
	log.SetOutput(f)

	for {
		ok := checkNginx()
		if !ok {
			log.Println("Nginx недоступен! Перезапуск...")
			restartNginx()
		} else {
			log.Println("Nginx OK")
		}
		time.Sleep(interval)
	}
}

func checkNginx() bool {
	client := http.Client{Timeout: 5 * time.Second}
	resp, err := client.Get(nginxURL)
	if err != nil {
		return false
	}
	defer resp.Body.Close()
	return resp.StatusCode == 200
}

func restartNginx() {
	cmd := exec.Command("/bin/sh", "/restart-nginx.sh")
	if err := cmd.Run(); err != nil {
		log.Println("Ошибка перезапуска Nginx:", err)
	}
}
