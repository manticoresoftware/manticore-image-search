<?php declare(strict_types=1);

namespace App\Core;

use Result;
use Muvon\KISS\RequestTrait;

final class Embed {
	use RequestTrait;

	/**
	 * @param string $url
	 * @return void
	 */
	private function __construct(protected string $url) {
		$this->request_type = 'json';
		$this->request_timeout = 60;
	}

	/**
	 * @param string $url
	 * @return Embed
	 */
	public static function new(string $url): self {
		return new self($url);
	}

	/**
	 * Get embeddings for text
	 * @param string $text
	 * @return Result<array<float>>
	 */
	public function getTextEmbeddings(string $text): Result {
		if (!$text) {
			return err('e_text_empty');
		}
		$url = "{$this->url}/text";
		$res = $this->request($url, ['text' => $text]);
		[$err, $vector] = $res;
		if ($err) {
			return err($err);
		}
		return ok($vector);
	}

	/**
	 * Get embeddings for an image
	 * @param string $path
	 * @return Result<array<float>>
	 */
	public function getImageEmbeddings(string $path): Result {
		$url = "{$this->url}/image";
		$image_base64 = base64_encode(file_get_contents($path));
		$res = $this->request($url, ['image' => $image_base64]);
		[$err, $vector] = $res;
		if ($err) {
			return err($err);
		}
		return ok($vector);
	}

	/**
	 * Get image caption
	 * @param string $path
	 * @return Result
	 */
	public function getImageCaption(string $path): Result {
		$url = "{$this->url}/caption";
		$image_base64 = base64_encode(file_get_contents($path));
		$res = $this->request($url, ['image' => $image_base64]);
		[$err, $caption] = $res;
		if ($err) {
			return err($err);
		}
		return ok($caption);
	}
}
