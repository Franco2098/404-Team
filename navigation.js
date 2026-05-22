// Menú desplegable del usuario
const toggle = document.getElementById("userMenuToggle");
const dropdown = document.getElementById("userDropdown");

toggle.addEventListener("click", function (e) {
    e.stopPropagation();
    dropdown.classList.toggle("show");
});

document.addEventListener("click", function () {
    dropdown.classList.remove("show");
});

// Sistema de navegación dinámica
const contentContainer = document.getElementById("contentContainer");
const navLinks = document.querySelectorAll(".nav-link");

// Detectar si está en admin o usuario regular
const isAdmin = window.location.pathname.includes('home_admin.html') || window.location.href.includes('home_admin.html');

// Mapeo de archivos a URLs de contenido
const contentMap = {
    'home.html': { file: 'content-horarios.html', label: 'Horarios' },
    'home_admin.html': { file: 'content-horarios.html', label: 'Horarios' },
    'Calendario.html': { file: 'content-calendario.html', label: 'Calendario' },
    'mapa.html': { file: 'content-mapa.html', label: 'Mapa' },
    'recompensas.html': { 
        file: isAdmin ? 'content-recompensas-admin.html' : 'content-recompensas.html', 
        label: 'Recompensas' 
    }
};

// Función para cargar contenido dinámicamente
function loadContent(htmlFile) {
    fetch(htmlFile)
        .then(response => {
            if (!response.ok) throw new Error('Error loading content');
            return response.text();
        })
        .then(data => {
            contentContainer.innerHTML = data;
        })
        .catch(error => console.error('Error:', error));
}

// Agregar eventos a los enlaces de navegación
navLinks.forEach(link => {
    link.addEventListener('click', function (e) {
        e.preventDefault();
        
        const href = this.getAttribute('href');
        
        // Remover clase "active" de todos los links
        navLinks.forEach(l => l.classList.remove('active'));
        
        // Agregar clase "active" al link actual
        this.classList.add('active');
        
        // Cargar el contenido
        if (contentMap[href]) {
            loadContent(contentMap[href].file);
        }
    });
});

