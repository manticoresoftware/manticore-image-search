<header>
	<div class="header-left">
		<h1>Image Search</h1>
		<span>Demo by <a href="https://manticoresearch.com" target="_blank" rel="noopener noreferrer">Manticore Search</a></span>
	</div>
	<div class="header-center">
		<div class="search-container">
			<input type="text" id="search-input" class="search-input" placeholder="Search images...">
			<button id="upload-button" class="icon-button upload-icon">
				<i class="fas fa-image"></i>
			</button>
			<button id="search-button" class="icon-button">
				<i class="fas fa-search"></i>
			</button>
		</div>
	</div>
	<div class="header-right">
		<a href="https://github.com/manticoresoftware/manticore-image-search" class="github-link" target="_blank" rel="noopener noreferrer">{>icon/github} GitHub</a>
	</div>
</header>
<main>
	<div id="drag-drop-area" class="drag-drop-area">

		<p>{>icon/upload}</p>
		<p>Drag and drop an image here or <span>click to select</span></p>
		<input type="file" id="file-input" style="display: none;" accept="image/*">
	</div>
	<div class="search-results-info">
		<div id="image-preview" style="display: none; text-align: center; margin: 10px 0;">
			<img src="" alt="Preview" style="max-width: 100px; max-height: 100px;">
		</div>
		Found in <span id="search-time">0</span> ms
	</div>
	<div class="image-grid" id="image-list">
		{image_list}
		<div class="image-container">
			<img src="{image_path}" alt="{caption}" loading="lazy">
			<button class="show-similar-btn" data-id="{id}">Show similar</button>
		</div>
		{/image_list}
	</div>
</main>
<script>
function toggleDragDropArea() {
	const dragDropArea = document.getElementById('drag-drop-area');
	dragDropArea.classList.toggle('active');
}

function reset(text = false) {
	const dragDropArea = document.getElementById('drag-drop-area');
	dragDropArea.classList.remove('active');

	// Reset preview image first
	const imagePreview = document.getElementById('image-preview');
	imagePreview.style.display = 'none'; // Hide preview
	if (text) {
		const searchTerm = document.getElementById('search-input').value;
		searchTerm.value = '';
	}
}

function render([err, data]) {
	const imageList = document.getElementById('image-list');
	if (err) {
		imageList.innerHTML = '<p>Error: ' + err + '</p>';
		console.error('Error:', err);
		return;
	}

	imageList.innerHTML = '';
	const searchTime = document.getElementById('search-time')
	searchTime.textContent = data.time.toFixed(0);
	data.items.forEach(result => {
		const item = document.createElement('div');
		item.classList.add('image-container');
		const img = document.createElement('img');
		img.src = result.image_path;
		img.alt = result.caption;
		img.loading = 'lazy';
		item.appendChild(img);
		const similarBtn = document.createElement('button');
		similarBtn.classList.add('show-similar-btn');
		similarBtn.setAttribute('data-id', result.id);
		similarBtn.innerText = 'Show similar';
		item.appendChild(similarBtn);
		imageList.appendChild(item);
	});
}

function performSearch() {
	var searchTerm = document.getElementById('search-input').value;
	reset();

	fetch('/api/search-by-text', {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		},
		body: JSON.stringify({ query: searchTerm })
	})
		.then(response => response.json())
		.then(render)
		.catch(error => {
			console.error('Error:', error);
		});
}

function performSimilarSearch(ev) {
	const el = ev.target;
	reset();
	const id = el.getAttribute('data-id');
	const imagePath = el.parentNode.querySelector('img').src;

	// Display preview
	const previewDiv = document.getElementById('image-preview');
	const previewImg = previewDiv.querySelector('img');
	previewImg.src = imagePath;
	previewDiv.style.display = 'block';

	fetch('/api/search-by-id', {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		},
		body: JSON.stringify({ id })
	})
		.then(response => response.json())
		.then(render)
		.catch(error => {
			console.error('Error:', error);
		});
}

document.getElementById('image-list').addEventListener('click', performSimilarSearch);
document.getElementById('search-button').addEventListener('click', performSearch);

document.getElementById('search-input').addEventListener('keypress', function(event) {
	if (event.key === 'Enter') {
		event.preventDefault();
		performSearch();
	}
});

document.getElementById('upload-button').addEventListener('click', toggleDragDropArea);

const dragDropArea = document.getElementById('drag-drop-area');

dragDropArea.addEventListener('click', function(e) {
	e.stopPropagation(); // Prevent the click from bubbling up
	document.getElementById('file-input').click();
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
		reset(true);

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
			.then(render)
			.catch(error => {
				console.error('Error:', error);
			});
	}
}

document.getElementById('file-input').addEventListener('change', function(event) {
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
