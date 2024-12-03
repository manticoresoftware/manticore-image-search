<?php declare(strict_types=1);
/**
 * @route home
 */

use App\Core\Manticore;
$image_url_prefix = getenv('IMAGE_URL_PREFIX') ?: '';
$image_list = Manticore::getRandomList()->unwrap();

