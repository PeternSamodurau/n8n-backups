--
-- PostgreSQL database dump
--

\restrict Ja7Ohe5pgtYg4p8eQcfHlyn7YPEcrGhkBEzNzYtfFZpz0l16e4OX91Gyb2HOibe

-- Dumped from database version 15.17 (Debian 15.17-1.pgdg13+1)
-- Dumped by pg_dump version 15.17 (Debian 15.17-1.pgdg13+1)

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
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: increment_workflow_version(); Type: FUNCTION; Schema: public; Owner: peter
--

CREATE FUNCTION public.increment_workflow_version() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
			BEGIN
				IF NEW."versionCounter" IS NOT DISTINCT FROM OLD."versionCounter" THEN
					NEW."versionCounter" = OLD."versionCounter" + 1;
				END IF;
				RETURN NEW;
			END;
			$$;


ALTER FUNCTION public.increment_workflow_version() OWNER TO peter;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: annotation_tag_entity; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.annotation_tag_entity (
    id character varying(16) NOT NULL,
    name character varying(24) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.annotation_tag_entity OWNER TO peter;

--
-- Name: auth_identity; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.auth_identity (
    "userId" uuid,
    "providerId" character varying(255) NOT NULL,
    "providerType" character varying(32) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.auth_identity OWNER TO peter;

--
-- Name: auth_provider_sync_history; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.auth_provider_sync_history (
    id integer NOT NULL,
    "providerType" character varying(32) NOT NULL,
    "runMode" text NOT NULL,
    status text NOT NULL,
    "startedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "endedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    scanned integer NOT NULL,
    created integer NOT NULL,
    updated integer NOT NULL,
    disabled integer NOT NULL,
    error text
);


ALTER TABLE public.auth_provider_sync_history OWNER TO peter;

--
-- Name: auth_provider_sync_history_id_seq; Type: SEQUENCE; Schema: public; Owner: peter
--

CREATE SEQUENCE public.auth_provider_sync_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_provider_sync_history_id_seq OWNER TO peter;

--
-- Name: auth_provider_sync_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: peter
--

ALTER SEQUENCE public.auth_provider_sync_history_id_seq OWNED BY public.auth_provider_sync_history.id;


--
-- Name: binary_data; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.binary_data (
    "fileId" uuid NOT NULL,
    "sourceType" character varying(50) NOT NULL,
    "sourceId" character varying(255) NOT NULL,
    data bytea NOT NULL,
    "mimeType" character varying(255),
    "fileName" character varying(255),
    "fileSize" integer NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    CONSTRAINT "CHK_binary_data_sourceType" CHECK ((("sourceType")::text = ANY ((ARRAY['execution'::character varying, 'chat_message_attachment'::character varying])::text[])))
);


ALTER TABLE public.binary_data OWNER TO peter;

--
-- Name: COLUMN binary_data."sourceType"; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.binary_data."sourceType" IS 'Source the file belongs to, e.g. ''execution''';


--
-- Name: COLUMN binary_data."sourceId"; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.binary_data."sourceId" IS 'ID of the source, e.g. execution ID';


--
-- Name: COLUMN binary_data.data; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.binary_data.data IS 'Raw, not base64 encoded';


--
-- Name: COLUMN binary_data."fileSize"; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.binary_data."fileSize" IS 'In bytes';


--
-- Name: chat_hub_agent_tools; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.chat_hub_agent_tools (
    "agentId" uuid NOT NULL,
    "toolId" uuid NOT NULL
);


ALTER TABLE public.chat_hub_agent_tools OWNER TO peter;

--
-- Name: chat_hub_agents; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.chat_hub_agents (
    id uuid NOT NULL,
    name character varying(256) NOT NULL,
    description character varying(512),
    "systemPrompt" text NOT NULL,
    "ownerId" uuid NOT NULL,
    "credentialId" character varying(36),
    provider character varying(16) NOT NULL,
    model character varying(64) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    icon json,
    files json DEFAULT '[]'::json NOT NULL,
    "suggestedPrompts" json DEFAULT '[]'::json NOT NULL
);


ALTER TABLE public.chat_hub_agents OWNER TO peter;

--
-- Name: COLUMN chat_hub_agents.provider; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.chat_hub_agents.provider IS 'ChatHubProvider enum: "openai", "anthropic", "google", "n8n"';


--
-- Name: COLUMN chat_hub_agents.model; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.chat_hub_agents.model IS 'Model name used at the respective Model node, ie. "gpt-4"';


--
-- Name: chat_hub_messages; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.chat_hub_messages (
    id uuid NOT NULL,
    "sessionId" uuid NOT NULL,
    "previousMessageId" uuid,
    "revisionOfMessageId" uuid,
    "retryOfMessageId" uuid,
    type character varying(16) NOT NULL,
    name character varying(128) NOT NULL,
    content text NOT NULL,
    provider character varying(16),
    model character varying(256),
    "workflowId" character varying(36),
    "executionId" integer,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "agentId" uuid,
    status character varying(16) DEFAULT 'success'::character varying NOT NULL,
    attachments json
);


ALTER TABLE public.chat_hub_messages OWNER TO peter;

--
-- Name: COLUMN chat_hub_messages.type; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.chat_hub_messages.type IS 'ChatHubMessageType enum: "human", "ai", "system", "tool", "generic"';


--
-- Name: COLUMN chat_hub_messages.provider; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.chat_hub_messages.provider IS 'ChatHubProvider enum: "openai", "anthropic", "google", "n8n"';


--
-- Name: COLUMN chat_hub_messages.model; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.chat_hub_messages.model IS 'Model name used at the respective Model node, ie. "gpt-4"';


--
-- Name: COLUMN chat_hub_messages."agentId"; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.chat_hub_messages."agentId" IS 'ID of the custom agent (if provider is "custom-agent")';


--
-- Name: COLUMN chat_hub_messages.status; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.chat_hub_messages.status IS 'ChatHubMessageStatus enum, eg. "success", "error", "running", "cancelled"';


--
-- Name: COLUMN chat_hub_messages.attachments; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.chat_hub_messages.attachments IS 'File attachments for the message (if any), stored as JSON. Files are stored as base64-encoded data URLs.';


--
-- Name: chat_hub_session_tools; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.chat_hub_session_tools (
    "sessionId" uuid NOT NULL,
    "toolId" uuid NOT NULL
);


ALTER TABLE public.chat_hub_session_tools OWNER TO peter;

--
-- Name: chat_hub_sessions; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.chat_hub_sessions (
    id uuid NOT NULL,
    title character varying(256) NOT NULL,
    "ownerId" uuid NOT NULL,
    "lastMessageAt" timestamp(3) with time zone NOT NULL,
    "credentialId" character varying(36),
    provider character varying(16),
    model character varying(256),
    "workflowId" character varying(36),
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "agentId" uuid,
    "agentName" character varying(128),
    type character varying(16) DEFAULT 'production'::character varying NOT NULL,
    CONSTRAINT "CHK_chat_hub_sessions_type" CHECK (((type)::text = ANY ((ARRAY['production'::character varying, 'manual'::character varying])::text[])))
);


ALTER TABLE public.chat_hub_sessions OWNER TO peter;

--
-- Name: COLUMN chat_hub_sessions.provider; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.chat_hub_sessions.provider IS 'ChatHubProvider enum: "openai", "anthropic", "google", "n8n"';


--
-- Name: COLUMN chat_hub_sessions.model; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.chat_hub_sessions.model IS 'Model name used at the respective Model node, ie. "gpt-4"';


--
-- Name: COLUMN chat_hub_sessions."agentId"; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.chat_hub_sessions."agentId" IS 'ID of the custom agent (if provider is "custom-agent")';


--
-- Name: COLUMN chat_hub_sessions."agentName"; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.chat_hub_sessions."agentName" IS 'Cached name of the custom agent (if provider is "custom-agent")';


--
-- Name: chat_hub_tools; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.chat_hub_tools (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    "typeVersion" double precision NOT NULL,
    "ownerId" uuid NOT NULL,
    definition json NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.chat_hub_tools OWNER TO peter;

--
-- Name: credentials_entity; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.credentials_entity (
    name character varying(128) NOT NULL,
    data text NOT NULL,
    type character varying(128) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    id character varying(36) NOT NULL,
    "isManaged" boolean DEFAULT false NOT NULL,
    "isGlobal" boolean DEFAULT false NOT NULL,
    "isResolvable" boolean DEFAULT false NOT NULL,
    "resolvableAllowFallback" boolean DEFAULT false NOT NULL,
    "resolverId" character varying(16)
);


ALTER TABLE public.credentials_entity OWNER TO peter;

--
-- Name: data_table; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.data_table (
    id character varying(36) NOT NULL,
    name character varying(128) NOT NULL,
    "projectId" character varying(36) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.data_table OWNER TO peter;

--
-- Name: data_table_column; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.data_table_column (
    id character varying(36) NOT NULL,
    name character varying(128) NOT NULL,
    type character varying(32) NOT NULL,
    index integer NOT NULL,
    "dataTableId" character varying(36) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.data_table_column OWNER TO peter;

--
-- Name: COLUMN data_table_column.type; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.data_table_column.type IS 'Expected: string, number, boolean, or date (not enforced as a constraint)';


--
-- Name: COLUMN data_table_column.index; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.data_table_column.index IS 'Column order, starting from 0 (0 = first column)';


--
-- Name: dynamic_credential_entry; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.dynamic_credential_entry (
    credential_id character varying(16) NOT NULL,
    subject_id character varying(2048) NOT NULL,
    resolver_id character varying(16) NOT NULL,
    data text NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.dynamic_credential_entry OWNER TO peter;

--
-- Name: dynamic_credential_resolver; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.dynamic_credential_resolver (
    id character varying(16) NOT NULL,
    name character varying(128) NOT NULL,
    type character varying(128) NOT NULL,
    config text NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.dynamic_credential_resolver OWNER TO peter;

--
-- Name: COLUMN dynamic_credential_resolver.config; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.dynamic_credential_resolver.config IS 'Encrypted resolver configuration (JSON encrypted as string)';


--
-- Name: dynamic_credential_user_entry; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.dynamic_credential_user_entry (
    "credentialId" character varying(16) NOT NULL,
    "userId" uuid NOT NULL,
    "resolverId" character varying(16) NOT NULL,
    data text NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.dynamic_credential_user_entry OWNER TO peter;

--
-- Name: event_destinations; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.event_destinations (
    id uuid NOT NULL,
    destination jsonb NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.event_destinations OWNER TO peter;

--
-- Name: execution_annotation_tags; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.execution_annotation_tags (
    "annotationId" integer NOT NULL,
    "tagId" character varying(24) NOT NULL
);


ALTER TABLE public.execution_annotation_tags OWNER TO peter;

--
-- Name: execution_annotations; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.execution_annotations (
    id integer NOT NULL,
    "executionId" integer NOT NULL,
    vote character varying(6),
    note text,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.execution_annotations OWNER TO peter;

--
-- Name: execution_annotations_id_seq; Type: SEQUENCE; Schema: public; Owner: peter
--

CREATE SEQUENCE public.execution_annotations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.execution_annotations_id_seq OWNER TO peter;

--
-- Name: execution_annotations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: peter
--

ALTER SEQUENCE public.execution_annotations_id_seq OWNED BY public.execution_annotations.id;


--
-- Name: execution_data; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.execution_data (
    "executionId" integer NOT NULL,
    "workflowData" json NOT NULL,
    data text NOT NULL,
    "workflowVersionId" character varying(36)
);


ALTER TABLE public.execution_data OWNER TO peter;

--
-- Name: execution_entity; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.execution_entity (
    id integer NOT NULL,
    finished boolean NOT NULL,
    mode character varying NOT NULL,
    "retryOf" character varying,
    "retrySuccessId" character varying,
    "startedAt" timestamp(3) with time zone,
    "stoppedAt" timestamp(3) with time zone,
    "waitTill" timestamp(3) with time zone,
    status character varying NOT NULL,
    "workflowId" character varying(36) NOT NULL,
    "deletedAt" timestamp(3) with time zone,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "storedAt" character varying(2) DEFAULT 'db'::character varying NOT NULL,
    CONSTRAINT "execution_entity_storedAt_check" CHECK ((("storedAt")::text = ANY ((ARRAY['db'::character varying, 'fs'::character varying, 's3'::character varying])::text[])))
);


ALTER TABLE public.execution_entity OWNER TO peter;

--
-- Name: execution_entity_id_seq; Type: SEQUENCE; Schema: public; Owner: peter
--

CREATE SEQUENCE public.execution_entity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.execution_entity_id_seq OWNER TO peter;

--
-- Name: execution_entity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: peter
--

ALTER SEQUENCE public.execution_entity_id_seq OWNED BY public.execution_entity.id;


--
-- Name: execution_metadata; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.execution_metadata (
    id integer NOT NULL,
    "executionId" integer NOT NULL,
    key character varying(255) NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.execution_metadata OWNER TO peter;

--
-- Name: execution_metadata_temp_id_seq; Type: SEQUENCE; Schema: public; Owner: peter
--

CREATE SEQUENCE public.execution_metadata_temp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.execution_metadata_temp_id_seq OWNER TO peter;

--
-- Name: execution_metadata_temp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: peter
--

ALTER SEQUENCE public.execution_metadata_temp_id_seq OWNED BY public.execution_metadata.id;


--
-- Name: folder; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.folder (
    id character varying(36) NOT NULL,
    name character varying(128) NOT NULL,
    "parentFolderId" character varying(36),
    "projectId" character varying(36) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.folder OWNER TO peter;

--
-- Name: folder_tag; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.folder_tag (
    "folderId" character varying(36) NOT NULL,
    "tagId" character varying(36) NOT NULL
);


ALTER TABLE public.folder_tag OWNER TO peter;

--
-- Name: insights_by_period; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.insights_by_period (
    id integer NOT NULL,
    "metaId" integer NOT NULL,
    type integer NOT NULL,
    value bigint NOT NULL,
    "periodUnit" integer NOT NULL,
    "periodStart" timestamp(0) with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.insights_by_period OWNER TO peter;

--
-- Name: COLUMN insights_by_period.type; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.insights_by_period.type IS '0: time_saved_minutes, 1: runtime_milliseconds, 2: success, 3: failure';


--
-- Name: COLUMN insights_by_period."periodUnit"; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.insights_by_period."periodUnit" IS '0: hour, 1: day, 2: week';


--
-- Name: insights_by_period_id_seq; Type: SEQUENCE; Schema: public; Owner: peter
--

ALTER TABLE public.insights_by_period ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.insights_by_period_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: insights_metadata; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.insights_metadata (
    "metaId" integer NOT NULL,
    "workflowId" character varying(36),
    "projectId" character varying(36),
    "workflowName" character varying(128) NOT NULL,
    "projectName" character varying(255) NOT NULL
);


ALTER TABLE public.insights_metadata OWNER TO peter;

--
-- Name: insights_metadata_metaId_seq; Type: SEQUENCE; Schema: public; Owner: peter
--

ALTER TABLE public.insights_metadata ALTER COLUMN "metaId" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."insights_metadata_metaId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: insights_raw; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.insights_raw (
    id integer NOT NULL,
    "metaId" integer NOT NULL,
    type integer NOT NULL,
    value bigint NOT NULL,
    "timestamp" timestamp(0) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.insights_raw OWNER TO peter;

--
-- Name: COLUMN insights_raw.type; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.insights_raw.type IS '0: time_saved_minutes, 1: runtime_milliseconds, 2: success, 3: failure';


--
-- Name: insights_raw_id_seq; Type: SEQUENCE; Schema: public; Owner: peter
--

ALTER TABLE public.insights_raw ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.insights_raw_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: installed_nodes; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.installed_nodes (
    name character varying(200) NOT NULL,
    type character varying(200) NOT NULL,
    "latestVersion" integer DEFAULT 1 NOT NULL,
    package character varying(241) NOT NULL
);


ALTER TABLE public.installed_nodes OWNER TO peter;

--
-- Name: installed_packages; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.installed_packages (
    "packageName" character varying(214) NOT NULL,
    "installedVersion" character varying(50) NOT NULL,
    "authorName" character varying(70),
    "authorEmail" character varying(70),
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.installed_packages OWNER TO peter;

--
-- Name: invalid_auth_token; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.invalid_auth_token (
    token character varying(512) NOT NULL,
    "expiresAt" timestamp(3) with time zone NOT NULL
);


ALTER TABLE public.invalid_auth_token OWNER TO peter;

--
-- Name: migrations; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    "timestamp" bigint NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.migrations OWNER TO peter;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: peter
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.migrations_id_seq OWNER TO peter;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: peter
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.oauth_access_tokens (
    token character varying NOT NULL,
    "clientId" character varying NOT NULL,
    "userId" uuid NOT NULL
);


ALTER TABLE public.oauth_access_tokens OWNER TO peter;

--
-- Name: oauth_authorization_codes; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.oauth_authorization_codes (
    code character varying(255) NOT NULL,
    "clientId" character varying NOT NULL,
    "userId" uuid NOT NULL,
    "redirectUri" character varying NOT NULL,
    "codeChallenge" character varying NOT NULL,
    "codeChallengeMethod" character varying(255) NOT NULL,
    "expiresAt" bigint NOT NULL,
    state character varying,
    used boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.oauth_authorization_codes OWNER TO peter;

--
-- Name: COLUMN oauth_authorization_codes."expiresAt"; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.oauth_authorization_codes."expiresAt" IS 'Unix timestamp in milliseconds';


--
-- Name: oauth_clients; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.oauth_clients (
    id character varying NOT NULL,
    name character varying(255) NOT NULL,
    "redirectUris" json NOT NULL,
    "grantTypes" json NOT NULL,
    "clientSecret" character varying(255),
    "clientSecretExpiresAt" bigint,
    "tokenEndpointAuthMethod" character varying(255) DEFAULT 'none'::character varying NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.oauth_clients OWNER TO peter;

--
-- Name: COLUMN oauth_clients."tokenEndpointAuthMethod"; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.oauth_clients."tokenEndpointAuthMethod" IS 'Possible values: none, client_secret_basic or client_secret_post';


--
-- Name: oauth_refresh_tokens; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.oauth_refresh_tokens (
    token character varying(255) NOT NULL,
    "clientId" character varying NOT NULL,
    "userId" uuid NOT NULL,
    "expiresAt" bigint NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.oauth_refresh_tokens OWNER TO peter;

--
-- Name: COLUMN oauth_refresh_tokens."expiresAt"; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.oauth_refresh_tokens."expiresAt" IS 'Unix timestamp in milliseconds';


--
-- Name: oauth_user_consents; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.oauth_user_consents (
    id integer NOT NULL,
    "userId" uuid NOT NULL,
    "clientId" character varying NOT NULL,
    "grantedAt" bigint NOT NULL
);


ALTER TABLE public.oauth_user_consents OWNER TO peter;

--
-- Name: COLUMN oauth_user_consents."grantedAt"; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.oauth_user_consents."grantedAt" IS 'Unix timestamp in milliseconds';


--
-- Name: oauth_user_consents_id_seq; Type: SEQUENCE; Schema: public; Owner: peter
--

ALTER TABLE public.oauth_user_consents ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.oauth_user_consents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: processed_data; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.processed_data (
    "workflowId" character varying(36) NOT NULL,
    context character varying(255) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.processed_data OWNER TO peter;

--
-- Name: project; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.project (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    type character varying(36) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    icon json,
    description character varying(512),
    "creatorId" uuid
);


ALTER TABLE public.project OWNER TO peter;

--
-- Name: COLUMN project."creatorId"; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.project."creatorId" IS 'ID of the user who created the project';


--
-- Name: project_relation; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.project_relation (
    "projectId" character varying(36) NOT NULL,
    "userId" uuid NOT NULL,
    role character varying NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.project_relation OWNER TO peter;

--
-- Name: project_secrets_provider_access; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.project_secrets_provider_access (
    "secretsProviderConnectionId" integer NOT NULL,
    "projectId" character varying(36) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    role character varying(128) DEFAULT 'secretsProviderConnection:user'::character varying NOT NULL,
    CONSTRAINT "CHK_project_secrets_provider_access_role" CHECK (((role)::text = ANY ((ARRAY['secretsProviderConnection:owner'::character varying, 'secretsProviderConnection:user'::character varying])::text[])))
);


ALTER TABLE public.project_secrets_provider_access OWNER TO peter;

--
-- Name: region; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.region (
    id integer NOT NULL,
    code text NOT NULL
);


ALTER TABLE public.region OWNER TO peter;

--
-- Name: region_id_seq; Type: SEQUENCE; Schema: public; Owner: peter
--

CREATE SEQUENCE public.region_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.region_id_seq OWNER TO peter;

--
-- Name: region_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: peter
--

ALTER SEQUENCE public.region_id_seq OWNED BY public.region.id;


--
-- Name: role; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.role (
    slug character varying(128) NOT NULL,
    "displayName" text,
    description text,
    "roleType" text,
    "systemRole" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.role OWNER TO peter;

--
-- Name: COLUMN role.slug; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.role.slug IS 'Unique identifier of the role for example: "global:owner"';


--
-- Name: COLUMN role."displayName"; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.role."displayName" IS 'Name used to display in the UI';


--
-- Name: COLUMN role.description; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.role.description IS 'Text describing the scope in more detail of users';


--
-- Name: COLUMN role."roleType"; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.role."roleType" IS 'Type of the role, e.g., global, project, or workflow';


--
-- Name: COLUMN role."systemRole"; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.role."systemRole" IS 'Indicates if the role is managed by the system and cannot be edited';


--
-- Name: role_scope; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.role_scope (
    "roleSlug" character varying(128) NOT NULL,
    "scopeSlug" character varying(128) NOT NULL
);


ALTER TABLE public.role_scope OWNER TO peter;

--
-- Name: scope; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.scope (
    slug character varying(128) NOT NULL,
    "displayName" text,
    description text
);


ALTER TABLE public.scope OWNER TO peter;

--
-- Name: COLUMN scope.slug; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.scope.slug IS 'Unique identifier of the scope for example: "project:create"';


--
-- Name: COLUMN scope."displayName"; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.scope."displayName" IS 'Name used to display in the UI';


--
-- Name: COLUMN scope.description; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.scope.description IS 'Text describing the scope in more detail of users';


--
-- Name: secrets_provider_connection; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.secrets_provider_connection (
    id integer NOT NULL,
    "providerKey" character varying(128) NOT NULL,
    type character varying(36) NOT NULL,
    "encryptedSettings" text NOT NULL,
    "isEnabled" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.secrets_provider_connection OWNER TO peter;

--
-- Name: COLUMN secrets_provider_connection.type; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.secrets_provider_connection.type IS 'Type of secrets provider. Possible values: awsSecretsManager, gcpSecretsManager, vault, azureKeyVault, infisical';


--
-- Name: secrets_provider_connection_id_seq; Type: SEQUENCE; Schema: public; Owner: peter
--

ALTER TABLE public.secrets_provider_connection ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.secrets_provider_connection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: settings; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.settings (
    key character varying(255) NOT NULL,
    value text NOT NULL,
    "loadOnStartup" boolean DEFAULT false NOT NULL
);


ALTER TABLE public.settings OWNER TO peter;

--
-- Name: shared_credentials; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.shared_credentials (
    "credentialsId" character varying(36) NOT NULL,
    "projectId" character varying(36) NOT NULL,
    role text NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.shared_credentials OWNER TO peter;

--
-- Name: shared_workflow; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.shared_workflow (
    "workflowId" character varying(36) NOT NULL,
    "projectId" character varying(36) NOT NULL,
    role text NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.shared_workflow OWNER TO peter;

--
-- Name: sources; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.sources (
    id integer NOT NULL,
    url text NOT NULL,
    type text DEFAULT 'rss'::text NOT NULL,
    active boolean DEFAULT true NOT NULL,
    region_id integer
);


ALTER TABLE public.sources OWNER TO peter;

--
-- Name: sources_id_seq; Type: SEQUENCE; Schema: public; Owner: peter
--

CREATE SEQUENCE public.sources_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sources_id_seq OWNER TO peter;

--
-- Name: sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: peter
--

ALTER SEQUENCE public.sources_id_seq OWNED BY public.sources.id;


--
-- Name: tag_entity; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.tag_entity (
    name character varying(24) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    id character varying(36) NOT NULL
);


ALTER TABLE public.tag_entity OWNER TO peter;

--
-- Name: test_case_execution; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.test_case_execution (
    id character varying(36) NOT NULL,
    "testRunId" character varying(36) NOT NULL,
    "executionId" integer,
    status character varying NOT NULL,
    "runAt" timestamp(3) with time zone,
    "completedAt" timestamp(3) with time zone,
    "errorCode" character varying,
    "errorDetails" json,
    metrics json,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    inputs json,
    outputs json
);


ALTER TABLE public.test_case_execution OWNER TO peter;

--
-- Name: test_run; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.test_run (
    id character varying(36) NOT NULL,
    "workflowId" character varying(36) NOT NULL,
    status character varying NOT NULL,
    "errorCode" character varying,
    "errorDetails" json,
    "runAt" timestamp(3) with time zone,
    "completedAt" timestamp(3) with time zone,
    metrics json,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "runningInstanceId" character varying(255),
    "cancelRequested" boolean DEFAULT false NOT NULL
);


ALTER TABLE public.test_run OWNER TO peter;

--
-- Name: user; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public."user" (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255),
    "firstName" character varying(32),
    "lastName" character varying(32),
    password character varying(255),
    "personalizationAnswers" json,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    settings json,
    disabled boolean DEFAULT false NOT NULL,
    "mfaEnabled" boolean DEFAULT false NOT NULL,
    "mfaSecret" text,
    "mfaRecoveryCodes" text,
    "lastActiveAt" date,
    "roleSlug" character varying(128) DEFAULT 'global:member'::character varying NOT NULL
);


ALTER TABLE public."user" OWNER TO peter;

--
-- Name: user_api_keys; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.user_api_keys (
    id character varying(36) NOT NULL,
    "userId" uuid NOT NULL,
    label character varying(100) NOT NULL,
    "apiKey" character varying NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    scopes json,
    audience character varying DEFAULT 'public-api'::character varying NOT NULL
);


ALTER TABLE public.user_api_keys OWNER TO peter;

--
-- Name: variables; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.variables (
    key character varying(50) NOT NULL,
    type character varying(50) DEFAULT 'string'::character varying NOT NULL,
    value character varying(255),
    id character varying(36) NOT NULL,
    "projectId" character varying(36)
);


ALTER TABLE public.variables OWNER TO peter;

--
-- Name: webhook_entity; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.webhook_entity (
    "webhookPath" character varying NOT NULL,
    method character varying NOT NULL,
    node character varying NOT NULL,
    "webhookId" character varying,
    "pathLength" integer,
    "workflowId" character varying(36) NOT NULL
);


ALTER TABLE public.webhook_entity OWNER TO peter;

--
-- Name: workflow_builder_session; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.workflow_builder_session (
    id uuid NOT NULL,
    "workflowId" character varying(36) NOT NULL,
    "userId" uuid NOT NULL,
    messages json DEFAULT '[]'::json NOT NULL,
    "previousSummary" text,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.workflow_builder_session OWNER TO peter;

--
-- Name: COLUMN workflow_builder_session."previousSummary"; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.workflow_builder_session."previousSummary" IS 'Summary of prior conversation from compaction (/compact or auto-compact)';


--
-- Name: workflow_dependency; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.workflow_dependency (
    id integer NOT NULL,
    "workflowId" character varying(36) NOT NULL,
    "workflowVersionId" integer NOT NULL,
    "dependencyType" character varying(32) NOT NULL,
    "dependencyKey" character varying(255) NOT NULL,
    "dependencyInfo" json,
    "indexVersionId" smallint DEFAULT 1 NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "publishedVersionId" character varying(36)
);


ALTER TABLE public.workflow_dependency OWNER TO peter;

--
-- Name: COLUMN workflow_dependency."workflowVersionId"; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.workflow_dependency."workflowVersionId" IS 'Version of the workflow';


--
-- Name: COLUMN workflow_dependency."dependencyType"; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.workflow_dependency."dependencyType" IS 'Type of dependency: "credential", "nodeType", "webhookPath", or "workflowCall"';


--
-- Name: COLUMN workflow_dependency."dependencyKey"; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.workflow_dependency."dependencyKey" IS 'ID or name of the dependency';


--
-- Name: COLUMN workflow_dependency."dependencyInfo"; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.workflow_dependency."dependencyInfo" IS 'Additional info about the dependency, interpreted based on type';


--
-- Name: COLUMN workflow_dependency."indexVersionId"; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.workflow_dependency."indexVersionId" IS 'Version of the index structure';


--
-- Name: workflow_dependency_id_seq; Type: SEQUENCE; Schema: public; Owner: peter
--

ALTER TABLE public.workflow_dependency ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.workflow_dependency_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: workflow_entity; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.workflow_entity (
    name character varying(128) NOT NULL,
    active boolean NOT NULL,
    nodes json NOT NULL,
    connections json NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    settings json,
    "staticData" json,
    "pinData" json,
    "versionId" character(36) NOT NULL,
    "triggerCount" integer DEFAULT 0 NOT NULL,
    id character varying(36) NOT NULL,
    meta json,
    "parentFolderId" character varying(36) DEFAULT NULL::character varying,
    "isArchived" boolean DEFAULT false NOT NULL,
    "versionCounter" integer DEFAULT 1 NOT NULL,
    description text,
    "activeVersionId" character varying(36)
);


ALTER TABLE public.workflow_entity OWNER TO peter;

--
-- Name: workflow_history; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.workflow_history (
    "versionId" character varying(36) NOT NULL,
    "workflowId" character varying(36) NOT NULL,
    authors character varying(255) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    nodes json NOT NULL,
    connections json NOT NULL,
    name character varying(128),
    autosaved boolean DEFAULT false NOT NULL,
    description text
);


ALTER TABLE public.workflow_history OWNER TO peter;

--
-- Name: workflow_publish_history; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.workflow_publish_history (
    id integer NOT NULL,
    "workflowId" character varying(36) NOT NULL,
    "versionId" character varying(36) NOT NULL,
    event character varying(36) NOT NULL,
    "userId" uuid,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    CONSTRAINT "CHK_workflow_publish_history_event" CHECK (((event)::text = ANY ((ARRAY['activated'::character varying, 'deactivated'::character varying])::text[])))
);


ALTER TABLE public.workflow_publish_history OWNER TO peter;

--
-- Name: COLUMN workflow_publish_history.event; Type: COMMENT; Schema: public; Owner: peter
--

COMMENT ON COLUMN public.workflow_publish_history.event IS 'Type of history record: activated (workflow is now active), deactivated (workflow is now inactive)';


--
-- Name: workflow_publish_history_id_seq; Type: SEQUENCE; Schema: public; Owner: peter
--

ALTER TABLE public.workflow_publish_history ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.workflow_publish_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: workflow_published_version; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.workflow_published_version (
    "workflowId" character varying(36) NOT NULL,
    "publishedVersionId" character varying(36) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.workflow_published_version OWNER TO peter;

--
-- Name: workflow_statistics; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.workflow_statistics (
    count bigint DEFAULT 0,
    "latestEvent" timestamp(3) with time zone,
    name character varying(128) NOT NULL,
    "workflowId" character varying(36) NOT NULL,
    "rootCount" bigint DEFAULT 0,
    id integer NOT NULL,
    "workflowName" character varying(128)
);


ALTER TABLE public.workflow_statistics OWNER TO peter;

--
-- Name: workflow_statistics_id_seq; Type: SEQUENCE; Schema: public; Owner: peter
--

CREATE SEQUENCE public.workflow_statistics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.workflow_statistics_id_seq OWNER TO peter;

--
-- Name: workflow_statistics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: peter
--

ALTER SEQUENCE public.workflow_statistics_id_seq OWNED BY public.workflow_statistics.id;


--
-- Name: workflows_tags; Type: TABLE; Schema: public; Owner: peter
--

CREATE TABLE public.workflows_tags (
    "workflowId" character varying(36) NOT NULL,
    "tagId" character varying(36) NOT NULL
);


ALTER TABLE public.workflows_tags OWNER TO peter;

--
-- Name: auth_provider_sync_history id; Type: DEFAULT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.auth_provider_sync_history ALTER COLUMN id SET DEFAULT nextval('public.auth_provider_sync_history_id_seq'::regclass);


--
-- Name: execution_annotations id; Type: DEFAULT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.execution_annotations ALTER COLUMN id SET DEFAULT nextval('public.execution_annotations_id_seq'::regclass);


--
-- Name: execution_entity id; Type: DEFAULT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.execution_entity ALTER COLUMN id SET DEFAULT nextval('public.execution_entity_id_seq'::regclass);


--
-- Name: execution_metadata id; Type: DEFAULT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.execution_metadata ALTER COLUMN id SET DEFAULT nextval('public.execution_metadata_temp_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: region id; Type: DEFAULT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.region ALTER COLUMN id SET DEFAULT nextval('public.region_id_seq'::regclass);


--
-- Name: sources id; Type: DEFAULT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.sources ALTER COLUMN id SET DEFAULT nextval('public.sources_id_seq'::regclass);


--
-- Name: workflow_statistics id; Type: DEFAULT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.workflow_statistics ALTER COLUMN id SET DEFAULT nextval('public.workflow_statistics_id_seq'::regclass);


--
-- Data for Name: annotation_tag_entity; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.annotation_tag_entity (id, name, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: auth_identity; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.auth_identity ("userId", "providerId", "providerType", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: auth_provider_sync_history; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.auth_provider_sync_history (id, "providerType", "runMode", status, "startedAt", "endedAt", scanned, created, updated, disabled, error) FROM stdin;
\.


--
-- Data for Name: binary_data; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.binary_data ("fileId", "sourceType", "sourceId", data, "mimeType", "fileName", "fileSize", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: chat_hub_agent_tools; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.chat_hub_agent_tools ("agentId", "toolId") FROM stdin;
\.


--
-- Data for Name: chat_hub_agents; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.chat_hub_agents (id, name, description, "systemPrompt", "ownerId", "credentialId", provider, model, "createdAt", "updatedAt", icon, files, "suggestedPrompts") FROM stdin;
\.


--
-- Data for Name: chat_hub_messages; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.chat_hub_messages (id, "sessionId", "previousMessageId", "revisionOfMessageId", "retryOfMessageId", type, name, content, provider, model, "workflowId", "executionId", "createdAt", "updatedAt", "agentId", status, attachments) FROM stdin;
\.


--
-- Data for Name: chat_hub_session_tools; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.chat_hub_session_tools ("sessionId", "toolId") FROM stdin;
\.


--
-- Data for Name: chat_hub_sessions; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.chat_hub_sessions (id, title, "ownerId", "lastMessageAt", "credentialId", provider, model, "workflowId", "createdAt", "updatedAt", "agentId", "agentName", type) FROM stdin;
\.


--
-- Data for Name: chat_hub_tools; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.chat_hub_tools (id, name, type, "typeVersion", "ownerId", definition, enabled, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: credentials_entity; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.credentials_entity (name, data, type, "createdAt", "updatedAt", id, "isManaged", "isGlobal", "isResolvable", "resolvableAllowFallback", "resolverId") FROM stdin;
Postgres account	U2FsdGVkX19jUhvBIuRZhd9U3l1A2Qnj0gO1Q2coOnXNSPJk9WeAlZ4pHB6/H9nNZ+iOD9Xrb7IFR1LGLzw8ECmoSf+xbhHvDksMx93ct98=	postgres	2026-04-02 08:48:09.522+00	2026-04-02 08:48:09.52+00	MWAKq8y3zoMvQl4y	f	f	f	f	\N
\.


--
-- Data for Name: data_table; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.data_table (id, name, "projectId", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: data_table_column; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.data_table_column (id, name, type, index, "dataTableId", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: dynamic_credential_entry; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.dynamic_credential_entry (credential_id, subject_id, resolver_id, data, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: dynamic_credential_resolver; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.dynamic_credential_resolver (id, name, type, config, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: dynamic_credential_user_entry; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.dynamic_credential_user_entry ("credentialId", "userId", "resolverId", data, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: event_destinations; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.event_destinations (id, destination, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: execution_annotation_tags; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.execution_annotation_tags ("annotationId", "tagId") FROM stdin;
\.


--
-- Data for Name: execution_annotations; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.execution_annotations (id, "executionId", vote, note, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: execution_data; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.execution_data ("executionId", "workflowData", data, "workflowVersionId") FROM stdin;
1	{"id":"3iz9JrDgjvhLOoGC","name":"AS_sources_to_news","active":false,"activeVersionId":null,"isArchived":false,"createdAt":"2026-04-02T08:40:36.569Z","updatedAt":"2026-04-02T08:47:16.832Z","nodes":[{"parameters":{"notice":"","rule":{"interval":[{"field":"minutes","minutesInterval":10}]}},"id":"f06f19ca-148d-40ec-87a9-4866fda1ba1c","name":"Schedule Trigger","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[-640,-64]},{"parameters":{"resource":"database","operation":"executeQuery","query":"SELECT id, url, type FROM sources WHERE active = true;","options":{}},"id":"2ec8f6bb-88e9-4802-bed0-9d757a34f418","name":"Select Sources","type":"n8n-nodes-base.postgres","typeVersion":2,"position":[-448,-64]},{"parameters":{"splitInBatchesNotice":"","batchSize":1,"options":{}},"id":"9a85cae3-50f0-4f0a-b380-4642bb4e3687","name":"Split in Batches","type":"n8n-nodes-base.splitInBatches","typeVersion":3,"position":[-240,-64]},{"parameters":{"curlImport":"","method":"GET","url":"={{ $json.url }}","authentication":"none","provideSslCertificates":false,"sendQuery":false,"sendHeaders":false,"sendBody":false,"options":{"response":{}},"infoMessage":""},"id":"04c672ac-36dc-4fe5-894f-ee1e56c17b61","name":"Fetch Source","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[-48,-64]},{"parameters":{"mode":"runOnceForEachItem","language":"javaScript","jsCode":"let { id: source_id, url, type } = $json;\\nlet body = $json.body || '';\\nlet links = [];\\n\\nif (type === 'rss') {\\n  links = [...body.matchAll(/<link>(.*?)<\\\\/link>/gi)]\\n    .map(m => m[1].trim())\\n    .filter(l => l.startsWith('http'));\\n}\\n\\nif (type === 'html') {\\n  links = [...body.matchAll(/href=[\\"']([^\\"']+)[\\"']/gi)]\\n    .map(m => m[1].trim())\\n    .filter(l => l.startsWith('http'));\\n}\\n\\nreturn links.map(link => ({ source_id, link }));","notice":""},"id":"0939c7e5-5acc-4ae8-a1ca-c9d081a00fb6","name":"Extract Links","type":"n8n-nodes-base.code","typeVersion":2,"position":[160,-64]},{"parameters":{"resource":"database","operation":"executeQuery","query":"INSERT INTO news (source_id, link, processed)\\nSELECT {{$json.source_id}}, '{{$json.link}}', false\\nWHERE NOT EXISTS (SELECT 1 FROM news WHERE link = '{{$json.link}}');","options":{}},"id":"1c42124e-a0d4-405a-818a-5bae71d7b189","name":"Insert News","type":"n8n-nodes-base.postgres","typeVersion":2,"position":[368,-64]}],"connections":{},"settings":{"executionOrder":"v1","binaryMode":"separate"},"staticData":null,"pinData":{}}	[{"version":1,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","pinData":"5","lastNodeExecuted":"6"},{"contextData":"7","nodeExecutionStack":"8","metadata":"9","waitingExecution":"10","waitingExecutionSource":"11","runtimeData":"12"},{"Schedule Trigger":"13"},{},"Schedule Trigger",{},[],{},{},{},{"version":1,"establishedAt":1775119639394,"source":"14","redaction":"15","triggerNode":"16"},["17"],"manual",{"version":1,"policy":"18"},{"name":"6","type":"19"},{"startTime":1775119639408,"executionIndex":0,"source":"20","hints":"21","executionTime":55,"executionStatus":"22","data":"23"},"none","n8n-nodes-base.scheduleTrigger",[],[],"success",{"main":"24"},["25"],["26"],{"json":"27","pairedItem":"28"},{"timestamp":"29","Readable date":"30","Readable time":"31","Day of week":"32","Year":"33","Month":"34","Day of month":"35","Hour":"36","Minute":"37","Second":"38","Timezone":"39"},{"item":0},"2026-04-02T04:47:19.440-04:00","April 2nd 2026, 4:47:19 am","4:47:19 am","Thursday","2026","April","02","04","47","19","America/New_York (UTC-04:00)"]	0e2e7cdd-ca05-4cbc-a102-38b02634471f
2	{"id":"zsdIM77q7kP328Kg","name":"DB Backup to GitHub","active":false,"activeVersionId":null,"isArchived":false,"createdAt":"2026-04-02T08:31:44.204Z","updatedAt":"2026-04-02T12:04:28.161Z","nodes":[{"parameters":{"notice":"","triggerTimes":{"item":[{"mode":"everyDay","hour":14,"minute":0}]}},"id":"c3e56160-f6d3-4a02-a511-c7917fd014ca","name":"Every hour","type":"n8n-nodes-base.cron","typeVersion":1,"position":[-640,-32]},{"parameters":{"authentication":"password","resource":"command","operation":"execute","command":"docker exec postgres pg_dump -U peter AS_news > /tmp/AS_news.sql && base64 /tmp/AS_news.sql","cwd":"/"},"id":"654ac1e5-ea09-45ea-a657-f9d7001ee364","name":"SSH pg_dump","type":"n8n-nodes-base.ssh","typeVersion":1,"position":[-448,-32]},{"parameters":{"curlImport":"","method":"PUT","url":"https://api.github.com/repos/PeternSamodurau/n8n-backups/contents/db/AS_news_{{$now}}.sql","authentication":"none","provideSslCertificates":false,"sendQuery":false,"sendHeaders":false,"sendBody":true,"contentType":"json","specifyBody":"keypair","bodyParameters":{"parameters":[{"name":"","value":""}]},"options":{},"infoMessage":""},"id":"0f26dfb0-32b3-4250-95b2-2c4ca3d6cdf6","name":"GitHub Upload DB","type":"n8n-nodes-base.httpRequest","typeVersion":3,"position":[-144,-32]}],"connections":{"SSH pg_dump":{"main":[[{"node":"GitHub Upload DB","type":"main","index":0}]]}},"settings":{"executionOrder":"v1","binaryMode":"separate"},"staticData":null,"pinData":{}}	[{"version":1,"startData":"1","resultData":"2","executionData":"3"},{},{"runData":"4","pinData":"5","lastNodeExecuted":"6"},{"contextData":"7","nodeExecutionStack":"8","metadata":"9","waitingExecution":"10","waitingExecutionSource":"11","runtimeData":"12"},{"Every hour":"13"},{},"Every hour",{},[],{},{},{},{"version":1,"establishedAt":1775131476136,"source":"14","redaction":"15","triggerNode":"16"},["17"],"manual",{"version":1,"policy":"18"},{"name":"6","type":"19"},{"startTime":1775131476141,"executionIndex":0,"source":"20","hints":"21","executionTime":101,"executionStatus":"22","data":"23"},"none","n8n-nodes-base.cron",[],[],"success",{"main":"24"},["25"],["26"],{"json":"27","pairedItem":"28"},{},{"item":0}]	51b65be3-a742-4b2e-bcfa-6d72ca1e8964
3	{"id":"zsdIM77q7kP328Kg","name":"DB Backup to GitHub","active":false,"activeVersionId":null,"isArchived":false,"createdAt":"2026-04-02T08:31:44.204Z","updatedAt":"2026-04-02T12:05:42.937Z","nodes":[{"parameters":{"notice":"","triggerTimes":{"item":[{"mode":"everyDay","hour":14,"minute":0}]}},"id":"060cbcc5-313c-4277-895a-0b11a5197c10","name":"Every hour","type":"n8n-nodes-base.cron","typeVersion":1,"position":[-576,0]},{"parameters":{"authentication":"password","resource":"command","operation":"execute","command":"docker exec postgres pg_dump -U peter AS_news > /tmp/AS_news.sql && base64 /tmp/AS_news.sql","cwd":"/"},"id":"432b9024-eeb2-4477-8dc0-103ebe322bd0","name":"SSH pg_dump","type":"n8n-nodes-base.ssh","typeVersion":1,"position":[-384,0]},{"parameters":{"curlImport":"","method":"PUT","url":"https://api.github.com/repos/PeternSamodurau/n8n-backups/contents/db/AS_news_{{$now}}.sql","authentication":"none","provideSslCertificates":false,"sendQuery":false,"sendHeaders":false,"sendBody":true,"contentType":"json","specifyBody":"keypair","bodyParameters":{"parameters":[{"name":"","value":""}]},"options":{},"infoMessage":""},"id":"a4d3c3d6-45a6-4195-bdf7-85e038420d74","name":"GitHub Upload DB","type":"n8n-nodes-base.httpRequest","typeVersion":3,"position":[-80,0]}],"connections":{"SSH pg_dump":{"main":[[{"node":"GitHub Upload DB","type":"main","index":0}]]},"Every hour":{"main":[[{"node":"SSH pg_dump","type":"main","index":0}]]}},"settings":{"executionOrder":"v1","binaryMode":"separate"},"staticData":null,"pinData":{}}	[{"version":1,"startData":"1","resultData":"2","executionData":"3"},{},{"error":"4","runData":"5","pinData":"6","lastNodeExecuted":"7"},{"contextData":"8","nodeExecutionStack":"9","metadata":"10","waitingExecution":"11","waitingExecutionSource":"12","runtimeData":"13"},{"level":"14","tags":"15","timestamp":1775131544125,"context":"16","functionality":"17","name":"18","node":"19","messages":"20","message":"21","stack":"22"},{"Every hour":"23","SSH pg_dump":"24"},{},"SSH pg_dump",{},["25"],{},{},{},{"version":1,"establishedAt":1775131544084,"source":"26","redaction":"27","triggerNode":"28"},"warning",{},{},"regular","NodeOperationError",{"parameters":"29","id":"30","name":"7","type":"31","typeVersion":1,"position":"32"},[],"Node does not have any credentials set","NodeOperationError: Node does not have any credentials set\\n    at ExecuteContext._getCredentials (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/n8n-core@file+packages+core_@opentelemetry+api@1.9.0_@opentelemetry+exporter-trace-otlp_9f358c3eeaef0d2736f54ac9757ada43/node_modules/n8n-core/src/execution-engine/node-execution-context/node-execution-context.ts:347:12)\\n    at ExecuteContext.getCredentials (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/n8n-core@file+packages+core_@opentelemetry+api@1.9.0_@opentelemetry+exporter-trace-otlp_9f358c3eeaef0d2736f54ac9757ada43/node_modules/n8n-core/src/execution-engine/node-execution-context/base-execute-context.ts:99:21)\\n    at ExecuteContext.execute (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/n8n-nodes-base@file+packages+nodes-base_@aws-sdk+credential-providers@3.808.0_asn1.js@5_8da18263ca0574b0db58d4fefd8173ce/node_modules/n8n-nodes-base/nodes/Ssh/Ssh.node.ts:344:36)\\n    at WorkflowExecute.executeNode (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/n8n-core@file+packages+core_@opentelemetry+api@1.9.0_@opentelemetry+exporter-trace-otlp_9f358c3eeaef0d2736f54ac9757ada43/node_modules/n8n-core/src/execution-engine/workflow-execute.ts:1043:31)\\n    at WorkflowExecute.runNode (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/n8n-core@file+packages+core_@opentelemetry+api@1.9.0_@opentelemetry+exporter-trace-otlp_9f358c3eeaef0d2736f54ac9757ada43/node_modules/n8n-core/src/execution-engine/workflow-execute.ts:1222:22)\\n    at /usr/local/lib/node_modules/n8n/node_modules/.pnpm/n8n-core@file+packages+core_@opentelemetry+api@1.9.0_@opentelemetry+exporter-trace-otlp_9f358c3eeaef0d2736f54ac9757ada43/node_modules/n8n-core/src/execution-engine/workflow-execute.ts:1668:38\\n    at processTicksAndRejections (node:internal/process/task_queues:103:5)\\n    at /usr/local/lib/node_modules/n8n/node_modules/.pnpm/n8n-core@file+packages+core_@opentelemetry+api@1.9.0_@opentelemetry+exporter-trace-otlp_9f358c3eeaef0d2736f54ac9757ada43/node_modules/n8n-core/src/execution-engine/workflow-execute.ts:2313:11",["33"],["34"],{"node":"19","data":"35","source":"36"},"manual",{"version":1,"policy":"37"},{"name":"38","type":"39"},{"authentication":"40","resource":"41","operation":"42","command":"43","cwd":"44"},"432b9024-eeb2-4477-8dc0-103ebe322bd0","n8n-nodes-base.ssh",[-384,0],{"startTime":1775131544090,"executionIndex":0,"source":"45","hints":"46","executionTime":15,"executionStatus":"47","data":"48"},{"startTime":1775131544111,"executionIndex":1,"source":"49","hints":"50","executionTime":54,"executionStatus":"51","error":"52"},{"main":"53"},{"main":"49"},"none","Every hour","n8n-nodes-base.cron","password","command","execute","docker exec postgres pg_dump -U peter AS_news > /tmp/AS_news.sql && base64 /tmp/AS_news.sql","/",[],[],"success",{"main":"54"},["55"],[],"error",{"level":"14","tags":"15","timestamp":1775131544125,"context":"16","functionality":"17","name":"18","node":"19","messages":"20","message":"21","stack":"22"},["56"],["57"],{"previousNode":"38","previousNodeOutput":0,"previousNodeRun":0},["58"],["59"],{"json":"60","pairedItem":"61"},{"json":"60","pairedItem":"62"},{},{"item":0},{"item":0}]	072a1dc7-3cd2-4285-bdc3-aa312442544a
\.


--
-- Data for Name: execution_entity; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.execution_entity (id, finished, mode, "retryOf", "retrySuccessId", "startedAt", "stoppedAt", "waitTill", status, "workflowId", "deletedAt", "createdAt", "storedAt") FROM stdin;
1	t	manual	\N	\N	2026-04-02 08:47:19.355+00	2026-04-02 08:47:19.467+00	\N	success	3iz9JrDgjvhLOoGC	\N	2026-04-02 08:47:19.271+00	db
2	t	manual	\N	\N	2026-04-02 12:04:36.105+00	2026-04-02 12:04:36.252+00	\N	success	zsdIM77q7kP328Kg	\N	2026-04-02 12:04:36.04+00	db
3	f	manual	\N	\N	2026-04-02 12:05:44.073+00	2026-04-02 12:05:44.168+00	\N	error	zsdIM77q7kP328Kg	\N	2026-04-02 12:05:44.03+00	db
\.


--
-- Data for Name: execution_metadata; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.execution_metadata (id, "executionId", key, value) FROM stdin;
\.


--
-- Data for Name: folder; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.folder (id, name, "parentFolderId", "projectId", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: folder_tag; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.folder_tag ("folderId", "tagId") FROM stdin;
\.


--
-- Data for Name: insights_by_period; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.insights_by_period (id, "metaId", type, value, "periodUnit", "periodStart") FROM stdin;
\.


--
-- Data for Name: insights_metadata; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.insights_metadata ("metaId", "workflowId", "projectId", "workflowName", "projectName") FROM stdin;
\.


--
-- Data for Name: insights_raw; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.insights_raw (id, "metaId", type, value, "timestamp") FROM stdin;
\.


--
-- Data for Name: installed_nodes; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.installed_nodes (name, type, "latestVersion", package) FROM stdin;
\.


--
-- Data for Name: installed_packages; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.installed_packages ("packageName", "installedVersion", "authorName", "authorEmail", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: invalid_auth_token; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.invalid_auth_token (token, "expiresAt") FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.migrations (id, "timestamp", name) FROM stdin;
1	1587669153312	InitialMigration1587669153312
2	1589476000887	WebhookModel1589476000887
3	1594828256133	CreateIndexStoppedAt1594828256133
4	1607431743768	MakeStoppedAtNullable1607431743768
5	1611144599516	AddWebhookId1611144599516
6	1617270242566	CreateTagEntity1617270242566
7	1620824779533	UniqueWorkflowNames1620824779533
8	1626176912946	AddwaitTill1626176912946
9	1630419189837	UpdateWorkflowCredentials1630419189837
10	1644422880309	AddExecutionEntityIndexes1644422880309
11	1646834195327	IncreaseTypeVarcharLimit1646834195327
12	1646992772331	CreateUserManagement1646992772331
13	1648740597343	LowerCaseUserEmail1648740597343
14	1652254514002	CommunityNodes1652254514002
15	1652367743993	AddUserSettings1652367743993
16	1652905585850	AddAPIKeyColumn1652905585850
17	1654090467022	IntroducePinData1654090467022
18	1658932090381	AddNodeIds1658932090381
19	1659902242948	AddJsonKeyPinData1659902242948
20	1660062385367	CreateCredentialsUserRole1660062385367
21	1663755770893	CreateWorkflowsEditorRole1663755770893
22	1664196174001	WorkflowStatistics1664196174001
23	1665484192212	CreateCredentialUsageTable1665484192212
24	1665754637025	RemoveCredentialUsageTable1665754637025
25	1669739707126	AddWorkflowVersionIdColumn1669739707126
26	1669823906995	AddTriggerCountColumn1669823906995
27	1671535397530	MessageEventBusDestinations1671535397530
28	1671726148421	RemoveWorkflowDataLoadedFlag1671726148421
29	1673268682475	DeleteExecutionsWithWorkflows1673268682475
30	1674138566000	AddStatusToExecutions1674138566000
31	1674509946020	CreateLdapEntities1674509946020
32	1675940580449	PurgeInvalidWorkflowConnections1675940580449
33	1676996103000	MigrateExecutionStatus1676996103000
34	1677236854063	UpdateRunningExecutionStatus1677236854063
35	1677501636754	CreateVariables1677501636754
36	1679416281778	CreateExecutionMetadataTable1679416281778
37	1681134145996	AddUserActivatedProperty1681134145996
38	1681134145997	RemoveSkipOwnerSetup1681134145997
39	1690000000000	MigrateIntegerKeysToString1690000000000
40	1690000000020	SeparateExecutionData1690000000020
41	1690000000030	RemoveResetPasswordColumns1690000000030
42	1690000000030	AddMfaColumns1690000000030
43	1690787606731	AddMissingPrimaryKeyOnExecutionData1690787606731
44	1691088862123	CreateWorkflowNameIndex1691088862123
45	1692967111175	CreateWorkflowHistoryTable1692967111175
46	1693491613982	ExecutionSoftDelete1693491613982
47	1693554410387	DisallowOrphanExecutions1693554410387
48	1694091729095	MigrateToTimestampTz1694091729095
49	1695128658538	AddWorkflowMetadata1695128658538
50	1695829275184	ModifyWorkflowHistoryNodesAndConnections1695829275184
51	1700571993961	AddGlobalAdminRole1700571993961
52	1705429061930	DropRoleMapping1705429061930
53	1711018413374	RemoveFailedExecutionStatus1711018413374
54	1711390882123	MoveSshKeysToDatabase1711390882123
55	1712044305787	RemoveNodesAccess1712044305787
56	1714133768519	CreateProject1714133768519
57	1714133768521	MakeExecutionStatusNonNullable1714133768521
58	1717498465931	AddActivatedAtUserSetting1717498465931
59	1720101653148	AddConstraintToExecutionMetadata1720101653148
60	1721377157740	FixExecutionMetadataSequence1721377157740
61	1723627610222	CreateInvalidAuthTokenTable1723627610222
62	1723796243146	RefactorExecutionIndices1723796243146
63	1724753530828	CreateAnnotationTables1724753530828
64	1724951148974	AddApiKeysTable1724951148974
65	1726606152711	CreateProcessedDataTable1726606152711
66	1727427440136	SeparateExecutionCreationFromStart1727427440136
67	1728659839644	AddMissingPrimaryKeyOnAnnotationTagMapping1728659839644
68	1729607673464	UpdateProcessedDataValueColumnToText1729607673464
69	1729607673469	AddProjectIcons1729607673469
70	1730386903556	CreateTestDefinitionTable1730386903556
71	1731404028106	AddDescriptionToTestDefinition1731404028106
72	1731582748663	MigrateTestDefinitionKeyToString1731582748663
73	1732271325258	CreateTestMetricTable1732271325258
74	1732549866705	CreateTestRun1732549866705
75	1733133775640	AddMockedNodesColumnToTestDefinition1733133775640
76	1734479635324	AddManagedColumnToCredentialsTable1734479635324
77	1736172058779	AddStatsColumnsToTestRun1736172058779
78	1736947513045	CreateTestCaseExecutionTable1736947513045
79	1737715421462	AddErrorColumnsToTestRuns1737715421462
80	1738709609940	CreateFolderTable1738709609940
81	1739549398681	CreateAnalyticsTables1739549398681
82	1740445074052	UpdateParentFolderIdColumn1740445074052
83	1741167584277	RenameAnalyticsToInsights1741167584277
84	1742918400000	AddScopesColumnToApiKeys1742918400000
85	1745322634000	ClearEvaluation1745322634000
86	1745587087521	AddWorkflowStatisticsRootCount1745587087521
87	1745934666076	AddWorkflowArchivedColumn1745934666076
88	1745934666077	DropRoleTable1745934666077
89	1747824239000	AddProjectDescriptionColumn1747824239000
90	1750252139166	AddLastActiveAtColumnToUser1750252139166
91	1750252139166	AddScopeTables1750252139166
92	1750252139167	AddRolesTables1750252139167
93	1750252139168	LinkRoleToUserTable1750252139168
94	1750252139170	RemoveOldRoleColumn1750252139170
95	1752669793000	AddInputsOutputsToTestCaseExecution1752669793000
96	1753953244168	LinkRoleToProjectRelationTable1753953244168
97	1754475614601	CreateDataStoreTables1754475614601
98	1754475614602	ReplaceDataStoreTablesWithDataTables1754475614602
99	1756906557570	AddTimestampsToRoleAndRoleIndexes1756906557570
100	1758731786132	AddAudienceColumnToApiKeys1758731786132
101	1758794506893	AddProjectIdToVariableTable1758794506893
102	1759399811000	ChangeValueTypesForInsights1759399811000
103	1760019379982	CreateChatHubTables1760019379982
104	1760020000000	CreateChatHubAgentTable1760020000000
105	1760020838000	UniqueRoleNames1760020838000
106	1760116750277	CreateOAuthEntities1760116750277
107	1760314000000	CreateWorkflowDependencyTable1760314000000
108	1760965142113	DropUnusedChatHubColumns1760965142113
109	1761047826451	AddWorkflowVersionColumn1761047826451
110	1761655473000	ChangeDependencyInfoToJson1761655473000
111	1761773155024	AddAttachmentsToChatHubMessages1761773155024
112	1761830340990	AddToolsColumnToChatHubTables1761830340990
113	1762177736257	AddWorkflowDescriptionColumn1762177736257
114	1762763704614	BackfillMissingWorkflowHistoryRecords1762763704614
115	1762771264000	ChangeDefaultForIdInUserTable1762771264000
116	1762771954619	AddIsGlobalColumnToCredentialsTable1762771954619
117	1762847206508	AddWorkflowHistoryAutoSaveFields1762847206508
118	1763047800000	AddActiveVersionIdColumn1763047800000
119	1763048000000	ActivateExecuteWorkflowTriggerWorkflows1763048000000
120	1763572724000	ChangeOAuthStateColumnToUnboundedVarchar1763572724000
121	1763716655000	CreateBinaryDataTable1763716655000
122	1764167920585	CreateWorkflowPublishHistoryTable1764167920585
123	1764276827837	AddCreatorIdToProjectTable1764276827837
124	1764682447000	CreateDynamicCredentialResolverTable1764682447000
125	1764689388394	AddDynamicCredentialEntryTable1764689388394
126	1765448186933	BackfillMissingWorkflowHistoryRecords1765448186933
127	1765459448000	AddResolvableFieldsToCredentials1765459448000
128	1765788427674	AddIconToAgentTable1765788427674
129	1765804780000	ConvertAgentIdToUuid1765804780000
130	1765886667897	AddAgentIdForeignKeys1765886667897
131	1765892199653	AddWorkflowVersionIdToExecutionData1765892199653
132	1766064542000	AddWorkflowPublishScopeToProjectRoles1766064542000
133	1766068346315	AddChatMessageIndices1766068346315
134	1766500000000	ExpandInsightsWorkflowIdLength1766500000000
135	1767018516000	ChangeWorkflowStatisticsFKToNoAction1767018516000
136	1768402473068	ExpandModelColumnLength1768402473068
137	1768557000000	AddStoredAtToExecutionEntity1768557000000
138	1768901721000	AddDynamicCredentialUserEntryTable1768901721000
139	1769000000000	AddPublishedVersionIdToWorkflowDependency1769000000000
140	1769433700000	CreateSecretsProviderConnectionTables1769433700000
141	1769698710000	CreateWorkflowPublishedVersionTable1769698710000
142	1769784356000	ExpandSubjectIDColumnLength1769784356000
143	1769900001000	AddWorkflowUnpublishScopeToCustomRoles1769900001000
144	1770000000000	CreateChatHubToolsTable1770000000000
145	1770000000000	ExpandProviderIdColumnLength1770000000000
146	1770220686000	CreateWorkflowBuilderSessionTable1770220686000
147	1771417407753	AddScalingFieldsToTestRun1771417407753
148	1771500000000	MigrateExternalSecretsToEntityStorage1771500000000
149	1771500000001	AddUnshareScopeToCustomRoles1771500000001
150	1771500000002	AddFilesColumnToChatHubAgents1771500000002
151	1772000000000	AddSuggestedPromptsToAgentTable1772000000000
152	1772619247761	AddRoleColumnToProjectSecretsProviderAccess1772619247761
153	1772619247762	ChangeWorkflowPublishedVersionFKsToRestrict1772619247762
154	1772700000000	AddTypeToChatHubSessions1772700000000
\.


--
-- Data for Name: oauth_access_tokens; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.oauth_access_tokens (token, "clientId", "userId") FROM stdin;
\.


--
-- Data for Name: oauth_authorization_codes; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.oauth_authorization_codes (code, "clientId", "userId", "redirectUri", "codeChallenge", "codeChallengeMethod", "expiresAt", state, used, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.oauth_clients (id, name, "redirectUris", "grantTypes", "clientSecret", "clientSecretExpiresAt", "tokenEndpointAuthMethod", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: oauth_refresh_tokens; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.oauth_refresh_tokens (token, "clientId", "userId", "expiresAt", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: oauth_user_consents; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.oauth_user_consents (id, "userId", "clientId", "grantedAt") FROM stdin;
\.


--
-- Data for Name: processed_data; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.processed_data ("workflowId", context, "createdAt", "updatedAt", value) FROM stdin;
\.


--
-- Data for Name: project; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.project (id, name, type, "createdAt", "updatedAt", icon, description, "creatorId") FROM stdin;
9Kr1aqOZ27Ze85UD	peter samodurov <spvrent@mail.ru>	personal	2026-04-02 07:46:59.243+00	2026-04-02 07:48:22.36+00	\N	\N	a1f82301-25dd-4e10-ace0-cc0cf1c901f5
\.


--
-- Data for Name: project_relation; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.project_relation ("projectId", "userId", role, "createdAt", "updatedAt") FROM stdin;
9Kr1aqOZ27Ze85UD	a1f82301-25dd-4e10-ace0-cc0cf1c901f5	project:personalOwner	2026-04-02 07:46:59.243+00	2026-04-02 07:46:59.243+00
\.


--
-- Data for Name: project_secrets_provider_access; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.project_secrets_provider_access ("secretsProviderConnectionId", "projectId", "createdAt", "updatedAt", role) FROM stdin;
\.


--
-- Data for Name: region; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.region (id, code) FROM stdin;
1	AS
2	EU
3	US
\.


--
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.role (slug, "displayName", description, "roleType", "systemRole", "createdAt", "updatedAt") FROM stdin;
global:chatUser	Chat User	Chat User	global	t	2026-04-02 07:47:06.766+00	2026-04-02 07:47:06.766+00
global:owner	Owner	Owner	global	t	2026-04-02 07:47:02.247+00	2026-04-02 07:47:07.395+00
global:admin	Admin	Admin	global	t	2026-04-02 07:47:02.247+00	2026-04-02 07:47:07.396+00
global:member	Member	Member	global	t	2026-04-02 07:47:02.247+00	2026-04-02 07:47:07.396+00
project:admin	Project Admin	Full control of settings, members, workflows, credentials and executions	project	t	2026-04-02 07:47:02.247+00	2026-04-02 07:47:07.547+00
project:personalOwner	Project Owner	Project Owner	project	t	2026-04-02 07:47:02.247+00	2026-04-02 07:47:07.547+00
project:editor	Project Editor	Create, edit, and delete workflows, credentials, and executions	project	t	2026-04-02 07:47:02.247+00	2026-04-02 07:47:07.547+00
project:viewer	Project Viewer	Read-only access to workflows, credentials, and executions	project	t	2026-04-02 07:47:02.247+00	2026-04-02 07:47:07.547+00
project:chatUser	Project Chat User	Chat-only access to chatting with workflows that have n8n Chat enabled	project	t	2026-04-02 07:47:02.247+00	2026-04-02 07:47:07.547+00
credential:owner	Credential Owner	Credential Owner	credential	t	2026-04-02 07:47:06.766+00	2026-04-02 07:47:06.766+00
credential:user	Credential User	Credential User	credential	t	2026-04-02 07:47:06.766+00	2026-04-02 07:47:06.766+00
workflow:owner	Workflow Owner	Workflow Owner	workflow	t	2026-04-02 07:47:06.766+00	2026-04-02 07:47:06.766+00
workflow:editor	Workflow Editor	Workflow Editor	workflow	t	2026-04-02 07:47:06.766+00	2026-04-02 07:47:06.766+00
secretsProviderConnection:owner	Secrets Provider Connection Owner	Full control of secrets provider connection settings and secrets	secretsProviderConnection	t	2026-04-02 07:47:06.766+00	2026-04-02 07:47:06.766+00
secretsProviderConnection:user	Secrets Provider Connection User	Read-only access to use secrets from the connection	secretsProviderConnection	t	2026-04-02 07:47:06.766+00	2026-04-02 07:47:06.766+00
\.


--
-- Data for Name: role_scope; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.role_scope ("roleSlug", "scopeSlug") FROM stdin;
global:owner	workflow:unpublish
global:owner	workflow:unshare
global:owner	credential:unshare
global:owner	aiAssistant:manage
global:owner	annotationTag:create
global:owner	annotationTag:read
global:owner	annotationTag:update
global:owner	annotationTag:delete
global:owner	annotationTag:list
global:owner	auditLogs:manage
global:owner	banner:dismiss
global:owner	community:register
global:owner	communityPackage:install
global:owner	communityPackage:uninstall
global:owner	communityPackage:update
global:owner	communityPackage:list
global:owner	credential:share
global:owner	credential:shareGlobally
global:owner	credential:move
global:owner	credential:create
global:owner	credential:read
global:owner	credential:update
global:owner	credential:delete
global:owner	credential:list
global:owner	externalSecretsProvider:sync
global:owner	externalSecretsProvider:create
global:owner	externalSecretsProvider:read
global:owner	externalSecretsProvider:update
global:owner	externalSecretsProvider:delete
global:owner	externalSecretsProvider:list
global:owner	externalSecret:list
global:owner	eventBusDestination:test
global:owner	eventBusDestination:create
global:owner	eventBusDestination:read
global:owner	eventBusDestination:update
global:owner	eventBusDestination:delete
global:owner	eventBusDestination:list
global:owner	ldap:sync
global:owner	ldap:manage
global:owner	license:manage
global:owner	logStreaming:manage
global:owner	orchestration:read
global:owner	project:create
global:owner	project:read
global:owner	project:update
global:owner	project:delete
global:owner	project:list
global:owner	saml:manage
global:owner	securityAudit:generate
global:owner	securitySettings:manage
global:owner	sourceControl:pull
global:owner	sourceControl:push
global:owner	sourceControl:manage
global:owner	tag:create
global:owner	tag:read
global:owner	tag:update
global:owner	tag:delete
global:owner	tag:list
global:owner	user:resetPassword
global:owner	user:changeRole
global:owner	user:enforceMfa
global:owner	user:generateInviteLink
global:owner	user:create
global:owner	user:read
global:owner	user:update
global:owner	user:delete
global:owner	user:list
global:owner	variable:create
global:owner	variable:read
global:owner	variable:update
global:owner	variable:delete
global:owner	variable:list
global:owner	projectVariable:create
global:owner	projectVariable:read
global:owner	projectVariable:update
global:owner	projectVariable:delete
global:owner	projectVariable:list
global:owner	workersView:manage
global:owner	workflow:share
global:owner	workflow:execute
global:owner	workflow:execute-chat
global:owner	workflow:move
global:owner	workflow:updateRedactionSetting
global:owner	workflow:create
global:owner	workflow:read
global:owner	workflow:update
global:owner	workflow:delete
global:owner	workflow:list
global:owner	folder:create
global:owner	folder:read
global:owner	folder:update
global:owner	folder:delete
global:owner	folder:list
global:owner	folder:move
global:owner	insights:list
global:owner	oidc:manage
global:owner	provisioning:manage
global:owner	dataTable:create
global:owner	dataTable:read
global:owner	dataTable:update
global:owner	dataTable:delete
global:owner	dataTable:list
global:owner	dataTable:readRow
global:owner	dataTable:writeRow
global:owner	dataTable:listProject
global:owner	execution:reveal
global:owner	role:manage
global:owner	mcp:manage
global:owner	mcp:oauth
global:owner	mcpApiKey:create
global:owner	mcpApiKey:rotate
global:owner	chatHub:manage
global:owner	chatHub:message
global:owner	chatHubAgent:create
global:owner	chatHubAgent:read
global:owner	chatHubAgent:update
global:owner	chatHubAgent:delete
global:owner	chatHubAgent:list
global:owner	breakingChanges:list
global:owner	apiKey:manage
global:owner	credentialResolver:create
global:owner	credentialResolver:read
global:owner	credentialResolver:update
global:owner	credentialResolver:delete
global:owner	credentialResolver:list
global:owner	workflow:publish
global:admin	workflow:unpublish
global:admin	workflow:unshare
global:admin	credential:unshare
global:admin	aiAssistant:manage
global:admin	annotationTag:create
global:admin	annotationTag:read
global:admin	annotationTag:update
global:admin	annotationTag:delete
global:admin	annotationTag:list
global:admin	auditLogs:manage
global:admin	banner:dismiss
global:admin	community:register
global:admin	communityPackage:install
global:admin	communityPackage:uninstall
global:admin	communityPackage:update
global:admin	communityPackage:list
global:admin	credential:share
global:admin	credential:shareGlobally
global:admin	credential:move
global:admin	credential:create
global:admin	credential:read
global:admin	credential:update
global:admin	credential:delete
global:admin	credential:list
global:admin	externalSecretsProvider:sync
global:admin	externalSecretsProvider:create
global:admin	externalSecretsProvider:read
global:admin	externalSecretsProvider:update
global:admin	externalSecretsProvider:delete
global:admin	externalSecretsProvider:list
global:admin	externalSecret:list
global:admin	eventBusDestination:test
global:admin	eventBusDestination:create
global:admin	eventBusDestination:read
global:admin	eventBusDestination:update
global:admin	eventBusDestination:delete
global:admin	eventBusDestination:list
global:admin	ldap:sync
global:admin	ldap:manage
global:admin	license:manage
global:admin	logStreaming:manage
global:admin	orchestration:read
global:admin	project:create
global:admin	project:read
global:admin	project:update
global:admin	project:delete
global:admin	project:list
global:admin	saml:manage
global:admin	securityAudit:generate
global:admin	securitySettings:manage
global:admin	sourceControl:pull
global:admin	sourceControl:push
global:admin	sourceControl:manage
global:admin	tag:create
global:admin	tag:read
global:admin	tag:update
global:admin	tag:delete
global:admin	tag:list
global:admin	user:resetPassword
global:admin	user:changeRole
global:admin	user:enforceMfa
global:admin	user:generateInviteLink
global:admin	user:create
global:admin	user:read
global:admin	user:update
global:admin	user:delete
global:admin	user:list
global:admin	variable:create
global:admin	variable:read
global:admin	variable:update
global:admin	variable:delete
global:admin	variable:list
global:admin	projectVariable:create
global:admin	projectVariable:read
global:admin	projectVariable:update
global:admin	projectVariable:delete
global:admin	projectVariable:list
global:admin	workersView:manage
global:admin	workflow:share
global:admin	workflow:execute
global:admin	workflow:execute-chat
global:admin	workflow:move
global:admin	workflow:updateRedactionSetting
global:admin	workflow:create
global:admin	workflow:read
global:admin	workflow:update
global:admin	workflow:delete
global:admin	workflow:list
global:admin	folder:create
global:admin	folder:read
global:admin	folder:update
global:admin	folder:delete
global:admin	folder:list
global:admin	folder:move
global:admin	insights:list
global:admin	oidc:manage
global:admin	provisioning:manage
global:admin	dataTable:create
global:admin	dataTable:read
global:admin	dataTable:update
global:admin	dataTable:delete
global:admin	dataTable:list
global:admin	dataTable:readRow
global:admin	dataTable:writeRow
global:admin	dataTable:listProject
global:admin	execution:reveal
global:admin	role:manage
global:admin	mcp:manage
global:admin	mcp:oauth
global:admin	mcpApiKey:create
global:admin	mcpApiKey:rotate
global:admin	chatHub:manage
global:admin	chatHub:message
global:admin	chatHubAgent:create
global:admin	chatHubAgent:read
global:admin	chatHubAgent:update
global:admin	chatHubAgent:delete
global:admin	chatHubAgent:list
global:admin	breakingChanges:list
global:admin	apiKey:manage
global:admin	credentialResolver:create
global:admin	credentialResolver:read
global:admin	credentialResolver:update
global:admin	credentialResolver:delete
global:admin	credentialResolver:list
global:admin	workflow:publish
global:member	annotationTag:create
global:member	annotationTag:read
global:member	annotationTag:update
global:member	annotationTag:delete
global:member	annotationTag:list
global:member	eventBusDestination:test
global:member	eventBusDestination:list
global:member	tag:create
global:member	tag:read
global:member	tag:update
global:member	tag:list
global:member	user:list
global:member	variable:read
global:member	variable:list
global:member	dataTable:list
global:member	mcp:oauth
global:member	mcpApiKey:create
global:member	mcpApiKey:rotate
global:member	chatHub:message
global:member	chatHubAgent:create
global:member	chatHubAgent:read
global:member	chatHubAgent:update
global:member	chatHubAgent:delete
global:member	chatHubAgent:list
global:member	apiKey:manage
global:member	credentialResolver:list
global:chatUser	chatHub:message
global:chatUser	chatHubAgent:create
global:chatUser	chatHubAgent:read
global:chatUser	chatHubAgent:update
global:chatUser	chatHubAgent:delete
global:chatUser	chatHubAgent:list
project:admin	workflow:unpublish
project:admin	credential:unshare
project:admin	credential:share
project:admin	credential:move
project:admin	credential:create
project:admin	credential:read
project:admin	credential:update
project:admin	credential:delete
project:admin	credential:list
project:admin	project:read
project:admin	project:update
project:admin	project:delete
project:admin	project:list
project:admin	sourceControl:push
project:admin	projectVariable:create
project:admin	projectVariable:read
project:admin	projectVariable:update
project:admin	projectVariable:delete
project:admin	projectVariable:list
project:admin	workflow:execute
project:admin	workflow:execute-chat
project:admin	workflow:move
project:admin	workflow:updateRedactionSetting
project:admin	workflow:create
project:admin	workflow:read
project:admin	workflow:update
project:admin	workflow:delete
project:admin	workflow:list
project:admin	folder:create
project:admin	folder:read
project:admin	folder:update
project:admin	folder:delete
project:admin	folder:list
project:admin	folder:move
project:admin	dataTable:create
project:admin	dataTable:read
project:admin	dataTable:update
project:admin	dataTable:delete
project:admin	dataTable:readRow
project:admin	dataTable:writeRow
project:admin	dataTable:listProject
project:admin	execution:reveal
project:admin	workflow:publish
project:personalOwner	workflow:unpublish
project:personalOwner	workflow:unshare
project:personalOwner	credential:unshare
project:personalOwner	credential:share
project:personalOwner	credential:move
project:personalOwner	credential:create
project:personalOwner	credential:read
project:personalOwner	credential:update
project:personalOwner	credential:delete
project:personalOwner	credential:list
project:personalOwner	project:read
project:personalOwner	project:list
project:personalOwner	workflow:share
project:personalOwner	workflow:execute
project:personalOwner	workflow:execute-chat
project:personalOwner	workflow:move
project:personalOwner	workflow:updateRedactionSetting
project:personalOwner	workflow:create
project:personalOwner	workflow:read
project:personalOwner	workflow:update
project:personalOwner	workflow:delete
project:personalOwner	workflow:list
project:personalOwner	folder:create
project:personalOwner	folder:read
project:personalOwner	folder:update
project:personalOwner	folder:delete
project:personalOwner	folder:list
project:personalOwner	folder:move
project:personalOwner	dataTable:create
project:personalOwner	dataTable:read
project:personalOwner	dataTable:update
project:personalOwner	dataTable:delete
project:personalOwner	dataTable:readRow
project:personalOwner	dataTable:writeRow
project:personalOwner	dataTable:listProject
project:personalOwner	execution:reveal
project:personalOwner	workflow:publish
project:editor	workflow:unpublish
project:editor	credential:create
project:editor	credential:read
project:editor	credential:update
project:editor	credential:delete
project:editor	credential:list
project:editor	project:read
project:editor	project:list
project:editor	projectVariable:create
project:editor	projectVariable:read
project:editor	projectVariable:update
project:editor	projectVariable:delete
project:editor	projectVariable:list
project:editor	workflow:execute
project:editor	workflow:execute-chat
project:editor	workflow:create
project:editor	workflow:read
project:editor	workflow:update
project:editor	workflow:delete
project:editor	workflow:list
project:editor	folder:create
project:editor	folder:read
project:editor	folder:update
project:editor	folder:delete
project:editor	folder:list
project:editor	dataTable:create
project:editor	dataTable:read
project:editor	dataTable:update
project:editor	dataTable:delete
project:editor	dataTable:readRow
project:editor	dataTable:writeRow
project:editor	dataTable:listProject
project:editor	workflow:publish
project:viewer	credential:read
project:viewer	credential:list
project:viewer	project:read
project:viewer	project:list
project:viewer	projectVariable:read
project:viewer	projectVariable:list
project:viewer	workflow:execute-chat
project:viewer	workflow:read
project:viewer	workflow:list
project:viewer	folder:read
project:viewer	folder:list
project:viewer	dataTable:read
project:viewer	dataTable:readRow
project:viewer	dataTable:listProject
project:chatUser	workflow:execute-chat
credential:owner	credential:unshare
credential:owner	credential:share
credential:owner	credential:move
credential:owner	credential:read
credential:owner	credential:update
credential:owner	credential:delete
credential:user	credential:read
workflow:owner	workflow:unpublish
workflow:owner	workflow:unshare
workflow:owner	workflow:share
workflow:owner	workflow:execute
workflow:owner	workflow:execute-chat
workflow:owner	workflow:move
workflow:owner	workflow:read
workflow:owner	workflow:update
workflow:owner	workflow:delete
workflow:owner	workflow:publish
workflow:editor	workflow:unpublish
workflow:editor	workflow:execute
workflow:editor	workflow:execute-chat
workflow:editor	workflow:read
workflow:editor	workflow:update
workflow:editor	workflow:publish
secretsProviderConnection:owner	externalSecretsProvider:sync
secretsProviderConnection:owner	externalSecretsProvider:read
secretsProviderConnection:owner	externalSecretsProvider:update
secretsProviderConnection:owner	externalSecretsProvider:delete
secretsProviderConnection:owner	externalSecretsProvider:list
secretsProviderConnection:owner	externalSecret:list
secretsProviderConnection:user	externalSecretsProvider:read
secretsProviderConnection:user	externalSecretsProvider:list
secretsProviderConnection:user	externalSecret:list
\.


--
-- Data for Name: scope; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.scope (slug, "displayName", description) FROM stdin;
workflow:unpublish	Unpublish Workflow	Allows unpublishing workflows.
workflow:unshare	Unshare Workflow	Allows removing workflow shares.
credential:unshare	Unshare Credential	Allows removing credential shares.
aiAssistant:manage	Manage AI Usage	Allows managing AI Usage settings.
aiAssistant:*	aiAssistant:*	\N
annotationTag:create	Create Annotation Tag	Allows creating new annotation tags.
annotationTag:read	annotationTag:read	\N
annotationTag:update	annotationTag:update	\N
annotationTag:delete	annotationTag:delete	\N
annotationTag:list	annotationTag:list	\N
annotationTag:*	annotationTag:*	\N
auditLogs:manage	auditLogs:manage	\N
auditLogs:*	auditLogs:*	\N
banner:dismiss	banner:dismiss	\N
banner:*	banner:*	\N
community:register	community:register	\N
community:*	community:*	\N
communityPackage:install	communityPackage:install	\N
communityPackage:uninstall	communityPackage:uninstall	\N
communityPackage:update	communityPackage:update	\N
communityPackage:list	communityPackage:list	\N
communityPackage:manage	communityPackage:manage	\N
communityPackage:*	communityPackage:*	\N
credential:share	credential:share	\N
credential:shareGlobally	credential:shareGlobally	\N
credential:move	credential:move	\N
credential:create	credential:create	\N
credential:read	credential:read	\N
credential:update	credential:update	\N
credential:delete	credential:delete	\N
credential:list	credential:list	\N
credential:*	credential:*	\N
externalSecretsProvider:sync	externalSecretsProvider:sync	\N
externalSecretsProvider:create	externalSecretsProvider:create	\N
externalSecretsProvider:read	externalSecretsProvider:read	\N
externalSecretsProvider:update	externalSecretsProvider:update	\N
externalSecretsProvider:delete	externalSecretsProvider:delete	\N
externalSecretsProvider:list	externalSecretsProvider:list	\N
externalSecretsProvider:*	externalSecretsProvider:*	\N
externalSecret:list	externalSecret:list	\N
externalSecret:*	externalSecret:*	\N
eventBusDestination:test	eventBusDestination:test	\N
eventBusDestination:create	eventBusDestination:create	\N
eventBusDestination:read	eventBusDestination:read	\N
eventBusDestination:update	eventBusDestination:update	\N
eventBusDestination:delete	eventBusDestination:delete	\N
eventBusDestination:list	eventBusDestination:list	\N
eventBusDestination:*	eventBusDestination:*	\N
ldap:sync	ldap:sync	\N
ldap:manage	ldap:manage	\N
ldap:*	ldap:*	\N
license:manage	license:manage	\N
license:*	license:*	\N
logStreaming:manage	logStreaming:manage	\N
logStreaming:*	logStreaming:*	\N
orchestration:read	orchestration:read	\N
orchestration:list	orchestration:list	\N
orchestration:*	orchestration:*	\N
project:create	project:create	\N
project:read	project:read	\N
project:update	project:update	\N
project:delete	project:delete	\N
project:list	project:list	\N
project:*	project:*	\N
saml:manage	saml:manage	\N
saml:*	saml:*	\N
securityAudit:generate	securityAudit:generate	\N
securityAudit:*	securityAudit:*	\N
securitySettings:manage	securitySettings:manage	\N
securitySettings:*	securitySettings:*	\N
sourceControl:pull	sourceControl:pull	\N
sourceControl:push	sourceControl:push	\N
sourceControl:manage	sourceControl:manage	\N
sourceControl:*	sourceControl:*	\N
tag:create	tag:create	\N
tag:read	tag:read	\N
tag:update	tag:update	\N
tag:delete	tag:delete	\N
tag:list	tag:list	\N
tag:*	tag:*	\N
user:resetPassword	user:resetPassword	\N
user:changeRole	user:changeRole	\N
user:enforceMfa	user:enforceMfa	\N
user:generateInviteLink	user:generateInviteLink	\N
user:create	user:create	\N
user:read	user:read	\N
user:update	user:update	\N
user:delete	user:delete	\N
user:list	user:list	\N
user:*	user:*	\N
variable:create	variable:create	\N
variable:read	variable:read	\N
variable:update	variable:update	\N
variable:delete	variable:delete	\N
variable:list	variable:list	\N
variable:*	variable:*	\N
projectVariable:create	projectVariable:create	\N
projectVariable:read	projectVariable:read	\N
projectVariable:update	projectVariable:update	\N
projectVariable:delete	projectVariable:delete	\N
projectVariable:list	projectVariable:list	\N
projectVariable:*	projectVariable:*	\N
workersView:manage	workersView:manage	\N
workersView:*	workersView:*	\N
workflow:share	workflow:share	\N
workflow:execute	workflow:execute	\N
workflow:execute-chat	workflow:execute-chat	\N
workflow:move	workflow:move	\N
workflow:activate	workflow:activate	\N
workflow:deactivate	workflow:deactivate	\N
workflow:updateRedactionSetting	workflow:updateRedactionSetting	\N
workflow:create	workflow:create	\N
workflow:read	workflow:read	\N
workflow:update	workflow:update	\N
workflow:delete	workflow:delete	\N
workflow:list	workflow:list	\N
workflow:*	workflow:*	\N
folder:create	folder:create	\N
folder:read	folder:read	\N
folder:update	folder:update	\N
folder:delete	folder:delete	\N
folder:list	folder:list	\N
folder:move	folder:move	\N
folder:*	folder:*	\N
insights:list	insights:list	\N
insights:*	insights:*	\N
oidc:manage	oidc:manage	\N
oidc:*	oidc:*	\N
provisioning:manage	provisioning:manage	\N
provisioning:*	provisioning:*	\N
dataTable:create	dataTable:create	\N
dataTable:read	dataTable:read	\N
dataTable:update	dataTable:update	\N
dataTable:delete	dataTable:delete	\N
dataTable:list	dataTable:list	\N
dataTable:readRow	dataTable:readRow	\N
dataTable:writeRow	dataTable:writeRow	\N
dataTable:listProject	dataTable:listProject	\N
dataTable:*	dataTable:*	\N
execution:delete	execution:delete	\N
execution:read	execution:read	\N
execution:retry	execution:retry	\N
execution:list	execution:list	\N
execution:get	execution:get	\N
execution:reveal	execution:reveal	\N
execution:*	execution:*	\N
workflowTags:update	workflowTags:update	\N
workflowTags:list	workflowTags:list	\N
workflowTags:*	workflowTags:*	\N
role:manage	role:manage	\N
role:*	role:*	\N
mcp:manage	mcp:manage	\N
mcp:oauth	mcp:oauth	\N
mcp:*	mcp:*	\N
mcpApiKey:create	mcpApiKey:create	\N
mcpApiKey:rotate	mcpApiKey:rotate	\N
mcpApiKey:*	mcpApiKey:*	\N
chatHub:manage	chatHub:manage	\N
chatHub:message	chatHub:message	\N
chatHub:*	chatHub:*	\N
chatHubAgent:create	chatHubAgent:create	\N
chatHubAgent:read	chatHubAgent:read	\N
chatHubAgent:update	chatHubAgent:update	\N
chatHubAgent:delete	chatHubAgent:delete	\N
chatHubAgent:list	chatHubAgent:list	\N
chatHubAgent:*	chatHubAgent:*	\N
breakingChanges:list	breakingChanges:list	\N
breakingChanges:*	breakingChanges:*	\N
apiKey:manage	apiKey:manage	\N
apiKey:*	apiKey:*	\N
credentialResolver:create	credentialResolver:create	\N
credentialResolver:read	credentialResolver:read	\N
credentialResolver:update	credentialResolver:update	\N
credentialResolver:delete	credentialResolver:delete	\N
credentialResolver:list	credentialResolver:list	\N
credentialResolver:*	credentialResolver:*	\N
*	*	\N
workflow:publish	Publish Workflow	Allows publishing workflows.
\.


--
-- Data for Name: secrets_provider_connection; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.secrets_provider_connection (id, "providerKey", type, "encryptedSettings", "isEnabled", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: settings; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.settings (key, value, "loadOnStartup") FROM stdin;
ui.banners.dismissed	["V1"]	t
features.ldap	{"loginEnabled":false,"loginLabel":"","connectionUrl":"","allowUnauthorizedCerts":false,"connectionSecurity":"none","connectionPort":389,"baseDn":"","bindingAdminDn":"","bindingAdminPassword":"","firstNameAttribute":"","lastNameAttribute":"","emailAttribute":"","loginIdAttribute":"","ldapIdAttribute":"","userFilter":"","synchronizationEnabled":false,"synchronizationInterval":60,"searchPageSize":0,"searchTimeout":60,"enforceEmailUniqueness":true}	t
userManagement.isInstanceOwnerSetUp	true	t
\.


--
-- Data for Name: shared_credentials; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.shared_credentials ("credentialsId", "projectId", role, "createdAt", "updatedAt") FROM stdin;
MWAKq8y3zoMvQl4y	9Kr1aqOZ27Ze85UD	credential:owner	2026-04-02 08:48:09.522+00	2026-04-02 08:48:09.522+00
\.


--
-- Data for Name: shared_workflow; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.shared_workflow ("workflowId", "projectId", role, "createdAt", "updatedAt") FROM stdin;
XHx0wNjTKl0j6e8U	9Kr1aqOZ27Ze85UD	workflow:owner	2026-04-02 08:18:58.555+00	2026-04-02 08:18:58.555+00
zsdIM77q7kP328Kg	9Kr1aqOZ27Ze85UD	workflow:owner	2026-04-02 08:31:44.204+00	2026-04-02 08:31:44.204+00
3iz9JrDgjvhLOoGC	9Kr1aqOZ27Ze85UD	workflow:owner	2026-04-02 08:40:36.569+00	2026-04-02 08:40:36.569+00
\.


--
-- Data for Name: sources; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.sources (id, url, type, active, region_id) FROM stdin;
1	https://www.gold.org/zh-hans/news-and-analysis	web	t	1
2	https://www.kallindex.com/	web	t	1
3	https://www.einpresswire.com/rss/asia-gold	rss	t	1
4	https://news.google.com/rss/search?q=gold+price+asia&hl=en&gl=US&ceid=US:en	rss	t	1
5	https://news.google.com/rss/search?q=gold+demand+asia&hl=en&gl=US&ceid=US:en	rss	t	1
6	https://news.google.com/rss/search?q=china+gold+market&hl=en&gl=US&ceid=US:en	rss	t	1
7	https://news.google.com/rss/search?q=india+gold+price&hl=en&gl=US&ceid=US:en	rss	t	1
8	https://asia.nikkei.com/rss	rss	t	1
9	https://www.scmp.com/rss/91/feed	rss	t	1
10	https://www.japantimes.co.jp/feed/	rss	t	1
11	https://www.koreatimes.co.kr/www/rss/rss.xml	rss	t	1
12	https://news.google.com/rss/search?q=asia+inflation&hl=en&gl=US&ceid=US:en	rss	t	1
13	https://news.google.com/rss/search?q=asia+unemployment&hl=en&gl=US&ceid=US:en	rss	t	1
14	https://news.google.com/rss/search?q=asia+interest+rates&hl=en&gl=US&ceid=US:en	rss	t	1
15	https://news.google.com/rss/search?q=china+economy&hl=en&gl=US&ceid=US:en	rss	t	1
16	https://news.google.com/rss/search?q=japan+economy&hl=en&gl=US&ceid=US:en	rss	t	1
17	https://news.google.com/rss/search?q=india+economy&hl=en&gl=US&ceid=US:en	rss	t	1
18	https://news.google.com/rss/search?q=south+china+sea+tensions&hl=en&gl=US&ceid=US:en	rss	t	1
19	https://news.google.com/rss/search?q=china+us+tensions&hl=en&gl=US&ceid=US:en	rss	t	1
20	https://www.scmp.com/rss/91/feed	rss	t	1
21	https://www.japantimes.co.jp/feed/topstories/	rss	t	1
22	https://www.straitstimes.com/news/world/rss.xml	rss	t	1
23	https://www.koreatimes.co.kr/www/rss/nation.xml	rss	t	1
24	https://www.aljazeera.com/xml/rss/all.xml	rss	t	1
25	https://www.channelnewsasia.com/api/v1/rss-outbound-feed?_format=xml	rss	t	1
26	https://www.bangkokpost.com/rss/data/topstories.xml	rss	t	1
27	https://www.hindustantimes.com/feeds/rss/world-news/rssfeed.xml	rss	t	1
28	https://timesofindia.indiatimes.com/rssfeeds/296589292.cms	rss	t	1
29	https://www.thehindu.com/news/international/feeder/default.rss	rss	t	1
30	https://www.manilatimes.net/feed/	rss	t	1
31	https://www.dawn.com/rss	rss	t	1
32	https://www.thenews.com.pk/rss/1/1	rss	t	1
33	https://www.arabnews.com/rss.xml	rss	t	1
34	https://english.alarabiya.net/.mrss/en.xml	rss	t	1
35	https://www.scmp.com	web	t	1
36	https://www.japantimes.co.jp	web	t	1
37	https://www.straitstimes.com	web	t	1
38	https://www.koreatimes.co.kr	web	t	1
39	https://www.aljazeera.com	web	t	1
40	https://www.channelnewsasia.com	web	t	1
41	https://www.bangkokpost.com	web	t	1
42	https://www.hindustantimes.com	web	t	1
43	https://timesofindia.indiatimes.com	web	t	1
44	https://www.thehindu.com	web	t	1
45	https://www.manilatimes.net	web	t	1
46	https://www.dawn.com	web	t	1
47	https://www.thenews.com.pk	web	t	1
48	https://www.arabnews.com	web	t	1
49	https://english.alarabiya.net	web	t	1
50	https://news.google.com/rss/topics/CAAqJggKIiBDQkFTRWdvSUwyMHZNRGx1YlY4U0FtVnVHZ0pWVXlnQVAB?hl=en&gl=US&ceid=US:en	rss	t	1
51	https://news.google.com/rss/search?q=Japan&hl=en&gl=US&ceid=US:en	rss	t	1
52	https://news.google.com/rss/search?q=China&hl=en&gl=US&ceid=US:en	rss	t	1
53	https://news.google.com/rss/search?q=India&hl=en&gl=US&ceid=US:en	rss	t	1
54	https://news.google.com/rss/search?q=Middle+East&hl=en&gl=US&ceid=US:en	rss	t	1
\.


--
-- Data for Name: tag_entity; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.tag_entity (name, "createdAt", "updatedAt", id) FROM stdin;
\.


--
-- Data for Name: test_case_execution; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.test_case_execution (id, "testRunId", "executionId", status, "runAt", "completedAt", "errorCode", "errorDetails", metrics, "createdAt", "updatedAt", inputs, outputs) FROM stdin;
\.


--
-- Data for Name: test_run; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.test_run (id, "workflowId", status, "errorCode", "errorDetails", "runAt", "completedAt", metrics, "createdAt", "updatedAt", "runningInstanceId", "cancelRequested") FROM stdin;
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public."user" (id, email, "firstName", "lastName", password, "personalizationAnswers", "createdAt", "updatedAt", settings, disabled, "mfaEnabled", "mfaSecret", "mfaRecoveryCodes", "lastActiveAt", "roleSlug") FROM stdin;
a1f82301-25dd-4e10-ace0-cc0cf1c901f5	spvrent@mail.ru	peter	samodurov	$2a$10$XnHx/wlGNBS.wHVTVNxores784hzWy8xXenxdh1oF/H6psOQ.lUSm	{"version":"v4","personalization_survey_submitted_at":"2026-04-02T07:48:29.056Z","personalization_survey_n8n_version":"2.13.4"}	2026-04-02 07:46:56.031+00	2026-04-02 12:25:56.108+00	{"userActivated": false}	f	f	\N	\N	2026-04-02	global:owner
\.


--
-- Data for Name: user_api_keys; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.user_api_keys (id, "userId", label, "apiKey", "createdAt", "updatedAt", scopes, audience) FROM stdin;
Sx3JDSFfQW2NL7Fz	a1f82301-25dd-4e10-ace0-cc0cf1c901f5	Backup API Key	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMWY4MjMwMS0yNWRkLTRlMTAtYWNlMC1jYzBjZjFjOTAxZjUiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwianRpIjoiOWM4Y2NlYzctZTVmYy00OGJhLWFjZTctY2E0MGFmMThlN2YyIiwiaWF0IjoxNzc1MTE4NTQ3fQ.FrJIZCMCos_wbG_PcvZ1L_i3zNQBMawPnTPqCMd7l6c	2026-04-02 08:29:07.55+00	2026-04-02 08:29:07.55+00	["credential:move","credential:create","credential:update","credential:delete","credential:list","project:create","project:update","project:delete","project:list","securityAudit:generate","sourceControl:pull","tag:create","tag:read","tag:update","tag:delete","tag:list","user:changeRole","user:enforceMfa","user:create","user:read","user:delete","user:list","variable:create","variable:update","variable:delete","variable:list","workflow:move","workflow:create","workflow:read","workflow:update","workflow:delete","workflow:list","dataTable:create","dataTable:read","dataTable:update","dataTable:delete","dataTable:list","workflowTags:update","workflowTags:list","executionTags:update","executionTags:list","workflow:activate","workflow:deactivate","execution:delete","execution:read","execution:retry","execution:stop","execution:list","dataTableRow:create","dataTableRow:read","dataTableRow:update","dataTableRow:delete","dataTableRow:upsert"]	public-api
\.


--
-- Data for Name: variables; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.variables (key, type, value, id, "projectId") FROM stdin;
\.


--
-- Data for Name: webhook_entity; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.webhook_entity ("webhookPath", method, node, "webhookId", "pathLength", "workflowId") FROM stdin;
\.


--
-- Data for Name: workflow_builder_session; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.workflow_builder_session (id, "workflowId", "userId", messages, "previousSummary", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: workflow_dependency; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.workflow_dependency (id, "workflowId", "workflowVersionId", "dependencyType", "dependencyKey", "dependencyInfo", "indexVersionId", "createdAt", "publishedVersionId") FROM stdin;
56	XHx0wNjTKl0j6e8U	2	nodeType	n8n-nodes-base.scheduleTrigger	{"nodeId":"de0aa6f5-3d8f-48dc-b672-e3d0dede9271","nodeVersion":1.3}	1	2026-04-02 09:14:11.328+00	\N
57	XHx0wNjTKl0j6e8U	2	nodeType	n8n-nodes-base.postgres	{"nodeId":"4cc41004-5df8-4876-9afb-f4a1968b1ed7","nodeVersion":2.6}	1	2026-04-02 09:14:11.328+00	\N
58	XHx0wNjTKl0j6e8U	2	credentialId	MWAKq8y3zoMvQl4y	{"nodeId":"4cc41004-5df8-4876-9afb-f4a1968b1ed7","nodeVersion":2.6}	1	2026-04-02 09:14:11.328+00	\N
59	XHx0wNjTKl0j6e8U	2	nodeType	n8n-nodes-base.splitInBatches	{"nodeId":"d9e133ff-f451-4ad7-8f88-c86f1dd6e795","nodeVersion":3}	1	2026-04-02 09:14:11.328+00	\N
60	XHx0wNjTKl0j6e8U	2	nodeType	n8n-nodes-base.httpRequest	{"nodeId":"fd33760e-5480-4b78-bb8e-bd898f5e6f8b","nodeVersion":4.4}	1	2026-04-02 09:14:11.328+00	\N
61	XHx0wNjTKl0j6e8U	2	nodeType	n8n-nodes-base.code	{"nodeId":"857f0bfb-b058-48a8-8bed-e320c5ed7488","nodeVersion":2}	1	2026-04-02 09:14:11.328+00	\N
62	XHx0wNjTKl0j6e8U	2	nodeType	n8n-nodes-base.switch	{"nodeId":"660ff7d0-dac3-4a70-bbff-1c30c4c86458","nodeVersion":3.4}	1	2026-04-02 09:14:11.328+00	\N
63	XHx0wNjTKl0j6e8U	2	nodeType	n8n-nodes-base.code	{"nodeId":"d5efdacb-67f9-41e1-a019-e8958f84561b","nodeVersion":2}	1	2026-04-02 09:14:11.328+00	\N
64	XHx0wNjTKl0j6e8U	2	nodeType	n8n-nodes-base.code	{"nodeId":"17918734-398d-41a4-a828-7c3bfc886c03","nodeVersion":2}	1	2026-04-02 09:14:11.328+00	\N
65	XHx0wNjTKl0j6e8U	2	nodeType	n8n-nodes-base.html	{"nodeId":"f19de0e9-9371-44a3-81dd-223464d429f2","nodeVersion":1.2}	1	2026-04-02 09:14:11.328+00	\N
66	XHx0wNjTKl0j6e8U	2	nodeType	n8n-nodes-base.httpRequest	{"nodeId":"4f7c2b83-a4ce-49bd-9724-a626457466d3","nodeVersion":4.4}	1	2026-04-02 09:14:11.328+00	\N
67	3iz9JrDgjvhLOoGC	6	nodeType	n8n-nodes-base.scheduleTrigger	{"nodeId":"f06f19ca-148d-40ec-87a9-4866fda1ba1c","nodeVersion":1}	1	2026-04-02 09:14:42.784+00	\N
68	3iz9JrDgjvhLOoGC	6	nodeType	n8n-nodes-base.postgres	{"nodeId":"2ec8f6bb-88e9-4802-bed0-9d757a34f418","nodeVersion":2}	1	2026-04-02 09:14:42.784+00	\N
69	3iz9JrDgjvhLOoGC	6	credentialId	MWAKq8y3zoMvQl4y	{"nodeId":"2ec8f6bb-88e9-4802-bed0-9d757a34f418","nodeVersion":2}	1	2026-04-02 09:14:42.784+00	\N
70	3iz9JrDgjvhLOoGC	6	nodeType	n8n-nodes-base.splitInBatches	{"nodeId":"9a85cae3-50f0-4f0a-b380-4642bb4e3687","nodeVersion":3}	1	2026-04-02 09:14:42.784+00	\N
71	3iz9JrDgjvhLOoGC	6	nodeType	n8n-nodes-base.httpRequest	{"nodeId":"04c672ac-36dc-4fe5-894f-ee1e56c17b61","nodeVersion":4}	1	2026-04-02 09:14:42.784+00	\N
72	3iz9JrDgjvhLOoGC	6	nodeType	n8n-nodes-base.code	{"nodeId":"0939c7e5-5acc-4ae8-a1ca-c9d081a00fb6","nodeVersion":2}	1	2026-04-02 09:14:42.784+00	\N
73	3iz9JrDgjvhLOoGC	6	nodeType	n8n-nodes-base.postgres	{"nodeId":"1c42124e-a0d4-405a-818a-5bae71d7b189","nodeVersion":2}	1	2026-04-02 09:14:42.784+00	\N
74	3iz9JrDgjvhLOoGC	6	credentialId	MWAKq8y3zoMvQl4y	{"nodeId":"1c42124e-a0d4-405a-818a-5bae71d7b189","nodeVersion":2}	1	2026-04-02 09:14:42.784+00	\N
104	zsdIM77q7kP328Kg	17	nodeType	n8n-nodes-base.cron	{"nodeId":"ffe232cf-b77a-46bf-8f54-8ddd5f9a89c3","nodeVersion":1}	1	2026-04-02 12:29:41.26+00	\N
105	zsdIM77q7kP328Kg	17	nodeType	n8n-nodes-base.executeCommand	{"nodeId":"50c29f56-9992-4a0c-b85c-5415dfa02620","nodeVersion":1}	1	2026-04-02 12:29:41.26+00	\N
106	zsdIM77q7kP328Kg	17	nodeType	n8n-nodes-base.httpRequest	{"nodeId":"a1b44f0c-ba6b-4152-b949-9243d91719c0","nodeVersion":3}	1	2026-04-02 12:29:41.26+00	\N
\.


--
-- Data for Name: workflow_entity; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.workflow_entity (name, active, nodes, connections, "createdAt", "updatedAt", settings, "staticData", "pinData", "versionId", "triggerCount", id, meta, "parentFolderId", "isArchived", "versionCounter", description, "activeVersionId") FROM stdin;
AS_news_analysis	f	[{"parameters":{"rule":{"interval":[{"field":"minutes"}]}},"type":"n8n-nodes-base.scheduleTrigger","typeVersion":1.3,"position":[-976,128],"id":"de0aa6f5-3d8f-48dc-b672-e3d0dede9271","name":"Schedule Trigger"},{"parameters":{"operation":"executeQuery","query":"SELECT id, link\\nFROM news\\nWHERE processed = false\\nORDER BY id ASC\\nLIMIT 50;\\n","options":{}},"type":"n8n-nodes-base.postgres","typeVersion":2.6,"position":[-832,128],"id":"4cc41004-5df8-4876-9afb-f4a1968b1ed7","name":"Execute a SQL query","credentials":{"postgres":{"id":"MWAKq8y3zoMvQl4y","name":"Postgres account"}}},{"parameters":{"options":{}},"type":"n8n-nodes-base.splitInBatches","typeVersion":3,"position":[-640,128],"id":"d9e133ff-f451-4ad7-8f88-c86f1dd6e795","name":"Loop Over Items"},{"parameters":{"url":"={{ $json[\\"link\\"] }}\\n","options":{"redirect":{"redirect":{}},"response":{"response":{"responseFormat":"text","outputPropertyName":"body"}}}},"type":"n8n-nodes-base.httpRequest","typeVersion":4.4,"position":[224,240],"id":"fd33760e-5480-4b78-bb8e-bd898f5e6f8b","name":"HTTP Request"},{"parameters":{"mode":"runOnceForEachItem","jsCode":"const { id, link } = $input.item.json;\\n\\nlet sourceType = 'web'; // по умолчанию считаем, что это обычная web-страница\\n\\nif (link.includes('news.google.com/rss/articles')) {\\n  sourceType = 'google_news';\\n}\\n\\nreturn {\\n  id,\\n  link,\\n  sourceType\\n};\\n"},"type":"n8n-nodes-base.code","typeVersion":2,"position":[-416,128],"id":"857f0bfb-b058-48a8-8bed-e320c5ed7488","name":"Code in JavaScript1"},{"parameters":{"rules":{"values":[{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict","version":3},"conditions":[{"leftValue":"={{ $json.sourceType }}\\n","rightValue":"google_news","operator":{"type":"string","operation":"contains"},"id":"621bcd6c-6bfd-4cee-820f-21328fa70159"}],"combinator":"and"}},{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict","version":3},"conditions":[{"id":"029151ac-2705-41e9-9e5a-951f257f4a89","leftValue":"={{ $json.sourceType }}\\n","rightValue":"web","operator":{"type":"string","operation":"contains"}}],"combinator":"and"}}]},"options":{}},"type":"n8n-nodes-base.switch","typeVersion":3.4,"position":[-208,128],"id":"660ff7d0-dac3-4a70-bbff-1c30c4c86458","name":"Switch"},{"parameters":{"jsCode":"// Loop over input items and add a new field called 'myNewField' to the JSON of each one\\nfor (const item of $input.all()) {\\n  item.json.myNewField = 1;\\n}\\n\\nreturn $input.all();"},"type":"n8n-nodes-base.code","typeVersion":2,"position":[0,240],"id":"d5efdacb-67f9-41e1-a019-e8958f84561b","name":"Web"},{"parameters":{"jsCode":"// Loop over input items and add a new field called 'myNewField' to the JSON of each one\\nfor (const item of $input.all()) {\\n  item.json.myNewField = 1;\\n}\\n\\nreturn $input.all();"},"type":"n8n-nodes-base.code","typeVersion":2,"position":[0,0],"id":"17918734-398d-41a4-a828-7c3bfc886c03","name":"Rss"},{"parameters":{"operation":"extractHtmlContent","dataPropertyName":"body","extractionValues":{"values":[{"key":"content","cssSelector":"article, [role=\\"main\\"], .post-content, .entry-content, .article-content, .story-content, .story-body, .article-body, .content, .main-content","skipSelectors":".comments, .sidebar, .related, .recommendations, .newsletter, .advertisement, .social-share, .meta, .footer, header, nav, .widget, .also-read, .more-news, .editor-picks"}]},"options":{}},"type":"n8n-nodes-base.html","typeVersion":1.2,"position":[432,240],"id":"f19de0e9-9371-44a3-81dd-223464d429f2","name":"HTML"},{"parameters":{"method":"POST","url":"http://host.docker.internal:11434/v1/chat/completions","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Content-Type","value":"application/json"}]},"sendBody":true,"specifyBody":"json","jsonBody":"={\\n  \\"model\\": \\"granite3.1-moe:1b\\",\\n  \\"messages\\": [\\n    {\\n      \\"role\\": \\"system\\",\\n      \\"content\\": \\"Ты переводчик. Переведи следующий текст на русский язык. Верни только переведённый текст, без комментариев и пояснений.\\"\\n    },\\n    {\\n      \\"role\\": \\"user\\",\\n      \\"content\\": {{ JSON.stringify($json.content) }}\\n    }\\n  ],\\n  \\"temperature\\": 0.3\\n}","options":{}},"type":"n8n-nodes-base.httpRequest","typeVersion":4.4,"position":[192,480],"id":"4f7c2b83-a4ce-49bd-9724-a626457466d3","name":"Call Ollama"}]	{"Schedule Trigger":{"main":[[{"node":"Execute a SQL query","type":"main","index":0}]]},"Loop Over Items":{"main":[[{"node":"Code in JavaScript1","type":"main","index":0}],[{"node":"Loop Over Items","type":"main","index":0}]]},"Execute a SQL query":{"main":[[{"node":"Loop Over Items","type":"main","index":0}]]},"HTTP Request":{"main":[[{"node":"HTML","type":"main","index":0}]]},"Code in JavaScript1":{"main":[[{"node":"Switch","type":"main","index":0}]]},"Switch":{"main":[[{"node":"Rss","type":"main","index":0}],[{"node":"Web","type":"main","index":0}]]},"Web":{"main":[[{"node":"HTTP Request","type":"main","index":0}]]}}	2026-04-02 08:18:58.555+00	2026-04-02 09:14:11.067+00	{"executionOrder":"v1","binaryMode":"separate"}	\N	{}	8a9a437a-e070-404a-ac52-bab3fc50b78a	0	XHx0wNjTKl0j6e8U	{"templateCredsSetupCompleted":true}	\N	f	2	\N	\N
AS_news	f	[{"parameters":{"rule":{"interval":[{"field":"minutes","minutesInterval":10}]}},"id":"f06f19ca-148d-40ec-87a9-4866fda1ba1c","name":"Schedule Trigger","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[-640,-64]},{"parameters":{"operation":"executeQuery","query":"SELECT id, url, type FROM sources WHERE active = true;","options":{}},"id":"2ec8f6bb-88e9-4802-bed0-9d757a34f418","name":"Select Sources","type":"n8n-nodes-base.postgres","typeVersion":2,"position":[-448,-64],"credentials":{"postgres":{"id":"MWAKq8y3zoMvQl4y","name":"Postgres account"}}},{"parameters":{"options":{}},"id":"9a85cae3-50f0-4f0a-b380-4642bb4e3687","name":"Split in Batches","type":"n8n-nodes-base.splitInBatches","typeVersion":3,"position":[-240,-64]},{"parameters":{"url":"={{ $json.url }}","options":{"response":{}}},"id":"04c672ac-36dc-4fe5-894f-ee1e56c17b61","name":"Fetch Source","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[-48,-64]},{"parameters":{"mode":"runOnceForEachItem","jsCode":"let { id: source_id, url, type } = $json;\\nlet body = $json.body || '';\\nlet links = [];\\n\\nif (type === 'rss') {\\n  links = [...body.matchAll(/<link>(.*?)<\\\\/link>/gi)]\\n    .map(m => m[1].trim())\\n    .filter(l => l.startsWith('http'));\\n}\\n\\nif (type === 'html') {\\n  links = [...body.matchAll(/href=[\\"']([^\\"']+)[\\"']/gi)]\\n    .map(m => m[1].trim())\\n    .filter(l => l.startsWith('http'));\\n}\\n\\nreturn links.map(link => ({ source_id, link }));"},"id":"0939c7e5-5acc-4ae8-a1ca-c9d081a00fb6","name":"Extract Links","type":"n8n-nodes-base.code","typeVersion":2,"position":[160,-64]},{"parameters":{"operation":"executeQuery","query":"INSERT INTO news (source_id, link, processed)\\nSELECT {{$json.source_id}}, '{{$json.link}}', false\\nWHERE NOT EXISTS (SELECT 1 FROM news WHERE link = '{{$json.link}}');","options":{}},"id":"1c42124e-a0d4-405a-818a-5bae71d7b189","name":"Insert News","type":"n8n-nodes-base.postgres","typeVersion":2,"position":[368,-64],"credentials":{"postgres":{"id":"MWAKq8y3zoMvQl4y","name":"Postgres account"}}}]	{}	2026-04-02 08:40:36.569+00	2026-04-02 09:14:42.734+00	{"executionOrder":"v1","binaryMode":"separate"}	\N	{}	eff75c03-0a23-41f3-adbd-e37d18c9c515	0	3iz9JrDgjvhLOoGC	{"templateCredsSetupCompleted":true}	\N	f	6	\N	\N
DB Backup to GitHub	f	[{"parameters":{"triggerTimes":{"item":[{}]}},"id":"ffe232cf-b77a-46bf-8f54-8ddd5f9a89c3","name":"Every hour","type":"n8n-nodes-base.cron","typeVersion":1,"position":[-656,112]},{"parameters":{"command":"docker exec postgres pg_dump -U peter AS_news"},"id":"50c29f56-9992-4a0c-b85c-5415dfa02620","name":"pg_dump inside postgres","type":"n8n-nodes-base.executeCommand","typeVersion":1,"position":[-400,112]},{"parameters":{"method":"PUT","url":"https://api.github.com/repos/PeternSamodurau/n8n-backups/contents/db/AS_news_{{$now}}.sql","sendBody":true,"bodyParameters":{"parameters":[{}]},"options":{}},"id":"a1b44f0c-ba6b-4152-b949-9243d91719c0","name":"GitHub Upload DB","type":"n8n-nodes-base.httpRequest","typeVersion":3,"position":[-112,112]}]	{}	2026-04-02 08:31:44.204+00	2026-04-02 12:29:41.229+00	{"executionOrder":"v1","binaryMode":"separate"}	\N	{}	bac655a3-88d3-4d1b-852c-515d1909dbb4	0	zsdIM77q7kP328Kg	{"templateCredsSetupCompleted":true}	\N	f	17	\N	\N
\.


--
-- Data for Name: workflow_history; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.workflow_history ("versionId", "workflowId", authors, "createdAt", "updatedAt", nodes, connections, name, autosaved, description) FROM stdin;
5a3d1c67-c16c-48b5-b0a8-14aa46e58685	XHx0wNjTKl0j6e8U	peter samodurov	2026-04-02 08:18:58.555+00	2026-04-02 08:18:58.555+00	[{"parameters":{"rule":{"interval":[{"field":"minutes"}]}},"type":"n8n-nodes-base.scheduleTrigger","typeVersion":1.3,"position":[-976,128],"id":"de0aa6f5-3d8f-48dc-b672-e3d0dede9271","name":"Schedule Trigger"},{"parameters":{"operation":"executeQuery","query":"SELECT id, link\\nFROM news\\nWHERE processed = false\\nORDER BY id ASC\\nLIMIT 50;\\n","options":{}},"type":"n8n-nodes-base.postgres","typeVersion":2.6,"position":[-832,128],"id":"4cc41004-5df8-4876-9afb-f4a1968b1ed7","name":"Execute a SQL query"},{"parameters":{"options":{}},"type":"n8n-nodes-base.splitInBatches","typeVersion":3,"position":[-640,128],"id":"d9e133ff-f451-4ad7-8f88-c86f1dd6e795","name":"Loop Over Items"},{"parameters":{"url":"={{ $json[\\"link\\"] }}\\n","options":{"redirect":{"redirect":{}},"response":{"response":{"responseFormat":"text","outputPropertyName":"body"}}}},"type":"n8n-nodes-base.httpRequest","typeVersion":4.4,"position":[224,240],"id":"fd33760e-5480-4b78-bb8e-bd898f5e6f8b","name":"HTTP Request"},{"parameters":{"mode":"runOnceForEachItem","jsCode":"const { id, link } = $input.item.json;\\n\\nlet sourceType = 'web'; // по умолчанию считаем, что это обычная web-страница\\n\\nif (link.includes('news.google.com/rss/articles')) {\\n  sourceType = 'google_news';\\n}\\n\\nreturn {\\n  id,\\n  link,\\n  sourceType\\n};\\n"},"type":"n8n-nodes-base.code","typeVersion":2,"position":[-416,128],"id":"857f0bfb-b058-48a8-8bed-e320c5ed7488","name":"Code in JavaScript1"},{"parameters":{"rules":{"values":[{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict","version":3},"conditions":[{"leftValue":"={{ $json.sourceType }}\\n","rightValue":"google_news","operator":{"type":"string","operation":"contains"},"id":"621bcd6c-6bfd-4cee-820f-21328fa70159"}],"combinator":"and"}},{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict","version":3},"conditions":[{"id":"029151ac-2705-41e9-9e5a-951f257f4a89","leftValue":"={{ $json.sourceType }}\\n","rightValue":"web","operator":{"type":"string","operation":"contains"}}],"combinator":"and"}}]},"options":{}},"type":"n8n-nodes-base.switch","typeVersion":3.4,"position":[-208,128],"id":"660ff7d0-dac3-4a70-bbff-1c30c4c86458","name":"Switch"},{"parameters":{"jsCode":"// Loop over input items and add a new field called 'myNewField' to the JSON of each one\\nfor (const item of $input.all()) {\\n  item.json.myNewField = 1;\\n}\\n\\nreturn $input.all();"},"type":"n8n-nodes-base.code","typeVersion":2,"position":[0,240],"id":"d5efdacb-67f9-41e1-a019-e8958f84561b","name":"Web"},{"parameters":{"jsCode":"// Loop over input items and add a new field called 'myNewField' to the JSON of each one\\nfor (const item of $input.all()) {\\n  item.json.myNewField = 1;\\n}\\n\\nreturn $input.all();"},"type":"n8n-nodes-base.code","typeVersion":2,"position":[0,0],"id":"17918734-398d-41a4-a828-7c3bfc886c03","name":"Rss"},{"parameters":{"operation":"extractHtmlContent","dataPropertyName":"body","extractionValues":{"values":[{"key":"content","cssSelector":"article, [role=\\"main\\"], .post-content, .entry-content, .article-content, .story-content, .story-body, .article-body, .content, .main-content","skipSelectors":".comments, .sidebar, .related, .recommendations, .newsletter, .advertisement, .social-share, .meta, .footer, header, nav, .widget, .also-read, .more-news, .editor-picks"}]},"options":{}},"type":"n8n-nodes-base.html","typeVersion":1.2,"position":[432,240],"id":"f19de0e9-9371-44a3-81dd-223464d429f2","name":"HTML"},{"parameters":{"method":"POST","url":"http://host.docker.internal:11434/v1/chat/completions","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Content-Type","value":"application/json"}]},"sendBody":true,"specifyBody":"json","jsonBody":"={\\n  \\"model\\": \\"granite3.1-moe:1b\\",\\n  \\"messages\\": [\\n    {\\n      \\"role\\": \\"system\\",\\n      \\"content\\": \\"Ты переводчик. Переведи следующий текст на русский язык. Верни только переведённый текст, без комментариев и пояснений.\\"\\n    },\\n    {\\n      \\"role\\": \\"user\\",\\n      \\"content\\": {{ JSON.stringify($json.content) }}\\n    }\\n  ],\\n  \\"temperature\\": 0.3\\n}","options":{}},"type":"n8n-nodes-base.httpRequest","typeVersion":4.4,"position":[192,480],"id":"4f7c2b83-a4ce-49bd-9724-a626457466d3","name":"Call Ollama"}]	{"Schedule Trigger":{"main":[[{"node":"Execute a SQL query","type":"main","index":0}]]},"Loop Over Items":{"main":[[{"node":"Code in JavaScript1","type":"main","index":0}],[{"node":"Loop Over Items","type":"main","index":0}]]},"Execute a SQL query":{"main":[[{"node":"Loop Over Items","type":"main","index":0}]]},"HTTP Request":{"main":[[{"node":"HTML","type":"main","index":0}]]},"Code in JavaScript1":{"main":[[{"node":"Switch","type":"main","index":0}]]},"Switch":{"main":[[{"node":"Rss","type":"main","index":0}],[{"node":"Web","type":"main","index":0}]]},"Web":{"main":[[{"node":"HTTP Request","type":"main","index":0}]]}}	\N	t	\N
71f5d4d4-4ab7-4ca4-ae4b-c441aae9bcdb	zsdIM77q7kP328Kg	peter samodurov	2026-04-02 08:32:16.195+00	2026-04-02 08:32:16.195+00	[{"parameters":{"rule":{"interval":[{}]}},"id":"bb1bd90f-83b5-454a-bd96-867cce01b746","name":"Запуск раз в день","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1.1,"position":[-576,128]},{"parameters":{"url":"http://host.docker.internal:5678/api/v1/workflows","sendHeaders":true,"headerParameters":{"parameters":[{"name":"X-N8N-API-KEY","value":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMWY4MjMwMS0yNWRkLTRlMTAtYWNlMC1jYzBjZjFjOTAxZjUiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwianRpIjoiOWM4Y2NlYzctZTVmYy00OGJhLWFjZTctY2E0MGFmMThlN2YyIiwiaWF0IjoxNzc1MTE4NTQ3fQ.FrJIZCMCos_wbG_PcvZ1L_i3zNQBMawPnTPqCMd7l6c"}]},"options":{}},"id":"2a990eaa-57d7-42f2-a877-36bebea0f451","name":"Получить список всех Workflow","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[-384,128]},{"parameters":{"options":{}},"id":"7a3d9774-e3bf-4495-85f7-032f19e7b9d5","name":"Извлечь данные из ответа","type":"n8n-nodes-base.extractFromFile","typeVersion":1,"position":[-176,128]},{"parameters":{"batchSize":10,"options":{}},"id":"2aa8a944-1fea-4f07-9261-9728418c697c","name":"Loop Over Items","type":"n8n-nodes-base.splitInBatches","typeVersion":3,"position":[32,128]},{"parameters":{"mode":"file","filePath":"/home/node/.n8n/backups/","fileName":"={{ $json.name }}.json","fileContent":"={{ JSON.stringify($json, null, 2) }}","createFolderIfNotExists":true},"id":"ae1bf8e9-69b6-4719-b4d2-67778598c4de","name":"Сохранить Workflow в файл","type":"n8n-nodes-base.writeToFile","typeVersion":1,"position":[224,128]}]	{"Запуск раз в день":{"main":[[{"node":"Получить список всех Workflow","type":"main","index":0}]]},"Получить список всех Workflow":{"main":[[{"node":"Извлечь данные из ответа","type":"main","index":0}]]},"Извлечь данные из ответа":{"main":[[{"node":"Loop Over Items","type":"main","index":0}]]}}	\N	t	\N
01184a00-2b8b-458b-a116-2d69f51ee85b	zsdIM77q7kP328Kg	peter samodurov	2026-04-02 08:33:03.77+00	2026-04-02 08:33:03.77+00	[{"parameters":{"rule":{"interval":[{"field":"hours"}]}},"id":"bb1bd90f-83b5-454a-bd96-867cce01b746","name":"Запуск раз в день","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1.1,"position":[-576,128]},{"parameters":{"url":"http://host.docker.internal:5678/api/v1/workflows","sendHeaders":true,"headerParameters":{"parameters":[{"name":"X-N8N-API-KEY","value":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMWY4MjMwMS0yNWRkLTRlMTAtYWNlMC1jYzBjZjFjOTAxZjUiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwianRpIjoiOWM4Y2NlYzctZTVmYy00OGJhLWFjZTctY2E0MGFmMThlN2YyIiwiaWF0IjoxNzc1MTE4NTQ3fQ.FrJIZCMCos_wbG_PcvZ1L_i3zNQBMawPnTPqCMd7l6c"}]},"options":{}},"id":"2a990eaa-57d7-42f2-a877-36bebea0f451","name":"Получить список всех Workflow","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[-384,128]},{"parameters":{"options":{}},"id":"7a3d9774-e3bf-4495-85f7-032f19e7b9d5","name":"Извлечь данные из ответа","type":"n8n-nodes-base.extractFromFile","typeVersion":1,"position":[-176,128]},{"parameters":{"batchSize":10,"options":{}},"id":"2aa8a944-1fea-4f07-9261-9728418c697c","name":"Loop Over Items","type":"n8n-nodes-base.splitInBatches","typeVersion":3,"position":[32,128]},{"parameters":{"mode":"file","filePath":"/home/node/.n8n/backups/","fileName":"={{ $json.name }}.json","fileContent":"={{ JSON.stringify($json, null, 2) }}","createFolderIfNotExists":true},"id":"ae1bf8e9-69b6-4719-b4d2-67778598c4de","name":"Сохранить Workflow в файл","type":"n8n-nodes-base.writeToFile","typeVersion":1,"position":[224,128]}]	{"Запуск раз в день":{"main":[[{"node":"Получить список всех Workflow","type":"main","index":0}]]},"Получить список всех Workflow":{"main":[[{"node":"Извлечь данные из ответа","type":"main","index":0}]]},"Извлечь данные из ответа":{"main":[[{"node":"Loop Over Items","type":"main","index":0}]]}}	\N	t	\N
bf15eb86-8a0e-4d29-b2e0-9a7c900c23b8	zsdIM77q7kP328Kg	peter samodurov	2026-04-02 08:33:09.872+00	2026-04-02 08:33:09.872+00	[{"parameters":{"rule":{"interval":[{"field":"minutes"}]}},"id":"bb1bd90f-83b5-454a-bd96-867cce01b746","name":"Запуск раз в день","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1.1,"position":[-576,128]},{"parameters":{"url":"http://host.docker.internal:5678/api/v1/workflows","sendHeaders":true,"headerParameters":{"parameters":[{"name":"X-N8N-API-KEY","value":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMWY4MjMwMS0yNWRkLTRlMTAtYWNlMC1jYzBjZjFjOTAxZjUiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwianRpIjoiOWM4Y2NlYzctZTVmYy00OGJhLWFjZTctY2E0MGFmMThlN2YyIiwiaWF0IjoxNzc1MTE4NTQ3fQ.FrJIZCMCos_wbG_PcvZ1L_i3zNQBMawPnTPqCMd7l6c"}]},"options":{}},"id":"2a990eaa-57d7-42f2-a877-36bebea0f451","name":"Получить список всех Workflow","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[-384,128]},{"parameters":{"options":{}},"id":"7a3d9774-e3bf-4495-85f7-032f19e7b9d5","name":"Извлечь данные из ответа","type":"n8n-nodes-base.extractFromFile","typeVersion":1,"position":[-176,128]},{"parameters":{"batchSize":10,"options":{}},"id":"2aa8a944-1fea-4f07-9261-9728418c697c","name":"Loop Over Items","type":"n8n-nodes-base.splitInBatches","typeVersion":3,"position":[32,128]},{"parameters":{"mode":"file","filePath":"/home/node/.n8n/backups/","fileName":"={{ $json.name }}.json","fileContent":"={{ JSON.stringify($json, null, 2) }}","createFolderIfNotExists":true},"id":"ae1bf8e9-69b6-4719-b4d2-67778598c4de","name":"Сохранить Workflow в файл","type":"n8n-nodes-base.writeToFile","typeVersion":1,"position":[224,128]}]	{"Запуск раз в день":{"main":[[{"node":"Получить список всех Workflow","type":"main","index":0}]]},"Получить список всех Workflow":{"main":[[{"node":"Извлечь данные из ответа","type":"main","index":0}]]},"Извлечь данные из ответа":{"main":[[{"node":"Loop Over Items","type":"main","index":0}]]}}	\N	t	\N
51b65be3-a742-4b2e-bcfa-6d72ca1e8964	zsdIM77q7kP328Kg	peter samodurov	2026-04-02 12:04:28.164+00	2026-04-02 12:04:28.164+00	[{"parameters":{"triggerTimes":{"item":[{}]}},"id":"c3e56160-f6d3-4a02-a511-c7917fd014ca","name":"Every hour","type":"n8n-nodes-base.cron","typeVersion":1,"position":[-640,-32]},{"parameters":{"command":"docker exec postgres pg_dump -U peter AS_news > /tmp/AS_news.sql && base64 /tmp/AS_news.sql"},"id":"654ac1e5-ea09-45ea-a657-f9d7001ee364","name":"SSH pg_dump","type":"n8n-nodes-base.ssh","typeVersion":1,"position":[-448,-32]},{"parameters":{"method":"PUT","url":"https://api.github.com/repos/PeternSamodurau/n8n-backups/contents/db/AS_news_{{$now}}.sql","sendBody":true,"bodyParameters":{"parameters":[{}]},"options":{}},"id":"0f26dfb0-32b3-4250-95b2-2c4ca3d6cdf6","name":"GitHub Upload DB","type":"n8n-nodes-base.httpRequest","typeVersion":3,"position":[-144,-32]}]	{"SSH pg_dump":{"main":[[{"node":"GitHub Upload DB","type":"main","index":0}]]}}	\N	t	\N
612ccac0-e3f4-4ede-af0e-5b42e46faea4	zsdIM77q7kP328Kg	peter samodurov	2026-04-02 08:33:12.77+00	2026-04-02 08:33:12.77+00	[{"parameters":{"rule":{"interval":[{"field":"minutes","minutesInterval":60}]}},"id":"bb1bd90f-83b5-454a-bd96-867cce01b746","name":"Запуск раз в день","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1.1,"position":[-576,128]},{"parameters":{"url":"http://host.docker.internal:5678/api/v1/workflows","sendHeaders":true,"headerParameters":{"parameters":[{"name":"X-N8N-API-KEY","value":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMWY4MjMwMS0yNWRkLTRlMTAtYWNlMC1jYzBjZjFjOTAxZjUiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwianRpIjoiOWM4Y2NlYzctZTVmYy00OGJhLWFjZTctY2E0MGFmMThlN2YyIiwiaWF0IjoxNzc1MTE4NTQ3fQ.FrJIZCMCos_wbG_PcvZ1L_i3zNQBMawPnTPqCMd7l6c"}]},"options":{}},"id":"2a990eaa-57d7-42f2-a877-36bebea0f451","name":"Получить список всех Workflow","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[-384,128]},{"parameters":{"options":{}},"id":"7a3d9774-e3bf-4495-85f7-032f19e7b9d5","name":"Извлечь данные из ответа","type":"n8n-nodes-base.extractFromFile","typeVersion":1,"position":[-176,128]},{"parameters":{"batchSize":10,"options":{}},"id":"2aa8a944-1fea-4f07-9261-9728418c697c","name":"Loop Over Items","type":"n8n-nodes-base.splitInBatches","typeVersion":3,"position":[32,128]},{"parameters":{"mode":"file","filePath":"/home/node/.n8n/backups/","fileName":"={{ $json.name }}.json","fileContent":"={{ JSON.stringify($json, null, 2) }}","createFolderIfNotExists":true},"id":"ae1bf8e9-69b6-4719-b4d2-67778598c4de","name":"Сохранить Workflow в файл","type":"n8n-nodes-base.writeToFile","typeVersion":1,"position":[224,128]}]	{"Запуск раз в день":{"main":[[{"node":"Получить список всех Workflow","type":"main","index":0}]]},"Получить список всех Workflow":{"main":[[{"node":"Извлечь данные из ответа","type":"main","index":0}]]},"Извлечь данные из ответа":{"main":[[{"node":"Loop Over Items","type":"main","index":0}]]}}	\N	t	\N
0e91a167-0005-44b5-8385-79e0fdb7bfc5	3iz9JrDgjvhLOoGC	peter samodurov	2026-04-02 08:40:48.868+00	2026-04-02 08:40:48.868+00	[{"parameters":{"rule":{"interval":[{"field":"minutes","minutesInterval":1}]}},"id":"b0b56191-de2d-439a-9314-1a717ec48d8f","name":"Schedule Trigger","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[-320,128]},{"parameters":{"operation":"executeQuery","query":"SELECT id, link FROM news WHERE processed = false ORDER BY id ASC LIMIT 50;","options":{}},"id":"950418b5-1251-4a99-bd17-1c50a46de309","name":"Select Unprocessed","type":"n8n-nodes-base.postgres","typeVersion":2,"position":[-128,128]},{"parameters":{"options":{}},"id":"10a73c34-a5d7-4f11-8693-3d72eac7b6ae","name":"Split in Batches","type":"n8n-nodes-base.splitInBatches","typeVersion":3,"position":[80,128]},{"parameters":{"mode":"runOnceForEachItem","jsCode":"const { id, link } = $json;\\n\\nlet sourceType = 'web';\\nif (link.includes('news.google.com/rss/articles')) sourceType = 'google_news';\\n\\nreturn { id, link, sourceType };"},"id":"f94f6510-e17a-4e76-9c06-cab79e6e3c99","name":"Detect Source","type":"n8n-nodes-base.code","typeVersion":2,"position":[288,128]},{"parameters":{"rules":{"values":[{"conditions":{"conditions":[{"leftValue":"={{ $json.sourceType }}","rightValue":"google_news","operator":{"type":"string","operation":"contains"}}]}},{"conditions":{"conditions":[{"leftValue":"={{ $json.sourceType }}","rightValue":"web","operator":{"type":"string","operation":"contains"}}]}}]},"options":{}},"id":"27cec0f4-829b-4766-bb01-32a5773ff364","name":"Switch Source","type":"n8n-nodes-base.switch","typeVersion":3,"position":[480,128]},{"parameters":{"url":"={{ $json.link }}","options":{"response":{}}},"id":"ab87f350-3248-4235-8465-5475805905d2","name":"HTTP Request","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[688,256]},{"parameters":{"mode":"runOnceForEachItem","jsCode":"let html = $json.body || '';\\n\\nhtml = html.replace(/<script[\\\\s\\\\S]*?<\\\\/script>/gi, '');\\nhtml = html.replace(/<style[\\\\s\\\\S]*?<\\\\/style>/gi, '');\\nhtml = html.replace(/<!--[\\\\s\\\\S]*?-->/g, '');\\n\\nlet paragraphs = [...html.matchAll(/<p[^>]*>([\\\\s\\\\S]*?)<\\\\/p>/gi)]\\n  .map(m => m[1].replace(/<[^>]+>/g, '').replace(/\\\\s+/g, ' ').trim())\\n  .filter(Boolean);\\n\\nparagraphs = paragraphs.filter(p => p.length > 40);\\n\\nlet content = paragraphs.join(\\"\\\\n\\\\n\\").trim();\\n\\nreturn { ...$json, content };"},"id":"9c5d93f0-389f-4791-94ff-109840bc1a2a","name":"Extract Article","type":"n8n-nodes-base.code","typeVersion":2,"position":[880,256]},{"parameters":{"operation":"executeQuery","query":"UPDATE news SET processed = true WHERE id = {{$json.id}};","options":{}},"id":"82f2a43e-2c44-4ad6-87ea-6212e2cfadc6","name":"Mark Processed","type":"n8n-nodes-base.postgres","typeVersion":2,"position":[1088,256]}]	{}	\N	t	\N
0e2e7cdd-ca05-4cbc-a102-38b02634471f	3iz9JrDgjvhLOoGC	peter samodurov	2026-04-02 08:47:16.835+00	2026-04-02 08:47:16.835+00	[{"parameters":{"rule":{"interval":[{"field":"minutes","minutesInterval":10}]}},"id":"f06f19ca-148d-40ec-87a9-4866fda1ba1c","name":"Schedule Trigger","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[-640,-64]},{"parameters":{"operation":"executeQuery","query":"SELECT id, url, type FROM sources WHERE active = true;","options":{}},"id":"2ec8f6bb-88e9-4802-bed0-9d757a34f418","name":"Select Sources","type":"n8n-nodes-base.postgres","typeVersion":2,"position":[-448,-64]},{"parameters":{"options":{}},"id":"9a85cae3-50f0-4f0a-b380-4642bb4e3687","name":"Split in Batches","type":"n8n-nodes-base.splitInBatches","typeVersion":3,"position":[-240,-64]},{"parameters":{"url":"={{ $json.url }}","options":{"response":{}}},"id":"04c672ac-36dc-4fe5-894f-ee1e56c17b61","name":"Fetch Source","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[-48,-64]},{"parameters":{"mode":"runOnceForEachItem","jsCode":"let { id: source_id, url, type } = $json;\\nlet body = $json.body || '';\\nlet links = [];\\n\\nif (type === 'rss') {\\n  links = [...body.matchAll(/<link>(.*?)<\\\\/link>/gi)]\\n    .map(m => m[1].trim())\\n    .filter(l => l.startsWith('http'));\\n}\\n\\nif (type === 'html') {\\n  links = [...body.matchAll(/href=[\\"']([^\\"']+)[\\"']/gi)]\\n    .map(m => m[1].trim())\\n    .filter(l => l.startsWith('http'));\\n}\\n\\nreturn links.map(link => ({ source_id, link }));"},"id":"0939c7e5-5acc-4ae8-a1ca-c9d081a00fb6","name":"Extract Links","type":"n8n-nodes-base.code","typeVersion":2,"position":[160,-64]},{"parameters":{"operation":"executeQuery","query":"INSERT INTO news (source_id, link, processed)\\nSELECT {{$json.source_id}}, '{{$json.link}}', false\\nWHERE NOT EXISTS (SELECT 1 FROM news WHERE link = '{{$json.link}}');","options":{}},"id":"1c42124e-a0d4-405a-818a-5bae71d7b189","name":"Insert News","type":"n8n-nodes-base.postgres","typeVersion":2,"position":[368,-64]}]	{}	\N	t	\N
eff75c03-0a23-41f3-adbd-e37d18c9c515	3iz9JrDgjvhLOoGC	peter samodurov	2026-04-02 08:48:11.207+00	2026-04-02 08:48:11.207+00	[{"parameters":{"rule":{"interval":[{"field":"minutes","minutesInterval":10}]}},"id":"f06f19ca-148d-40ec-87a9-4866fda1ba1c","name":"Schedule Trigger","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[-640,-64]},{"parameters":{"operation":"executeQuery","query":"SELECT id, url, type FROM sources WHERE active = true;","options":{}},"id":"2ec8f6bb-88e9-4802-bed0-9d757a34f418","name":"Select Sources","type":"n8n-nodes-base.postgres","typeVersion":2,"position":[-448,-64],"credentials":{"postgres":{"id":"MWAKq8y3zoMvQl4y","name":"Postgres account"}}},{"parameters":{"options":{}},"id":"9a85cae3-50f0-4f0a-b380-4642bb4e3687","name":"Split in Batches","type":"n8n-nodes-base.splitInBatches","typeVersion":3,"position":[-240,-64]},{"parameters":{"url":"={{ $json.url }}","options":{"response":{}}},"id":"04c672ac-36dc-4fe5-894f-ee1e56c17b61","name":"Fetch Source","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[-48,-64]},{"parameters":{"mode":"runOnceForEachItem","jsCode":"let { id: source_id, url, type } = $json;\\nlet body = $json.body || '';\\nlet links = [];\\n\\nif (type === 'rss') {\\n  links = [...body.matchAll(/<link>(.*?)<\\\\/link>/gi)]\\n    .map(m => m[1].trim())\\n    .filter(l => l.startsWith('http'));\\n}\\n\\nif (type === 'html') {\\n  links = [...body.matchAll(/href=[\\"']([^\\"']+)[\\"']/gi)]\\n    .map(m => m[1].trim())\\n    .filter(l => l.startsWith('http'));\\n}\\n\\nreturn links.map(link => ({ source_id, link }));"},"id":"0939c7e5-5acc-4ae8-a1ca-c9d081a00fb6","name":"Extract Links","type":"n8n-nodes-base.code","typeVersion":2,"position":[160,-64]},{"parameters":{"operation":"executeQuery","query":"INSERT INTO news (source_id, link, processed)\\nSELECT {{$json.source_id}}, '{{$json.link}}', false\\nWHERE NOT EXISTS (SELECT 1 FROM news WHERE link = '{{$json.link}}');","options":{}},"id":"1c42124e-a0d4-405a-818a-5bae71d7b189","name":"Insert News","type":"n8n-nodes-base.postgres","typeVersion":2,"position":[368,-64],"credentials":{"postgres":{"id":"MWAKq8y3zoMvQl4y","name":"Postgres account"}}}]	{}	\N	t	\N
8a9a437a-e070-404a-ac52-bab3fc50b78a	XHx0wNjTKl0j6e8U	peter samodurov	2026-04-02 09:14:11.076+00	2026-04-02 09:14:11.076+00	[{"parameters":{"rule":{"interval":[{"field":"minutes"}]}},"type":"n8n-nodes-base.scheduleTrigger","typeVersion":1.3,"position":[-976,128],"id":"de0aa6f5-3d8f-48dc-b672-e3d0dede9271","name":"Schedule Trigger"},{"parameters":{"operation":"executeQuery","query":"SELECT id, link\\nFROM news\\nWHERE processed = false\\nORDER BY id ASC\\nLIMIT 50;\\n","options":{}},"type":"n8n-nodes-base.postgres","typeVersion":2.6,"position":[-832,128],"id":"4cc41004-5df8-4876-9afb-f4a1968b1ed7","name":"Execute a SQL query","credentials":{"postgres":{"id":"MWAKq8y3zoMvQl4y","name":"Postgres account"}}},{"parameters":{"options":{}},"type":"n8n-nodes-base.splitInBatches","typeVersion":3,"position":[-640,128],"id":"d9e133ff-f451-4ad7-8f88-c86f1dd6e795","name":"Loop Over Items"},{"parameters":{"url":"={{ $json[\\"link\\"] }}\\n","options":{"redirect":{"redirect":{}},"response":{"response":{"responseFormat":"text","outputPropertyName":"body"}}}},"type":"n8n-nodes-base.httpRequest","typeVersion":4.4,"position":[224,240],"id":"fd33760e-5480-4b78-bb8e-bd898f5e6f8b","name":"HTTP Request"},{"parameters":{"mode":"runOnceForEachItem","jsCode":"const { id, link } = $input.item.json;\\n\\nlet sourceType = 'web'; // по умолчанию считаем, что это обычная web-страница\\n\\nif (link.includes('news.google.com/rss/articles')) {\\n  sourceType = 'google_news';\\n}\\n\\nreturn {\\n  id,\\n  link,\\n  sourceType\\n};\\n"},"type":"n8n-nodes-base.code","typeVersion":2,"position":[-416,128],"id":"857f0bfb-b058-48a8-8bed-e320c5ed7488","name":"Code in JavaScript1"},{"parameters":{"rules":{"values":[{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict","version":3},"conditions":[{"leftValue":"={{ $json.sourceType }}\\n","rightValue":"google_news","operator":{"type":"string","operation":"contains"},"id":"621bcd6c-6bfd-4cee-820f-21328fa70159"}],"combinator":"and"}},{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict","version":3},"conditions":[{"id":"029151ac-2705-41e9-9e5a-951f257f4a89","leftValue":"={{ $json.sourceType }}\\n","rightValue":"web","operator":{"type":"string","operation":"contains"}}],"combinator":"and"}}]},"options":{}},"type":"n8n-nodes-base.switch","typeVersion":3.4,"position":[-208,128],"id":"660ff7d0-dac3-4a70-bbff-1c30c4c86458","name":"Switch"},{"parameters":{"jsCode":"// Loop over input items and add a new field called 'myNewField' to the JSON of each one\\nfor (const item of $input.all()) {\\n  item.json.myNewField = 1;\\n}\\n\\nreturn $input.all();"},"type":"n8n-nodes-base.code","typeVersion":2,"position":[0,240],"id":"d5efdacb-67f9-41e1-a019-e8958f84561b","name":"Web"},{"parameters":{"jsCode":"// Loop over input items and add a new field called 'myNewField' to the JSON of each one\\nfor (const item of $input.all()) {\\n  item.json.myNewField = 1;\\n}\\n\\nreturn $input.all();"},"type":"n8n-nodes-base.code","typeVersion":2,"position":[0,0],"id":"17918734-398d-41a4-a828-7c3bfc886c03","name":"Rss"},{"parameters":{"operation":"extractHtmlContent","dataPropertyName":"body","extractionValues":{"values":[{"key":"content","cssSelector":"article, [role=\\"main\\"], .post-content, .entry-content, .article-content, .story-content, .story-body, .article-body, .content, .main-content","skipSelectors":".comments, .sidebar, .related, .recommendations, .newsletter, .advertisement, .social-share, .meta, .footer, header, nav, .widget, .also-read, .more-news, .editor-picks"}]},"options":{}},"type":"n8n-nodes-base.html","typeVersion":1.2,"position":[432,240],"id":"f19de0e9-9371-44a3-81dd-223464d429f2","name":"HTML"},{"parameters":{"method":"POST","url":"http://host.docker.internal:11434/v1/chat/completions","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Content-Type","value":"application/json"}]},"sendBody":true,"specifyBody":"json","jsonBody":"={\\n  \\"model\\": \\"granite3.1-moe:1b\\",\\n  \\"messages\\": [\\n    {\\n      \\"role\\": \\"system\\",\\n      \\"content\\": \\"Ты переводчик. Переведи следующий текст на русский язык. Верни только переведённый текст, без комментариев и пояснений.\\"\\n    },\\n    {\\n      \\"role\\": \\"user\\",\\n      \\"content\\": {{ JSON.stringify($json.content) }}\\n    }\\n  ],\\n  \\"temperature\\": 0.3\\n}","options":{}},"type":"n8n-nodes-base.httpRequest","typeVersion":4.4,"position":[192,480],"id":"4f7c2b83-a4ce-49bd-9724-a626457466d3","name":"Call Ollama"}]	{"Schedule Trigger":{"main":[[{"node":"Execute a SQL query","type":"main","index":0}]]},"Loop Over Items":{"main":[[{"node":"Code in JavaScript1","type":"main","index":0}],[{"node":"Loop Over Items","type":"main","index":0}]]},"Execute a SQL query":{"main":[[{"node":"Loop Over Items","type":"main","index":0}]]},"HTTP Request":{"main":[[{"node":"HTML","type":"main","index":0}]]},"Code in JavaScript1":{"main":[[{"node":"Switch","type":"main","index":0}]]},"Switch":{"main":[[{"node":"Rss","type":"main","index":0}],[{"node":"Web","type":"main","index":0}]]},"Web":{"main":[[{"node":"HTTP Request","type":"main","index":0}]]}}	\N	t	\N
072a1dc7-3cd2-4285-bdc3-aa312442544a	zsdIM77q7kP328Kg	peter samodurov	2026-04-02 12:05:42.939+00	2026-04-02 12:05:42.939+00	[{"parameters":{"triggerTimes":{"item":[{}]}},"id":"060cbcc5-313c-4277-895a-0b11a5197c10","name":"Every hour","type":"n8n-nodes-base.cron","typeVersion":1,"position":[-576,0]},{"parameters":{"command":"docker exec postgres pg_dump -U peter AS_news > /tmp/AS_news.sql && base64 /tmp/AS_news.sql"},"id":"432b9024-eeb2-4477-8dc0-103ebe322bd0","name":"SSH pg_dump","type":"n8n-nodes-base.ssh","typeVersion":1,"position":[-384,0]},{"parameters":{"method":"PUT","url":"https://api.github.com/repos/PeternSamodurau/n8n-backups/contents/db/AS_news_{{$now}}.sql","sendBody":true,"bodyParameters":{"parameters":[{}]},"options":{}},"id":"a4d3c3d6-45a6-4195-bdf7-85e038420d74","name":"GitHub Upload DB","type":"n8n-nodes-base.httpRequest","typeVersion":3,"position":[-80,0]}]	{"SSH pg_dump":{"main":[[{"node":"GitHub Upload DB","type":"main","index":0}]]},"Every hour":{"main":[[{"node":"SSH pg_dump","type":"main","index":0}]]}}	\N	t	\N
35f071c8-368d-4573-a1e7-eae969bc09c5	zsdIM77q7kP328Kg	peter samodurov	2026-04-02 12:26:58.218+00	2026-04-02 12:26:58.218+00	[{"parameters":{"triggerTimes":{"item":[{}]}},"id":"060cbcc5-313c-4277-895a-0b11a5197c10","name":"Every hour","type":"n8n-nodes-base.cron","typeVersion":1,"position":[-800,-32]},{"parameters":{"command":"docker exec postgres pg_dump -U peter AS_news > /tmp/AS_news.sql && base64 /tmp/AS_news.sql"},"id":"432b9024-eeb2-4477-8dc0-103ebe322bd0","name":"SSH pg_dump","type":"n8n-nodes-base.ssh","typeVersion":1,"position":[-608,-32]},{"parameters":{"method":"PUT","url":"https://api.github.com/repos/PeternSamodurau/n8n-backups/contents/db/AS_news_{{$now}}.sql","sendBody":true,"bodyParameters":{"parameters":[{}]},"options":{}},"id":"a4d3c3d6-45a6-4195-bdf7-85e038420d74","name":"GitHub Upload DB","type":"n8n-nodes-base.httpRequest","typeVersion":3,"position":[-304,-32]}]	{"SSH pg_dump":{"main":[[{"node":"GitHub Upload DB","type":"main","index":0}]]},"Every hour":{"main":[[{"node":"SSH pg_dump","type":"main","index":0}]]}}	\N	t	\N
54847bf5-127d-457c-968c-863e3a56b75d	zsdIM77q7kP328Kg	peter samodurov	2026-04-02 12:28:10.683+00	2026-04-02 12:28:10.683+00	[]	{}	\N	t	\N
ee32ea45-cedd-4cde-bba1-38da04696367	zsdIM77q7kP328Kg	peter samodurov	2026-04-02 12:28:19.173+00	2026-04-02 12:28:19.173+00	[{"parameters":{"triggerTimes":{"item":[{}]}},"id":"277baf4e-ecf9-41c0-baa6-008a8d63ee9c","name":"Every hour","type":"n8n-nodes-base.cron","typeVersion":1,"position":[-704,-16]},{"parameters":{"command":"docker exec postgres pg_dump -U peter AS_news"},"id":"4ee21392-4c65-484a-9e81-ffb9e2a9f23e","name":"pg_dump inside postgres","type":"n8n-nodes-base.executeCommand","typeVersion":1,"position":[-448,-16]},{"parameters":{"method":"PUT","url":"https://api.github.com/repos/PeternSamodurau/n8n-backups/contents/db/AS_news_{{$now}}.sql","sendBody":true,"bodyParameters":{"parameters":[{}]},"options":{}},"id":"2570eb56-4a71-4328-a4a0-a23ce4880229","name":"GitHub Upload DB","type":"n8n-nodes-base.httpRequest","typeVersion":3,"position":[-160,-16]}]	{}	\N	t	\N
f70fb21d-d5a2-497e-881e-4e7d54d8bfb1	zsdIM77q7kP328Kg	peter samodurov	2026-04-02 12:29:38.41+00	2026-04-02 12:29:38.41+00	[]	{}	\N	t	\N
bac655a3-88d3-4d1b-852c-515d1909dbb4	zsdIM77q7kP328Kg	peter samodurov	2026-04-02 12:29:41.232+00	2026-04-02 12:29:41.232+00	[{"parameters":{"triggerTimes":{"item":[{}]}},"id":"ffe232cf-b77a-46bf-8f54-8ddd5f9a89c3","name":"Every hour","type":"n8n-nodes-base.cron","typeVersion":1,"position":[-656,112]},{"parameters":{"command":"docker exec postgres pg_dump -U peter AS_news"},"id":"50c29f56-9992-4a0c-b85c-5415dfa02620","name":"pg_dump inside postgres","type":"n8n-nodes-base.executeCommand","typeVersion":1,"position":[-400,112]},{"parameters":{"method":"PUT","url":"https://api.github.com/repos/PeternSamodurau/n8n-backups/contents/db/AS_news_{{$now}}.sql","sendBody":true,"bodyParameters":{"parameters":[{}]},"options":{}},"id":"a1b44f0c-ba6b-4152-b949-9243d91719c0","name":"GitHub Upload DB","type":"n8n-nodes-base.httpRequest","typeVersion":3,"position":[-112,112]}]	{}	\N	t	\N
\.


--
-- Data for Name: workflow_publish_history; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.workflow_publish_history (id, "workflowId", "versionId", event, "userId", "createdAt") FROM stdin;
\.


--
-- Data for Name: workflow_published_version; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.workflow_published_version ("workflowId", "publishedVersionId", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: workflow_statistics; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.workflow_statistics (count, "latestEvent", name, "workflowId", "rootCount", id, "workflowName") FROM stdin;
1	2026-04-02 08:47:19.538+00	manual_success	3iz9JrDgjvhLOoGC	0	1	AS_sources_to_news
1	2026-04-02 12:04:36.333+00	manual_success	zsdIM77q7kP328Kg	0	2	DB Backup to GitHub
1	2026-04-02 12:05:44.38+00	manual_error	zsdIM77q7kP328Kg	0	3	DB Backup to GitHub
\.


--
-- Data for Name: workflows_tags; Type: TABLE DATA; Schema: public; Owner: peter
--

COPY public.workflows_tags ("workflowId", "tagId") FROM stdin;
\.


--
-- Name: auth_provider_sync_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: peter
--

SELECT pg_catalog.setval('public.auth_provider_sync_history_id_seq', 1, false);


--
-- Name: execution_annotations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: peter
--

SELECT pg_catalog.setval('public.execution_annotations_id_seq', 1, false);


--
-- Name: execution_entity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: peter
--

SELECT pg_catalog.setval('public.execution_entity_id_seq', 3, true);


--
-- Name: execution_metadata_temp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: peter
--

SELECT pg_catalog.setval('public.execution_metadata_temp_id_seq', 1, false);


--
-- Name: insights_by_period_id_seq; Type: SEQUENCE SET; Schema: public; Owner: peter
--

SELECT pg_catalog.setval('public.insights_by_period_id_seq', 1, false);


--
-- Name: insights_metadata_metaId_seq; Type: SEQUENCE SET; Schema: public; Owner: peter
--

SELECT pg_catalog.setval('public."insights_metadata_metaId_seq"', 1, false);


--
-- Name: insights_raw_id_seq; Type: SEQUENCE SET; Schema: public; Owner: peter
--

SELECT pg_catalog.setval('public.insights_raw_id_seq', 1, false);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: peter
--

SELECT pg_catalog.setval('public.migrations_id_seq', 154, true);


--
-- Name: oauth_user_consents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: peter
--

SELECT pg_catalog.setval('public.oauth_user_consents_id_seq', 1, false);


--
-- Name: region_id_seq; Type: SEQUENCE SET; Schema: public; Owner: peter
--

SELECT pg_catalog.setval('public.region_id_seq', 6, true);


--
-- Name: secrets_provider_connection_id_seq; Type: SEQUENCE SET; Schema: public; Owner: peter
--

SELECT pg_catalog.setval('public.secrets_provider_connection_id_seq', 1, false);


--
-- Name: sources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: peter
--

SELECT pg_catalog.setval('public.sources_id_seq', 54, true);


--
-- Name: workflow_dependency_id_seq; Type: SEQUENCE SET; Schema: public; Owner: peter
--

SELECT pg_catalog.setval('public.workflow_dependency_id_seq', 106, true);


--
-- Name: workflow_publish_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: peter
--

SELECT pg_catalog.setval('public.workflow_publish_history_id_seq', 1, false);


--
-- Name: workflow_statistics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: peter
--

SELECT pg_catalog.setval('public.workflow_statistics_id_seq', 3, true);


--
-- Name: test_run PK_011c050f566e9db509a0fadb9b9; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.test_run
    ADD CONSTRAINT "PK_011c050f566e9db509a0fadb9b9" PRIMARY KEY (id);


--
-- Name: project_secrets_provider_access PK_0402b7fcec5415246656f102f83; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.project_secrets_provider_access
    ADD CONSTRAINT "PK_0402b7fcec5415246656f102f83" PRIMARY KEY ("secretsProviderConnectionId", "projectId");


--
-- Name: installed_packages PK_08cc9197c39b028c1e9beca225940576fd1a5804; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.installed_packages
    ADD CONSTRAINT "PK_08cc9197c39b028c1e9beca225940576fd1a5804" PRIMARY KEY ("packageName");


--
-- Name: execution_metadata PK_17a0b6284f8d626aae88e1c16e4; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.execution_metadata
    ADD CONSTRAINT "PK_17a0b6284f8d626aae88e1c16e4" PRIMARY KEY (id);


--
-- Name: project_relation PK_1caaa312a5d7184a003be0f0cb6; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.project_relation
    ADD CONSTRAINT "PK_1caaa312a5d7184a003be0f0cb6" PRIMARY KEY ("projectId", "userId");


--
-- Name: chat_hub_sessions PK_1eafef1273c70e4464fec703412; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_sessions
    ADD CONSTRAINT "PK_1eafef1273c70e4464fec703412" PRIMARY KEY (id);


--
-- Name: folder_tag PK_27e4e00852f6b06a925a4d83a3e; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.folder_tag
    ADD CONSTRAINT "PK_27e4e00852f6b06a925a4d83a3e" PRIMARY KEY ("folderId", "tagId");


--
-- Name: role PK_35c9b140caaf6da09cfabb0d675; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT "PK_35c9b140caaf6da09cfabb0d675" PRIMARY KEY (slug);


--
-- Name: secrets_provider_connection PK_4350ae85e76f9ba7df1370acb5d; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.secrets_provider_connection
    ADD CONSTRAINT "PK_4350ae85e76f9ba7df1370acb5d" PRIMARY KEY (id);


--
-- Name: project PK_4d68b1358bb5b766d3e78f32f57; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT "PK_4d68b1358bb5b766d3e78f32f57" PRIMARY KEY (id);


--
-- Name: dynamic_credential_entry PK_5135ffcabecad4727ff6b9b803d; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.dynamic_credential_entry
    ADD CONSTRAINT "PK_5135ffcabecad4727ff6b9b803d" PRIMARY KEY (credential_id, subject_id, resolver_id);


--
-- Name: workflow_dependency PK_52325e34cd7a2f0f67b0f3cad65; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.workflow_dependency
    ADD CONSTRAINT "PK_52325e34cd7a2f0f67b0f3cad65" PRIMARY KEY (id);


--
-- Name: invalid_auth_token PK_5779069b7235b256d91f7af1a15; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.invalid_auth_token
    ADD CONSTRAINT "PK_5779069b7235b256d91f7af1a15" PRIMARY KEY (token);


--
-- Name: shared_workflow PK_5ba87620386b847201c9531c58f; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.shared_workflow
    ADD CONSTRAINT "PK_5ba87620386b847201c9531c58f" PRIMARY KEY ("workflowId", "projectId");


--
-- Name: workflow_published_version PK_5c76fb7ee939fe2530374d3f75a; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.workflow_published_version
    ADD CONSTRAINT "PK_5c76fb7ee939fe2530374d3f75a" PRIMARY KEY ("workflowId");


--
-- Name: folder PK_6278a41a706740c94c02e288df8; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.folder
    ADD CONSTRAINT "PK_6278a41a706740c94c02e288df8" PRIMARY KEY (id);


--
-- Name: data_table_column PK_673cb121ee4a8a5e27850c72c51; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.data_table_column
    ADD CONSTRAINT "PK_673cb121ee4a8a5e27850c72c51" PRIMARY KEY (id);


--
-- Name: chat_hub_tools PK_696d26426c704fba79b2c195ef5; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_tools
    ADD CONSTRAINT "PK_696d26426c704fba79b2c195ef5" PRIMARY KEY (id);


--
-- Name: annotation_tag_entity PK_69dfa041592c30bbc0d4b84aa00; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.annotation_tag_entity
    ADD CONSTRAINT "PK_69dfa041592c30bbc0d4b84aa00" PRIMARY KEY (id);


--
-- Name: oauth_refresh_tokens PK_74abaed0b30711b6532598b0392; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.oauth_refresh_tokens
    ADD CONSTRAINT "PK_74abaed0b30711b6532598b0392" PRIMARY KEY (token);


--
-- Name: dynamic_credential_user_entry PK_74f548e633abc66dc27c8f0ca77; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.dynamic_credential_user_entry
    ADD CONSTRAINT "PK_74f548e633abc66dc27c8f0ca77" PRIMARY KEY ("credentialId", "userId", "resolverId");


--
-- Name: chat_hub_messages PK_7704a5add6baed43eef835f0bfb; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_messages
    ADD CONSTRAINT "PK_7704a5add6baed43eef835f0bfb" PRIMARY KEY (id);


--
-- Name: execution_annotations PK_7afcf93ffa20c4252869a7c6a23; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.execution_annotations
    ADD CONSTRAINT "PK_7afcf93ffa20c4252869a7c6a23" PRIMARY KEY (id);


--
-- Name: oauth_user_consents PK_85b9ada746802c8993103470f05; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.oauth_user_consents
    ADD CONSTRAINT "PK_85b9ada746802c8993103470f05" PRIMARY KEY (id);


--
-- Name: chat_hub_session_tools PK_87aea76ff4c274c4a5ac838ebe3; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_session_tools
    ADD CONSTRAINT "PK_87aea76ff4c274c4a5ac838ebe3" PRIMARY KEY ("sessionId", "toolId");


--
-- Name: migrations PK_8c82d7f526340ab734260ea46be; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT "PK_8c82d7f526340ab734260ea46be" PRIMARY KEY (id);


--
-- Name: installed_nodes PK_8ebd28194e4f792f96b5933423fc439df97d9689; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.installed_nodes
    ADD CONSTRAINT "PK_8ebd28194e4f792f96b5933423fc439df97d9689" PRIMARY KEY (name);


--
-- Name: shared_credentials PK_8ef3a59796a228913f251779cff; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.shared_credentials
    ADD CONSTRAINT "PK_8ef3a59796a228913f251779cff" PRIMARY KEY ("credentialsId", "projectId");


--
-- Name: test_case_execution PK_90c121f77a78a6580e94b794bce; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.test_case_execution
    ADD CONSTRAINT "PK_90c121f77a78a6580e94b794bce" PRIMARY KEY (id);


--
-- Name: user_api_keys PK_978fa5caa3468f463dac9d92e69; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.user_api_keys
    ADD CONSTRAINT "PK_978fa5caa3468f463dac9d92e69" PRIMARY KEY (id);


--
-- Name: execution_annotation_tags PK_979ec03d31294cca484be65d11f; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.execution_annotation_tags
    ADD CONSTRAINT "PK_979ec03d31294cca484be65d11f" PRIMARY KEY ("annotationId", "tagId");


--
-- Name: webhook_entity PK_b21ace2e13596ccd87dc9bf4ea6; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.webhook_entity
    ADD CONSTRAINT "PK_b21ace2e13596ccd87dc9bf4ea6" PRIMARY KEY ("webhookPath", method);


--
-- Name: insights_by_period PK_b606942249b90cc39b0265f0575; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.insights_by_period
    ADD CONSTRAINT "PK_b606942249b90cc39b0265f0575" PRIMARY KEY (id);


--
-- Name: workflow_history PK_b6572dd6173e4cd06fe79937b58; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.workflow_history
    ADD CONSTRAINT "PK_b6572dd6173e4cd06fe79937b58" PRIMARY KEY ("versionId");


--
-- Name: dynamic_credential_resolver PK_b76cfb088dcdaf5275e9980bb64; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.dynamic_credential_resolver
    ADD CONSTRAINT "PK_b76cfb088dcdaf5275e9980bb64" PRIMARY KEY (id);


--
-- Name: scope PK_bfc45df0481abd7f355d6187da1; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.scope
    ADD CONSTRAINT "PK_bfc45df0481abd7f355d6187da1" PRIMARY KEY (slug);


--
-- Name: oauth_clients PK_c4759172d3431bae6f04e678e0d; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.oauth_clients
    ADD CONSTRAINT "PK_c4759172d3431bae6f04e678e0d" PRIMARY KEY (id);


--
-- Name: workflow_publish_history PK_c788f7caf88e91e365c97d6d04a; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.workflow_publish_history
    ADD CONSTRAINT "PK_c788f7caf88e91e365c97d6d04a" PRIMARY KEY (id);


--
-- Name: processed_data PK_ca04b9d8dc72de268fe07a65773; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.processed_data
    ADD CONSTRAINT "PK_ca04b9d8dc72de268fe07a65773" PRIMARY KEY ("workflowId", context);


--
-- Name: chat_hub_agent_tools PK_cc8806fdea48297a7d497035d72; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_agent_tools
    ADD CONSTRAINT "PK_cc8806fdea48297a7d497035d72" PRIMARY KEY ("agentId", "toolId");


--
-- Name: settings PK_dc0fe14e6d9943f268e7b119f69ab8bd; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT "PK_dc0fe14e6d9943f268e7b119f69ab8bd" PRIMARY KEY (key);


--
-- Name: oauth_access_tokens PK_dcd71f96a5d5f4bf79e67d322bf; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT "PK_dcd71f96a5d5f4bf79e67d322bf" PRIMARY KEY (token);


--
-- Name: data_table PK_e226d0001b9e6097cbfe70617cb; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.data_table
    ADD CONSTRAINT "PK_e226d0001b9e6097cbfe70617cb" PRIMARY KEY (id);


--
-- Name: workflow_builder_session PK_e69ef0d385986e273423b0e8695; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.workflow_builder_session
    ADD CONSTRAINT "PK_e69ef0d385986e273423b0e8695" PRIMARY KEY (id);


--
-- Name: user PK_ea8f538c94b6e352418254ed6474a81f; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT "PK_ea8f538c94b6e352418254ed6474a81f" PRIMARY KEY (id);


--
-- Name: insights_raw PK_ec15125755151e3a7e00e00014f; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.insights_raw
    ADD CONSTRAINT "PK_ec15125755151e3a7e00e00014f" PRIMARY KEY (id);


--
-- Name: chat_hub_agents PK_f39a3b36bbdf0e2979ddb21cf78; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_agents
    ADD CONSTRAINT "PK_f39a3b36bbdf0e2979ddb21cf78" PRIMARY KEY (id);


--
-- Name: insights_metadata PK_f448a94c35218b6208ce20cf5a1; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.insights_metadata
    ADD CONSTRAINT "PK_f448a94c35218b6208ce20cf5a1" PRIMARY KEY ("metaId");


--
-- Name: oauth_authorization_codes PK_fb91ab932cfbd694061501cc20f; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.oauth_authorization_codes
    ADD CONSTRAINT "PK_fb91ab932cfbd694061501cc20f" PRIMARY KEY (code);


--
-- Name: binary_data PK_fc3691585b39408bb0551122af6; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.binary_data
    ADD CONSTRAINT "PK_fc3691585b39408bb0551122af6" PRIMARY KEY ("fileId");


--
-- Name: role_scope PK_role_scope; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.role_scope
    ADD CONSTRAINT "PK_role_scope" PRIMARY KEY ("roleSlug", "scopeSlug");


--
-- Name: oauth_user_consents UQ_083721d99ce8db4033e2958ebb4; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.oauth_user_consents
    ADD CONSTRAINT "UQ_083721d99ce8db4033e2958ebb4" UNIQUE ("userId", "clientId");


--
-- Name: data_table_column UQ_8082ec4890f892f0bc77473a123; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.data_table_column
    ADD CONSTRAINT "UQ_8082ec4890f892f0bc77473a123" UNIQUE ("dataTableId", name);


--
-- Name: data_table UQ_b23096ef747281ac944d28e8b0d; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.data_table
    ADD CONSTRAINT "UQ_b23096ef747281ac944d28e8b0d" UNIQUE ("projectId", name);


--
-- Name: user UQ_e12875dfb3b1d92d7d7c5377e2; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT "UQ_e12875dfb3b1d92d7d7c5377e2" UNIQUE (email);


--
-- Name: workflow_builder_session UQ_ec2aa73632932d485a1d5192ce1; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.workflow_builder_session
    ADD CONSTRAINT "UQ_ec2aa73632932d485a1d5192ce1" UNIQUE ("workflowId", "userId");


--
-- Name: auth_identity auth_identity_pkey; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.auth_identity
    ADD CONSTRAINT auth_identity_pkey PRIMARY KEY ("providerId", "providerType");


--
-- Name: auth_provider_sync_history auth_provider_sync_history_pkey; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.auth_provider_sync_history
    ADD CONSTRAINT auth_provider_sync_history_pkey PRIMARY KEY (id);


--
-- Name: credentials_entity credentials_entity_pkey; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.credentials_entity
    ADD CONSTRAINT credentials_entity_pkey PRIMARY KEY (id);


--
-- Name: event_destinations event_destinations_pkey; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.event_destinations
    ADD CONSTRAINT event_destinations_pkey PRIMARY KEY (id);


--
-- Name: execution_data execution_data_pkey; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.execution_data
    ADD CONSTRAINT execution_data_pkey PRIMARY KEY ("executionId");


--
-- Name: execution_entity pk_e3e63bbf986767844bbe1166d4e; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.execution_entity
    ADD CONSTRAINT pk_e3e63bbf986767844bbe1166d4e PRIMARY KEY (id);


--
-- Name: workflows_tags pk_workflows_tags; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.workflows_tags
    ADD CONSTRAINT pk_workflows_tags PRIMARY KEY ("workflowId", "tagId");


--
-- Name: region region_code_key; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_code_key UNIQUE (code);


--
-- Name: region region_pkey; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (id);


--
-- Name: sources sources_pkey; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.sources
    ADD CONSTRAINT sources_pkey PRIMARY KEY (id);


--
-- Name: tag_entity tag_entity_pkey; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.tag_entity
    ADD CONSTRAINT tag_entity_pkey PRIMARY KEY (id);


--
-- Name: variables variables_pkey; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.variables
    ADD CONSTRAINT variables_pkey PRIMARY KEY (id);


--
-- Name: workflow_entity workflow_entity_pkey; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.workflow_entity
    ADD CONSTRAINT workflow_entity_pkey PRIMARY KEY (id);


--
-- Name: workflow_statistics workflow_statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.workflow_statistics
    ADD CONSTRAINT workflow_statistics_pkey PRIMARY KEY (id);


--
-- Name: IDX_070b5de842ece9ccdda0d9738b; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX "IDX_070b5de842ece9ccdda0d9738b" ON public.workflow_publish_history USING btree ("workflowId", "versionId");


--
-- Name: IDX_14f68deffaf858465715995508; Type: INDEX; Schema: public; Owner: peter
--

CREATE UNIQUE INDEX "IDX_14f68deffaf858465715995508" ON public.folder USING btree ("projectId", id);


--
-- Name: IDX_1d8ab99d5861c9388d2dc1cf73; Type: INDEX; Schema: public; Owner: peter
--

CREATE UNIQUE INDEX "IDX_1d8ab99d5861c9388d2dc1cf73" ON public.insights_metadata USING btree ("workflowId");


--
-- Name: IDX_1e31657f5fe46816c34be7c1b4; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX "IDX_1e31657f5fe46816c34be7c1b4" ON public.workflow_history USING btree ("workflowId");


--
-- Name: IDX_1ef35bac35d20bdae979d917a3; Type: INDEX; Schema: public; Owner: peter
--

CREATE UNIQUE INDEX "IDX_1ef35bac35d20bdae979d917a3" ON public.user_api_keys USING btree ("apiKey");


--
-- Name: IDX_4c72ebdb265d1775bf61147af0; Type: INDEX; Schema: public; Owner: peter
--

CREATE UNIQUE INDEX "IDX_4c72ebdb265d1775bf61147af0" ON public.chat_hub_tools USING btree ("ownerId", name);


--
-- Name: IDX_56900edc3cfd16612e2ef2c6a8; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX "IDX_56900edc3cfd16612e2ef2c6a8" ON public.binary_data USING btree ("sourceType", "sourceId");


--
-- Name: IDX_5f0643f6717905a05164090dde; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX "IDX_5f0643f6717905a05164090dde" ON public.project_relation USING btree ("userId");


--
-- Name: IDX_60b6a84299eeb3f671dfec7693; Type: INDEX; Schema: public; Owner: peter
--

CREATE UNIQUE INDEX "IDX_60b6a84299eeb3f671dfec7693" ON public.insights_by_period USING btree ("periodStart", type, "periodUnit", "metaId");


--
-- Name: IDX_61448d56d61802b5dfde5cdb00; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX "IDX_61448d56d61802b5dfde5cdb00" ON public.project_relation USING btree ("projectId");


--
-- Name: IDX_62476b94b56d9dc7ed9ed75d3d; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX "IDX_62476b94b56d9dc7ed9ed75d3d" ON public.dynamic_credential_entry USING btree (subject_id);


--
-- Name: IDX_63d7bbae72c767cf162d459fcc; Type: INDEX; Schema: public; Owner: peter
--

CREATE UNIQUE INDEX "IDX_63d7bbae72c767cf162d459fcc" ON public.user_api_keys USING btree ("userId", label);


--
-- Name: IDX_6edec973a6450990977bb854c3; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX "IDX_6edec973a6450990977bb854c3" ON public.dynamic_credential_user_entry USING btree ("resolverId");


--
-- Name: IDX_8e4b4774db42f1e6dda3452b2a; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX "IDX_8e4b4774db42f1e6dda3452b2a" ON public.test_case_execution USING btree ("testRunId");


--
-- Name: IDX_97f863fa83c4786f1956508496; Type: INDEX; Schema: public; Owner: peter
--

CREATE UNIQUE INDEX "IDX_97f863fa83c4786f1956508496" ON public.execution_annotations USING btree ("executionId");


--
-- Name: IDX_9c9ee9df586e60bb723234e499; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX "IDX_9c9ee9df586e60bb723234e499" ON public.dynamic_credential_resolver USING btree (type);


--
-- Name: IDX_UniqueRoleDisplayName; Type: INDEX; Schema: public; Owner: peter
--

CREATE UNIQUE INDEX "IDX_UniqueRoleDisplayName" ON public.role USING btree ("displayName");


--
-- Name: IDX_a3697779b366e131b2bbdae297; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX "IDX_a3697779b366e131b2bbdae297" ON public.execution_annotation_tags USING btree ("tagId");


--
-- Name: IDX_a36dc616fabc3f736bb82410a2; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX "IDX_a36dc616fabc3f736bb82410a2" ON public.dynamic_credential_user_entry USING btree ("userId");


--
-- Name: IDX_a4ff2d9b9628ea988fa9e7d0bf; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX "IDX_a4ff2d9b9628ea988fa9e7d0bf" ON public.workflow_dependency USING btree ("workflowId");


--
-- Name: IDX_ae51b54c4bb430cf92f48b623f; Type: INDEX; Schema: public; Owner: peter
--

CREATE UNIQUE INDEX "IDX_ae51b54c4bb430cf92f48b623f" ON public.annotation_tag_entity USING btree (name);


--
-- Name: IDX_c1519757391996eb06064f0e7c; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX "IDX_c1519757391996eb06064f0e7c" ON public.execution_annotation_tags USING btree ("annotationId");


--
-- Name: IDX_cec8eea3bf49551482ccb4933e; Type: INDEX; Schema: public; Owner: peter
--

CREATE UNIQUE INDEX "IDX_cec8eea3bf49551482ccb4933e" ON public.execution_metadata USING btree ("executionId", key);


--
-- Name: IDX_chat_hub_messages_sessionId; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX "IDX_chat_hub_messages_sessionId" ON public.chat_hub_messages USING btree ("sessionId");


--
-- Name: IDX_chat_hub_sessions_owner_lastmsg_id; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX "IDX_chat_hub_sessions_owner_lastmsg_id" ON public.chat_hub_sessions USING btree ("ownerId", "lastMessageAt" DESC, id);


--
-- Name: IDX_d61a12235d268a49af6a3c09c1; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX "IDX_d61a12235d268a49af6a3c09c1" ON public.dynamic_credential_entry USING btree (resolver_id);


--
-- Name: IDX_d6870d3b6e4c185d33926f423c; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX "IDX_d6870d3b6e4c185d33926f423c" ON public.test_run USING btree ("workflowId");


--
-- Name: IDX_e48a201071ab85d9d09119d640; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX "IDX_e48a201071ab85d9d09119d640" ON public.workflow_dependency USING btree ("dependencyKey");


--
-- Name: IDX_e7fe1cfda990c14a445937d0b9; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX "IDX_e7fe1cfda990c14a445937d0b9" ON public.workflow_dependency USING btree ("dependencyType");


--
-- Name: IDX_execution_entity_deletedAt; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX "IDX_execution_entity_deletedAt" ON public.execution_entity USING btree ("deletedAt");


--
-- Name: IDX_role_scope_scopeSlug; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX "IDX_role_scope_scopeSlug" ON public.role_scope USING btree ("scopeSlug");


--
-- Name: IDX_secrets_provider_connection_providerKey; Type: INDEX; Schema: public; Owner: peter
--

CREATE UNIQUE INDEX "IDX_secrets_provider_connection_providerKey" ON public.secrets_provider_connection USING btree ("providerKey");


--
-- Name: IDX_workflow_dependency_publishedVersionId; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX "IDX_workflow_dependency_publishedVersionId" ON public.workflow_dependency USING btree ("publishedVersionId");


--
-- Name: IDX_workflow_entity_name; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX "IDX_workflow_entity_name" ON public.workflow_entity USING btree (name);


--
-- Name: IDX_workflow_statistics_workflow_name; Type: INDEX; Schema: public; Owner: peter
--

CREATE UNIQUE INDEX "IDX_workflow_statistics_workflow_name" ON public.workflow_statistics USING btree ("workflowId", name);


--
-- Name: idx_07fde106c0b471d8cc80a64fc8; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX idx_07fde106c0b471d8cc80a64fc8 ON public.credentials_entity USING btree (type);


--
-- Name: idx_16f4436789e804e3e1c9eeb240; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX idx_16f4436789e804e3e1c9eeb240 ON public.webhook_entity USING btree ("webhookId", method, "pathLength");


--
-- Name: idx_812eb05f7451ca757fb98444ce; Type: INDEX; Schema: public; Owner: peter
--

CREATE UNIQUE INDEX idx_812eb05f7451ca757fb98444ce ON public.tag_entity USING btree (name);


--
-- Name: idx_execution_entity_stopped_at_status_deleted_at; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX idx_execution_entity_stopped_at_status_deleted_at ON public.execution_entity USING btree ("stoppedAt", status, "deletedAt") WHERE (("stoppedAt" IS NOT NULL) AND ("deletedAt" IS NULL));


--
-- Name: idx_execution_entity_wait_till_status_deleted_at; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX idx_execution_entity_wait_till_status_deleted_at ON public.execution_entity USING btree ("waitTill", status, "deletedAt") WHERE (("waitTill" IS NOT NULL) AND ("deletedAt" IS NULL));


--
-- Name: idx_execution_entity_workflow_id_started_at; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX idx_execution_entity_workflow_id_started_at ON public.execution_entity USING btree ("workflowId", "startedAt") WHERE (("startedAt" IS NOT NULL) AND ("deletedAt" IS NULL));


--
-- Name: idx_workflows_tags_workflow_id; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX idx_workflows_tags_workflow_id ON public.workflows_tags USING btree ("workflowId");


--
-- Name: pk_credentials_entity_id; Type: INDEX; Schema: public; Owner: peter
--

CREATE UNIQUE INDEX pk_credentials_entity_id ON public.credentials_entity USING btree (id);


--
-- Name: pk_tag_entity_id; Type: INDEX; Schema: public; Owner: peter
--

CREATE UNIQUE INDEX pk_tag_entity_id ON public.tag_entity USING btree (id);


--
-- Name: pk_workflow_entity_id; Type: INDEX; Schema: public; Owner: peter
--

CREATE UNIQUE INDEX pk_workflow_entity_id ON public.workflow_entity USING btree (id);


--
-- Name: project_relation_role_idx; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX project_relation_role_idx ON public.project_relation USING btree (role);


--
-- Name: project_relation_role_project_idx; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX project_relation_role_project_idx ON public.project_relation USING btree ("projectId", role);


--
-- Name: user_role_idx; Type: INDEX; Schema: public; Owner: peter
--

CREATE INDEX user_role_idx ON public."user" USING btree ("roleSlug");


--
-- Name: variables_global_key_unique; Type: INDEX; Schema: public; Owner: peter
--

CREATE UNIQUE INDEX variables_global_key_unique ON public.variables USING btree (key) WHERE ("projectId" IS NULL);


--
-- Name: variables_project_key_unique; Type: INDEX; Schema: public; Owner: peter
--

CREATE UNIQUE INDEX variables_project_key_unique ON public.variables USING btree ("projectId", key) WHERE ("projectId" IS NOT NULL);


--
-- Name: workflow_entity workflow_version_increment; Type: TRIGGER; Schema: public; Owner: peter
--

CREATE TRIGGER workflow_version_increment BEFORE UPDATE ON public.workflow_entity FOR EACH ROW EXECUTE FUNCTION public.increment_workflow_version();


--
-- Name: workflow_builder_session FK_00290cdeee4d4d7db84709be936; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.workflow_builder_session
    ADD CONSTRAINT "FK_00290cdeee4d4d7db84709be936" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: processed_data FK_06a69a7032c97a763c2c7599464; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.processed_data
    ADD CONSTRAINT "FK_06a69a7032c97a763c2c7599464" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: workflow_entity FK_08d6c67b7f722b0039d9d5ed620; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.workflow_entity
    ADD CONSTRAINT "FK_08d6c67b7f722b0039d9d5ed620" FOREIGN KEY ("activeVersionId") REFERENCES public.workflow_history("versionId") ON DELETE RESTRICT;


--
-- Name: project_secrets_provider_access FK_18e5c27d2524b1638b292904e48; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.project_secrets_provider_access
    ADD CONSTRAINT "FK_18e5c27d2524b1638b292904e48" FOREIGN KEY ("secretsProviderConnectionId") REFERENCES public.secrets_provider_connection(id) ON DELETE CASCADE;


--
-- Name: insights_metadata FK_1d8ab99d5861c9388d2dc1cf733; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.insights_metadata
    ADD CONSTRAINT "FK_1d8ab99d5861c9388d2dc1cf733" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE SET NULL;


--
-- Name: workflow_history FK_1e31657f5fe46816c34be7c1b4b; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.workflow_history
    ADD CONSTRAINT "FK_1e31657f5fe46816c34be7c1b4b" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: chat_hub_messages FK_1f4998c8a7dec9e00a9ab15550e; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_messages
    ADD CONSTRAINT "FK_1f4998c8a7dec9e00a9ab15550e" FOREIGN KEY ("revisionOfMessageId") REFERENCES public.chat_hub_messages(id) ON DELETE CASCADE;


--
-- Name: oauth_user_consents FK_21e6c3c2d78a097478fae6aaefa; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.oauth_user_consents
    ADD CONSTRAINT "FK_21e6c3c2d78a097478fae6aaefa" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: insights_metadata FK_2375a1eda085adb16b24615b69c; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.insights_metadata
    ADD CONSTRAINT "FK_2375a1eda085adb16b24615b69c" FOREIGN KEY ("projectId") REFERENCES public.project(id) ON DELETE SET NULL;


--
-- Name: chat_hub_messages FK_25c9736e7f769f3a005eef4b372; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_messages
    ADD CONSTRAINT "FK_25c9736e7f769f3a005eef4b372" FOREIGN KEY ("retryOfMessageId") REFERENCES public.chat_hub_messages(id) ON DELETE CASCADE;


--
-- Name: chat_hub_agent_tools FK_2b53d796b3dbae91b1a9553c048; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_agent_tools
    ADD CONSTRAINT "FK_2b53d796b3dbae91b1a9553c048" FOREIGN KEY ("agentId") REFERENCES public.chat_hub_agents(id) ON DELETE CASCADE;


--
-- Name: execution_metadata FK_31d0b4c93fb85ced26f6005cda3; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.execution_metadata
    ADD CONSTRAINT "FK_31d0b4c93fb85ced26f6005cda3" FOREIGN KEY ("executionId") REFERENCES public.execution_entity(id) ON DELETE CASCADE;


--
-- Name: shared_credentials FK_416f66fc846c7c442970c094ccf; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.shared_credentials
    ADD CONSTRAINT "FK_416f66fc846c7c442970c094ccf" FOREIGN KEY ("credentialsId") REFERENCES public.credentials_entity(id) ON DELETE CASCADE;


--
-- Name: variables FK_42f6c766f9f9d2edcc15bdd6e9b; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.variables
    ADD CONSTRAINT "FK_42f6c766f9f9d2edcc15bdd6e9b" FOREIGN KEY ("projectId") REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: chat_hub_agent_tools FK_43e70f04c53344f82483d0570f6; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_agent_tools
    ADD CONSTRAINT "FK_43e70f04c53344f82483d0570f6" FOREIGN KEY ("toolId") REFERENCES public.chat_hub_tools(id) ON DELETE CASCADE;


--
-- Name: chat_hub_agents FK_441ba2caba11e077ce3fbfa2cd8; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_agents
    ADD CONSTRAINT "FK_441ba2caba11e077ce3fbfa2cd8" FOREIGN KEY ("ownerId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: workflow_published_version FK_5c76fb7ee939fe2530374d3f75a; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.workflow_published_version
    ADD CONSTRAINT "FK_5c76fb7ee939fe2530374d3f75a" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE RESTRICT;


--
-- Name: project_relation FK_5f0643f6717905a05164090dde7; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.project_relation
    ADD CONSTRAINT "FK_5f0643f6717905a05164090dde7" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: project_relation FK_61448d56d61802b5dfde5cdb002; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.project_relation
    ADD CONSTRAINT "FK_61448d56d61802b5dfde5cdb002" FOREIGN KEY ("projectId") REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: insights_by_period FK_6414cfed98daabbfdd61a1cfbc0; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.insights_by_period
    ADD CONSTRAINT "FK_6414cfed98daabbfdd61a1cfbc0" FOREIGN KEY ("metaId") REFERENCES public.insights_metadata("metaId") ON DELETE CASCADE;


--
-- Name: oauth_authorization_codes FK_64d965bd072ea24fb6da55468cd; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.oauth_authorization_codes
    ADD CONSTRAINT "FK_64d965bd072ea24fb6da55468cd" FOREIGN KEY ("clientId") REFERENCES public.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: chat_hub_session_tools FK_6596a328affd8d4967ffb303eee; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_session_tools
    ADD CONSTRAINT "FK_6596a328affd8d4967ffb303eee" FOREIGN KEY ("toolId") REFERENCES public.chat_hub_tools(id) ON DELETE CASCADE;


--
-- Name: chat_hub_messages FK_6afb260449dd7a9b85355d4e0c9; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_messages
    ADD CONSTRAINT "FK_6afb260449dd7a9b85355d4e0c9" FOREIGN KEY ("executionId") REFERENCES public.execution_entity(id) ON DELETE SET NULL;


--
-- Name: insights_raw FK_6e2e33741adef2a7c5d66befa4e; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.insights_raw
    ADD CONSTRAINT "FK_6e2e33741adef2a7c5d66befa4e" FOREIGN KEY ("metaId") REFERENCES public.insights_metadata("metaId") ON DELETE CASCADE;


--
-- Name: workflow_publish_history FK_6eab5bd9eedabe9c54bd879fc40; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.workflow_publish_history
    ADD CONSTRAINT "FK_6eab5bd9eedabe9c54bd879fc40" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE SET NULL;


--
-- Name: dynamic_credential_user_entry FK_6edec973a6450990977bb854c38; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.dynamic_credential_user_entry
    ADD CONSTRAINT "FK_6edec973a6450990977bb854c38" FOREIGN KEY ("resolverId") REFERENCES public.dynamic_credential_resolver(id) ON DELETE CASCADE;


--
-- Name: oauth_access_tokens FK_7234a36d8e49a1fa85095328845; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT "FK_7234a36d8e49a1fa85095328845" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: installed_nodes FK_73f857fc5dce682cef8a99c11dbddbc969618951; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.installed_nodes
    ADD CONSTRAINT "FK_73f857fc5dce682cef8a99c11dbddbc969618951" FOREIGN KEY (package) REFERENCES public.installed_packages("packageName") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: oauth_access_tokens FK_78b26968132b7e5e45b75876481; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT "FK_78b26968132b7e5e45b75876481" FOREIGN KEY ("clientId") REFERENCES public.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: workflow_builder_session FK_7983c618db48f47bf5a4cc1e1e4; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.workflow_builder_session
    ADD CONSTRAINT "FK_7983c618db48f47bf5a4cc1e1e4" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: chat_hub_sessions FK_7bc13b4c7e6afbfaf9be326c189; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_sessions
    ADD CONSTRAINT "FK_7bc13b4c7e6afbfaf9be326c189" FOREIGN KEY ("credentialId") REFERENCES public.credentials_entity(id) ON DELETE SET NULL;


--
-- Name: folder FK_804ea52f6729e3940498bd54d78; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.folder
    ADD CONSTRAINT "FK_804ea52f6729e3940498bd54d78" FOREIGN KEY ("parentFolderId") REFERENCES public.folder(id) ON DELETE CASCADE;


--
-- Name: shared_credentials FK_812c2852270da1247756e77f5a4; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.shared_credentials
    ADD CONSTRAINT "FK_812c2852270da1247756e77f5a4" FOREIGN KEY ("projectId") REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: test_case_execution FK_8e4b4774db42f1e6dda3452b2af; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.test_case_execution
    ADD CONSTRAINT "FK_8e4b4774db42f1e6dda3452b2af" FOREIGN KEY ("testRunId") REFERENCES public.test_run(id) ON DELETE CASCADE;


--
-- Name: data_table_column FK_930b6e8faaf88294cef23484160; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.data_table_column
    ADD CONSTRAINT "FK_930b6e8faaf88294cef23484160" FOREIGN KEY ("dataTableId") REFERENCES public.data_table(id) ON DELETE CASCADE;


--
-- Name: dynamic_credential_user_entry FK_945ba70b342a066d1306b12ccd2; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.dynamic_credential_user_entry
    ADD CONSTRAINT "FK_945ba70b342a066d1306b12ccd2" FOREIGN KEY ("credentialId") REFERENCES public.credentials_entity(id) ON DELETE CASCADE;


--
-- Name: folder_tag FK_94a60854e06f2897b2e0d39edba; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.folder_tag
    ADD CONSTRAINT "FK_94a60854e06f2897b2e0d39edba" FOREIGN KEY ("folderId") REFERENCES public.folder(id) ON DELETE CASCADE;


--
-- Name: execution_annotations FK_97f863fa83c4786f19565084960; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.execution_annotations
    ADD CONSTRAINT "FK_97f863fa83c4786f19565084960" FOREIGN KEY ("executionId") REFERENCES public.execution_entity(id) ON DELETE CASCADE;


--
-- Name: chat_hub_agents FK_9c61ad497dcbae499c96a6a78ba; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_agents
    ADD CONSTRAINT "FK_9c61ad497dcbae499c96a6a78ba" FOREIGN KEY ("credentialId") REFERENCES public.credentials_entity(id) ON DELETE SET NULL;


--
-- Name: chat_hub_sessions FK_9f9293d9f552496c40e0d1a8f80; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_sessions
    ADD CONSTRAINT "FK_9f9293d9f552496c40e0d1a8f80" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE SET NULL;


--
-- Name: execution_annotation_tags FK_a3697779b366e131b2bbdae2976; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.execution_annotation_tags
    ADD CONSTRAINT "FK_a3697779b366e131b2bbdae2976" FOREIGN KEY ("tagId") REFERENCES public.annotation_tag_entity(id) ON DELETE CASCADE;


--
-- Name: dynamic_credential_user_entry FK_a36dc616fabc3f736bb82410a22; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.dynamic_credential_user_entry
    ADD CONSTRAINT "FK_a36dc616fabc3f736bb82410a22" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: shared_workflow FK_a45ea5f27bcfdc21af9b4188560; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.shared_workflow
    ADD CONSTRAINT "FK_a45ea5f27bcfdc21af9b4188560" FOREIGN KEY ("projectId") REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: workflow_dependency FK_a4ff2d9b9628ea988fa9e7d0bf8; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.workflow_dependency
    ADD CONSTRAINT "FK_a4ff2d9b9628ea988fa9e7d0bf8" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: oauth_user_consents FK_a651acea2f6c97f8c4514935486; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.oauth_user_consents
    ADD CONSTRAINT "FK_a651acea2f6c97f8c4514935486" FOREIGN KEY ("clientId") REFERENCES public.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_refresh_tokens FK_a699f3ed9fd0c1b19bc2608ac53; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.oauth_refresh_tokens
    ADD CONSTRAINT "FK_a699f3ed9fd0c1b19bc2608ac53" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: dynamic_credential_entry FK_a6d1dd080958304a47a02952aab; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.dynamic_credential_entry
    ADD CONSTRAINT "FK_a6d1dd080958304a47a02952aab" FOREIGN KEY (credential_id) REFERENCES public.credentials_entity(id) ON DELETE CASCADE;


--
-- Name: folder FK_a8260b0b36939c6247f385b8221; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.folder
    ADD CONSTRAINT "FK_a8260b0b36939c6247f385b8221" FOREIGN KEY ("projectId") REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: oauth_authorization_codes FK_aa8d3560484944c19bdf79ffa16; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.oauth_authorization_codes
    ADD CONSTRAINT "FK_aa8d3560484944c19bdf79ffa16" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: chat_hub_messages FK_acf8926098f063cdbbad8497fd1; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_messages
    ADD CONSTRAINT "FK_acf8926098f063cdbbad8497fd1" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE SET NULL;


--
-- Name: oauth_refresh_tokens FK_b388696ce4d8be7ffbe8d3e4b69; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.oauth_refresh_tokens
    ADD CONSTRAINT "FK_b388696ce4d8be7ffbe8d3e4b69" FOREIGN KEY ("clientId") REFERENCES public.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: workflow_publish_history FK_b4cfbc7556d07f36ca177f5e473; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.workflow_publish_history
    ADD CONSTRAINT "FK_b4cfbc7556d07f36ca177f5e473" FOREIGN KEY ("versionId") REFERENCES public.workflow_history("versionId") ON DELETE CASCADE;


--
-- Name: chat_hub_tools FK_b8030b47af9213f1fd15450fb7f; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_tools
    ADD CONSTRAINT "FK_b8030b47af9213f1fd15450fb7f" FOREIGN KEY ("ownerId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: project_secrets_provider_access FK_bd264b81209355b543878deedb1; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.project_secrets_provider_access
    ADD CONSTRAINT "FK_bd264b81209355b543878deedb1" FOREIGN KEY ("projectId") REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: workflow_publish_history FK_c01316f8c2d7101ec4fa9809267; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.workflow_publish_history
    ADD CONSTRAINT "FK_c01316f8c2d7101ec4fa9809267" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: execution_annotation_tags FK_c1519757391996eb06064f0e7c8; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.execution_annotation_tags
    ADD CONSTRAINT "FK_c1519757391996eb06064f0e7c8" FOREIGN KEY ("annotationId") REFERENCES public.execution_annotations(id) ON DELETE CASCADE;


--
-- Name: data_table FK_c2a794257dee48af7c9abf681de; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.data_table
    ADD CONSTRAINT "FK_c2a794257dee48af7c9abf681de" FOREIGN KEY ("projectId") REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: project_relation FK_c6b99592dc96b0d836d7a21db91; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.project_relation
    ADD CONSTRAINT "FK_c6b99592dc96b0d836d7a21db91" FOREIGN KEY (role) REFERENCES public.role(slug);


--
-- Name: chat_hub_messages FK_chat_hub_messages_agentId; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_messages
    ADD CONSTRAINT "FK_chat_hub_messages_agentId" FOREIGN KEY ("agentId") REFERENCES public.chat_hub_agents(id) ON DELETE SET NULL;


--
-- Name: chat_hub_sessions FK_chat_hub_sessions_agentId; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_sessions
    ADD CONSTRAINT "FK_chat_hub_sessions_agentId" FOREIGN KEY ("agentId") REFERENCES public.chat_hub_agents(id) ON DELETE SET NULL;


--
-- Name: dynamic_credential_entry FK_d61a12235d268a49af6a3c09c13; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.dynamic_credential_entry
    ADD CONSTRAINT "FK_d61a12235d268a49af6a3c09c13" FOREIGN KEY (resolver_id) REFERENCES public.dynamic_credential_resolver(id) ON DELETE CASCADE;


--
-- Name: test_run FK_d6870d3b6e4c185d33926f423c8; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.test_run
    ADD CONSTRAINT "FK_d6870d3b6e4c185d33926f423c8" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: shared_workflow FK_daa206a04983d47d0a9c34649ce; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.shared_workflow
    ADD CONSTRAINT "FK_daa206a04983d47d0a9c34649ce" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: folder_tag FK_dc88164176283de80af47621746; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.folder_tag
    ADD CONSTRAINT "FK_dc88164176283de80af47621746" FOREIGN KEY ("tagId") REFERENCES public.tag_entity(id) ON DELETE CASCADE;


--
-- Name: workflow_published_version FK_df3428a541b802d6a63ac56e330; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.workflow_published_version
    ADD CONSTRAINT "FK_df3428a541b802d6a63ac56e330" FOREIGN KEY ("publishedVersionId") REFERENCES public.workflow_history("versionId") ON DELETE RESTRICT;


--
-- Name: user_api_keys FK_e131705cbbc8fb589889b02d457; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.user_api_keys
    ADD CONSTRAINT "FK_e131705cbbc8fb589889b02d457" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: chat_hub_messages FK_e22538eb50a71a17954cd7e076c; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_messages
    ADD CONSTRAINT "FK_e22538eb50a71a17954cd7e076c" FOREIGN KEY ("sessionId") REFERENCES public.chat_hub_sessions(id) ON DELETE CASCADE;


--
-- Name: test_case_execution FK_e48965fac35d0f5b9e7f51d8c44; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.test_case_execution
    ADD CONSTRAINT "FK_e48965fac35d0f5b9e7f51d8c44" FOREIGN KEY ("executionId") REFERENCES public.execution_entity(id) ON DELETE SET NULL;


--
-- Name: chat_hub_messages FK_e5d1fa722c5a8d38ac204746662; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_messages
    ADD CONSTRAINT "FK_e5d1fa722c5a8d38ac204746662" FOREIGN KEY ("previousMessageId") REFERENCES public.chat_hub_messages(id) ON DELETE CASCADE;


--
-- Name: chat_hub_session_tools FK_e649bf1295f4ed8d4299ed290f9; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_session_tools
    ADD CONSTRAINT "FK_e649bf1295f4ed8d4299ed290f9" FOREIGN KEY ("sessionId") REFERENCES public.chat_hub_sessions(id) ON DELETE CASCADE;


--
-- Name: chat_hub_sessions FK_e9ecf8ede7d989fcd18790fe36a; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.chat_hub_sessions
    ADD CONSTRAINT "FK_e9ecf8ede7d989fcd18790fe36a" FOREIGN KEY ("ownerId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: user FK_eaea92ee7bfb9c1b6cd01505d56; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT "FK_eaea92ee7bfb9c1b6cd01505d56" FOREIGN KEY ("roleSlug") REFERENCES public.role(slug);


--
-- Name: role_scope FK_role; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.role_scope
    ADD CONSTRAINT "FK_role" FOREIGN KEY ("roleSlug") REFERENCES public.role(slug) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: role_scope FK_scope; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.role_scope
    ADD CONSTRAINT "FK_scope" FOREIGN KEY ("scopeSlug") REFERENCES public.scope(slug) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: auth_identity auth_identity_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.auth_identity
    ADD CONSTRAINT "auth_identity_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."user"(id);


--
-- Name: credentials_entity credentials_entity_resolverId_foreign; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.credentials_entity
    ADD CONSTRAINT "credentials_entity_resolverId_foreign" FOREIGN KEY ("resolverId") REFERENCES public.dynamic_credential_resolver(id) ON DELETE SET NULL;


--
-- Name: execution_data execution_data_fk; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.execution_data
    ADD CONSTRAINT execution_data_fk FOREIGN KEY ("executionId") REFERENCES public.execution_entity(id) ON DELETE CASCADE;


--
-- Name: execution_entity fk_execution_entity_workflow_id; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.execution_entity
    ADD CONSTRAINT fk_execution_entity_workflow_id FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: webhook_entity fk_webhook_entity_workflow_id; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.webhook_entity
    ADD CONSTRAINT fk_webhook_entity_workflow_id FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: workflow_entity fk_workflow_parent_folder; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.workflow_entity
    ADD CONSTRAINT fk_workflow_parent_folder FOREIGN KEY ("parentFolderId") REFERENCES public.folder(id) ON DELETE CASCADE;


--
-- Name: workflows_tags fk_workflows_tags_tag_id; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.workflows_tags
    ADD CONSTRAINT fk_workflows_tags_tag_id FOREIGN KEY ("tagId") REFERENCES public.tag_entity(id) ON DELETE CASCADE;


--
-- Name: workflows_tags fk_workflows_tags_workflow_id; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.workflows_tags
    ADD CONSTRAINT fk_workflows_tags_workflow_id FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: project projects_creatorId_foreign; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT "projects_creatorId_foreign" FOREIGN KEY ("creatorId") REFERENCES public."user"(id) ON DELETE SET NULL;


--
-- Name: sources sources_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: peter
--

ALTER TABLE ONLY public.sources
    ADD CONSTRAINT sources_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.region(id);


--
-- PostgreSQL database dump complete
--

\unrestrict Ja7Ohe5pgtYg4p8eQcfHlyn7YPEcrGhkBEzNzYtfFZpz0l16e4OX91Gyb2HOibe

