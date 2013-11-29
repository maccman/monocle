--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

--
-- Name: c_posts_user_handle(); Type: FUNCTION; Schema: public; Owner: Alex
--

CREATE FUNCTION c_posts_user_handle() RETURNS trigger
    LANGUAGE plpgsql
    AS $$      BEGIN
        IF OLD.handle != NEW.handle THEN
          UPDATE "posts" SET "user_handle" = NEW.handle WHERE "user_id" = NEW.id;
        END IF;
        RETURN NEW;
      END;
$$;


ALTER FUNCTION public.c_posts_user_handle() OWNER TO "Alex";

--
-- Name: c_posts_voted(); Type: FUNCTION; Schema: public; Owner: Alex
--

CREATE FUNCTION c_posts_voted() RETURNS trigger
    LANGUAGE plpgsql
    AS $$      BEGIN
        UPDATE "posts" SET voted_user_ids = array_append(voted_user_ids, NEW.user_id) WHERE "id" = NEW.post_id;
        RETURN NEW;
      END;
$$;


ALTER FUNCTION public.c_posts_voted() OWNER TO "Alex";

--
-- Name: cc_posts_comments_count(); Type: FUNCTION; Schema: public; Owner: Alex
--

CREATE FUNCTION cc_posts_comments_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$        BEGIN
          IF (TG_OP = 'DELETE') THEN
            UPDATE "posts" SET "comments_count" = "comments_count" - 1 WHERE "id" = OLD.post_id;
            RETURN OLD;
          ELSIF (TG_OP = 'INSERT') THEN
            UPDATE "posts" SET "comments_count" = "comments_count" + 1 WHERE "id" = NEW."post_id";
            RETURN NEW;
          END IF;
        END;
$$;


ALTER FUNCTION public.cc_posts_comments_count() OWNER TO "Alex";

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: comment_votes; Type: TABLE; Schema: public; Owner: Alex; Tablespace:
--

CREATE TABLE comment_votes (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    iid integer NOT NULL,
    user_id uuid,
    comment_id uuid,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.comment_votes OWNER TO "Alex";

--
-- Name: comment_votes_iid_seq; Type: SEQUENCE; Schema: public; Owner: Alex
--

CREATE SEQUENCE comment_votes_iid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.comment_votes_iid_seq OWNER TO "Alex";

--
-- Name: comment_votes_iid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: Alex
--

ALTER SEQUENCE comment_votes_iid_seq OWNED BY comment_votes.iid;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: Alex; Tablespace:
--

CREATE TABLE comments (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    iid integer NOT NULL,
    user_id uuid,
    post_id uuid,
    body text,
    votes integer DEFAULT 0,
    score double precision DEFAULT 0.0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    parent_id uuid
);


ALTER TABLE public.comments OWNER TO "Alex";

--
-- Name: comments_iid_seq; Type: SEQUENCE; Schema: public; Owner: Alex
--

CREATE SEQUENCE comments_iid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.comments_iid_seq OWNER TO "Alex";

--
-- Name: comments_iid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: Alex
--

ALTER SEQUENCE comments_iid_seq OWNED BY comments.iid;


--
-- Name: post_visits; Type: TABLE; Schema: public; Owner: Alex; Tablespace:
--

CREATE TABLE post_visits (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    iid integer NOT NULL,
    user_id uuid,
    post_id uuid,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.post_visits OWNER TO "Alex";

--
-- Name: post_visits_iid_seq; Type: SEQUENCE; Schema: public; Owner: Alex
--

CREATE SEQUENCE post_visits_iid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.post_visits_iid_seq OWNER TO "Alex";

--
-- Name: post_visits_iid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: Alex
--

ALTER SEQUENCE post_visits_iid_seq OWNED BY post_visits.iid;


--
-- Name: post_votes; Type: TABLE; Schema: public; Owner: Alex; Tablespace:
--

CREATE TABLE post_votes (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    iid integer NOT NULL,
    user_id uuid,
    post_id uuid,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.post_votes OWNER TO "Alex";

--
-- Name: post_votes_iid_seq; Type: SEQUENCE; Schema: public; Owner: Alex
--

CREATE SEQUENCE post_votes_iid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.post_votes_iid_seq OWNER TO "Alex";

--
-- Name: post_votes_iid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: Alex
--

ALTER SEQUENCE post_votes_iid_seq OWNED BY post_votes.iid;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: Alex; Tablespace:
--

CREATE TABLE posts (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    iid integer NOT NULL,
    visits integer DEFAULT 0,
    title text,
    url text,
    slug text,
    oembed json,
    html_title text,
    link_icons json,
    domain text,
    votes integer DEFAULT 0,
    score double precision DEFAULT 0.0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    user_id uuid,
    open_graph json,
    body text,
    summary text,
    tweet_id text,
    scheduled_at timestamp without time zone,
    published_at timestamp without time zone,
    comment_count integer DEFAULT 0 NOT NULL,
    comments_count integer DEFAULT 0 NOT NULL,
    user_handle text,
    voted_user_ids uuid[] DEFAULT '{}'::uuid[],
    preview_url text
);


ALTER TABLE public.posts OWNER TO "Alex";

--
-- Name: posts_iid_seq; Type: SEQUENCE; Schema: public; Owner: Alex
--

CREATE SEQUENCE posts_iid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.posts_iid_seq OWNER TO "Alex";

--
-- Name: posts_iid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: Alex
--

ALTER SEQUENCE posts_iid_seq OWNED BY posts.iid;


--
-- Name: schema_info; Type: TABLE; Schema: public; Owner: Alex; Tablespace:
--

CREATE TABLE schema_info (
    version integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.schema_info OWNER TO "Alex";

--
-- Name: user_invites; Type: TABLE; Schema: public; Owner: Alex; Tablespace:
--

CREATE TABLE user_invites (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    iid integer NOT NULL,
    email text,
    code text,
    user_id uuid,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    twitter character varying(255),
    github text,
    invited_user_id uuid
);


ALTER TABLE public.user_invites OWNER TO "Alex";

--
-- Name: user_invites_iid_seq; Type: SEQUENCE; Schema: public; Owner: Alex
--

CREATE SEQUENCE user_invites_iid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_invites_iid_seq OWNER TO "Alex";

--
-- Name: user_invites_iid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: Alex
--

ALTER SEQUENCE user_invites_iid_seq OWNED BY user_invites.iid;


--
-- Name: users; Type: TABLE; Schema: public; Owner: Alex; Tablespace:
--

CREATE TABLE users (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    iid integer NOT NULL,
    uid text,
    provider text,
    handle text,
    about text,
    email text,
    url text,
    twitter text,
    karma integer DEFAULT 0,
    name text,
    auth json,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    admin boolean DEFAULT false,
    registered boolean,
    parent_id uuid,
    invites_count integer DEFAULT 0,
    github text,
    secret text,
    manifesto boolean DEFAULT false
);


ALTER TABLE public.users OWNER TO "Alex";

--
-- Name: users_iid_seq; Type: SEQUENCE; Schema: public; Owner: Alex
--

CREATE SEQUENCE users_iid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_iid_seq OWNER TO "Alex";

--
-- Name: users_iid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: Alex
--

ALTER SEQUENCE users_iid_seq OWNED BY users.iid;


--
-- Name: iid; Type: DEFAULT; Schema: public; Owner: Alex
--

ALTER TABLE ONLY comment_votes ALTER COLUMN iid SET DEFAULT nextval('comment_votes_iid_seq'::regclass);


--
-- Name: iid; Type: DEFAULT; Schema: public; Owner: Alex
--

ALTER TABLE ONLY comments ALTER COLUMN iid SET DEFAULT nextval('comments_iid_seq'::regclass);


--
-- Name: iid; Type: DEFAULT; Schema: public; Owner: Alex
--

ALTER TABLE ONLY post_visits ALTER COLUMN iid SET DEFAULT nextval('post_visits_iid_seq'::regclass);


--
-- Name: iid; Type: DEFAULT; Schema: public; Owner: Alex
--

ALTER TABLE ONLY post_votes ALTER COLUMN iid SET DEFAULT nextval('post_votes_iid_seq'::regclass);


--
-- Name: iid; Type: DEFAULT; Schema: public; Owner: Alex
--

ALTER TABLE ONLY posts ALTER COLUMN iid SET DEFAULT nextval('posts_iid_seq'::regclass);


--
-- Name: iid; Type: DEFAULT; Schema: public; Owner: Alex
--

ALTER TABLE ONLY user_invites ALTER COLUMN iid SET DEFAULT nextval('user_invites_iid_seq'::regclass);


--
-- Name: iid; Type: DEFAULT; Schema: public; Owner: Alex
--

ALTER TABLE ONLY users ALTER COLUMN iid SET DEFAULT nextval('users_iid_seq'::regclass);


--
-- Name: comment_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: Alex; Tablespace:
--

ALTER TABLE ONLY comment_votes
    ADD CONSTRAINT comment_votes_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: Alex; Tablespace:
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: post_visits_pkey; Type: CONSTRAINT; Schema: public; Owner: Alex; Tablespace:
--

ALTER TABLE ONLY post_visits
    ADD CONSTRAINT post_visits_pkey PRIMARY KEY (id);


--
-- Name: post_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: Alex; Tablespace:
--

ALTER TABLE ONLY post_votes
    ADD CONSTRAINT post_votes_pkey PRIMARY KEY (id);


--
-- Name: posts_pkey; Type: CONSTRAINT; Schema: public; Owner: Alex; Tablespace:
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: user_invites_pkey; Type: CONSTRAINT; Schema: public; Owner: Alex; Tablespace:
--

ALTER TABLE ONLY user_invites
    ADD CONSTRAINT user_invites_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: Alex; Tablespace:
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: comment_votes_comment_id_index; Type: INDEX; Schema: public; Owner: Alex; Tablespace:
--

CREATE INDEX comment_votes_comment_id_index ON comment_votes USING btree (comment_id);


--
-- Name: comment_votes_user_id_index; Type: INDEX; Schema: public; Owner: Alex; Tablespace:
--

CREATE INDEX comment_votes_user_id_index ON comment_votes USING btree (user_id);


--
-- Name: comments_iid_index; Type: INDEX; Schema: public; Owner: Alex; Tablespace:
--

CREATE UNIQUE INDEX comments_iid_index ON comments USING btree (iid);


--
-- Name: post_visits_post_id_index; Type: INDEX; Schema: public; Owner: Alex; Tablespace:
--

CREATE INDEX post_visits_post_id_index ON post_visits USING btree (post_id);


--
-- Name: post_visits_user_id_index; Type: INDEX; Schema: public; Owner: Alex; Tablespace:
--

CREATE INDEX post_visits_user_id_index ON post_visits USING btree (user_id);


--
-- Name: post_votes_post_id_index; Type: INDEX; Schema: public; Owner: Alex; Tablespace:
--

CREATE INDEX post_votes_post_id_index ON post_votes USING btree (post_id);


--
-- Name: post_votes_user_id_index; Type: INDEX; Schema: public; Owner: Alex; Tablespace:
--

CREATE INDEX post_votes_user_id_index ON post_votes USING btree (user_id);


--
-- Name: posts_iid_index; Type: INDEX; Schema: public; Owner: Alex; Tablespace:
--

CREATE UNIQUE INDEX posts_iid_index ON posts USING btree (iid);


--
-- Name: posts_published_at_index; Type: INDEX; Schema: public; Owner: Alex; Tablespace:
--

CREATE INDEX posts_published_at_index ON posts USING btree (published_at);


--
-- Name: posts_slug_index; Type: INDEX; Schema: public; Owner: Alex; Tablespace:
--

CREATE UNIQUE INDEX posts_slug_index ON posts USING btree (slug);


--
-- Name: posts_user_id_index; Type: INDEX; Schema: public; Owner: Alex; Tablespace:
--

CREATE INDEX posts_user_id_index ON posts USING btree (user_id);


--
-- Name: user_invites_code_key; Type: INDEX; Schema: public; Owner: Alex; Tablespace:
--

CREATE UNIQUE INDEX user_invites_code_key ON user_invites USING btree (code);


--
-- Name: user_invites_user_id_index; Type: INDEX; Schema: public; Owner: Alex; Tablespace:
--

CREATE INDEX user_invites_user_id_index ON user_invites USING btree (user_id);


--
-- Name: users_handle_index; Type: INDEX; Schema: public; Owner: Alex; Tablespace:
--

CREATE INDEX users_handle_index ON users USING btree (handle);


--
-- Name: users_iid_index; Type: INDEX; Schema: public; Owner: Alex; Tablespace:
--

CREATE UNIQUE INDEX users_iid_index ON users USING btree (iid);


--
-- Name: users_uid_index; Type: INDEX; Schema: public; Owner: Alex; Tablespace:
--

CREATE UNIQUE INDEX users_uid_index ON users USING btree (uid);


--
-- Name: pgt_cc_posts__id__comments_count__post_id; Type: TRIGGER; Schema: public; Owner: Alex
--

CREATE TRIGGER pgt_cc_posts__id__comments_count__post_id BEFORE INSERT OR DELETE ON comments FOR EACH ROW EXECUTE PROCEDURE cc_posts_comments_count();


--
-- Name: trg_posts_user_handle; Type: TRIGGER; Schema: public; Owner: Alex
--

CREATE TRIGGER trg_posts_user_handle BEFORE UPDATE ON users FOR EACH ROW EXECUTE PROCEDURE c_posts_user_handle();


--
-- Name: trg_posts_voted; Type: TRIGGER; Schema: public; Owner: Alex
--

CREATE TRIGGER trg_posts_voted BEFORE INSERT ON post_votes FOR EACH ROW EXECUTE PROCEDURE c_posts_voted();


--
-- Name: comment_votes_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: Alex
--

ALTER TABLE ONLY comment_votes
    ADD CONSTRAINT comment_votes_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES comments(id);


--
-- Name: comment_votes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: Alex
--

ALTER TABLE ONLY comment_votes
    ADD CONSTRAINT comment_votes_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: comments_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: Alex
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES comments(id);


--
-- Name: comments_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: Alex
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES posts(id);


--
-- Name: comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: Alex
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: post_visits_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: Alex
--

ALTER TABLE ONLY post_visits
    ADD CONSTRAINT post_visits_post_id_fkey FOREIGN KEY (post_id) REFERENCES posts(id);


--
-- Name: post_visits_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: Alex
--

ALTER TABLE ONLY post_visits
    ADD CONSTRAINT post_visits_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: post_votes_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: Alex
--

ALTER TABLE ONLY post_votes
    ADD CONSTRAINT post_votes_post_id_fkey FOREIGN KEY (post_id) REFERENCES posts(id);


--
-- Name: post_votes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: Alex
--

ALTER TABLE ONLY post_votes
    ADD CONSTRAINT post_votes_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: posts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: Alex
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: user_invites_invited_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: Alex
--

ALTER TABLE ONLY user_invites
    ADD CONSTRAINT user_invites_invited_user_id_fkey FOREIGN KEY (invited_user_id) REFERENCES users(id);


--
-- Name: user_invites_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: Alex
--

ALTER TABLE ONLY user_invites
    ADD CONSTRAINT user_invites_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: users_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: Alex
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES users(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: Alex
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM "Alex";
GRANT ALL ON SCHEMA public TO "Alex";
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

