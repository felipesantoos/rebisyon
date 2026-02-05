SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: card_state; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.card_state AS ENUM (
    'new',
    'learn',
    'review',
    'relearn'
);


--
-- Name: review_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.review_type AS ENUM (
    'learn',
    'review',
    'relearn',
    'cram'
);


--
-- Name: scheduler_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.scheduler_type AS ENUM (
    'sm2',
    'fsrs'
);


--
-- Name: theme_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.theme_type AS ENUM (
    'light',
    'dark',
    'auto'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: browser_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.browser_config (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    visible_columns text[] DEFAULT '{note,deck,tags,due,interval,ease}'::text[],
    column_widths jsonb DEFAULT '{}'::jsonb NOT NULL,
    sort_column character varying(100),
    sort_direction character varying(10) DEFAULT 'asc'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: browser_config_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.browser_config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: browser_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.browser_config_id_seq OWNED BY public.browser_config.id;


--
-- Name: cards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cards (
    id bigint NOT NULL,
    note_id bigint NOT NULL,
    card_type_id integer DEFAULT 0 NOT NULL,
    deck_id bigint NOT NULL,
    home_deck_id bigint,
    due bigint DEFAULT 0 NOT NULL,
    "interval" integer DEFAULT 0 NOT NULL,
    ease integer DEFAULT 2500 NOT NULL,
    lapses integer DEFAULT 0 NOT NULL,
    reps integer DEFAULT 0 NOT NULL,
    state public.card_state DEFAULT 'new'::public.card_state NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    flag smallint DEFAULT 0 NOT NULL,
    suspended boolean DEFAULT false NOT NULL,
    buried boolean DEFAULT false NOT NULL,
    stability double precision,
    difficulty double precision,
    last_review_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT check_due_valid CHECK ((due >= 0)),
    CONSTRAINT check_ease_range CHECK ((ease >= 1300)),
    CONSTRAINT check_flag_range CHECK (((flag >= 0) AND (flag <= 7))),
    CONSTRAINT check_home_deck CHECK (((home_deck_id IS NULL) OR (home_deck_id <> deck_id))),
    CONSTRAINT check_interval_non_negative CHECK (("interval" >= 0)),
    CONSTRAINT check_new_position CHECK (((state <> 'new'::public.card_state) OR ("position" >= 0))),
    CONSTRAINT check_review_due CHECK (((state <> 'review'::public.card_state) OR (due > '1000000000000'::bigint))),
    CONSTRAINT check_review_interval CHECK (((state <> 'review'::public.card_state) OR ("interval" >= 0)))
);


--
-- Name: cards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cards_id_seq OWNED BY public.cards.id;


--
-- Name: deck_options_presets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deck_options_presets (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    options_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    deleted_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: deck_options_presets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deck_options_presets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deck_options_presets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deck_options_presets_id_seq OWNED BY public.deck_options_presets.id;


--
-- Name: decks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.decks (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    parent_id bigint,
    options_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    deleted_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: decks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.decks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: decks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.decks_id_seq OWNED BY public.decks.id;


--
-- Name: deletions_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deletions_log (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    object_type character varying(50) NOT NULL,
    object_id bigint NOT NULL,
    object_data jsonb,
    deleted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT check_object_type CHECK (((object_type)::text = ANY ((ARRAY['note'::character varying, 'card'::character varying, 'deck'::character varying, 'note_type'::character varying])::text[])))
);


--
-- Name: deletions_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deletions_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deletions_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deletions_log_id_seq OWNED BY public.deletions_log.id;


--
-- Name: flag_names; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flag_names (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    flag_number smallint NOT NULL,
    name character varying(50) NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT check_flag_number CHECK (((flag_number >= 1) AND (flag_number <= 7)))
);


--
-- Name: flag_names_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flag_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flag_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flag_names_id_seq OWNED BY public.flag_names.id;


--
-- Name: jwt_denylist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jwt_denylist (
    id bigint NOT NULL,
    jti character varying NOT NULL,
    exp timestamp(6) without time zone NOT NULL
);


--
-- Name: jwt_denylist_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jwt_denylist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jwt_denylist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jwt_denylist_id_seq OWNED BY public.jwt_denylist.id;


--
-- Name: media; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.media (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    filename character varying(255) NOT NULL,
    hash character varying(64) NOT NULL,
    size bigint NOT NULL,
    mime_type character varying(100) NOT NULL,
    storage_path character varying(512) NOT NULL,
    deleted_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT check_size_positive CHECK ((size > 0))
);


--
-- Name: media_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.media_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: media_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.media_id_seq OWNED BY public.media.id;


--
-- Name: note_media; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.note_media (
    note_id bigint NOT NULL,
    media_id bigint NOT NULL,
    field_name character varying(100),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: note_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.note_types (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    fields_json jsonb DEFAULT '[]'::jsonb NOT NULL,
    card_types_json jsonb DEFAULT '[]'::jsonb NOT NULL,
    templates_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    deleted_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: note_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.note_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: note_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.note_types_id_seq OWNED BY public.note_types.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notes (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    guid character varying(36) NOT NULL,
    note_type_id bigint NOT NULL,
    fields_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    tags text[] DEFAULT '{}'::text[],
    marked boolean DEFAULT false NOT NULL,
    deleted_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT check_guid_format CHECK (((guid)::text ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'::text))
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notes_id_seq OWNED BY public.notes.id;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reviews (
    id bigint NOT NULL,
    card_id bigint NOT NULL,
    rating smallint NOT NULL,
    "interval" integer NOT NULL,
    ease integer NOT NULL,
    time_ms integer NOT NULL,
    review_type public.review_type NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT check_interval_valid CHECK (("interval" <> 0)),
    CONSTRAINT check_rating_range CHECK (((rating >= 1) AND (rating <= 4))),
    CONSTRAINT check_time_ms_positive CHECK ((time_ms > 0))
);


--
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reviews_id_seq OWNED BY public.reviews.id;


--
-- Name: saved_searches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.saved_searches (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    search_query text NOT NULL,
    deleted_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: saved_searches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.saved_searches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: saved_searches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.saved_searches_id_seq OWNED BY public.saved_searches.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: user_preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_preferences (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    language character varying DEFAULT 'pt-BR'::character varying NOT NULL,
    theme public.theme_type DEFAULT 'auto'::public.theme_type NOT NULL,
    auto_sync boolean DEFAULT true NOT NULL,
    next_day_starts_at time without time zone DEFAULT '04:00:00'::time without time zone NOT NULL,
    learn_ahead_limit integer DEFAULT 20 NOT NULL,
    timebox_time_limit integer DEFAULT 0 NOT NULL,
    video_driver character varying DEFAULT 'auto'::character varying NOT NULL,
    ui_size numeric(3,2) DEFAULT 1.0 NOT NULL,
    minimalist_mode boolean DEFAULT false NOT NULL,
    reduce_motion boolean DEFAULT false NOT NULL,
    paste_strips_formatting boolean DEFAULT false NOT NULL,
    paste_images_as_png boolean DEFAULT false NOT NULL,
    default_deck_behavior character varying DEFAULT 'current_deck'::character varying NOT NULL,
    show_play_buttons boolean DEFAULT true NOT NULL,
    interrupt_audio_on_answer boolean DEFAULT true NOT NULL,
    show_remaining_count boolean DEFAULT true NOT NULL,
    show_next_review_time boolean DEFAULT false NOT NULL,
    spacebar_answers_card boolean DEFAULT true NOT NULL,
    ignore_accents_in_search boolean DEFAULT false NOT NULL,
    default_search_text character varying,
    sync_audio_and_images boolean DEFAULT true NOT NULL,
    periodically_sync_media boolean DEFAULT false NOT NULL,
    force_one_way_sync boolean DEFAULT false NOT NULL,
    self_hosted_sync_server_url character varying(512),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT check_learn_ahead_limit CHECK ((learn_ahead_limit >= 0)),
    CONSTRAINT check_timebox_limit CHECK ((timebox_time_limit >= 0)),
    CONSTRAINT check_ui_size CHECK (((ui_size > (0)::numeric) AND (ui_size <= 3.0)))
);


--
-- Name: user_preferences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_preferences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_preferences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_preferences_id_seq OWNED BY public.user_preferences.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp(6) without time zone,
    remember_created_at timestamp(6) without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp(6) without time zone,
    last_sign_in_at timestamp(6) without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    confirmation_token character varying,
    confirmed_at timestamp(6) without time zone,
    confirmation_sent_at timestamp(6) without time zone,
    unconfirmed_email character varying,
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying,
    locked_at timestamp(6) without time zone,
    last_login_at timestamp(6) without time zone,
    deleted_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: browser_config id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.browser_config ALTER COLUMN id SET DEFAULT nextval('public.browser_config_id_seq'::regclass);


--
-- Name: cards id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards ALTER COLUMN id SET DEFAULT nextval('public.cards_id_seq'::regclass);


--
-- Name: deck_options_presets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deck_options_presets ALTER COLUMN id SET DEFAULT nextval('public.deck_options_presets_id_seq'::regclass);


--
-- Name: decks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decks ALTER COLUMN id SET DEFAULT nextval('public.decks_id_seq'::regclass);


--
-- Name: deletions_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deletions_log ALTER COLUMN id SET DEFAULT nextval('public.deletions_log_id_seq'::regclass);


--
-- Name: flag_names id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flag_names ALTER COLUMN id SET DEFAULT nextval('public.flag_names_id_seq'::regclass);


--
-- Name: jwt_denylist id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jwt_denylist ALTER COLUMN id SET DEFAULT nextval('public.jwt_denylist_id_seq'::regclass);


--
-- Name: media id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media ALTER COLUMN id SET DEFAULT nextval('public.media_id_seq'::regclass);


--
-- Name: note_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_types ALTER COLUMN id SET DEFAULT nextval('public.note_types_id_seq'::regclass);


--
-- Name: notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes ALTER COLUMN id SET DEFAULT nextval('public.notes_id_seq'::regclass);


--
-- Name: reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews ALTER COLUMN id SET DEFAULT nextval('public.reviews_id_seq'::regclass);


--
-- Name: saved_searches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_searches ALTER COLUMN id SET DEFAULT nextval('public.saved_searches_id_seq'::regclass);


--
-- Name: user_preferences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_preferences ALTER COLUMN id SET DEFAULT nextval('public.user_preferences_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: browser_config browser_config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.browser_config
    ADD CONSTRAINT browser_config_pkey PRIMARY KEY (id);


--
-- Name: cards cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (id);


--
-- Name: deck_options_presets deck_options_presets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deck_options_presets
    ADD CONSTRAINT deck_options_presets_pkey PRIMARY KEY (id);


--
-- Name: decks decks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decks
    ADD CONSTRAINT decks_pkey PRIMARY KEY (id);


--
-- Name: deletions_log deletions_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deletions_log
    ADD CONSTRAINT deletions_log_pkey PRIMARY KEY (id);


--
-- Name: flag_names flag_names_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flag_names
    ADD CONSTRAINT flag_names_pkey PRIMARY KEY (id);


--
-- Name: jwt_denylist jwt_denylist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jwt_denylist
    ADD CONSTRAINT jwt_denylist_pkey PRIMARY KEY (id);


--
-- Name: media media_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media
    ADD CONSTRAINT media_pkey PRIMARY KEY (id);


--
-- Name: note_media note_media_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_media
    ADD CONSTRAINT note_media_pkey PRIMARY KEY (note_id, media_id);


--
-- Name: note_types note_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_types
    ADD CONSTRAINT note_types_pkey PRIMARY KEY (id);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: saved_searches saved_searches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_searches
    ADD CONSTRAINT saved_searches_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: user_preferences user_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_preferences
    ADD CONSTRAINT user_preferences_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_cards_buried; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cards_buried ON public.cards USING btree (buried) WHERE (buried = true);


--
-- Name: idx_cards_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cards_created_at ON public.cards USING btree (created_at);


--
-- Name: idx_cards_deck_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cards_deck_id ON public.cards USING btree (deck_id);


--
-- Name: idx_cards_deck_state_due; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cards_deck_state_due ON public.cards USING btree (deck_id, state, due) WHERE ((suspended = false) AND (buried = false));


--
-- Name: idx_cards_due; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cards_due ON public.cards USING btree (due) WHERE ((suspended = false) AND (buried = false));


--
-- Name: idx_cards_flag; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cards_flag ON public.cards USING btree (flag) WHERE (flag > 0);


--
-- Name: idx_cards_fsrs_stability; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cards_fsrs_stability ON public.cards USING btree (stability) WHERE (stability IS NOT NULL);


--
-- Name: idx_cards_home_deck_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cards_home_deck_id ON public.cards USING btree (home_deck_id) WHERE (home_deck_id IS NOT NULL);


--
-- Name: idx_cards_note_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cards_note_id ON public.cards USING btree (note_id);


--
-- Name: idx_cards_note_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cards_note_state ON public.cards USING btree (note_id, state);


--
-- Name: idx_cards_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cards_position ON public.cards USING btree ("position") WHERE (state = 'new'::public.card_state);


--
-- Name: idx_cards_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cards_state ON public.cards USING btree (state) WHERE ((suspended = false) AND (buried = false));


--
-- Name: idx_cards_study_query; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cards_study_query ON public.cards USING btree (deck_id, state, due, suspended, buried) WHERE ((suspended = false) AND (buried = false));


--
-- Name: idx_cards_suspended; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cards_suspended ON public.cards USING btree (suspended) WHERE (suspended = true);


--
-- Name: idx_cards_sync; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cards_sync ON public.cards USING btree (note_id, updated_at);


--
-- Name: idx_decks_unique_name_child; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_decks_unique_name_child ON public.decks USING btree (user_id, name, parent_id) WHERE ((parent_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: idx_decks_unique_name_root; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_decks_unique_name_root ON public.decks USING btree (user_id, name) WHERE ((parent_id IS NULL) AND (deleted_at IS NULL));


--
-- Name: idx_deletions_log_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_deletions_log_deleted_at ON public.deletions_log USING btree (deleted_at);


--
-- Name: idx_deletions_log_object; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_deletions_log_object ON public.deletions_log USING btree (object_type, object_id);


--
-- Name: idx_deletions_log_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_deletions_log_user_id ON public.deletions_log USING btree (user_id);


--
-- Name: idx_flag_names_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_flag_names_user_id ON public.flag_names USING btree (user_id);


--
-- Name: idx_media_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_media_hash ON public.media USING btree (hash);


--
-- Name: idx_media_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_media_user_id ON public.media USING btree (user_id);


--
-- Name: idx_note_media_media_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_note_media_media_id ON public.note_media USING btree (media_id);


--
-- Name: idx_note_media_note_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_note_media_note_id ON public.note_media USING btree (note_id);


--
-- Name: idx_notes_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notes_active ON public.notes USING btree (user_id, note_type_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_notes_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notes_created_at ON public.notes USING btree (created_at) WHERE (deleted_at IS NULL);


--
-- Name: idx_notes_fields_fts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notes_fields_fts ON public.notes USING gin (to_tsvector('portuguese'::regconfig, (fields_json)::text)) WHERE (deleted_at IS NULL);


--
-- Name: idx_notes_guid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notes_guid ON public.notes USING btree (guid);


--
-- Name: idx_notes_marked; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notes_marked ON public.notes USING btree (marked) WHERE (deleted_at IS NULL);


--
-- Name: idx_notes_note_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notes_note_type_id ON public.notes USING btree (note_type_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_notes_sync; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notes_sync ON public.notes USING btree (user_id, updated_at) WHERE (deleted_at IS NULL);


--
-- Name: idx_notes_tags; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notes_tags ON public.notes USING gin (tags) WHERE (deleted_at IS NULL);


--
-- Name: idx_notes_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notes_updated_at ON public.notes USING btree (updated_at) WHERE (deleted_at IS NULL);


--
-- Name: idx_notes_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notes_user_id ON public.notes USING btree (user_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_reviews_card_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reviews_card_created ON public.reviews USING btree (card_id, created_at);


--
-- Name: idx_reviews_card_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reviews_card_id ON public.reviews USING btree (card_id);


--
-- Name: idx_reviews_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reviews_created_at ON public.reviews USING btree (created_at);


--
-- Name: idx_saved_searches_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_saved_searches_user_id ON public.saved_searches USING btree (user_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_users_email_active; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_users_email_active ON public.users USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: index_browser_config_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_browser_config_on_user_id ON public.browser_config USING btree (user_id);


--
-- Name: index_decks_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decks_on_name ON public.decks USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: index_decks_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decks_on_parent_id ON public.decks USING btree (parent_id) WHERE (deleted_at IS NULL);


--
-- Name: index_decks_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decks_on_user_id ON public.decks USING btree (user_id) WHERE (deleted_at IS NULL);


--
-- Name: index_decks_on_user_id_and_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decks_on_user_id_and_parent_id ON public.decks USING btree (user_id, parent_id) WHERE (deleted_at IS NULL);


--
-- Name: index_decks_on_user_id_and_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decks_on_user_id_and_updated_at ON public.decks USING btree (user_id, updated_at) WHERE (deleted_at IS NULL);


--
-- Name: index_jwt_denylist_on_exp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jwt_denylist_on_exp ON public.jwt_denylist USING btree (exp);


--
-- Name: index_jwt_denylist_on_jti; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_jwt_denylist_on_jti ON public.jwt_denylist USING btree (jti);


--
-- Name: index_note_types_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_types_on_name ON public.note_types USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: index_note_types_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_types_on_user_id ON public.note_types USING btree (user_id) WHERE (deleted_at IS NULL);


--
-- Name: index_user_preferences_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_preferences_on_user_id ON public.user_preferences USING btree (user_id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_created_at ON public.users USING btree (created_at);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON public.users USING btree (unlock_token);


--
-- Name: notes_guid_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX notes_guid_key ON public.notes USING btree (guid) WHERE (deleted_at IS NULL);


--
-- Name: unique_flag_per_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_flag_per_user ON public.flag_names USING btree (user_id, flag_number);


--
-- Name: unique_media_hash_per_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_media_hash_per_user ON public.media USING btree (user_id, hash, deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: unique_note_media_field; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_note_media_field ON public.note_media USING btree (note_id, media_id, field_name);


--
-- Name: unique_note_type_name_per_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_note_type_name_per_user ON public.note_types USING btree (user_id, name, deleted_at);


--
-- Name: unique_preset_name_per_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_preset_name_per_user ON public.deck_options_presets USING btree (user_id, name, deleted_at);


--
-- Name: unique_saved_search_name_per_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_saved_search_name_per_user ON public.saved_searches USING btree (user_id, name, deleted_at);


--
-- Name: decks fk_rails_0bafed89b2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decks
    ADD CONSTRAINT fk_rails_0bafed89b2 FOREIGN KEY (parent_id) REFERENCES public.decks(id);


--
-- Name: note_media fk_rails_314cf3a387; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_media
    ADD CONSTRAINT fk_rails_314cf3a387 FOREIGN KEY (note_id) REFERENCES public.notes(id);


--
-- Name: deletions_log fk_rails_3b80abfbe0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deletions_log
    ADD CONSTRAINT fk_rails_3b80abfbe0 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: media fk_rails_3e7fe89c9c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media
    ADD CONSTRAINT fk_rails_3e7fe89c9c FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: note_media fk_rails_447a8d7256; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_media
    ADD CONSTRAINT fk_rails_447a8d7256 FOREIGN KEY (media_id) REFERENCES public.media(id);


--
-- Name: notes fk_rails_573fae1b86; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT fk_rails_573fae1b86 FOREIGN KEY (note_type_id) REFERENCES public.note_types(id);


--
-- Name: decks fk_rails_5d31349cbe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decks
    ADD CONSTRAINT fk_rails_5d31349cbe FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: saved_searches fk_rails_63c5382842; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_searches
    ADD CONSTRAINT fk_rails_63c5382842 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: cards fk_rails_6c4effce17; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT fk_rails_6c4effce17 FOREIGN KEY (deck_id) REFERENCES public.decks(id);


--
-- Name: reviews fk_rails_6db99a1526; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT fk_rails_6db99a1526 FOREIGN KEY (card_id) REFERENCES public.cards(id);


--
-- Name: notes fk_rails_7f2323ad43; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT fk_rails_7f2323ad43 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: note_types fk_rails_86e5b39b6e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_types
    ADD CONSTRAINT fk_rails_86e5b39b6e FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_preferences fk_rails_a69bfcfd81; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_preferences
    ADD CONSTRAINT fk_rails_a69bfcfd81 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: cards fk_rails_e284ecf7c6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT fk_rails_e284ecf7c6 FOREIGN KEY (home_deck_id) REFERENCES public.decks(id);


--
-- Name: deck_options_presets fk_rails_e63d9922e5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deck_options_presets
    ADD CONSTRAINT fk_rails_e63d9922e5 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: browser_config fk_rails_f204c4abe9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.browser_config
    ADD CONSTRAINT fk_rails_f204c4abe9 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: cards fk_rails_f6657ef635; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT fk_rails_f6657ef635 FOREIGN KEY (note_id) REFERENCES public.notes(id);


--
-- Name: flag_names fk_rails_fcb6bf0985; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flag_names
    ADD CONSTRAINT fk_rails_fcb6bf0985 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20260205000016'),
('20260205000015'),
('20260205000014'),
('20260205000013'),
('20260205000012'),
('20260205000011'),
('20260205000010'),
('20260205000009'),
('20260205000008'),
('20260205000007'),
('20260205000006'),
('20260205000005'),
('20260205000004'),
('20260205000003'),
('20260205000002'),
('20260205000001');

