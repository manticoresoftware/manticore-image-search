<?php declare(strict_types=1);

namespace App\Image;

use App\Core\Model;

final class ImageModel extends Model {
	public int $id;
	public string $image_path;
	/** @var array<float> */
	public array $embeddings;
	public string $caption;

	/**
	 * Get current table name for org
	 * @return string
	 */

	public function tableName(): string {
		return 'image';
	}

	/**
	 * @return string
	 */
	public function createTableSql(): string {
		$table = $this->tableName();
		return "CREATE TABLE IF NOT EXISTS {$table} (
			id bigint,
			image_path text,
			caption text,
			embeddings float_vector knn_type='hnsw' knn_dims='512' hnsw_similarity='COSINE'
			)";
	}
}

