common:
  alphabet: 'nGWZFAQcUxV2fqJtMmyR7BHwPXNrL9DijhCsvuaezpTS3gEdk546Yb8K'
  epoch: 1725775000
  secret: ''
  trigger_map_file: '{{CONFIG_DIR}}/trigger_event_map.php'
  trigger_param_file: '{{CONFIG_DIR}}/trigger_param_map.php'
  uri_map_file: '{{CONFIG_DIR}}/uri_request_map.php'
  param_map_file: '{{CONFIG_DIR}}/import_var_map.php'
  action_map_file: '{{CONFIG_DIR}}/action_map.php'
  upload_max_filesize: '10M'
  type: 'fpm'
  proto: 'http'
  domain: 'manticore-image-search.zz'
  zones:
    - 'www'
  lang_type: 'none'
  languages:
    - 'en'
  cli_level: 2

common:production:
  domain: 'image.manticoresearch.com'

default:
  action: 'home'

view:
  source_dir: '{{APP_DIR}}/views'
  compile_dir: '{{TMP_DIR}}/views'
  template_extension: 'tpl'
  strip_comments: false
  merge_lines: false

view:production:
  compile_dir: '{{TMP_DIR}}/{{PROJECT_REV}}/views'
  strip_comments: false
  merge_lines: false

session:
  name: 'SS'
  save_handler: 'files'
  save_depth: 2
  save_path: "{{TMP_DIR}}/{{PROJECT_REV}}/sessions"

server:
  port: 80
  ssl_port: 443
  auth_name: 'test'
  auth_pass: 'test'
  auth_routes: 'admin'
  open_file_cache: 'off'
  use_ssl: false

server:production:
  open_file_cache: 'max=100000 inactive=600s'
  use_ssl: true

cors:
  origin: '*'
  methods: 'GET, POST, PUT, DELETE, OPTIONS'
  headers: 'DNT,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Account-Token,API-Token,Request-Signature'
  credentials: 'true'

embed:
  host: 'embed'
  port: 8000

embed:production:
  host: '127.0.0.1'

manticore:
  host: 'manticore'
  port: 9308

manticore:production:
  host: '127.0.0.1'
