<?php declare(strict_types=1);

/**
 * @route api/search-by-id
 * @var int $id
 */

use App\Core\Manticore;

return Manticore::searchById($id);
