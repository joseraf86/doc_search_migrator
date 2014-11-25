class Extractor < ActiveRecord::Base
  require 'xmlsimple'

  def self.migrar_TEG
    # Conexion con la base de datos de anterior anterior de Busconest: busconest_jorge
    result = ActiveRecord::Base.connection.execute('SELECT metadata FROM documento WHERE id=4') 
    teg =  XmlSimple.xml_in(result.to_a.first[0])

    # CREAR PERSONA AUTOR1
    # Extraccion de datos del archivo XML

    # Extraer la cedula del autor1 autor2
    @autor1_cedula = teg['autor'][0]['cedula'][0]
    @autor2_cedula = teg['autor'][1]['cedula'][0] unless teg['autor'][1].nil?
    #puts teg['autor'][0]
    #puts teg['autor'][1]
    #puts 'FFFFF'
    #puts teg['autor'][1]

    # Verificar si ya existe la Persona en la Base de Datos de Busconest: migracion
    migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
    result = migracion_busconest_database.connection.execute("SELECT id FROM persona WHERE cedula LIKE \"#{@autor1_cedula}\"")

    @autor1_persona_id = result.to_a.first[0] unless result.to_a.first.nil?

    # Si la persona no esta en la Base de Datos Busconest: migracion debemos crearla
    if @autor1_persona_id.nil?

      # Migrar el correo
      @autor1_email = teg['autor'][0]['correo'][0]

      # Conexion con la base de datos de Conest: conest_dummy_development
      # para buscar los nombres, apellidos y nombre completo del autor1
      #
      conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
      f = conest_dummy_development_database.connection.execute("SELECT primer_nombre,
                                                                     segundo_nombre,
                                                                     primer_apellido,
                                                                     segundo_apellido
                                                              FROM estudiante 
                                                              WHERE cedula LIKE \"#{@autor1_cedula}\"")
      unless f.to_a.first[1] == ''
        @autor1_nombres = f.to_a.first[0]+" "+f.to_a.first[1]
      else
        @autor1_nombres = f.to_a.first[0]
      end#unless

      unless f.to_a.first[3] == ''
        @autor1_apellidos = f.to_a.first[2]+" "+f.to_a.first[3]
      else
        @autor1_apellidos = f.to_a.first[2]
      end#unless

      @autor1_nombre_completo = @autor1_nombres+" "+@autor1_apellidos

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
                   VALUES (\"#{@autor1_cedula}\",
                           \"#{@autor1_nombres}\",
                           \"#{@autor1_apellidos}\",
                           \"#{@autor1_nombre_completo}\",
                           \"#{@autor1_email}\",
                           \"#{t}\",
                           \"#{t}\"
                            )"
        )
    end#if
    
     
    # CREAR ESTUDIANTE AUTOR1
    # puts teg['autor'][1]['cedula'][0]+" YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYy"
    case teg['licenciatura_id'][0]
      when 'B'
        @estudiante1_escuela_id = 1 
      when 'C'
        @estudiante1_escuela_id = 2
      when 'F'
        @estudiante1_escuela_id = 3
      when 'G'
        @estudiante1_escuela_id = 4
      when 'M'
        @estudiante1_escuela_id = 5
      when 'Q'
        @estudiante1_escuela_id = 6 
    end#case

    # Verificamos si no existe previamente el estudiante
    # en la Base de Datos Busconest: migracion
    migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
    r = migracion_busconest_database.connection.execute("SELECT persona_id
                                                           FROM estudiante 
                                                             JOIN persona ON (estudiante.persona_id=persona.id) 
                                                           WHERE cedula LIKE \"#{@autor1_cedula}\" AND
                                                                 escuela_id = #{@estudiante1_escuela_id}")

    @autor1_persona_id_from_estudiante = r.to_a.first[0] unless r.to_a.first.nil?

    # Si no estudiante asociado para autor1 (debe coincidir la escuela tambien ya que una persona puede tener mas
    # de un estudiante asociado (por ejemplo el autor1 curso dos pregrados)
    #
    if @autor1_persona_id_from_estudiante.nil?

      @estudiante1_promedio_general = teg['autor'][0]['promedio_general'][0]
      @estudiante1_promedio_ponderado = teg['autor'][0]['promedio_ponderado'][0]
      @estudiante1_eficiencia = teg['autor'][0]['eficiencia'][0]
      @estudiante1_grado_id = 1 # PREGRADO

      # Extraer el id de la Persona correspondiente al autor1 en la Base de Datos Busconest: migracion
      # para poder establecer los foreign_key en la tabla Autor
      migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
      r = migracion_busconest_database.connection.execute("SELECT id FROM persona WHERE cedula LIKE \"#{@autor1_cedula}\"")
      @estudiante1_persona_id = r.to_a.first[0]
        
      # Recuperar mencion del estudiante en la BD conest_dummy_development 
      conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
      f = conest_dummy_development_database.connection.execute( "SELECT gra.mencion_id 
                                                                 FROM graduando as gra 
                                                                   JOIN mencion as men  ON (gra.mencion_id=men.id)  
                                                                 WHERE gra.estudiante_cedula LIKE \"#{@autor1_cedula}\"")
      case f.to_a.first[0]
        when 'ASTROF' # ASTROFISICA
          @estudiante1_mencion_id = 19
        when 'ATI'    # APLICACIONES CON TECNOLOGIA EN INTERNET
          @estudiante1_mencion_id = 6
        when 'BASICA' # BASICA - Quimica
          @estudiante1_mencion_id = 30 
        when 'BD'     # BASES DE DATOS
          @estudiante1_mencion_id = 9
        when 'BIOCEL' #BIOLOGIA CELULAR
          @estudiante1_mencion_id = 1
        when 'BOTAN'  # BOTANICA
          @estudiante1_mencion_id = 2
        when 'CALCIE' # CALCULO CIENTIFICO
          @estudiante1_mencion_id = 7
        when 'CIEMAT' # CIENCIA DE LOS MATERIALES - Fisica
          @estudiante1_mencion_id = 20
        when 'COMGRA' # COMPUTACION GRAFICA
          @estudiante1_mencion_id = 13
        when 'ECOL'   # ECOLOGIA
          @estudiante1_mencion_id = 3
        when 'FISCOM' # FISICA COMPUTACIONAL
          @estudiante1_mencion_id = 21
        when 'FISEXP' # FISICA EXPERIMENTAL
          @estudiante1_mencion_id = 22
        when 'FISICA' # FISICA
          @estudiante1_mencion_id = 23
        when 'FISMED' # FISICA MEDICA
          @estudiante1_mencion_id = 24
        when 'FISTEO' # FISICA TEORICA
          @estudiante1_mencion_id = 25
        when 'GEOFIS' # GEOFISICA
          @estudiante1_mencion_id = 26
        when 'GEOQUI' # GEOQUIMICA
          @estudiante1_mencion_id = 31
        when 'INGSOF' # INGENIERIA DE SOFTWARE
          @estudiante1_mencion_id = 10
        when 'INSTR'  # INSTRUMENTACION - Fisica
          @estudiante1_mencion_id = 27
        when 'INTART' # INTELIGENCIA ARTIFICIAL
          @estudiante1_mencion_id = 11
        when 'MODMAT' # MODELOS MATEMATICOS
          @estudiante1_mencion_id = 14
        when 'OCEAN'  # OCEANOGRAFIA
          @estudiante1_mencion_id = 28
        when 'REDES'  # TECNOLOGIAS EN COMUNICACIONES Y REDES DE COMPUTADORAS
          @estudiante1_mencion_id = 8
        when 'RESMAG' # ESPECTROSCOPIA DE RESONANCIA MAGNETICA NUCLEAR
          @estudiante1_mencion_id = 29
        when 'SDISPA' # SISTEMAS DISTRIBUIDOS Y PARALELOS
          @estudiante1_mencion_id = 16
        when 'SINMEB' # SIN OPCION - Biologia
          @estudiante1_mencion_id = 17
        when 'SINMEN' # SIN OPCION - Computacion
          @estudiante1_mencion_id = 18
        when 'SISINF' # SISTEMAS DE INFORMACION
          @estudiante1_mencion_id = 15
        when 'TECALI' # TECNOLOGIA DE ALIMENTOS
          @estudiante1_mencion_id = 4
        when 'TECEDU' # TECNOLOGIAS EDUCATIVAS
          @estudiante1_mencion_id = 12
        when 'TECNOL' # TECNOLOGIA - Quimica
          @estudiante1_mencion_id = 32
        when 'ZOOL'   # ZOOLOGIA
          @estudiante1_mencion_id = 5
      end#case

      # Buscar en la BD conest_dummy_development el premio: 
      # suma/magna cum laude, premio especial de graduacion, alto rendimiento academico
      # Ojo: El premio es asociado al estudiante y el reconocimiento al documento
      #
      conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
      f = conest_dummy_development_database.connection.execute( "SELECT tipo_premio_academico.nombre 
                                                                 FROM tipo_premio_academico 
                                  JOIN graduando_con_premio ON graduando_con_premio.tipo_premio_academico_id = tipo_premio_academico.id
                                                                 WHERE estudiante_cedula LIKE \"#{@autor1_cedula}\"")

      unless f.to_a.first.nil?
        case f.to_a.first[0]
          when 'PREMIO SUMA CUM LAUDE'
            @estudiante1_premio_id = 3
          when 'PREMIO MAGNA CUM LAUDE'
            @estudiante1_premio_id = 2
          when 'PREMIO ESPECIAL DE GRADUACION'
            @estudiante1_premio_id = 1
          when 'PREMIO ALTO RENDIMIENTO ACADEMICO'
            @estudiante1_premio_id = 4
         end#case
      end#unless

      unless f.to_a.first.nil?
        case f.to_a.first[1]
          when 'PREMIO SUMA CUM LAUDE'
            @estudiante1_premio_id = 3
          when 'PREMIO MAGNA CUM LAUDE'
            @estudiante1_premio_id = 2
          when 'PREMIO ESPECIAL DE GRADUACION'
            @estudiante1_premio_id = 1
          when 'PREMIO ALTO RENDIMIENTO ACADEMICO'
            @estudiante1_premio_id = 4
         end#case
      end#unless


      # Stear timestamps
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
                   VALUES (\"#{@estudiante1_promedio_general}\",
                           \"#{@estudiante1_promedio_ponderado}\",
                           \"#{@estudiante1_eficiencia}\",
                           \"#{@estudiante1_escuela_id}\",
                           \"#{@estudiante1_grado_id}\",
                           \"#{@estudiante1_persona_id}\",
                           \"#{@estudiante1_mencion_id}\",
                           \"#{@estudiante1_premio_id}\",
                           \"#{t}\",
                           \"#{t}\"
                            )"
      )

     if @estudiante1_premio_id.nil?     
       migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
       migracion_busconest_database.connection.execute( "UPDATE estudiante SET premio_id=NULL WHERE premio_id=0")
     end#if

    end#if

    # CREAR PAREJA
    # Si el documento no se hizo en pareja no se hace esta parte
    unless @autor2_cedula.nil?
      # Verificar si ya existe la Persona en la Base de Datos de Busconest: migracion
      migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
      result = migracion_busconest_database.connection.execute("SELECT id FROM persona WHERE cedula LIKE \"#{@autor2_cedula}\"")

      @autor2_persona_id = result.to_a.first[0] unless result.to_a.first.nil?

      # Si la pareja no esta registrada en la Base de Datos: migracion
      if @autor2_persona_id.nil?
        #puts teg['autor'][1]['cedula'][1]+" XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        @autor2_cedula = teg['autor'][1]['cedula'][0]
        @autor2_email = teg['autor'][1]['correo'][0]

        conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
        f = conest_dummy_development_database.connection.execute("SELECT primer_nombre,
                                                                     segundo_nombre,
                                                                     primer_apellido,
                                                                     segundo_apellido
                                                                FROM estudiante 
                                                                WHERE cedula LIKE \"#{@autor2_cedula}\"")
        unless f.to_a.first[1] == ''
          @autor2_nombres = f.to_a.first[0]+" "+f.to_a.first[1]
        else
          @autor2_nombres = f.to_a.first[0]
        end#unless

        unless f.to_a.first[3] == ''
          @autor2_apellidos = f.to_a.first[2]+" "+f.to_a.first[3]
        else
          @autor2_apellidos = f.to_a.first[2]
        end#unless

        @autor2_nombre_completo = @autor2_nombres+" "+@autor2_apellidos

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
                 VALUES (\"#{@autor2_cedula}\",
                         \"#{@autor2_nombres}\",
                         \"#{@autor2_apellidos}\",
                         \"#{@autor2_nombre_completo}\",
                         \"#{@autor2_email}\",
                         \"#{t}\",
                         \"#{t}\"
                          )"
        )

      end#if   -- si autor2 no tiene asociada a una persona

      # CREAR ESTUDIANTE AUTOR2

      case teg['licenciatura_id'][0]
        when 'B'
          @estudiante2_escuela_id = 1 
        when 'C'
          @estudiante2_escuela_id = 2
        when 'F'
          @estudiante2_escuela_id = 3
        when 'G'
          @estudiante2_escuela_id = 4
        when 'M'
          @estudiante2_escuela_id = 5
        when 'Q'
          @estudiante2_escuela_id = 6 
      end#case

      # Verificamos si no existe previamente el estudiante
      # en la Base de Datos Busconest: migracion
      migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
      r = migracion_busconest_database.connection.execute("SELECT persona_id
                                                           FROM estudiante 
                                                             JOIN persona ON (estudiante.persona_id=persona.id) 
                                                           WHERE cedula LIKE \"#{@autor2_cedula}\" AND
                                                                 escuela_id = #{@estudiante2_escuela_id}")

      @autor2_persona_id_from_estudiante = r.to_a.first[0] unless r.to_a.first.nil?

      # Si no estudiante asociado para autor1 (debe coincidir la escuela tambien ya que una persona puede tener mas
      # de un estudiante asociado (por ejemplo el autor1 curso dos pregrados)
      #
      # puts 'XxX'
      # puts @autor2_persona_id_from_estudiante
      if @autor2_persona_id_from_estudiante.nil?

        @estudiante2_promedio_general = teg['autor'][1]['promedio_general'][0]
        @estudiante2_promedio_ponderado = teg['autor'][1]['promedio_ponderado'][0]
        @estudiante2_eficiencia = teg['autor'][1]['eficiencia'][0]
        @estudiante2_grado_id = 1 # PREGRADO

        # Extraer el id de la Persona correspondiente al autor2 en la Base de Datos Busconest: migracion
        # para poder establecer los foreign_key en la tabla Autor
        #
        migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
        r = migracion_busconest_database.connection.execute("SELECT id FROM persona WHERE cedula LIKE \"#{@autor2_cedula}\"")
        @estudiante2_persona_id = r.to_a.first[0]
        
        # Recuperar mencion del estudiante en la BD conest_dummy_development 
        conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
        f = conest_dummy_development_database.connection.execute( "SELECT gra.mencion_id 
                                                                 FROM graduando as gra 
                                                                   JOIN mencion as men  ON (gra.mencion_id=men.id)  
                                                                 WHERE gra.estudiante_cedula LIKE \"#{@autor2_cedula}\"")
        case f.to_a.first[0]
          when 'ASTROF' # ASTROFISICA
            @estudiante2_mencion_id = 19
          when 'ATI'    # APLICACIONES CON TECNOLOGIA EN INTERNET
            @estudiante2_mencion_id = 6
          when 'BASICA' # BASICA - Quimica
            @estudiante2_mencion_id = 30 
          when 'BD'     # BASES DE DATOS
            @estudiante2_mencion_id = 9
          when 'BIOCEL' #BIOLOGIA CELULAR
            @estudiante2_mencion_id = 1
          when 'BOTAN'  # BOTANICA
            @estudiante2_mencion_id = 2
          when 'CALCIE' # CALCULO CIENTIFICO
            @estudiante2_mencion_id = 7
          when 'CIEMAT' # CIENCIA DE LOS MATERIALES - Fisica
            @estudiante2_mencion_id = 20
          when 'COMGRA' # COMPUTACION GRAFICA
            @estudiante2_mencion_id = 13
          when 'ECOL'   # ECOLOGIA
            @estudiante2_mencion_id = 3
          when 'FISCOM' # FISICA COMPUTACIONAL
            @estudiante2_mencion_id = 21
          when 'FISEXP' # FISICA EXPERIMENTAL
            @estudiante2_mencion_id = 22
          when 'FISICA' # FISICA
            @estudiante2_mencion_id = 23
          when 'FISMED' # FISICA MEDICA
            @estudiante2_mencion_id = 24
          when 'FISTEO' # FISICA TEORICA
            @estudiante2_mencion_id = 25
          when 'GEOFIS' # GEOFISICA
             @estudiante2_mencion_id = 26
          when 'GEOQUI' # GEOQUIMICA
             @estudiante2_mencion_id = 31
          when 'INGSOF' # INGENIERIA DE SOFTWARE
             @estudiante2_mencion_id = 10
          when 'INSTR'  # INSTRUMENTACION - Fisica
             @estudiante2_mencion_id = 27
          when 'INTART' # INTELIGENCIA ARTIFICIAL
             @estudiante2_mencion_id = 11
          when 'MODMAT' # MODELOS MATEMATICOS
            @estudiante2_mencion_id = 14
          when 'OCEAN'  # OCEANOGRAFIA
            @estudiante2_mencion_id = 28
          when 'REDES'  # TECNOLOGIAS EN COMUNICACIONES Y REDES DE COMPUTADORAS
            @estudiante2_mencion_id = 8
          when 'RESMAG' # ESPECTROSCOPIA DE RESONANCIA MAGNETICA NUCLEAR
            @estudiante2_mencion_id = 29
          when 'SDISPA' # SISTEMAS DISTRIBUIDOS Y PARALELOS
            @estudiante2_mencion_id = 16
          when 'SINMEB' # SIN OPCION - Biologia
            @estudiante2_mencion_id = 17
          when 'SINMEN' # SIN OPCION - Computacion
            @estudiante2_mencion_id = 18
          when 'SISINF' # SISTEMAS DE INFORMACION
            @estudiante2_mencion_id = 15
          when 'TECALI' # TECNOLOGIA DE ALIMENTOS
            @estudiante2_mencion_id = 4
          when 'TECEDU' # TECNOLOGIAS EDUCATIVAS
            @estudiante2_mencion_id = 12
          when 'TECNOL' # TECNOLOGIA - Quimica
            @estudiante2_mencion_id = 32
          when 'ZOOL'   # ZOOLOGIA
            @estudiante2_mencion_id = 5
        end#case

        # Buscar en la BD conest_dummy_development el premio: 
        # suma/magna cum laude, premio especial de graduacion, alto rendimiento academico
        # Ojo: El premio es asociado al estudiante y el reconocimiento al documento
        #
        conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
        f = conest_dummy_development_database.connection.execute( "SELECT tipo_premio_academico.nombre 
                                                                 FROM tipo_premio_academico 
                                  JOIN graduando_con_premio ON graduando_con_premio.tipo_premio_academico_id = tipo_premio_academico.id
                                                                 WHERE estudiante_cedula LIKE \"#{@autor2_cedula}\"")

        unless f.to_a.first.nil?
          case f.to_a.first[0]
            when 'PREMIO SUMA CUM LAUDE'
              @estudiante2_premio_id = 3
            when 'PREMIO MAGNA CUM LAUDE'
              @estudiante2_premio_id = 2
            when 'PREMIO ESPECIAL DE GRADUACION'
              @estudiante2_premio_id = 1
            when 'PREMIO ALTO RENDIMIENTO ACADEMICO'
              @estudiante2_premio_id = 4
           end#case
        end#unless

        unless f.to_a.first.nil?
          case f.to_a.first[1]
            when 'PREMIO SUMA CUM LAUDE'
              @estudiante2_premio_id = 3
            when 'PREMIO MAGNA CUM LAUDE'
              @estudiante2_premio_id = 2
            when 'PREMIO ESPECIAL DE GRADUACION'
              @estudiante2_premio_id = 1
            when 'PREMIO ALTO RENDIMIENTO ACADEMICO'
              @estudiante2_premio_id = 4
           end#case
        end#unless


        # Stear timestamps
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
                   VALUES (\"#{@estudiante2_promedio_general}\",
                           \"#{@estudiante2_promedio_ponderado}\",
                           \"#{@estudiante2_eficiencia}\",
                           \"#{@estudiante2_escuela_id}\",
                           \"#{@estudiante2_grado_id}\",
                           \"#{@estudiante2_persona_id}\",
                           \"#{@estudiante2_mencion_id}\",
                           \"#{@estudiante2_premio_id}\",
                           \"#{t}\",
                           \"#{t}\"
                            )"
          )

        if @estudiante2_premio_id.nil?     
          migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
          migracion_busconest_database.connection.execute( "UPDATE estudiante SET premio_id=NULL WHERE premio_id=0")
        end#if

      end#if -- si autor2 tiene estudiante asociado en su licenciatura
    end#unless -- si el el documento tiene autor2

    # CREAR TUTORES
    # Extraer la cedula del tutor1 y tutor2
    # @tutor1_cedula = teg['tutor'][0]['cedula'][0]
    # @tutor2_cedula = teg['tutor'][1]['cedula'][0] unless teg['autor'][1].nil?


    # RECUPERAR DATOS TUTORES
    # Buscar los tutores en la tabla docente_planilla
    my_query = "SELECT id
                FROM planilla_individual
                WHERE estudiante_cedula LIKE #{@autor1_cedula} AND 
                      documento_subido LIKE \"1\""

    conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
    f = conest_dummy_development_database.connection.execute(my_query).to_a
    #datos = ActiveRecord::Base.connection.execute(my_query).to_a
    @planilla_individual_id = f[0].first

    my_query = "SELECT docente_cedula 
                FROM docente_planilla
                WHERE planilla_individual_id = #{@planilla_individual_id} AND
                      tipo_jurado_id LIKE 'TU'"

    conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
    f = conest_dummy_development_database.connection.execute(my_query).to_a
    #datos = ActiveRecord::Base.connection.execute(my_query).to_a
    tutores_ci = f

    # Si hay 2 tutores en la tabla docente_planilla
    if tutores_ci.size == 2
      @tutor  = tutores_ci[0].first
      my_query = "SELECT cedula, nombre, correo FROM docente WHERE cedula LIKE #{@tutor}"
      conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
      res = conest_dummy_development_database.connection.execute(my_query).to_a
      #res = ActiveRecord::Base.connection.execute(my_query).to_a
      @tutor1_ci = res[0][0]
      @tutor1_nombre = res[0][1]
      @tutor1_correo = res[0][2]  

      @tutor2 = tutores_ci[1].first
      my_query = "SELECT cedula, nombre, correo FROM docente WHERE cedula LIKE #{@tutor2}"
      conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
      res = conest_dummy_development_database.connection.execute(my_query).to_a
      #res = ActiveRecord::Base.connection.execute(my_query).to_a
      @tutor2_ci = res[0][0]
      @tutor2_nombre = res[0][1]
      @tutor2_correo = res[0][2] 
    end#if

    # Si hay 1 tutor en la tabla docente_planilla
    if tutores_ci.size == 1
      @tutor  = tutores_ci[0].first
      my_query = "SELECT cedula, nombre, correo FROM docente WHERE cedula LIKE #{@tutor}"
      conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
      res = conest_dummy_development_database.connection.execute(my_query).to_a
      #res = ActiveRecord::Base.connection.execute(my_query).to_a
      @tutor1_ci = res[0][0]
      @tutor1_nombre = res[0][1]
      @tutor1_correo = res[0][2]
    end#if

    # Buscar los tutores en la tabla calificador_externo_planilla
    my_query = "SELECT calificador_externo_cedula 
                FROM calificador_externo_planilla
                WHERE planilla_individual_id = #{@planilla_individual_id}
                      AND tipo_jurado_id LIKE 'TU'"
    conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
    datos = conest_dummy_development_database.connection.execute(my_query).to_a
    #datos = ActiveRecord::Base.connection.execute(my_query).to_a
    tutores_ci = datos

    # Si hay 2 tutores en la tabla calificador_externo_planilla
    if tutores_ci.size == 2
      @tutor  = tutores_ci[0].first
      my_query = "SELECT cedula, nombre, correo FROM calificador_externo WHERE cedula LIKE #{@tutor}"
      conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
      res = conest_dummy_development_database.connection.execute(my_query).to_a
      #res = ActiveRecord::Base.connection.execute(my_query).to_a
      @tutor1_ci = res[0][0]
      @tutor1_nombre = res[0][1]
      @tutor1_correo = res[0][2]  

      @tutor2 = tutores_ci[1].first
      my_query = "SELECT cedula, nombre, correo FROM calificador_externo WHERE cedula LIKE #{@tutor2}"
      conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
      res = conest_dummy_development_database.connection.execute(my_query).to_a
      #res = ActiveRecord::Base.connection.execute(my_query).to_a
      @tutor2_ci = res[1][0]
      @tutor2_nombre = res[1][1]
      @tutor2_correo = res[1][2] 
    end#if

    # Si hay 1 tutor en la tabla calificador_externo_planilla 
    if tutores_ci.size == 1
      @tutor  = tutores_ci[0].first
      my_query = "SELECT cedula, nombre, correo FROM calificador_externo WHERE cedula LIKE #{@tutor}"
      conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
      res = conest_dummy_development_database.connection.execute(my_query).to_a
      #res = ActiveRecord::Base.connection.execute(my_query).to_a
      @tutor2_ci = res[0][0]
      @tutor2_nombre = res[0][1]
      @tutor2_correo = res[0][2]
    end#if

    # Verificar si ya existe la Persona asociada al tutor1 en la Base de Datos de Busconest: migracion
    migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
    result = migracion_busconest_database.connection.execute("SELECT id FROM persona WHERE cedula LIKE \"#{@tutor1_ci}\"")

    @tutor1_persona_id = result.to_a.first[0] unless result.to_a.first.nil?

    # Si la pareja no esta registrada en la Base de Datos: migracion
    if @tutor1_persona_id.nil?
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
                 VALUES (\"#{@tutor1_ci}\",
                         \"#{@tutor1_nombre}\",
                         \"#{@tutor1_nombre}\",
                         \"#{@tutor1_nombre}\",
                         \"#{@tutor1_correo}\",
                         \"#{t}\",
                         \"#{t}\"
                          )"
      )

    end#if

    unless @tutor2_ci.nil?
      puts @tutor2_ci
    
      # Verificar si ya existe la Persona asociada al tutor2 en la Base de Datos de Busconest: migracion
      migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
      result = migracion_busconest_database.connection.execute("SELECT id FROM persona WHERE cedula LIKE \"#{@tutor2_ci}\"")

      @tutor2_persona_id = result.to_a.first[0] unless result.to_a.first.nil?

      # Si la pareja no esta registrada en la Base de Datos: migracion
      if @tutor2_persona_id.nil?
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
                 VALUES (\"#{@tutor2_ci}\",
                         \"#{@tutor2_nombre}\",
                         \"#{@tutor2_nombre}\",
                         \"#{@tutor2_nombre}\",
                         \"#{@tutor2_correo}\",
                         \"#{t}\",
                         \"#{t}\"
                          )"
        )

      end#if
      # Extraer el id de la Persona correspondiente al tutor2 en la Base de Datos Busconest: migracion
      # para poder establecer los foreign_key en la tabla Tutor
      #
      migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
      r = migracion_busconest_database.connection.execute("SELECT id FROM persona WHERE cedula LIKE \"#{@tutor2_ci}\"")
      @tutor2_persona_id = r.to_a.first[0]
    end#unless
    # Extraer el id de la Persona correspondiente al tutor1 en la Base de Datos Busconest: migracion
    # para poder establecer los foreign_key en la tabla Tutor
    #
    migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
    r = migracion_busconest_database.connection.execute("SELECT id FROM persona WHERE cedula LIKE \"#{@tutor1_ci}\"")
    @tutor1_persona_id = r.to_a.first[0]

    puts @tutor1_ci
    puts @tutor1_nombre
    puts @tutor1_correo
    puts @tutor1_persona_id

    puts @tutor2_ci
    puts @tutor2_nombre
    puts @tutor2_correo
    puts @tutor2_persona_id

    # CREAR JURADOS
    # Buscar los jurados en la tabla docente_planilla
    #puts 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    #puts @planilla_individual_id
    my_query = "SELECT docente_cedula 
                FROM docente_planilla
                WHERE planilla_individual_id = #{@planilla_individual_id}
                      AND (tipo_jurado_id LIKE 'JU')"

    conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
    datos = conest_dummy_development_database.connection.execute(my_query).to_a
    #datos = ActiveRecord::Base.connection.execute(my_query).to_a
    jurados_ci = datos
    #puts 'DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD'
    #puts datos

    # Si hay 2 jurados en la tabla docente_planilla
    if jurados_ci.size == 2
      @jurado  = jurados_ci[0].first
      my_query = "SELECT cedula, nombre, correo FROM docente WHERE cedula LIKE #{@jurado}"
      conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
      res = conest_dummy_development_database.connection.execute(my_query).to_a
      #res = ActiveRecord::Base.connection.execute(my_query).to_a
      @jurado1_ci = res[0][0]
      @jurado1_nombre = res[0][1]
      @jurado1_correo = res[0][2]  

      @jurado2 = jurados_ci[1].first
      my_query = "SELECT cedula, nombre, correo FROM docente WHERE cedula LIKE #{@jurado2}"
      conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
      res = conest_dummy_development_database.connection.execute(my_query).to_a
      #res = ActiveRecord::Base.connection.execute(my_query).to_a
      @jurado2_ci = res[0][0]
      @jurado2_nombre = res[0][1]
      @jurado2_correo = res[0][2] 
    end#if

    # Si hay 1 jurado en la tabla docente_planilla
    if jurados_ci.size == 1
      @jurado1  = jurados_ci[0].first
      my_query = "SELECT cedula, nombre, correo FROM docente WHERE cedula LIKE #{@jurado1}"
      conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
      res = conest_dummy_development_database.connection.execute(my_query).to_a
      #res = ActiveRecord::Base.connection.execute(my_query).to_a
      @jurado1_ci = res[0][0]
      @jurado1_nombre = res[0][1]
      @jurado1_correo = res[0][2]
    end#if

    my_query = "SELECT calificador_externo_cedula 
                FROM calificador_externo_planilla
                WHERE planilla_individual_id = #{@planilla_individual_id}
                      AND (tipo_jurado_id LIKE 'J1'
                      OR tipo_jurado_id LIKE 'J2')"

    conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
    datos = conest_dummy_development_database.connection.execute(my_query).to_a
    #datos = ActiveRecord::Base.connection.execute(my_query).to_a
    jurados_ci = datos

    # Si hay 2 jurados en la tabla calificador_externo_planilla
    if jurados_ci.size == 2
      @jurado1  = jurados_ci[0].first
      my_query = "SELECT cedula, nombre, correo FROM calificador_externo WHERE cedula LIKE #{@jurado1}"
      conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
      res = conest_dummy_development_database.connection.execute(my_query).to_a
      #res = ActiveRecord::Base.connection.execute(my_query).to_a
      @jurado1_ci = res[0][0]
      @jurado1_nombre = res[0][1]
      @jurado1_correo = res[0][2]  

      @jurado2 = jurados_ci[1].first
      my_query = "SELECT cedula, nombre, correo FROM calificador_externo WHERE cedula LIKE #{@jurado2}"
      conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
      res = conest_dummy_development_database.connection.execute(my_query).to_a
      #res = ActiveRecord::Base.connection.execute(my_query).to_a
      @jurado2_ci = res[0][0]
      @jurado2_nombre = res[0][1]
      @jurado2_correo = res[0][2] 
    end#if

    # Si hay 1 jurado en la tabla calificador_externo_planilla
    if jurados_ci.size == 1
      @jurado2  = jurados_ci[0].first
      my_query = "SELECT cedula, nombre, correo FROM calificador_externo WHERE cedula LIKE #{@jurado2}"
      conest_dummy_development_database = ActiveRecord::Base.establish_connection "conest_dummy_development"
      res = conest_dummy_development_database.connection.execute(my_query).to_a
      #res = ActiveRecord::Base.connection.execute(my_query).to_a
      @jurado2_ci = res[0][0]
      @jurado2_nombre = res[0][1]
      @jurado2_correo = res[0][2]
    end#if

    puts 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    puts @jurado1_ci
    puts @jurado1_nombre
    puts @jurado1_correo
    #puts @jurado1_persona_id

    puts @jurado2_ci
    puts @jurado2_nombre
    puts @jurado2_correo
    #puts @jurado2_persona_id

    # Verificar si ya existe la Persona asociada al jurado1 en la Base de Datos de Busconest: migracion
    migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
    result = migracion_busconest_database.connection.execute("SELECT id FROM persona WHERE cedula LIKE \"#{@jurado1_ci}\"")

    @jurado1_persona_id = result.to_a.first[0] unless result.to_a.first.nil?

    puts 'CCCCCCCCCCCCCCCC'
    puts @jurado1_persona_id
    # Si el jurado1 no esta registrado en la Base de Datos: migracion
    if @jurado1_persona_id.nil?
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
                 VALUES (\"#{@jurado1_ci}\",
                         \"#{@jurado1_nombre}\",
                         \"#{@jurado1_nombre}\",
                         \"#{@jurado1_nombre}\",
                         \"#{@jurado1_correo}\",
                         \"#{t}\",
                         \"#{t}\"
                          )"
      )
      # Extraer el id de la Persona correspondiente al jurado1 en la Base de Datos Busconest: migracion
      # para poder establecer los foreign_key en la tabla Jurado
      #
      puts 'ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ'
      puts @jurado1_ci

      migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
      r = migracion_busconest_database.connection.execute("SELECT id FROM persona WHERE cedula LIKE \"#{@jurado1_ci}\"")
      @jurado1_persona_id = r.to_a.first[0]
    end#if

    # Verificar si ya existe la Persona asociada al jurado2 en la Base de Datos de Busconest: migracion
    migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
    result = migracion_busconest_database.connection.execute("SELECT id FROM persona WHERE cedula LIKE \"#{@jurado2_ci}\"")

    @jurado2_persona_id = result.to_a.first[0] unless result.to_a.first.nil?

    # Si la pareja no esta registrada en la Base de Datos: migracion
    if @jurado2_persona_id.nil?
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
                 VALUES (\"#{@jurado2_ci}\",
                         \"#{@jurado2_nombre}\",
                         \"#{@jurado2_nombre}\",
                         \"#{@jurado2_nombre}\",
                         \"#{@jurado2_correo}\",
                         \"#{t}\",
                         \"#{t}\"
                          )"
      )

      # Extraer el id de la Persona correspondiente al tutor1 en la Base de Datos Busconest: migracion
      # para poder establecer los foreign_key en la tabla Tutor
      #
      migracion_busconest_database = ActiveRecord::Base.establish_connection "migracion_busconest_development"
      r = migracion_busconest_database.connection.execute("SELECT id FROM persona WHERE cedula LIKE \"#{@jurado2_ci}\"")
      @jurado2_persona_id = r.to_a.first[0]
    end#if

    puts '??????????????????????????????????????????????????'
    puts @jurado1_persona_id
    puts @jurado2_persona_id


  end#def
end#class
