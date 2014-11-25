class Extractor < ActiveRecord::Base
  require 'xmlsimple'

  def self.migrar_TEG

    # Conexion con la base de datos anterior de Busconest: busconest_jorge
    # Extraer los ids de todos los documentos
    busconest_jorge_database = ActiveRecord::Base.establish_connection "development"
    result = busconest_jorge_database.connection.execute("SELECT id FROM documento")
    ids = result.to_a

    # GRAN LOOP (desde el primer documenro hasta el ultimo)
    #i = 1
    ids.each do |id|

      doc_id = id.first

      # Conexion con la base de datos anterior de Busconest: busconest_jorge
      # Parsear el XML con la data del documento
      busconest_jorge_database = ActiveRecord::Base.establish_connection "development"
      result = busconest_jorge_database.connection.execute("SELECT metadata FROM documento WHERE id=#{doc_id}") 
      xml_data = result.to_a.first[0]
      unless xml_data.nil?
       begin
        teg =  XmlSimple.xml_in(xml_data)

        autores_persona_id = []

        # CREAR EL PRIMER GRADUANDO 
        r = crear_persona( teg['autor'][0]['cedula'][0],
                         teg['autor'][0]['correo'][0] )

        autores_persona_id.push(r)

        crear_estudiante( teg['autor'][0]['cedula'][0],
                        teg['licenciatura_id'][0],
                        teg['autor'][0]['promedio_general'][0],
                        teg['autor'][0]['promedio_ponderado'][0],
                        teg['autor'][0]['eficiencia'][0] ) 

        # CREAR EL SEGUNDO GRADUANDO (si existe)
        autor2_cedula = teg['autor'][1]['cedula'][0] unless teg['autor'][1].nil?
        unless autor2_cedula.nil?
          r2 = crear_persona( teg['autor'][1]['cedula'][0],
                            teg['autor'][1]['correo'][0] )
          autores_persona_id.push(r2)

          crear_estudiante( teg['autor'][1]['cedula'][0],
                          teg['licenciatura_id'][0],
                          teg['autor'][1]['promedio_general'][0],
                          teg['autor'][1]['promedio_ponderado'][0],
                          teg['autor'][1]['eficiencia'][0]) 
        end#unless

        # CREAR EL O LOS TUTORES
        tutores_persona_id = crear_tutores(teg['autor'][0]['cedula'][0])


        # CREAR JURADOS
        jurados_persona_id = crear_jurados(teg['autor'][0]['cedula'][0])


        # CREAR DOCUMENTO  
        if teg['publico'].nil?
          teg_publico = 1 
        else
          teg_publico = teg['publico'][0]
        end#if

        documento_id= crear_documento(teg['titulo_html'][0],
                                    teg['resumen_html'][0],
                                    teg['palabras_clave'][0],
                                    teg['fecha_publicacion'][0],
                                    teg['licenciatura_id'][0],
                                    teg_publico,
                                    teg['calificacion'][0],
                                    doc_id)


        # Relacionar la tabla Documento y Persona, mediate las tablas Autor, Tutor y Jurado
        crear_relacion_autor(autores_persona_id, documento_id)
        crear_relacion_tutor(tutores_persona_id, documento_id)
        crear_relacion_jurado(jurados_persona_id, documento_id)

        unless teg['autor'][1].nil?
          crear_reconocimiento(documento_id,
                             teg['autor'][0]['cedula'][0], 
                             teg['autor'][1]['cedula'][0])
        else
          crear_reconocimiento(documento_id,
                             teg['autor'][0]['cedula'][0], 
                             teg['autor'][0]['cedula'][0])
        end#unless


       rescue# Si sale algo mal en el begin cuando se lee el XML
         msg = ("ERROR LEYENDO EL XML #{doc_id}\n"+ $!.to_s) +"\n"
         File.open('output.txt', 'a') {|f| f.write(msg) }
         $stderr.print ("IO failed (doc_id #{doc_id})"+ $!.to_s) +"\n"
       end#begin

      end#unless
      #i = i + 1
    end#do
     
  end#def_migrar


  # CREAR PERSONA
  #
  def self.crear_persona( autor_cedula, autor_email )

    # Verificar si ya existe la Persona en la Base de Datos de Busconest: migracion
    migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
    result = migracion_busconest_database.connection.execute("SELECT id FROM persona WHERE cedula LIKE \"#{autor_cedula}\"")

    autor_persona_id = result.to_a.first[0] unless result.to_a.first.nil?

    # Si la persona no esta en la Base de Datos Busconest: migracion debemos crearla
    if autor_persona_id.nil?

      # Conexion con la base de datos de Conest: conest_dummy_development
      # para buscar los nombres, apellidos y nombre completo del autor1
      #
      conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
      f = conest_dummy_development_database.connection.execute("SELECT primer_nombre,
                                                                     segundo_nombre,
                                                                     primer_apellido,
                                                                     segundo_apellido
                                                              FROM estudiante 
                                                              WHERE cedula LIKE \"#{autor_cedula}\"")
      unless f.to_a.first[1] == ''
        autor_nombres = f.to_a.first[0]+" "+f.to_a.first[1]
      else
        autor_nombres = f.to_a.first[0]
      end#unless

      unless f.to_a.first[3] == ''
        autor_apellidos = f.to_a.first[2]+" "+f.to_a.first[3]
      else
        autor_apellidos = f.to_a.first[2]
      end#unless

      autor_nombre_completo = autor_nombres+" "+autor_apellidos

      # Setear los timestamps
      t = Time.now.strftime "%Y-%m-%d %H:%M:%S UTC"

      # Conexion con la base de datos nueva de Busconest: busconest_migracion
      # para crear la Persona correspondiente al autor1
      migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
      migracion_busconest_database.connection.execute(
        "INSERT INTO persona (cedula,
                           nombres,
                           apellidos,
                           nombre_completo,
                           email,
                           created_at,
                           updated_at )
                   VALUES (\"#{autor_cedula}\",
                           \"#{autor_nombres}\",
                           \"#{autor_apellidos}\",
                           \"#{autor_nombre_completo}\",
                           \"#{autor_email}\",
                           \"#{t}\",
                           \"#{t}\"
                            )"
        )
    end#if

    # Recuperar el id de la Persona en la Base de Datos de Busconest: migracion
    migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
    result = migracion_busconest_database.connection.execute("SELECT id FROM persona WHERE cedula LIKE \"#{autor_cedula}\"")
    return result.to_a.first[0]

  end#def_crear_persona


  # CREAR ESTUDIANTE
  #
  def self.crear_estudiante(autor_cedula, licenciatura_id, promedio_general, promedio_ponderado, eficiencia )

    estudiante_escuela_id = mapear_licenciatura(licenciatura_id)

    # Verificamos si no existe previamente el estudiante
    # en la Base de Datos Busconest: migracion
    migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
    r = migracion_busconest_database.connection.execute("SELECT persona_id
                                                           FROM estudiante 
                                                             JOIN persona ON (estudiante.persona_id=persona.id) 
                                                           WHERE cedula LIKE \"#{autor_cedula}\" AND
                                                                 escuela_id = #{estudiante_escuela_id}")

    autor_persona_id_from_estudiante = r.to_a.first[0] unless r.to_a.first.nil?

    # Si no hay estudiante asociado para autor (debe coincidir la escuela tambien, ya que una persona puede tener mas
    # de un estudiante asociado (por ejemplo el autor curso dos pregrados)
    #
    if autor_persona_id_from_estudiante.nil?

      estudiante_promedio_general = promedio_general
      estudiante_promedio_ponderado = promedio_ponderado
      estudiante_eficiencia = eficiencia
      estudiante_grado_id = 1 # PREGRADO

      # Extraer el id de la Persona correspondiente al autor en la Base de Datos Busconest: migracion
      # para poder establecer el foreign_key en la tabla Autor
      migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
      r = migracion_busconest_database.connection.execute("SELECT id FROM persona WHERE cedula LIKE \"#{autor_cedula}\"")
      estudiante_persona_id = r.to_a.first[0]
        
      # Recuperar mencion del estudiante en la BD conest_dummy_development 
      conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
      f = conest_dummy_development_database.connection.execute( "SELECT gra.mencion_id 
                                                                 FROM graduando as gra 
                                                                   JOIN mencion as men  ON (gra.mencion_id=men.id)  
                                                                 WHERE gra.estudiante_cedula LIKE \"#{autor_cedula}\"")

      unless f.to_a.first.nil?
        estudiante_mencion_id = mapear_menciones ( f.to_a.first[0] )
      else
        estudiante_mencion_id = nil
      end#unless

      # Buscar en la BD conest_dummy_development el premio: 
      # suma/magna cum laude, premio especial de graduacion, alto rendimiento academico
      # Ojo: El premio es asociado al estudiante y el reconocimiento al documento
      #
      conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
      f = conest_dummy_development_database.connection.execute( "SELECT tipo_premio_academico.nombre 
                                                                 FROM tipo_premio_academico 
                                  JOIN graduando_con_premio ON graduando_con_premio.tipo_premio_academico_id = tipo_premio_academico.id
                                                                 WHERE estudiante_cedula LIKE \"#{autor_cedula}\"")

      unless f.to_a.first.nil?
        case f.to_a.first[0]
          when 'PREMIO SUMA CUM LAUDE'
            estudiante_premio_id = 3
          when 'PREMIO MAGNA CUM LAUDE'
            estudiante_premio_id = 2
          when 'PREMIO ESPECIAL DE GRADUACION'
            estudiante_premio_id = 1
          when 'PREMIO ALTO RENDIMIENTO ACADEMICO'
            estudiante_premio_id = 4
         end#case
      end#unless

      unless f.to_a.first.nil?
        case f.to_a.first[1]
          when 'PREMIO SUMA CUM LAUDE'
            estudiante_premio_id = 3
          when 'PREMIO MAGNA CUM LAUDE'
            estudiante_premio_id = 2
          when 'PREMIO ESPECIAL DE GRADUACION'
            estudiante_premio_id = 1
          when 'PREMIO ALTO RENDIMIENTO ACADEMICO'
            estudiante_premio_id = 4
         end#case
      end#unless


      # Setear timestamps
      t = Time.now.strftime "%Y-%m-%d %H:%M:%S UTC"

      migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
      migracion_busconest_database.connection.execute(
        "INSERT INTO estudiante (promedio_general,
                           promedio_ponderado,
                           eficiencia,
                           escuela_id,
                           grado_id,
                           persona_id,
                           mencion_id,
                           premio_id,
                           created_at,
                           updated_at )
                   VALUES (\"#{estudiante_promedio_general}\",
                           \"#{estudiante_promedio_ponderado}\",
                           \"#{estudiante_eficiencia}\",
                           \"#{estudiante_escuela_id}\",
                           \"#{estudiante_grado_id}\",
                           \"#{estudiante_persona_id}\",
                           \"#{estudiante_mencion_id}\",
                           \"#{estudiante_premio_id}\",
                           \"#{t}\",
                           \"#{t}\"
                            )"
      )

     # Cambiar a NULL los valores 0 que indican que el estudiante no tiene premio
     if estudiante_premio_id.nil?     
       migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
       migracion_busconest_database.connection.execute( "UPDATE estudiante SET premio_id=NULL WHERE premio_id=0")
     end#if

     # Cambiar a NULL los valores 0 que indican que el estudiante no tiene mencion
     if estudiante_premio_id.nil?     
       migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
       migracion_busconest_database.connection.execute( "UPDATE estudiante SET mencion_id=NULL WHERE mencion_id=0")
     end#if

    end#if
  end#def_crear_estudiante

  def self.mapear_licenciatura( licenciatura_id )
    case licenciatura_id
      when 'B'
        estudiante_escuela_id = 1 
      when 'C'
        estudiante_escuela_id = 2
      when 'F'
        estudiante_escuela_id = 3
      when 'G'
        estudiante_escuela_id = 4
      when 'M'
        estudiante_escuela_id = 5
      when 'Q'
        estudiante_escuela_id = 6 
    end#case
    return estudiante_escuela_id
  end#def_mapear_licenciatura


  def self.mapear_menciones (estudiante_mencion_id)
    case estudiante_mencion_id
      when 'ASTROF' # ASTROFISICA
        estudiante_mencion_id = 19
      when 'ATI'    # APLICACIONES CON TECNOLOGIA EN INTERNET
        estudiante_mencion_id = 6
      when 'BASICA' # BASICA - Quimica
        estudiante_mencion_id = 30 
      when 'BD'     # BASES DE DATOS
        estudiante_mencion_id = 9
      when 'BIOCEL' #BIOLOGIA CELULAR
        estudiante_mencion_id = 1
      when 'BOTAN'  # BOTANICA
        estudiante_mencion_id = 2
      when 'CALCIE' # CALCULO CIENTIFICO
        estudiante_mencion_id = 7
      when 'CIEMAT' # CIENCIA DE LOS MATERIALES - Fisica
        estudiante_mencion_id = 20
      when 'COMGRA' # COMPUTACION GRAFICA
        estudiante_mencion_id = 13
      when 'ECOL'   # ECOLOGIA
        estudiante_mencion_id = 3
      when 'FISCOM' # FISICA COMPUTACIONAL
        estudiante_mencion_id = 21
      when 'FISEXP' # FISICA EXPERIMENTAL
        estudiante_mencion_id = 22
      when 'FISICA' # FISICA
        estudiante_mencion_id = 23
      when 'FISMED' # FISICA MEDICA
        estudiante_mencion_id = 24
      when 'FISTEO' # FISICA TEORICA
        estudiante_mencion_id = 25
      when 'GEOFIS' # GEOFISICA
        estudiante_mencion_id = 26
      when 'GEOQUI' # GEOQUIMICA
        estudiante_mencion_id = 31
      when 'INGSOF' # INGENIERIA DE SOFTWARE
        estudiante_mencion_id = 10
      when 'INSTR'  # INSTRUMENTACION - Fisica
        estudiante_mencion_id = 27
      when 'INTART' # INTELIGENCIA ARTIFICIAL
        estudiante_mencion_id = 11
      when 'MODMAT' # MODELOS MATEMATICOS
        estudiante_mencion_id = 14
      when 'OCEAN'  # OCEANOGRAFIA
        estudiante_mencion_id = 28
      when 'REDES'  # TECNOLOGIAS EN COMUNICACIONES Y REDES DE COMPUTADORAS
        estudiante_mencion_id = 8
      when 'RESMAG' # ESPECTROSCOPIA DE RESONANCIA MAGNETICA NUCLEAR
        estudiante_mencion_id = 29
      when 'SDISPA' # SISTEMAS DISTRIBUIDOS Y PARALELOS
        estudiante_mencion_id = 16
      when 'SINMEB' # SIN OPCION - Biologia
        estudiante_mencion_id = 17
      when 'SINMEN' # SIN OPCION - Computacion
        estudiante_mencion_id = 18
      when 'SISINF' # SISTEMAS DE INFORMACION
        estudiante_mencion_id = 15
      when 'TECALI' # TECNOLOGIA DE ALIMENTOS
        estudiante_mencion_id = 4
      when 'TECEDU' # TECNOLOGIAS EDUCATIVAS
        estudiante_mencion_id = 12
      when 'TECNOL' # TECNOLOGIA - Quimica
        estudiante_mencion_id = 32
      when 'ZOOL'   # ZOOLOGIA
        estudiante_mencion_id = 5
      end#case
    return estudiante_mencion_id
  end#def_mapear_menciones

  # CREAR TUTORES
  #
  def self.crear_tutores(autor_cedula)

    # RECUPERAR DATOS TUTORES

    my_query = "SELECT id
                FROM planilla_individual
                WHERE estudiante_cedula LIKE #{autor_cedula} AND 
                      documento_subido LIKE \"1\""

    conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
    f = conest_dummy_development_database.connection.execute(my_query).to_a
    planilla_individual_id = f[0].first

    # Buscar los tutores en la tabla docente_planilla de busconest_dummy
    my_query = "SELECT docente_cedula 
                FROM docente_planilla
                WHERE planilla_individual_id = #{planilla_individual_id} AND
                      tipo_jurado_id LIKE 'TU'"

    conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
    f = conest_dummy_development_database.connection.execute(my_query).to_a
    tutores_ci_docente = f

    # Buscar los tutores en la tabla calificador_externo_planilla de busconest_dummy
    my_query = "SELECT calificador_externo_cedula 
                FROM calificador_externo_planilla
                WHERE planilla_individual_id = #{planilla_individual_id}
                      AND tipo_jurado_id LIKE 'TU'"
    conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
    f = conest_dummy_development_database.connection.execute(my_query).to_a
    tutores_ci_externo = f

    tutor1_ci = nil
    tutor1_nombre = nil
    tutor1_correo = nil
    tutor2_ci = nil
    tutor2_nombre = nil
    tutor2_correo = nil

    case tutores_ci_docente.size
    # Si hay 2 tutores en la tabla docente_planilla
      when  2
        tutor  = tutores_ci_docente[0].first
        my_query = "SELECT cedula, nombre, correo FROM docente WHERE cedula LIKE #{tutor}"
        conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
        res = conest_dummy_development_database.connection.execute(my_query).to_a

        tutor1_ci = res[0][0]
        tutor1_nombre = res[0][1]
        tutor1_correo = res[0][2]  

        tutor2 = tutores_ci_docente[1].first
        my_query = "SELECT cedula, nombre, correo FROM docente WHERE cedula LIKE #{tutor2}"
        conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
        res = conest_dummy_development_database.connection.execute(my_query).to_a

        tutor2_ci = res[0][0]
        tutor2_nombre = res[0][1]
        tutor2_correo = res[0][2] 

      # Si hay solo 1 tutor en la tabla docente_planilla
      when 1
        tutor  = tutores_ci_docente[0].first
        my_query = "SELECT cedula, nombre, correo FROM docente WHERE cedula LIKE #{tutor}"
        conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
        res = conest_dummy_development_database.connection.execute(my_query).to_a

        tutor1_ci = res[0][0]
        tutor1_nombre = res[0][1]
        tutor1_correo = res[0][2]
    end#case


    case tutores_ci_externo.size
      # Si hay 2 tutores en la tabla calificador_externo_planilla
      when 2
        tutor  = tutores_ci_externo[0].first
        my_query = "SELECT cedula, nombre, correo FROM calificador_externo WHERE cedula LIKE #{tutor}"
        conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
        res = conest_dummy_development_database.connection.execute(my_query).to_a
        
        tutor1_ci = res[0][0]
        tutor1_nombre = res[0][1]
        tutor1_correo = res[0][2]  

        tutor2 = tutores_ci_externo[1].first
        my_query = "SELECT cedula, nombre, correo FROM calificador_externo WHERE cedula LIKE #{tutor2}"
        conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
        res = conest_dummy_development_database.connection.execute(my_query).to_a
        
        tutor2_ci = res[1][0]
        tutor2_nombre = res[1][1]
        tutor2_correo = res[1][2] 
   
      # Si hay 1 tutor en la tabla calificador_externo_planilla 
      when 1
        tutor  = tutores_ci_externo[0].first
        my_query = "SELECT cedula, nombre, correo FROM calificador_externo WHERE cedula LIKE #{tutor}"
        conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
        res = conest_dummy_development_database.connection.execute(my_query).to_a
      
        tutor2_ci = res[0][0]
        tutor2_nombre = res[0][1]
        tutor2_correo = res[0][2]
    end#case

    tutores_persona_id = []

    unless tutor1_ci.nil?
      # Verificar si ya existe la Persona asociada al tutor1 en la Base de Datos de Busconest: migracion
      migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
      result = migracion_busconest_database.connection.execute("SELECT id FROM persona WHERE cedula LIKE \"#{tutor1_ci}\"")

      tutor1_persona_id = result.to_a.first[0] unless result.to_a.first.nil?

      # Si el tutor1 no esta registrado como Persona en la Base de Datos: migracion
      if tutor1_persona_id.nil?
        t = Time.now.strftime "%Y-%m-%d %H:%M:%S UTC"
        migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
        migracion_busconest_database.connection.execute(
          "INSERT INTO persona (cedula,
                         nombres,
                         apellidos,
                         nombre_completo,
                         email,
                         created_at,
                         updated_at )
                 VALUES (\"#{tutor1_ci}\",
                         \"#{tutor1_nombre}\",
                         \"#{tutor1_nombre}\",
                         \"#{tutor1_nombre}\",
                         \"#{tutor1_correo}\",
                         \"#{t}\",
                         \"#{t}\"
                          )"
        )

      end#if

      # Extraer el id de la Persona correspondiente al tutor1 en la Base de Datos Busconest: migracion
      # para poder establecer los foreign_key en la tabla Tutor
      #
      migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
      r = migracion_busconest_database.connection.execute("SELECT id FROM persona WHERE cedula LIKE \"#{tutor1_ci}\"")
      tutores_persona_id.push(r.to_a.first[0]) unless r.to_a.first.nil?
    end#unless
  
    unless tutor2_ci.nil?
      # Verificar si ya existe la Persona asociada al tutor2 en la Base de Datos de Busconest: migracion
      migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
      result = migracion_busconest_database.connection.execute("SELECT id FROM persona WHERE cedula LIKE \"#{tutor2_ci}\"")

      tutor2_persona_id = result.to_a.first[0] unless result.to_a.first.nil?

      # Si el tutor2 no esta no esta asociado como Persona en la Base de Datos: migracion
      if tutor2_persona_id.nil?
        t = Time.now.strftime "%Y-%m-%d %H:%M:%S UTC"
        migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
        migracion_busconest_database.connection.execute(
          "INSERT INTO persona (cedula,
                         nombres,
                         apellidos,
                         nombre_completo,
                         email,
                         created_at,
                         updated_at )
                 VALUES (\"#{tutor2_ci}\",
                         \"#{tutor2_nombre}\",
                         \"#{tutor2_nombre}\",
                         \"#{tutor2_nombre}\",
                         \"#{tutor2_correo}\",
                         \"#{t}\",
                         \"#{t}\"
                          )"
          )

      end#if

      # Extraer el id de la Persona correspondiente al tutor2 en la Base de Datos Busconest: migracion
      # para poder establecer los foreign_key en la tabla Tutor
      #
      migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
      r = migracion_busconest_database.connection.execute("SELECT id FROM persona WHERE cedula LIKE \"#{tutor2_ci}\"")
      tutores_persona_id.push(r.to_a.first[0]) unless r.to_a.first.nil?
    end#unless
    
    return tutores_persona_id
 
  end#def_crear_tutores


  # CREAR JURADOS
  #
  def self.crear_jurados( autor_cedula )

    # RECUPERAR DATOS JURADOS

    my_query = "SELECT id
                FROM planilla_individual
                WHERE estudiante_cedula LIKE #{autor_cedula} AND 
                      documento_subido LIKE \"1\""

    conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
    f = conest_dummy_development_database.connection.execute(my_query).to_a
    planilla_individual_id = f[0].first


    # Buscar los jurados en la tabla docente_planilla
    my_query = "SELECT docente_cedula 
                FROM docente_planilla
                WHERE planilla_individual_id = #{planilla_individual_id}
                      AND (tipo_jurado_id LIKE 'JU' OR
                           tipo_jurado_id LIKE 'J1' OR 
                           tipo_jurado_id LIKE 'J2')"

    conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
    datos = conest_dummy_development_database.connection.execute(my_query).to_a
    jurados_ci_docente = datos

    # Buscar los jurados en la tabla calificador_externo
    my_query = "SELECT calificador_externo_cedula 
                FROM calificador_externo_planilla
                WHERE planilla_individual_id = #{planilla_individual_id}
                      AND (tipo_jurado_id LIKE 'JU' OR
                           tipo_jurado_id LIKE 'J1' OR 
                           tipo_jurado_id LIKE 'J2')"

    conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
    datos = conest_dummy_development_database.connection.execute(my_query).to_a
    jurados_ci_externo = datos


    case jurados_ci_docente.size
      # Si hay 2 jurados en la tabla docente_planilla
      when 2
        jurado  = jurados_ci_docente[0].first
        my_query = "SELECT cedula, nombre, correo FROM docente WHERE cedula LIKE #{jurado}"
        conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
        res = conest_dummy_development_database.connection.execute(my_query).to_a

        jurado1_ci = res[0][0]
        jurado1_nombre = res[0][1]
        jurado1_correo = res[0][2]  

        jurado2 = jurados_ci_docente[1].first
        my_query = "SELECT cedula, nombre, correo FROM docente WHERE cedula LIKE #{jurado2}"
        conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
        res = conest_dummy_development_database.connection.execute(my_query).to_a

        jurado2_ci = res[0][0]
        jurado2_nombre = res[0][1]
        jurado2_correo = res[0][2] 

      # Si hay 1 jurado en la tabla docente_planilla (el otro debe estar en la tabla calificador_externo)
      when 1
        jurado1  = jurados_ci_docente[0].first
        my_query = "SELECT cedula, nombre, correo FROM docente WHERE cedula LIKE #{jurado1}"
        conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
        res = conest_dummy_development_database.connection.execute(my_query).to_a

        jurado1_ci = res[0][0]
        jurado1_nombre = res[0][1]
        jurado1_correo = res[0][2]
    end#case

    case jurados_ci_externo.size
      # Si hay 2 jurados en la tabla calificador_externo_planilla
      when 2
        jurado1  = jurados_ci_externo[0].first
        my_query = "SELECT cedula, nombre, correo FROM calificador_externo WHERE cedula LIKE #{jurado1}"
        conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
        res = conest_dummy_development_database.connection.execute(my_query).to_a
      
        jurado1_ci = res[0][0]
        jurado1_nombre = res[0][1]
        jurado1_correo = res[0][2]  

        jurado2 = jurados_ci_externo[1].first
        my_query = "SELECT cedula, nombre, correo FROM calificador_externo WHERE cedula LIKE #{jurado2}"
        conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
        res = conest_dummy_development_database.connection.execute(my_query).to_a
      
        jurado2_ci = res[0][0]
        jurado2_nombre = res[0][1]
        jurado2_correo = res[0][2] 

      # Si hay 1 jurado en la tabla calificador_externo_planilla
      when 1
        jurado2  = jurados_ci_externo[0].first
        my_query = "SELECT cedula, nombre, correo FROM calificador_externo WHERE cedula LIKE #{jurado2}"
        conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
        res = conest_dummy_development_database.connection.execute(my_query).to_a
      
        jurado2_ci = res[0][0]
        jurado2_nombre = res[0][1]
        jurado2_correo = res[0][2]
    end#case

    # Verificar si ya existe la Persona asociada al jurado1 en la Base de Datos de Busconest: migracion
    migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
    result = migracion_busconest_database.connection.execute("SELECT id FROM persona WHERE cedula LIKE \"#{jurado1_ci}\"")

    jurado1_persona_id = result.to_a.first[0] unless result.to_a.first.nil?

    # Si el jurado1 no esta registrado en la Base de Datos: migracion
    if jurado1_persona_id.nil?
      t = Time.now.strftime "%Y-%m-%d %H:%M:%S UTC"
      migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
      migracion_busconest_database.connection.execute(
        "INSERT INTO persona (cedula,
                         nombres,
                         apellidos,
                         nombre_completo,
                         email,
                         created_at,
                         updated_at )
                 VALUES (\"#{jurado1_ci}\",
                         \"#{jurado1_nombre}\",
                         \"#{jurado1_nombre}\",
                         \"#{jurado1_nombre}\",
                         \"#{jurado1_correo}\",
                         \"#{t}\",
                         \"#{t}\"
                          )"
      )
    end#if

    # Verificar si ya existe la Persona asociada al jurado2 en la Base de Datos de Busconest: migracion
    migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
    result = migracion_busconest_database.connection.execute("SELECT id FROM persona WHERE cedula LIKE \"#{jurado2_ci}\"")

    jurado2_persona_id = result.to_a.first[0] unless result.to_a.first.nil?

    # Si el jurado2 no esta registrado en la Base de Datos: migracion
    if jurado2_persona_id.nil?
      t = Time.now.strftime "%Y-%m-%d %H:%M:%S UTC"
      migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
      migracion_busconest_database.connection.execute(
        "INSERT INTO persona (cedula,
                         nombres,
                         apellidos,
                         nombre_completo,
                         email,
                         created_at,
                         updated_at )
                 VALUES (\"#{jurado2_ci}\",
                         \"#{jurado2_nombre}\",
                         \"#{jurado2_nombre}\",
                         \"#{jurado2_nombre}\",
                         \"#{jurado2_correo}\",
                         \"#{t}\",
                         \"#{t}\"
                          )"
      )

    end#if

    jurados_persona_id = []

    # Extraer el id de la Persona correspondiente al jurado1 en la Base de Datos Busconest: migracion
    # para poder establecer los foreign_key en la tabla Jurado
    #
    migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
    r = migracion_busconest_database.connection.execute("SELECT id FROM persona WHERE cedula LIKE \"#{jurado2_ci}\"")
    jurados_persona_id.push(r.to_a.first[0])

    # Extraer el id de la Persona correspondiente al jurado1 en la Base de Datos Busconest: migracion
    # para poder establecer los foreign_key en la tabla Jurado
    #
    migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
    r = migracion_busconest_database.connection.execute("SELECT id FROM persona WHERE cedula LIKE \"#{jurado1_ci}\"")
    jurados_persona_id.push(r.to_a.first[0])

    return jurados_persona_id

  end#def_crear_jurados

  def self.crear_documento(teg_titulo,
                       teg_resumen,
                       teg_palabras_clave,
                       teg_fecha_publicacion,
                       teg_licenciatura_id,
                       teg_publico,
                       teg_calificacion,
                       doc_id)

    #CREAR DOCUMENTO  
    #documento_titulo  = (teg_titulo.to_s).gsub( /\'\\["#(){}\[\]]/, '"' => '\\"', '#' => '\#', '(' => '\(', ')' => '\)', '{' => '\{', '}' => '\}', '[' => '\[', ']' => '\]', '\\' => '\\\\', '\'' => '\\\'')
    documento_titulo  = (teg_titulo.to_s).gsub( /"/, '"' => '\"')
    documento_titulo = nil if documento_titulo == '{}'
    documento_titulo_texto_plano = ActionController::Base.helpers.strip_tags(documento_titulo)

    #documento_resumen = (teg_resumen.to_s).gsub( /\'\\["#(){}\[\]]/, '"' => '\\"', '#' => '\#', '(' => '\(', ')' => '\)', '{' => '\{', '}' => '\}', '[' => '\[', ']' => '\]', '\\' => '\\\\', '\'' => '\\\'')
    documento_resumen  = (teg_resumen.to_s).gsub( /"/, '"' => '\"')
    documento_resumen = nil if documento_resumen == '{}'
    documento_resumen_texto_plano = ActionController::Base.helpers.strip_tags(documento_resumen)


    #documento_palabras_clave = (teg_palabras_clave.to_s).gsub( /\'\\["#(){}\[\]]/, '"' => '\\"', '#' => '\#', '(' => '\(', ')' => '\)', '{' => '\{', '}' => '\}', '[' => '\[', ']' => '\]', '\\' => '\\\\', '\'' => '\\\'')
    documento_palabras_clave  = (teg_palabras_clave.to_s).gsub( /"/, '"' => '\"')
    documento_palabras_clave = nil if documento_palabras_clave == '{}'

    documento_fecha_publicacion = teg_fecha_publicacion

    # Correcion del error en el año 0008 -> 2008
    documento_fecha_publicacion[6] = '2'
    fecha_doc = documento_fecha_publicacion[6]+
                documento_fecha_publicacion[7]+
                documento_fecha_publicacion[8]+
                documento_fecha_publicacion[9] 

   
    documento_fecha_publicacion = documento_fecha_publicacion[6]+
                documento_fecha_publicacion[7]+
                documento_fecha_publicacion[8]+
                documento_fecha_publicacion[9]+
                documento_fecha_publicacion[5]+
                documento_fecha_publicacion[3]+
                documento_fecha_publicacion[4]+
                documento_fecha_publicacion[2]+
                documento_fecha_publicacion[0]+
                documento_fecha_publicacion[1] 
    # Fin de correcion

    # Hacer el mapeo de los codigos de licenciatura_id en la BD Busconest jorge 
    # a los codigos de escuela_id en la BD Busconest nueva
    #
    case teg_licenciatura_id
      when 'B'
        documento_escuela_id = 1
        documento_directorio = 'BIOLOGIA'
      when 'C'
        documento_escuela_id = 2
        documento_directorio = 'COMPUTACION'
      when 'F'
        documento_escuela_id = 3
        documento_directorio = 'FISICA'
      when 'G'
        documento_escuela_id = 4
        documento_directorio = 'GEOQUIMICA'
      when 'M'
        documento_escuela_id = 5
        documento_directorio = 'MATEMATICA'
      when 'Q'
        documento_escuela_id = 6
        documento_directorio = 'QUIMICA'
    end#case

    documento_tipo_documento_id   = 1 # TEG
    documento_estado_documento_id = 1 # NUEVO (no indexado)
    documento_idioma_id           = 1 # Español
    documento_visibilidad_id      = teg_publico

    # Generar los timestamps

    # Si la visibilidad es distinta de 1 (Publico)       
    documento_visibilidad_id = '2' unless documento_visibilidad_id == '1'

    my_query = "SELECT archivo
                 INTO DUMPFILE \'/tmp/documentos/#{documento_directorio}/#{fecha_doc}/documento_#{doc_id}.pdf\'
                FROM documento 
                WHERE id=#{doc_id}" 

    migrador_development_database = ActiveRecord::Base.establish_connection "development"
    migrador_development_database.connection.execute(my_query)

    publicacion_file_name    = "Documento_#{doc_id}.pdf"
    publicacion_content_type = 'application/pdf'
    publicacion_file_size    = File.size("/tmp/documentos/#{documento_directorio}/#{fecha_doc}/documento_#{doc_id}.pdf")
    t = publicacion_updated_at   = Time.now.strftime "%Y-%m-%d %H:%M:%S UTC"
    documento_calificacion   = teg_calificacion
    documento_descargas      = 0

    begin
      lector = PDF::Reader.new("/tmp/documentos/#{documento_directorio}/#{fecha_doc}/documento_#{doc_id}.pdf")
      documento_paginas = lector.page_count
      documento_estado  = 'COMPLETO'
    rescue
      documento_estado  = 'INCOMPLETO'
    end#Exception PDF

    migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
    migracion_busconest_database.connection.execute(
      "INSERT INTO documento (id,
                         titulo,
                         resumen,
                         fecha_publicacion,
                         palabras_clave,
                         escuela_id,
                         tipo_documento_id,
                         estado_documento_id,
                         idioma_id,
                         visibilidad_id,
                         created_at,
                         updated_at,
                         publicacion_file_name,
                         publicacion_content_type,
                         publicacion_file_size,
                         publicacion_updated_at,
                         calificacion,
                         descargas,
                         paginas,
                         estado)
                 VALUES (#{doc_id},
                         \"#{documento_titulo}\",
                         \"#{documento_resumen}\",
                         \"#{documento_fecha_publicacion}\",
                         \"#{documento_palabras_clave}\",
                         \"#{documento_escuela_id}\",
                         \"#{documento_tipo_documento_id}\",
                         \"#{documento_estado_documento_id}\",
                         \"#{documento_idioma_id}\",
                         \"#{documento_visibilidad_id}\",
                         \"#{t}\",
                         \"#{t}\",
                         \"#{publicacion_file_name}\",
                         \"#{publicacion_content_type}\",
                         \"#{publicacion_file_size}\",
                         \"#{publicacion_updated_at}\",
                         \"#{documento_calificacion}\",
                         \"#{documento_descargas}\",
                         \"#{documento_paginas}\",
                         \"#{documento_estado}\"
                          )"
    )

    # Extraer el id del Documento de la Base de Datos de Busconest: migracion
    migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
    result = migracion_busconest_database.connection.execute("SELECT id 
                                                             FROM documento 
                                                             WHERE publicacion_file_name LIKE \"Documento_#{doc_id}.pdf\"")
    documento_id = result.to_a.first[0] unless result.to_a.first.nil?

    return documento_id

  end#def_crear_documento

  def self.crear_relacion_autor(autores_persona_id, documento_id)
    # Relacionar la tabla Documento y Persona, mediate las tablas Autor, Tutor y Jurado
    # Crear el autor1 en la tabla Autor
    t = Time.now.strftime "%Y-%m-%d %H:%M:%S UTC"
    migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
    migracion_busconest_database.connection.execute(
      "INSERT INTO autor (persona_id,
                         documento_id,
                         created_at,
                         updated_at )
                 VALUES (\"#{autores_persona_id[0]}\",
                         \"#{documento_id}\",
                         \"#{t}\",
                         \"#{t}\"
                          )"
    )

    # Crear el autor2 en la tabla Autor (si existe)
    unless  autores_persona_id[1].nil?
      t = Time.now.strftime "%Y-%m-%d %H:%M:%S UTC"
      migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
      migracion_busconest_database.connection.execute(
        "INSERT INTO autor (persona_id,
                         documento_id,
                         created_at,
                         updated_at )
                 VALUES (\"#{autores_persona_id[1]}\",
                         \"#{documento_id}\",
                         \"#{t}\",
                         \"#{t}\"
                          )"
      )      
    end#unless

  end#def_crear_relacion_autor

  def self.crear_relacion_tutor(tutores_persona_id, documento_id)
    # Crear el tutor1 en la tabla Tutor
    t = Time.now.strftime "%Y-%m-%d %H:%M:%S UTC"
    migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
    migracion_busconest_database.connection.execute(
      "INSERT INTO tutor (persona_id,
                         documento_id,
                         created_at,
                         updated_at )
                 VALUES (\"#{tutores_persona_id[0]}\",
                         \"#{documento_id}\",
                         \"#{t}\",
                         \"#{t}\"
                          )"
    )

    # Crear el tutor2 en la tabla Tutor (si existe)
    unless  tutores_persona_id[1].nil?
      t = Time.now.strftime "%Y-%m-%d %H:%M:%S UTC"
      migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
      migracion_busconest_database.connection.execute(
        "INSERT INTO tutor (persona_id,
                         documento_id,
                         created_at,
                         updated_at )
                 VALUES (\"#{tutores_persona_id[1]}\",
                         \"#{documento_id}\",
                         \"#{t}\",
                         \"#{t}\"
                          )"
      )      
    end#unless

  end#def_crear_relacion_tutor


  def self.crear_relacion_jurado(jurados_persona_id, documento_id)
    # Crear el jurado1 en la tabla Jurado
    t = Time.now.strftime "%Y-%m-%d %H:%M:%S UTC"
    migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
    migracion_busconest_database.connection.execute(
      "INSERT INTO jurado (persona_id,
                         documento_id,
                         created_at,
                         updated_at )
                 VALUES (\"#{jurados_persona_id[0]}\",
                         \"#{documento_id}\",
                         \"#{t}\",
                         \"#{t}\"
                          )"
    )

    # Crear el jurado2 en la tabla Jurado
    t = Time.now.strftime "%Y-%m-%d %H:%M:%S UTC"
    migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
    migracion_busconest_database.connection.execute(
        "INSERT INTO jurado (persona_id,
                         documento_id,
                         created_at,
                         updated_at )
                 VALUES (\"#{jurados_persona_id[1]}\",
                         \"#{documento_id}\",
                         \"#{t}\",
                         \"#{t}\"
                          )"
    )
  end#def_crear_relacion_jurado


 def self.crear_reconocimiento(documento_id, autor_cedula, autor2_cedula)
    # Buscar en la BD conest_dummy_development el reconocimiento: 
    # mencion honorifica
    # Ojo: El premio es asociado al estudiante y el reconocimiento al documento
    #
    conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
    f = conest_dummy_development_database.connection.execute( "SELECT tipo_premio_academico.nombre 
                                                                 FROM tipo_premio_academico 
                                  JOIN graduando_con_premio ON graduando_con_premio.tipo_premio_academico_id = tipo_premio_academico.id
                                                                 WHERE estudiante_cedula LIKE \"#{autor_cedula}\"")
    unless f.to_a.first.nil?
      case f.to_a.first[0]
        when 'MENCION HONORIFICA'
          doc_reconocimiento_id = 1
      end#case
    end#unless

    unless f.to_a.first.nil?
      case f.to_a.first[1]
        when 'MENCION HONORIFICA'
          doc_reconocimiento_id = 1
      end#case
    end#unless

    unless autor2_cedula.nil?
      conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
      f = conest_dummy_development_database.connection.execute( "SELECT tipo_premio_academico.nombre 
                                                                 FROM tipo_premio_academico 
                                  JOIN graduando_con_premio ON graduando_con_premio.tipo_premio_academico_id = tipo_premio_academico.id
                                                                 WHERE estudiante_cedula LIKE \"#{autor2_cedula}\"")
      unless f.to_a.first.nil?
        case f.to_a.first[0]
          when 'MENCION HONORIFICA'
            doc_reconocimiento_id = 1
        end#case
      end#unless

      unless f.to_a.first.nil?
        case f.to_a.first[1]
          when 'MENCION HONORIFICA'
            doc_reconocimiento_id = 1
        end#case
      end#unless
   
    end#unless

    # Si alguno de los dos autores recibio mencion honorifica entonces asociamos esta distincion
    # al documento en la tabla documento_reconocimiento en la BD Busconest nueva
    #
    unless doc_reconocimiento_id.nil? || documento_id.nil?
      t = Time.now.strftime "%Y-%m-%d %H:%M:%S UTC"
      migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
      migracion_busconest_database.connection.execute(
        "INSERT INTO documento_reconocimiento (documento_id,
                         reconocimiento_id
                          )
                 VALUES (\"#{documento_id}\",
                         \"#{doc_reconocimiento_id}\"
                          )"
      )   
    end#unless

 end#def_crear_reconocimiento

end#class
