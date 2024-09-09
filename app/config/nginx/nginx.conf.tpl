log_format app
  '$remote_addr - $remote_user [$time_local] "$request" '
  '$status $body_bytes_sent "$http_referer" '
  '"$http_user_agent" "$http_x_forwarded_for" '
  '$upstream_response_time sec "$host"';

upstream app-fpm {
  server unix:{{RUN_DIR}}/php-fpm.sock;
}

map $host $static_dir {
	hostnames;
	default {{STATIC_DIR}};
	{{STATIC_DIR_MAP}}
}

server {
  error_log {{LOG_DIR}}/nginx-error.log;

  listen   {{SERVER_PORT}};
  {{SSL_LISTEN_DIRECTIVE}}

  {{SSL_CERT_DIRECTIVE}}
  {{SSL_CERT_KEY_DIRECTIVE}}

  server_name  {{SERVER_NAME}};
  client_max_body_size {{UPLOAD_MAX_FILESIZE}};

  include {{CONFIG_DIR}}/nginx_route_map.conf;

  open_file_cache {{OPEN_FILE_CACHE}}; # disable file cache for development
  root $static_dir;
	set $realm off;
	if ($request_uri ~ ^/({{RESTRICTED_ROUTES}})/) {
		set $realm Restricted;
	}
	if ($request_uri ~ "[?&]ROUTE=({{RESTRICTED_ROUTES}})") {
		set $realm Restricted;
	}

	auth_basic $realm;
	auth_basic_user_file {{CONFIG_DIR}}/.htpasswd;
  location = / {
    if ($request_method !~ ^(GET|HEAD|POST|PUT|DELETE|OPTIONS)$ ) {
      return 444;
    }

    if ($request_method = 'OPTIONS') {
      add_header 'Access-Control-Allow-Origin' '{{CORS_ORIGIN}}' always;
      add_header 'Access-Control-Allow-Credentials' '{{CORS_CREDENTIALS}}' always;
      add_header 'Access-Control-Allow-Methods' '{{CORS_METHODS}}' always;
      add_header 'Access-Control-Allow-Headers' '{{CORS_HEADERS}}' always;
      add_header 'Access-Control-Max-Age' 1728000;
      add_header 'Content-Type' 'text/plain charset=UTF-8';
      add_header 'Content-Length' 0;
      return 204;
    }

    try_files $uri @app;
    log_not_found  off;
    error_log      /dev/null;
  }

	location /files {
		alias {{ENV_DIR}}/files;
		autoindex on;
		try_files $uri $uri/ =404;

		location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
			expires 30d;
			add_header Cache-Control "public, no-transform";
		}

		location ~ /\. {
			deny all;
			access_log off;
			log_not_found off;
		}
	}

  location @app {
    access_log  {{LOG_DIR}}/nginx-access.log app buffer=32k;

    expires off;

    # CORS headers
    add_header 'Access-Control-Allow-Origin' '{{CORS_ORIGIN}}' always;
    add_header 'Access-Control-Allow-Credentials' '{{CORS_CREDENTIALS}}' always;
    add_header 'Access-Control-Allow-Methods' '{{CORS_METHODS}}' always;
    add_header 'Access-Control-Allow-Headers' '{{CORS_HEADERS}}' always;

    include        {{CONFIG_DIR}}/nginx_fastcgi_params;

    fastcgi_param  SCRIPT_FILENAME  {{APP_DIR}}/main.php;
    fastcgi_param  SCRIPT_NAME      {{APP_DIR}}/main.php;
    fastcgi_param  APP_ENV      {{APP_ENV}};

    fastcgi_pass   app-fpm;
  }

  # This location block is used to view PHP-FPM stats
  location = /php_status {
    deny all;

    include        {{CONFIG_DIR}}/nginx_fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $fastcgi_script_name;
    fastcgi_pass app-fpm;
  }
}

# Default server
server {
  listen {{SERVER_PORT}} default_server;
  server_name  _;

  # Stub status
  location = /nginx_status {
    allow 127.0.0.1;
    allow 10.0.0.0/8;
    allow 192.168.0.0/16;
    allow 172.16.0.0/12;
    deny all;

    stub_status on;
    access_log off;
  }

  location = /php_status {
    allow 127.0.0.1;
    allow 10.0.0.0/8;
    allow 192.168.0.0/16;
    allow 172.16.0.0/12;
    deny all;
    access_log off;

    include      {{CONFIG_DIR}}/nginx_fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $fastcgi_script_name;
    fastcgi_pass app-fpm;
  }

  location / {
    return 444;
  }
}
