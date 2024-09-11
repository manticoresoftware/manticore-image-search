<?php declare(strict_types=1);
/**
 * @route home
 */

use App\Core\Manticore;
$image_list = Manticore::getRandomList()->unwrap();

