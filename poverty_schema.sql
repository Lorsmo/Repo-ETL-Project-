-- Table: public.poverty

-- DROP TABLE public.poverty;

CREATE TABLE public.poverty
(
    id integer NOT NULL DEFAULT nextval('poverty_id_seq'::regclass),
    state_fips_code integer NOT NULL,
    county_fips_code integer NOT NULL,
    name_county character varying(50) COLLATE pg_catalog."default" NOT NULL,
    state_abbr character varying(3) COLLATE pg_catalog."default" NOT NULL,
    poverty_population character varying(10) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT poverty_pkey PRIMARY KEY (id)
);