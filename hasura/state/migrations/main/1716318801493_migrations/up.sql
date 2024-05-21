SET check_function_bodies = false;
CREATE TABLE public.locations (
    location public.geography(Point,4326) NOT NULL,
    user_id integer NOT NULL,
    name text,
    id integer NOT NULL
);
CREATE TABLE public.users (
    id integer NOT NULL,
    apple_id text,
    timezone text,
    language text DEFAULT 'en'::text NOT NULL,
    name text DEFAULT 'username'::text NOT NULL,
    config jsonb DEFAULT jsonb_build_object() NOT NULL
);
CREATE FUNCTION public.closest_user_location(user_row public.users, ref_point text, radius double precision) RETURNS SETOF public.locations
    LANGUAGE sql STABLE
    AS $$
  SELECT l.* FROM public.locations AS l
  WHERE l.user_id = user_row.id
    AND ST_DWithin(l.location, ST_GeogFromText(ref_point), radius)
  ORDER BY ST_Distance(l.location, ST_GeogFromText(ref_point))
$$;
CREATE TABLE public.associations (
    id integer NOT NULL,
    ref_one_id integer NOT NULL,
    ref_one_table text NOT NULL,
    ref_two_id integer NOT NULL,
    ref_two_table text NOT NULL
);
CREATE TABLE public.events (
    id integer NOT NULL,
    interaction_id integer,
    user_id integer NOT NULL,
    parent_id integer,
    logs jsonb,
    metadata jsonb,
    status text,
    start_time timestamp without time zone,
    cost_time integer,
    cost_money integer,
    event_type text NOT NULL,
    end_time timestamp without time zone
);
COMMENT ON COLUMN public.events.cost_time IS 'seconds';
COMMENT ON COLUMN public.events.cost_money IS 'cents';
CREATE FUNCTION public.event_association_by_type(event_row public.events, association_type text) RETURNS SETOF public.associations
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN QUERY
    SELECT ea.*
    FROM public.fetch_associations('events', event_row.id) ea
    WHERE ea.ref_two_table = association_type;
END;
$$;
CREATE FUNCTION public.event_associations(event_row public.events) RETURNS SETOF public.associations
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    -- Return all associations related to the event ID
    RETURN QUERY
    SELECT * FROM fetch_associations('events', event_row.id);
END;
$$;
CREATE FUNCTION public.event_duration(event_row public.events) RETURNS integer
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    -- Check if either start_time or end_time is null
    IF event_row.start_time IS NULL OR event_row.end_time IS NULL THEN
        RETURN 0; -- Return 0 if any timestamp is null
    ELSE
        -- Calculate the duration in seconds if both timestamps are present
        RETURN EXTRACT(EPOCH FROM (event_row.end_time - event_row.start_time));
    END IF;
END;
$$;
CREATE FUNCTION public.event_locations(event_row public.events) RETURNS SETOF public.locations
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN QUERY
    SELECT loc.*
    FROM locations loc
    WHERE loc.id IN (
        SELECT ea.ref_two_id
        FROM public.event_association_by_type(event_row, 'locations') ea
    );
END;
$$;
CREATE TABLE public.objects (
    id integer NOT NULL,
    object_type text NOT NULL,
    name text NOT NULL
);
CREATE FUNCTION public.event_objects(event_row public.events) RETURNS SETOF public.objects
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN QUERY
    SELECT obj.*
    FROM objects obj
    WHERE obj.id IN (
        SELECT ea.ref_two_id
        FROM public.event_association_by_type(event_row, 'objects') ea
    );
END;
$$;
CREATE FUNCTION public.fetch_associations(from_row_type text, from_row_id integer) RETURNS SETOF public.associations
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN 
    RETURN QUERY
    SELECT
      id,
      CASE
        WHEN ref_two_table = from_row_type AND ref_two_id = from_row_id THEN ref_two_id
        ELSE ref_one_id
      END as ref_one_id,
      CASE
        WHEN ref_two_table = from_row_type AND ref_two_id = from_row_id THEN ref_two_table
        ELSE ref_one_table
      END as ref_one_table,
      CASE
        WHEN ref_two_table = from_row_type AND ref_two_id = from_row_id THEN ref_one_id
        ELSE ref_two_id
      END as ref_two_id,
      CASE
        WHEN ref_two_table = from_row_type AND ref_two_id = from_row_id THEN ref_one_table
        ELSE ref_two_table
      END as ref_two_table
    FROM
      associations
    WHERE
      (ref_one_table = from_row_type AND ref_one_id = from_row_id)
      OR (ref_two_table = from_row_type AND ref_two_id = from_row_id);
END;
$$;
CREATE TABLE public.event_types (
    name text NOT NULL,
    metadata jsonb,
    parent text,
    embedding public.vector(1536)
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
    "timestamp" timestamp with time zone DEFAULT now(),
    debug jsonb,
    match_score double precision DEFAULT '0'::double precision NOT NULL,
    transcode_version integer DEFAULT 0 NOT NULL
);
CREATE FUNCTION public.match_interactions(query_embedding public.vector, match_threshold double precision, target_user_id integer) RETURNS SETOF public.interactions
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
  RETURN QUERY
  SELECT 
    i.id,
    i.content,
    i.content_type,
    i.embedding,
    i.user_id,
    i.timestamp,
    i.debug,
    i.embedding <#> query_embedding
  FROM interactions i
  WHERE (i.embedding <#> query_embedding < -match_threshold)
    AND (i.user_id = target_user_id)
  ORDER BY i.embedding <#> query_embedding;
END;
$$;
CREATE FUNCTION public.object_events(object_row public.objects) RETURNS SETOF public.events
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN QUERY
    SELECT ev.*
    FROM events ev
    JOIN (
        SELECT
            CASE
                WHEN ref_one_table = 'events' THEN ref_one_id
                ELSE ref_two_id
            END as event_id
        FROM fetch_associations('objects', object_row.id)
        WHERE (ref_two_table = 'events')
    ) as assoc
    ON ev.id = assoc.event_id;
END;
$$;
CREATE SEQUENCE public.associations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.associations_id_seq OWNED BY public.associations.id;
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
CREATE SEQUENCE public.locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;
CREATE TABLE public.object_types (
    id text NOT NULL,
    metadata jsonb NOT NULL
);
CREATE SEQUENCE public.objects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.objects_id_seq OWNED BY public.objects.id;
CREATE TABLE public.todos (
    id integer NOT NULL,
    name text NOT NULL,
    goal_id integer,
    status text DEFAULT 'todo'::text NOT NULL,
    updated timestamp with time zone DEFAULT now() NOT NULL,
    due timestamp with time zone DEFAULT now() NOT NULL,
    user_id integer NOT NULL,
    current_count integer,
    done_as_expected boolean
);
CREATE SEQUENCE public.todo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.todo_id_seq OWNED BY public.todos.id;
CREATE SEQUENCE public.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.user_id_seq OWNED BY public.users.id;
CREATE TABLE public.user_movements (
    id integer NOT NULL,
    user_id integer NOT NULL,
    movements jsonb[],
    date timestamp with time zone NOT NULL,
    moves jsonb DEFAULT jsonb_build_object() NOT NULL
);
CREATE SEQUENCE public.user_movements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.user_movements_id_seq OWNED BY public.user_movements.id;
ALTER TABLE ONLY public.associations ALTER COLUMN id SET DEFAULT nextval('public.associations_id_seq'::regclass);
ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);
ALTER TABLE ONLY public.goals ALTER COLUMN id SET DEFAULT nextval('public.goal_id_seq'::regclass);
ALTER TABLE ONLY public.interactions ALTER COLUMN id SET DEFAULT nextval('public.interactions_id_seq'::regclass);
ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);
ALTER TABLE ONLY public.objects ALTER COLUMN id SET DEFAULT nextval('public.objects_id_seq'::regclass);
ALTER TABLE ONLY public.todos ALTER COLUMN id SET DEFAULT nextval('public.todo_id_seq'::regclass);
ALTER TABLE ONLY public.user_movements ALTER COLUMN id SET DEFAULT nextval('public.user_movements_id_seq'::regclass);
ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);
ALTER TABLE ONLY public.associations
    ADD CONSTRAINT associations_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.goals
    ADD CONSTRAINT goal_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.interactions
    ADD CONSTRAINT interactions_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_id_key UNIQUE (id);
ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.object_types
    ADD CONSTRAINT object_types_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.event_types
    ADD CONSTRAINT tags_name_key UNIQUE (name);
ALTER TABLE ONLY public.event_types
    ADD CONSTRAINT tags_pkey PRIMARY KEY (name);
ALTER TABLE ONLY public.todos
    ADD CONSTRAINT todo_goal_id_user_id_key UNIQUE (goal_id, user_id);
ALTER TABLE ONLY public.todos
    ADD CONSTRAINT todo_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.user_movements
    ADD CONSTRAINT user_movements_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.user_movements
    ADD CONSTRAINT user_movements_user_id_date_key UNIQUE (user_id, date);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);
CREATE INDEX event_types_embedding_idx ON public.event_types USING hnsw (embedding public.vector_ip_ops);
CREATE INDEX interactions_embedding_idx ON public.interactions USING hnsw (embedding public.vector_ip_ops);
ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_interaction_id_fkey FOREIGN KEY (interaction_id) REFERENCES public.interactions(id) ON UPDATE CASCADE ON DELETE CASCADE;
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
ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.objects
    ADD CONSTRAINT objects_object_type_fkey FOREIGN KEY (object_type) REFERENCES public.object_types(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.event_types
    ADD CONSTRAINT tags_parent_fkey FOREIGN KEY (parent) REFERENCES public.event_types(name) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.todos
    ADD CONSTRAINT todo_goal_id_fkey FOREIGN KEY (goal_id) REFERENCES public.goals(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.todos
    ADD CONSTRAINT todo_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
