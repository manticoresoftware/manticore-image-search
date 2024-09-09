<?php declare(strict_types=1);

namespace App\Core;

use Result;

/** @package App\Core */
class Image {
	protected string $image_path;
	private function __construct() {
	}

	/**
	 * @param string $image_path
	 * @return Image
	 */
	public static function new(string $image_path): self {
		$Self = new self();
		$Self->image_path = $image_path;
		return $Self;
	}

	/**
	 * Upload image to the server
	 * @param string $tmp_path
	 * @return Result<self>
	 */
	public static function upload(string $tmp_path): Result {
		$upload_dir = '/tmp/';
		$filename = uniqid() . '.jpg';
		$destination = $upload_dir . $filename;

		if (!is_dir($upload_dir)) {
			mkdir($upload_dir, 0755, true);
		}

		if (move_uploaded_file($tmp_path, $destination)) {
			$image_path = static::prepare($destination)->unwrap();
			return ok(static::new($image_path));
		} else {
			return err('e_image_move_failed');
		}
	}

	/**
	 * @param string $image_path
	 * @return Result<string>
	 */
	public static function prepare(string $image_path): Result {
		$resize_command = "convert {$image_path} -resize '512x512>' -quality 60 {$image_path}";
		exec($resize_command, $output, $return_var);

		if ($return_var === 0) {
			return ok($image_path);
		} else {
			return err('e_image_resize_failed');
		}
	}

	/**
	 * Get base64 encoded image
	 * @return string
	 */
	public function getBase64(): string {
		return base64_encode(file_get_contents($this->image_path));
	}

	/**
	 * Get the image path
	 * @return string
	 */
	public function getPath(): string {
		return $this->image_path;
	}
}
