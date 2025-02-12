-- LIMPIAR BASE DE DATOS

-- PERSONAS
truncate table persona;
truncate table estudiante;
truncate table autor;
truncate table tutor;
truncate table jurado;

-- DOCUMENTOS
truncate table documento;
truncate table contenido;

-- INDICES
truncate table tindex;
truncate table rindex;
truncate table cindex;
truncate table clindex;
truncate table termino;

-- TABLAS ASOCIATIVAS
truncate table area_documento;
truncate table documento_reconocimiento;

-- TABLAS QUE NO DEBERIAN SER TRUNCADAS
-- PARA MENTENER LA CONSISTENCIA DE LA APLICACION
-- BORRAR LOS REGISTROS MANUALMENTE
# truncate table area;
# truncate table escuela;
# truncate table estado_documento;
# truncate table grado;
# truncate table idioma;
# truncate table mencion;
# truncate table premio;
# truncate table reconocimiento;
# truncate table tipo_documento;
# truncate table usuario;
# truncate table visibilidad;
# truncate table schema_migrations;
