# Vifraison – Instalación y uso

## Requisitos previos
- Python 3.10 o superior → https://www.python.org/downloads/
  (Durante la instalación marca "Add Python to PATH")
- MariaDB o MySQL instalado y corriendo en local → https://mariadb.org/download/?t=mariadb&p=mariadb&r=12.2.2&os=windows&cpu=x86_64&pkg=msi&mirror=raiolanetworks
- Git → https://git-scm.com/downloads

## 1. Clonar el repositorio

git clone https://github.com/Franco2098/404-Team.git
cd tu-repo

## 2. Instalar dependencias

python -m pip install -r requirements.txt

## 3. Configurar la base de datos

Abre tu cliente SQL (HeidiSQL, DBeaver, terminal de MariaDB) y ejecuta:

    mysql -u root -p < vifrayson_BD.sql

O abre el archivo vifrayson_BD.sql y ejecútalo desde tu cliente gráfico.

## 4. Configurar la conexión

Abre app.py y edita estas líneas si tu configuración es diferente:

    DB_CONFIG = {
        'host':     'localhost',
        'user':     'root',
        'password': '',       # ← pon tu contraseña si tienes una
        'database': 'Vifraison',
        'port': '3306',
    }

## 5. Arrancar el servidor

python app.py

Abre el navegador en: http://localhost:5000

## Credenciales de prueba

| Usuario            | Contraseña   | Rol     |
|--------------------|--------------|---------|
| admin              | admin123     | Admin   |
| pedro@mail.com     | clave123     | Usuario |
| ana@mail.com       | password456  | Usuario |
| luis@mail.com      | login789     | Usuario |