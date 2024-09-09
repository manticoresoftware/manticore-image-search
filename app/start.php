<?php declare(strict_types=1);

// This file includes when we start our application App::start()

container('embed', static function () {
	$host = config('embed.host');
	$port = config('embed.port');
	$url = "http://$host:$port";
	return App\Core\Embed::new($url);
});

