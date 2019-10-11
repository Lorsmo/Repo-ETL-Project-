-- Table: public.co_income

-- DROP TABLE public.co_income;

CREATE TABLE public.co_income
(
    id text COLLATE pg_catalog."default" NOT NULL,
    state text COLLATE pg_catalog."default",
    county text COLLATE pg_catalog."default",
    p_c_p_income integer,
    CONSTRAINT co_income_pkey PRIMARY KEY (id)
);
