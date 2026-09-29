# SISTEMA DE GESTION HOSPITALARIA - HOSPITALES DE OCCIDENTE

**Universidad:** Universidad de San Carlos de Guatemala (USAC)  
**Centro:** Centro Universitario de Occidente (CUNOC)  
**Division:** Ciencias de la Ingenieria  
**Carrera:** Ingenieria en Ciencias y Sistemas  
**Curso:** Sistemas de Bases de Datos 1  
**Catedratico:** Ing. Bryan Rene Gomez Gomez  
**Proyecto:** Proyecto 1 - Modelado y Gestion de una Base de Datos Hospitalaria  
**Estudiante:** Elmer Miguel  
**Registro Academico:** 201931295  
**Fecha:** Septiembre 2026  
**Motor SGBD:** PostgreSQL 16+

---

## 1. DESCRIPCION GENERAL

El presente proyecto implementa la solucion integral para la gestion clinica, administrativa, quirurgica y financiera de la cadena de Hospitales de Occidente en Guatemala. El diseno relacional cumple estrictamente con la Tercera Forma Normal (3FN), la notacion de Barker, integridad referencial con acciones foraneas explicitas (ON DELETE / ON UPDATE), restricciones CHECK de dominio inmutables, control de concurrencia quirurgica mediante extensiones GiST, y perfiles de seguridad DCL bajo el principio de menor privilegio.

---

## 2. ESTRUCTURA Y CONTENIDO DE CARPETAS

El repositorio se encuentra organizado en las carpetas reglamentarias descritas en la especificacion:

### `modelo/`

Contiene los archivos nativos de modelado y las exportaciones graficas del modelo relacional en notacion Barker:

- `diagrama_barker.drawio`: Archivo nativo editable en Draw.io con el diagrama relacional completo.
- `barker_por_modulo.drawio`: Archivo nativo multi-pagina con el desglose independiente de los 8 modulos del sistema y el diagrama general.
- `diagrama_barker.png`: Exportacion en alta resolucion del diagrama general.
- `modulo_1.png` a `modulo_8.png`: Imagenes en alta definicion de cada modulo asistencial.
- `modulo_9.png`: Diagrama de arquitectura modular.

### `sql/ddl/`

Contiene la definicion completa del esquema institucional `hospitales_occidente`:

- `ddl.sql`: Script DDL idempotente que crea la base de datos `hospital_occidente`, esquema, extension `btree_gist`, 66 tablas, llaves primarias, 125 llaves foraneas con acciones referenciales explicitas (RESTRICT, CASCADE, SET NULL), restricciones CHECK de dominio comentadas, indices B-Tree, 5 vistas 3FN y 8 triggers de reglas de negocio clinicas.

### `sql/dml/`

Contiene el conjunto exhaustivo de datos de prueba clinicos y administrativos:

- `dml.sql`: Script DML que puebla las 66 tablas con datos realistas enfocados en el Occidente de Guatemala (Quetzaltenango/Xela, Totonicapan, San Marcos), 40 personas con 39 DPIs unicos de 13 digitos y 1 menor sin DPI, casos clinicos de Consulta Externa (tarifas normales, reconsultas al 75%, referencias al 80% y recargos al 110%), admisiones, traslados, cirugias aprobadas y rechazadas por comite, checklists, financiamiento de 1 a 12 cuotas, pagos y encuestas de calidad. Incluye la sincronizacion de las 53 secuencias IDENTITY mediante `setval`.

### `sql/dcl/`

Contiene la implementacion de seguridad y control de acceso:

- `dcl.sql`: Script DCL idempotente con revocacion preventiva en bloque anonimo `DO`. Define 4 roles institucionales (`rol_admin_hospital`, `rol_auditor_consulta`, `rol_medico_asistencial`, `rol_caja_facturacion`) y 4 usuarios con contrasenas encriptadas (`usr_admin_occidente`, `usr_auditor_occidente`, `usr_medico_occidente`, `usr_caja_occidente`) segun el principio de menor privilegio.

### `backup/`

Contiene el respaldo fisico oficial de la base de datos:

- `backup.sql`: Archivo SQL plano generado con `pg_dump` que preserva la estructura completa, objetos auxiliares (triggers, vistas, indices) y la totalidad de los datos de prueba listos para restauracion inmediata.

### `documentacion/`

Contiene los informes academicos y el diccionario de datos formal:

- `documentacion_proyecto1.pdf`: Documento PDF consolidado de 88 paginas con portada institucional, diagramas vectoriales, diccionario de datos de 66 tablas y sentencias SQL completas.
- `diccionario_de_datos.md`: Diccionario de datos en formato Markdown con las 66 tablas documentadas atributo por atributo.
- `docuLatex/`: Carpeta con el proyecto LaTeX reproducible:
  - `documentacion.tex`: Codigo fuente en LaTeX utilizando la plantilla solicitada con Helvetica (Arial), geometry 2cm, caption personalizado, tablas formateadas con estilo booktabs/tabular y listings SQL.
  - `documentacion.pdf`: PDF oficial compilado con `pdflatex`.
  - `diagrams/`: Carpeta con todos los diagramas vectoriales exportados en formato PDF (`diagrama_barker.pdf`, `modulo_1.pdf` a `modulo_8.pdf`, `modulo_9.pdf`).

---

## 3. ORDEN DE EJECUCION DE LOS SCRIPTS SQL

Para levantar el entorno completo desde DBeaver o linea de comandos, ejecute los scripts en el siguiente orden secuencial estricto:

1. **DDL:** `sql/ddl/ddl.sql` (Crea esquema, tablas, restricciones, indices, vistas y triggers).
2. **DML:** `sql/dml/dml.sql` (Inserta datos clinicos y ajusta las 53 secuencias).
3. **DCL:** `sql/dcl/dcl.sql` (Configura roles, usuarios y asigna privilegios de seguridad).

---

## 4. COMANDOS DE DESPLIEGUE EN DOCKER POSTGRESQL

Si utiliza el contenedor Docker oficial de PostgreSQL (`user1` / `1234`):

```bash
# 1. Cargar DDL (Estructura de Base de Datos)
docker exec -i postgresql psql -U user1 -d hospital_occidente < sql/ddl/ddl.sql

# 2. Cargar DML (Poblacion de Datos Clinicos)
docker exec -i postgresql psql -U user1 -d hospital_occidente < sql/dml/dml.sql

# 3. Cargar DCL (Roles, Usuarios y Privilegios)
docker exec -i postgresql psql -U user1 -d hospital_occidente < sql/dcl/dcl.sql
```

### Comandos de Respaldo y Restauracion (pg_dump)

```bash
# Generar respaldo completo (Estructura y Datos):
docker exec postgresql pg_dump -U user1 -d hospital_occidente --clean --if-exists --no-owner > backup/backup.sql

# Restaurar la base de datos a partir del respaldo:
docker exec -i postgresql psql -U user1 -d hospital_occidente < backup/backup.sql
```

---

## 5. COMPILACION DE LA DOCUMENTACION EN LATEX

Para recompilar el informe PDF desde la carpeta `documentacion/docuLatex/`:

```bash
cd documentacion/docuLatex
pdflatex -interaction=nonstopmode documentacion.tex
pdflatex -interaction=nonstopmode documentacion.tex
```
