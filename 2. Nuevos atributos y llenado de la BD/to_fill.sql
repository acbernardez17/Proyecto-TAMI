/*************************************************************/
/* Sentencias de creado para tablas que serán rellenadas */
/*************************************************************/

CREATE TABLE HOTEL
(
    ID_HOTEL   	    VARCHAR(6) NOT NULL,
    DIRECCION    	VARCHAR(40) NOT NULL UNIQUE,
    ESTRELLAS		INT(1) UNSIGNED NOT NULL,
    NOMBRE   		VARCHAR(40) NOT NULL,
    
    ULTIMA_ACTUALIZACION timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

        PRIMARY KEY (ID_HOTEL)
);

CREATE TABLE ESPACIO
(
    ID_ESPACIO   	    VARCHAR(9) NOT NULL,
    NOMBRE   		    VARCHAR(40),
    SUPERFICIE		    FLOAT(6,3) UNSIGNED NOT NULL,
    ID_HOTEL            VARCHAR(6) NOT NULL,
    # ID_ESPACIO_CONT	    VARCHAR(9), # ID del espacio contenedor, si existe.

    ULTIMA_ACTUALIZACION timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

        PRIMARY KEY (ID_ESPACIO),
        FOREIGN KEY (ID_HOTEL) REFERENCES HOTEL(ID_HOTEL) ON DELETE CASCADE
        # Si se borra un hotel, se borran sus espacios.
);

# ALTER TABLE ESPACIO ADD FOREIGN KEY(ID_ESPACIO_CONT) REFERENCES ESPACIO(ID_ESPACIO) ON DELETE SET NULL;
# Por defecto, si borramos un espacio, sus subespacios
# se mantienen como "huérfanos".

CREATE TABLE ESPACIO_INSTALACION
(
    ID_ESPACIO   		VARCHAR(9) NOT NULL,
    AFORO			    INT(5) UNSIGNED,
    HORARIO_ACCESIBLE	VARCHAR(40),
    ES_EXTERIOR		    enum('Sí', 'No') NOT NULL,
    USO_INFANTIL		enum('Sí', 'No') NOT NULL,

    ULTIMA_ACTUALIZACION timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

        PRIMARY KEY (ID_ESPACIO),
        FOREIGN KEY (ID_ESPACIO) REFERENCES ESPACIO(ID_ESPACIO) ON DELETE CASCADE
        # Borrado en cascada: Si borramos los datos generales de espacio de un
        # espacio de instalación borramos también sus datos concretos.
);

CREATE TABLE ESPACIO_HOSPEDAJE
(
    ID_ESPACIO          VARCHAR(9) NOT NULL,
    NUM_BANHOS          INT(2),
    NUM_CAMAS           INT(2) NOT NULL,
    TIENE_TERRAZA       enum('Sí', 'No') NOT NULL,
    ADMITE_FUMADORES    enum('Sí', 'No') NOT NULL,
    ADMITE_MASCOTAS     enum('Sí', 'No') NOT NULL,

    ULTIMA_ACTUALIZACION timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

        PRIMARY KEY (ID_ESPACIO),
        FOREIGN KEY (ID_ESPACIO) REFERENCES ESPACIO(ID_ESPACIO) ON DELETE CASCADE
        # Borrado en cascada: Si borramos los datos generales de espacio de un
        # espacio de hospedaje borramos también sus datos concretos.
);

CREATE TABLE HABITACION
(
    ID_ESPACIO  VARCHAR(9) NOT NULL,
    TIPO        enum('INDIVIDUAL', 'DOBLE', 'TRIPLE', 'CUADRUPLE') NOT NULL,
    ES_SUITE    enum('Sí', 'No') NOT NULL,

    ULTIMA_ACTUALIZACION timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

        PRIMARY KEY (ID_ESPACIO),
        FOREIGN KEY (ID_ESPACIO) REFERENCES ESPACIO_HOSPEDAJE(ID_ESPACIO) ON DELETE CASCADE
        # Borrado en cascada: Si borramos los datos generales de espacio de hospedaje
        # de una habitación borramos también sus datos concretos.
);

CREATE TABLE APARTAMENTO
(
    ID_ESPACIO          VARCHAR(9) NOT NULL,
    TIENE_SALON         enum('Sí', 'No') NOT NULL,
    COCINA_ELECTRICA    enum('Sí', 'No') NOT NULL,

    ULTIMA_ACTUALIZACION timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

        PRIMARY KEY (ID_ESPACIO),
        FOREIGN KEY (ID_ESPACIO) REFERENCES ESPACIO_HOSPEDAJE(ID_ESPACIO) ON DELETE CASCADE
        # Borrado en cascada: Si borramos los datos generales de espacio de hospedaje
        # de un apartamento borramos también sus datos concretos.
);

CREATE TABLE PERSONA
(
    NUM_ID              VARCHAR (9) NOT NULL,
    NOMBRE              VARCHAR (40) NOT NULL,
    TELEFONO            VARCHAR(31) NOT NULL UNIQUE, #  Incluye Prefijo(hasta 5 dígitos), número (hasta 15) y sufijo(hasta 11).
    FECHA_NACIMIENTO    DATE,

    ULTIMA_ACTUALIZACION timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

        PRIMARY KEY (NUM_ID)
);

CREATE TABLE CLIENTE
(
    ID_CLIENTE              VARCHAR (9) NOT NULL, #clave subrogada
    FECHA_PRIMER_CONTRATO   DATE NOT NULL,

    ULTIMA_ACTUALIZACION timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

        PRIMARY KEY (ID_CLIENTE)
);

CREATE TABLE HUESPED
(
    NUM_ID          VARCHAR(9) NOT NULL,
    ID_CLIENTE      VARCHAR(9) UNIQUE,
    NACIONALIDAD    VARCHAR(20) NOT NULL,
    NUM_TARJETA     VARCHAR(19) UNIQUE,

    ULTIMA_ACTUALIZACION timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

        PRIMARY KEY (NUM_ID),
        FOREIGN KEY (ID_CLIENTE) REFERENCES CLIENTE(ID_CLIENTE) ON DELETE SET NULL,
        # Un huésped puede no ser un cliente, por lo que si borramos sus datos
        # de cliente, mantendremos los de huésped.
        FOREIGN KEY (NUM_ID) REFERENCES PERSONA(NUM_ID) ON DELETE CASCADE
        # Si borramos los datos de persona, borramos también los de huésped.
);

CREATE TABLE EMPRESA
(
    CIF             VARCHAR(9) NOT NULL,
    ID_CLIENTE      VARCHAR(9) UNIQUE,
    NOMBRE          VARCHAR(40) NOT NULL,
    NUM_EMPLEADOS   INT(4) UNSIGNED,

    ULTIMA_ACTUALIZACION timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

        PRIMARY KEY (CIF),
        FOREIGN KEY (ID_CLIENTE) REFERENCES CLIENTE(ID_CLIENTE) ON DELETE SET NULL
        # Una empresa puede no ser un cliente, por lo que si borramos sus datos
        # de cliente, mantendremos los de empresa.
);

CREATE TABLE AGENCIA
(
    COD_AGENCIA                 VARCHAR(9) NOT NULL,
    ID_CLIENTE                  VARCHAR(9) UNIQUE,
    NOMBRE                      VARCHAR(40) NOT NULL,
    FECHA_INICIO_RELACIONES     DATE NOT NULL,

    ULTIMA_ACTUALIZACION timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

        PRIMARY KEY (COD_AGENCIA),
        FOREIGN KEY (ID_CLIENTE) REFERENCES CLIENTE (ID_CLIENTE) ON DELETE SET NULL
        # Una agencia puede no ser un cliente, por lo que si borramos sus datos
        # de cliente, mantendremos los de agencia.
);

CREATE TABLE CLIENTE_RESERVA_ESP_HOSPEDAJE
(
    ID_RESERVA      VARCHAR(20) NOT NULL,
    ID_CLIENTE      VARCHAR(9) NOT NULL UNIQUE,
    ID_ESPACIO      VARCHAR(9) NOT NULL UNIQUE,
    FECHA_RESERVA   DATE NOT NULL,
    FECHA_ENTRADA   DATE NOT NULL UNIQUE,
    FECHA_SALIDA    DATE NOT NULL,
    PRECIO          FLOAT(8,2) UNSIGNED,

        PRIMARY KEY (ID_RESERVA),
        FOREIGN KEY (ID_CLIENTE) REFERENCES CLIENTE (ID_CLIENTE) ON DELETE CASCADE,
        FOREIGN KEY (ID_ESPACIO) REFERENCES ESPACIO_HOSPEDAJE(ID_ESPACIO) ON DELETE CASCADE
        # Si se borran el espacio reservado o el cliente que reserva, se borra la reserva en cascada.
);