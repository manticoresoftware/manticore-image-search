<?php declare(strict_types=1);

/**
 * @route api/search-by-text
 * @var string $query
 */

use App\Core\Manticore;

$Embed = container('embed');
$embeddings = $Embed->getTextEmbeddings($query)->unwrap();
return Manticore::search($embeddings);
