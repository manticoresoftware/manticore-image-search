<?php declare(strict_types=1);

system(
	'echo "' . config('server.auth_name')
		. ':"$(openssl passwd -apr1 '
		. escapeshellarg(config('server.auth_pass'))
		. ') > $CONFIG_DIR/.htpasswd'
);

$routes = Env::load(config('common.uri_map_file'));
uasort(
	$routes, function ($a, $b) {
		return (sizeof($a) > sizeof($b)) ? 1 : -1;
	}
);

$lang_type = config('common.lang_type');

$lang_match = match ($lang_type) {
	'path' => implode('|', config('common.languages')),
	default => null
};

$rewrites = [];
foreach ($routes as $route => $params) {
	// First zone, after action and rest of is params
	$zone = array_shift($params);
	$action = array_shift($params);
	$i = 0; // route like (bla (bla bla)) with uff8 cant handle by nginx. so hack it
	$uri = '/?ROUTE=' . preg_replace_callback('|\([^\)]+\)|is', fn() => '$' . ++$i, $route)
	. '&ACTION=' . $action
	;

	// If we have something more,foreach it
	foreach ($params as $k => $v) {
		$uri .= '&' . $v . '=$' . ($k + 1);
	}

	$rewrites[$zone] ??= [];
	// If we have lang_type = path
	if ($lang_match) {
		if ($route === 'home') { // Set root
			$rewrites[$zone][] = "rewrite '^/(?:$lang_match)/?$' '$uri';";
		}
		$route = "(?:$lang_match)/$route";
	}

	$rewrites[$zone][] = "rewrite '^/$route/?$' '$uri';";
}

// Form domain related rewrite rules
$domain = config('common.domain');
$rewrite_rules = '';
foreach ($rewrites as $zone => $rules) {
	// Special case for www we use single domain
	if ($zone === 'www') {
		$condition = "\$host = {$domain}";
	} else {
		$condition = "\$host = {$zone}.{$domain}";
	}
	$rewrite_rules .= "if ({$condition}) {" . PHP_EOL
	. implode(PHP_EOL, $rules) . PHP_EOL
	. '}' . PHP_EOL;
}

// Prepare all server names we should use
$zones = config('common.zones');
// Exclude zones which we explicit set
$zones = array_filter($zones, fn($zone) => $zone !== 'ws');
$ws_domain = "ws.{$domain}";
$domains = array_map(
	fn($zone) => "{$zone}.{$domain}",
	$zones
);
// If there is www in zones we unshift domain without www
if (in_array('www', $zones)) {
	array_unshift($domains, $domain);
}
$server_names = implode(' ', $domains);

// Static dir map
$static_dir = getenv('STATIC_DIR');
// Extract default_zone that is used for default static dir
array_shift($zones);
$static_dir_map = implode(
	PHP_EOL, array_map(
		fn($zone) => "{$zone}.{$domain} {$static_dir}/{$zone};",
		$zones
	)
);

// Create directories for static files if not exists
array_map(fn($zone) => mkdir($static_dir . "/{$zone}"), $zones);

Env::configure(
	__DIR__, [
		'{{UPLOAD_MAX_FILESIZE}}' => config('common.upload_max_filesize'),
		'{{SERVER_NAME}}' => $server_names,
		'{{SERVER_PORT}}' => config('server.port'),
		'{{STATIC_DIR_MAP}}' => $static_dir_map,
		'{{RESTRICTED_ROUTES}}' => config('server.auth_routes'),
		'{{REWRITE_RULES}}' => $rewrite_rules,
		'{{CORS_ORIGIN}}' => config('cors.origin'),
		'{{CORS_METHODS}}' => config('cors.methods'),
		'{{CORS_HEADERS}}' => config('cors.headers'),
		'{{CORS_CREDENTIALS}}' => config('cors.credentials'),
		'{{OPEN_FILE_CACHE}}' => config('server.open_file_cache'),
		'{{WS_HOST}}' => config('ws.host'),
		'{{WS_PORT}}' => config('ws.port'),
		'{{WS_SERVER_NAME}}' => $ws_domain,
	]
);
