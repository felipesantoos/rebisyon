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
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'Main schema for Anki system';


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


--
-- Name: count_due_cards(bigint, bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.count_due_cards(p_deck_id bigint, p_timestamp bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN (
    SELECT COUNT(*)
    FROM cards
    WHERE deck_id = p_deck_id
      AND state = 'review'
      AND due <= p_timestamp
      AND suspended = FALSE
      AND buried = FALSE
  );
END;
$$;


--
-- Name: count_learning_cards(bigint, bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.count_learning_cards(p_deck_id bigint, p_timestamp bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN (
    SELECT COUNT(*)
    FROM cards
    WHERE deck_id = p_deck_id
      AND state IN ('learn', 'relearn')
      AND due <= p_timestamp
      AND suspended = FALSE
      AND buried = FALSE
  );
END;
$$;


--
-- Name: count_new_cards(bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.count_new_cards(p_deck_id bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN (
    SELECT COUNT(*)
    FROM cards
    WHERE deck_id = p_deck_id
      AND state = 'new'
      AND suspended = FALSE
      AND buried = FALSE
  );
END;
$$;


--
-- Name: generate_guid(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_guid() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN gen_random_uuid()::VARCHAR;
END;
$$;


--
-- Name: log_note_deletion(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.log_note_deletion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN
    INSERT INTO deletions_log (user_id, object_type, object_id, object_data)
    VALUES (
      OLD.user_id,
      'note',
      OLD.id,
      jsonb_build_object(
        'guid', OLD.guid,
        'note_type_id', OLD.note_type_id,
        'fields', OLD.fields_json,
        'tags', OLD.tags
      )
    );
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: reset_sequences(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reset_sequences() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  seq_name TEXT;
  max_id BIGINT;
BEGIN
  FOR seq_name IN
    SELECT sequence_name
    FROM information_schema.sequences
    WHERE sequence_schema = 'public'
  LOOP
    EXECUTE format('SELECT COALESCE(MAX(id), 0) FROM %I',
      REPLACE(seq_name, '_id_seq', ''));
    GET DIAGNOSTICS max_id = ROW_COUNT;
    EXECUTE format('SELECT setval(%L, %s)', seq_name, max_id + 1);
  END LOOP;
END;
$$;


--
-- Name: set_note_guid(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_note_guid() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.guid IS NULL OR NEW.guid = '' THEN
    NEW.guid = generate_guid();
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;


--
-- Name: validate_single_ankiweb_sync(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_single_ankiweb_sync() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.ankiweb_sync_enabled = TRUE AND (OLD.ankiweb_sync_enabled IS NULL OR OLD.ankiweb_sync_enabled = FALSE) THEN
    IF EXISTS (
      SELECT 1 FROM profiles
      WHERE user_id = NEW.user_id
        AND id != NEW.id
        AND ankiweb_sync_enabled = TRUE
        AND deleted_at IS NULL
    ) THEN
      RAISE EXCEPTION 'Only one profile per user can have AnkiWeb sync enabled';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: add_ons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.add_ons (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    version character varying(20) NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    config_json jsonb DEFAULT '{}'::jsonb,
    installed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: TABLE add_ons; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.add_ons IS 'User installed add-ons table';


--
-- Name: COLUMN add_ons.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.add_ons.code IS 'Unique add-on code';


--
-- Name: COLUMN add_ons.config_json; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.add_ons.config_json IS 'Add-on configurations';


--
-- Name: add_ons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.add_ons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: add_ons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.add_ons_id_seq OWNED BY public.add_ons.id;


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
-- Name: backups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.backups (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    filename character varying(255) NOT NULL,
    size bigint NOT NULL,
    storage_path character varying(512) NOT NULL,
    backup_type character varying(20) DEFAULT 'automatic'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT check_backup_type CHECK (((backup_type)::text = ANY ((ARRAY['automatic'::character varying, 'manual'::character varying, 'pre_operation'::character varying])::text[]))),
    CONSTRAINT check_size_positive CHECK ((size > 0))
);


--
-- Name: TABLE backups; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.backups IS 'User backups table';


--
-- Name: COLUMN backups.backup_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.backups.backup_type IS 'Type: automatic, manual, pre_operation';


--
-- Name: backups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.backups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: backups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.backups_id_seq OWNED BY public.backups.id;


--
-- Name: browser_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.browser_config (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    visible_columns text[] DEFAULT ARRAY['note'::text, 'deck'::text, 'tags'::text, 'due'::text, 'interval'::text, 'ease'::text] NOT NULL,
    column_widths jsonb DEFAULT '{}'::jsonb NOT NULL,
    sort_column character varying(100),
    sort_direction character varying(10) DEFAULT 'asc'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: TABLE browser_config; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.browser_config IS 'Browser configuration (visible columns, sorting)';


--
-- Name: COLUMN browser_config.visible_columns; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.browser_config.visible_columns IS 'Array of visible column names';


--
-- Name: COLUMN browser_config.column_widths; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.browser_config.column_widths IS 'Column widths: {"note": 200, "deck": 150}';


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
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    stability real,
    difficulty real,
    last_review_at timestamp with time zone,
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
-- Name: TABLE cards; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.cards IS 'Cards table';


--
-- Name: COLUMN cards.card_type_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cards.card_type_id IS 'Card type ID (ordinal of card type in note type)';


--
-- Name: COLUMN cards.home_deck_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cards.home_deck_id IS 'Original deck (home deck) when card is in filtered deck';


--
-- Name: COLUMN cards.due; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cards.due IS 'Timestamp (milliseconds) or queue position (for new cards)';


--
-- Name: COLUMN cards."interval"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cards."interval" IS 'Interval in days (or negative seconds for learning)';


--
-- Name: COLUMN cards.ease; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cards.ease IS 'Ease factor in permille (2500 = 2.5x)';


--
-- Name: COLUMN cards."position"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cards."position" IS 'Position in new cards queue';


--
-- Name: COLUMN cards.flag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cards.flag IS 'Colored flag (0-7, 0 = no flag)';


--
-- Name: COLUMN cards.stability; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cards.stability IS 'FSRS stability (in days)';


--
-- Name: COLUMN cards.difficulty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cards.difficulty IS 'FSRS difficulty (0.0-1.0)';


--
-- Name: decks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.decks (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    parent_id bigint,
    options_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: TABLE decks; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.decks IS 'Decks (card decks) table';


--
-- Name: COLUMN decks.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.decks.name IS 'Deck name (can contain :: for hierarchy)';


--
-- Name: COLUMN decks.parent_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.decks.parent_id IS 'Parent deck ID (NULL for root decks)';


--
-- Name: COLUMN decks.options_json; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.decks.options_json IS 'Deck options in JSON (preset, limits, etc.)';


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notes (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    guid character varying(36) NOT NULL,
    note_type_id bigint NOT NULL,
    fields_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    tags text[] DEFAULT '{}'::text[] NOT NULL,
    marked boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT check_guid_format CHECK (((guid)::text ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'::text))
);


--
-- Name: TABLE notes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.notes IS 'Notes table';


--
-- Name: COLUMN notes.guid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.notes.guid IS 'Unique global GUID for synchronization';


--
-- Name: COLUMN notes.fields_json; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.notes.fields_json IS 'Note fields: {"Front": "...", "Back": "..."}';


--
-- Name: COLUMN notes.tags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.notes.tags IS 'Array of note tags';


--
-- Name: COLUMN notes.marked; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.notes.marked IS 'Indicates if note is marked (tag "marked")';


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
    type public.review_type NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT check_interval_valid CHECK (("interval" <> 0)),
    CONSTRAINT check_rating_range CHECK (((rating >= 1) AND (rating <= 4))),
    CONSTRAINT check_time_ms_positive CHECK ((time_ms > 0))
);


--
-- Name: TABLE reviews; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.reviews IS 'Review history (revlog) table';


--
-- Name: COLUMN reviews.rating; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reviews.rating IS 'Rating: 1=Again, 2=Hard, 3=Good, 4=Easy';


--
-- Name: COLUMN reviews."interval"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reviews."interval" IS 'New interval after review (days or negative seconds)';


--
-- Name: COLUMN reviews.ease; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reviews.ease IS 'New ease factor after review (permille)';


--
-- Name: COLUMN reviews.time_ms; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reviews.time_ms IS 'Time spent on review (milliseconds)';


--
-- Name: COLUMN reviews.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reviews.type IS 'Review type: learn, review, relearn, cram';


--
-- Name: card_info_extended; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.card_info_extended AS
 SELECT c.id,
    c.note_id,
    c.deck_id,
    c.state,
    c.due,
    c."interval",
    c.ease,
    c.lapses,
    c.reps,
    c.flag,
    c.suspended,
    c.buried,
    n.guid,
    n.note_type_id,
    n.tags,
    n.marked,
    d.name AS deck_name,
    count(r.id) AS total_reviews,
    max(r.created_at) AS last_review_at
   FROM (((public.cards c
     JOIN public.notes n ON ((n.id = c.note_id)))
     JOIN public.decks d ON ((d.id = c.deck_id)))
     LEFT JOIN public.reviews r ON ((r.card_id = c.id)))
  WHERE ((n.deleted_at IS NULL) AND (d.deleted_at IS NULL))
  GROUP BY c.id, c.note_id, c.deck_id, c.state, c.due, c."interval", c.ease, c.lapses, c.reps, c.flag, c.suspended, c.buried, n.guid, n.note_type_id, n.tags, n.marked, d.name;


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
-- Name: check_database_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.check_database_log (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    status character varying(20) DEFAULT 'completed'::character varying NOT NULL,
    issues_found integer DEFAULT 0 NOT NULL,
    issues_details jsonb,
    execution_time_ms integer,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT check_issues_non_negative CHECK ((issues_found >= 0)),
    CONSTRAINT check_status CHECK (((status)::text = ANY ((ARRAY['running'::character varying, 'completed'::character varying, 'failed'::character varying, 'corrupted'::character varying])::text[])))
);


--
-- Name: TABLE check_database_log; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.check_database_log IS 'Database integrity check log';


--
-- Name: COLUMN check_database_log.issues_details; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.check_database_log.issues_details IS 'Details of found issues';


--
-- Name: check_database_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.check_database_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: check_database_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.check_database_log_id_seq OWNED BY public.check_database_log.id;


--
-- Name: deck_options_presets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deck_options_presets (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    options_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: TABLE deck_options_presets; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.deck_options_presets IS 'Deck options presets table';


--
-- Name: COLUMN deck_options_presets.options_json; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.deck_options_presets.options_json IS 'Preset options in JSON';


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
-- Name: deck_statistics; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.deck_statistics AS
 SELECT d.id AS deck_id,
    d.user_id,
    d.name AS deck_name,
    count(DISTINCT c.id) FILTER (WHERE ((c.state = 'new'::public.card_state) AND (c.suspended = false) AND (c.buried = false))) AS new_count,
    count(DISTINCT c.id) FILTER (WHERE ((c.state = ANY (ARRAY['learn'::public.card_state, 'relearn'::public.card_state])) AND (c.suspended = false) AND (c.buried = false))) AS learning_count,
    count(DISTINCT c.id) FILTER (WHERE ((c.state = 'review'::public.card_state) AND (c.suspended = false) AND (c.buried = false))) AS review_count,
    count(DISTINCT c.id) FILTER (WHERE (c.suspended = true)) AS suspended_count,
    count(DISTINCT n.id) AS notes_count
   FROM ((public.decks d
     LEFT JOIN public.cards c ON ((c.deck_id = d.id)))
     LEFT JOIN public.notes n ON ((n.id = c.note_id)))
  WHERE (d.deleted_at IS NULL)
  GROUP BY d.id, d.user_id, d.name;


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
    deleted_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT check_object_type CHECK (((object_type)::text = ANY ((ARRAY['note'::character varying, 'card'::character varying, 'deck'::character varying, 'note_type'::character varying])::text[])))
);


--
-- Name: TABLE deletions_log; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.deletions_log IS 'Deletion log for possible recovery';


--
-- Name: COLUMN deletions_log.object_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.deletions_log.object_data IS 'Deleted object data (for recovery)';


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
-- Name: note_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.note_types (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    fields_json jsonb DEFAULT '[]'::jsonb NOT NULL,
    card_types_json jsonb DEFAULT '[]'::jsonb NOT NULL,
    templates_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: TABLE note_types; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.note_types IS 'Note types table';


--
-- Name: COLUMN note_types.fields_json; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.note_types.fields_json IS 'Array of fields: [{"name": "Front", "ord": 0}, ...]';


--
-- Name: COLUMN note_types.card_types_json; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.note_types.card_types_json IS 'Array of card types: [{"name": "Forward", "ord": 0}, ...]';


--
-- Name: COLUMN note_types.templates_json; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.note_types.templates_json IS 'Templates: {"Front": "...", "Back": "...", "Styling": "..."}';


--
-- Name: empty_cards; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.empty_cards AS
 SELECT c.id AS card_id,
    c.note_id,
    c.deck_id,
    n.user_id,
    n.note_type_id,
    d.name AS deck_name
   FROM (((public.cards c
     JOIN public.notes n ON ((n.id = c.note_id)))
     JOIN public.decks d ON ((d.id = c.deck_id)))
     JOIN public.note_types nt ON ((nt.id = n.note_type_id)))
  WHERE ((n.deleted_at IS NULL) AND (c.suspended = false) AND (((c.state = 'new'::public.card_state) AND (c."position" = 0)) OR ((jsonb_typeof(n.fields_json) = 'object'::text) AND (n.fields_json = '{}'::jsonb))));


--
-- Name: filtered_decks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.filtered_decks (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    search_filter text NOT NULL,
    second_filter text,
    limit_cards integer DEFAULT 20 NOT NULL,
    order_by character varying(50) DEFAULT 'due'::character varying NOT NULL,
    reschedule boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_rebuild_at timestamp with time zone,
    deleted_at timestamp with time zone,
    CONSTRAINT check_limit_positive CHECK ((limit_cards > 0))
);


--
-- Name: TABLE filtered_decks; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.filtered_decks IS 'Filtered decks (custom study) table';


--
-- Name: COLUMN filtered_decks.search_filter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.filtered_decks.search_filter IS 'Main search filter';


--
-- Name: COLUMN filtered_decks.second_filter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.filtered_decks.second_filter IS 'Optional second filter';


--
-- Name: COLUMN filtered_decks.order_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.filtered_decks.order_by IS 'Order: due, random, intervals, lapses, etc.';


--
-- Name: filtered_decks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.filtered_decks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: filtered_decks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.filtered_decks_id_seq OWNED BY public.filtered_decks.id;


--
-- Name: flag_names; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flag_names (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    flag_number smallint NOT NULL,
    name character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT check_flag_number CHECK (((flag_number >= 1) AND (flag_number <= 7)))
);


--
-- Name: TABLE flag_names; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.flag_names IS 'Custom flag names table';


--
-- Name: COLUMN flag_names.flag_number; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.flag_names.flag_number IS 'Flag number (1-7)';


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
    jti character varying(255) NOT NULL,
    exp timestamp with time zone NOT NULL
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
-- Name: leeches; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.leeches AS
 SELECT c.id AS card_id,
    c.note_id,
    c.deck_id,
    n.user_id,
    c.lapses,
    d.name AS deck_name,
    nt.name AS note_type_name,
    n.tags
   FROM (((public.cards c
     JOIN public.notes n ON ((n.id = c.note_id)))
     JOIN public.decks d ON ((d.id = c.deck_id)))
     JOIN public.note_types nt ON ((nt.id = n.note_type_id)))
  WHERE ((n.deleted_at IS NULL) AND (c.suspended = false) AND ('leech'::text = ANY (n.tags)) AND (c.lapses >= ( SELECT ((decks.options_json ->> 'leech_threshold'::text))::integer AS int4
           FROM public.decks
          WHERE (decks.id = c.deck_id))));


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
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT check_size_positive CHECK ((size > 0))
);


--
-- Name: TABLE media; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.media IS 'Media files table (images, audio, video)';


--
-- Name: COLUMN media.hash; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.media.hash IS 'SHA-256 hash of file (for deduplication)';


--
-- Name: COLUMN media.storage_path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.media.storage_path IS 'File path in storage';


--
-- Name: COLUMN media.deleted_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.media.deleted_at IS 'Soft delete - NULL if active';


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
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: TABLE note_media; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.note_media IS 'Junction table between notes and media';


--
-- Name: COLUMN note_media.field_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.note_media.field_name IS 'Field name where media is used (NULL if in template)';


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
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profiles (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    ankiweb_sync_enabled boolean DEFAULT false NOT NULL,
    ankiweb_username character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: TABLE profiles; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.profiles IS 'User profiles table - allows multiple isolated collections per user';


--
-- Name: COLUMN profiles.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.profiles.name IS 'Profile name (unique per user)';


--
-- Name: COLUMN profiles.ankiweb_sync_enabled; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.profiles.ankiweb_sync_enabled IS 'Whether this profile is synced with AnkiWeb';


--
-- Name: COLUMN profiles.ankiweb_username; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.profiles.ankiweb_username IS 'AnkiWeb username for sync (nullable)';


--
-- Name: COLUMN profiles.deleted_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.profiles.deleted_at IS 'Soft delete - NULL if active';


--
-- Name: profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.profiles_id_seq OWNED BY public.profiles.id;


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
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: TABLE saved_searches; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.saved_searches IS 'User saved searches table';


--
-- Name: COLUMN saved_searches.search_query; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.saved_searches.search_query IS 'Search query in Anki syntax';


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
-- Name: shared_deck_ratings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shared_deck_ratings (
    id bigint NOT NULL,
    shared_deck_id bigint NOT NULL,
    user_id bigint NOT NULL,
    rating smallint NOT NULL,
    comment text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT check_rating_range CHECK (((rating >= 1) AND (rating <= 5)))
);


--
-- Name: TABLE shared_deck_ratings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.shared_deck_ratings IS 'Shared deck ratings';


--
-- Name: shared_deck_ratings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shared_deck_ratings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shared_deck_ratings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shared_deck_ratings_id_seq OWNED BY public.shared_deck_ratings.id;


--
-- Name: shared_decks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shared_decks (
    id bigint NOT NULL,
    author_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    category character varying(100),
    package_path character varying(512) NOT NULL,
    package_size bigint NOT NULL,
    download_count integer DEFAULT 0 NOT NULL,
    rating_average real DEFAULT 0.0,
    rating_count integer DEFAULT 0 NOT NULL,
    tags text[] DEFAULT '{}'::text[] NOT NULL,
    is_featured boolean DEFAULT false NOT NULL,
    is_public boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT check_package_size_positive CHECK ((package_size > 0)),
    CONSTRAINT check_rating_average CHECK (((rating_average >= (0)::double precision) AND (rating_average <= (5)::double precision)))
);


--
-- Name: TABLE shared_decks; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.shared_decks IS 'Publicly shared decks table';


--
-- Name: COLUMN shared_decks.package_path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.shared_decks.package_path IS 'Path to .apkg file in storage';


--
-- Name: COLUMN shared_decks.rating_average; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.shared_decks.rating_average IS 'Average rating (0-5)';


--
-- Name: shared_decks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shared_decks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shared_decks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shared_decks_id_seq OWNED BY public.shared_decks.id;


--
-- Name: sync_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sync_meta (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    client_id character varying(255) NOT NULL,
    last_sync timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_sync_usn bigint DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: TABLE sync_meta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.sync_meta IS 'Synchronization metadata table';


--
-- Name: COLUMN sync_meta.client_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sync_meta.client_id IS 'Unique client/device identifier';


--
-- Name: COLUMN sync_meta.last_sync_usn; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sync_meta.last_sync_usn IS 'Last synchronized update sequence number';


--
-- Name: sync_meta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sync_meta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sync_meta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sync_meta_id_seq OWNED BY public.sync_meta.id;


--
-- Name: undo_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.undo_history (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    operation_type character varying(50) NOT NULL,
    operation_data jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT check_operation_type CHECK (((operation_type)::text = ANY ((ARRAY['edit_note'::character varying, 'delete_note'::character varying, 'move_card'::character varying, 'change_flag'::character varying, 'add_tag'::character varying, 'remove_tag'::character varying, 'change_deck'::character varying])::text[])))
);


--
-- Name: TABLE undo_history; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.undo_history IS 'Operation history for undo/redo';


--
-- Name: COLUMN undo_history.operation_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.undo_history.operation_data IS 'Operation data for reversal';


--
-- Name: undo_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.undo_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: undo_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.undo_history_id_seq OWNED BY public.undo_history.id;


--
-- Name: user_preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_preferences (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    language character varying(10) DEFAULT 'pt-BR'::character varying NOT NULL,
    theme public.theme_type DEFAULT 'auto'::public.theme_type NOT NULL,
    auto_sync boolean DEFAULT true NOT NULL,
    next_day_starts_at time without time zone DEFAULT '04:00:00'::time without time zone NOT NULL,
    learn_ahead_limit integer DEFAULT 20 NOT NULL,
    timebox_time_limit integer DEFAULT 0 NOT NULL,
    video_driver character varying(50) DEFAULT 'auto'::character varying NOT NULL,
    ui_size real DEFAULT 1.0 NOT NULL,
    minimalist_mode boolean DEFAULT false NOT NULL,
    reduce_motion boolean DEFAULT false NOT NULL,
    paste_strips_formatting boolean DEFAULT false NOT NULL,
    paste_images_as_png boolean DEFAULT false NOT NULL,
    default_deck_behavior character varying(50) DEFAULT 'current_deck'::character varying NOT NULL,
    show_play_buttons boolean DEFAULT true NOT NULL,
    interrupt_audio_on_answer boolean DEFAULT true NOT NULL,
    show_remaining_count boolean DEFAULT true NOT NULL,
    show_next_review_time boolean DEFAULT false NOT NULL,
    spacebar_answers_card boolean DEFAULT true NOT NULL,
    ignore_accents_in_search boolean DEFAULT false NOT NULL,
    default_search_text character varying(255),
    sync_audio_and_images boolean DEFAULT true NOT NULL,
    periodically_sync_media boolean DEFAULT false NOT NULL,
    force_one_way_sync boolean DEFAULT false NOT NULL,
    self_hosted_sync_server_url character varying(512),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT check_learn_ahead_limit CHECK ((learn_ahead_limit >= 0)),
    CONSTRAINT check_timebox_limit CHECK ((timebox_time_limit >= 0)),
    CONSTRAINT check_ui_size CHECK (((ui_size > (0)::double precision) AND (ui_size <= (3.0)::double precision)))
);


--
-- Name: TABLE user_preferences; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.user_preferences IS 'Global user preferences table';


--
-- Name: COLUMN user_preferences.learn_ahead_limit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_preferences.learn_ahead_limit IS 'Limit in minutes to show learning cards before due';


--
-- Name: COLUMN user_preferences.timebox_time_limit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_preferences.timebox_time_limit IS 'Time limit in minutes for timeboxing (0 = disabled)';


--
-- Name: COLUMN user_preferences.ui_size; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_preferences.ui_size IS 'UI size multiplier (1.0 = default)';


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
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_login_at timestamp with time zone,
    deleted_at timestamp with time zone,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp with time zone,
    remember_created_at timestamp with time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    confirmation_token character varying(255),
    confirmed_at timestamp with time zone,
    confirmation_sent_at timestamp with time zone,
    unconfirmed_email character varying(255),
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying(255),
    locked_at timestamp with time zone
);


--
-- Name: TABLE users; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.users IS 'Users table';


--
-- Name: COLUMN users.email; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.email IS 'Unique user email';


--
-- Name: COLUMN users.encrypted_password; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.encrypted_password IS 'Password hash (bcrypt)';


--
-- Name: COLUMN users.deleted_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.deleted_at IS 'Soft delete - NULL if active';


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
-- Name: add_ons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.add_ons ALTER COLUMN id SET DEFAULT nextval('public.add_ons_id_seq'::regclass);


--
-- Name: backups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.backups ALTER COLUMN id SET DEFAULT nextval('public.backups_id_seq'::regclass);


--
-- Name: browser_config id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.browser_config ALTER COLUMN id SET DEFAULT nextval('public.browser_config_id_seq'::regclass);


--
-- Name: cards id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards ALTER COLUMN id SET DEFAULT nextval('public.cards_id_seq'::regclass);


--
-- Name: check_database_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.check_database_log ALTER COLUMN id SET DEFAULT nextval('public.check_database_log_id_seq'::regclass);


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
-- Name: filtered_decks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filtered_decks ALTER COLUMN id SET DEFAULT nextval('public.filtered_decks_id_seq'::regclass);


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
-- Name: profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles ALTER COLUMN id SET DEFAULT nextval('public.profiles_id_seq'::regclass);


--
-- Name: reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews ALTER COLUMN id SET DEFAULT nextval('public.reviews_id_seq'::regclass);


--
-- Name: saved_searches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_searches ALTER COLUMN id SET DEFAULT nextval('public.saved_searches_id_seq'::regclass);


--
-- Name: shared_deck_ratings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shared_deck_ratings ALTER COLUMN id SET DEFAULT nextval('public.shared_deck_ratings_id_seq'::regclass);


--
-- Name: shared_decks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shared_decks ALTER COLUMN id SET DEFAULT nextval('public.shared_decks_id_seq'::regclass);


--
-- Name: sync_meta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sync_meta ALTER COLUMN id SET DEFAULT nextval('public.sync_meta_id_seq'::regclass);


--
-- Name: undo_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.undo_history ALTER COLUMN id SET DEFAULT nextval('public.undo_history_id_seq'::regclass);


--
-- Name: user_preferences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_preferences ALTER COLUMN id SET DEFAULT nextval('public.user_preferences_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: add_ons add_ons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.add_ons
    ADD CONSTRAINT add_ons_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: backups backups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.backups
    ADD CONSTRAINT backups_pkey PRIMARY KEY (id);


--
-- Name: browser_config browser_config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.browser_config
    ADD CONSTRAINT browser_config_pkey PRIMARY KEY (id);


--
-- Name: browser_config browser_config_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.browser_config
    ADD CONSTRAINT browser_config_user_id_key UNIQUE (user_id);


--
-- Name: cards cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (id);


--
-- Name: check_database_log check_database_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.check_database_log
    ADD CONSTRAINT check_database_log_pkey PRIMARY KEY (id);


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
-- Name: filtered_decks filtered_decks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filtered_decks
    ADD CONSTRAINT filtered_decks_pkey PRIMARY KEY (id);


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
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


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
-- Name: shared_deck_ratings shared_deck_ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shared_deck_ratings
    ADD CONSTRAINT shared_deck_ratings_pkey PRIMARY KEY (id);


--
-- Name: shared_decks shared_decks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shared_decks
    ADD CONSTRAINT shared_decks_pkey PRIMARY KEY (id);


--
-- Name: sync_meta sync_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sync_meta
    ADD CONSTRAINT sync_meta_pkey PRIMARY KEY (id);


--
-- Name: undo_history undo_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.undo_history
    ADD CONSTRAINT undo_history_pkey PRIMARY KEY (id);


--
-- Name: add_ons unique_addon_code_per_user; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.add_ons
    ADD CONSTRAINT unique_addon_code_per_user UNIQUE (user_id, code);


--
-- Name: flag_names unique_flag_per_user; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flag_names
    ADD CONSTRAINT unique_flag_per_user UNIQUE (user_id, flag_number);


--
-- Name: media unique_media_hash_per_user; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media
    ADD CONSTRAINT unique_media_hash_per_user UNIQUE (user_id, hash, deleted_at);


--
-- Name: note_media unique_note_media_field; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_media
    ADD CONSTRAINT unique_note_media_field UNIQUE (note_id, media_id, field_name);


--
-- Name: note_types unique_note_type_name_per_user; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_types
    ADD CONSTRAINT unique_note_type_name_per_user UNIQUE (user_id, name, deleted_at);


--
-- Name: deck_options_presets unique_preset_name_per_user; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deck_options_presets
    ADD CONSTRAINT unique_preset_name_per_user UNIQUE (user_id, name, deleted_at);


--
-- Name: profiles unique_profile_name_per_user; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT unique_profile_name_per_user UNIQUE (user_id, name, deleted_at);


--
-- Name: saved_searches unique_saved_search_name_per_user; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_searches
    ADD CONSTRAINT unique_saved_search_name_per_user UNIQUE (user_id, name, deleted_at);


--
-- Name: sync_meta unique_user_client; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sync_meta
    ADD CONSTRAINT unique_user_client UNIQUE (user_id, client_id);


--
-- Name: shared_deck_ratings unique_user_deck_rating; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shared_deck_ratings
    ADD CONSTRAINT unique_user_deck_rating UNIQUE (shared_deck_id, user_id);


--
-- Name: user_preferences user_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_preferences
    ADD CONSTRAINT user_preferences_pkey PRIMARY KEY (id);


--
-- Name: user_preferences user_preferences_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_preferences
    ADD CONSTRAINT user_preferences_user_id_key UNIQUE (user_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_add_ons_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_add_ons_code ON public.add_ons USING btree (code);


--
-- Name: idx_add_ons_enabled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_add_ons_enabled ON public.add_ons USING btree (user_id, enabled) WHERE (enabled = true);


--
-- Name: idx_add_ons_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_add_ons_user_id ON public.add_ons USING btree (user_id);


--
-- Name: idx_backups_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_backups_created_at ON public.backups USING btree (created_at);


--
-- Name: idx_backups_user_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_backups_user_created ON public.backups USING btree (user_id, created_at);


--
-- Name: idx_backups_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_backups_user_id ON public.backups USING btree (user_id);


--
-- Name: idx_browser_config_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_browser_config_user_id ON public.browser_config USING btree (user_id);


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
-- Name: idx_check_database_log_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_check_database_log_status ON public.check_database_log USING btree (status);


--
-- Name: idx_check_database_log_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_check_database_log_user_id ON public.check_database_log USING btree (user_id, created_at DESC);


--
-- Name: idx_deck_options_presets_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_deck_options_presets_user_id ON public.deck_options_presets USING btree (user_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_decks_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_decks_active ON public.decks USING btree (user_id, parent_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_decks_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_decks_name ON public.decks USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: idx_decks_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_decks_parent_id ON public.decks USING btree (parent_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_decks_sync; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_decks_sync ON public.decks USING btree (user_id, updated_at) WHERE (deleted_at IS NULL);


--
-- Name: idx_decks_unique_name_child; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_decks_unique_name_child ON public.decks USING btree (user_id, name, parent_id) WHERE ((parent_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: idx_decks_unique_name_root; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_decks_unique_name_root ON public.decks USING btree (user_id, name) WHERE ((parent_id IS NULL) AND (deleted_at IS NULL));


--
-- Name: idx_decks_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_decks_user_id ON public.decks USING btree (user_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_decks_user_parent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_decks_user_parent ON public.decks USING btree (user_id, parent_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_deletions_log_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_deletions_log_deleted_at ON public.deletions_log USING btree (deleted_at);


--
-- Name: idx_deletions_log_object; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_deletions_log_object ON public.deletions_log USING btree (object_type, object_id);


--
-- Name: idx_deletions_log_user_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_deletions_log_user_deleted_at ON public.deletions_log USING btree (user_id, deleted_at DESC);


--
-- Name: idx_deletions_log_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_deletions_log_user_id ON public.deletions_log USING btree (user_id);


--
-- Name: idx_filtered_decks_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_filtered_decks_name ON public.filtered_decks USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: idx_filtered_decks_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_filtered_decks_user_id ON public.filtered_decks USING btree (user_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_flag_names_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_flag_names_user_id ON public.flag_names USING btree (user_id);


--
-- Name: idx_media_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_media_active ON public.media USING btree (user_id, mime_type) WHERE (deleted_at IS NULL);


--
-- Name: idx_media_filename; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_media_filename ON public.media USING btree (filename) WHERE (deleted_at IS NULL);


--
-- Name: idx_media_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_media_hash ON public.media USING btree (hash) WHERE (deleted_at IS NULL);


--
-- Name: idx_media_mime_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_media_mime_type ON public.media USING btree (mime_type) WHERE (deleted_at IS NULL);


--
-- Name: idx_media_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_media_user_id ON public.media USING btree (user_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_note_media_media_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_note_media_media_id ON public.note_media USING btree (media_id);


--
-- Name: idx_note_media_note_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_note_media_note_id ON public.note_media USING btree (note_id);


--
-- Name: idx_note_types_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_note_types_name ON public.note_types USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: idx_note_types_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_note_types_user_id ON public.note_types USING btree (user_id) WHERE (deleted_at IS NULL);


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
-- Name: idx_profiles_ankiweb_sync; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_profiles_ankiweb_sync ON public.profiles USING btree (user_id, ankiweb_sync_enabled) WHERE ((ankiweb_sync_enabled = true) AND (deleted_at IS NULL));


--
-- Name: idx_profiles_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_profiles_name ON public.profiles USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: idx_profiles_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_profiles_user_id ON public.profiles USING btree (user_id) WHERE (deleted_at IS NULL);


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
-- Name: idx_reviews_rating; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reviews_rating ON public.reviews USING btree (rating);


--
-- Name: idx_reviews_stats; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reviews_stats ON public.reviews USING btree (card_id, type, rating, created_at);


--
-- Name: idx_reviews_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reviews_type ON public.reviews USING btree (type);


--
-- Name: idx_saved_searches_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_saved_searches_user_id ON public.saved_searches USING btree (user_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_shared_deck_ratings_deck_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_shared_deck_ratings_deck_id ON public.shared_deck_ratings USING btree (shared_deck_id);


--
-- Name: idx_shared_deck_ratings_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_shared_deck_ratings_user_id ON public.shared_deck_ratings USING btree (user_id);


--
-- Name: idx_shared_decks_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_shared_decks_author_id ON public.shared_decks USING btree (author_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_shared_decks_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_shared_decks_category ON public.shared_decks USING btree (category) WHERE ((deleted_at IS NULL) AND (is_public = true));


--
-- Name: idx_shared_decks_downloads; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_shared_decks_downloads ON public.shared_decks USING btree (download_count DESC) WHERE ((deleted_at IS NULL) AND (is_public = true));


--
-- Name: idx_shared_decks_featured; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_shared_decks_featured ON public.shared_decks USING btree (is_featured) WHERE ((deleted_at IS NULL) AND (is_public = true));


--
-- Name: idx_shared_decks_name_fts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_shared_decks_name_fts ON public.shared_decks USING gin (to_tsvector('portuguese'::regconfig, (((name)::text || ' '::text) || COALESCE(description, ''::text)))) WHERE ((deleted_at IS NULL) AND (is_public = true));


--
-- Name: idx_shared_decks_tags; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_shared_decks_tags ON public.shared_decks USING gin (tags) WHERE ((deleted_at IS NULL) AND (is_public = true));


--
-- Name: idx_sync_meta_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sync_meta_client_id ON public.sync_meta USING btree (client_id);


--
-- Name: idx_sync_meta_last_sync; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sync_meta_last_sync ON public.sync_meta USING btree (last_sync);


--
-- Name: idx_sync_meta_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sync_meta_user_id ON public.sync_meta USING btree (user_id);


--
-- Name: idx_undo_history_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_undo_history_created_at ON public.undo_history USING btree (created_at DESC);


--
-- Name: idx_undo_history_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_undo_history_user_id ON public.undo_history USING btree (user_id, created_at DESC);


--
-- Name: idx_user_preferences_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_preferences_user_id ON public.user_preferences USING btree (user_id);


--
-- Name: idx_users_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_created_at ON public.users USING btree (created_at);


--
-- Name: idx_users_email_active; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_users_email_active ON public.users USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: index_jwt_denylist_on_exp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jwt_denylist_on_exp ON public.jwt_denylist USING btree (exp);


--
-- Name: index_jwt_denylist_on_jti; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_jwt_denylist_on_jti ON public.jwt_denylist USING btree (jti);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


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
-- Name: notes log_notes_deletion; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER log_notes_deletion BEFORE UPDATE ON public.notes FOR EACH ROW EXECUTE FUNCTION public.log_note_deletion();


--
-- Name: notes set_notes_guid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_notes_guid BEFORE INSERT ON public.notes FOR EACH ROW EXECUTE FUNCTION public.set_note_guid();


--
-- Name: add_ons update_add_ons_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_add_ons_updated_at BEFORE UPDATE ON public.add_ons FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: browser_config update_browser_config_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_browser_config_updated_at BEFORE UPDATE ON public.browser_config FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: cards update_cards_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_cards_updated_at BEFORE UPDATE ON public.cards FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: deck_options_presets update_deck_options_presets_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_deck_options_presets_updated_at BEFORE UPDATE ON public.deck_options_presets FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: decks update_decks_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_decks_updated_at BEFORE UPDATE ON public.decks FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: filtered_decks update_filtered_decks_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_filtered_decks_updated_at BEFORE UPDATE ON public.filtered_decks FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: flag_names update_flag_names_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_flag_names_updated_at BEFORE UPDATE ON public.flag_names FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: note_types update_note_types_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_note_types_updated_at BEFORE UPDATE ON public.note_types FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: notes update_notes_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_notes_updated_at BEFORE UPDATE ON public.notes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: profiles update_profiles_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: saved_searches update_saved_searches_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_saved_searches_updated_at BEFORE UPDATE ON public.saved_searches FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: shared_deck_ratings update_shared_deck_ratings_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_shared_deck_ratings_updated_at BEFORE UPDATE ON public.shared_deck_ratings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: shared_decks update_shared_decks_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_shared_decks_updated_at BEFORE UPDATE ON public.shared_decks FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: sync_meta update_sync_meta_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_sync_meta_updated_at BEFORE UPDATE ON public.sync_meta FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: user_preferences update_user_preferences_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON public.user_preferences FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: profiles validate_single_ankiweb_sync_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER validate_single_ankiweb_sync_trigger BEFORE INSERT OR UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.validate_single_ankiweb_sync();


--
-- Name: add_ons add_ons_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.add_ons
    ADD CONSTRAINT add_ons_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: backups backups_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.backups
    ADD CONSTRAINT backups_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: browser_config browser_config_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.browser_config
    ADD CONSTRAINT browser_config_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: cards cards_deck_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_deck_id_fkey FOREIGN KEY (deck_id) REFERENCES public.decks(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT cards_deck_id_fkey ON cards; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT cards_deck_id_fkey ON public.cards IS 'Restrict delete: does not allow deleting deck with cards';


--
-- Name: cards cards_home_deck_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_home_deck_id_fkey FOREIGN KEY (home_deck_id) REFERENCES public.decks(id) ON DELETE SET NULL;


--
-- Name: cards cards_note_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_note_id_fkey FOREIGN KEY (note_id) REFERENCES public.notes(id) ON DELETE CASCADE;


--
-- Name: CONSTRAINT cards_note_id_fkey ON cards; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT cards_note_id_fkey ON public.cards IS 'Cascade delete: deleting note deletes all related cards';


--
-- Name: check_database_log check_database_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.check_database_log
    ADD CONSTRAINT check_database_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: deck_options_presets deck_options_presets_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deck_options_presets
    ADD CONSTRAINT deck_options_presets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: decks decks_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decks
    ADD CONSTRAINT decks_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.decks(id) ON DELETE SET NULL;


--
-- Name: decks decks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decks
    ADD CONSTRAINT decks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: deletions_log deletions_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deletions_log
    ADD CONSTRAINT deletions_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: filtered_decks filtered_decks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filtered_decks
    ADD CONSTRAINT filtered_decks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: flag_names flag_names_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flag_names
    ADD CONSTRAINT flag_names_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: media media_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media
    ADD CONSTRAINT media_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: note_media note_media_media_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_media
    ADD CONSTRAINT note_media_media_id_fkey FOREIGN KEY (media_id) REFERENCES public.media(id) ON DELETE CASCADE;


--
-- Name: note_media note_media_note_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_media
    ADD CONSTRAINT note_media_note_id_fkey FOREIGN KEY (note_id) REFERENCES public.notes(id) ON DELETE CASCADE;


--
-- Name: note_types note_types_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_types
    ADD CONSTRAINT note_types_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: notes notes_note_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_note_type_id_fkey FOREIGN KEY (note_type_id) REFERENCES public.note_types(id) ON DELETE RESTRICT;


--
-- Name: CONSTRAINT notes_note_type_id_fkey ON notes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT notes_note_type_id_fkey ON public.notes IS 'Restrict delete: does not allow deleting note type with notes';


--
-- Name: notes notes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: profiles profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.cards(id) ON DELETE CASCADE;


--
-- Name: saved_searches saved_searches_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saved_searches
    ADD CONSTRAINT saved_searches_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: shared_deck_ratings shared_deck_ratings_shared_deck_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shared_deck_ratings
    ADD CONSTRAINT shared_deck_ratings_shared_deck_id_fkey FOREIGN KEY (shared_deck_id) REFERENCES public.shared_decks(id) ON DELETE CASCADE;


--
-- Name: shared_deck_ratings shared_deck_ratings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shared_deck_ratings
    ADD CONSTRAINT shared_deck_ratings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: shared_decks shared_decks_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shared_decks
    ADD CONSTRAINT shared_decks_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: sync_meta sync_meta_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sync_meta
    ADD CONSTRAINT sync_meta_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: undo_history undo_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.undo_history
    ADD CONSTRAINT undo_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_preferences user_preferences_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_preferences
    ADD CONSTRAINT user_preferences_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20260205000001');

