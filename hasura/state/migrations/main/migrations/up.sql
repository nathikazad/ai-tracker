SET check_function_bodies = false;
CREATE TABLE public.event_types (
    name text NOT NULL,
    metadata jsonb,
    parent text
);
CREATE FUNCTION public.get_event_type_path(input_event_type public.event_types) RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    event_type_name text := input_event_type.name;
BEGIN
    RETURN (
        WITH RECURSIVE parent_tree AS (
            -- Base case
            SELECT 
                name, 
                parent, 
                1 AS depth
            FROM 
                event_types 
            WHERE 
                name = event_type_name
            UNION ALL
            -- Recursive step
            SELECT 
                e.name, 
                e.parent, 
                pt.depth + 1 AS depth
            FROM 
                event_types e
            JOIN 
                parent_tree pt ON e.name = pt.parent
        )
        SELECT 
            STRING_AGG(name, '/' ORDER BY depth DESC) AS path
        FROM 
            parent_tree
        WHERE 
            name != 'root'
    );
END;
$$;
CREATE TABLE public.interactions (
    id integer NOT NULL,
    content text NOT NULL,
    content_type character varying(40),
    embedding public.vector(1536) NOT NULL,
    user_id integer NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now()
);
CREATE FUNCTION public.match_interactions(query_embedding public.vector, match_threshold double precision, target_user_id integer) RETURNS SETOF public.interactions
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM interactions
  WHERE (interactions.embedding <#> query_embedding < -match_threshold)
    AND (interactions.user_id = target_user_id)
  ORDER BY interactions.embedding <#> query_embedding;
END;
$$;
CREATE TABLE public.event_tag (
    event_id integer NOT NULL,
    tag_name text NOT NULL
);
CREATE TABLE public.events (
    id integer NOT NULL,
    interaction_id integer,
    user_id integer NOT NULL,
    parent_id integer,
    logs jsonb,
    metadata jsonb,
    status text,
    "time" timestamp without time zone DEFAULT now(),
    cost_time integer,
    cost_money integer,
    event_type text NOT NULL,
    goal_id integer
);
COMMENT ON COLUMN public.events.cost_time IS 'seconds';
COMMENT ON COLUMN public.events.cost_money IS 'cents';
CREATE SEQUENCE public.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;
CREATE TABLE public.goals (
    id integer NOT NULL,
    nl_description text NOT NULL,
    name text NOT NULL,
    status text DEFAULT 'active'::text NOT NULL,
    user_id integer NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    period integer DEFAULT 1 NOT NULL,
    target_number integer,
    frequency jsonb
);
CREATE SEQUENCE public.goal_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.goal_id_seq OWNED BY public.goals.id;
CREATE SEQUENCE public.interactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.interactions_id_seq OWNED BY public.interactions.id;
CREATE TABLE public.todos (
    id integer NOT NULL,
    name text NOT NULL,
    goal_id integer,
    status text DEFAULT 'todo'::text NOT NULL,
    updated timestamp with time zone DEFAULT now() NOT NULL,
    due timestamp with time zone DEFAULT now() NOT NULL,
    user_id integer NOT NULL,
    target_count integer,
    current_count integer
);
CREATE SEQUENCE public.todo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.todo_id_seq OWNED BY public.todos.id;
CREATE TABLE public.users (
    id integer NOT NULL,
    apple_id text,
    timezone text
);
CREATE SEQUENCE public.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.user_id_seq OWNED BY public.users.id;
ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);
ALTER TABLE ONLY public.goals ALTER COLUMN id SET DEFAULT nextval('public.goal_id_seq'::regclass);
ALTER TABLE ONLY public.interactions ALTER COLUMN id SET DEFAULT nextval('public.interactions_id_seq'::regclass);
ALTER TABLE ONLY public.todos ALTER COLUMN id SET DEFAULT nextval('public.todo_id_seq'::regclass);
ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);
ALTER TABLE ONLY public.event_tag
    ADD CONSTRAINT event_tag_pkey PRIMARY KEY (event_id, tag_name);
ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.goals
    ADD CONSTRAINT goal_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.interactions
    ADD CONSTRAINT interactions_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.event_types
    ADD CONSTRAINT tags_name_key UNIQUE (name);
ALTER TABLE ONLY public.event_types
    ADD CONSTRAINT tags_pkey PRIMARY KEY (name);
ALTER TABLE ONLY public.todos
    ADD CONSTRAINT todo_goal_id_user_id_key UNIQUE (goal_id, user_id);
ALTER TABLE ONLY public.todos
    ADD CONSTRAINT todo_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);
CREATE INDEX interactions_embedding_idx ON public.interactions USING hnsw (embedding public.vector_ip_ops);
ALTER TABLE ONLY public.event_tag
    ADD CONSTRAINT event_tag_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.event_tag
    ADD CONSTRAINT event_tag_tag_fkey FOREIGN KEY (tag_name) REFERENCES public.event_types(name) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_goal_id_fkey FOREIGN KEY (goal_id) REFERENCES public.goals(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_interaction_id_fkey FOREIGN KEY (interaction_id) REFERENCES public.interactions(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.events(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_tag_name_fkey FOREIGN KEY (event_type) REFERENCES public.event_types(name) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.goals
    ADD CONSTRAINT goal_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.interactions
    ADD CONSTRAINT interactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.event_types
    ADD CONSTRAINT tags_parent_fkey FOREIGN KEY (parent) REFERENCES public.event_types(name) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.todos
    ADD CONSTRAINT todo_goal_id_fkey FOREIGN KEY (goal_id) REFERENCES public.goals(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.todos
    ADD CONSTRAINT todo_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
