FROM nginx:stable

COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html

COPY nginx-check /usr/local/bin/nginx-check
COPY restart-nginx.sh /restart-nginx.sh

COPY start.sh /start.sh

RUN chmod +x /usr/local/bin/nginx-check /restart-nginx.sh /start.sh

EXPOSE 80

CMD ["/start.sh"]


