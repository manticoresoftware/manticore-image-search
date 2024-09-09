<header>
	<div class="search-container">
		<input type="text" id="searchInput" class="search-input" placeholder="Search images...">
		<button id="searchButton" class="search-button">
			<i class="fas fa-search"></i>
		</button>
	</div>
	<div class="upload-container">
		<input type="file" id="fileInput" style="display: none;" accept="image/*">
		<button id="uploadButton" class="upload-button">
			<i class="fas fa-upload"></i> Upload
		</button>
	</div>
</header>

<main class="image-grid" id="image-list">
	<!-- Add your images here -->
	<img src="https://via.placeholder.com/300" alt="Image 1">
	<img src="https://via.placeholder.com/300" alt="Image 2">
	<img src="https://via.placeholder.com/300" alt="Image 3">
	<img src="https://via.placeholder.com/300" alt="Image 4">
	<img src="https://via.placeholder.com/300" alt="Image 5">
	<img src="https://via.placeholder.com/300" alt="Image 6">
	<!-- Add more images as needed -->
</main>
<script>
const renderFn = ([err, data]) => {
	const imageList = document.getElementById('image-list');
	if (err) {
		imageList.innerHTML = '<p>Error: ' + err + '</p>';
		console.error('Error:', err);
		return;
	}

	imageList.innerHTML = '';
	data.items.forEach(result => {
		const img = document.createElement('img');
		img.src = result.image_path;
		img.alt = result.alt;
		imageList.appendChild(img);
	});
};

document.getElementById('searchButton').addEventListener('click', function() {
	var searchTerm = document.getElementById('searchInput').value;

	fetch('/api/search-by-text', {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		},
		body: JSON.stringify({ query: searchTerm })
	})
		.then(response => response.json())
		.then(renderFn)
		.catch(error => {
			console.error('Error:', error);
		});
});

document.getElementById('uploadButton').addEventListener('click', function() {
	document.getElementById('fileInput').click();
});

document.getElementById('fileInput').addEventListener('change', function(event) {
	var file = event.target.files[0];

	if (file) {
		var formData = new FormData();
		formData.append('file', file);

		fetch('/api/search-by-image', {
			method: 'POST',
			body: formData
		})
			.then(response => {
				if (!response.ok) {
					throw new Error('Network response was not ok');
				}
				return response.json();
			})
			.then(renderFn)
			.catch(error => {
				console.error('Error:', error);
				// Handle any errors here
				// For example, you could display an error message to the user
			});
	}
});
</script>
