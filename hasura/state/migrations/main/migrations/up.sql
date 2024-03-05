SET check_function_bodies = false;
CREATE TABLE public.interactions (
    id integer NOT NULL,
    content text NOT NULL,
    content_type character varying(40),
    embedding public.vector(1536) NOT NULL,
    user_id integer NOT NULL
);
CREATE FUNCTION public.match_interactions(query_embedding public.vector, match_threshold double precision, user_id integer DEFAULT NULL::integer) RETURNS SETOF public.interactions
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM interactions -- Adjusted from 'documents' to 'interactions' based on your context
  WHERE (interactions.embedding <#> query_embedding < -match_threshold)
    AND (user_id IS NULL OR interactions.user_id = user_id) -- Check for user_id if provided
  ORDER BY interactions.embedding <#> query_embedding;
END;
$$;
CREATE SEQUENCE public.interactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.interactions_id_seq OWNED BY public.interactions.id;
CREATE TABLE public."user" (
    id integer NOT NULL
);
CREATE SEQUENCE public.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.user_id_seq OWNED BY public."user".id;
ALTER TABLE ONLY public.interactions ALTER COLUMN id SET DEFAULT nextval('public.interactions_id_seq'::regclass);
ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);
ALTER TABLE ONLY public.interactions
    ADD CONSTRAINT interactions_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);
CREATE INDEX interactions_embedding_idx ON public.interactions USING hnsw (embedding public.vector_ip_ops);
ALTER TABLE ONLY public.interactions
    ADD CONSTRAINT interactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
