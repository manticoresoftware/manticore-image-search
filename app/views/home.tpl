<header>
	<div class="header-left">
		<h1>Image Search</h1>
		<span>Demo by <a href="https://manticoresearch.com" target="_blank" rel="noopener noreferrer">Manticore Search</a></span>
	</div>
	<div class="header-center">
		<div class="search-container">
			<input type="text" id="searchInput" class="search-input" placeholder="Search images...">
			<button id="uploadButton" class="icon-button upload-icon">
				<i class="fas fa-image"></i>
			</button>
			<button id="searchButton" class="icon-button">
				<i class="fas fa-search"></i>
			</button>
		</div>
	</div>
	<div class="header-right">
		<a href="https://github.com/manticoresoftware/manticore-image-search" class="github-link" target="_blank" rel="noopener noreferrer">{>icon/github} GitHub</a>
	</div>
</header>
<main>
	<div id="dragDropArea" class="drag-drop-area">
		<p>Drag and drop an image here or click to select</p>
		<input type="file" id="fileInput" style="display: none;" accept="image/*">
	</div>
	<div class="search-results-info">
		<div id="image-preview" style="display: none; text-align: center; margin: 10px 0;">
			<img src="" alt="Preview" style="max-width: 100px; max-height: 100px;">
		</div>
		Found <span id="result-count">0</span> results in <span id="search-time">0</span> ms
	</div>
	<div class="image-grid" id="image-list">
		<!-- Add your images here -->
		<img src="https://via.placeholder.com/300" alt="Image 1">
		<img src="https://via.placeholder.com/300" alt="Image 2">
		<img src="https://via.placeholder.com/300" alt="Image 3">
		<img src="https://via.placeholder.com/300" alt="Image 4">
		<img src="https://via.placeholder.com/300" alt="Image 5">
		<img src="https://via.placeholder.com/300" alt="Image 6">
		<!-- Add more images as needed -->
	</div>
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
	const searchResultsCount = document.getElementById('result-count')
	const searchTime = document.getElementById('search-time')
	searchResultsCount.textContent = data.count.total + (data.count.total_more ? '+' : '');
	searchTime.textContent = data.time.toFixed(0);
	data.items.forEach(result => {
		const img = document.createElement('img');
		img.src = result.image_path;
		img.alt = result.alt;
		imageList.appendChild(img);
	});
};

function performSearch() {
	var searchTerm = document.getElementById('searchInput').value;

	// Reset preview image first
	const imagePreview = document.getElementById('image-preview');
	imagePreview.style.display = 'none'; // Hide preview

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
}

document.getElementById('searchButton').addEventListener('click', performSearch);

document.getElementById('searchInput').addEventListener('keypress', function(event) {
	if (event.key === 'Enter') {
		event.preventDefault();
		performSearch();
	}
});

document.getElementById('uploadButton').addEventListener('click', function() {
	const dragDropArea = document.getElementById('dragDropArea');
	dragDropArea.classList.toggle('active');
});

const dragDropArea = document.getElementById('dragDropArea');

dragDropArea.addEventListener('click', function(e) {
	e.stopPropagation(); // Prevent the click from bubbling up
	document.getElementById('fileInput').click();
});

dragDropArea.addEventListener('dragover', function(e) {
	e.preventDefault();
	this.style.borderColor = '#000';
});

dragDropArea.addEventListener('dragleave', function(e) {
	e.preventDefault();
	this.style.borderColor = '#ccc';
});

dragDropArea.addEventListener('drop', function(e) {
	e.preventDefault();
	this.style.borderColor = '#ccc';
	const file = e.dataTransfer.files[0];
	handleFile(file);
});

function handleFile(file) {
	if (file) {
		// Reset preview image first
		const imagePreview = document.getElementById('image-preview');
		imagePreview.style.display = 'none'; // Hide preview

		// Show preview
		const reader = new FileReader();
		reader.onload = function(e) {
			const previewDiv = document.getElementById('image-preview');
			const previewImg = previewDiv.querySelector('img');
			previewImg.src = e.target.result;
			previewDiv.style.display = 'block';
		}
		reader.readAsDataURL(file);

		// Process upload now
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
			});
	}
}

document.getElementById('fileInput').addEventListener('change', function(event) {
	const file = event.target.files[0];
	handleFile(file);
});

// Prevent the upload dialog from showing when clicking on images
document.getElementById('image-list').addEventListener('click', function(e) {
	if (e.target.tagName === 'IMG') {
		e.preventDefault();
	}
});
</script>
