<?php declare(strict_types=1);

namespace App\Core;

use Exception;
use Manticoresearch\Client;
use Manticoresearch\Exceptions\NoMoreNodesException;
use Manticoresearch\Exceptions\RuntimeException;
use Manticoresearch\Query\KnnQuery;
use Manticoresearch\Search;
use Result;
use Throwable;

/** @package App\Lib */
class Manticore {
	/**
	 * Get current instance of the client
	 * @return Client
	 */
	public static function client(): Client {
		static $client;

		if (!$client) {
			$client = new Client(config('manticore'));
		}

		return $client;
	}

	/**
	 * Add any type of model to the index on permanent store
	 * @param array<Model> $list
	 * @return Result
	 */
	public static function add(array $list): Result {
		if (!$list) {
			return ok();
		}

		$table = $list[0]->tableName();
		try {
			$client = static::client();
			// If table is missing create it
			if (!static::isTableExists($table)) {
				$client->sql($list[0]->createTableSql(), true);
			}
			$index = $client->index($table);
			$docs = array_map(fn ($v) => (array)$v, $list);
			$index->replaceDocuments($docs);
			return ok();
		} catch (Throwable) {
			return err("e_add_{$table}_failed");
		}
	}

	/**
	 * @param string $table
	 * @return bool
	 * @throws NoMoreNodesException
	 * @throws Exception
	 * @throws RuntimeException
	 */
	public static function isTableExists(string $table): bool {
		static $exist_cache = [];
		$has_cache = $exist_cache[$table] ?? false;
		if ($has_cache) {
			return true;
		}

		$client = static::client();
		$list = $client->sql("SHOW TABLES LIKE '$table'", true);
		$count = sizeof($list);
		$exists = $count === 1;
		if ($exists) {
			$exist_cache[$table] = true;
		}

		return $exists;
	}

	/**
	 * Get random list of images that we display on the main image by default
	 * @return Result<array<Model>>
	 */
	public static function getRandomList(): Result {
		$Client = static::client();
		$list = $Client->sql('SELECT * FROM image ORDER BY RAND() LIMIT 128');
		$hits = $list['hits']['hits'] ?? [];
		$docs = [];
		if ($hits) {
			foreach ($hits as $hit) {
				$docs[] = ['id' => $hit['_id'], ... $hit['_source']];
			}
		}
		return ok($docs);
	}

	/**
	 * Perform the multimodel search and return combined list
	 * @param  array<float> $embeddings
	 * @param int $offset
	 * @return Result<array{time:int,list:array<Model>}>
	 */
	public static function search(array $embeddings, int $offset = 0): Result {
		$time = 0;

		$items = [];
		$search = static::getSearch('image', $embeddings);
		$search->offset($offset);
		$search->limit(128);
		$docs = $search->get();
		$time += (int)($docs->getResponse()->getTime() * 1000);
		$count = $docs->getTotal();
		$count_relation = $docs->getResponse()->getResponse()['hits']['total_relation'] ?? 'eq';

		foreach ($docs as $doc) {
			$row = ['id' => (int)$doc->getId(), ...$doc->getData()];
			$items[] = $row;
		}

		$counters = [
			'total' => $count,
			'total_more' => $count_relation !== 'eq',
		];

		return ok(
			[
			'time' => $time,
			'items' => $items,
			'count' => $counters,
			]
		);
	}

	/**
	 * Find similar by id
	 * @param int $id
	 * @return Result<array{time:int,list:array<Model>}>
	 * @throws NoMoreNodesException
	 * @throws RuntimeException
	 */
	public static function searchById(int $id): Result {
		$Client = static::client();
		$t = microtime(true);
		$list = $Client->sql(sprintf('SELECT * FROM image WHERE knn(embeddings, 10, %s) LIMIT 128', $id), true);
		$time = (int)((microtime(true) - $t) * 1000);
		$docs = [];
		foreach ($list as $id => $doc) {
			$docs[] = ['id' => $id, ...$doc];
		}

		return ok([
			'time' => $time,
			'items' => $docs,
			'count' => [
				'total' => sizeof($docs),
				'total_more' => false,
			],
		]);
	}

	/**
	 * Get the search object by table name
	 * @param  string $table
	 * @param  string $query
	 * @param  array  $filters
	 * @return Search
	 */
	protected static function getSearch(string $table, array $embeddings): Search {
		$client = static::client();
		$Index = $client->index($table);
		$Query = new KnnQuery('embeddings', $embeddings, 10);
		return $Index->search($Query);
	}
}
