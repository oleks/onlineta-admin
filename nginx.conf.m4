server {
  root /home/COURSE_NAME/static;

  charset utf-8;

  index index.html;

  server_name COURSE_URL;

  location / {
    try_files $uri $uri/ =404;
  }

  location ~ (/grade/) {
    include /etc/nginx/proxy_params;
    proxy_pass            http://localhost:COURSE_PROXY_PORT;
    proxy_read_timeout    240s;
    client_max_body_size  4M;
  }
}
