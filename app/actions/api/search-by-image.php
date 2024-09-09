<?php declare(strict_types=1);

/**
 * @route api/search-by-image
 */

use App\Core\Image;
use App\Core\Manticore;

$file = $_FILES['file'];
if ($file['error'] === UPLOAD_ERR_OK) {
	$Image = Image::upload($file['tmp_name'])->unwrap();
	$Embed = container('embed');
	$embeddings = $Embed->getImageEmbeddings($Image->getPath())->unwrap();
	return Manticore::search($embeddings);
}

return err('e_upload_failed', $file['error']);
