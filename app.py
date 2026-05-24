from flask import Flask, request, jsonify, session
from flask_cors import CORS
import pymysql
import pymysql.cursors
import os

app = Flask(__name__, static_folder='static', static_url_path='')
app.secret_key = 'vifraison_secret_2024'
CORS(app, supports_credentials=True)

# ─────────────────────────────────────────────
#  CONFIGURACIÓN DE BASE DE DATOS
#  MariaDB en localhost, root 
# ─────────────────────────────────────────────
DB_CONFIG = {
    'host':     os.getenv('DB_HOST', 'localhost'),
    'user':     os.getenv('DB_USER', 'root'),
    'password': os.getenv('DB_PASSWORD', 'root'),   
    'database': os.getenv('DB_NAME', 'Vifraison'),
    'port':     int(os.getenv('DB_PORT', 3306)),
    'charset':  'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor
}


def get_db():
    """Devuelve una conexión nueva a MariaDB."""
    return pymysql.connect(**DB_CONFIG)


def query(sql, params=None, fetch=True):
    """Ejecuta una consulta y devuelve los resultados como lista de dicts."""
    conn = get_db()
    try:
        with conn.cursor() as cur:
            if params:
                cur.execute(sql, params)
            else:
                cur.execute(sql)
            if fetch:
                return cur.fetchall()
            conn.commit()
    finally:
        conn.close()
    return []


def call_proc(name, args=()):
    """Llama a un stored procedure y devuelve todos los resultados."""
    conn = get_db()
    try:
        with conn.cursor() as cur:
            cur.callproc(name, args)
            results = []
            # PyMySQL: iterar nextset() para obtener todos los result sets
            while True:
                rows = cur.fetchall()
                if rows:
                    results.extend(rows)
                if not cur.nextset():
                    break
            conn.commit()
            return results
    finally:
        conn.close()


# ═══════════════════════════════════════════════════════
#  SERVIR ARCHIVOS ESTÁTICOS (HTML)
# ═══════════════════════════════════════════════════════

@app.route('/')
def index():
    return app.send_static_file('equipo404.html')


# ═══════════════════════════════════════════════════════
#  AUTH
# ═══════════════════════════════════════════════════════

@app.route('/api/login', methods=['POST'])
def login():
    data  = request.get_json()
    user  = (data.get('usuario') or '').strip()
    passw = (data.get('password') or '').strip()

    if not user or not passw:
        return jsonify({'ok': False, 'msg': 'Por favor completa todos los campos'}), 400

    # Admin hardcoded (puedes moverlo a la BD si quieres)
    if user == 'admin' and passw == 'admin123':
        session['user'] = {'id': 0, 'nombre': 'Admin', 'rol': 'admin'}
        return jsonify({'ok': True, 'rol': 'admin', 'nombre': 'Admin'})

    # Buscar en BD (Login + Usuarios)
    rows = query(
        """
        SELECT u.id_usuario, u.nombre, u.estado
        FROM Login l
        JOIN Usuarios u ON l.id_usuario = u.id_usuario
        WHERE u.email = %s AND l.contraseña = %s
        """,
        (user, passw)
    )

    if not rows:
        return jsonify({'ok': False, 'msg': 'Usuario o contraseña incorrectos'}), 401

    u = rows[0]
    if u['estado'] != 'ACTIVO':
        return jsonify({'ok': False, 'msg': 'Usuario inactivo'}), 403

    session['user'] = {'id': u['id_usuario'], 'nombre': u['nombre'], 'rol': 'user'}
    return jsonify({'ok': True, 'rol': 'user', 'nombre': u['nombre']})


@app.route('/api/logout', methods=['POST'])
def logout():
    session.clear()
    return jsonify({'ok': True})


@app.route('/api/me', methods=['GET'])
def me():
    u = session.get('user')
    if not u:
        return jsonify({'ok': False}), 401
    return jsonify({'ok': True, **u})

# ═══════════════════════════════════════════════════════
#  FICHAJE
# ═══════════════════════════════════════════════════════
 
@app.route('/api/fichaje/estado', methods=['GET'])
def fichaje_estado():
    u = session.get('user')
    if not u:
        return jsonify({'ok': False}), 401
    rows = call_proc('sp_estado_fichaje', (u['id'],))
    if not rows:
        return jsonify({'ok': True, 'estado': 'sin_fichar'})
    f = rows[0]
    # Convertir timedelta a string HH:MM si es necesario
    def td(val):
        if val is None:
            return None
        if hasattr(val, 'seconds'):  # timedelta
            h, m = divmod(val.seconds // 60, 60)
            return f'{h:02d}:{m:02d}'
        return str(val)[:5]
    entrada = td(f['hora_entrada'])
    salida  = td(f['hora_salida'])
    if entrada and not salida:
        estado = 'entrada_fichada'
    elif entrada and salida:
        estado = 'completo'
    else:
        estado = 'sin_fichar'
    return jsonify({'ok': True, 'estado': estado, 'entrada': entrada, 'salida': salida})
 
 
@app.route('/api/fichaje/entrada', methods=['POST'])
def fichar_entrada():
    u = session.get('user')
    if not u:
        return jsonify({'ok': False}), 401
    try:
        call_proc('sp_fichar_entrada', (u['id'],))
        return jsonify({'ok': True})
    except Exception as e:
        return jsonify({'ok': False, 'msg': str(e)}), 400
 
 
@app.route('/api/fichaje/salida', methods=['POST'])
def fichar_salida():
    u = session.get('user')
    if not u:
        return jsonify({'ok': False}), 401
    try:
        call_proc('sp_fichar_salida', (u['id'],))
        return jsonify({'ok': True})
    except Exception as e:
        return jsonify({'ok': False, 'msg': str(e)}), 400
    
# ═══════════════════════════════════════════════════════
#  TAREAS
# ═══════════════════════════════════════════════════════

@app.route('/api/tareas', methods=['GET'])
def get_tareas():
    u = session.get('user')
    if not u:
        return jsonify({'ok': False}), 401
    fecha = request.args.get('fecha')
    if not fecha:
        return jsonify({'ok': False, 'msg': 'Falta parámetro fecha'}), 400
    rows = query("""
        SELECT id_tarea, TIME_FORMAT(hora, '%%H:%%i') AS hora, descripcion
        FROM Tareas
        WHERE id_usuario = %s AND fecha = %s
        ORDER BY hora ASC
    """, (u['id'], fecha))
    return jsonify(rows)


@app.route('/api/tareas', methods=['POST'])
def crear_tarea():
    d = request.get_json()
    try:
        call_proc('sp_alta_tarea', (int(d['id_usuario']), d['fecha'], d['hora'], d['descripcion']))
        return jsonify({'ok': True})
    except Exception as e:
        return jsonify({'ok': False, 'msg': str(e)}), 400


@app.route('/api/tareas/<int:tid>', methods=['PUT'])
def editar_tarea(tid):
    d = request.get_json()
    try:
        call_proc('sp_modificar_tarea', (tid, d['hora'], d['descripcion']))
        return jsonify({'ok': True})
    except Exception as e:
        return jsonify({'ok': False, 'msg': str(e)}), 400


@app.route('/api/tareas/<int:tid>', methods=['DELETE'])
def borrar_tarea(tid):
    try:
        call_proc('sp_baja_tarea', (tid,))
        return jsonify({'ok': True})
    except Exception as e:
        return jsonify({'ok': False, 'msg': str(e)}), 400
    
    
@app.route('/api/horarios/usuarios-por-fecha', methods=['GET'])
def usuarios_por_fecha():
    fecha = request.args.get('fecha')
    if not fecha:
        return jsonify({'ok': False, 'msg': 'Falta fecha'}), 400
    rows = query("""
        SELECT h.id_usuario, u.nombre
        FROM Horario h
        JOIN Usuarios u ON h.id_usuario = u.id_usuario
        WHERE h.fecha = %s
        ORDER BY u.nombre
    """, (fecha,))
    return jsonify(rows)


@app.route('/api/tareas/por-fecha', methods=['GET'])
def get_tareas_por_fecha():
    fecha = request.args.get('fecha')
    if not fecha:
        return jsonify({'ok': False, 'msg': 'Falta fecha'}), 400
    rows = query("""
        SELECT t.id_tarea, t.id_usuario, u.nombre,
               TIME_FORMAT(t.hora, '%%H:%%i') AS hora,
               t.descripcion
        FROM Tareas t
        JOIN Usuarios u ON t.id_usuario = u.id_usuario
        WHERE t.fecha = %s
        ORDER BY u.nombre, t.hora ASC
    """, (fecha,))
    return jsonify(rows)

# ═══════════════════════════════════════════════════════
#  HORARIOS
# ═══════════════════════════════════════════════════════

@app.route('/api/horarios', methods=['GET'])
def get_horarios():
    u = session.get('user', {})
    if u.get('rol') == 'admin':
        rows = query("""
            SELECT h.fecha, h.id_usuario, u.nombre,
                   TIME_FORMAT(h.entrada,'%H:%i') AS entrada,
                   TIME_FORMAT(h.salida,'%H:%i')  AS salida
            FROM Horario h
            JOIN Usuarios u ON h.id_usuario = u.id_usuario
            ORDER BY h.fecha, u.nombre
        """)
    else:
        rows = query("""
            SELECT h.fecha, h.id_usuario, u.nombre,
                   DATE_FORMAT(h.entrada, '%%H:%%i') AS entrada,
                   DATE_FORMAT(h.salida,  '%%H:%%i') AS salida
            FROM Horario h
            JOIN Usuarios u ON h.id_usuario = u.id_usuario
            WHERE h.id_usuario = %s
            ORDER BY h.fecha
        """, (u.get('id'),))
    for r in rows:
        if hasattr(r.get('fecha'), 'isoformat'):
            r['fecha'] = r['fecha'].isoformat()
    return jsonify(rows)


@app.route('/api/horarios', methods=['POST'])
def crear_horario():
    d = request.get_json()
    try:
        call_proc('sp_alta_horario', (d['fecha'], int(d['id_usuario']), d['entrada'], d['salida']))
        return jsonify({'ok': True})
    except Exception as e:
        return jsonify({'ok': False, 'msg': str(e)}), 400


@app.route('/api/horarios/<fecha>', methods=['PUT'])
def editar_horario(fecha):
    d = request.get_json()
    try:
        call_proc('sp_modificar_horario', (fecha, d['entrada'], d['salida']))
        return jsonify({'ok': True})
    except Exception as e:
        return jsonify({'ok': False, 'msg': str(e)}), 400


@app.route('/api/horarios/<fecha>', methods=['DELETE'])
def borrar_horario(fecha):
    try:
        call_proc('sp_baja_horario', (fecha,))
        return jsonify({'ok': True})
    except Exception as e:
        return jsonify({'ok': False, 'msg': str(e)}), 400


# ═══════════════════════════════════════════════════════
#  RECOMPENSAS
# ═══════════════════════════════════════════════════════

@app.route('/api/recompensas', methods=['GET'])
def get_recompensas():
    rows = call_proc('sp_listar_recompensas')
    return jsonify(rows)


@app.route('/api/recompensas', methods=['POST'])
def crear_recompensa():
    d = request.get_json()
    try:
        call_proc('sp_alta_recompensa', (d['descripcion'], int(d['puntos_requeridos'])))
        return jsonify({'ok': True})
    except Exception as e:
        return jsonify({'ok': False, 'msg': str(e)}), 400


@app.route('/api/recompensas/<int:rid>', methods=['PUT'])
def editar_recompensa(rid):
    d = request.get_json()
    try:
        query(
            "UPDATE Recompensas SET descripcion=%s, puntos_requeridos=%s WHERE id_recompensa=%s",
            (d['descripcion'], int(d['puntos_requeridos']), rid),
            fetch=False
        )
        return jsonify({'ok': True})
    except Exception as e:
        return jsonify({'ok': False, 'msg': str(e)}), 400


@app.route('/api/recompensas/<int:rid>', methods=['DELETE'])
def borrar_recompensa(rid):
    try:
        query("DELETE FROM Recompensas WHERE id_recompensa=%s", (rid,), fetch=False)
        return jsonify({'ok': True})
    except Exception as e:
        return jsonify({'ok': False, 'msg': str(e)}), 400


# ═══════════════════════════════════════════════════════
#  USUARIOS  (solo admin)
# ═══════════════════════════════════════════════════════

@app.route('/api/usuarios', methods=['GET'])
def get_usuarios():
    rows = call_proc('sp_listar_usuarios_activos')
    return jsonify(rows)


@app.route('/api/usuarios', methods=['POST'])
def crear_usuario():
    d = request.get_json()
    try:
        call_proc('sp_alta_usuario', (
            d['nombre'], d['email'],
            int(d['telefono']), int(d['numero_ss']), d.get('estado', 'ACTIVO')
        ))
        return jsonify({'ok': True})
    except Exception as e:
        return jsonify({'ok': False, 'msg': str(e)}), 400


@app.route('/api/usuarios/<int:uid>', methods=['PUT'])
def editar_usuario(uid):
    d = request.get_json()
    try:
        call_proc('sp_modificar_usuario', (
            uid, d['nombre'], d['email'], int(d['telefono']), d['estado']
        ))
        return jsonify({'ok': True})
    except Exception as e:
        return jsonify({'ok': False, 'msg': str(e)}), 400


@app.route('/api/usuarios/<int:uid>', methods=['DELETE'])
def baja_usuario(uid):
    try:
        call_proc('sp_baja_usuario', (uid,))
        return jsonify({'ok': True})
    except Exception as e:
        return jsonify({'ok': False, 'msg': str(e)}), 400


# ═══════════════════════════════════════════════════════
#  MAPA
# ═══════════════════════════════════════════════════════

@app.route('/api/mapa/<int:uid>', methods=['GET'])
def get_mapa(uid):
    rows = call_proc('sp_consultar_mapa', (uid,))
    return jsonify(rows[0] if rows else {})


# ═══════════════════════════════════════════════════════
#  MAIN
# ═══════════════════════════════════════════════════════

if __name__ == '__main__':
    app.run(debug=True, port=5000)
