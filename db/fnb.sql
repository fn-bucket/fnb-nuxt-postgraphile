--
-- PostgreSQL database dump
--

-- Dumped from database version 15.0 (Debian 15.0-1.pgdg110+1)
-- Dumped by pg_dump version 15.1

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
-- Name: app; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA app;


ALTER SCHEMA app OWNER TO postgres;

--
-- Name: app_fn; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA app_fn;


ALTER SCHEMA app_fn OWNER TO postgres;

--
-- Name: app_fn_private; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA app_fn_private;


ALTER SCHEMA app_fn_private OWNER TO postgres;

--
-- Name: app_fn_public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA app_fn_public;


ALTER SCHEMA app_fn_public OWNER TO postgres;

--
-- Name: auth_bootstrap; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA auth_bootstrap;


ALTER SCHEMA auth_bootstrap OWNER TO postgres;

--
-- Name: auth_fn; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA auth_fn;


ALTER SCHEMA auth_fn OWNER TO postgres;

--
-- Name: auth_fn_private; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA auth_fn_private;


ALTER SCHEMA auth_fn_private OWNER TO postgres;

--
-- Name: msg; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA msg;


ALTER SCHEMA msg OWNER TO postgres;

--
-- Name: msg_fn; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA msg_fn;


ALTER SCHEMA msg_fn OWNER TO postgres;

--
-- Name: postgraphile_watch; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA postgraphile_watch;


ALTER SCHEMA postgraphile_watch OWNER TO postgres;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: shard_1; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA shard_1;


ALTER SCHEMA shard_1 OWNER TO postgres;

--
-- Name: app_route_menu_behavior; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.app_route_menu_behavior AS ENUM (
    'none',
    'module',
    'navbar'
);


ALTER TYPE app.app_route_menu_behavior OWNER TO postgres;

--
-- Name: app_tenant_payment_status; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.app_tenant_payment_status AS ENUM (
    'current',
    'warning',
    'delinquent'
);


ALTER TYPE app.app_tenant_payment_status OWNER TO postgres;

--
-- Name: app_tenant_payment_status_summary_result; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.app_tenant_payment_status_summary_result AS (
	status app.app_tenant_payment_status
);


ALTER TYPE app.app_tenant_payment_status_summary_result OWNER TO postgres;

--
-- Name: app_tenant_type; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.app_tenant_type AS ENUM (
    'anchor',
    'customer',
    'subsidiary',
    'test',
    'demo',
    'tutorial',
    'pending'
);


ALTER TYPE app.app_tenant_type OWNER TO postgres;

--
-- Name: application_setting; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.application_setting AS (
	key text,
	name text,
	value text
);


ALTER TYPE app.application_setting OWNER TO postgres;

--
-- Name: application_setting_scope; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.application_setting_scope AS ENUM (
    'applicaton',
    'license_pack_anchor',
    'app_tenant',
    'app_user'
);


ALTER TYPE app.application_setting_scope OWNER TO postgres;

--
-- Name: application_setting_type; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.application_setting_type AS ENUM (
    'string',
    'number',
    'array'
);


ALTER TYPE app.application_setting_type OWNER TO postgres;

--
-- Name: setting_accepted_value; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.setting_accepted_value AS (
	label text,
	value text
);


ALTER TYPE app.setting_accepted_value OWNER TO postgres;

--
-- Name: application_setting_config; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.application_setting_config AS (
	key text,
	name text,
	scope app.application_setting_scope,
	type app.application_setting_type,
	accepted_values app.setting_accepted_value[],
	ordinal integer,
	default_value text,
	value text,
	tenant_edit_key text
);


ALTER TYPE app.application_setting_config OWNER TO postgres;

--
-- Name: contact_status; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.contact_status AS ENUM (
    'active',
    'inactive'
);


ALTER TYPE app.contact_status OWNER TO postgres;

--
-- Name: contact_type; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.contact_type AS ENUM (
    'individual',
    'group'
);


ALTER TYPE app.contact_type OWNER TO postgres;

--
-- Name: error_report_status; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.error_report_status AS ENUM (
    'captured',
    'working',
    'addressed'
);


ALTER TYPE app.error_report_status OWNER TO postgres;

--
-- Name: expiration_interval; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.expiration_interval AS ENUM (
    'none',
    'minute',
    'hour',
    'day',
    'week',
    'month',
    'quarter',
    'year',
    'explicit'
);


ALTER TYPE app.expiration_interval OWNER TO postgres;

--
-- Name: license_pack_availability; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.license_pack_availability AS ENUM (
    'published',
    'draft',
    'discontinued'
);


ALTER TYPE app.license_pack_availability OWNER TO postgres;

--
-- Name: license_pack_type; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.license_pack_type AS ENUM (
    'anchor',
    'addon'
);


ALTER TYPE app.license_pack_type OWNER TO postgres;

--
-- Name: license_type_upgrade; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.license_type_upgrade AS (
	source_license_type_key text,
	target_license_type_key text
);


ALTER TYPE app.license_type_upgrade OWNER TO postgres;

--
-- Name: renewal_frequency; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.renewal_frequency AS ENUM (
    'never',
    'weekly',
    'monthly',
    'quarterly',
    'yearly',
    'expires'
);


ALTER TYPE app.renewal_frequency OWNER TO postgres;

--
-- Name: upgrade_path; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.upgrade_path AS (
	license_pack_key text,
	license_type_upgrades app.license_type_upgrade[]
);


ALTER TYPE app.upgrade_path OWNER TO postgres;

--
-- Name: upgrade_config; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.upgrade_config AS (
	upgrade_paths app.upgrade_path[]
);


ALTER TYPE app.upgrade_config OWNER TO postgres;

--
-- Name: id_generator(integer); Type: FUNCTION; Schema: shard_1; Owner: postgres
--

CREATE FUNCTION shard_1.id_generator(shard_id integer DEFAULT 1) RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    our_epoch bigint := 1314220021721;
    seq_id bigint;
    now_millis bigint;
    presult bigint;
    result text;
BEGIN
    SELECT nextval('shard_1.global_id_sequence') % 1024 INTO seq_id;

    SELECT FLOOR(EXTRACT(EPOCH FROM clock_timestamp()) * 1000) INTO now_millis;
    presult := (now_millis - our_epoch) << 23;
    presult := presult | (shard_id << 10);
    presult := presult | (seq_id);
    result := presult::text;
    return result;
END;
$$;


ALTER FUNCTION shard_1.id_generator(shard_id integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: license_pack; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.license_pack (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    key text NOT NULL,
    name text NOT NULL,
    availability app.license_pack_availability DEFAULT 'draft'::app.license_pack_availability NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    published_at timestamp with time zone,
    discontinued_at timestamp with time zone,
    type app.license_pack_type NOT NULL,
    renewal_frequency app.renewal_frequency DEFAULT 'monthly'::app.renewal_frequency NOT NULL,
    expiration_interval app.expiration_interval DEFAULT 'none'::app.expiration_interval NOT NULL,
    expiration_interval_multiplier integer DEFAULT 1 NOT NULL,
    explicit_expiration_date date,
    price numeric(10,2) DEFAULT 0 NOT NULL,
    upgrade_config app.upgrade_config DEFAULT ROW(ARRAY[]::app.upgrade_path[])::app.upgrade_config NOT NULL,
    available_add_on_keys text[] DEFAULT '{}'::text[] NOT NULL,
    coupon_code text,
    is_public_offering boolean,
    application_settings app.application_setting[],
    implicit_add_on_keys text[] DEFAULT '{}'::text[] NOT NULL
);


ALTER TABLE app.license_pack OWNER TO postgres;

--
-- Name: license_pack_sibling_set; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.license_pack_sibling_set AS (
	published app.license_pack,
	draft app.license_pack,
	discontinued app.license_pack[]
);


ALTER TYPE app.license_pack_sibling_set OWNER TO postgres;

--
-- Name: license_status; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.license_status AS ENUM (
    'active',
    'inactive',
    'expired',
    'void'
);


ALTER TYPE app.license_status OWNER TO postgres;

--
-- Name: license_status_reason; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.license_status_reason AS ENUM (
    'initial',
    'adjustment',
    'account_deletion',
    'consolidation',
    'subscription_deactivation'
);


ALTER TYPE app.license_status_reason OWNER TO postgres;

--
-- Name: order_direction; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.order_direction AS ENUM (
    'asc',
    'desc'
);


ALTER TYPE app.order_direction OWNER TO postgres;

--
-- Name: permission_key; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.permission_key AS ENUM (
    'Admin',
    'SuperAdmin',
    'Demon',
    'Tenant',
    'Support',
    'Demo',
    'User'
);


ALTER TYPE app.permission_key OWNER TO postgres;

--
-- Name: license_pack_license_type; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.license_pack_license_type (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    license_type_key text NOT NULL,
    license_pack_id text NOT NULL,
    license_count integer DEFAULT 1 NOT NULL,
    assign_upon_subscription boolean DEFAULT false NOT NULL,
    unlimited_provision boolean DEFAULT false NOT NULL,
    expiration_interval app.expiration_interval DEFAULT 'none'::app.expiration_interval NOT NULL,
    expiration_interval_multiplier integer DEFAULT 1 NOT NULL,
    explicit_expiration_date date
);


ALTER TABLE app.license_pack_license_type OWNER TO postgres;

--
-- Name: subscription_available_license_type; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.subscription_available_license_type AS (
	license_pack_license_type app.license_pack_license_type,
	provisioned_count integer,
	active_count integer,
	inactive_count integer,
	available_count integer,
	can_provision boolean,
	void_count integer,
	expired_count integer
);


ALTER TYPE app.subscription_available_license_type OWNER TO postgres;

--
-- Name: subscription_renewal_behavior; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.subscription_renewal_behavior AS ENUM (
    'renew',
    'expire',
    'ask_admin'
);


ALTER TYPE app.subscription_renewal_behavior OWNER TO postgres;

--
-- Name: content_slug_info; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.content_slug_info AS (
	entity_identifier text,
	key text,
	description text,
	content text,
	data jsonb
);


ALTER TYPE app_fn.content_slug_info OWNER TO postgres;

--
-- Name: app_route_info; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.app_route_info AS (
	name text,
	application_key text,
	permission_key text,
	description text,
	path text,
	menu_behavior app.app_route_menu_behavior,
	menu_parent_name text,
	menu_ordinal integer,
	content_slugs app_fn.content_slug_info[]
);


ALTER TYPE app_fn.app_route_info OWNER TO postgres;

--
-- Name: app_structure; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.app_structure AS (
	key text,
	name text,
	app_routes app_fn.app_route_info[]
);


ALTER TYPE app_fn.app_structure OWNER TO postgres;

--
-- Name: app_tenant_group_info; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.app_tenant_group_info AS (
	name text,
	support_email text,
	id text
);


ALTER TYPE app_fn.app_tenant_group_info OWNER TO postgres;

--
-- Name: app_tenant_search_options; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.app_tenant_search_options AS (
	type app.app_tenant_type,
	search_string text
);


ALTER TYPE app_fn.app_tenant_search_options OWNER TO postgres;

--
-- Name: license_type_info; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.license_type_info AS (
	name text,
	key text,
	application_key text,
	permission_key app.permission_key,
	permissions text[],
	sync_user_on_assignment boolean
);


ALTER TYPE app_fn.license_type_info OWNER TO postgres;

--
-- Name: application_info; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.application_info AS (
	name text,
	key text,
	license_type_infos app_fn.license_type_info[],
	app_structure app_fn.app_structure,
	setting_configs app.application_setting_config[]
);


ALTER TYPE app_fn.application_info OWNER TO postgres;

--
-- Name: app_tenant_auth0_info; Type: TYPE; Schema: auth_fn; Owner: postgres
--

CREATE TYPE auth_fn.app_tenant_auth0_info AS (
	id text,
	name text
);


ALTER TYPE auth_fn.app_tenant_auth0_info OWNER TO postgres;

--
-- Name: app_user_auth0_info; Type: TYPE; Schema: auth_fn; Owner: postgres
--

CREATE TYPE auth_fn.app_user_auth0_info AS (
	permission_key text,
	username text,
	inactive boolean,
	app_tenant_name text,
	app_tenant_id text,
	parent_app_tenant_id text,
	subsidiaries auth_fn.app_tenant_auth0_info[],
	app_user_id text,
	preferred_timezone text,
	contact_id text,
	first_name text,
	last_name text,
	recovery_email text,
	app_role text,
	permissions text[],
	home_path text,
	licensing_scope text[],
	ext_auth_id text,
	ext_auth_blocked boolean
);


ALTER TYPE auth_fn.app_user_auth0_info OWNER TO postgres;

--
-- Name: auth0_workflow_request; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.auth0_workflow_request AS (
	app_user_auth0_info auth_fn.app_user_auth0_info
);


ALTER TYPE app_fn.auth0_workflow_request OWNER TO postgres;

--
-- Name: create_contact_input; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.create_contact_input AS (
	organization_id text,
	location_id text,
	email text,
	first_name text,
	last_name text,
	cell_phone text,
	office_phone text,
	title text,
	nickname text,
	external_id text
);


ALTER TYPE app_fn.create_contact_input OWNER TO postgres;

--
-- Name: error_report_info; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.error_report_info AS (
	reported_by_app_user_id text,
	reported_as_app_user_id text,
	comment text,
	operation_name text,
	observed_count integer,
	message text,
	variables jsonb
);


ALTER TYPE app_fn.error_report_info OWNER TO postgres;

--
-- Name: error_report_search_options; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.error_report_search_options AS (
	app_user_id text,
	operation_name text,
	start_time timestamp without time zone,
	end_time timestamp without time zone,
	search_term text,
	result_limit integer,
	result_offset integer,
	status app.error_report_status
);


ALTER TYPE app_fn.error_report_search_options OWNER TO postgres;

--
-- Name: housekeeping_task; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.housekeeping_task AS (
	key text,
	data jsonb
);


ALTER TYPE app_fn.housekeeping_task OWNER TO postgres;

--
-- Name: license_pack_license_type_info; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.license_pack_license_type_info AS (
	id text,
	license_pack_key text,
	license_type_key text,
	license_count integer,
	assign_upon_subscription boolean,
	unlimited_provision boolean,
	expiration_interval app.expiration_interval,
	expiration_interval_multiplier integer,
	explicit_expiration_date date
);


ALTER TYPE app_fn.license_pack_license_type_info OWNER TO postgres;

--
-- Name: license_pack_info; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.license_pack_info AS (
	id text,
	key text,
	name text,
	renewal_frequency app.renewal_frequency,
	expiration_interval app.expiration_interval,
	expiration_interval_multiplier integer,
	explicit_expiration_date date,
	price numeric(10,2),
	license_type_infos app_fn.license_pack_license_type_info[],
	content_slugs app_fn.content_slug_info[],
	upgrade_config app.upgrade_config,
	type app.license_pack_type,
	available_add_on_keys text[],
	coupon_code text,
	is_public_offering boolean,
	application_settings app.application_setting[],
	implicit_add_on_keys text[]
);


ALTER TYPE app_fn.license_pack_info OWNER TO postgres;

--
-- Name: license_pack_key_versions_result; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.license_pack_key_versions_result AS (
	key text,
	type app.license_pack_type,
	draft app.license_pack,
	published app.license_pack,
	discontinued app.license_pack[]
);


ALTER TYPE app_fn.license_pack_key_versions_result OWNER TO postgres;

--
-- Name: licensing_status; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.licensing_status AS ENUM (
    'current',
    'inactive',
    'expired'
);


ALTER TYPE app_fn.licensing_status OWNER TO postgres;

--
-- Name: line_chart_parsing; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.line_chart_parsing AS (
	y_axis_key text
);


ALTER TYPE app_fn.line_chart_parsing OWNER TO postgres;

--
-- Name: line_chart_dataset; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.line_chart_dataset AS (
	label text,
	fill boolean,
	border_color text,
	parsing app_fn.line_chart_parsing,
	y_axis_id text,
	data text[]
);


ALTER TYPE app_fn.line_chart_dataset OWNER TO postgres;

--
-- Name: line_chart_data; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.line_chart_data AS (
	labels text[],
	datasets app_fn.line_chart_dataset[]
);


ALTER TYPE app_fn.line_chart_data OWNER TO postgres;

--
-- Name: new_app_user_info; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.new_app_user_info AS (
	username text,
	app_tenant_id text,
	ext_auth_id text,
	ext_crm_id text,
	contact_info app_fn.create_contact_input
);


ALTER TYPE app_fn.new_app_user_info OWNER TO postgres;

--
-- Name: new_app_tenant_info; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.new_app_tenant_info AS (
	name text,
	identifier text,
	registration_complete boolean,
	type app.app_tenant_type,
	parent_app_tenant_id text,
	admin_user_info app_fn.new_app_user_info
);


ALTER TYPE app_fn.new_app_tenant_info OWNER TO postgres;

--
-- Name: note_info; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.note_info AS (
	id text,
	content text
);


ALTER TYPE app_fn.note_info OWNER TO postgres;

--
-- Name: subscribe_new_app_tenant_info; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.subscribe_new_app_tenant_info AS (
	license_pack_key text,
	new_app_tenant_info app_fn.new_app_tenant_info
);


ALTER TYPE app_fn.subscribe_new_app_tenant_info OWNER TO postgres;

--
-- Name: supportable_app_tenant_info; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.supportable_app_tenant_info AS (
	id text,
	name text,
	anchor_subscription_key text
);


ALTER TYPE app_fn.supportable_app_tenant_info OWNER TO postgres;

--
-- Name: update_contact_info_input; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.update_contact_info_input AS (
	first_name text,
	last_name text,
	office_phone text,
	cell_phone text
);


ALTER TYPE app_fn.update_contact_info_input OWNER TO postgres;

--
-- Name: brochure_contact_input; Type: TYPE; Schema: app_fn_public; Owner: postgres
--

CREATE TYPE app_fn_public.brochure_contact_input AS (
	company_name text,
	contact_info app_fn.create_contact_input,
	message text
);


ALTER TYPE app_fn_public.brochure_contact_input OWNER TO postgres;

--
-- Name: contact; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.contact (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status app.contact_status DEFAULT 'active'::app.contact_status NOT NULL,
    type app.contact_type DEFAULT 'individual'::app.contact_type NOT NULL,
    organization_id text,
    location_id text,
    external_id text,
    first_name text,
    last_name text,
    email text,
    cell_phone text,
    office_phone text,
    title text,
    nickname text
);


ALTER TABLE app.contact OWNER TO postgres;

--
-- Name: brochure_contact_result; Type: TYPE; Schema: app_fn_public; Owner: postgres
--

CREATE TYPE app_fn_public.brochure_contact_result AS (
	app_user_auth0_info auth_fn.app_user_auth0_info,
	contact app.contact,
	message text
);


ALTER TYPE app_fn_public.brochure_contact_result OWNER TO postgres;

--
-- Name: pricing_info; Type: TYPE; Schema: app_fn_public; Owner: postgres
--

CREATE TYPE app_fn_public.pricing_info AS (
	contact app.contact
);


ALTER TYPE app_fn_public.pricing_info OWNER TO postgres;

--
-- Name: registration_info; Type: TYPE; Schema: app_fn_public; Owner: postgres
--

CREATE TYPE app_fn_public.registration_info AS (
	company_name text,
	email text,
	first_name text,
	last_name text,
	phone text,
	license_pack_key text
);


ALTER TYPE app_fn_public.registration_info OWNER TO postgres;

--
-- Name: request_pricing_info; Type: TYPE; Schema: app_fn_public; Owner: postgres
--

CREATE TYPE app_fn_public.request_pricing_info AS (
	company_name text,
	contact_info app_fn.create_contact_input,
	library_id text
);


ALTER TYPE app_fn_public.request_pricing_info OWNER TO postgres;

--
-- Name: subscribe_from_brochure_input; Type: TYPE; Schema: app_fn_public; Owner: postgres
--

CREATE TYPE app_fn_public.subscribe_from_brochure_input AS (
	license_pack_key text,
	new_app_tenant_info app_fn.new_app_tenant_info,
	request_custom_plan boolean
);


ALTER TYPE app_fn_public.subscribe_from_brochure_input OWNER TO postgres;

--
-- Name: subscribe_from_brochure_result; Type: TYPE; Schema: app_fn_public; Owner: postgres
--

CREATE TYPE app_fn_public.subscribe_from_brochure_result AS (
	app_user_auth0_info auth_fn.app_user_auth0_info,
	custom_plan_requested boolean,
	license_pack app.license_pack
);


ALTER TYPE app_fn_public.subscribe_from_brochure_result OWNER TO postgres;

--
-- Name: jwt_token_bootstrap; Type: TYPE; Schema: auth_bootstrap; Owner: postgres
--

CREATE TYPE auth_bootstrap.jwt_token_bootstrap AS (
	role text,
	app_user_id text,
	app_tenant_id text,
	permissions text,
	current_app_user auth_fn.app_user_auth0_info
);


ALTER TYPE auth_bootstrap.jwt_token_bootstrap OWNER TO postgres;

--
-- Name: app_tenant; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.app_tenant (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name text NOT NULL,
    identifier text,
    organization_id text,
    registration_identifier text DEFAULT shard_1.id_generator() NOT NULL,
    registration_complete boolean DEFAULT false NOT NULL,
    settings jsonb DEFAULT '{}'::jsonb NOT NULL,
    type app.app_tenant_type DEFAULT 'customer'::app.app_tenant_type NOT NULL,
    parent_app_tenant_id text,
    anchor_subscription_id text,
    billing_topic_id text,
    CONSTRAINT app_tenant_check CHECK (((type = 'anchor'::app.app_tenant_type) OR (parent_app_tenant_id IS NOT NULL)))
);


ALTER TABLE app.app_tenant OWNER TO postgres;

--
-- Name: init_demo_result; Type: TYPE; Schema: auth_fn; Owner: postgres
--

CREATE TYPE auth_fn.init_demo_result AS (
	license_pack_key text,
	app_user_auth0_info auth_fn.app_user_auth0_info,
	demo_app_tenant app.app_tenant
);


ALTER TYPE auth_fn.init_demo_result OWNER TO postgres;

--
-- Name: init_subsidiary_admin_result; Type: TYPE; Schema: auth_fn; Owner: postgres
--

CREATE TYPE auth_fn.init_subsidiary_admin_result AS (
	app_user_auth0_info auth_fn.app_user_auth0_info,
	subsidiary_app_tenant app.app_tenant
);


ALTER TYPE auth_fn.init_subsidiary_admin_result OWNER TO postgres;

--
-- Name: jwt_token; Type: TYPE; Schema: auth_fn; Owner: postgres
--

CREATE TYPE auth_fn.jwt_token AS (
	role text,
	app_user_id text,
	app_tenant_id text
);


ALTER TYPE auth_fn.jwt_token OWNER TO postgres;

--
-- Name: email_status; Type: TYPE; Schema: msg; Owner: postgres
--

CREATE TYPE msg.email_status AS ENUM (
    'requested',
    'sent',
    'received',
    'error'
);


ALTER TYPE msg.email_status OWNER TO postgres;

--
-- Name: message_status; Type: TYPE; Schema: msg; Owner: postgres
--

CREATE TYPE msg.message_status AS ENUM (
    'draft',
    'sent',
    'deleted'
);


ALTER TYPE msg.message_status OWNER TO postgres;

--
-- Name: subscription_status; Type: TYPE; Schema: msg; Owner: postgres
--

CREATE TYPE msg.subscription_status AS ENUM (
    'active',
    'inactive',
    'blocked'
);


ALTER TYPE msg.subscription_status OWNER TO postgres;

--
-- Name: email_request_info; Type: TYPE; Schema: msg_fn; Owner: postgres
--

CREATE TYPE msg_fn.email_request_info AS (
	subject text,
	content text,
	from_address text,
	to_addresses text,
	cc_addresses text,
	bcc_addresses text,
	options jsonb
);


ALTER TYPE msg_fn.email_request_info OWNER TO postgres;

--
-- Name: message_info; Type: TYPE; Schema: msg_fn; Owner: postgres
--

CREATE TYPE msg_fn.message_info AS (
	id text,
	topic_id text,
	content text,
	tags text[]
);


ALTER TYPE msg_fn.message_info OWNER TO postgres;

--
-- Name: subscription_info; Type: TYPE; Schema: msg_fn; Owner: postgres
--

CREATE TYPE msg_fn.subscription_info AS (
	topic_id text,
	subscriber_contact_id text
);


ALTER TYPE msg_fn.subscription_info OWNER TO postgres;

--
-- Name: topic_info; Type: TYPE; Schema: msg_fn; Owner: postgres
--

CREATE TYPE msg_fn.topic_info AS (
	id text,
	name text,
	identifier text
);


ALTER TYPE msg_fn.topic_info OWNER TO postgres;

--
-- Name: app_user; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.app_user (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    ext_auth_id text,
    ext_crm_id text,
    contact_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    username text NOT NULL,
    recovery_email text NOT NULL,
    inactive boolean DEFAULT false NOT NULL,
    password_reset_required boolean DEFAULT false NOT NULL,
    permission_key app.permission_key NOT NULL,
    is_support boolean DEFAULT false NOT NULL,
    preferred_timezone text DEFAULT 'PST8PDT'::text NOT NULL,
    settings jsonb DEFAULT '{}'::jsonb NOT NULL,
    ext_auth_blocked boolean DEFAULT false NOT NULL,
    language_id text DEFAULT 'en'::text NOT NULL
);


ALTER TABLE app.app_user OWNER TO postgres;

--
-- Name: app_tenant_active_guest_users(app.app_tenant); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.app_tenant_active_guest_users(_app_tenant app.app_tenant) RETURNS SETOF app.app_user
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
  BEGIN
    return query
      select distinct
        u.*
      from app.app_user u
      join app.license l on l.assigned_to_app_user_id = u.id
      where u.app_tenant_id = _app_tenant.id
      and u.inactive = false
      and l.license_type_key like '%-guest-user'
      and u.permission_key in ('SuperAdmin', 'Admin', 'User')
    ;

  END
  $$;


ALTER FUNCTION app.app_tenant_active_guest_users(_app_tenant app.app_tenant) OWNER TO postgres;

--
-- Name: app_tenant_subscription; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.app_tenant_subscription (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    created_date date DEFAULT (CURRENT_TIMESTAMP)::date NOT NULL,
    expiration_date date,
    renewal_behavior app.subscription_renewal_behavior DEFAULT 'ask_admin'::app.subscription_renewal_behavior NOT NULL,
    is_anchor_subscription boolean DEFAULT true NOT NULL,
    inactive boolean DEFAULT false NOT NULL,
    app_tenant_id text NOT NULL,
    license_pack_id text NOT NULL,
    payment_processor_info jsonb DEFAULT '{}'::jsonb NOT NULL,
    parent_app_tenant_subscription_id text
);


ALTER TABLE app.app_tenant_subscription OWNER TO postgres;

--
-- Name: app_tenant_active_subscriptions(app.app_tenant); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.app_tenant_active_subscriptions(_app_tenant app.app_tenant) RETURNS SETOF app.app_tenant_subscription
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
  _app_tenant_id text;
BEGIN
  if _app_tenant.type = 'subsidiary' then
    _app_tenant_id = _app_tenant.parent_app_tenant_id;
  else
    _app_tenant_id = _app_tenant.id;
  end if;

  return query
  select ats.*
  from app.app_tenant_subscription ats
  where app_tenant_id = _app_tenant_id
  and inactive = false
  ;
END
$$;


ALTER FUNCTION app.app_tenant_active_subscriptions(_app_tenant app.app_tenant) OWNER TO postgres;

--
-- Name: app_tenant_active_users(app.app_tenant); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.app_tenant_active_users(_app_tenant app.app_tenant) RETURNS SETOF app.app_user
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
  BEGIN
    return query
      select distinct
        u.*
      from app.app_user u
      left join app.license l on l.assigned_to_app_user_id = u.id
      where u.app_tenant_id = _app_tenant.id
      and u.inactive = false
      and (l.license_type_key is null or l.license_type_key != '%-guest-user')
      and u.permission_key in ('SuperAdmin', 'Admin', 'User')
    ;

  END
  $$;


ALTER FUNCTION app.app_tenant_active_users(_app_tenant app.app_tenant) OWNER TO postgres;

--
-- Name: app_tenant_available_licenses(app.app_tenant); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.app_tenant_available_licenses(_app_tenant app.app_tenant) RETURNS SETOF app.subscription_available_license_type
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
DECLARE
  _app_tenant_id text;
  _subscription app.app_tenant_subscription;
  _result app.subscription_available_license_type;
  _all_results app.subscription_available_license_type[];
BEGIN
  _all_results := '{}'::app.subscription_available_license_type[];

  -- need to first pull the anchor subscription for the app tenant, then do the following with the app_tenant_id from that
  select * into _subscription from app.app_tenant_subscription where id = _app_tenant.anchor_subscription_id;

  for _subscription in
    select * from app.app_tenant_subscription where app_tenant_id = _subscription.app_tenant_id
  loop
    for _result in
      (select * from app.app_tenant_subscription_available_licenses(_subscription))
    loop
      _all_results := array_append(_all_results, _result);
    end loop;
  end loop;

  return query
    select * from unnest(_all_results)
  ;
END
$$;


ALTER FUNCTION app.app_tenant_available_licenses(_app_tenant app.app_tenant) OWNER TO postgres;

--
-- Name: app_tenant_flags(app.app_tenant); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.app_tenant_flags(_app_tenant app.app_tenant) RETURNS jsonb
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    _app_flags jsonb;
    _app_user_id text;
    _app_tenant_is_linked boolean;
    _is_admin_or_therapist boolean;
    _err_context text;
  BEGIN
    _app_user_id := (select auth_fn.current_app_user()->>'app_user_id');

    _is_admin_or_therapist := (
      (
        select count(*) 
        from app.license 
        where assigned_to_app_user_id = _app_user_id
        and inactive = false 
        and (position('admin' in license_type_key::text) > 0 or position('therapist' in license_type_key::text) > 0)
        or (select auth_fn.app_user_has_permission('p:app-tenant-scope'))
      ) > 0
    );

    _app_flags := jsonb_build_object(
      -- 'whateverYouWant', _some_value_or flag
    );

    return _app_flags;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app.app_tenant_flags:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app.app_tenant_flags(_app_tenant app.app_tenant) OWNER TO postgres;

--
-- Name: app_tenant_inactive_guest_users(app.app_tenant); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.app_tenant_inactive_guest_users(_app_tenant app.app_tenant) RETURNS SETOF app.app_user
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
  BEGIN
    return query
      select distinct
        u.*
      from app.app_user u
      join app.license l on l.assigned_to_app_user_id = u.id
      where u.app_tenant_id = _app_tenant.id
      and u.inactive = true
      and l.license_type_key = '%-guest-user'
      and u.permission_key in ('SuperAdmin', 'Admin', 'User')
    ;

  END
  $$;


ALTER FUNCTION app.app_tenant_inactive_guest_users(_app_tenant app.app_tenant) OWNER TO postgres;

--
-- Name: app_tenant_inactive_users(app.app_tenant); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.app_tenant_inactive_users(_app_tenant app.app_tenant) RETURNS SETOF app.app_user
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
  BEGIN
    return query
      select distinct
        u.*
      from app.app_user u
      left join app.license l on l.assigned_to_app_user_id = u.id
      where u.app_tenant_id = _app_tenant.id
      and u.inactive = true
      and (l.license_type_key is null or l.license_type_key != '%-guest-user')
      and u.permission_key in ('SuperAdmin', 'Admin', 'User')
    ;

  END
  $$;


ALTER FUNCTION app.app_tenant_inactive_users(_app_tenant app.app_tenant) OWNER TO postgres;

--
-- Name: app_tenant_license_type_is_available(text, text); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.app_tenant_license_type_is_available(_app_tenant_id text, _license_type_key text) RETURNS boolean
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
  DECLARE
    _license_pack_license_type app.license_pack_license_type;
    _subscription_available_license_type app.subscription_available_license_type;
    _err_context text;
  BEGIN
    with atal as (
      select
        (app.app_tenant_available_licenses(apt.*)).* al
      from app.app_tenant apt where id = _app_tenant_id
    )
    , cp as (
      select (atal).license_pack_license_type lplt
      from atal
      where can_provision = true
    )
    , lplt as (
      select
        (lplt).*
      from cp
    )
    select *
    into _license_pack_license_type
    from lplt
    where license_type_key = _license_type_key
    ;

    if _license_pack_license_type.id is null then
      return false;
    else
      return true;
    end if;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.app_tenant_license_type_is_available:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
END
$$;


ALTER FUNCTION app.app_tenant_license_type_is_available(_app_tenant_id text, _license_type_key text) OWNER TO postgres;

--
-- Name: app_tenant_payment_status_summary(app.app_tenant); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.app_tenant_payment_status_summary(_app_tenant app.app_tenant) RETURNS app.app_tenant_payment_status_summary_result
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    _err_context text;
    _result app.app_tenant_payment_status_summary_result;
  BEGIN
    select array_agg(bp.*)
    into _result.pastdue_payments
    from bill.payment bp
    where bp.app_tenant_id = _app_tenant.id
    and bp.status = 'pastdue'
    group by bp.billing_date
    order by bp.billing_date desc
    ;
    _result.pastdue_payments := coalesce(_result.pastdue_payments, '{}'::bill.payment[]);

    select array_agg(bp.*)
    into _result.scheduled_payments
    from bill.payment bp
    where bp.app_tenant_id = _app_tenant.id
    and bp.status = 'scheduled'
    group by bp.billing_date
    order by bp.billing_date asc
    ;
    _result.scheduled_payments := coalesce(_result.scheduled_payments, '{}'::bill.payment[]);


    _result.status = (
      select case
        when array_length(_result.pastdue_payments, 1) > 0 then
          'warning'
        when array_length(_result.pastdue_payments, 1) > 2 then
          'delinquent'
        else
          'current'
      end
    );

    return _result;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app.app_tenant_payment_status_summary:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
    END
  $$;


ALTER FUNCTION app.app_tenant_payment_status_summary(_app_tenant app.app_tenant) OWNER TO postgres;

--
-- Name: app_tenant_subscription_available_add_ons(app.app_tenant_subscription); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.app_tenant_subscription_available_add_ons(_app_tenant_subscription app.app_tenant_subscription) RETURNS SETOF app.license_pack
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
  _license_pack app.license_pack;
  _upgrade_config app.upgrade_config;
  _upgrade_path app.upgrade_path;
  _upgrade_paths app.upgrade_path[];
  _upgrade_keys text[];
BEGIN
  select * into _license_pack from app.license_pack where id = _app_tenant_subscription.license_pack_id;

  return query
  select lp.*
  from app.license_pack lp
  where lp.key = any(_license_pack.available_add_on_keys)
  and lp.availability = 'published'
  order by lp.key
  ;

END
$$;


ALTER FUNCTION app.app_tenant_subscription_available_add_ons(_app_tenant_subscription app.app_tenant_subscription) OWNER TO postgres;

--
-- Name: app_tenant_subscription_available_licenses(app.app_tenant_subscription); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.app_tenant_subscription_available_licenses(_app_tenant_subscription app.app_tenant_subscription) RETURNS SETOF app.subscription_available_license_type
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
  DECLARE
    _subscription_id text;
    _retval app.subscription_available_license_type[];
  BEGIN
    _subscription_id := _app_tenant_subscription.id;

    return query
    with lplt as (
      select lplt.*
      from app.license_pack_license_type lplt
      join app.license_pack lp on lp.id = lplt.license_pack_id
      join app.app_tenant_subscription ats on ats.license_pack_id = lp.id
      where ats.id = _subscription_id
    )
    ,p as (
      select
        lplt.license_type_key
        ,(
          select count(*)
          from app.license l
          where l.license_type_key = lplt.license_type_key
          and l.subscription_id = _subscription_id
        ) as provisioned_count
        ,(
          select count(*)
          from app.license l
          where l.license_type_key = lplt.license_type_key
          and l.subscription_id = _subscription_id
          and l.status = 'active'
        ) as active_count
        ,(
          select count(*)
          from app.license l
          where l.license_type_key = lplt.license_type_key
          and l.subscription_id = _subscription_id
          and l.status = 'inactive'
        ) as inactive_count
        ,(
          select count(*)
          from app.license l
          where l.license_type_key = lplt.license_type_key
          and l.subscription_id = _subscription_id
          and l.status = 'void'
        ) as void_count
        ,(
          select count(*)
          from app.license l
          where l.license_type_key = lplt.license_type_key
          and l.subscription_id = _subscription_id
          and l.status = 'expired'
        ) as expired_count
      from lplt
    )
    ,a as (
      select
        (lplt.*)::app.license_pack_license_type
        ,p.provisioned_count::integer
        ,p.active_count::integer
        ,p.inactive_count::integer
        ,case
          when lplt.unlimited_provision = true then null::integer
          else (lplt.license_count - p.provisioned_count)::integer
        end available_count
        ,case
          when _app_tenant_subscription.inactive = true then false
          when lplt.unlimited_provision::boolean then true
          when (lplt.license_count - p.provisioned_count)::integer > 0 then true
          else false
        end::boolean can_provision
        ,p.void_count::integer
        ,p.expired_count::integer
      from p
      join lplt on p.license_type_key = lplt.license_type_key
      and lplt.license_pack_id = _app_tenant_subscription.license_pack_id
    )
    select
      a.*
    from a
    ;
  END
  $$;


ALTER FUNCTION app.app_tenant_subscription_available_licenses(_app_tenant_subscription app.app_tenant_subscription) OWNER TO postgres;

--
-- Name: app_tenant_subscription_available_upgrade_paths(app.app_tenant_subscription); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.app_tenant_subscription_available_upgrade_paths(_app_tenant_subscription app.app_tenant_subscription) RETURNS SETOF app.license_pack
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
  _license_pack app.license_pack;
  _upgrade_config app.upgrade_config;
  _upgrade_path app.upgrade_path;
  _upgrade_paths app.upgrade_path[];
  _upgrade_keys text[];
BEGIN
  select * into _license_pack from app.license_pack where id = _app_tenant_subscription.license_pack_id;

  _upgrade_config := _license_pack.upgrade_config;

  if _upgrade_config is null then
    -- return empty set
    return query select * from app.license_pack where true = false;
  end if;

  -- reduce upgrade config to possible keys
  _upgrade_keys := '{}'::text;
  _upgrade_paths := coalesce(_upgrade_config.upgrade_paths, '{}'::app.upgrade_path[]);
  foreach _upgrade_path in array(_upgrade_paths)
  loop
    _upgrade_keys := array_append(_upgrade_keys, _upgrade_path.license_pack_key);
  end loop;

  -- return published license paths from upgrade config
  return query
  select *
  from app.license_pack
  where key = any(_upgrade_keys)
  and availability = 'published'
  ;

END
$$;


ALTER FUNCTION app.app_tenant_subscription_available_upgrade_paths(_app_tenant_subscription app.app_tenant_subscription) OWNER TO postgres;

--
-- Name: license; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.license (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    subscription_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    external_id text,
    name text,
    license_type_key text NOT NULL,
    assigned_to_app_user_id text,
    inactive boolean DEFAULT false NOT NULL,
    expiration_date date,
    status app.license_status NOT NULL,
    status_reason app.license_status_reason DEFAULT 'initial'::app.license_status_reason NOT NULL,
    comment text
);


ALTER TABLE app.license OWNER TO postgres;

--
-- Name: app_user_active_licenses(app.app_user); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.app_user_active_licenses(_app_user app.app_user) RETURNS SETOF app.license
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
DECLARE
  _all_results app.subscription_available_license_type[];
BEGIN
  return query
  select *
  from app.license
  where assigned_to_app_user_id = _app_user.id
  and inactive is false
  and expiration_date > current_timestamp
  ;
END
$$;


ALTER FUNCTION app.app_user_active_licenses(_app_user app.app_user) OWNER TO postgres;

--
-- Name: app_user_home_path(app.app_user); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.app_user_home_path(_app_user app.app_user) RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
  _license app.license;
  _path text;
BEGIN

  select l.*
  into _license
  from app.license l
  where l.assigned_to_app_user_id = _app_user.id
  and l.inactive = false
  order by l.created_at
  limit 1
  ;

  _path := case
    when _app_user.permission_key = 'SuperAdmin' then 'AppTenants'
    else 'Home'
  end;

  return _path;
END
$$;


ALTER FUNCTION app.app_user_home_path(_app_user app.app_user) OWNER TO postgres;

--
-- Name: app_user_licensing_status(app.app_user); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.app_user_licensing_status(_app_user app.app_user) RETURNS app_fn.licensing_status
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
  DECLARE
    _current_license app.license;
    _result app_fn.licensing_status;
    _err_context text;
  BEGIN
    _result := 'expired';
    for _current_license in
      select *
      from app.license
      where assigned_to_app_user_id = _app_user.id
      and (expiration_date is null or expiration_date > current_date)
      and inactive = false
    loop
      if _current_license.expiration_date is null or _current_license.expiration_date > current_date then
        _result := 'current';
        exit;
      end if;
      _result := 'inactive';
    end loop;

    if _result = 'current' and _app_user.inactive = true then
      _result := 'inactive';
    end if;

    return _result;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app.app_user_licensing_status:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app.app_user_licensing_status(_app_user app.app_user) OWNER TO postgres;

--
-- Name: app_user_permissions(app.app_user, text); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.app_user_permissions(_app_user app.app_user, _current_app_tenant_id text) RETURNS text[]
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    _permissions text[];
    _tenant_permissions text[];
  BEGIN
    with keys as (
      select distinct lp.permission_key
      from app.license_permission lp
      join app.license l on l.id = lp.license_id
      join app.app_user u on u.id = l.assigned_to_app_user_id
      where (u.id = _app_user.id)
      and l.inactive = false
      -- and u.inactive = false
      group by lp.permission_key
    )
    select coalesce(array_agg(permission_key), '{}'::text[])
    into _permissions
    from keys
    ;

    -- permissions for app tenant licenses (vision-library, etc.)
    with keys as (
      select distinct ltp.permission_key
      from app.license_type_permission ltp
      join app.license_type lt on lt.key = ltp.license_type_key
      join app.license_pack_license_type lplt on lplt.license_type_key = lt.key
      join app.license_pack lp on lp.id = lplt.license_pack_id
      join app.app_tenant_subscription ats on ats.license_pack_id = lp.id
      where (
        ats.app_tenant_id = _current_app_tenant_id 
          or 
        ats.id = (select anchor_subscription_id from app.app_tenant where id = _app_user.app_tenant_id)
      )      
      and ats.inactive = false
      and lt.permission_key = 'Tenant'
      group by ltp.permission_key
    )
    select coalesce(array_agg(permission_key), '{}'::text[])
    into _tenant_permissions
    from keys
    where permission_key != all(_permissions)
    ;
    _permissions := array_cat(_permissions, _tenant_permissions);

    if _app_user.permission_key = 'SuperAdmin' then
      -- _permissions := array_append(_permissions, 'p:super-admin');
      _permissions := array_append(_permissions, 'm:admin');
      _permissions := array_append(_permissions, 'p:app-tenant-scope');
      _permissions := array_append(_permissions, 'p:manage-subsidiaries');
      _permissions := array_append(_permissions, 'p:demo');
      _permissions := array_append(_permissions, 'p:create-announcement');
    end if;

    if _app_user.permission_key = 'Admin' then
      _permissions := array_append(_permissions, 'p:demo');
      _permissions := array_append(_permissions, 'm:admin');
      _permissions := array_append(_permissions, 'p:create-announcement');
      _permissions := array_append(_permissions, 'p:admin-subsidiaries');
    end if;

    if _app_user.permission_key = 'Support' then
      _permissions := array_append(_permissions, 'm:admin');
      _permissions := array_append(_permissions, 'p:app-tenant-scope');
      _permissions := array_append(_permissions, 'p:support');
      _permissions := array_append(_permissions, 'p:create-announcement');
      _permissions := array_append(_permissions, 'p:admin-subsidiaries');
    end if;

    if _app_user.permission_key = 'Demo' then
      _permissions := array_append(_permissions, 'p:demo');
      _permissions := array_append(_permissions, 'm:admin');
      _permissions := array_append(_permissions, 'p:app-tenant-scope');
      _permissions := array_append(_permissions, 'p:create-announcement');
    end if;

    return _permissions;
  END
  $$;


ALTER FUNCTION app.app_user_permissions(_app_user app.app_user, _current_app_tenant_id text) OWNER TO postgres;

--
-- Name: app_user_primary_license(app.app_user); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.app_user_primary_license(_app_user app.app_user) RETURNS app.license
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
  _license app.license;
BEGIN

  raise notice '_app_user.id: %', _app_user.id;

  select l.*
  into _license
  from app.license l
  where l.assigned_to_app_user_id = _app_user.id
  and l.inactive = false
  order by l.created_at
  limit 1
  ;

  return _license;
END
$$;


ALTER FUNCTION app.app_user_primary_license(_app_user app.app_user) OWNER TO postgres;

--
-- Name: application_no_delete(); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.application_no_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   RAISE EXCEPTION 'You may not delete the application!';
END; $$;


ALTER FUNCTION app.application_no_delete() OWNER TO postgres;

--
-- Name: calculate_license_status(app.license); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.calculate_license_status(_license app.license) RETURNS app.license_status
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    _license_status app.license_status;
  BEGIN
    if _license.status = 'void' then
      return 'void';
    end if;

    if _license.expiration_date < current_date then
      return 'expired';
    end if;

    -- if _license.inactive or _license.status = 'inactive' then
    if _license.inactive then
      return 'inactive';
    end if;

    return 'active';
  END
  $$;


ALTER FUNCTION app.calculate_license_status(_license app.license) OWNER TO postgres;

--
-- Name: contact_full_name(app.contact); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.contact_full_name(_contact app.contact) RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
  _full_name text;
BEGIN
  _full_name := _contact.first_name || ' ' || _contact.last_name;

  return _full_name;
END
$$;


ALTER FUNCTION app.contact_full_name(_contact app.contact) OWNER TO postgres;

--
-- Name: contact_has_unanswered_messages(app.contact); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.contact_has_unanswered_messages(_contact app.contact) RETURNS boolean
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    _message msg.message;
    _last_message msg.message;
    _result boolean;
  BEGIN
    for _message in
      select m.*
      from msg.subscription s
      join msg.topic t on s.topic_id = t.id
      join msg.message m on m.topic_id = t.id
      where s.status = 'active'
      and s.subscriber_contact_id = _contact.id
      and m.posted_by_contact_id = _contact.id
      order by m.created_at desc
      limit 1
    loop
      select m.*
      into _last_message
      from msg.message m
      where m.topic_id = _message.topic_id
      order by m.created_at desc
      limit 1;

      if _last_message.posted_by_contact_id = _message.posted_by_contact_id then
        return true;
      end if;

    end loop;

    return false;
  END
  $$;


ALTER FUNCTION app.contact_has_unanswered_messages(_contact app.contact) OWNER TO postgres;

--
-- Name: create_contact(app_fn.create_contact_input, text); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.create_contact(_contact_info app_fn.create_contact_input, _app_tenant_id text DEFAULT NULL::text) RETURNS app.contact
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _contact app.contact;
    _err_context text;
  BEGIN
    if app_tenant_id is null then
      raise exception 'cannot create contact without app tenant id';
    end if;

    --------------  create contact
    insert into app.contact(
      app_tenant_id
      ,organization_id
      ,location_id
      ,first_name
      ,last_name
      ,email
      ,cell_phone
      ,office_phone
      ,title
      ,nickname
      ,external_id
    )
    values (
      app_tenant_id
      ,_contact_info.organization_id
      ,_contact_info.location_id
      ,_contact_info.first_name
      ,_contact_info.last_name
      ,_contact_info.email
      ,_contact_info.cell_phone
      ,_contact_info.office_phone
      ,_contact_info.title
      ,_contact_info.nickname
      ,_contact_info.external_id
    )
    returning *
    into _contact;

    return _contact;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.create_contact:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app.create_contact(_contact_info app_fn.create_contact_input, _app_tenant_id text) OWNER TO postgres;

--
-- Name: fn_ensure_license_status(); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.fn_ensure_license_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.status := app.calculate_license_status(NEW);
    -- raise exception '%', NEW;
    RETURN NEW;
  END; $$;


ALTER FUNCTION app.fn_ensure_license_status() OWNER TO postgres;

--
-- Name: fn_update_eula_trigger(); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.fn_update_eula_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    if OLD.content != NEW.content then
      raise exception 'cannot update content of eula';
    end if;

    if NEW.is_inactive != true or NEW.deactivated_at is null then
      raise exception 'the only update allowed for eula is deactivation';
    end if;

    RETURN NEW;
  END; $$;


ALTER FUNCTION app.fn_update_eula_trigger() OWNER TO postgres;

--
-- Name: license_can_activate(app.license); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.license_can_activate(_license app.license) RETURNS boolean
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    _can_activate boolean;
  BEGIN

    select ats.inactive = false
    into _can_activate
    from app.app_tenant_subscription ats
    where ats.id = _license.subscription_id
    ;

    return _can_activate;
  END
  $$;


ALTER FUNCTION app.license_can_activate(_license app.license) OWNER TO postgres;

--
-- Name: license_pack_allowed_actions(app.license_pack); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.license_pack_allowed_actions(_license_pack app.license_pack) RETURNS text[]
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
  _allowed_actions text[];
  _draft_exists boolean;
  _published_exists boolean;
BEGIN
  _allowed_actions := '{}'::text[];

  select
    (count(*) > 0)
  into _draft_exists
  from app.license_pack
  where key = _license_pack.key
  and availability = 'draft';

  select
    (count(*) > 0)
  into _published_exists
  from app.license_pack
  where key = _license_pack.key
  and availability = 'published';

  if _license_pack.availability = 'draft' then
    if _published_exists then
      _allowed_actions := '{"publish-confirm", "discard", "edit"}';
    else
      _allowed_actions := '{"publish", "discard", "edit"}';
    end if;
  elsif _license_pack.availability = 'published' then
    if _draft_exists = true then
      _allowed_actions := '{"discontinue"}';
    else
      _allowed_actions := '{"discontinue", "clone"}';
    end if;
  elsif _license_pack.availability = 'discontinued' then
    if _draft_exists = true then
      _allowed_actions := '{}';
    else
      _allowed_actions := '{"clone"}';
    end if;
  end if;

  return _allowed_actions;
END
$$;


ALTER FUNCTION app.license_pack_allowed_actions(_license_pack app.license_pack) OWNER TO postgres;

--
-- Name: license_pack_candidate_add_on_keys(app.license_pack); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.license_pack_candidate_add_on_keys(_license_pack app.license_pack) RETURNS text[]
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
  _candidate_add_on_keys text[];
BEGIN

  with ao as(
    select lp.key
    from app.license_pack lp
    where lp.type = 'addon'
    and lp.availability != 'discontinued'
    order by lp.key
  )
  ,fao as (
    select *
    from ao
    where key not in (select unnest(_license_pack.available_add_on_keys))
  )
  select array_agg(fao.key)
  into _candidate_add_on_keys
  from fao
  ;

  return _candidate_add_on_keys;
END
$$;


ALTER FUNCTION app.license_pack_candidate_add_on_keys(_license_pack app.license_pack) OWNER TO postgres;

--
-- Name: license_pack_candidate_license_type_keys(app.license_pack); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.license_pack_candidate_license_type_keys(_license_pack app.license_pack) RETURNS text[]
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
  _candidate_license_type_keys text[];
BEGIN

  _candidate_license_type_keys := '{}'::text[];

  select array_agg(lt.key)
  into _candidate_license_type_keys
  from app.license_type lt
  where key not in (
    select license_type_key
    from app.license_pack_license_type
    where license_pack_id = _license_pack.id
  )
  ;

  return _candidate_license_type_keys;
END
$$;


ALTER FUNCTION app.license_pack_candidate_license_type_keys(_license_pack app.license_pack) OWNER TO postgres;

--
-- Name: license_pack_candidate_upgrade_path_keys(app.license_pack); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.license_pack_candidate_upgrade_path_keys(_license_pack app.license_pack) RETURNS text[]
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
  _upgrade_path app.upgrade_path;
  _current_upgrade_path_keys text[];
  _candidate_upgrade_path_keys text[];
BEGIN

  _current_upgrade_path_keys := '{}'::text[];
  foreach _upgrade_path in array((_license_pack.upgrade_config).upgrade_paths)
  loop
    _current_upgrade_path_keys := array_append(_current_upgrade_path_keys, _upgrade_path.license_pack_key);
  end loop;

  with anchors as(
    select distinct key
    from app.license_pack
    where type = 'anchor'
    and availability != 'discontinued'
    and key != _license_pack.key
  )
  select array_agg(anchors.key)
  into _candidate_upgrade_path_keys
  from anchors
  where key not in (select unnest(_current_upgrade_path_keys))
  ;

  return _candidate_upgrade_path_keys;
END
$$;


ALTER FUNCTION app.license_pack_candidate_upgrade_path_keys(_license_pack app.license_pack) OWNER TO postgres;

--
-- Name: license_pack_discontinued_add_ons(app.license_pack); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.license_pack_discontinued_add_ons(_license_pack app.license_pack) RETURNS app.license_pack[]
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
  _discontinued_add_ons app.license_pack[];
BEGIN
  with p as (
    select lp.*
    from app.license_pack lp
    where lp.key = any(_license_pack.available_add_on_keys)
    and lp.availability in ('discontinued')
    and lp.key not in (
      select key from app.license_pack_draft_add_ons(_license_pack)
    )
    and lp.key not in (
      select key from app.license_pack_published_add_ons(_license_pack)
    )
    order by lp.key
  )
  select array_agg(p.*)
  into _discontinued_add_ons
  from p
  ;

  return _discontinued_add_ons;

END
$$;


ALTER FUNCTION app.license_pack_discontinued_add_ons(_license_pack app.license_pack) OWNER TO postgres;

--
-- Name: license_pack_draft_add_ons(app.license_pack); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.license_pack_draft_add_ons(_license_pack app.license_pack) RETURNS app.license_pack[]
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
  _draft_add_ons app.license_pack[];
BEGIN
  with p as (
    select lp.*
    from app.license_pack lp
    where lp.key = any(_license_pack.available_add_on_keys)
    and lp.availability = 'draft'
    order by lp.key
  )
  select array_agg(p.*)
  into _draft_add_ons
  from p
  ;

  return _draft_add_ons;

END
$$;


ALTER FUNCTION app.license_pack_draft_add_ons(_license_pack app.license_pack) OWNER TO postgres;

--
-- Name: license_pack_published_add_ons(app.license_pack); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.license_pack_published_add_ons(_license_pack app.license_pack) RETURNS app.license_pack[]
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
  _published_add_ons app.license_pack[];
BEGIN
  with p as (
    select lp.*
    from app.license_pack lp
    where lp.key = any(_license_pack.available_add_on_keys)
    and lp.availability = 'published'
    order by lp.key
  )
  select array_agg(p.*)
  into _published_add_ons
  from p
  ;

  return _published_add_ons;

END
$$;


ALTER FUNCTION app.license_pack_published_add_ons(_license_pack app.license_pack) OWNER TO postgres;

--
-- Name: license_pack_published_implicit_add_ons(app.license_pack); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.license_pack_published_implicit_add_ons(_license_pack app.license_pack) RETURNS app.license_pack[]
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    _published_implicit_add_ons app.license_pack[];
  BEGIN
    with p as (
      select lp.*
      from app.license_pack lp
      where lp.key = any(_license_pack.available_implicit_add_on_keys)
      and lp.availability = 'published'
      order by lp.key
    )
    select array_agg(p.*)
    into _published_implicit_add_ons
    from p
    ;

    return _published_implicit_add_ons;

  END
  $$;


ALTER FUNCTION app.license_pack_published_implicit_add_ons(_license_pack app.license_pack) OWNER TO postgres;

--
-- Name: license_pack_siblings(app.license_pack); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.license_pack_siblings(_license_pack app.license_pack) RETURNS app.license_pack_sibling_set
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
  _sibling_set app.license_pack_sibling_set;
  _published app.license_pack;
  _draft app.license_pack;
  _discontinued app.license_pack[];
BEGIN

  select * into _published from app.license_pack where key = _license_pack.key and availability = 'published';
  select * into _draft from app.license_pack where key = _license_pack.key and availability = 'draft';

  with d as (
    select lp.*
    from app.license_pack lp
    where lp.key = _license_pack.key
    and lp.availability = 'discontinued'
    order by discontinued_at desc
  )
  select coalesce(array_agg(d.*::app.license_pack), '{}'::app.license_pack[]) into _discontinued from d;

  _sibling_set.published = _published;
  _sibling_set.draft = _draft;
  _sibling_set.discontinued = _discontinued;

  return _sibling_set;
END
$$;


ALTER FUNCTION app.license_pack_siblings(_license_pack app.license_pack) OWNER TO postgres;

--
-- Name: set_app_tenant_setting_to_default(text); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.set_app_tenant_setting_to_default(_app_tenant_id text) RETURNS app.app_tenant
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _default_settings jsonb;
    _application_setting_configs app.application_setting_config[];
    _application_setting_config app.application_setting_config;
    _asc_jsonb jsonb;
    _app_tenant app.app_tenant;
  BEGIN
    -- select to_jsonb(settings) into _default_settings from app.app_tenant where id = _app_tenant_id;
    -- _default_settings := '{}';

    -- foreach _application_setting_config in array(_application_setting_configs)
    -- loop
    --   _asc_jsonb := to_jsonb(_application_setting_config);
    --   _default_settings := _default_settings || jsonb_build_object(_asc_jsonb->>'key', _asc_jsonb->>'default_value');
    -- end loop;

    -- update app.app_tenant set settings = _default_settings where id = _app_tenant_id returning * into _app_tenant;

    return _app_tenant;
  END
  $$;


ALTER FUNCTION app.set_app_tenant_setting_to_default(_app_tenant_id text) OWNER TO postgres;

--
-- Name: activate_app_tenant_subscription(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.activate_app_tenant_subscription(_app_tenant_subscription_id text) RETURNS app.app_tenant_subscription
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _app_tenant_subscription app.app_tenant_subscription;
    _err_context text;
  BEGIN
    update app.app_tenant_subscription set
      inactive = false
    where id = _app_tenant_subscription_id
    returning *
    into _app_tenant_subscription;

    return _app_tenant_subscription;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.activate_app_tenant_subscription:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.activate_app_tenant_subscription(_app_tenant_subscription_id text) OWNER TO postgres;

--
-- Name: activate_license(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.activate_license(_license_id text) RETURNS app.license
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _license app.license;
    _app_tenant_subscription app.app_tenant_subscription;
    _err_context text;
  BEGIN

    select ats.*
    into _app_tenant_subscription
    from app.app_tenant_subscription ats
    join app.license l on ats.id = l.subscription_id
    ;

    if _app_tenant_subscription.inactive = true then
      raise exception 'cannot activate a license for an inactive subscription';
    end if;

    update app.license set
      inactive = false
    where id = _license_id
    returning *
    into _license;

    return _license;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.activate_license:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.activate_license(_license_id text) OWNER TO postgres;

--
-- Name: supported_language; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.supported_language (
    id text NOT NULL,
    name text NOT NULL,
    inactive boolean DEFAULT true NOT NULL
);


ALTER TABLE app.supported_language OWNER TO postgres;

--
-- Name: activate_supported_language(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.activate_supported_language(_language_id text) RETURNS app.supported_language
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _language app.supported_language;
    _err_context text;
  BEGIN
    update app.supported_language set inactive = false where id = _language_id returning * into _language;
    
    return _language;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.activate_supported_language:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.activate_supported_language(_language_id text) OWNER TO postgres;

--
-- Name: app_tenant_group_member; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.app_tenant_group_member (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_group_id text NOT NULL,
    app_tenant_id text NOT NULL
);


ALTER TABLE app.app_tenant_group_member OWNER TO postgres;

--
-- Name: add_app_tenant_group_member(text, text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.add_app_tenant_group_member(_app_tenant_group_id text, _app_tenant_id text) RETURNS app.app_tenant_group_member
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _err_context text;
    _app_tenant_group_member app.app_tenant_group_member;
  BEGIN
    insert into app.app_tenant_group_member(
      app_tenant_group_id
      ,app_tenant_id
    ) values (
      _app_tenant_group_id
      ,_app_tenant_id
    ) on conflict (
      app_tenant_group_id
      ,app_tenant_id
    ) do update set
      app_tenant_id = _app_tenant_id
    returning *
    into _app_tenant_group_member
    ;

    return _app_tenant_group_member;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.add_app_tenant_group_member:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.add_app_tenant_group_member(_app_tenant_group_id text, _app_tenant_id text) OWNER TO postgres;

--
-- Name: error_report; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.error_report (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    first_reported_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_reported_at timestamp with time zone NOT NULL,
    observed_count integer,
    message text,
    comment text,
    reported_by_app_user_id text,
    reported_as_app_user_id text,
    operation_name text NOT NULL,
    variables jsonb NOT NULL,
    status app.error_report_status DEFAULT 'captured'::app.error_report_status NOT NULL
);


ALTER TABLE app.error_report OWNER TO postgres;

--
-- Name: address_error_report(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.address_error_report(_error_report_id text) RETURNS app.error_report
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _error_report app.error_report;
    _err_context text;
  BEGIN
    update app.error_report set status = 'addressed' where id = _error_report_id returning * into _error_report;

    return _error_report;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.address_error_report:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.address_error_report(_error_report_id text) OWNER TO postgres;

--
-- Name: after_user_license_assigned(text, text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.after_user_license_assigned(_license_type_key text, _assigned_to_app_user_id text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _app_user app.app_user;
    _app_tenant app.app_tenant;
    _existing_license app.license;
    _err_context text;
  BEGIN
    -- select * into _app_user from app.app_user where id = _assigned_to_app_user_id;
    -- select * into _app_tenant from app.app_tenant where id = _app_user.app_tenant_id;

    -- if _license_type_key like 'some-license' then
    --   insert into some.table(id, app_tenant_id, app_user_id, contact_id)
    --   values (
    --     _assigned_to_app_user_id
    --     ,_app_user.app_tenant_id
    --     ,_assigned_to_app_user_id
    --     ,_app_user.contact_id
    --   )
    --   on conflict (app_user_id)
    --   do nothing
    --   ;
    -- elsif _license_type_key like 'some-license' then
    --   insert into some.table(id, app_tenant_id, app_user_id, contact_id)
    --   values (
    --     _assigned_to_app_user_id
    --     ,_app_user.app_tenant_id
    --     ,_assigned_to_app_user_id
    --     ,_app_user.contact_id
    --   )
    --   on conflict (app_user_id)
    --   do nothing
    --   ;
    -- end if;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.after_user_license_assigned:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.after_user_license_assigned(_license_type_key text, _assigned_to_app_user_id text) OWNER TO postgres;

--
-- Name: FUNCTION after_user_license_assigned(_license_type_key text, _assigned_to_app_user_id text); Type: COMMENT; Schema: app_fn; Owner: postgres
--

COMMENT ON FUNCTION app_fn.after_user_license_assigned(_license_type_key text, _assigned_to_app_user_id text) IS '@omit';


--
-- Name: app_tenant_search(app_fn.app_tenant_search_options); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.app_tenant_search(_options app_fn.app_tenant_search_options DEFAULT ROW('customer'::app.app_tenant_type, NULL::text)) RETURNS SETOF app.app_tenant
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    _err_context text;
  BEGIN
    _options.type := coalesce(_options.type, 'customer');

    return query
      select t.*
      from app.app_tenant t
      where (_options.type = t.type)
      and (_options.search_string is null or position(_options.search_string in t.name) > 0)
      order by name
      ;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.app_tenant_search:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.app_tenant_search(_options app_fn.app_tenant_search_options) OWNER TO postgres;

--
-- Name: app_tenant_subsidiaries(); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.app_tenant_subsidiaries() RETURNS SETOF app.app_tenant
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
DECLARE
  _app_tenant app.app_tenant;
BEGIN
  if auth_fn.current_app_user()->>'permission_key' = 'Admin' then
    return query
    select * from app.app_tenant where parent_app_tenant_id = auth_fn.current_app_user()->>'app_tenant_id';
  end if;

  if auth_fn.current_app_user()->>'permission_key' in ('Support', 'SuperAdmin') then
    return query
    select * from app.app_tenant where parent_app_tenant_id = auth_fn.current_app_user()->>'app_tenant_id';
  end if;
END
$$;


ALTER FUNCTION app_fn.app_tenant_subsidiaries() OWNER TO postgres;

--
-- Name: assign_license_to_user(text, text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.assign_license_to_user(_license_id text, _app_user_id text) RETURNS app.license
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _license app.license;
    _err_context text;
  BEGIN
    update app.license set
      inactive = true
    where license_type_key = (select license_type_key from app.license where id = _license_id)
    and assigned_to_app_user_id = _app_user_id
    ;

    update app.license
    set assigned_to_app_user_id = _app_user_id
    where id = _license_id
    returning *
    into _license;

    return _license;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.assign_license_to_user:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.assign_license_to_user(_license_id text, _app_user_id text) OWNER TO postgres;

--
-- Name: calculate_upgrade_config(app.license_pack); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.calculate_upgrade_config(_license_pack app.license_pack) RETURNS app.upgrade_config
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _old_upgrade_config app.upgrade_config;
    _new_upgrade_config app.upgrade_config;
    _old_upgrade_path app.upgrade_path;
    _new_upgrade_path app.upgrade_path;
    _new_upgrade_paths app.upgrade_path[];
    _new_license_type_upgrade app.license_type_upgrade;
    _new_license_type_upgrades app.license_type_upgrade[];
    _old_license_type_upgrade app.license_type_upgrade;
    _target_license_pack app.license_pack;
    _license_pack_license_type_key text;
    _err_context text;
  BEGIN
  -- this function ensures that all upgrade paths have explicit mappings in place for all possible license types
  -- maybe not really necessary so may rip it out

    _old_upgrade_config := coalesce(_license_pack.upgrade_config,row('{}'::app.upgrade_path[])::app.upgrade_config);
    _new_upgrade_config := row('{}');
    _new_upgrade_paths := '{}'::app.upgrade_path[];

    foreach _old_upgrade_path in array(_old_upgrade_config.upgrade_paths)
    loop
      _new_upgrade_path := row(_old_upgrade_path.license_pack_key,'{}');
      _new_license_type_upgrades := '{}';

      for _license_pack_license_type_key in
        with ltk as (
          select distinct license_type_key from app.license_pack_license_type where license_pack_id = _license_pack.id
          union
          select distinct license_type_key from app.license_pack_license_type where license_pack_id in (
            select id from app.license_pack where key = any(_license_pack.available_add_on_keys) and availability != 'discontinued'
          )
        )
        select distinct license_type_key from ltk
      loop
        _new_license_type_upgrade := null;
        foreach _old_license_type_upgrade in array(_old_upgrade_path.license_type_upgrades)
        loop
          if _old_license_type_upgrade.source_license_type_key = _license_pack_license_type_key then
            _new_license_type_upgrade := _old_license_type_upgrade;
            exit;
          end if;
        end loop;
        _new_license_type_upgrade := coalesce(
          _new_license_type_upgrade
          ,row(
            _license_pack_license_type_key
            ,_license_pack_license_type_key
          )::app.license_type_upgrade
        );
        _new_license_type_upgrades := array_append(_new_license_type_upgrades, _new_license_type_upgrade);
      end loop;

      _new_upgrade_path.license_type_upgrades = _new_license_type_upgrades;
      _new_upgrade_paths := array_append(_new_upgrade_paths, _new_upgrade_path);
    end loop;

    _new_upgrade_config.upgrade_paths := _new_upgrade_paths;

    return _new_upgrade_config;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.calculate_upgrade_config:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.calculate_upgrade_config(_license_pack app.license_pack) OWNER TO postgres;

--
-- Name: change_app_tenant_type(text, app.app_tenant_type); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.change_app_tenant_type(_app_tenant_id text, _app_tenant_type app.app_tenant_type) RETURNS app.app_tenant
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _app_tenant app.app_tenant;
    _err_context text;
  BEGIN
    if auth_fn.current_app_user()->>'permission_key' not in ('Support', 'SuperAdmin') then
      raise exception 'not authorized';
    end if;

    select * into _app_tenant from app.app_tenant where id = _app_tenant_id;

    if _app_tenant.id is null then
      raise exception 'no app tenant for this id: %', _app_tenant_id;
    end if;

    if _app_tenant.type in ('anchor', 'subsidiary', 'demo', 'tutorial') then
      raise exception 'cannot manipulate tenant of type: %', _app_tenant.type;
    end if;

    if _app_tenant.type = 'customer' and _app_tenant_type not in ('pending', 'test') then
      raise exception 'illegal to change app tenant type from % to %', _app_tenant.type, _app_tenant_type;
    end if;

    if _app_tenant.type = 'pending' and _app_tenant_type not in ('customer', 'test') then
      raise exception 'illegal to change app tenant type from % to %', _app_tenant.type, _app_tenant_type;
    end if;

    if _app_tenant.type = 'test' and _app_tenant_type not in ('customer', 'pending') then
      raise exception 'illegal to change app tenant type from % to %', _app_tenant.type, _app_tenant_type;
    end if;

    update app.app_tenant set type = _app_tenant_type where id = _app_tenant.id returning * into _app_tenant;
    return _app_tenant;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.app_tenant_search:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.change_app_tenant_type(_app_tenant_id text, _app_tenant_type app.app_tenant_type) OWNER TO postgres;

--
-- Name: change_app_user_email(text, text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.change_app_user_email(_app_user_id text, _email text) RETURNS auth_fn.app_user_auth0_info
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _app_user app.app_user;
    _app_user_auth0_info auth_fn.app_user_auth0_info;
    _err_context text;
  BEGIN
    select * into _app_user from app.app_user where id = _app_user_id;

    if _app_user.id is null then
      raise exception 'no app user exists for id: %', _app_user_id;
    end if;

    update app.app_user set 
      recovery_email = _email
      ,username = _email
    where id = _app_user.id 
    returning * into _app_user;
    
    update app.contact set
      email = _email
    where id = _app_user.contact_id;
    
    _app_user_auth0_info := (select auth_fn.get_app_user_info(_app_user.recovery_email, _app_user.app_tenant_id));
    
    return _app_user_auth0_info;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.change_app_user_email:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.change_app_user_email(_app_user_id text, _email text) OWNER TO postgres;

--
-- Name: change_license_type(text[], text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.change_license_type(_license_ids text[], _license_type_key text) RETURNS SETOF app.license
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _license app.license;
    _err_context text;
  BEGIN
    for _license in
      select * from app.license where id = any (_license_ids)
    loop

      update app.license set 
        license_type_key = _license_type_key
      where id = _license.id
      returning *
      into _license;

      return next _license;
    end loop;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.change_license_type:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.change_license_type(_license_ids text[], _license_type_key text) OWNER TO postgres;

--
-- Name: check_subscription_for_license_availability(text, app.app_tenant_subscription); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.check_subscription_for_license_availability(_license_type_key text, _app_tenant_subscription app.app_tenant_subscription) RETURNS boolean
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    _issued_count integer;
    _allowed_count integer;
    _allow_unlimited_provision boolean;
    _err_context text;
  BEGIN

    select lplt.unlimited_provision
    into _allow_unlimited_provision
    from app.license_pack_license_type lplt
    where lplt.license_pack_id = _app_tenant_subscription.license_pack_id
    and lplt.license_type_key = _license_type_key;

    if _allow_unlimited_provision = true then
      return true;
    end if;

    select count(*)
    into _issued_count
    from app.license
    where subscription_id = _app_tenant_subscription.id
    and license_type_key = _license_type_key;

    select lplt.license_count
    into _allowed_count
    from app.license_pack_license_type lplt
    where lplt.license_pack_id = _app_tenant_subscription.license_pack_id
    and lplt.license_type_key = _license_type_key;

    if _allowed_count > _issued_count then
      return true;
    else
      return false;
    end if;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.check_subscription_for_license_availability:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.check_subscription_for_license_availability(_license_type_key text, _app_tenant_subscription app.app_tenant_subscription) OWNER TO postgres;

--
-- Name: clone_license_pack(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.clone_license_pack(_id text) RETURNS app.license_pack
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _src_license_pack app.license_pack;
    _tgt_license_pack app.license_pack;
    _err_context text;
  BEGIN

    select *
    into _src_license_pack
    from app.license_pack
    where id = _id;

    if _src_license_pack.id is null then
      raise exception 'no license pack for this id';
    end if;

    if _src_license_pack.availability = 'draft' then
      return _src_license_pack;
    end if;

    select *
    into _tgt_license_pack
    from app.license_pack
    where key = _src_license_pack.key
    and availability = 'draft';

    if _tgt_license_pack.id is not null then
      return _tgt_license_pack;
    end if;

    insert into app.license_pack(
      key
      ,name
      ,availability
      ,type
      ,renewal_frequency
      ,price
      ,upgrade_config
      ,available_add_on_keys
      ,implicit_add_on_keys
      ,is_public_offering
    )
    values(
      _src_license_pack.key
      ,_src_license_pack.name
      ,'draft'
      ,_src_license_pack.type
      ,_src_license_pack.renewal_frequency
      ,_src_license_pack.price
      ,_src_license_pack.upgrade_config
      ,_src_license_pack.available_add_on_keys
      ,_src_license_pack.implicit_add_on_keys
      ,_src_license_pack.is_public_offering
    )
    returning *
    into _tgt_license_pack
    ;

    with lplt as (
      select *
      from app.license_pack_license_type
      where license_pack_id = _src_license_pack.id
    )
    insert into app.license_pack_license_type(
      license_type_key
      ,license_pack_id
      ,license_count
      ,assign_upon_subscription
      ,unlimited_provision
      ,expiration_interval
    )
    select
      lplt.license_type_key
      ,_tgt_license_pack.id
      ,lplt.license_count
      ,lplt.assign_upon_subscription
      ,lplt.unlimited_provision
      ,lplt.expiration_interval
    from lplt
    ;

    return _tgt_license_pack;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.clone_license_pack:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.clone_license_pack(_id text) OWNER TO postgres;

--
-- Name: create_app_tenant(app_fn.new_app_tenant_info); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.create_app_tenant(_new_tenant_info app_fn.new_app_tenant_info) RETURNS app.app_tenant
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _user_info app_fn.new_app_user_info;
    _app_tenant app.app_tenant;
    _contact_info app_fn.create_contact_input;
    _contact app.contact;
    _organization app.organization;
    _app_user app.app_user;
    _anchor_tenant app.app_tenant;
    _err_context text;
  BEGIN
    if _new_tenant_info.type = 'anchor' then
      select *
      into _app_tenant
      from app.app_tenant
      where type = 'anchor'
      ;
    end if;

    if _new_tenant_info.type = 'customer' then
      select *
      into _app_tenant
      from app.app_tenant
      where name = _new_tenant_info.name
      and type = 'customer'
      ;
    end if;

    if _new_tenant_info.type = 'demo' then
      select *
      into _app_tenant
      from app.app_tenant
      where identifier = _new_tenant_info.identifier
      and type = 'demo'
      ;
    end if;

    if _new_tenant_info.type = 'tutorial' then
      select *
      into _app_tenant
      from app.app_tenant
      where identifier = _new_tenant_info.identifier
      and type = 'tutorial'
      ;
    end if;
    -- select *
    -- into _app_tenant
    -- from app.app_tenant
    -- where name = _new_tenant_info.name
    -- ;

    if _app_tenant.id is not null then
      return _app_tenant;
    end if;

    select * into _anchor_tenant from app.app_tenant where type = 'anchor';

    if _anchor_tenant.id is null and _new_tenant_info.identifier != 'anchor' then
      raise exception 'no anchor tenant is configured';
    end if;
-- raise exception '_new_tenant_info: %', jsonb_pretty(to_jsonb(_new_tenant_info));
-- raise exception '_new_tenant_info: %   %   %', _new_tenant_info.parent_app_tenant_id, _anchor_tenant.id, auth_fn.current_app_user()->>'app_tenant_id';
    -- --------------  create the app tenant

    insert into app.app_tenant(
      name
      ,identifier
      ,type
      ,parent_app_tenant_id
    )
    values (
      _new_tenant_info.name
      ,_new_tenant_info.identifier
      ,case
        when _new_tenant_info.identifier = 'anchor' then 'anchor'::app.app_tenant_type
        else coalesce(_new_tenant_info.type, 'customer'::app.app_tenant_type)
      end
      ,case
        when _new_tenant_info.identifier = 'anchor' then null
        else coalesce(_new_tenant_info.parent_app_tenant_id, _anchor_tenant.id)
      end
    )
    returning * into _app_tenant;

    -- raise exception 'cat: %', _app_tenant;

    insert into app.organization(
      app_tenant_id
      ,name
      ,external_id
    )
    select
      _app_tenant.id
      ,_app_tenant.name
      ,_app_tenant.identifier
    on conflict(app_tenant_id, name)
    do nothing
    returning * into _organization
    ;

    update app.app_tenant
    set organization_id = _organization.id
    where id = _app_tenant.id
    returning * into _app_tenant;

    if _app_tenant.identifier != 'anchor' then
      perform app.set_app_tenant_setting_to_default(_app_tenant.id);
    end if;
    if (_new_tenant_info.type = 'customer' or _new_tenant_info.type = 'anchor') and (_new_tenant_info.admin_user_info).username is not null then
      --------------- create the admin user
      _user_info := _new_tenant_info.admin_user_info;
      if _user_info.username is null then
      raise exception 'cannot register user without username';
      end if;

      _contact_info := _user_info.contact_info;
      if _contact_info.email is null then
        raise exception 'cannot register new admin user without email address';
      end if;

      _contact_info.organization_id := _organization.id;

      _user_info.app_tenant_id := _app_tenant.id;
      _user_info.contact_info := _contact_info;

      _app_user := app_fn.create_app_user(_user_info);

      perform app_fn.grant_admin(_app_user.id);
    end if;

    return _app_tenant;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.create_app_tenant:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.create_app_tenant(_new_tenant_info app_fn.new_app_tenant_info) OWNER TO postgres;

--
-- Name: create_app_user(app_fn.new_app_user_info); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.create_app_user(_user_info app_fn.new_app_user_info) RETURNS app.app_user
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _license_pack app.license_pack;
    _contact app.contact;
    _contact_info app_fn.create_contact_input;
    _app_user app.app_user;
    _err_context text;
  BEGIN
    _contact_info := _user_info.contact_info;

    if _contact_info.email is null then
      raise exception 'cannot register user without email address';
    end if;
    select *
    into _contact
    from app.contact
    where app_tenant_id = _user_info.app_tenant_id
    and email = _contact_info.email;

    if _contact.id is null then
      --------------  create contact
      insert into app.contact(
        app_tenant_id
        ,organization_id
        ,first_name
        ,last_name
        ,email
        ,cell_phone
        ,office_phone
        ,title
        ,nickname
        ,external_id
      )
      values (
        _user_info.app_tenant_id
        ,_contact_info.organization_id
        ,_contact_info.first_name
        ,_contact_info.last_name
        ,_contact_info.email
        ,_contact_info.cell_phone
        ,_contact_info.office_phone
        ,_contact_info.title
        ,_contact_info.nickname
        ,_contact_info.external_id
      )
      returning *
      into _contact;
    end if;

    select *
    into _app_user
    from app.app_user
    where username = _user_info.username
    and app_tenant_id = _user_info.app_tenant_id
    ;

    if _app_user.id is null then
      update app.app_user set
        recovery_email = username
      where username = _contact_info.email||'-guest'
      ;
      --------------  create app_user
      insert into app.app_user(
        app_tenant_id
        ,contact_id
        ,username
        ,recovery_email
        ,permission_key
        ,inactive
        ,ext_auth_id
        ,ext_crm_id
        ,language_id
      )
      values (
        _user_info.app_tenant_id
        ,_contact.id
        ,coalesce(_user_info.username, _contact_info.email)
        ,_contact_info.email
        ,'User'
        ,false
        ,_user_info.ext_auth_id
        ,_user_info.ext_crm_id
        ,'en'
      )
      returning *
      into _app_user
      ;
    end if;

    return _app_user;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.create_app_user:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.create_app_user(_user_info app_fn.new_app_user_info) OWNER TO postgres;

--
-- Name: application; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.application (
    key text NOT NULL,
    name text,
    setting_configs app.application_setting_config[]
);


ALTER TABLE app.application OWNER TO postgres;

--
-- Name: create_application(app_fn.application_info); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.create_application(_application_info app_fn.application_info) RETURNS app.application
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _application app.application;
    _license_type_info app_fn.license_type_info;
    _license_type app.license_type;
    _permission_key text;
    _permission app.permission;
    _app_structure app_fn.app_structure;
    _app_route_info app_fn.app_route_info;
    _app_route app.app_route;
    _content_slug_info app_fn.content_slug_info;
    _err_context text;
  BEGIN

    if _application_info.name is null then
      RAISE EXCEPTION 'Must specify application name';
    end if;

    if _application_info.key is null then
      RAISE EXCEPTION 'Must specify application key';
    end if;

    insert into app.application(name ,key, setting_configs)
    values (_application_info.name ,_application_info.key, _application_info.setting_configs)
    on conflict(key)
    do update set
      name = coalesce(_application_info.name, application.name)
    returning *
    into _application
    ;

    _app_structure := _application_info.app_structure;

    _app_structure.app_routes := coalesce(_app_structure.app_routes, '{}'::app_fn.app_route_info[]);

    foreach _app_route_info in array(_app_structure.app_routes)
    loop
      insert into app.app_route(
        name
        ,application_key
        ,permission_key
        ,description
        ,path
        ,menu_behavior
        ,menu_parent_name
        ,menu_ordinal
      )
      values (
        _app_route_info.name
        ,_application.key
        ,_app_route_info.permission_key
        ,_app_route_info.description
        ,_app_route_info.path
        ,_app_route_info.menu_behavior
        ,_app_route_info.menu_parent_name
        ,_app_route_info.menu_ordinal
      )
      on conflict (name)
      do update set
        description = coalesce(_app_route.description, app_route.description)
        ,path = coalesce(_app_route.path, app_route.path)
        ,menu_behavior = coalesce(_app_route.menu_behavior, app_route.menu_behavior)
        ,menu_parent_name = coalesce(_app_route.menu_parent_name, app_route.menu_parent_name)
        ,menu_ordinal = coalesce(_app_route.menu_ordinal, app_route.menu_ordinal)
      returning * into _app_route
      ;

      foreach _content_slug_info in array(_app_route_info.content_slugs)
      loop
        _content_slug_info.entity_type := 'approute';
        _content_slug_info.entity_identifier:= _app_route.id;
        perform app_fn.upsert_content_slug(_content_slug_info);
      end loop;

    end loop;

    foreach _license_type_info in ARRAY _application_info.license_type_infos
    loop
      _license_type := app_fn.create_license_type(_license_type_info);
    end loop;

    return _application;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.create_application:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.create_application(_application_info app_fn.application_info) OWNER TO postgres;

--
-- Name: create_demo_app_tenant(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.create_demo_app_tenant(_license_pack_key text) RETURNS app.app_tenant
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _demo_app_tenant app.app_tenant;
    _identifier text;
    _app_tenant_subscription app.app_tenant_subscription;
    _subscription app.app_tenant_subscription;
    _license_pack app.license_pack;
    _err_context text;
  BEGIN
    if auth_fn.app_user_has_permission('p:demo') = false then
      raise exception 'permission denied';
    end if;

    select * into _license_pack from app.license_pack 
    where key = _license_pack_key 
    and availability = 'published'
    ;

    if _license_pack.id is null then
      raise exception 'no published license pack for key: %', _license_pack_key;
    end if;

    _identifier := 'demo-' || _license_pack_key;

    select * into _demo_app_tenant from app.app_tenant where type = 'demo' and identifier = _identifier;

    if _demo_app_tenant.id is null then
      _app_tenant_subscription := (
        select app_fn.subscribe_to_license_pack_new_tenant(
          _license_pack_key
          ,row(
            'Demo: '||_license_pack.name
            ,_identifier
            ,true
            ,'demo'
            ,auth_fn.current_app_user()->>'app_tenant_id'
            ,null::app_fn.new_app_user_info
          )::app_fn.new_app_tenant_info
        )
      );

      select * into _demo_app_tenant from app.app_tenant where identifier = _identifier;

      -- _subscription need to set this properly
      perform app_fn.create_demo_users(_demo_app_tenant, _app_tenant_subscription, _subscription);
    else
      select * into _app_tenant_subscription from app.app_tenant_subscription
      where id = _demo_app_tenant.anchor_subscription_id
      ;
      update app.license set expiration_date = current_timestamp + '1 year'::interval where app_tenant_id = _demo_app_tenant.id;
    end if;

    return _demo_app_tenant;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.create_demo_app_tenant:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.create_demo_app_tenant(_license_pack_key text) OWNER TO postgres;

--
-- Name: create_demo_users(app.app_tenant, app.app_tenant_subscription, app.app_tenant_subscription); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.create_demo_users(_app_tenant app.app_tenant, _app_tenant_subscription app.app_tenant_subscription, _subscription app.app_tenant_subscription) RETURNS SETOF auth_fn.app_user_auth0_info
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _err_context text;
    _license_type app.license_type;
    _demo_users app_fn.new_app_user_info[];
    _new_app_user_info app_fn.new_app_user_info;
    _app_user app.app_user;
    _app_user_auth0_info auth_fn.app_user_auth0_info;
    _user_count integer;
    _i integer;
  BEGIN
    _demo_users := (select app_fn.demo_user_infos(_app_tenant));
    _user_count = 1;

    for _license_type in
      select
        lt.*
      from app.app_tenant_subscription ats
      join app.license_pack lp on lp.id = ats.license_pack_id
      join app.license_pack_license_type lplt on lplt.license_pack_id = lp.id
      join app.license_type lt on lplt.license_type_key = lt.key
      where lt.permission_key = 'User'
      and ats.app_tenant_id = _app_tenant.id
    loop
      -- for i in 1..2 loop
      --   _new_app_user_info := _demo_users[_user_count];
      --   select * into _app_user from app.app_user where username = _new_app_user_info.username;
      --   if _app_user.id is null then
      --     _app_user_auth0_info := (
      --       select app_fn.create_new_licensed_app_user(
      --         _license_type.key,
      --         _app_tenant_subscription.id,
      --         _new_app_user_info
      --       )
      --     );
      --   end if;
      --   _user_count := _user_count + 1;
      --   return next _app_user_auth0_info;
      -- end loop;

    end loop
    ;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.create_demo_users:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.create_demo_users(_app_tenant app.app_tenant, _app_tenant_subscription app.app_tenant_subscription, _subscription app.app_tenant_subscription) OWNER TO postgres;

--
-- Name: license_type; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.license_type (
    key text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    external_id text,
    name text,
    application_key text NOT NULL,
    permission_key app.permission_key DEFAULT 'User'::app.permission_key NOT NULL,
    sync_user_on_assignment boolean DEFAULT true NOT NULL
);


ALTER TABLE app.license_type OWNER TO postgres;

--
-- Name: create_license_type(app_fn.license_type_info); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.create_license_type(_license_type_info app_fn.license_type_info) RETURNS app.license_type
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _license_type app.license_type;
    _permission_key text;
    _permission app.permission;
    _err_context text;
  BEGIN

    if _license_type_info.name is null then
      RAISE EXCEPTION 'Must specify license type name';
    end if;

    if _license_type_info.key is null then
      RAISE EXCEPTION 'Must specify license type key';
    end if;

    if _license_type_info.application_key is null then
      RAISE EXCEPTION 'Must specify license type application_key';
    end if;

    insert into app.license_type(name ,key, application_key, permission_key, sync_user_on_assignment)
    values (_license_type_info.name ,_license_type_info.key, _license_type_info.application_key, coalesce(_license_type_info.permission_key, 'User'), coalesce(_license_type_info.sync_user_on_assignment, true))
    on conflict(key)
    do update set key = _license_type_info.key
    returning *
    into _license_type
    ;

    foreach _permission_key in ARRAY _license_type_info.permissions
    loop
      _permission := app_fn.create_permission(_permission_key);
      perform app_fn.grant_license_type_permission(_license_type.key, _permission.key);
    end loop;

    return _license_type;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.create_license_type:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.create_license_type(_license_type_info app_fn.license_type_info) OWNER TO postgres;

--
-- Name: FUNCTION create_license_type(_license_type_info app_fn.license_type_info); Type: COMMENT; Schema: app_fn; Owner: postgres
--

COMMENT ON FUNCTION app_fn.create_license_type(_license_type_info app_fn.license_type_info) IS 'Upserts a license type.';


--
-- Name: create_new_licensed_app_user(text, text, app_fn.new_app_user_info); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.create_new_licensed_app_user(_license_type_key text, _subscription_id text, _user_info app_fn.new_app_user_info) RETURNS auth_fn.app_user_auth0_info
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _subscription app.app_tenant_subscription;
    _license_pack_license_type app.license_pack_license_type;
    _license_type app.license_type;
    _available_count integer;
    _provisioned_count integer;
    _app_user app.app_user;
    _expiration_date date;
    _result auth_fn.app_user_auth0_info;
    _err_context text;
  BEGIN
    select *
    into _app_user
    from app.app_user
    where username = _user_info.username;

    if _app_user.id is not null then
      raise exception 'BK102:%:app user already exists', _user_info.username;
    end if;

    select *
    into _license_type
    from app.license_type
    where key = _license_type_key;

    if _license_type.key is null then
      raise exception 'BK103:%:no license type for key', _license_type_key;
    end if;

    select *
    into _subscription
    from app.app_tenant_subscription
    where id = _subscription_id;
    if _subscription.id is null then
      raise exception 'BK104:%:no subscription for id', _subscription_id;
    end if;

    select *
    into _license_pack_license_type
    from app.license_pack_license_type
    where license_pack_id = _subscription.license_pack_id
    and license_type_key = _license_type_key
    ;
    _user_info.app_tenant_id = coalesce(_user_info.app_tenant_id, _subscription.app_tenant_id);
    _app_user := app_fn.create_app_user(_user_info);

    _expiration_date := case
      when _license_pack_license_type.expiration_interval = 'explicit' then _license_pack_license_type.explicit_expiration_date
      when _license_pack_license_type.expiration_interval = 'none' then null
      when _license_pack_license_type.expiration_interval = 'quarter' then current_date + ((_license_pack_license_type.expiration_interval_multiplier * 3)::text || ' ' || 'month'::text)::interval
      else current_date + (coalesce(_license_pack_license_type.expiration_interval_multiplier, 1)::text || ' ' || _license_pack_license_type.expiration_interval::text)::interval
    end;
    perform app_fn.provision_tenant_license(
      _license_type_key
      ,_subscription.app_tenant_id
      ,_app_user.id
      ,_subscription_id
      ,_expiration_date
    );

    _result := (
      select auth_fn_private.do_get_app_user_info(
      _app_user.recovery_email
      ,_app_user.app_tenant_id
      )
    );

    return _result;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.create_new_licensed_user:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.create_new_licensed_app_user(_license_type_key text, _subscription_id text, _user_info app_fn.new_app_user_info) OWNER TO postgres;

--
-- Name: permission; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.permission (
    key text NOT NULL
);


ALTER TABLE app.permission OWNER TO postgres;

--
-- Name: create_permission(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.create_permission(_permission_key text) RETURNS app.permission
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _permission app.permission;
    _err_context text;
  BEGIN

  insert into app.permission(key)
  values (_permission_key)
  on conflict(key)
  do update
  set key = _permission_key
  returning *
  into _permission;

  return _permission;
  exception
    when others then
      GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
      if position('FB' in SQLSTATE::text) = 0 then
        _err_context := 'app_fn.create_permission:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
        raise exception '%', _err_context using errcode = 'FB500';
      end if;
      raise;
  end;
  $$;


ALTER FUNCTION app_fn.create_permission(_permission_key text) OWNER TO postgres;

--
-- Name: FUNCTION create_permission(_permission_key text); Type: COMMENT; Schema: app_fn; Owner: postgres
--

COMMENT ON FUNCTION app_fn.create_permission(_permission_key text) IS 'Upserts a permission.';


--
-- Name: create_subsidiary(text, text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.create_subsidiary(_parent_app_tenant_id text, _subsidiary_name text) RETURNS app.app_tenant
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _parent_app_tenant app.app_tenant;
    _subsidiary_app_tenant app.app_tenant;
    _err_context text;
  BEGIN
    select *
    into _parent_app_tenant
    from app.app_tenant
    where id = _parent_app_tenant_id;
    if _parent_app_tenant.id is null then
      raise exception 'no parent app tenant';
    end if;

    select *
    into _subsidiary_app_tenant
    from app.app_tenant
    where name = _subsidiary_name
    and parent_app_tenant_id = _parent_app_tenant.id
    ;
    if _subsidiary_app_tenant.id is not null then
      return _subsidiary_app_tenant;
    end if;

    _subsidiary_app_tenant := (
      select app_fn.create_app_tenant(
        row(
          _subsidiary_name -- _name
          ,null -- identifier text
          ,true -- registration_complete boolean
          ,'subsidiary'::app.app_tenant_type
          ,_parent_app_tenant.id -- parent_app_tenant_id text
          ,null::app_fn.new_app_user_info
        )::app_fn.new_app_tenant_info
      )
    );

    update app.app_tenant set
      anchor_subscription_id = _parent_app_tenant.anchor_subscription_id
    where id = _subsidiary_app_tenant.id
    returning * into _subsidiary_app_tenant;

    return _subsidiary_app_tenant;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.create_subsidiary:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.create_subsidiary(_parent_app_tenant_id text, _subsidiary_name text) OWNER TO postgres;

--
-- Name: create_tutorial_tenant(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.create_tutorial_tenant(_license_pack_key text DEFAULT NULL::text) RETURNS app.app_tenant
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _tutorial_tenant app.app_tenant;
    _app_tenant_subscription app.app_tenant_subscription;
    _identifier text;
    _err_context text;
  BEGIN
    if auth_fn.app_user_has_permission('p:tutorial') = false then
      raise exception 'permission denied';
    end if;

    _identifier := (select auth_fn.current_app_user()->>'app_user_id');
    select * into _tutorial_tenant
    from app.app_tenant
    where identifier = _identifier
    ;

    if _tutorial_tenant.id is not null then
      return _tutorial_tenant;
    end if;

    if _license_pack_key is null or _license_pack_key = '' then
      select lp.key
      into _license_pack_key
      from app.license_pack lp
      join app.app_tenant_subscription ats on ats.license_pack_id = lp.id
      join app.app_tenant apt on apt.anchor_subscription_id = ats.id
      where ats.app_tenant_id = auth_fn.current_app_user()->>'app_tenant_id'
      ;
    end if;

    _app_tenant_subscription := (
      select app_fn.subscribe_to_license_pack_new_tenant(
        _license_pack_key
        ,row(
          'Tutorial: '||(auth_fn.current_app_user()->>'username')
          ,_identifier
          ,true
          ,'tutorial'
          ,auth_fn.current_app_user()->>'app_tenant_id'
          ,row(
            _identifier
            ,null
            ,null
            ,null
            ,row(
              null
              ,null
              ,auth_fn.current_app_user()->>'recovery_email'
              ,'Tutorial'
              ,'Admin'
              ,null
              ,null
              ,null
              ,null
              ,_identifier
            )
          )::app_fn.new_app_user_info
        )::app_fn.new_app_tenant_info
      )
    );

    perform app_fn.create_demo_users(_tutorial_tenant, _app_tenant_subscription);

    return _tutorial_tenant;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.create_tutorial_tenant:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.create_tutorial_tenant(_license_pack_key text) OWNER TO postgres;

--
-- Name: current_app_tenant(); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.current_app_tenant() RETURNS app.app_tenant
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
  _app_tenant app.app_tenant;
BEGIN
-- raise exception 'wtf: %', auth_fn.current_app_user()->>'app_tenant_id';
  select *
  into _app_tenant
  from app.app_tenant
  where id = auth_fn.current_app_user()->>'app_tenant_id'
  ;

  return _app_tenant;
END
$$;


ALTER FUNCTION app_fn.current_app_tenant() OWNER TO postgres;

--
-- Name: current_app_tenant_active_subscriptions(); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.current_app_tenant_active_subscriptions() RETURNS SETOF app.app_tenant_subscription
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
DECLARE
  _app_tenant app.app_tenant;
  _app_tenant_subscription app.app_tenant_subscription;
BEGIN
  select * into _app_tenant from app.app_tenant where id = auth_fn.current_app_user()->>'app_tenant_id';
-- raise exception '%', _app_tenant;
  if _app_tenant.type = 'subsidiary' then
    return query
    select *
    from app.app_tenant_subscription
    where app_tenant_id = _app_tenant.parent_app_tenant_id
    and inactive = false
    ;
  else
    return query
    select *
    from app.app_tenant_subscription
    where app_tenant_id = _app_tenant.id
    and inactive = false
    ;
  end if;
END
$$;


ALTER FUNCTION app_fn.current_app_tenant_active_subscriptions() OWNER TO postgres;

--
-- Name: current_app_tenant_inactive_subscriptions(); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.current_app_tenant_inactive_subscriptions() RETURNS SETOF app.app_tenant_subscription
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
DECLARE
  _app_tenant app.app_tenant;
  _app_tenant_subscription app.app_tenant_subscription;
BEGIN
  select * into _app_tenant from app.app_tenant where id = auth_fn.current_app_user()->>'app_tenant_id';
-- raise exception '%', _app_tenant;
  if _app_tenant.type = 'subsidiary' then
    return query
    select *
    from app.app_tenant_subscription
    where app_tenant_id = _app_tenant.parent_app_tenant_id
    and inactive = true
    ;
  else
    return query
    select *
    from app.app_tenant_subscription
    where app_tenant_id = _app_tenant.id
    and inactive = true
    ;
  end if;
END
$$;


ALTER FUNCTION app_fn.current_app_tenant_inactive_subscriptions() OWNER TO postgres;

--
-- Name: current_user_licensing_status(); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.current_user_licensing_status() RETURNS app_fn.licensing_status
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
  DECLARE
    _app_user app.app_user;
    _current_license app.license;
    _result app_fn.licensing_status;
    _err_context text;
  BEGIN
    if auth_fn.current_app_user()->>'permission_key' in ('SuperAdmin', 'Support', 'Demo') then
      return 'current';
    end if;

    select *
    into _app_user
    from app.app_user
    where id = auth_fn.current_app_user()->>'app_user_id';

    _result := (select app.app_user_licensing_status(_app_user));
    return _result;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.licensing_status:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.current_user_licensing_status() OWNER TO postgres;

--
-- Name: deactivate_app_tenant_subscription(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.deactivate_app_tenant_subscription(_app_tenant_subscription_id text) RETURNS app.app_tenant_subscription
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _app_tenant_subscription app.app_tenant_subscription;
    _err_context text;
    _license_pack_license_type app.license_pack_license_type;
    _license_count integer;
  BEGIN
    select * into _app_tenant_subscription from app.app_tenant_subscription where id = _app_tenant_subscription_id;
    if _app_tenant_subscription.id is null then raise exception 'no app_tenant_subscription exists for this id'; end if;
    -- if _app_tenant_subscription.inactive = true then raise exception 'can only deactivate active app_tenant_subscription'; end if;

    update app.app_tenant_subscription set
      inactive = true
    where id = _app_tenant_subscription_id
    returning *
    into _app_tenant_subscription;

    for _license_pack_license_type in
      select lplt.*
      from app.license_pack_license_type lplt
      join app.license_pack lp on lp.id = lplt.license_pack_id
      where lp.id = _app_tenant_subscription.license_pack_id
    loop
      select count(*) into _license_count 
      from app.license 
      where subscription_id = _app_tenant_subscription.id 
      and license_type_key = _license_pack_license_type.license_type_key;
      
      if _license_pack_license_type.license_count - _license_count > 0 then
        perform app_fn.void_licenses(
          _license_pack_license_type.license_type_key
          ,_app_tenant_subscription.id
          ,'subscription_deactivation'
          ,_license_pack_license_type.license_count - _license_count
        );
      end if;
    end loop;

    update app.license set 
      inactive = true
      ,status = 'inactive'
    where status = 'active'
    and subscription_id = _app_tenant_subscription.id
    ;

    return _app_tenant_subscription;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.deactivate_app_tenant_subscription:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.deactivate_app_tenant_subscription(_app_tenant_subscription_id text) OWNER TO postgres;

--
-- Name: deactivate_app_tenant_subscriptions(text[]); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.deactivate_app_tenant_subscriptions(_app_tenant_subscription_ids text[]) RETURNS SETOF app.app_tenant_subscription
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _app_tenant_subscription app.app_tenant_subscription;
    _app_tenant_subscription_id text;
    _err_context text;
  BEGIN
    foreach _app_tenant_subscription_id in array(_app_tenant_subscription_ids) loop
      _app_tenant_subscription := app_fn.deactivate_app_tenant_subscription(_app_tenant_subscription_id);
      return next _app_tenant_subscription;
    end loop;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.deactivate_app_tenant_subscriptions:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.deactivate_app_tenant_subscriptions(_app_tenant_subscription_ids text[]) OWNER TO postgres;

--
-- Name: deactivate_app_user(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.deactivate_app_user(_app_user_id text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _app_user app.app_user;
    _app_user_auth0_info auth_fn.app_user_auth0_info;
    _project prj.project;
    _uows_to_schedule prj.uow[];
    _result jsonb;
    _err_context text;
  BEGIN
    update app.app_user set
      inactive = true
    where id = _app_user_id
    returning *
    into _app_user;

    update app.license 
    set 
      inactive = 'true'
      ,status = 'inactive' 
    where assigned_to_app_user_id = _app_user.id
    and status = 'active';

    _app_user_auth0_info := (select auth_fn.get_app_user_info(_app_user.id, _app_user.app_tenant_id));

    _result := to_jsonb(_app_user_auth0_info);

    return _result;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.deactivate_app_user:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.deactivate_app_user(_app_user_id text) OWNER TO postgres;

--
-- Name: deactivate_license(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.deactivate_license(_license_id text) RETURNS app.license
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _license app.license;
    _app_tenant_subscription app.app_tenant_subscription;
    _err_context text;
  BEGIN

    select ats.*
    into _app_tenant_subscription
    from app.app_tenant_subscription ats
    join app.license l on ats.id = l.subscription_id
    ;

    if _app_tenant_subscription.inactive = true then
      raise exception 'cannot deactivate a license for an inactive subscription';
    end if;

    update app.license set
      inactive = true
    where id = _license_id
    returning *
    into _license;

    return _license;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.deactivate_license:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.deactivate_license(_license_id text) OWNER TO postgres;

--
-- Name: deactivate_supported_language(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.deactivate_supported_language(_language_id text) RETURNS app.supported_language
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _language app.supported_language;
    _err_context text;
  BEGIN
    update app.supported_language set inactive = true where id = _language_id returning * into _language;
    
    return _language;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.deactivate_supported_language:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.deactivate_supported_language(_language_id text) OWNER TO postgres;

--
-- Name: delete_app_errors(text[]); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.delete_app_errors(_error_report_ids text[]) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _err_context text;
  BEGIN
    delete from app.error_report
    where id = any(_error_report_ids)
    ;

    return true;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.delete_app_errors:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.delete_app_errors(_error_report_ids text[]) OWNER TO postgres;

--
-- Name: delete_app_tenant_group(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.delete_app_tenant_group(_app_tenant_group_id text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _err_context text;
  BEGIN
    
    delete from app.app_tenant_group_admin where app_tenant_group_id = _app_tenant_group_id;
    delete from app.app_tenant_group_member where app_tenant_group_id = _app_tenant_group_id;
    delete from app.app_tenant_group where id = _app_tenant_group_id;

    return true;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.delete_app_tenant_group:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.delete_app_tenant_group(_app_tenant_group_id text) OWNER TO postgres;

--
-- Name: delete_license(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.delete_license(_license_id text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _license app.license;
    _app_tenant_subscription app.app_tenant_subscription;
    _err_context text;
  BEGIN

    select * into _license from app.license where id = _license_id;

    if _license.id is null then
      raise exception 'no license exists for id: %', _license_id;
    end if;

    select ats.*
    into _app_tenant_subscription
    from app.app_tenant_subscription ats
    join app.license l on ats.id = l.subscription_id
    ;

    if _app_tenant_subscription.inactive = true then
      raise exception 'cannot delete a license for an inactive subscription';
    end if;

    delete from app.license_permission where license_id = _license_id;
    delete from app.license where id = _license_id;

    return true;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.delete_license:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.delete_license(_license_id text) OWNER TO postgres;

--
-- Name: demo_admin_users(); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.demo_admin_users() RETURNS SETOF app.app_user
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
  DECLARE
    _err_context text;
    _tenant_permissions text[];
  BEGIN
    return query
    select u.*
    from app.app_user u
    join app.app_tenant t on u.app_tenant_id = t.id
    join app.license l on l.assigned_to_app_user_id = u.id
    where ((u.permission_key = 'Admin' and t.type = 'customer') or u.permission_key = 'SuperAdmin') 
    and u.inactive = false
    and l.license_type_key = 'app-demo-admin'
    ;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.demo_admin_users:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.demo_admin_users() OWNER TO postgres;

--
-- Name: demo_user_infos(app.app_tenant); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.demo_user_infos(_app_tenant app.app_tenant) RETURNS app_fn.new_app_user_info[]
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    _err_context text;
    _user_infos app_fn.new_app_user_info[];
  BEGIN

    _user_infos := array[
      row(
        _app_tenant.id||'_1' -- username text
        ,_app_tenant.id      -- ,app_tenant_id text
        ,null                -- ,ext_auth_id text
        ,null                -- ,ext_crm_id text
        ,row(
          _app_tenant.organization_id        -- organization_id text
          ,null                              -- ,location_id text
          ,'demo-usr-1@ourvisualbrain.com'   -- ,email text
          ,'Stewart'                         -- ,first_name text
          ,'Cameron Wentworth III'           -- ,last_name text
          ,null                              -- ,cell_phone text
          ,null                              -- ,office_phone text
          ,null                              -- ,title text
          ,null                              -- ,nickname text
          ,null                              -- ,external_id text
        )::app_fn.create_contact_input
      )::app_fn.new_app_user_info
      ,row(
        _app_tenant.id||'_2' -- username text
        ,_app_tenant.id      -- ,app_tenant_id text
        ,null                -- ,ext_auth_id text
        ,null                -- ,ext_crm_id text
        ,row(
          _app_tenant.organization_id        -- organization_id text
          ,null                              -- ,location_id text
          ,'demo-usr-2@ourvisualbrain.com'   -- ,email text
          ,'Anita'                         -- ,first_name text
          ,'Bath'           -- ,last_name text
          ,null                              -- ,cell_phone text
          ,null                              -- ,office_phone text
          ,null                              -- ,title text
          ,null                              -- ,nickname text
          ,null                              -- ,external_id text
        )::app_fn.create_contact_input
      )::app_fn.new_app_user_info
      ,row(
        _app_tenant.id||'_3' -- username text
        ,_app_tenant.id      -- ,app_tenant_id text
        ,null                -- ,ext_auth_id text
        ,null                -- ,ext_crm_id text
        ,row(
          _app_tenant.organization_id        -- organization_id text
          ,null                              -- ,location_id text
          ,'demo-usr-3@ourvisualbrain.com'   -- ,email text
          ,'Randy'                         -- ,first_name text
          ,'Mevent'           -- ,last_name text
          ,null                              -- ,cell_phone text
          ,null                              -- ,office_phone text
          ,null                              -- ,title text
          ,null                              -- ,nickname text
          ,null                              -- ,external_id text
        )::app_fn.create_contact_input
      )::app_fn.new_app_user_info
      ,row(
        _app_tenant.id||'_4' -- username text
        ,_app_tenant.id      -- ,app_tenant_id text
        ,null                -- ,ext_auth_id text
        ,null                -- ,ext_crm_id text
        ,row(
          _app_tenant.organization_id        -- organization_id text
          ,null                              -- ,location_id text
          ,'demo-usr-4@ourvisualbrain.com'   -- ,email text
          ,'Colton'                         -- ,first_name text
          ,'Hunter'           -- ,last_name text
          ,null                              -- ,cell_phone text
          ,null                              -- ,office_phone text
          ,null                              -- ,title text
          ,null                              -- ,nickname text
          ,null                              -- ,external_id text
        )::app_fn.create_contact_input
      )::app_fn.new_app_user_info
      ,row(
        _app_tenant.id||'_5' -- username text
        ,_app_tenant.id      -- ,app_tenant_id text
        ,null                -- ,ext_auth_id text
        ,null                -- ,ext_crm_id text
        ,row(
          _app_tenant.organization_id        -- organization_id text
          ,null                              -- ,location_id text
          ,'demo-usr-5@ourvisualbrain.com'   -- ,email text
          ,'Carter'                         -- ,first_name text
          ,'Moss'           -- ,last_name text
          ,null                              -- ,cell_phone text
          ,null                              -- ,office_phone text
          ,null                              -- ,title text
          ,null                              -- ,nickname text
          ,null                              -- ,external_id text
        )::app_fn.create_contact_input
      )::app_fn.new_app_user_info
      ,row(
        _app_tenant.id||'_6' -- username text
        ,_app_tenant.id      -- ,app_tenant_id text
        ,null                -- ,ext_auth_id text
        ,null                -- ,ext_crm_id text
        ,row(
          _app_tenant.organization_id        -- organization_id text
          ,null                              -- ,location_id text
          ,'demo-usr-6@ourvisualbrain.com'   -- ,email text
          ,'Royce'                         -- ,first_name text
          ,'Flaherson'           -- ,last_name text
          ,null                              -- ,cell_phone text
          ,null                              -- ,office_phone text
          ,null                              -- ,title text
          ,null                              -- ,nickname text
          ,null                              -- ,external_id text
        )::app_fn.create_contact_input
      )::app_fn.new_app_user_info
      ,row(
        _app_tenant.id||'_7' -- username text
        ,_app_tenant.id      -- ,app_tenant_id text
        ,null                -- ,ext_auth_id text
        ,null                -- ,ext_crm_id text
        ,row(
          _app_tenant.organization_id        -- organization_id text
          ,null                              -- ,location_id text
          ,'demo-usr-7@ourvisualbrain.com'   -- ,email text
          ,'Steve'                         -- ,first_name text
          ,'Careers'           -- ,last_name text
          ,null                              -- ,cell_phone text
          ,null                              -- ,office_phone text
          ,null                              -- ,title text
          ,null                              -- ,nickname text
          ,null                              -- ,external_id text
        )::app_fn.create_contact_input
      )::app_fn.new_app_user_info
      ,row(
        _app_tenant.id||'_8' -- username text
        ,_app_tenant.id      -- ,app_tenant_id text
        ,null                -- ,ext_auth_id text
        ,null                -- ,ext_crm_id text
        ,row(
          _app_tenant.organization_id        -- organization_id text
          ,null                              -- ,location_id text
          ,'demo-usr-8@ourvisualbrain.com'   -- ,email text
          ,'Bill'                         -- ,first_name text
          ,'Fences'           -- ,last_name text
          ,null                              -- ,cell_phone text
          ,null                              -- ,office_phone text
          ,null                              -- ,title text
          ,null                              -- ,nickname text
          ,null                              -- ,external_id text
        )::app_fn.create_contact_input
      )::app_fn.new_app_user_info
      ,row(
        _app_tenant.id||'_9' -- username text
        ,_app_tenant.id      -- ,app_tenant_id text
        ,null                -- ,ext_auth_id text
        ,null                -- ,ext_crm_id text
        ,row(
          _app_tenant.organization_id        -- organization_id text
          ,null                              -- ,location_id text
          ,'demo-usr-9@ourvisualbrain.com'   -- ,email text
          ,'Margaret'                         -- ,first_name text
          ,'Ito'           -- ,last_name text
          ,null                              -- ,cell_phone text
          ,null                              -- ,office_phone text
          ,null                              -- ,title text
          ,null                              -- ,nickname text
          ,null                              -- ,external_id text
        )::app_fn.create_contact_input
      )::app_fn.new_app_user_info
      ,row(
        _app_tenant.id||'_10' -- username text
        ,_app_tenant.id      -- ,app_tenant_id text
        ,null                -- ,ext_auth_id text
        ,null                -- ,ext_crm_id text
        ,row(
          _app_tenant.organization_id        -- organization_id text
          ,null                              -- ,location_id text
          ,'demo-usr-10@ourvisualbrain.com'   -- ,email text
          ,'William'                         -- ,first_name text
          ,'Thompson'           -- ,last_name text
          ,null                              -- ,cell_phone text
          ,null                              -- ,office_phone text
          ,null                              -- ,title text
          ,null                              -- ,nickname text
          ,null                              -- ,external_id text
        )::app_fn.create_contact_input
      )::app_fn.new_app_user_info
    ]::app_fn.new_app_user_info[]
    ;

    return _user_infos;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.demo_user_infos:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.demo_user_infos(_app_tenant app.app_tenant) OWNER TO postgres;

--
-- Name: demoable_license_packs(); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.demoable_license_packs() RETURNS SETOF app.license_pack
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    _err_context text;
  BEGIN
    return query
    select *
    from app.license_pack
    where availability = 'published'
    and is_public_offering = true
    order by key
    ;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.demoable_license_packs:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.demoable_license_packs() OWNER TO postgres;

--
-- Name: demote_user_from_admin(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.demote_user_from_admin(_app_user_id text) RETURNS auth_fn.app_user_auth0_info
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _app_user app.app_user;
    _app_user_auth0_info auth_fn.app_user_auth0_info;
    _license_pack_license_type app.license_pack_license_type;
    _expiration_date date;
    _err_context text;
  BEGIN
    select * into _app_user from app.app_user where id = _app_user_id;
    if _app_user.id is null then
      raise exception 'no app user with this id';
    end if;

    delete from app.license_permission where license_id in (
      select id from app.license where assigned_to_app_user_id = _app_user.id and position('-admin' in license_type_key) > 0
    );
    delete from app.license where assigned_to_app_user_id = _app_user.id and position('-admin' in license_type_key) > 0;
    update app.app_user set permission_key = 'User' where id = _app_user.id returning * into _app_user;

    _app_user_auth0_info := (select auth_fn.get_app_user_info(_app_user.recovery_email, _app_user.app_tenant_id));
    
    return _app_user_auth0_info;
    
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.demote_user_from_admin:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.demote_user_from_admin(_app_user_id text) OWNER TO postgres;

--
-- Name: demote_user_from_app_tenant_group_admin(text, text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.demote_user_from_app_tenant_group_admin(_app_user_id text, _app_tenant_group_id text) RETURNS auth_fn.app_user_auth0_info
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _app_user app.app_user;
    _app_user_auth0_info auth_fn.app_user_auth0_info;
    _license_pack_license_type app.license_pack_license_type;
    _expiration_date date;
    _err_context text;
  BEGIN
    select * into _app_user from app.app_user where id = _app_user_id;
    if _app_user.id is null then
      raise exception 'no app user with this id';
    end if;

    delete from app.app_tenant_group_admin where app_user_id = _app_user.id and app_tenant_group_id = _app_tenant_group_id;

    if (select count(*) from app.app_tenant_group_admin where app_user_id = _app_user.id) = 0 then
      delete from app.license_permission where license_id in (
        select id from app.license where assigned_to_app_user_id = _app_user.id and license_type_key = 'app-tenant-group-admin'
      );
      delete from app.license where assigned_to_app_user_id = _app_user.id and license_type_key = 'app-tenant-group-admin';
    end if;

    _app_user_auth0_info := (select auth_fn.get_app_user_info(_app_user.recovery_email, _app_user.app_tenant_id));
    
    return _app_user_auth0_info;
    
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.demote_user_from_app_tenant_group_admin:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.demote_user_from_app_tenant_group_admin(_app_user_id text, _app_tenant_group_id text) OWNER TO postgres;

--
-- Name: demote_user_from_demo_admin(text, text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.demote_user_from_demo_admin(_app_user_id text, _language_id text) RETURNS auth_fn.app_user_auth0_info
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _app_user app.app_user;
    _app_user_auth0_info auth_fn.app_user_auth0_info;
    _err_context text;
  BEGIN
    select * into _app_user from app.app_user where id = _app_user_id;
    if _app_user.id is null then
      raise exception 'no app user with this id';
    end if;

    delete from app.license_permission where license_id in (
      select id from app.license where assigned_to_app_user_id = _app_user.id and license_type_key = 'app-demo-admin'
    );
    delete from app.license where assigned_to_app_user_id = _app_user.id and license_type_key = 'app-demo-admin';

    _app_user_auth0_info := (select auth_fn.get_app_user_info(_app_user.recovery_email, _app_user.app_tenant_id));
    
    return _app_user_auth0_info;
    
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.demote_user_from_demo_admin:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.demote_user_from_demo_admin(_app_user_id text, _language_id text) OWNER TO postgres;

--
-- Name: discard_license_pack(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.discard_license_pack(_id text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _license_pack app.license_pack;
    _err_context text;
  BEGIN

    select *
    into _license_pack
    from app.license_pack
    where id = _id
    ;

    if _license_pack.id is null then
      raise exception 'no license pack for id: %', _id;
    end if;

    if 
      _license_pack.availability != 'draft' 
      and (select count(*) from app.app_tenant_subscription where license_pack_id = _id) > 0
    then
      raise exception 'can only discard draft license packs';
    end if;

    delete from app.license_pack_license_type where license_pack_id = _id;
    delete from app.license_pack where id = _id;

    return true;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.discontinue_license_pack:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.discard_license_pack(_id text) OWNER TO postgres;

--
-- Name: discontinue_license_pack(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.discontinue_license_pack(_id text) RETURNS app.license_pack
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _license_pack app.license_pack;
    _err_context text;
  BEGIN

    update app.license_pack set
      availability = 'discontinued',
      discontinued_at = current_timestamp
    where id = _id
    returning *
    into _license_pack;

    return _license_pack;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.discontinue_license_pack:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.discontinue_license_pack(_id text) OWNER TO postgres;

--
-- Name: eligible_app_tenant_group_admin_candidates(); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.eligible_app_tenant_group_admin_candidates() RETURNS SETOF app.app_user
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
  DECLARE
    _err_context text;
    _tenant_permissions text[];
  BEGIN
    return query
    select u.*
    from app.app_user u
    join app.app_tenant t on u.app_tenant_id = t.id
    where ((u.permission_key = 'Admin' and t.type = 'customer') or u.permission_key = 'SuperAdmin') 
    and u.inactive = false
    ;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.eligible_app_tenant_group_admin_candidates:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.eligible_app_tenant_group_admin_candidates() OWNER TO postgres;

--
-- Name: eligible_demo_admin_candidates(); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.eligible_demo_admin_candidates() RETURNS SETOF app.app_user
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
  DECLARE
    _err_context text;
    _tenant_permissions text[];
  BEGIN
    return query
    select u.*
    from app.app_user u
    join app.app_tenant t on u.app_tenant_id = t.id
    where ((u.permission_key = 'Admin' and t.type = 'customer') or u.permission_key = 'SuperAdmin') 
    and u.inactive = false
    and not exists (select id from app.license where assigned_to_app_user_id = u.id and license_type_key = 'app-demo-admin' and inactive = false)
    ;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.eligible_demo_admin_candidates:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.eligible_demo_admin_candidates() OWNER TO postgres;

--
-- Name: error_report_search(app_fn.error_report_search_options); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.error_report_search(_options app_fn.error_report_search_options) RETURNS SETOF app.error_report
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    _err_context text;
  BEGIN
    return query
    select er.*
    from app.error_report er
    -- where (_options.operation_name is null or er.operation_name = _options.operation_name)
    where operation_name not in ('record-score', 'game-session')
    and (_options.status is null or er.status = _options.status)
    -- and (_options.app_user_id is null or er.reported_by_app_user_id = _options.app_user_id or er.reported_as_app_user_id = _options.app_user_id)
    -- and (_options.start_time is null  or er.first_reported_at > _options.start_time)
    -- and (_options.end_time is null  or er.last_reported_at < _options.end_time)
    -- and (_options.search_term is null or position(_options.search_term in er.message) > 0)
    -- and (_options.search_term is null or position(_options.search_term in er.comment) > 0)
    -- and (_options.search_term is null or position(_options.search_term in er.variables::text) > 0)
    order by er.last_reported_at desc
    limit _options.result_limit
    offset _options.result_offset
    ;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.error_report_search:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.error_report_search(_options app_fn.error_report_search_options) OWNER TO postgres;

--
-- Name: expired_licenses(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.expired_licenses(_app_tenant_id text DEFAULT NULL::text) RETURNS SETOF app.license
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    _err_context text;
  BEGIN
    return query
    select l.*
    from app.license l
    join app.app_tenant_subscription ats on ats.id = l.subscription_id
    join app.license_pack lp on ats.license_pack_id = lp.id
    join app.app_tenant a on ats.id = a.anchor_subscription_id
    where l.inactive = false
    and current_date > l.expiration_date
    and l.expiration_date is not null
    and (_app_tenant_id is null or l.app_tenant_id = _app_tenant_id)
    and lp.key not like '%trial%'
    and a.type = 'customer'
    ;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.expired_licenses:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.expired_licenses(_app_tenant_id text) OWNER TO postgres;

--
-- Name: find_available_license_subscription(text, text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.find_available_license_subscription(_license_type_key text, _app_tenant_id text) RETURNS app.app_tenant_subscription
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    _app_tenant_subscription app.app_tenant_subscription;
    _issued_count integer;
    _allowed_count integer;
    _allow_unlimited_provision boolean;
    _err_context text;
  BEGIN
    -- raise exception 'wtf: % ---- %', _license_type_key, _app_tenant_id;

    for _app_tenant_subscription in
      select * from app.app_tenant_subscription
      where app_tenant_id = _app_tenant_id
      and inactive = false
      order by created_date
    loop
      if (select app_fn.check_subscription_for_license_availability(
        _license_type_key
        ,_app_tenant_subscription
      ) = true) then
        return _app_tenant_subscription;
      end if;
      -- select lplt.unlimited_provision
      -- into _allow_unlimited_provision
      -- from app.license_pack_license_type lplt
      -- where lplt.license_pack_id = _app_tenant_subscription.license_pack_id
      -- and lplt.license_type_key = _license_type_key;

      -- if _allow_unlimited_provision = true then
      --   return _app_tenant_subscription;
      -- end if;

      -- select count(*)
      -- into _issued_count
      -- from app.license
      -- where subscription_id = _app_tenant_subscription.id
      -- and license_type_key = _license_type_key;

      -- -- raise notice 'WTF: %', (select key from app.license_pack where id = _app_tenant_subscription.license_pack_id);

      -- select lplt.license_count
      -- into _allowed_count
      -- from app.license_pack_license_type lplt
      -- where lplt.license_pack_id = _app_tenant_subscription.license_pack_id
      -- and lplt.license_type_key = _license_type_key;

      -- -- raise notice 'WTF INDEED: % % %', _allowed_count, _issued_count, _license_type_key;

      -- if _allowed_count > _issued_count then
      --   return _app_tenant_subscription;
      -- end if;
    end loop;

    raise exception 'no available license: %', _license_type_key;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.find_available_license_subscription:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.find_available_license_subscription(_license_type_key text, _app_tenant_id text) OWNER TO postgres;

--
-- Name: force_provision_tenant_license(text, text, text, text, date); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.force_provision_tenant_license(_license_type_key text, _app_tenant_id text, _assigned_to_app_user_id text, _subscription_id text, _expiration_date date DEFAULT NULL::date) RETURNS app.license
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _license_type app.license_type;
    _license app.license;
    _app_tenant_subscription app.app_tenant_subscription;
    _app_tenant app.app_tenant;
    _err_context text;
  BEGIN
    select *
    into _license_type
    from app.license_type
    where key = _license_type_key
    ;

    insert into app.license(
      app_tenant_id
      ,name
      ,license_type_key
      ,subscription_id
      ,expiration_date
    )
    values (
      _app_tenant_id
      ,_license_type.name
      ,_license_type.key
      ,_subscription_id
      ,_expiration_date
    )
    returning *
    into _license;

    _license := (select app_fn.assign_license_to_user(_license.id, _assigned_to_app_user_id));

    with lp as (
      select
        l.id license_id
        ,l.app_tenant_id
        ,ltp.permission_key
      from app.license l
      join app.license_type lt on lt.key = l.license_type_key
      join app.license_type_permission ltp on lt.key = ltp.license_type_key
      where l.id = _license.id
    )
    insert into app.license_permission (license_id, app_tenant_id, permission_key)
    select
      lp.license_id
      ,lp.app_tenant_id
      ,lp.permission_key
    from lp
    on conflict (license_id, permission_key)
    do nothing;

    perform app_fn.after_user_license_assigned(_license.license_type_key, _license.assigned_to_app_user_id);

    return _license;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.force_provision_tenant_license:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.force_provision_tenant_license(_license_type_key text, _app_tenant_id text, _assigned_to_app_user_id text, _subscription_id text, _expiration_date date) OWNER TO postgres;

--
-- Name: FUNCTION force_provision_tenant_license(_license_type_key text, _app_tenant_id text, _assigned_to_app_user_id text, _subscription_id text, _expiration_date date); Type: COMMENT; Schema: app_fn; Owner: postgres
--

COMMENT ON FUNCTION app_fn.force_provision_tenant_license(_license_type_key text, _app_tenant_id text, _assigned_to_app_user_id text, _subscription_id text, _expiration_date date) IS '@omit';


--
-- Name: grant_admin(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.grant_admin(_app_user_id text) RETURNS app.app_user
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _app_user app.app_user;
    _err_context text;
  BEGIN
    update app.app_user set permission_key = 'Admin' where id = _app_user_id returning * into _app_user;
    return _app_user;
  exception
    when others then
      GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
      if position('FB' in SQLSTATE::text) = 0 then
        _err_context := 'app_fn.grant_admin:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
        raise exception '%', _err_context using errcode = 'FB500';
      end if;
      raise;
  end;
  $$;


ALTER FUNCTION app_fn.grant_admin(_app_user_id text) OWNER TO postgres;

--
-- Name: license_type_permission; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.license_type_permission (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    license_type_key text NOT NULL,
    permission_key text NOT NULL
);


ALTER TABLE app.license_type_permission OWNER TO postgres;

--
-- Name: grant_license_type_permission(text, text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.grant_license_type_permission(_license_type_key text, _permission_key text) RETURNS app.license_type_permission
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _license_type_permission app.license_type_permission;
    _err_context text;
  BEGIN

  insert into app.license_type_permission(license_type_key, permission_key)
  values (_license_type_key, _permission_key)
  on conflict(license_type_key, permission_key)
  do update set
    permission_key = _permission_key
  returning *
  into _license_type_permission;

  return _license_type_permission;
  exception
    when others then
      GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
      if position('FB' in SQLSTATE::text) = 0 then
        _err_context := 'app_fn.grant_license_type_permission:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
        raise exception '%', _err_context using errcode = 'FB500';
      end if;
      raise;
end;
$$;


ALTER FUNCTION app_fn.grant_license_type_permission(_license_type_key text, _permission_key text) OWNER TO postgres;

--
-- Name: FUNCTION grant_license_type_permission(_license_type_key text, _permission_key text); Type: COMMENT; Schema: app_fn; Owner: postgres
--

COMMENT ON FUNCTION app_fn.grant_license_type_permission(_license_type_key text, _permission_key text) IS 'Adds a permission to a license type.';


--
-- Name: grant_super_admin(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.grant_super_admin(_app_user_id text) RETURNS app.app_user
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _app_user app.app_user;
    _err_context text;
  BEGIN
    update app.app_user set permission_key = 'SuperAdmin' where id = _app_user_id returning * into _app_user;
    return _app_user;
  exception
    when others then
      GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
      if position('FB' in SQLSTATE::text) = 0 then
        _err_context := 'app_fn.grant_super_admin:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
        raise exception '%', _err_context using errcode = 'FB500';
      end if;
      raise;
  end;
  $$;


ALTER FUNCTION app_fn.grant_super_admin(_app_user_id text) OWNER TO postgres;

--
-- Name: grant_user(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.grant_user(_app_user_id text) RETURNS app.app_user
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _app_user app.app_user;
    _err_context text;
  BEGIN
    update app.app_user set permission_key = 'Admin' where id = _app_user_id returning * into _app_user;
    return _app_user;
  exception
    when others then
      GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
      if position('FB' in SQLSTATE::text) = 0 then
        _err_context := 'app_fn.grant_user:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
        raise exception '%', _err_context using errcode = 'FB500';
      end if;
      raise;
  end;
  $$;


ALTER FUNCTION app_fn.grant_user(_app_user_id text) OWNER TO postgres;

--
-- Name: housekeeping_tasks(); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.housekeeping_tasks() RETURNS app_fn.housekeeping_task[]
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    _housekeeping_tasks app_fn.housekeeping_task[];
    _err_context text;
  BEGIN
    _housekeeping_tasks := (
      select app_fn_private.do_housekeeping_tasks(auth_fn.current_app_user()->>'app_user_id')
    );

    return _housekeeping_tasks;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.housekeeping_tasks:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.housekeeping_tasks() OWNER TO postgres;

--
-- Name: issue_license_to_existing_app_user(text, text, text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.issue_license_to_existing_app_user(_license_type_key text, _subscription_id text, _app_user_id text) RETURNS app.license
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _subscription app.app_tenant_subscription;
    _license_pack_license_type app.license_pack_license_type;
    _license_type app.license_type;
    _available_count integer;
    _provisioned_count integer;
    _app_user app.app_user;
    _expiration_date date;
    _license app.license;
    _err_context text;
  BEGIN
    select *
    into _app_user
    from app.app_user
    where id = _app_user_id;

    if _app_user.id is null then
      raise exception 'BK102:%:app user does not exist', _app_user_id;
    end if;

    select *
    into _license_type
    from app.license_type
    where key = _license_type_key;

    if _license_type.key is null then
      raise exception 'BK103:%:no license type for key', _license_type_key;
    end if;

    select *
    into _subscription
    from app.app_tenant_subscription
    where id = _subscription_id;
    if _subscription.id is null then
      raise exception 'BK104:%:no subscription for id', _subscription_id;
    end if;

    select *
    into _license_pack_license_type
    from app.license_pack_license_type
    where license_pack_id = _subscription.license_pack_id
    and license_type_key = _license_type_key
    ;

    _expiration_date := case
      when _license_pack_license_type.expiration_interval = 'explicit' then _license_pack_license_type.explicit_expiration_date
      when _license_pack_license_type.expiration_interval = 'none' then null
      when _license_pack_license_type.expiration_interval = 'quarter' then current_date + ((_license_pack_license_type.expiration_interval_multiplier * 3)::text || ' ' || 'month'::text)::interval
      else current_date + (coalesce(_license_pack_license_type.expiration_interval_multiplier, 1)::text || ' ' || _license_pack_license_type.expiration_interval::text)::interval
    end;

    _license := app_fn.provision_tenant_license(
      _license_type_key
      ,_subscription.app_tenant_id
      ,_app_user.id
      ,_subscription_id
      ,_expiration_date
    );

    return _license;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.create_new_licensed_user:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.issue_license_to_existing_app_user(_license_type_key text, _subscription_id text, _app_user_id text) OWNER TO postgres;

--
-- Name: license_packs_by_key_version(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.license_packs_by_key_version(_license_pack_key text DEFAULT NULL::text) RETURNS SETOF app_fn.license_pack_key_versions_result
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
BEGIN

  return query
  with keys as (
    select distinct
      key
    from app.license_pack
    group by key
  )
  , sorted as (
    select
      k.key
      ,(select type from app.license_pack where key = k.key limit 1) as type
      ,(select lp from app.license_pack lp where key = k.key and availability = 'draft') draft
      ,(select lp from app.license_pack lp where key = k.key and availability = 'published') published
      ,(select coalesce(array_agg(lp),'{}'::app.license_pack[]) from app.license_pack lp where key = k.key and availability = 'discontinued') discontinued
    from keys k
  )
  select
    s.*
  from sorted s
  where (_license_pack_key is null or _license_pack_key = '' or s.key = _license_pack_key)
  ;
END
$$;


ALTER FUNCTION app_fn.license_packs_by_key_version(_license_pack_key text) OWNER TO postgres;

--
-- Name: move_licenses_to_subscription(text[], text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.move_licenses_to_subscription(_license_ids text[], _app_tenant_subscription_id text) RETURNS SETOF app.license
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _target_app_tenant_subscription app.app_tenant_subscription;
    _subscription_available_license_type app.subscription_available_license_type;
    _available_count integer;
    _current_count integer;
    _lplt app.license_pack_license_type;
    _license app.license;
    _err_context text;
  BEGIN
    for _license in
      select * from app.license where id = any (_license_ids)
    loop
      select * into _target_app_tenant_subscription from app.app_tenant_subscription where id = _app_tenant_subscription_id;
      if _target_app_tenant_subscription.id is null then raise exception 'no app_tenant_subscription exists for this id'; end if;
      if _target_app_tenant_subscription.inactive = true then raise exception 'can only move licenses to app_tenant_subscription'; end if;

      select *
      into _lplt
      from app.license_pack_license_type lplt
      where license_type_key = _license.license_type_key
      and license_pack_id = _target_app_tenant_subscription.license_pack_id
      ;

      select count(*) 
      into _current_count 
      from app.license
      where subscription_id = _target_app_tenant_subscription.id
      and license_type_key = _license.license_type_key;

      if _lplt.unlimited_provision = false and _current_count >= _lplt.license_count then
        raise exception 'no license available: %', _license.license_type_key;
      end if;
      
      update app.license set subscription_id = _target_app_tenant_subscription.id
      where id = _license.id
      returning *
      into _license;

      return next _license;
    end loop;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.move_licenses_to_subscription:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.move_licenses_to_subscription(_license_ids text[], _app_tenant_subscription_id text) OWNER TO postgres;

--
-- Name: promote_user_to_admin(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.promote_user_to_admin(_app_user_id text) RETURNS auth_fn.app_user_auth0_info
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _app_user app.app_user;
    _app_user_auth0_info auth_fn.app_user_auth0_info;
    _license_pack_license_type app.license_pack_license_type;
    _expiration_date date;
    _err_context text;
  BEGIN
    select * into _app_user from app.app_user where id = _app_user_id;
    if _app_user.id is null then
      raise exception 'no app user with this id';
    end if;

    select lplt.* 
    into _license_pack_license_type
    from app.license_pack_license_type lplt
    join app.license_pack lp on lplt.license_pack_id = lp.id
    join app.app_tenant_subscription ats on ats.license_pack_id = lp.id
    join app.app_tenant a on a.anchor_subscription_id = ats.id and a.id = _app_user.app_tenant_id
    where position('-admin' in lplt.license_type_key) > 0
    ;
    
    _expiration_date := case
      when _license_pack_license_type.expiration_interval = 'explicit' then _license_pack_license_type.explicit_expiration_date
      when _license_pack_license_type.expiration_interval = 'none' then null
      when _license_pack_license_type.expiration_interval = 'quarter' then current_date + ((_license_pack_license_type.expiration_interval_multiplier * 3)::text || ' ' || 'month'::text)::interval
      else current_date + (coalesce(_license_pack_license_type.expiration_interval_multiplier, 1)::text || ' ' || _license_pack_license_type.expiration_interval::text)::interval
    end;

    perform app_fn.force_provision_tenant_license(
      _license_pack_license_type.license_type_key
      ,_app_user.app_tenant_id
      ,_app_user.id
      ,(select anchor_subscription_id from app.app_tenant where id = _app_user.app_tenant_id)
      ,_expiration_date
    );

    update app.app_user set permission_key = 'Admin' where id = _app_user.id returning * into _app_user;

    _app_user_auth0_info := (select auth_fn.get_app_user_info(_app_user.recovery_email, _app_user.app_tenant_id));
    
    return _app_user_auth0_info;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.promote_user_to_admin:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.promote_user_to_admin(_app_user_id text) OWNER TO postgres;

--
-- Name: promote_user_to_app_tenant_group_admin(text, text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.promote_user_to_app_tenant_group_admin(_app_user_id text, _app_tenant_group_id text) RETURNS auth_fn.app_user_auth0_info
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _app_user app.app_user;
    _app_user_auth0_info auth_fn.app_user_auth0_info;
    _app_tenant_group_admin app.app_tenant_group_admin;
    _err_context text;
  BEGIN
    select * into _app_tenant_group_admin from app.app_tenant_group_admin 
    where app_tenant_group_id = _app_tenant_group_id and app_user_id = _app_user_id;
    if _app_tenant_group_admin.id is not null then return _app_tenant_group_admin; end if;

    select * into _app_user from app.app_user where id = _app_user_id;
    if _app_user.id is null then
      raise exception 'no app user with this id';
    end if;

    if _app_user.permission_key not in ('Admin', 'SuperAdmin') then
      raise exception 'can only promote an admin or super admin user to app tenant group admin';
    end if;

    perform app_fn.force_provision_tenant_license(
      'app-tenant-group-admin'
      ,_app_user.app_tenant_id
      ,_app_user.id
      ,(select anchor_subscription_id from app.app_tenant where id = _app_user.app_tenant_id)
      ,null
    );

    insert into app.app_tenant_group_admin(app_tenant_group_id, app_user_id) values (_app_tenant_group_id, _app_user.id);

    _app_user_auth0_info := (select auth_fn.get_app_user_info(_app_user.recovery_email, _app_user.app_tenant_id));
    
    return _app_user_auth0_info;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.promote_user_to_app_tenant_group_admin:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.promote_user_to_app_tenant_group_admin(_app_user_id text, _app_tenant_group_id text) OWNER TO postgres;

--
-- Name: promote_user_to_demo_admin(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.promote_user_to_demo_admin(_app_user_id text) RETURNS auth_fn.app_user_auth0_info
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _app_user app.app_user;
    _app_user_auth0_info auth_fn.app_user_auth0_info;
    _license_pack_license_type app.license_pack_license_type;
    _err_context text;
  BEGIN
    select * into _app_user from app.app_user where id = _app_user_id;
    if _app_user.id is null then
      raise exception 'no app user with this id';
    end if;

    if _app_user.permission_key not in ('Admin', 'SuperAdmin') then
      raise exception 'can only promote an admin or super admin user to demo admin';
    end if;

    perform app_fn.force_provision_tenant_license(
      'app-demo-admin'
      ,_app_user.app_tenant_id
      ,_app_user.id
      ,(select anchor_subscription_id from app.app_tenant where id = _app_user.app_tenant_id)
      ,null
    );

    _app_user_auth0_info := (select auth_fn.get_app_user_info(_app_user.recovery_email, _app_user.app_tenant_id));
    
    return _app_user_auth0_info;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.promote_user_to_demo_admin:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.promote_user_to_demo_admin(_app_user_id text) OWNER TO postgres;

--
-- Name: provision_tenant_license(text, text, text, text, date); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.provision_tenant_license(_license_type_key text, _app_tenant_id text, _assigned_to_app_user_id text, _subscription_id text, _expiration_date date DEFAULT NULL::date) RETURNS app.license
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _license_type app.license_type;
    _license app.license;
    _app_tenant_subscription app.app_tenant_subscription;
    _app_tenant app.app_tenant;
    _err_context text;
  BEGIN
    select *
    into _license_type
    from app.license_type
    where key = _license_type_key
    ;

    if _license_type.key is null then
      raise exception 'license type key not supported: %', _license_type_key;
    end if;

    select * into _app_tenant_subscription
    from app.app_tenant_subscription
    where id = _subscription_id;
    if _app_tenant_subscription.parent_app_tenant_subscription_id is not null then
      -- this is recursive.  get the license from parent subscription
      -- happens when the current app tenant is a subsidiary
      _license := app_fn.provision_tenant_license(
        _license_type_key
        ,_app_tenant_subscription.app_tenant_id
        ,_assigned_to_app_user_id
        ,_app_tenant_subscription.parent_app_tenant_subscription_id
        ,_expiration_date
      );
      return _license;
    else
      if (select app_fn.check_subscription_for_license_availability(_license_type_key, _app_tenant_subscription) = false) then
        _app_tenant_subscription := (select app_fn.find_available_license_subscription(_license_type_key, _app_tenant_subscription.app_tenant_id));
      end if;
    end if;

    if _app_tenant_subscription.id is null then
      raise exception 'no license available: %', _license_type_key;
    end if;

    -- if position('patient' in _license_type_key) > 0 then
    if position('patient' in _license_type_key) > 0 and _expiration_date is null then
      _expiration_date := (current_date + '1 year'::interval);
    end if;
    -- raise exception '_expiration_date: %, _license_type_key: %', _expiration_date, _license_type_key;

    insert into app.license(
      app_tenant_id
      ,name
      ,license_type_key
      ,subscription_id
      ,expiration_date
    )
    values (
      _app_tenant_id
      ,_license_type.name
      ,_license_type.key
      ,_app_tenant_subscription.id
      ,_expiration_date
    )
    returning *
    into _license;

    _license := (select app_fn.assign_license_to_user(_license.id, _assigned_to_app_user_id));

    with lp as (
      select
        l.id license_id
        ,l.app_tenant_id
        ,ltp.permission_key
      from app.license l
      join app.license_type lt on lt.key = l.license_type_key
      join app.license_type_permission ltp on lt.key = ltp.license_type_key
      where l.id = _license.id
    )
    insert into app.license_permission (license_id, app_tenant_id, permission_key)
    select
      lp.license_id
      ,lp.app_tenant_id
      ,lp.permission_key
    from lp
    on conflict (license_id, permission_key)
    do nothing;

    if _assigned_to_app_user_id is not null then
      perform app_fn.after_user_license_assigned(_license_type_key, _assigned_to_app_user_id);
    end if;

    return _license;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.provision_tenant_license:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.provision_tenant_license(_license_type_key text, _app_tenant_id text, _assigned_to_app_user_id text, _subscription_id text, _expiration_date date) OWNER TO postgres;

--
-- Name: publish_license_pack(text, boolean); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.publish_license_pack(_id text, _discontinue_existing boolean DEFAULT false) RETURNS app.license_pack
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _license_pack app.license_pack;
    _existing app.license_pack;
    _err_context text;
  BEGIN

    select *
    into _license_pack
    from app.license_pack
    where id = _id;

    if _license_pack.id is null then
      raise exception 'no license pack for this id';
    end if;

    if _license_pack.availability = 'discontinued' then
      raise exception 'cannot publish a discontinued license pack';
    end if;

    select *
    into _existing
    from app.license_pack
    where key = _license_pack.key
    and id != _license_pack.id
    and availability in ('published')
    ;

    if _existing.id is not null then
      if _discontinue_existing = false then
        raise exception 'a published license pack with this key exists: %', _existing.key;
      else
        update app.license_pack set
          availability = 'discontinued'
          ,discontinued_at = current_timestamp
        where id = _existing.id;
      end if;
    end if;


    update app.license_pack set
      availability = 'published'
      ,published_at = current_timestamp
    where id = _id
    returning *
    into _license_pack;

    return _license_pack;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.publish_license_pack:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.publish_license_pack(_id text, _discontinue_existing boolean) OWNER TO postgres;

--
-- Name: purge_app_tenant_subscription(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.purge_app_tenant_subscription(_app_tenant_subscription_id text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _app_tenant_subscription app.app_tenant_subscription;
    _err_context text;
  BEGIN
    select * into _app_tenant_subscription from app.app_tenant_subscription where id = _app_tenant_subscription_id;
    if _app_tenant_subscription.id is null then raise exception 'no app_tenant_subscription exists for this id'; end if;
    if _app_tenant_subscription.inactive = false then raise exception 'can only purge inactive app_tenant_subscription'; end if;
    if (select count(*) from app.app_tenant where anchor_subscription_id = _app_tenant_subscription.id) > 0 then
      raise exception 'cannot purge a current anchor subscription';
    end if;

    delete from app.license_permission where license_id in (
      select id from app.license where subscription_id = _app_tenant_subscription.id
    );
    delete from app.license where subscription_id = _app_tenant_subscription.id;
    delete from app.app_tenant_subscription where id = _app_tenant_subscription.id;
    return true;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.purge_app_tenant_subscription:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.purge_app_tenant_subscription(_app_tenant_subscription_id text) OWNER TO postgres;

--
-- Name: raise_exception(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.raise_exception(_msg text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  _err_context text;
BEGIN
  raise exception '%', coalesce(_msg, 'NO MSG!');

  exception
    when others then
      GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
      if position('FB' in SQLSTATE::text) = 0 then
        _err_context := 'app_fn.raise_exception:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
        raise exception '%', _err_context using errcode = 'FB500';
      end if;
      raise;
END
$$;


ALTER FUNCTION app_fn.raise_exception(_msg text) OWNER TO postgres;

--
-- Name: rando(); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.rando() RETURNS text
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  DECLARE
    _retval boolean;
  BEGIN

    RETURN 'pizza';
  end;
  $$;


ALTER FUNCTION app_fn.rando() OWNER TO postgres;

--
-- Name: reactivate_app_user(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.reactivate_app_user(_app_user_id text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _app_user app.app_user;
    _app_user_auth0_info auth_fn.app_user_auth0_info;
    _project prj.project;
    _uows_to_schedule prj.uow[];
    _license app.license;
    _result jsonb;
    _err_context text;
  BEGIN
    update app.app_user set
      inactive = false
    where id = _app_user_id
    returning *
    into _app_user;

    with ls as (
      select distinct on (l.license_type_key)
        l.license_type_key
        ,l.id
        ,l.created_at
      from app.license l
      where l.assigned_to_app_user_id = _app_user.id
      and l.status = 'inactive'
      and l.expiration_date > current_date
      order by
        l.license_type_key
        ,l.expiration_date desc
        ,l.created_at desc
    )
    update app.license l
      set 
        inactive = 'false'
        ,status = 'active'
      from ls
      where l.id = ls.id
    ;

    -- for _license in
    -- loop
    --   update app.license 
    --   set 
    --     inactive = 'false'
    --     ,status = 'active'
    --   where id = _license_id
    --   ;
    -- end loop;

    -- update app.license 
    -- set 
    --   inactive = 'false'
    --   ,status = 'active'
    -- where assigned_to_app_user_id = _app_user.id
    -- and status = 'inactive'
    -- and expiration_date > current_date;

    _app_user_auth0_info := (select auth_fn.get_app_user_info(_app_user.id, _app_user.app_tenant_id));

    _result := to_jsonb(_app_user_auth0_info);

    return _result;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.reactivate_app_user:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.reactivate_app_user(_app_user_id text) OWNER TO postgres;

--
-- Name: remove_app_tenant(text, text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.remove_app_tenant(_app_tenant_id text, _confirmation_code text DEFAULT NULL::text) RETURNS app.app_tenant
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _err_context text;
    _app_tenant app.app_tenant;
  BEGIN
    select * into _app_tenant from app.app_tenant where id = _app_tenant_id;

    if _app_tenant.id is null then return true; end if;
    if _app_tenant.type = 'anchor' then raise exception 'cannot remove anchor tenant'; end if;
    if
      _app_tenant.type = 'customer'
      and coalesce(_confirmation_code, '') != _app_tenant.name
      then raise exception 'confirmation code must match app tenant name';
    end if;

    perform app_fn.remove_app_tenant(id, name) from app.app_tenant where parent_app_tenant_id = _app_tenant.id;

    delete from app.signed_eula where app_tenant_id = _app_tenant_id;
    delete from app.app_tenant_group_member where app_tenant_id = _app_tenant_id;

    update prj.project set uow_id = null where app_tenant_id = _app_tenant_id;
    delete from prj.contact_project_role where app_tenant_id = _app_tenant_id;
    delete from prj.uow_dependency where app_tenant_id = _app_tenant_id;
    delete from prj.uow where app_tenant_id = _app_tenant_id;
    delete from prj.project where app_tenant_id = _app_tenant_id;
    delete from prj.uow_history where app_tenant_id = _app_tenant_id;
    delete from prj.project_history where app_tenant_id = _app_tenant_id;

    delete from msg.message where app_tenant_id = _app_tenant_id;
    delete from msg.subscription where app_tenant_id = _app_tenant_id;
    delete from msg.topic where app_tenant_id = _app_tenant_id;

    delete from bill.payment where app_tenant_id = _app_tenant_id;
    delete from bill.payment_method where app_tenant_id = _app_tenant_id;

    delete from app.license_permission where app_tenant_id = _app_tenant_id;
    delete from app.license where app_tenant_id = _app_tenant_id;
    delete from app.license_permission where license_id in (select id from app.license where assigned_to_app_user_id in (select id from app.app_user where app_tenant_id = _app_tenant_id));
    delete from app.license where assigned_to_app_user_id in (select id from app.app_user where app_tenant_id = _app_tenant_id);
    delete from bill.payment where app_tenant_id = _app_tenant_id;
    update app.app_tenant set anchor_subscription_id = null where id = _app_tenant_id;
    if _app_tenant.type != 'subsidiary' then
      delete from app.app_tenant_subscription where app_tenant_id = _app_tenant_id;
    end if;

    delete from app.app_tenant_group_admin atga where app_user_id in (select id from app.app_user where app_tenant_id = _app_tenant_id);
    delete from app.error_report er where reported_by_app_user_id in (select id from app.app_user where app_tenant_id = _app_tenant_id);
    delete from app.error_report er where reported_as_app_user_id in (select id from app.app_user where app_tenant_id = _app_tenant_id);
    delete from app.app_user where app_tenant_id = _app_tenant_id;
    delete from app.contact where app_tenant_id = _app_tenant_id;
    update app.app_tenant set organization_id = null where id = _app_tenant_id;
    delete from app.organization where app_tenant_id = _app_tenant_id;
    delete from app.app_tenant where id = _app_tenant_id;

    return _app_tenant;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.remove_app_tenant:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.remove_app_tenant(_app_tenant_id text, _confirmation_code text) OWNER TO postgres;

--
-- Name: remove_app_tenant_group_member(text, text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.remove_app_tenant_group_member(_app_tenant_group_id text, _app_tenant_id text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _err_context text;
  BEGIN
    delete from app.app_tenant_group_member where app_tenant_group_id = _app_tenant_group_id and app_tenant_id = _app_tenant_id;

    return true;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.remove_app_tenant_group_member:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.remove_app_tenant_group_member(_app_tenant_group_id text, _app_tenant_id text) OWNER TO postgres;

--
-- Name: remove_app_user(text, text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.remove_app_user(_app_user_id text, _confirmation_code text DEFAULT NULL::text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _err_context text;
    _app_user app.app_user;
  BEGIN
    -- if 
    --   position('p:super-admin' in auth_fn.current_app_user()->>'permissions') = 0
    -- then
    --   raise exception 'permission denied';
    -- end if;

    select * into _app_user from app.app_user where id = _app_user_id;
    if _confirmation_code != _app_user.recovery_email then
      raise exception 'confirmation code must match recover email';
    end if;

    if _app_user.id is null then return true; end if;

    delete from app.signed_eula where signed_by_app_user_id = _app_user.id;
    
    delete from app.app_tenant_group_admin atga where app_user_id = _app_user_id;

    delete from msg.message where posted_by_contact_id = _app_user.contact_id;
    delete from msg.subscription where subscriber_contact_id = _app_user.contact_id;

    delete from app.error_report where reported_by_app_user_id = _app_user.id;
    delete from app.error_report where reported_as_app_user_id = _app_user.id;
    delete from app.license_permission where license_id in (select id from app.license where assigned_to_app_user_id = _app_user_id);
    delete from app.license where assigned_to_app_user_id = _app_user_id;
    delete from app.app_user where id = _app_user_id;
    delete from app.contact where id = _app_user.contact_id;

    return true;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.remove_app_user:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.remove_app_user(_app_user_id text, _confirmation_code text) OWNER TO postgres;

--
-- Name: remove_license_pack_license_type(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.remove_license_pack_license_type(_id text) RETURNS app.license_pack
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _license_pack_license_type app.license_pack_license_type;
    _license_pack app.license_pack;
    _new_upgrade_config app.upgrade_config;
    _upgrade_path app.upgrade_path;
    _new_upgrade_paths app.upgrade_path[];
    _new_upgrade_path app.upgrade_path;
    _license_type_upgrade app.license_type_upgrade;
    _new_license_type_upgrade app.license_type_upgrade;
    _new_license_type_upgrades app.license_type_upgrade[];
    _err_context text;
  BEGIN

    select *
    into _license_pack_license_type
    from app.license_pack_license_type
    where id = _id;

    if _license_pack_license_type.id is null then
      raise exception 'no license_pack_license_type for id';
    end if;

    select *
    into _license_pack
    from app.license_pack
    where id = _license_pack_license_type.license_pack_id;

    if _license_pack.availability != 'draft' then
      raise exception 'can only remove license type from draft license packs';
    end if;

    -- _new_upgrade_config = row(array[]::app.upgrade_path[])::app.upgrade_config;
    _new_upgrade_paths = '{}'::app.upgrade_path[];

    foreach _upgrade_path in array((_license_pack.upgrade_config).upgrade_paths)
    loop
      _new_upgrade_path.license_pack_key := _upgrade_path.license_pack_key;
      _new_license_type_upgrades := '{}'::app.license_type_upgrade[];

      foreach _license_type_upgrade in array(_upgrade_path.license_type_upgrades)
      loop
        if _license_type_upgrade.source_license_type_key != _license_pack_license_type.license_type_key then
          _new_license_type_upgrades := array_append(_new_license_type_upgrades, _license_type_upgrade);
        end if;
      end loop;
      _new_upgrade_path.license_type_upgrades := _new_license_type_upgrades;
      _new_upgrade_paths := array_append(_new_upgrade_paths, _new_upgrade_path);
    end loop;
    _new_upgrade_config.upgrade_paths := _new_upgrade_paths;
    -- raise exception '%  --------------------------------------------\n\n %', _license_pack.upgrade_config, _new_upgrade_config;

    update app.license_pack set
      upgrade_config = _new_upgrade_config
    where id = _license_pack.id
    ;

    delete from app.license_pack_license_type where id = _id;

    return _license_pack;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.remove_license_pack_license_type:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.remove_license_pack_license_type(_id text) OWNER TO postgres;

--
-- Name: renew_app_user_license(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.renew_app_user_license(_app_user_id text) RETURNS app.license
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _app_user app.app_user;
    _license app.license;
    _new_license app.license;
    _err_context text;
  BEGIN

    select *
    into _app_user
    from app.app_user
    where id = _app_user_id
    ;

    if _app_user.id is null then
      raise exception 'no app user for this id: %', _app_user_id;
    end if;

    select *
    into _license
    from app.license
    where assigned_to_app_user_id = _app_user_id
    order by created_at desc
    limit 1
    ;

    if _license.id is null then
      raise exception 'no license for this app user id: %', _app_user_id;
    end if;

    _new_license := app_fn.provision_tenant_license(
      _license.license_type_key -- _license_type_key text
      ,_app_user.app_tenant_id::text -- ,_app_tenant_id text
      ,_app_user.id::text -- ,_assigned_to_app_user_id text
      ,(select anchor_subscription_id from app.app_tenant where id = _app_user.app_tenant_id) -- ,_subscription_id text
      ,null -- ,_expiration_date date default null
    );

    -- raise exception 'licenseids: % -- %', _license.license_type_key, _new_license.license_type_key;

    return _new_license;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.renew_app_user_license:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.renew_app_user_license(_app_user_id text) OWNER TO postgres;

--
-- Name: report_app_errors(app_fn.error_report_info[]); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.report_app_errors(_error_report_infos app_fn.error_report_info[]) RETURNS SETOF app.error_report
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _error_report app.error_report;
    _error_report_info app_fn.error_report_info;
    _err_context text;
  BEGIN

    foreach _error_report_info in array(_error_report_infos)
    loop
  -- raise exception '_error_report_info: %', _error_report_info;
      select *
      into _error_report
      from app.error_report
      where operation_name = _error_report_info.operation_name
      and reported_as_app_user_id = _error_report_info.reported_as_app_user_id
      and reported_by_app_user_id = _error_report_info.reported_by_app_user_id
      and message = _error_report_info.message
      and status != 'addressed'
      ;
  -- raise exception '_error_report: %', _error_report;
      if _error_report.id is null then
        insert into app.error_report(
          message
          ,operation_name
          ,variables
          ,reported_by_app_user_id
          ,reported_as_app_user_id
          ,first_reported_at
          ,last_reported_at
          ,observed_count
          ,comment
          ,status
        )
        select
          _error_report_info.message
          ,_error_report_info.operation_name
          ,coalesce(_error_report_info.variables, '{}'::jsonb)
          ,_error_report_info.reported_by_app_user_id
          ,_error_report_info.reported_as_app_user_id
          ,current_timestamp
          ,current_timestamp
          ,coalesce(_error_report_info.observed_count, 1)
          ,_error_report_info.comment
          ,'captured'
        returning *
        into _error_report
        ;
      else
        update app.error_report er set
          observed_count = er.observed_count + coalesce(_error_report_info.observed_count, 1)
          ,last_reported_at = current_timestamp
        where id = _error_report.id
        returning * into _error_report
        ;
      end if;

      return next _error_report;
    end loop
    ;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.report_app_errors:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.report_app_errors(_error_report_infos app_fn.error_report_info[]) OWNER TO postgres;

--
-- Name: reset_demo_data(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.reset_demo_data(_app_tenant_id text) RETURNS app.app_tenant
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _demo_app_tenant app.app_tenant;
    _identifier text;
    _app_tenant_subscription app.app_tenant_subscription;
    _license_pack app.license_pack;
    _err_context text;
  BEGIN
    if auth_fn.app_user_has_permission('p:demo') = false then
      raise exception 'permission denied';
    end if;

    select * into _demo_app_tenant from app.app_tenant where type = 'demo' and id = _app_tenant_id;

    if _demo_app_tenant.id is null then
      raise exception 'no demo tenant for id: %', _app_tenant_id;
    end if;

    return _demo_app_tenant;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.reset_demo_data:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.reset_demo_data(_app_tenant_id text) OWNER TO postgres;

--
-- Name: eula; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.eula (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_inactive boolean DEFAULT false NOT NULL,
    deactivated_at timestamp with time zone,
    content text NOT NULL,
    CONSTRAINT eula_check CHECK (((is_inactive = false) OR (deactivated_at IS NOT NULL)))
);


ALTER TABLE app.eula OWNER TO postgres;

--
-- Name: set_app_eula(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.set_app_eula(_content text) RETURNS app.eula
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _eula app.eula;
    _err_context text;
  BEGIN
    select * into _eula from app.eula where is_inactive = false;

    if _eula.content = _content then
      return _eula;
    end if;
    
    update app.eula set 
      is_inactive = true
      ,deactivated_at = current_timestamp
    where is_inactive = false
    ;

    insert into app.eula(
      content
    ) values (_content)
    returning *
    into _eula
    ;

    return _eula;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.set_app_eula:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.set_app_eula(_content text) OWNER TO postgres;

--
-- Name: set_user_ext_auth_id(text, text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.set_user_ext_auth_id(_recovery_email text, _ext_auth_id text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _err_context text;
  BEGIN
    update app.app_user set ext_auth_id = _ext_auth_id where recovery_email = _recovery_email;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.set_user_ext_auth_id:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.set_user_ext_auth_id(_recovery_email text, _ext_auth_id text) OWNER TO postgres;

--
-- Name: FUNCTION set_user_ext_auth_id(_recovery_email text, _ext_auth_id text); Type: COMMENT; Schema: app_fn; Owner: postgres
--

COMMENT ON FUNCTION app_fn.set_user_ext_auth_id(_recovery_email text, _ext_auth_id text) IS '@omit';


--
-- Name: signed_eula; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.signed_eula (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    eula_id text NOT NULL,
    app_tenant_id text NOT NULL,
    signed_by_app_user_id text NOT NULL,
    signed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    content text NOT NULL
);


ALTER TABLE app.signed_eula OWNER TO postgres;

--
-- Name: sign_current_eula(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.sign_current_eula(_eula_id text) RETURNS app.signed_eula
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _signed_eula app.signed_eula;
    _err_context text;
  BEGIN
    
    _signed_eula := (select app_fn_private.do_sign_current_eula(
      _eula_id
      ,auth_fn.current_app_user()->>'app_tenant_id'
      ,auth_fn.current_app_user()->>'app_user_id'
    ));

    return _signed_eula;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.sign_current_eula:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.sign_current_eula(_eula_id text) OWNER TO postgres;

--
-- Name: subscribe_to_license_pack_existing_tenant(text, text, boolean); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.subscribe_to_license_pack_existing_tenant(_license_pack_key text, _existing_tenant_id text, _force_subscribe boolean DEFAULT false) RETURNS app.app_tenant_subscription
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _app_tenant app.app_tenant;
    _license_pack app.license_pack;
    _existing_anchor_subscription app.app_tenant_subscription;
    _existing_license app.license;
    _existing_license_pack app.license_pack;
    _new_app_tenant_subscription app.app_tenant_subscription;
    _upgrade_config app.upgrade_config;
    _upgrade_path app.upgrade_path;
    _license_type_upgrade app.license_type_upgrade;
    _new_license_type_key text;
    _license_pack_license_type app.license_pack_license_type;
    _expiration_date date;
    _implicit_add_on_key text;
    _implicit_add_on_license_pack app.license_pack;
    _err_context text;
  BEGIN

    select *
    into _app_tenant
    from app.app_tenant
    where id = _existing_tenant_id
    ;

    if _app_tenant.id is null then
      raise exception 'BK102:%: this app tenant does not exist', _existing_tenant_id;
    end if;

    select *
    into _license_pack
    from app.license_pack
    where key = _license_pack_key
    and availability = 'published'
    ;

    if _license_pack.key is null then
      raise exception 'no published license pack for key: %', _license_pack_key;
    end if;

    if _license_pack.key = 'anchor' and _app_tenant.type != 'anchor' then
      raise exception 'cannot subscribe anchor license pack';
    end if;

    if _license_pack.key = 'anchor' then -- check to see if subscription already exists
      select * into _existing_anchor_subscription from app.app_tenant_subscription where license_pack_id = _license_pack.id;
      if _existing_anchor_subscription.id is not null then
        return _existing_anchor_subscription;
      end if;
    end if;

    if _license_pack.type = 'anchor' then
      -- there can be one and only on anchor subscrption

      -- find and verify existing anchor subscription
      select *
      into _existing_anchor_subscription
      from app.app_tenant_subscription
      where id = _app_tenant.anchor_subscription_id
      ;
      if _existing_anchor_subscription.id is null then
        raise exception 'SEVERE ERROR: no anchor subscription for app tenant: %', _app_tenant.id;
      end if;

      -- get the license pack associated with anchor subscription
      select *
      into _existing_license_pack
      from app.license_pack
      where id = _existing_anchor_subscription.license_pack_id
      ;

      -- deactivate the current subscription
      update app.app_tenant_subscription set
        inactive = true
      where id = _existing_anchor_subscription.id;

      _expiration_date := case
        when _license_pack.expiration_interval = 'explicit' then _license_pack.explicit_expiration_date
        when _license_pack.expiration_interval = 'none' then null
        when _license_pack.expiration_interval = 'quarter' then current_date + ((_license_pack.expiration_interval_multiplier * 3)::text || ' ' || 'month'::text)::interval
        else current_date + (coalesce(_license_pack.expiration_interval_multiplier, 1)::text || ' ' || _license_pack.expiration_interval::text)::interval
      end;

      -- create the new subscription
      insert into app.app_tenant_subscription(app_tenant_id, license_pack_id, is_anchor_subscription, expiration_date)
      values (_app_tenant.id, _license_pack.id, true, _expiration_date::date)
      returning *
      into _new_app_tenant_subscription;

      update app.app_tenant set
        anchor_subscription_id = _new_app_tenant_subscription.id
      where id = _app_tenant.id
      returning * into _app_tenant;

      foreach _implicit_add_on_key in array coalesce(_license_pack.implicit_add_on_keys::text[], '{}'::text[])::text[] loop
        select * 
        into _implicit_add_on_license_pack
        from app.license_pack
        where key = _implicit_add_on_key
        and (_force_subscribe = true or availability = 'published')
        ;
        if _implicit_add_on_license_pack.id is null then
          raise exception 'no add on license pack for key: %', _implicit_add_on_key;
        end if;

        _expiration_date := case
          when _implicit_add_on_license_pack.expiration_interval = 'explicit' then _implicit_add_on_license_pack.explicit_expiration_date
          when _implicit_add_on_license_pack.expiration_interval = 'none' then null
          when _implicit_add_on_license_pack.expiration_interval = 'quarter' then current_date + ((_implicit_add_on_license_pack.expiration_interval_multiplier * 3)::text || ' ' || 'month'::text)::interval
          else current_date + (coalesce(_implicit_add_on_license_pack.expiration_interval_multiplier, 1)::text || ' ' || _implicit_add_on_license_pack.expiration_interval::text)::interval
        end;
        insert into app.app_tenant_subscription(
          app_tenant_id
          ,license_pack_id
          ,is_anchor_subscription
          ,expiration_date
          )
        values (_app_tenant.id, _implicit_add_on_license_pack.id, false, _expiration_date::date)
        ;
      end loop;

      -- find the appropriate upgrade path and verify
      _upgrade_config := _existing_license_pack.upgrade_config;
      _upgrade_path := null;
      foreach _upgrade_path in array(_upgrade_config.upgrade_paths)
      loop
        if _upgrade_path.license_pack_key = _license_pack_key then
          exit;
        end if;
      end loop;
      if _force_subscribe = false and _upgrade_path is null then
        raise exception 'no upgrade path exists for this key: %', _license_pack_key;
      end if;

      for _existing_license in
        select *
        from app.license
        where subscription_id = _existing_anchor_subscription.id
        and inactive = false
        and (expiration_date is null or expiration_date > current_date)
      loop
        -- deactivate this license
        update app.license set
          inactive = true
        where id = _existing_license.id
        ;

        -- find the license type for the upgrade
        -- if there is no upgrade designation, use the same type as the existing license
        _license_type_upgrade := null;
        if _force_subscribe = false then
          foreach _license_type_upgrade in array(_upgrade_path.license_type_upgrades)
          loop
            if _license_type_upgrade.source_license_type_key = _existing_license.license_type_key then
              _new_license_type_key = _license_type_upgrade.target_license_type_key;
            else
              _new_license_type_key = _existing_license.license_type_key;
            end if;
          end loop;
        else
          _new_license_type_key = _existing_license.license_type_key;
        end if;


        select *
        into _license_pack_license_type
        from app.license_pack_license_type
        where license_pack_id = _license_pack.id
        and license_type_key = _license_type_upgrade.target_license_type_key;

        if _force_subscribe = false and _license_pack_license_type.id is null then
          raise exception 'no license_pack_license_type: % for license_pack_id: %', _license_type_upgrade.target_license_type_key, _license_pack.id;
        end if;

        _expiration_date := _existing_license.expiration_date;
        -- create an identical or upgraded license in new subscription
        -- BY FORCING THIS, WE MAY NEED TO CLEANUP WITH NEW TOOLS LATER
        perform app_fn.provision_tenant_license(
          _new_license_type_key
          ,_app_tenant.id
          ,_existing_license.assigned_to_app_user_id
          ,_new_app_tenant_subscription.id
          ,_expiration_date
        );
        -- THIS SECTION MAY NEED TO GO AWAY OR BE RETHOUGHT
        -- if _force_subscribe = false then
        --   perform app_fn.force_provision_tenant_license(
        --     _new_license_type_key
        --     ,_app_tenant.id
        --     ,_existing_license.assigned_to_app_user_id
        --     ,_new_app_tenant_subscription.id,
        --     _expiration_date
        --   );
        -- else
        --   -- perform app_fn.force_provision_tenant_license(
        --   perform app_fn.provision_tenant_license(
        --     _new_license_type_key
        --     ,_app_tenant.id
        --     ,_existing_license.assigned_to_app_user_id
        --     ,_new_app_tenant_subscription.id,
        --     _expiration_date
        --   );
        -- end if;
      end loop;

      -- this will void out any unused licenses and maybe other stuff
      perform app_fn.deactivate_app_tenant_subscription(_existing_anchor_subscription.id);
    elsif _license_pack.type = 'addon' then
      -- create the new subscription
      insert into app.app_tenant_subscription(app_tenant_id, license_pack_id, is_anchor_subscription)
      values (_app_tenant.id, _license_pack.id, false)
      returning *
      into _new_app_tenant_subscription;

    end if;

    return _new_app_tenant_subscription;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.subscribe_to_license_pack_existing_tenant:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.subscribe_to_license_pack_existing_tenant(_license_pack_key text, _existing_tenant_id text, _force_subscribe boolean) OWNER TO postgres;

--
-- Name: subscribe_to_license_pack_new_tenant(text, app_fn.new_app_tenant_info, boolean); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.subscribe_to_license_pack_new_tenant(_license_pack_key text, _new_tenant_info app_fn.new_app_tenant_info, _allow_discontinued boolean DEFAULT false) RETURNS app.app_tenant_subscription
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _license_pack app.license_pack;
    _license_type app.license_type;
    _license_pack_license_type app.license_pack_license_type;
    _license app.license;
    _user_info app_fn.new_app_user_info;
    _app_tenant app.app_tenant;
    _contact app.contact;
    _app_user app.app_user;
    _app_tenant_subscription app.app_tenant_subscription;
    _expiration_date date;
    _implicit_add_on_key text;
    _implicit_add_on_license_pack app.license_pack;
    _err_context text;
  BEGIN
    select *
    into _license_pack
    from app.license_pack
    where key = _license_pack_key
    and (
      _new_tenant_info.type in ('demo', 'test', 'tutorial') 
      or availability = 'published'
      or (_allow_discontinued = true and availability = 'discontinued')
    )
    ;

    if _license_pack.id is null then
      raise exception 'no published license pack for key: %', _license_pack_key;
    end if;

    if _new_tenant_info.type = 'anchor' then
      select *
      into _app_tenant
      from app.app_tenant
      where type = 'anchor'
      ;
    end if;

    if _new_tenant_info.type = 'customer' then
      select *
      into _app_tenant
      from app.app_tenant
      where name = _new_tenant_info.name
      and type = 'customer'
      ;
    end if;

    if _new_tenant_info.type = 'demo' then
      select *
      into _app_tenant
      from app.app_tenant
      where identifier = _new_tenant_info.identifier
      and type = 'demo'
      ;
    end if;

    if _new_tenant_info.type = 'tutorial' then
      select *
      into _app_tenant
      from app.app_tenant
      where identifier = _new_tenant_info.identifier
      and type = 'tutorial'
      ;
    end if;

    if _app_tenant.id is not null then
      raise exception 'BK101:%: this app tenant already exists.  please use app_fn.subscribe_to_license_pack_existing_tenant()', _app_tenant_subscription.id;
    end if;

    if _license_pack.type != 'anchor' then
      raise exception 'new tenants can only be create with anchor subscription.';
    end if;

    _new_tenant_info.type := coalesce(_new_tenant_info.type, 'customer');

    --------------  create the app tenant
    _app_tenant := (select app_fn.create_app_tenant(_new_tenant_info));

    _expiration_date := case
      when _license_pack.expiration_interval = 'explicit' then _license_pack.explicit_expiration_date
      when _license_pack.expiration_interval = 'none' then null
      when _license_pack.expiration_interval = 'quarter' then current_date + ((_license_pack.expiration_interval_multiplier * 3)::text || ' ' || 'month'::text)::interval
      else current_date + (coalesce(_license_pack.expiration_interval_multiplier, 1)::text || ' ' || _license_pack.expiration_interval::text)::interval
    end;
    
    insert into app.app_tenant_subscription(app_tenant_id, license_pack_id, expiration_date)
    values (_app_tenant.id, _license_pack.id, _expiration_date)
    returning *
    into _app_tenant_subscription;

    foreach _implicit_add_on_key in array coalesce(_license_pack.implicit_add_on_keys::text[], '{}'::text[])::text[] loop
      select * 
      into _implicit_add_on_license_pack
      from app.license_pack
      where key = _implicit_add_on_key
      and (_allow_discontinued = true or availability = 'published')
      ;
      if _license_pack.id is null then
        raise exception 'no add on license pack for key: %', _implicit_add_on_key;
      end if;

      _expiration_date := case
        when _implicit_add_on_license_pack.expiration_interval = 'explicit' then _implicit_add_on_license_pack.explicit_expiration_date
        when _implicit_add_on_license_pack.expiration_interval = 'none' then null
        when _implicit_add_on_license_pack.expiration_interval = 'quarter' then current_date + ((_implicit_add_on_license_pack.expiration_interval_multiplier * 3)::text || ' ' || 'month'::text)::interval
        else current_date + (coalesce(_implicit_add_on_license_pack.expiration_interval_multiplier, 1)::text || ' ' || _implicit_add_on_license_pack.expiration_interval::text)::interval
      end;
      insert into app.app_tenant_subscription(
        app_tenant_id
        ,license_pack_id
        ,is_anchor_subscription
        ,expiration_date)
      values (_app_tenant.id, _implicit_add_on_license_pack.id, false, _expiration_date::date)
      ;
    end loop;

    update app.app_tenant set
      anchor_subscription_id = _app_tenant_subscription.id
    where id = _app_tenant.id
    returning * into _app_tenant;

    if (_new_tenant_info.admin_user_info).username is not null then -- create all licenses that should be assigned on subscription
      select *
      into _app_user
      from app.app_user
      where app_tenant_id = _app_tenant.id
      and username = (_new_tenant_info.admin_user_info).username
      ;

      for _license_pack_license_type in
        select *
        from app.license_pack_license_type
        where license_pack_id = _license_pack.id
        and assign_upon_subscription = true
      loop
        _expiration_date := case
          when _license_pack_license_type.expiration_interval = 'explicit' then _license_pack_license_type.explicit_expiration_date
          when _license_pack_license_type.expiration_interval = 'none' then null
          when _license_pack_license_type.expiration_interval = 'quarter' then current_date + ((_license_pack_license_type.expiration_interval_multiplier * 3)::text || ' ' || 'month'::text)::interval
          else current_date + (coalesce(_license_pack_license_type.expiration_interval_multiplier, 1)::text || ' ' || _license_pack_license_type.expiration_interval::text)::interval
        end;
        perform app_fn.force_provision_tenant_license(
          _license_pack_license_type.license_type_key
          ,_app_tenant.id
          ,_app_user.id
          ,_app_tenant_subscription.id
          ,_expiration_date
        );
      end loop;
    end if;

    return _app_tenant_subscription;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.subscribe_to_license_pack_new_tenant:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.subscribe_to_license_pack_new_tenant(_license_pack_key text, _new_tenant_info app_fn.new_app_tenant_info, _allow_discontinued boolean) OWNER TO postgres;

--
-- Name: support_email(); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.support_email() RETURNS text
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
  DECLARE
    _app_tenant_group app.app_tenant_group;
    _app_user_info jsonb;
    _role text;
    _err_context text;
  BEGIN
    _role := coalesce(current_setting('role', 't'), 'app_anon');
    if _role = 'app_anon' then
      return 'help@ourvisualbrain.com';
    else
      select atg.*
      into _app_tenant_group
      from app.app_tenant_group atg
      join app.app_tenant_group_member atgm on atgm.app_tenant_group_id = atg.id
      where atgm.app_tenant_id = auth_fn.current_app_user()->>'app_tenant_id'
      limit 1
      ;
      return coalesce(_app_tenant_group.support_email, 'help@ourvisualbrain.com');
    end if;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.support_email:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.support_email() OWNER TO postgres;

--
-- Name: supportable_app_tenants(text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.supportable_app_tenants(_app_tenant_group_id text DEFAULT NULL::text) RETURNS SETOF app_fn.supportable_app_tenant_info
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
  DECLARE
    _app_tenant_group app.app_tenant_group;
    _err_context text;
  BEGIN
    if 
      auth_fn.app_user_has_permission('p:app-tenant-group-admin') = false and
      auth_fn.app_user_has_permission('p:super-admin') = false
    then
      raise exception 'user is not an app tenant group admin or super admin';
    end if;

    if auth_fn.app_user_has_permission('p:super-admin') = false then
      select *
      into _app_tenant_group
      from app.app_tenant_group atg
      join app.app_tenant_group_admin atga on atga.app_tenant_group_id = atg.id
      where atga.app_user_id = auth_fn.current_app_user()->>'app_user_id'
      ;

      if _app_tenant_group.id is null then
        raise exception 'user is not an admin of any groups';
      end if;

      return query
      select
        t.id
        ,t.name
        ,lp.key
      from app.app_tenant t
      join app.app_tenant_group_member atgm on t.id = atgm.app_tenant_id
      join app.app_tenant_subscription ats on ats.id = t.anchor_subscription_id
      join app.license_pack lp on lp.id = ats.license_pack_id
      where atgm.app_tenant_group_id = _app_tenant_group.id
      order by t.name
      ;
    else
      if _app_tenant_group_id is not null then
        select *
        into _app_tenant_group
        where id = _app_tenant_group_id
        ;

        return query
        select
          t.id
          ,t.name
          ,lp.key
        from app.app_tenant t
        join app.app_tenant_group_member atgm on t.id = atgm.app_tenant_id
        join app.app_tenant_subscription ats on ats.id = t.anchor_subscription_id
        join app.license_pack lp on lp.id = ats.license_pack_id
        where atgm.app_tenant_group_id = _app_tenant_group.id
        order by t.name
        ;
      else
        return query
        select
          t.id
          ,t.name
          ,lp.key
        from app.app_tenant t
        join app.app_tenant_subscription ats on ats.id = t.anchor_subscription_id
        join app.license_pack lp on lp.id = ats.license_pack_id
        where t.type = 'customer'
        and ats.inactive = false
        order by t.name
        ;
      end if;
    end if;


    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.supportable_app_tenants:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.supportable_app_tenants(_app_tenant_group_id text) OWNER TO postgres;

--
-- Name: unvoid_licenses(text[]); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.unvoid_licenses(_license_ids text[]) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _err_context text;
  BEGIN
    delete from app.license where id = any(_license_ids);
    return true;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.un_void_licenses:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.unvoid_licenses(_license_ids text[]) OWNER TO postgres;

--
-- Name: update_app_tenant_name(text, text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.update_app_tenant_name(_app_tenant_id text, _name text) RETURNS app.app_tenant
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _app_tenant app.app_tenant;
    _err_context text;
  BEGIN
    select * into _app_tenant from app.app_tenant where id = _app_tenant_id;

    if _app_tenant.id is null then
      raise exception 'no app tenant for _license_id';
    end if;

    update app.app_tenant set
      name = _name
    where id = _app_tenant_id
    returning *
    into _app_tenant
    ;

    return _app_tenant;
  
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.update_app_tenant_name:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.update_app_tenant_name(_app_tenant_id text, _name text) OWNER TO postgres;

--
-- Name: update_app_tenant_setting(text, text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.update_app_tenant_setting(_key text, _value text) RETURNS app.app_tenant
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _current_settings jsonb;
    _app_tenant_id text;
    _app_tenant app.app_tenant;
  BEGIN
    _app_tenant_id := auth_fn.current_app_user()->>'app_tenant_id';
    select settings into _current_settings from app.app_tenant where id = _app_tenant_id;

    _current_settings := _current_settings || jsonb_build_object(_key, _value);

    update app.app_tenant set settings = _current_settings where id = _app_tenant_id returning * into _app_tenant;

    return _app_tenant;
  END
  $$;


ALTER FUNCTION app_fn.update_app_tenant_setting(_key text, _value text) OWNER TO postgres;

--
-- Name: update_app_user_preferred_language(text, text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.update_app_user_preferred_language(_app_user_id text, _language_id text) RETURNS app.app_user
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _app_user app.app_user;
    _language app.supported_language;
    _err_context text;
  BEGIN
    select * into _app_user from app.app_user where id = _app_user_id;
    if _app_user.id is null then
      raise exception 'no app_user for id: %', _app_user_id;
    end if;

    select * into _language from app.supported_language where id = _language_id;
    if _language.id is null then
      raise exception 'no language for id: %', _language_id;
    end if;


    update app.app_user set
      language_id = _language.id
    where id = _app_user.id
    returning * 
    into _app_user
    ;

    return _app_user;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.update_app_user_preferred_language:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.update_app_user_preferred_language(_app_user_id text, _language_id text) OWNER TO postgres;

--
-- Name: update_contact_info(text, app_fn.update_contact_info_input); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.update_contact_info(_contact_id text, _contact_info app_fn.update_contact_info_input) RETURNS app.contact
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _contact app.contact;
    _err_context text;
  BEGIN
    select * into _contact from app.contact where id = _contact_id;

    update app.contact set
      first_name = coalesce(_contact_info.first_name, first_name)
      ,last_name = coalesce(_contact_info.last_name, last_name)
      ,office_phone = coalesce(_contact_info.office_phone, office_phone)
      ,cell_phone = coalesce(_contact_info.cell_phone, cell_phone)
    where id = _contact.id;

    return _contact;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.update_contact_info:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.update_contact_info(_contact_id text, _contact_info app_fn.update_contact_info_input) OWNER TO postgres;

--
-- Name: update_license_expiration(text, date); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.update_license_expiration(_license_id text, _expiration_date date DEFAULT NULL::date) RETURNS app.license
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _license app.license;
    _err_context text;
  BEGIN
    select * into _license from app.license where id = _license_id;

    if _license.id is null then
      raise exception 'no license for _license_id';
    end if;

    update app.license set
      expiration_date = _expiration_date
    where id = _license_id
    returning *
    into _license
    ;

    return _license;
  
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.update_license_expiration:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.update_license_expiration(_license_id text, _expiration_date date) OWNER TO postgres;

--
-- Name: app_route; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.app_route (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    name text NOT NULL,
    application_key text NOT NULL,
    permission_key text,
    description text,
    path text NOT NULL,
    menu_behavior app.app_route_menu_behavior DEFAULT 'none'::app.app_route_menu_behavior NOT NULL,
    menu_parent_name text,
    menu_ordinal integer
);


ALTER TABLE app.app_route OWNER TO postgres;

--
-- Name: upsert_app_route(app_fn.app_route_info); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.upsert_app_route(_app_route_info app_fn.app_route_info) RETURNS app.app_route
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _app_route app.app_route;
    _err_context text;
  BEGIN

    -- insert into app.app_route(
    --   app
    -- )

    return _app_route;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.create_app_route:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.upsert_app_route(_app_route_info app_fn.app_route_info) OWNER TO postgres;

--
-- Name: app_tenant_group; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.app_tenant_group (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    name text NOT NULL,
    support_email text DEFAULT 'help@ourvisualbrain.com'::text NOT NULL
);


ALTER TABLE app.app_tenant_group OWNER TO postgres;

--
-- Name: upsert_app_tenant_group(app_fn.app_tenant_group_info); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.upsert_app_tenant_group(_app_tenant_group_info app_fn.app_tenant_group_info) RETURNS app.app_tenant_group
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _app_tenant_group app.app_tenant_group;
    _err_context text;
  BEGIN
    select * into _app_tenant_group from app.app_tenant_group 
    where id = _app_tenant_group_info.id
    ;

    if _app_tenant_group.id is null then
      insert into app.app_tenant_group(
        name
        ,support_email
      ) values (
        _app_tenant_group_info.name
        ,coalesce(_app_tenant_group_info.support_email, 'help@ourvisualbrain.com')
      )
      returning * into _app_tenant_group;
    else
      update app.app_tenant_group set
        name = _app_tenant_group_info.name
        ,support_email = coalesce(_app_tenant_group_info.support_email, 'help@ourvisualbrain.com')
      where id = _app_tenant_group.id
      returning * into _app_tenant_group
      ;
    end if;

    return _app_tenant_group;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.upsert_app_tenant_group:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.upsert_app_tenant_group(_app_tenant_group_info app_fn.app_tenant_group_info) OWNER TO postgres;

--
-- Name: upsert_license_pack(app_fn.license_pack_info); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.upsert_license_pack(_license_pack_info app_fn.license_pack_info) RETURNS app.license_pack
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _license_pack_license_type app.license_pack_license_type;
    _license_pack app.license_pack;
    _license_type_info app_fn.license_pack_license_type_info;
    _add_on_target_key text;
    _upgrade_config app.upgrade_config;
    _content_slug_info app_fn.content_slug_info;
    _err_context text;
  BEGIN

    if _license_pack_info.id is not null then
      select *
      into _license_pack
      from app.license_pack
      where id = _license_pack_info.id
      ;

      if _license_pack.availability != 'draft' then
        raise exception 'only draft license packs can be edited';
      end if;
    else
      select *
      into _license_pack
      from app.license_pack
      where key = _license_pack_info.key
      and availability = 'draft';
    end if;

    if _license_pack.id is null then
      if _license_pack_info.name is null then
        raise exception 'new license pack must have name';
      end if;

      if _license_pack_info.key is null then
        raise exception 'new license pack must have key';
      end if;

      insert into app.license_pack(
        name
        ,key
        ,renewal_frequency
        ,expiration_interval
        ,expiration_interval_multiplier
        ,explicit_expiration_date
        ,price
        ,type
        ,upgrade_config
        ,availability
        ,available_add_on_keys
        ,coupon_code
        ,is_public_offering
        ,application_settings
        ,implicit_add_on_keys
      ) values (
        _license_pack_info.name
        ,_license_pack_info.key
        ,coalesce(_license_pack_info.renewal_frequency, 'never')
        ,coalesce(_license_pack_info.expiration_interval, 'none')
        ,coalesce(_license_pack_info.expiration_interval_multiplier, 1)
        ,_license_pack_info.explicit_expiration_date
        ,coalesce(_license_pack_info.price, 0)
        ,coalesce(_license_pack_info.type, 'anchor')
        ,coalesce(_license_pack_info.upgrade_config,row('{}'::app.upgrade_path[])::app.upgrade_config)
        ,'draft'
        ,coalesce(_license_pack_info.available_add_on_keys,'{}')
        ,_license_pack_info.coupon_code
        ,coalesce(_license_pack_info.is_public_offering)
        ,coalesce(_license_pack_info.application_settings, '{}'::app.application_setting[])
        ,coalesce(_license_pack_info.implicit_add_on_keys, '{}'::text[])
      )
      returning *
      into _license_pack
      ;
      foreach _content_slug_info in array(coalesce(_license_pack_info.content_slugs,'{}'))
      loop
        _content_slug_info.entity_type := 'license_pack';
        _content_slug_info.entity_identifier:= _license_pack.id;
        perform app_fn.upsert_content_slug(_content_slug_info);
      end loop;
    else
      update app.license_pack lp set
        name = coalesce(_license_pack_info.name, lp.name)
        ,key = coalesce(_license_pack_info.key, lp.key)
        ,renewal_frequency = coalesce(_license_pack_info.renewal_frequency, lp.renewal_frequency)
        ,expiration_interval = coalesce(_license_pack_info.expiration_interval, lp.expiration_interval)
        ,expiration_interval_multiplier = coalesce(_license_pack_info.expiration_interval_multiplier, 1)
        ,explicit_expiration_date = _license_pack_info.explicit_expiration_date
        ,price = coalesce(_license_pack_info.price, lp.price)
        ,upgrade_config = coalesce(_license_pack_info.upgrade_config, lp.upgrade_config)
        ,available_add_on_keys = coalesce(_license_pack_info.available_add_on_keys, lp.available_add_on_keys)
        ,coupon_code = coalesce(_license_pack_info.coupon_code, lp.coupon_code)
        ,is_public_offering = coalesce(_license_pack_info.is_public_offering, lp.is_public_offering)
        ,implicit_add_on_keys = coalesce(_license_pack_info.implicit_add_on_keys, lp.implicit_add_on_keys)
        ,type = coalesce(_license_pack_info.type, lp.type)
      where id = _license_pack.id
      returning *
      into _license_pack
      ;
    end if;

    foreach _license_type_info in ARRAY(coalesce(_license_pack_info.license_type_infos, '{}'::app_fn.license_pack_license_type_info[]))
    loop
      insert into app.license_pack_license_type(
        license_type_key
        ,license_pack_id
        ,license_count
        ,assign_upon_subscription
        ,unlimited_provision
        ,expiration_interval
        ,expiration_interval_multiplier
        ,explicit_expiration_date
      )
      values (
        _license_type_info.license_type_key
        ,_license_pack.id
        ,_license_type_info.license_count
        ,_license_type_info.assign_upon_subscription
        ,_license_type_info.unlimited_provision
        ,coalesce(_license_type_info.expiration_interval, 'none')::app.expiration_interval
        ,coalesce(_license_type_info.expiration_interval_multiplier, 1)::integer
        ,_license_type_info.explicit_expiration_date
      )
      on conflict (license_pack_id, license_type_key)
      do update set
        license_count = coalesce(_license_type_info.license_count, license_pack_license_type.license_count)
        ,assign_upon_subscription = coalesce(_license_type_info.assign_upon_subscription, license_pack_license_type.assign_upon_subscription)
        ,unlimited_provision = coalesce(_license_type_info.unlimited_provision, license_pack_license_type.unlimited_provision)
        ,expiration_interval = coalesce(_license_type_info.expiration_interval, license_pack_license_type.expiration_interval)
        ,expiration_interval_multiplier = coalesce(_license_type_info.expiration_interval_multiplier, 1)::integer
        ,explicit_expiration_date = _license_type_info.explicit_expiration_date
      ;
    end loop;

    _upgrade_config := app_fn.calculate_upgrade_config(_license_pack);
    update app.license_pack set upgrade_config = _upgrade_config where id = _license_pack.id returning * into _license_pack;

    return _license_pack;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.create_license_pack:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn.upsert_license_pack(_license_pack_info app_fn.license_pack_info) OWNER TO postgres;

--
-- Name: void_licenses(text, text, app.license_status_reason, integer); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.void_licenses(_license_type_key text, _app_tenant_subscription_id text, _reason app.license_status_reason, _number_to_void integer DEFAULT 1) RETURNS SETOF app.license
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _app_tenant_subscription app.app_tenant_subscription;
    _lplt app.license_pack_license_type;
    _license_type app.license_type;
    _license app.license;
    _provisioned_count integer;
    _available_count integer;
    _err_context text;
  BEGIN
    select * into _app_tenant_subscription from app.app_tenant_subscription where id = _app_tenant_subscription_id;
    if _app_tenant_subscription.id is null then raise exception 'no subscription for id'; end if;

    select * into _lplt from app.license_pack_license_type 
    where license_pack_id = _app_tenant_subscription.license_pack_id
    and license_type_key = _license_type_key
    ;
    
    select count(*) into _provisioned_count from app.license 
    where subscription_id = _app_tenant_subscription.id and license_type_key = _license_type_key;

    select * into _license_type from app.license_type where key = _license_type_key;

    _available_count := _lplt.license_count - _provisioned_count;

    if _available_count < _number_to_void then 
      raise exception 'cannot void more licenses than are available';
      -- raise exception 'cannot void more licenses than are available: %', jsonb_build_object(
      --   'ltk', _license_type.key
      --   ,'lpid', _lplt.id
      --   ,'lplc', _lplt.license_count
      --   ,'pc', _provisioned_count
      --   ,'ac', _available_count
      --   ,'nv', _number_to_void
      --   ,'lp', (select key from app.license_pack where id = _app_tenant_subscription.license_pack_id)
      -- ); 
    end if;

    for i in 1.._number_to_void loop
      insert into app.license(
        app_tenant_id
        ,name
        ,license_type_key
        ,subscription_id
        ,expiration_date
        ,status
        ,status_reason
      )
      values (
        _app_tenant_subscription.app_tenant_id
        ,_license_type.name
        ,_license_type.key
        ,_app_tenant_subscription.id
        ,current_date
        ,'void'
        ,_reason
      )
      returning *
      into _license;

      return next _license;
    end loop;
    
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.void_licenses:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn.void_licenses(_license_type_key text, _app_tenant_subscription_id text, _reason app.license_status_reason, _number_to_void integer) OWNER TO postgres;

--
-- Name: do_housekeeping_tasks(text); Type: FUNCTION; Schema: app_fn_private; Owner: postgres
--

CREATE FUNCTION app_fn_private.do_housekeeping_tasks(_app_user_id text) RETURNS app_fn.housekeeping_task[]
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    _housekeeping_tasks app_fn.housekeeping_task[];
    _eula app.eula;
    _signed_eula app.signed_eula;
    _err_context text;
  BEGIN
    _housekeeping_tasks := array[]::app_fn.housekeeping_task[];

    select se.* 
      into _signed_eula 
      from app.signed_eula se 
      join app.eula e on e.id = se.eula_id 
      where e.is_inactive = false;

    if _signed_eula.id is null then
      select * into _eula from app.eula where is_inactive = false;
      if _eula.id is not null then
        _housekeeping_tasks := array_append(_housekeeping_tasks,
          row(
            'sign-eula'
            ,jsonb_build_object(
              'id', _eula.id
              ,'content', _eula.content
            )
          )::app_fn.housekeeping_task
        );
      end if;
    end if;

    return _housekeeping_tasks;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn_private.do_housekeeping_tasks:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn_private.do_housekeeping_tasks(_app_user_id text) OWNER TO postgres;

--
-- Name: do_sign_current_eula(text, text, text); Type: FUNCTION; Schema: app_fn_private; Owner: postgres
--

CREATE FUNCTION app_fn_private.do_sign_current_eula(_eula_id text, _app_tenant_id text, _app_user_id text) RETURNS app.signed_eula
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _eula app.eula;
    _signed_eula app.signed_eula;
    _err_context text;
  BEGIN
    select *
    into _eula
    from app.eula
    where id = _eula_id
    ;

    if _eula.is_inactive then
      raise exception 'cannot sign inactive eula';
    end if;
    
    insert into app.signed_eula(
      eula_id
      ,app_tenant_id
      ,signed_by_app_user_id
      ,signed_at
      ,content
    )
    select
      _eula.id
      ,_app_tenant_id
      ,_app_user_id
      ,current_timestamp
      ,_eula.content
    on conflict(signed_by_app_user_id, eula_id) do update set content = _eula.content
    returning * into _signed_eula
    ;      

    return _signed_eula;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn_private.do_sign_current_eula:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION app_fn_private.do_sign_current_eula(_eula_id text, _app_tenant_id text, _app_user_id text) OWNER TO postgres;

--
-- Name: contact_from_brochure(app_fn_public.brochure_contact_input); Type: FUNCTION; Schema: app_fn_public; Owner: postgres
--

CREATE FUNCTION app_fn_public.contact_from_brochure(_brochure_contact_input app_fn_public.brochure_contact_input) RETURNS app_fn_public.brochure_contact_result
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _app_user_auth0_info auth_fn.app_user_auth0_info;
    _app_user app.app_user;
    _app_tenant_subscription app.app_tenant_subscription;
    _organization app.organization;
    _result app_fn_public.brochure_contact_result;
    _contact app.contact;
    _err_context text;
  BEGIN
    select * into _app_user from app.app_user where lower(recovery_email) = lower(trim(both from (_brochure_contact_input.contact_info).email, ' '));

    if _app_user.id is null then
      select * into _app_tenant_subscription from app.app_tenant_subscription where id = (
        select anchor_subscription_id from app.app_tenant where type = 'anchor'
      );

      insert into app.organization(name, app_tenant_id)
      select _brochure_contact_input.company_name, _app_tenant_subscription.app_tenant_id
      on conflict(app_tenant_id, name) do update
      set name = _brochure_contact_input.company_name
      returning * into _organization;

      _app_user_auth0_info := (select app_fn.create_new_licensed_app_user(
        '%-guest-user'::text,
        _app_tenant_subscription.id::text,
        row(
          (_brochure_contact_input.contact_info).email||'-guest' -- username text
          ,_app_tenant_subscription.app_tenant_id -- ,app_tenant_id text
          ,null -- ,ext_auth_id text
          ,null -- ,ext_crm_id text  -- hijacking this field
          ,row(
            _organization.id -- organization_id text
            ,null -- ,location_id text
            ,(_brochure_contact_input.contact_info).email-- ,email text
            ,(_brochure_contact_input.contact_info).first_name -- ,first_name text
            ,(_brochure_contact_input.contact_info).last_name -- ,last_name text
            ,(_brochure_contact_input.contact_info).cell_phone -- ,cell_phone text
            ,(_brochure_contact_input.contact_info).office_phone -- ,office_phone text
            ,null -- ,title text
            ,null -- ,nickname text
            ,null -- ,external_id text
          )::app_fn.create_contact_input
        )::app_fn.new_app_user_info
      ));
    else
      _app_user_auth0_info := (select auth_fn_private.do_get_app_user_info(_app_user.recovery_email, _app_user.app_tenant_id));
    end if;

    select * into _contact from app.contact where id = _app_user_auth0_info.contact_id;

    _result.app_user_auth0_info := _app_user_auth0_info;
    _result.contact := _contact;
    _result.message := _brochure_contact_input.message;

    return _result;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn_public.contact_from_brochure:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;

  end;
  $$;


ALTER FUNCTION app_fn_public.contact_from_brochure(_brochure_contact_input app_fn_public.brochure_contact_input) OWNER TO postgres;

--
-- Name: public_offerings(); Type: FUNCTION; Schema: app_fn_public; Owner: postgres
--

CREATE FUNCTION app_fn_public.public_offerings() RETURNS SETOF app.license_pack
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
  DECLARE
    _public_offerings app.license_pack;
    _retval jsonb;
  BEGIN

    return query
    select *
    from app.license_pack
    where is_public_offering = true
    and availability = 'published'
    ;
  end;
  $$;


ALTER FUNCTION app_fn_public.public_offerings() OWNER TO postgres;

--
-- Name: request_pricing(app_fn_public.request_pricing_info); Type: FUNCTION; Schema: app_fn_public; Owner: postgres
--

CREATE FUNCTION app_fn_public.request_pricing(_request_pricing_info app_fn_public.request_pricing_info) RETURNS auth_fn.app_user_auth0_info
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _app_user_auth0_info auth_fn.app_user_auth0_info;
    _app_user app.app_user;
    _app_tenant_subscription app.app_tenant_subscription;
    _organization app.organization;
    _err_context text;
  BEGIN
    select * into _app_user from app.app_user where lower(recovery_email) = lower(trim(both from (_request_pricing_info.contact_info).email, ' '));

    if _app_user.id is null then
      select * into _app_tenant_subscription from app.app_tenant_subscription where id = (
        select anchor_subscription_id from app.app_tenant where type = 'anchor'
      );

      insert into app.organization(name, app_tenant_id)
      select _request_pricing_info.company_name, _app_tenant_subscription.app_tenant_id
      on conflict(app_tenant_id, name) do update
      set name = _request_pricing_info.company_name
      returning * into _organization;

      _app_user_auth0_info := (select app_fn.create_new_licensed_app_user(
        '%-guest-user'::text,
        _app_tenant_subscription.id::text,
        row(
          (_request_pricing_info.contact_info).email||'-guest' -- username text
          ,_app_tenant_subscription.app_tenant_id -- ,app_tenant_id text
          ,null -- ,ext_auth_id text
          ,_request_pricing_info.library_id -- ,ext_crm_id text  -- hijacking this field
          ,row(
            _organization.id -- organization_id text
            ,null -- ,location_id text
            ,(_request_pricing_info.contact_info).email-- ,email text
            ,(_request_pricing_info.contact_info).first_name -- ,first_name text
            ,(_request_pricing_info.contact_info).last_name -- ,last_name text
            ,(_request_pricing_info.contact_info).cell_phone -- ,cell_phone text
            ,(_request_pricing_info.contact_info).office_phone -- ,office_phone text
            ,null -- ,title text
            ,null -- ,nickname text
            ,null -- ,external_id text
          )::app_fn.create_contact_input
        )::app_fn.new_app_user_info
      ));
    else
      _app_user_auth0_info := (select auth_fn_private.do_get_app_user_info(_app_user.recovery_email, _app_user.app_tenant_id));
    end if;

    return _app_user_auth0_info;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn_public.request_pricing:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;

  end;
  $$;


ALTER FUNCTION app_fn_public.request_pricing(_request_pricing_info app_fn_public.request_pricing_info) OWNER TO postgres;

--
-- Name: subscribe_from_brochure(app_fn_public.subscribe_from_brochure_input); Type: FUNCTION; Schema: app_fn_public; Owner: postgres
--

CREATE FUNCTION app_fn_public.subscribe_from_brochure(_subscribe_from_brochure_input app_fn_public.subscribe_from_brochure_input) RETURNS app_fn_public.subscribe_from_brochure_result
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _result app_fn_public.subscribe_from_brochure_result;
    _contact app.contact;
    _license_pack app.license_pack;
    _app_user_auth0_info auth_fn.app_user_auth0_info;
    _app_tenant_subscription app.app_tenant_subscription;
    _err_context text;
  BEGIN
    update app.app_user set recovery_email = recovery_email||'-subscribed'
    where recovery_email = (((_subscribe_from_brochure_input.new_app_tenant_info).admin_user_info).contact_info).email
    and app_tenant_id = (select id from app.app_tenant where type = 'anchor');

    _app_tenant_subscription := (select app_fn.subscribe_to_license_pack_new_tenant(
      _subscribe_from_brochure_input.license_pack_key
      ,_subscribe_from_brochure_input.new_app_tenant_info
    ));

    select * 
    into _contact
    from app.contact
    where app_tenant_id = _app_tenant_subscription.app_tenant_id
    and email = (((_subscribe_from_brochure_input.new_app_tenant_info).admin_user_info).contact_info).email
    ;

    select *
    into _license_pack
    from app.license_pack
    where id = _app_tenant_subscription.license_pack_id
    ;

    _app_user_auth0_info := (select auth_fn_private.do_get_app_user_info(_contact.email, _app_tenant_subscription.app_tenant_id));
    _result.app_user_auth0_info := _app_user_auth0_info;
    _result.license_pack := _license_pack;
    _result.custom_plan_requested := _subscribe_from_brochure_input.request_custom_plan;

    return _result;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.subscribe_from_brochure:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;

  end;
  $$;


ALTER FUNCTION app_fn_public.subscribe_from_brochure(_subscribe_from_brochure_input app_fn_public.subscribe_from_brochure_input) OWNER TO postgres;

--
-- Name: upsert_registration(app_fn_public.registration_info); Type: FUNCTION; Schema: app_fn_public; Owner: postgres
--

CREATE FUNCTION app_fn_public.upsert_registration(_registration_info app_fn_public.registration_info) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _app_tenant_subscription app.app_tenant_subscription;
    _registration app.registration;
    _app_user app.app_user;
    _app_tenant app.app_tenant;
    _err_context text;
    _retval jsonb;
  BEGIN
    _app_tenant_subscription := app_fn.subscribe_to_license_pack_new_tenant(
      _registration_info.license_pack_key
      ,row(
        _registration_info.company_name -- name
        ,_registration_info.email -- identifier
        ,false -- registration complete
        ,'customer'::app.app_tenant_type
        ,null
        ,row(
          _registration_info.email
          ,null
          ,null
          ,null
          ,row(
            null
            ,null
            ,_registration_info.email
            ,_registration_info.first_name
            ,_registration_info.last_name
            ,null
            ,_registration_info.phone
            ,null
            ,null
            ,null
          )::app_fn.create_contact_input
        )::app_fn.new_app_user_info
      )::app_fn.new_app_tenant_info
    );

    select *
    into _app_user
    from app.app_user
    where app_tenant_id = _app_tenant_subscription.app_tenant_id
    and username = _registration_info.email
    ;

    select *
    into _app_tenant
    from app.app_tenant
    where id = _app_tenant_subscription.app_tenant_id
    ;

    _retval := (
      select to_jsonb(
        auth_fn.get_app_user_info(
          _registration_info.email
          ,(
            select app_tenant_id from app.app_user where recovery_email = _registration_info.email
          )
        )
      )
    );

    return _retval;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'app_fn.upsert_registration:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION app_fn_public.upsert_registration(_registration_info app_fn_public.registration_info) OWNER TO postgres;

--
-- Name: authenticate_bootstrap(text); Type: FUNCTION; Schema: auth_bootstrap; Owner: postgres
--

CREATE FUNCTION auth_bootstrap.authenticate_bootstrap(_username text) RETURNS auth_bootstrap.jwt_token_bootstrap
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $$
  DECLARE
    _app_user app.app_user;
    _token auth_bootstrap.jwt_token_bootstrap;
  BEGIN
    select * into _app_user from app.app_user where username = _username;

    _token.current_app_user := (select auth_fn_private.do_get_app_user_info(_app_user.username, _app_user.app_tenant_id));
    _token.role := 'app_usr';
    _token.app_user_id := (_token.current_app_user).app_user_id;
    _token.app_tenant_id := (_token.current_app_user).app_tenant_id;
    _token.permissions := array_to_string((_token.current_app_user).permissions, ',');

    return _token;

  end;
  $$;


ALTER FUNCTION auth_bootstrap.authenticate_bootstrap(_username text) OWNER TO postgres;

--
-- Name: bs_users(); Type: FUNCTION; Schema: auth_bootstrap; Owner: postgres
--

CREATE FUNCTION auth_bootstrap.bs_users() RETURNS SETOF app.app_user
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $$
  DECLARE
    _token auth_bootstrap.jwt_token_bootstrap;
  BEGIN
    return query
    select *
    from app.app_user;
  end;
  $$;


ALTER FUNCTION auth_bootstrap.bs_users() OWNER TO postgres;

--
-- Name: app_user_has_access(text); Type: FUNCTION; Schema: auth_fn; Owner: postgres
--

CREATE FUNCTION auth_fn.app_user_has_access(_app_tenant_id text) RETURNS boolean
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  DECLARE
    _has_super_admin boolean;
    _usr_app_tenant_id text;
    _retval boolean;
  BEGIN
    _usr_app_tenant_id := (select auth_fn.current_app_user()->>'app_tenant_id');
    _has_super_admin := (select auth_fn.app_user_has_permission('p:super-admin'));

    _retval := case
      when _has_super_admin = true then
        true
      else
        _usr_app_tenant_id = _app_tenant_id
    end;

    RETURN _retval;
  end;
  $$;


ALTER FUNCTION auth_fn.app_user_has_access(_app_tenant_id text) OWNER TO postgres;

--
-- Name: FUNCTION app_user_has_access(_app_tenant_id text); Type: COMMENT; Schema: auth_fn; Owner: postgres
--

COMMENT ON FUNCTION auth_fn.app_user_has_access(_app_tenant_id text) IS 'Verify if a user has access to an entity via the app_tenant_id';


--
-- Name: app_user_has_game_library(text); Type: FUNCTION; Schema: auth_fn; Owner: postgres
--

CREATE FUNCTION auth_fn.app_user_has_game_library(_game_id text) RETURNS boolean
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  DECLARE
    _tenant_identifier text;
    _tenant_permissions text[];
    _game_permissions text[];
    _retval boolean;
  BEGIN
    select identifier into _tenant_identifier from app.app_tenant where id = auth_fn.current_app_user()->>'app_tenant_id';
    if _tenant_identifier = 'anchor' then
      return true;
    end if;

    with keys as (
      select distinct ltp.permission_key
      from app.license_type_permission ltp
      join app.license_type lt on lt.key = ltp.license_type_key
      join app.license_pack_license_type lplt on lplt.license_type_key = lt.key
      join app.license_pack lp on lp.id = lplt.license_pack_id
      join app.app_tenant_subscription ats on ats.license_pack_id = lp.id
      where ats.app_tenant_id = auth_fn.current_app_user()->>'app_tenant_id'
      and ats.inactive = false
      and lt.permission_key = 'Tenant'
      group by ltp.permission_key
    )
    select array_agg(permission_key)
    into _tenant_permissions
    from keys
    ;

    _retval := _tenant_permissions && _game_permissions;

    RETURN _retval;
  end;
  $$;


ALTER FUNCTION auth_fn.app_user_has_game_library(_game_id text) OWNER TO postgres;

--
-- Name: app_user_has_library(text); Type: FUNCTION; Schema: auth_fn; Owner: postgres
--

CREATE FUNCTION auth_fn.app_user_has_library(_library_id text) RETURNS boolean
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  DECLARE
    _tenant_identifier text;
    _tenant_permissions text[];
    _library_permission text;
    _retval boolean;
  BEGIN

    _library_permission := 'l:' || _library_id;
    _retval := (regexp_split_to_array(auth_fn.current_app_user()->>'permissions',','))@>(array[_library_permission]);

    RETURN _retval;
  end;
  $$;


ALTER FUNCTION auth_fn.app_user_has_library(_library_id text) OWNER TO postgres;

--
-- Name: app_user_has_licensing_scope(text); Type: FUNCTION; Schema: auth_fn; Owner: postgres
--

CREATE FUNCTION auth_fn.app_user_has_licensing_scope(_app_tenant_id text) RETURNS boolean
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  DECLARE
    _app_permission_key app.permission_key;
    _ls_app_tenant_id_json jsonb;
    _ls_app_tenant_id text;
  BEGIN
    if auth_fn.current_app_user()->>'permission_key' in ('SuperAdmin', 'Support') then
      return true;
    end if;

    for _ls_app_tenant_id_json in (select jsonb_array_elements(auth_fn.current_app_user()->'licensing_scope'))
    loop
      _ls_app_tenant_id := (select _ls_app_tenant_id_json #>> '{}');
      if _ls_app_tenant_id = _app_tenant_id then
        return true;
      end if;
    end loop;

    return false;
  end;
  $$;


ALTER FUNCTION auth_fn.app_user_has_licensing_scope(_app_tenant_id text) OWNER TO postgres;

--
-- Name: app_user_has_permission(text); Type: FUNCTION; Schema: auth_fn; Owner: postgres
--

CREATE FUNCTION auth_fn.app_user_has_permission(_permission text) RETURNS boolean
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  DECLARE
    _retval boolean;

  BEGIN
    _retval := position(_permission in auth_fn.current_app_user()->>'permissions') > 0;

    RETURN _retval;
  end;
  $$;


ALTER FUNCTION auth_fn.app_user_has_permission(_permission text) OWNER TO postgres;

--
-- Name: app_user_has_permission_key(app.permission_key); Type: FUNCTION; Schema: auth_fn; Owner: postgres
--

CREATE FUNCTION auth_fn.app_user_has_permission_key(_permission_key app.permission_key) RETURNS boolean
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  DECLARE
  BEGIN
    if auth_fn.current_app_user()->>'permission_key' = _permission_key::text then
      return true;
    else
      return false;
    end if;
  end;
  $$;


ALTER FUNCTION auth_fn.app_user_has_permission_key(_permission_key app.permission_key) OWNER TO postgres;

--
-- Name: auth_0_pre_registration(text); Type: FUNCTION; Schema: auth_fn; Owner: postgres
--

CREATE FUNCTION auth_fn.auth_0_pre_registration(_email text) RETURNS auth_fn.app_user_auth0_info
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
  DECLARE
    _err_context text;
    _app_user app.app_user;
    _app_tenant_subscription app.app_tenant_subscription;
    _app_user_auth0_info auth_fn.app_user_auth0_info;
  BEGIN

    select * into _app_user from app.app_user where lower(recovery_email) = lower(trim(both from _email, ' '));

    if _app_user.id is null then
      select * into _app_tenant_subscription from app.app_tenant_subscription where id = (
        select anchor_subscription_id from app.app_tenant where type = 'anchor'
      );

       _app_user_auth0_info := (select app_fn.create_new_licensed_app_user(
        '%-guest-user'::text,
        _app_tenant_subscription.id::text,
        row(
          _email -- username text
          ,_app_tenant_subscription.app_tenant_id -- ,app_tenant_id text
          ,null -- ,ext_auth_id text
          ,null -- ,ext_crm_id text
          ,row(
            null -- organization_id text
            ,null -- ,location_id text
            ,_email-- ,email text
            ,null -- ,first_name text
            ,null -- ,last_name text
            ,null -- ,cell_phone text
            ,null -- ,office_phone text
            ,null -- ,title text
            ,null -- ,nickname text
            ,null -- ,external_id text
          )::app_fn.create_contact_input
        )::app_fn.new_app_user_info
      ));
    else
      -- prolly want to change to auth_fn_private.do_get_app_user_info
      _app_user_auth0_info := (select auth_fn.get_app_user_info(_app_user.recovery_email, _app_user.app_tenant_id));
    end if;

    return _app_user_auth0_info;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'auth_fn.auth_0_pre_registration:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION auth_fn.auth_0_pre_registration(_email text) OWNER TO postgres;

--
-- Name: FUNCTION auth_0_pre_registration(_email text); Type: COMMENT; Schema: auth_fn; Owner: postgres
--

COMMENT ON FUNCTION auth_fn.auth_0_pre_registration(_email text) IS '@omit';


--
-- Name: current_app_user(); Type: FUNCTION; Schema: auth_fn; Owner: postgres
--

CREATE FUNCTION auth_fn.current_app_user() RETURNS jsonb
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
  BEGIN
  return current_setting('jwt.claims.current_app_user')::jsonb;
  end;
  $$;


ALTER FUNCTION auth_fn.current_app_user() OWNER TO postgres;

--
-- Name: current_app_user_id(); Type: FUNCTION; Schema: auth_fn; Owner: postgres
--

CREATE FUNCTION auth_fn.current_app_user_id() RETURNS text
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  DECLARE
  BEGIN
    return current_setting('jwt.claims.app_user_id')::text;
  end;
  $$;


ALTER FUNCTION auth_fn.current_app_user_id() OWNER TO postgres;

--
-- Name: get_app_tenant_scope_permissions(text); Type: FUNCTION; Schema: auth_fn; Owner: postgres
--

CREATE FUNCTION auth_fn.get_app_tenant_scope_permissions(_app_tenant_id text) RETURNS text[]
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    _err_context text;
    _permissions text[];
    _tenant_permissions text[];
    _app_tenant app.app_tenant;
    _anchor_tenant_id text;
  BEGIN
    select * into _app_tenant from app.app_tenant where id = _app_tenant_id;
    select id into _anchor_tenant_id from app.app_tenant where type = 'anchor';
    if _app_tenant.parent_app_tenant_id is not null and _app_tenant.parent_app_tenant_id != _anchor_tenant_id then
      _permissions := (select auth_fn.get_app_tenant_scope_permissions(_app_tenant.parent_app_tenant_id));
      return _permissions;
    end if;

    -- with keys as (
    --   select distinct ltp.permission_key
    --   from app.license_type_permission ltp
    --   join app.license_type lt on lt.key = ltp.license_type_key
    --   join app.license_pack_license_type lplt on lplt.license_type_key = lt.key
    --   join app.license_pack lp on lp.id = lplt.license_pack_id
    --   join app.app_tenant_subscription ats on ats.license_pack_id = lp.id
    --   join app.app_tenant apt on apt.anchor_subscription_id = ats.id
    --   where apt.id = _app_tenant_id
    --   and lplt.assign_upon_subscription = true
    --   group by ltp.permission_key
    -- )
    -- select array_agg(permission_key)
    -- into _permissions
    -- from keys
    -- ;
    with keys as (
      select distinct ltp.permission_key
      from app.license_type_permission ltp
      join app.license_type lt on lt.key = ltp.license_type_key
      join app.license_pack_license_type lplt on lplt.license_type_key = lt.key
      join app.license_pack lp on lp.id = lplt.license_pack_id
      join app.app_tenant_subscription ats on ats.license_pack_id = lp.id
      where ats.app_tenant_id = _app_tenant_id
      and lp.type = 'anchor'
      and ats.inactive = false
      and lplt.assign_upon_subscription = true
      group by ltp.permission_key
    )
    select array_agg(permission_key)
    into _permissions
    from keys
    ;

    with keys as (
      select distinct ltp.permission_key
      from app.license_type_permission ltp
      join app.license_type lt on lt.key = ltp.license_type_key
      join app.license_pack_license_type lplt on lplt.license_type_key = lt.key
      join app.license_pack lp on lp.id = lplt.license_pack_id
      join app.app_tenant_subscription ats on ats.license_pack_id = lp.id
      where ats.app_tenant_id = _app_tenant_id
      and ats.inactive = false
      and lt.permission_key = 'Tenant'
      group by ltp.permission_key
    )
    select array_agg(permission_key)
    into _tenant_permissions
    from keys
    ;
    _permissions := array_cat(_permissions, _tenant_permissions);

    _permissions := array_append(_permissions, 'm:admin');

    return _permissions;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'auth_fn.get_app_tenant_scope_permissions:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION auth_fn.get_app_tenant_scope_permissions(_app_tenant_id text) OWNER TO postgres;

--
-- Name: FUNCTION get_app_tenant_scope_permissions(_app_tenant_id text); Type: COMMENT; Schema: auth_fn; Owner: postgres
--

COMMENT ON FUNCTION auth_fn.get_app_tenant_scope_permissions(_app_tenant_id text) IS '@omit';


--
-- Name: get_app_user_info(text, text); Type: FUNCTION; Schema: auth_fn; Owner: postgres
--

CREATE FUNCTION auth_fn.get_app_user_info(_recovery_email_or_id_or_username text, _current_app_tenant_id text) RETURNS auth_fn.app_user_auth0_info
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
  DECLARE
    _err_context text;
    _app_user_auth0_info auth_fn.app_user_auth0_info;
    _app_user app.app_user;
    _working_app_tenant_id text;
    _permission text;
    _permissions text[];
    _has_permission boolean;
  BEGIN
    -- enforce usage of this function explicitly
    --
    select * into _app_user from app.app_user usr
    where usr.recovery_email = _recovery_email_or_id_or_username or usr.id = _recovery_email_or_id_or_username or usr.username = _recovery_email_or_id_or_username
    ;
    if _app_user.id is null then
      raise exception 'no app user';
    end if;

    _has_permission := false;

    if auth_fn.current_app_user()->>'app_user_id' = _app_user.id then
      _has_permission := true;
    elsif auth_fn.app_user_has_permission('p:super-admin') or auth_fn.current_app_user()->>'permission_key' in ('SuperAdmin', 'Support') then
      _has_permission := true;
    elsif (auth_fn.app_user_has_permission('p:demo') and _recovery_email_or_id_or_username = 'fnb-demo') then
      _has_permission := true;
    elsif (auth_fn.app_user_has_permission('p:app-tenant-group-admin') and _recovery_email_or_id_or_username = 'fnb-support') then
      _has_permission := true;
    elsif auth_fn.app_user_has_permission('p:admin') then
      _has_permission := (select auth_fn.app_user_has_licensing_scope(_app_user.app_tenant_id));
    end if;

    if _has_permission = false or _has_permission is null then
      raise exception 'permission denied';
    end if;

    _app_user_auth0_info := (select auth_fn_private.do_get_app_user_info(
      _recovery_email_or_id_or_username
      ,_current_app_tenant_id
    ))
    ;
    -- raise exception '_current_app_tenant_id: %, _app_user_auth_0.app_tenant_id, %', _current_app_tenant_id, _app_user_auth0_info.app_tenant_id;
    return _app_user_auth0_info;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'auth_fn.get_app_user_info:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;  
  $$;


ALTER FUNCTION auth_fn.get_app_user_info(_recovery_email_or_id_or_username text, _current_app_tenant_id text) OWNER TO postgres;

--
-- Name: init_app_tenant_support(text); Type: FUNCTION; Schema: auth_fn; Owner: postgres
--

CREATE FUNCTION auth_fn.init_app_tenant_support(_app_tenant_id text) RETURNS auth_fn.app_user_auth0_info
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
  DECLARE
    _err_context text;
    _app_user_auth0_info auth_fn.app_user_auth0_info;
    _tenant_permissions text[];
  BEGIN
    if 
      auth_fn.app_user_has_permission('p:super-admin') = false and
      auth_fn.app_user_has_permission('p:app-tenant-group-admin') = false
    then
      raise exception 'permission denied';
    end if;
    -- if user is SuperAdmin, they can do whatever
    -- if user has permission 'p:app-tenant-group-admin' then _app_tenant_id must be in support scope for this tenant
    if 
      auth_fn.app_user_has_permission('p:super-admin') = false and
      auth_fn.app_user_has_permission('p:app-tenant-group-admin') = true
    then
      if _app_tenant_id not in (
        select t.id
        from app.app_tenant t
        join app.app_tenant_group_member atgm on t.id = atgm.app_tenant_id
        join app.app_tenant_group atg on atg.id = atgm.app_tenant_group_id
        join app.app_tenant_group_admin atga on atga.app_tenant_group_id = atg.id
        where atga.app_user_id = auth_fn.current_app_user()->>'app_user_id'
      ) 
      then
        raise exception 'permission denied - user is not a manager of tenant group';
      end if;
    end if;
    
    _app_user_auth0_info := auth_fn.get_app_user_info('fnb-support', _app_tenant_id);
    _tenant_permissions := (select auth_fn.get_app_tenant_scope_permissions(_app_tenant_id));
    _app_user_auth0_info.permissions := array_cat(_app_user_auth0_info.permissions, _tenant_permissions);

    _app_user_auth0_info.permissions := array_append(_app_user_auth0_info.permissions, 'p:clinic-patient');
    _app_user_auth0_info.permissions := array_append(_app_user_auth0_info.permissions, 'p:home-patient');
    -- remove duplicate permissions
    with perms as (
      select unnest(_app_user_auth0_info.permissions) as p
    )
    ,d as (
      select distinct p from perms
    )
    select array_agg(p) from d
    into _app_user_auth0_info.permissions
    ;

    return _app_user_auth0_info;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'auth_fn.init_app_tenant_support:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION auth_fn.init_app_tenant_support(_app_tenant_id text) OWNER TO postgres;

--
-- Name: init_demo(text); Type: FUNCTION; Schema: auth_fn; Owner: postgres
--

CREATE FUNCTION auth_fn.init_demo(_license_pack_key text) RETURNS auth_fn.init_demo_result
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _err_context text;
    _demo_app_tenant app.app_tenant;
    _app_user_auth0_info auth_fn.app_user_auth0_info;
    _result auth_fn.init_demo_result;
    _tenant_permissions text[];
  BEGIN
    if auth_fn.app_user_has_permission('p:demo') = false then
      raise exception 'permission denied';
    end if;
    _demo_app_tenant := (select app_fn.create_demo_app_tenant(_license_pack_key));

    _app_user_auth0_info := auth_fn.get_app_user_info('fnb-demo', _demo_app_tenant.id);
    _tenant_permissions := (select auth_fn.get_app_tenant_scope_permissions(_demo_app_tenant.id));
    _app_user_auth0_info.permissions = array_cat(_app_user_auth0_info.permissions, _tenant_permissions);

    _result.demo_app_tenant = _demo_app_tenant;
    _result.app_user_auth0_info = _app_user_auth0_info;
    _result.license_pack_key = _license_pack_key;

    return _result;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'auth_fn.init_demo:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION auth_fn.init_demo(_license_pack_key text) OWNER TO postgres;

--
-- Name: init_subsidiary_admin(text); Type: FUNCTION; Schema: auth_fn; Owner: postgres
--

CREATE FUNCTION auth_fn.init_subsidiary_admin(_subsidiary_app_tenant_id text) RETURNS auth_fn.init_subsidiary_admin_result
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _err_context text;
    _subsidiary_app_tenant app.app_tenant;
    _app_user_auth0_info auth_fn.app_user_auth0_info;
    _result auth_fn.init_subsidiary_admin_result;
    _tenant_permissions text[];
  BEGIN
    if auth_fn.app_user_has_permission('p:admin-subsidiaries') = false then
      raise exception 'permission denied';
    end if;

    select *
    into _subsidiary_app_tenant
    from app.app_tenant
    where id = _subsidiary_app_tenant_id
    ;

    _app_user_auth0_info := (select auth_fn.get_app_user_info(auth_fn.current_app_user()->>'username', _subsidiary_app_tenant_id));
    _tenant_permissions := (select auth_fn.get_app_tenant_scope_permissions(_subsidiary_app_tenant_id));
    _app_user_auth0_info.permissions = array_cat(_app_user_auth0_info.permissions, _tenant_permissions);

    _app_user_auth0_info.permissions := array_append(_app_user_auth0_info.permissions, 'p:clinic-patient');
    _app_user_auth0_info.permissions := array_append(_app_user_auth0_info.permissions, 'p:home-patient');
    -- remove duplicate permissions
    with perms as (
      select unnest(_app_user_auth0_info.permissions) as p
    )
    ,d as (
      select distinct p from perms
    )
    select array_agg(p) from d
    into _app_user_auth0_info.permissions
    ;

    _result.subsidiary_app_tenant = _subsidiary_app_tenant;
    _result.app_user_auth0_info = _app_user_auth0_info;

    return _result;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'auth_fn.init_subsidiary_admin:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION auth_fn.init_subsidiary_admin(_subsidiary_app_tenant_id text) OWNER TO postgres;

--
-- Name: do_get_app_user_info(text, text); Type: FUNCTION; Schema: auth_fn_private; Owner: postgres
--

CREATE FUNCTION auth_fn_private.do_get_app_user_info(_recovery_email_or_id_or_username text, _current_app_tenant_id text) RETURNS auth_fn.app_user_auth0_info
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
  DECLARE
    _err_context text;
    _app_user_auth0_info auth_fn.app_user_auth0_info;
    _app_user app.app_user;
    _working_app_tenant_id text;
    _permission text;
    _permissions text[];
    _has_permission boolean;
  BEGIN
    select
      usr.permission_key -- permission_key
      ,usr.username -- username
      ,usr.inactive -- inactive
      ,ten.name -- app_tenant_name
      ,coalesce(_current_app_tenant_id, ten.id) -- app_tenant_id
      -- ,ten.id -- app_tenant_id
      ,case
        when ten.type = 'subsidiary' then ten.parent_app_tenant_id
        else null
      end -- parent_app_tenant_id
      ,case
        when ten.type = 'customer' then (
          with s as (
            select
              id::text
              ,name::text
            from app.app_tenant
            where parent_app_tenant_id = ten.id
          )
          select array_agg(s::auth_fn.app_tenant_auth0_info)::auth_fn.app_tenant_auth0_info[]
          from s
        )
        else '{}'::auth_fn.app_tenant_auth0_info[]
      end -- subsidiaries
      ,usr.id -- app_user_id
      ,usr.preferred_timezone -- preferred_timezone
      ,c.id as contact_id -- contact_id
      ,c.first_name -- first_name
      ,c.last_name -- last_name
      ,usr.recovery_email -- recovery_email
      ,case
        when usr.permission_key = 'SuperAdmin' then 'app_sp_adm'
        when usr.permission_key = 'Admin' then 'app_adm'
        when usr.permission_key = 'Support' then 'app_adm'
        when usr.permission_key = 'Demo' then 'app_adm'
        when usr.permission_key = 'User' then 'app_usr'
      end -- app_role
      ,(select app.app_user_permissions(usr, _current_app_tenant_id)) -- permissions
      ,(select app.app_user_home_path(usr)) -- home_path
      ,'{}'::text[] -- licensing_scope
      ,usr.ext_auth_id -- ext_auth_id
      ,usr.ext_auth_blocked -- ext_auth_blocked
    into _app_user_auth0_info
    from app.app_user usr
    join app.app_tenant ten on ten.id = usr.app_tenant_id
    join app.contact c on usr.contact_id = c.id
    where usr.recovery_email = _recovery_email_or_id_or_username or usr.id = _recovery_email_or_id_or_username or usr.username = _recovery_email_or_id_or_username
    ;
    _working_app_tenant_id := coalesce(_current_app_tenant_id, _app_user_auth0_info.app_tenant_id);

    -- licensing scope
    _app_user_auth0_info.licensing_scope := array_append(_app_user_auth0_info.licensing_scope, _working_app_tenant_id);
    if _app_user_auth0_info.permission_key in ('Support', 'Admin') then
      _app_user_auth0_info.licensing_scope := array_cat(
        _app_user_auth0_info.licensing_scope
        ,(
          select coalesce(array_agg(id),'{}'::text[]) from app.app_tenant where parent_app_tenant_id = _working_app_tenant_id and type = 'subsidiary'
        )
      );
    end if;

    return _app_user_auth0_info;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'auth_fn_private.do_get_app_user_info:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;  
  $$;


ALTER FUNCTION auth_fn_private.do_get_app_user_info(_recovery_email_or_id_or_username text, _current_app_tenant_id text) OWNER TO postgres;

--
-- Name: FUNCTION do_get_app_user_info(_recovery_email_or_id_or_username text, _current_app_tenant_id text); Type: COMMENT; Schema: auth_fn_private; Owner: postgres
--

COMMENT ON FUNCTION auth_fn_private.do_get_app_user_info(_recovery_email_or_id_or_username text, _current_app_tenant_id text) IS '@OMIT';


--
-- Name: subscription; Type: TABLE; Schema: msg; Owner: postgres
--

CREATE TABLE msg.subscription (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status msg.subscription_status DEFAULT 'active'::msg.subscription_status NOT NULL,
    topic_id text NOT NULL,
    subscriber_contact_id text NOT NULL,
    last_read timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE msg.subscription OWNER TO postgres;

--
-- Name: deactivate_subscription(text); Type: FUNCTION; Schema: msg_fn; Owner: postgres
--

CREATE FUNCTION msg_fn.deactivate_subscription(_subscription_id text) RETURNS msg.subscription
    LANGUAGE plpgsql
    AS $$
    DECLARE
      _subscription msg.subscription;
      _err_context text;
    BEGIN
      update msg.subscription set
        status = 'inactive'
      where id = _subscription_id
      returning *
      into _subscription
      ;

      return _subscription;

      exception
        when others then
          GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
          if position('FB' in SQLSTATE::text) = 0 then
            _err_context := 'msg_fn.deactivate_subscription:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
            raise exception '%', _err_context using errcode = 'FB500';
          end if;
          raise;
    end;
    $$;


ALTER FUNCTION msg_fn.deactivate_subscription(_subscription_id text) OWNER TO postgres;

--
-- Name: message; Type: TABLE; Schema: msg; Owner: postgres
--

CREATE TABLE msg.message (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status msg.message_status DEFAULT 'sent'::msg.message_status NOT NULL,
    topic_id text NOT NULL,
    content text NOT NULL,
    posted_by_contact_id text NOT NULL,
    tags text[] DEFAULT '{}'::text[] NOT NULL,
    acknowledged_at timestamp with time zone
);


ALTER TABLE msg.message OWNER TO postgres;

--
-- Name: upsert_message(msg_fn.message_info); Type: FUNCTION; Schema: msg_fn; Owner: postgres
--

CREATE FUNCTION msg_fn.upsert_message(_message_info msg_fn.message_info) RETURNS msg.message
    LANGUAGE plpgsql
    AS $$
    DECLARE
      _topic msg.topic;
      _message msg.message;
      _posted_by_contact_id text;
      _err_context text;
    BEGIN
      select contact_id into _posted_by_contact_id from app.app_user where id = auth_fn.current_app_user_id();

      select * into _topic from msg.topic where id = _message_info.topic_id;
      if _topic.id is null then
        raise exception 'no topic for id: %', _message_info.topic_id;
      end if;

      select * into _message from msg.message where id = _message_info.id;

      if _message.id is not null then
        update msg.message set
          content = _message_info.content
          ,tags = coalesce(_message_info.tags, '{}')
        where id = _message.id
        ;
      else
        insert into msg.message(
          app_tenant_id
          ,topic_id
          ,posted_by_contact_id
          ,content
          ,tags
        )
        select
          _topic.app_tenant_id
          ,_message_info.topic_id
          ,_posted_by_contact_id
          ,_message_info.content
          ,coalesce(_message_info.tags, '{}')
        returning *
        into _message
        ;
      end if;

      return _message;
      exception
        when others then
          GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
          if position('FB' in SQLSTATE::text) = 0 then
            _err_context := 'msg_fn.upsert_message:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
            raise exception '%', _err_context using errcode = 'FB500';
          end if;
          raise;
    end;
    $$;


ALTER FUNCTION msg_fn.upsert_message(_message_info msg_fn.message_info) OWNER TO postgres;

--
-- Name: upsert_subscription(msg_fn.subscription_info); Type: FUNCTION; Schema: msg_fn; Owner: postgres
--

CREATE FUNCTION msg_fn.upsert_subscription(_subscription_info msg_fn.subscription_info) RETURNS msg.subscription
    LANGUAGE plpgsql
    AS $$
    DECLARE
      _topic msg.topic;
      _subscription msg.subscription;
      _err_context text;
    BEGIN
      select *
      into _topic
      from msg.topic
      where id = _subscription_info.topic_id
      ;
      if _topic.id is null then
        raise exception 'no topic for id: %', _subscription_info.topic_id;
      end if;

      select * into _subscription
      from msg.subscription
      where topic_id = _subscription_info.topic_id
      and subscriber_contact_id = _subscription_info.subscriber_contact_id
      ;

      if _subscription.id is not null then
        update msg.subscription set
          status = 'active'
        where id = _subscription.id
        ;
      else
        insert into msg.subscription(
          app_tenant_id
          ,topic_id
          ,subscriber_contact_id
        )
        select
          _topic.app_tenant_id
          ,_topic.id
          ,_subscription_info.subscriber_contact_id
        returning *
        into _subscription
        ;
      end if;

      return _subscription;
      exception
        when others then
          GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
          if position('FB' in SQLSTATE::text) = 0 then
            _err_context := 'msg_fn.upsert_subscription:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
            raise exception '%', _err_context using errcode = 'FB500';
          end if;
          raise;
    end;
    $$;


ALTER FUNCTION msg_fn.upsert_subscription(_subscription_info msg_fn.subscription_info) OWNER TO postgres;

--
-- Name: topic; Type: TABLE; Schema: msg; Owner: postgres
--

CREATE TABLE msg.topic (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name text NOT NULL,
    identifier text
);


ALTER TABLE msg.topic OWNER TO postgres;

--
-- Name: upsert_topic(msg_fn.topic_info); Type: FUNCTION; Schema: msg_fn; Owner: postgres
--

CREATE FUNCTION msg_fn.upsert_topic(_topic_info msg_fn.topic_info) RETURNS msg.topic
    LANGUAGE plpgsql
    AS $$
    DECLARE
      _topic msg.topic;
      _topic_id text;
      _err_context text;
    BEGIN
      _topic_id = coalesce(_topic_info.id, shard_1.id_generator());
      select *
        into _topic
      from msg.topic
      where (id = _topic_id or identifier = _topic_info.identifier)
      and app_tenant_id = auth_fn.current_app_user()->>'app_tenant_id'
      ;

      if _topic.id is not null then
        update msg.topic set
          name = _topic_info.name
        where id = _topic_id
        ;
      else
        insert into msg.topic(
          id
          ,app_tenant_id
          ,name
          ,identifier
        )
        select
          _topic_id
          ,auth_fn.current_app_user()->>'app_tenant_id'
          ,_topic_info.name
          ,_topic_info.identifier
        returning *
        into _topic
        ;
      end if;

      return _topic;
      exception
        when others then
          GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
          if position('FB' in SQLSTATE::text) = 0 then
            _err_context := 'msg_fn.upsert_topic:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
            raise exception '%', _err_context using errcode = 'FB500';
          end if;
          raise;
    end;
    $$;


ALTER FUNCTION msg_fn.upsert_topic(_topic_info msg_fn.topic_info) OWNER TO postgres;

--
-- Name: notify_watchers_ddl(); Type: FUNCTION; Schema: postgraphile_watch; Owner: postgres
--

CREATE FUNCTION postgraphile_watch.notify_watchers_ddl() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
begin
  perform pg_notify(
    'postgraphile_watch',
    json_build_object(
      'type',
      'ddl',
      'payload',
      (select json_agg(json_build_object('schema', schema_name, 'command', command_tag)) from pg_event_trigger_ddl_commands() as x)
    )::text
  );
end;
$$;


ALTER FUNCTION postgraphile_watch.notify_watchers_ddl() OWNER TO postgres;

--
-- Name: notify_watchers_drop(); Type: FUNCTION; Schema: postgraphile_watch; Owner: postgres
--

CREATE FUNCTION postgraphile_watch.notify_watchers_drop() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
begin
  perform pg_notify(
    'postgraphile_watch',
    json_build_object(
      'type',
      'drop',
      'payload',
      (select json_agg(distinct x.schema_name) from pg_event_trigger_dropped_objects() as x)
    )::text
  );
end;
$$;


ALTER FUNCTION postgraphile_watch.notify_watchers_drop() OWNER TO postgres;

--
-- Name: app_exception; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.app_exception (
    err_code text NOT NULL,
    description text,
    svr_message_mask text,
    ui_message_mask text,
    CONSTRAINT app_exception_err_code_check CHECK ((err_code <> ''::text))
);


ALTER TABLE app.app_exception OWNER TO postgres;

--
-- Name: app_tenant_group_admin; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.app_tenant_group_admin (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_group_id text NOT NULL,
    app_user_id text NOT NULL
);


ALTER TABLE app.app_tenant_group_admin OWNER TO postgres;

--
-- Name: facility; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.facility (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    organization_id text,
    location_id text,
    name text,
    external_id text
);


ALTER TABLE app.facility OWNER TO postgres;

--
-- Name: license_permission; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.license_permission (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    license_id text NOT NULL,
    permission_key text NOT NULL
);


ALTER TABLE app.license_permission OWNER TO postgres;

--
-- Name: location; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.location (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    external_id text,
    name text,
    address1 text,
    address2 text,
    city text,
    state text,
    zip text,
    lat text,
    lon text
);


ALTER TABLE app.location OWNER TO postgres;

--
-- Name: module; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.module (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    application_key text NOT NULL,
    name text NOT NULL,
    route_name text NOT NULL,
    permission_key text NOT NULL
);


ALTER TABLE app.module OWNER TO postgres;

--
-- Name: note; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.note (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by_app_user_id text NOT NULL,
    content text NOT NULL
);


ALTER TABLE app.note OWNER TO postgres;

--
-- Name: organization; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.organization (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    external_id text,
    name text NOT NULL,
    location_id text,
    primary_contact_id text,
    CONSTRAINT organization_name_check CHECK ((name <> ''::text))
);


ALTER TABLE app.organization OWNER TO postgres;

--
-- Name: registration; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.registration (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    created_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP)::date NOT NULL,
    expires_at timestamp with time zone DEFAULT ((CURRENT_TIMESTAMP)::date + '24:00:00'::interval) NOT NULL,
    registered_at timestamp with time zone,
    canceled_at timestamp with time zone,
    company_name text NOT NULL,
    email text NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    phone text NOT NULL,
    registration_info jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE app.registration OWNER TO postgres;

--
-- Name: sub_module; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.sub_module (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    module_id text NOT NULL,
    name text NOT NULL,
    route_name text NOT NULL,
    permission_key text NOT NULL
);


ALTER TABLE app.sub_module OWNER TO postgres;

--
-- Name: email_request; Type: TABLE; Schema: msg; Owner: postgres
--

CREATE TABLE msg.email_request (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    sent_by_app_user_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status msg.email_status DEFAULT 'sent'::msg.email_status NOT NULL,
    subject text,
    content text,
    from_address text,
    to_addresses text,
    cc_addresses text,
    bcc_addresses text,
    options text,
    ext_mail_service_result jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE msg.email_request OWNER TO postgres;

--
-- Name: global_id_sequence; Type: SEQUENCE; Schema: shard_1; Owner: postgres
--

CREATE SEQUENCE shard_1.global_id_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE shard_1.global_id_sequence OWNER TO postgres;

--
-- Data for Name: app_exception; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.app_exception (err_code, description, svr_message_mask, ui_message_mask) FROM stdin;
\.


--
-- Data for Name: app_route; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.app_route (id, name, application_key, permission_key, description, path, menu_behavior, menu_parent_name, menu_ordinal) FROM stdin;
\.


--
-- Data for Name: app_tenant; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.app_tenant (id, created_at, name, identifier, organization_id, registration_identifier, registration_complete, settings, type, parent_app_tenant_id, anchor_subscription_id, billing_topic_id) FROM stdin;
2978135433587721825	2022-11-23 22:10:30.932856+00	Anchor Tenant	anchor	2978135433612887651	2978135433587721826	f	{}	anchor	\N	2978135433696773732	\N
2978135444492912241	2022-11-23 22:10:32.171285+00	Drainage Tenant	dng	2978135444509689459	2978135444492912242	f	{}	customer	2978135433587721825	2978135444568409716	\N
2978135452478867072	2022-11-23 22:10:33.18673+00	Address Book Tenant	address-book	2978135452478867074	2978135452478867073	f	{}	customer	2978135433587721825	2978135452478867075	\N
\.


--
-- Data for Name: app_tenant_group; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.app_tenant_group (id, name, support_email) FROM stdin;
\.


--
-- Data for Name: app_tenant_group_admin; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.app_tenant_group_admin (id, app_tenant_group_id, app_user_id) FROM stdin;
\.


--
-- Data for Name: app_tenant_group_member; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.app_tenant_group_member (id, app_tenant_group_id, app_tenant_id) FROM stdin;
\.


--
-- Data for Name: app_tenant_subscription; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.app_tenant_subscription (id, created_date, expiration_date, renewal_behavior, is_anchor_subscription, inactive, app_tenant_id, license_pack_id, payment_processor_info, parent_app_tenant_subscription_id) FROM stdin;
2978135433696773732	2022-11-23	\N	ask_admin	t	f	2978135433587721825	2978135432421705302	{}	\N
2978135444568409716	2022-11-23	\N	ask_admin	t	f	2978135444492912241	2978135433076016734	{}	\N
2978135452478867075	2022-11-23	\N	ask_admin	t	f	2978135452478867072	2978135432899855963	{}	\N
\.


--
-- Data for Name: app_user; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.app_user (id, app_tenant_id, ext_auth_id, ext_crm_id, contact_id, created_at, username, recovery_email, inactive, password_reset_required, permission_key, is_support, preferred_timezone, settings, ext_auth_blocked, language_id) FROM stdin;
2978135433931654758	2978135433587721825	\N	\N	2978135433906488933	2022-11-23 22:10:30.932856+00	appsuperadmin	app-super-admin@function-bucket.com	f	f	SuperAdmin	f	PST8PDT	{}	f	en
2978135434283976298	2978135433587721825	\N	\N	2978135434283976297	2022-11-23 22:10:30.932856+00	fnb-support	help@function-bucket.com	f	f	Support	f	PST8PDT	{}	f	en
2978135434309142126	2978135433587721825	\N	\N	2978135434309142125	2022-11-23 22:10:30.932856+00	fnb-demo	demo@function-bucket.com	f	f	Demo	f	PST8PDT	{}	f	en
2978135448360060534	2978135444492912241	\N	\N	2978135448343283317	2022-11-23 22:10:32.636648+00	dng-admin	dng-admin@example.com	f	f	User	f	PST8PDT	{}	f	en
2978135452252374652	2978135444492912241	\N	\N	2978135452235597435	2022-11-23 22:10:33.105986+00	dng-user	dng-user@example.com	f	f	User	f	PST8PDT	{}	f	en
2978135456153077381	2978135452478867072	\N	\N	2978135456136300164	2022-11-23 22:10:33.571273+00	address-book-admin	address-book-admin@example.com	f	f	User	f	PST8PDT	{}	f	en
2978135459726624395	2978135452478867072	\N	\N	2978135459709847178	2022-11-23 22:10:34.001235+00	address-book-user	address-book-user@example.com	f	f	User	f	PST8PDT	{}	f	en
\.


--
-- Data for Name: application; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.application (key, name, setting_configs) FROM stdin;
anchor	Anchor	\N
address-book	Address Book	\N
dng	Drainage	\N
\.


--
-- Data for Name: contact; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.contact (id, app_tenant_id, created_at, status, type, organization_id, location_id, external_id, first_name, last_name, email, cell_phone, office_phone, title, nickname) FROM stdin;
2978135433906488933	2978135433587721825	2022-11-23 22:10:30.932856+00	active	individual	\N	\N	kevin	Kevin	Burkett	app-super-admin@function-bucket.com	\N	\N	\N	\N
2978135434283976297	2978135433587721825	2022-11-23 22:10:30.932856+00	active	individual	\N	\N	fnb-support	FNB	Support	help@function-bucket.com	\N	\N	\N	\N
2978135434309142125	2978135433587721825	2022-11-23 22:10:30.932856+00	active	individual	\N	\N	fnb-demo	FNB	Demo	demo@function-bucket.com	\N	\N	\N	\N
2978135448343283317	2978135444492912241	2022-11-23 22:10:32.636648+00	active	individual	\N	\N	\N	Drainage	Admin	dng-admin@example.com	\N	\N	\N	\N
2978135452235597435	2978135444492912241	2022-11-23 22:10:33.105986+00	active	individual	\N	\N	\N	Drainage	User	dng-user@example.com	\N	\N	\N	\N
2978135456136300164	2978135452478867072	2022-11-23 22:10:33.571273+00	active	individual	\N	\N	\N	Drainage	Admin	address-book-admin@example.com	\N	\N	\N	\N
2978135459709847178	2978135452478867072	2022-11-23 22:10:34.001235+00	active	individual	\N	\N	\N	Drainage	User	address-book-user@example.com	\N	\N	\N	\N
\.


--
-- Data for Name: error_report; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.error_report (id, first_reported_at, last_reported_at, observed_count, message, comment, reported_by_app_user_id, reported_as_app_user_id, operation_name, variables, status) FROM stdin;
\.


--
-- Data for Name: eula; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.eula (id, created_at, updated_at, is_inactive, deactivated_at, content) FROM stdin;
\.


--
-- Data for Name: facility; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.facility (id, app_tenant_id, created_at, organization_id, location_id, name, external_id) FROM stdin;
\.


--
-- Data for Name: license; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.license (id, app_tenant_id, subscription_id, created_at, external_id, name, license_type_key, assigned_to_app_user_id, inactive, expiration_date, status, status_reason, comment) FROM stdin;
2978135433981986407	2978135433587721825	2978135433696773732	2022-11-23 22:10:30.932856+00	\N	Anchor Super Admin	anchor-super-admin	2978135433931654758	f	\N	active	initial	\N
2978135434283976299	2978135433587721825	2978135433696773732	2022-11-23 22:10:30.932856+00	\N	Anchor Support	anchor-support	2978135434283976298	f	\N	active	initial	\N
2978135434309142127	2978135433587721825	2978135433696773732	2022-11-23 22:10:30.932856+00	\N	Anchor Demo	anchor-demo	2978135434309142126	f	\N	active	initial	\N
2978135448393614967	2978135444492912241	2978135444568409716	2022-11-23 22:10:32.636648+00	\N	Address Book Admin	dng-admin	2978135448360060534	f	\N	active	initial	\N
2978135452285929085	2978135444492912241	2978135444568409716	2022-11-23 22:10:33.105986+00	\N	Address Book User	dng-user	2978135452252374652	f	2023-11-23	active	initial	\N
2978135456178243206	2978135452478867072	2978135452478867075	2022-11-23 22:10:33.571273+00	\N	Address Book Admin	address-book-admin	2978135456153077381	f	\N	active	initial	\N
2978135459760178828	2978135452478867072	2978135452478867075	2022-11-23 22:10:34.001235+00	\N	Address Book User	address-book-user	2978135459726624395	f	2023-11-23	active	initial	\N
\.


--
-- Data for Name: license_pack; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.license_pack (id, key, name, availability, created_at, published_at, discontinued_at, type, renewal_frequency, expiration_interval, expiration_interval_multiplier, explicit_expiration_date, price, upgrade_config, available_add_on_keys, coupon_code, is_public_offering, application_settings, implicit_add_on_keys) FROM stdin;
2978135432421705302	anchor	Anchor	published	2022-11-23 22:10:30.770432+00	2022-11-23 22:10:30.845967+00	\N	anchor	never	none	1	\N	0.00	({})	{}	\N	f	{}	{}
2978135432899855963	address-book	Address Book	published	2022-11-23 22:10:30.857597+00	2022-11-23 22:10:30.869922+00	\N	anchor	never	none	1	\N	0.00	({})	{}	\N	f	{}	{}
2978135433076016734	dng	Drainage	published	2022-11-23 22:10:30.87881+00	2022-11-23 22:10:30.891708+00	\N	anchor	never	none	1	\N	0.00	({})	{}	\N	f	{}	{}
\.


--
-- Data for Name: license_pack_license_type; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.license_pack_license_type (id, license_type_key, license_pack_id, license_count, assign_upon_subscription, unlimited_provision, expiration_interval, expiration_interval_multiplier, explicit_expiration_date) FROM stdin;
2978135432488814167	anchor-super-admin	2978135432421705302	0	f	t	none	1	\N
2978135432597866072	anchor-user	2978135432421705302	0	f	t	none	1	\N
2978135432597866073	anchor-support	2978135432421705302	0	f	t	none	1	\N
2978135432597866074	anchor-demo	2978135432421705302	0	f	t	none	1	\N
2978135432899855964	address-book-admin	2978135432899855963	0	t	t	none	1	\N
2978135432908244573	address-book-user	2978135432899855963	0	f	t	year	1	\N
2978135433076016735	dng-admin	2978135433076016734	0	t	t	none	1	\N
2978135433076016736	dng-user	2978135433076016734	0	f	t	year	1	\N
\.


--
-- Data for Name: license_permission; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.license_permission (id, app_tenant_id, created_at, license_id, permission_key) FROM stdin;
2978135434099426920	2978135433587721825	2022-11-23 22:10:30.932856+00	2978135433981986407	p:super-admin
2978135434292364908	2978135433587721825	2022-11-23 22:10:30.932856+00	2978135434283976299	p:support
2978135434317530736	2978135433587721825	2022-11-23 22:10:30.932856+00	2978135434309142127	p:demo
2978135448410392184	2978135444492912241	2022-11-23 22:10:32.636648+00	2978135448393614967	p:dng-admin
2978135448418780793	2978135444492912241	2022-11-23 22:10:32.636648+00	2978135448393614967	m:dng-admin
2978135448418780794	2978135444492912241	2022-11-23 22:10:32.636648+00	2978135448393614967	m:dng
2978135452302706302	2978135444492912241	2022-11-23 22:10:33.105986+00	2978135452285929085	p:dng-user
2978135452302706303	2978135444492912241	2022-11-23 22:10:33.105986+00	2978135452285929085	m:dng
2978135456195020423	2978135452478867072	2022-11-23 22:10:33.571273+00	2978135456178243206	p:address-book-admin
2978135456195020424	2978135452478867072	2022-11-23 22:10:33.571273+00	2978135456178243206	m:address-book-admin
2978135456195020425	2978135452478867072	2022-11-23 22:10:33.571273+00	2978135456178243206	m:address-book
2978135459776956045	2978135452478867072	2022-11-23 22:10:34.001235+00	2978135459760178828	p:address-book-user
2978135459776956046	2978135452478867072	2022-11-23 22:10:34.001235+00	2978135459760178828	m:address-book
\.


--
-- Data for Name: license_type; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.license_type (key, created_at, external_id, name, application_key, permission_key, sync_user_on_assignment) FROM stdin;
anchor-super-admin	2022-11-23 22:10:29.507317+00	\N	Anchor Super Admin	anchor	SuperAdmin	t
anchor-user	2022-11-23 22:10:29.507317+00	\N	Anchor User	anchor	User	t
anchor-support	2022-11-23 22:10:29.507317+00	\N	Anchor Support	anchor	User	t
anchor-demo	2022-11-23 22:10:29.507317+00	\N	Anchor Demo	anchor	User	t
address-book-admin	2022-11-23 22:10:29.584666+00	\N	Address Book Admin	address-book	User	t
address-book-user	2022-11-23 22:10:29.584666+00	\N	Address Book User	address-book	User	t
dng-admin	2022-11-23 22:10:29.593846+00	\N	Address Book Admin	dng	User	t
dng-user	2022-11-23 22:10:29.593846+00	\N	Address Book User	dng	User	t
\.


--
-- Data for Name: license_type_permission; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.license_type_permission (id, created_at, license_type_key, permission_key) FROM stdin;
2978135422044997192	2022-11-23 22:10:29.507317+00	anchor-super-admin	p:super-admin
2978135422103717449	2022-11-23 22:10:29.507317+00	anchor-user	p:anchor-user
2978135422112106058	2022-11-23 22:10:29.507317+00	anchor-support	p:support
2978135422112106059	2022-11-23 22:10:29.507317+00	anchor-demo	p:demo
2978135422212769356	2022-11-23 22:10:29.584666+00	address-book-admin	p:address-book-admin
2978135422212769357	2022-11-23 22:10:29.584666+00	address-book-admin	m:address-book-admin
2978135422212769358	2022-11-23 22:10:29.584666+00	address-book-admin	m:address-book
2978135422212769359	2022-11-23 22:10:29.584666+00	address-book-user	p:address-book-user
2978135422212769360	2022-11-23 22:10:29.584666+00	address-book-user	m:address-book
2978135422288266833	2022-11-23 22:10:29.593846+00	dng-admin	p:dng-admin
2978135422288266834	2022-11-23 22:10:29.593846+00	dng-admin	m:dng-admin
2978135422288266835	2022-11-23 22:10:29.593846+00	dng-admin	m:dng
2978135422288266836	2022-11-23 22:10:29.593846+00	dng-user	p:dng-user
2978135422288266837	2022-11-23 22:10:29.593846+00	dng-user	m:dng
\.


--
-- Data for Name: location; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.location (id, app_tenant_id, created_at, external_id, name, address1, address2, city, state, zip, lat, lon) FROM stdin;
\.


--
-- Data for Name: module; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.module (id, application_key, name, route_name, permission_key) FROM stdin;
\.


--
-- Data for Name: note; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.note (id, app_tenant_id, created_at, updated_at, created_by_app_user_id, content) FROM stdin;
\.


--
-- Data for Name: organization; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.organization (id, app_tenant_id, created_at, external_id, name, location_id, primary_contact_id) FROM stdin;
2978135433612887651	2978135433587721825	2022-11-23 22:10:30.932856+00	anchor	Anchor Tenant	\N	\N
2978135444509689459	2978135444492912241	2022-11-23 22:10:32.171285+00	dng	Drainage Tenant	\N	\N
2978135452478867074	2978135452478867072	2022-11-23 22:10:33.18673+00	address-book	Address Book Tenant	\N	\N
\.


--
-- Data for Name: permission; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.permission (key) FROM stdin;
p:super-admin
p:anchor-user
p:support
p:demo
p:address-book-admin
m:address-book-admin
p:address-book-user
m:address-book
p:dng-admin
m:dng-admin
p:dng-user
m:dng
\.


--
-- Data for Name: registration; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.registration (id, created_at, expires_at, registered_at, canceled_at, company_name, email, first_name, last_name, phone, registration_info) FROM stdin;
\.


--
-- Data for Name: signed_eula; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.signed_eula (id, eula_id, app_tenant_id, signed_by_app_user_id, signed_at, content) FROM stdin;
\.


--
-- Data for Name: sub_module; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.sub_module (id, module_id, name, route_name, permission_key) FROM stdin;
\.


--
-- Data for Name: supported_language; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.supported_language (id, name, inactive) FROM stdin;
en	English	f
\.


--
-- Data for Name: email_request; Type: TABLE DATA; Schema: msg; Owner: postgres
--

COPY msg.email_request (id, app_tenant_id, sent_by_app_user_id, created_at, status, subject, content, from_address, to_addresses, cc_addresses, bcc_addresses, options, ext_mail_service_result) FROM stdin;
\.


--
-- Data for Name: message; Type: TABLE DATA; Schema: msg; Owner: postgres
--

COPY msg.message (id, app_tenant_id, created_at, status, topic_id, content, posted_by_contact_id, tags, acknowledged_at) FROM stdin;
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: msg; Owner: postgres
--

COPY msg.subscription (id, app_tenant_id, created_at, status, topic_id, subscriber_contact_id, last_read) FROM stdin;
\.


--
-- Data for Name: topic; Type: TABLE DATA; Schema: msg; Owner: postgres
--

COPY msg.topic (id, app_tenant_id, created_at, name, identifier) FROM stdin;
\.


--
-- Name: global_id_sequence; Type: SEQUENCE SET; Schema: shard_1; Owner: postgres
--

SELECT pg_catalog.setval('shard_1.global_id_sequence', 2748, true);


--
-- Name: app_route app_route_name_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_route
    ADD CONSTRAINT app_route_name_key UNIQUE (name);


--
-- Name: app_tenant app_tenant_identifier_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_tenant
    ADD CONSTRAINT app_tenant_identifier_key UNIQUE (identifier);


--
-- Name: app_user app_user_username_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_user
    ADD CONSTRAINT app_user_username_key UNIQUE (username);


--
-- Name: app_exception pk_app_exception; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_exception
    ADD CONSTRAINT pk_app_exception PRIMARY KEY (err_code);


--
-- Name: app_route pk_app_route; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_route
    ADD CONSTRAINT pk_app_route PRIMARY KEY (id);


--
-- Name: app_tenant pk_app_tenant; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_tenant
    ADD CONSTRAINT pk_app_tenant PRIMARY KEY (id);


--
-- Name: app_tenant_group pk_app_tenant_group; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_tenant_group
    ADD CONSTRAINT pk_app_tenant_group PRIMARY KEY (id);


--
-- Name: app_tenant_group_admin pk_app_tenant_group_admin; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_tenant_group_admin
    ADD CONSTRAINT pk_app_tenant_group_admin PRIMARY KEY (id);


--
-- Name: app_tenant_group_member pk_app_tenant_group_member; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_tenant_group_member
    ADD CONSTRAINT pk_app_tenant_group_member PRIMARY KEY (id);


--
-- Name: app_tenant_subscription pk_app_tenant_subscription; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_tenant_subscription
    ADD CONSTRAINT pk_app_tenant_subscription PRIMARY KEY (id);


--
-- Name: app_user pk_app_user; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_user
    ADD CONSTRAINT pk_app_user PRIMARY KEY (id);


--
-- Name: application pk_application; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.application
    ADD CONSTRAINT pk_application PRIMARY KEY (key);


--
-- Name: contact pk_contact; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.contact
    ADD CONSTRAINT pk_contact PRIMARY KEY (id);


--
-- Name: error_report pk_error_report; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.error_report
    ADD CONSTRAINT pk_error_report PRIMARY KEY (id);


--
-- Name: eula pk_eula; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.eula
    ADD CONSTRAINT pk_eula PRIMARY KEY (id);


--
-- Name: facility pk_facility; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.facility
    ADD CONSTRAINT pk_facility PRIMARY KEY (id);


--
-- Name: license pk_license; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license
    ADD CONSTRAINT pk_license PRIMARY KEY (id);


--
-- Name: license_pack pk_license_pack; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_pack
    ADD CONSTRAINT pk_license_pack PRIMARY KEY (id);


--
-- Name: license_pack_license_type pk_license_pack_license_type; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_pack_license_type
    ADD CONSTRAINT pk_license_pack_license_type PRIMARY KEY (id);


--
-- Name: license_permission pk_license_permission; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_permission
    ADD CONSTRAINT pk_license_permission PRIMARY KEY (id);


--
-- Name: license_type pk_license_type; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_type
    ADD CONSTRAINT pk_license_type PRIMARY KEY (key);


--
-- Name: license_type_permission pk_license_type_permission; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_type_permission
    ADD CONSTRAINT pk_license_type_permission PRIMARY KEY (id);


--
-- Name: location pk_location; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.location
    ADD CONSTRAINT pk_location PRIMARY KEY (id);


--
-- Name: module pk_module; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.module
    ADD CONSTRAINT pk_module PRIMARY KEY (id);


--
-- Name: note pk_note; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.note
    ADD CONSTRAINT pk_note PRIMARY KEY (id);


--
-- Name: organization pk_organization; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.organization
    ADD CONSTRAINT pk_organization PRIMARY KEY (id);


--
-- Name: permission pk_permission; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.permission
    ADD CONSTRAINT pk_permission PRIMARY KEY (key);


--
-- Name: registration pk_registration; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.registration
    ADD CONSTRAINT pk_registration PRIMARY KEY (id);


--
-- Name: signed_eula pk_signed_eula; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.signed_eula
    ADD CONSTRAINT pk_signed_eula PRIMARY KEY (id);


--
-- Name: sub_module pk_sub_module; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.sub_module
    ADD CONSTRAINT pk_sub_module PRIMARY KEY (id);


--
-- Name: supported_language pk_supported_language; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.supported_language
    ADD CONSTRAINT pk_supported_language PRIMARY KEY (id);


--
-- Name: signed_eula signed_eula_signed_by_app_user_id_eula_id_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.signed_eula
    ADD CONSTRAINT signed_eula_signed_by_app_user_id_eula_id_key UNIQUE (signed_by_app_user_id, eula_id);


--
-- Name: app_route uq_app_route; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_route
    ADD CONSTRAINT uq_app_route UNIQUE (application_key, name);


--
-- Name: app_tenant_group uq_app_tenant_group; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_tenant_group
    ADD CONSTRAINT uq_app_tenant_group UNIQUE (name);


--
-- Name: app_tenant_group_admin uq_app_tenant_group_admin; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_tenant_group_admin
    ADD CONSTRAINT uq_app_tenant_group_admin UNIQUE (app_tenant_group_id, app_user_id);


--
-- Name: app_tenant_group_member uq_app_tenant_group_member; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_tenant_group_member
    ADD CONSTRAINT uq_app_tenant_group_member UNIQUE (app_tenant_group_id, app_tenant_id);


--
-- Name: organization uq_app_tenant_name; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.organization
    ADD CONSTRAINT uq_app_tenant_name UNIQUE (app_tenant_id, name);


--
-- Name: app_tenant uq_app_tenant_organization; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_tenant
    ADD CONSTRAINT uq_app_tenant_organization UNIQUE (organization_id);


--
-- Name: app_user uq_app_user_contact; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_user
    ADD CONSTRAINT uq_app_user_contact UNIQUE (contact_id);


--
-- Name: app_user uq_app_user_tenant_recovery_email; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_user
    ADD CONSTRAINT uq_app_user_tenant_recovery_email UNIQUE (app_tenant_id, recovery_email);


--
-- Name: contact uq_contact_app_tenant_and_email; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.contact
    ADD CONSTRAINT uq_contact_app_tenant_and_email UNIQUE (app_tenant_id, email);


--
-- Name: contact uq_contact_app_tenant_and_external_id; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.contact
    ADD CONSTRAINT uq_contact_app_tenant_and_external_id UNIQUE (app_tenant_id, external_id);


--
-- Name: facility uq_facility_app_tenant_and_organization_and_name; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.facility
    ADD CONSTRAINT uq_facility_app_tenant_and_organization_and_name UNIQUE (organization_id, name);


--
-- Name: license_pack_license_type uq_license_pack_license_type; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_pack_license_type
    ADD CONSTRAINT uq_license_pack_license_type UNIQUE (license_pack_id, license_type_key);


--
-- Name: license_permission uq_license_permission; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_permission
    ADD CONSTRAINT uq_license_permission UNIQUE (license_id, permission_key);


--
-- Name: license_type uq_license_type; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_type
    ADD CONSTRAINT uq_license_type UNIQUE (application_key, key);


--
-- Name: license_type_permission uq_license_type_permission; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_type_permission
    ADD CONSTRAINT uq_license_type_permission UNIQUE (license_type_key, permission_key);


--
-- Name: location uq_location_app_tenant_and_external_id; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.location
    ADD CONSTRAINT uq_location_app_tenant_and_external_id UNIQUE (app_tenant_id, external_id);


--
-- Name: registration uq_registration; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.registration
    ADD CONSTRAINT uq_registration UNIQUE (company_name);


--
-- Name: email_request pk_email_request; Type: CONSTRAINT; Schema: msg; Owner: postgres
--

ALTER TABLE ONLY msg.email_request
    ADD CONSTRAINT pk_email_request PRIMARY KEY (id);


--
-- Name: message pk_message; Type: CONSTRAINT; Schema: msg; Owner: postgres
--

ALTER TABLE ONLY msg.message
    ADD CONSTRAINT pk_message PRIMARY KEY (id);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: msg; Owner: postgres
--

ALTER TABLE ONLY msg.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: topic pk_topic; Type: CONSTRAINT; Schema: msg; Owner: postgres
--

ALTER TABLE ONLY msg.topic
    ADD CONSTRAINT pk_topic PRIMARY KEY (id);


--
-- Name: subscription uq_subscription; Type: CONSTRAINT; Schema: msg; Owner: postgres
--

ALTER TABLE ONLY msg.subscription
    ADD CONSTRAINT uq_subscription UNIQUE (topic_id, subscriber_contact_id);


--
-- Name: idx_app_app_tenant_subscription_parent_app_tenant_subscription_; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_app_app_tenant_subscription_parent_app_tenant_subscription_ ON app.app_tenant_subscription USING btree (parent_app_tenant_subscription_id);


--
-- Name: idx_app_error_report_reported_as_app_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_app_error_report_reported_as_app_user_id ON app.error_report USING btree (reported_as_app_user_id);


--
-- Name: idx_app_error_report_reported_by_app_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_app_error_report_reported_by_app_user_id ON app.error_report USING btree (reported_by_app_user_id);


--
-- Name: idx_app_license_assigned_to_active; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX idx_app_license_assigned_to_active ON app.license USING btree (assigned_to_app_user_id, license_type_key, inactive) WHERE (inactive = false);


--
-- Name: idx_app_license_pack_draft_key; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX idx_app_license_pack_draft_key ON app.license_pack USING btree (key, availability) WHERE (availability = 'draft'::app.license_pack_availability);


--
-- Name: idx_app_license_pack_published_key; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX idx_app_license_pack_published_key ON app.license_pack USING btree (key, availability) WHERE (availability = 'published'::app.license_pack_availability);


--
-- Name: idx_app_route_application_key; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_app_route_application_key ON app.app_route USING btree (application_key);


--
-- Name: idx_app_route_menu_parent; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_app_route_menu_parent ON app.app_route USING btree (menu_parent_name);


--
-- Name: idx_app_signed_eula_app_tenant_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_app_signed_eula_app_tenant_id ON app.signed_eula USING btree (app_tenant_id);


--
-- Name: idx_app_signed_eula_eula_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_app_signed_eula_eula_id ON app.signed_eula USING btree (eula_id);


--
-- Name: idx_app_tenant_anchor_subscription; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_app_tenant_anchor_subscription ON app.app_tenant USING btree (anchor_subscription_id);


--
-- Name: idx_app_tenant_billing_topic; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_app_tenant_billing_topic ON app.app_tenant USING btree (billing_topic_id);


--
-- Name: idx_app_tenant_parent; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_app_tenant_parent ON app.app_tenant USING btree (parent_app_tenant_id);


--
-- Name: idx_app_tenant_subscription_anchor; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX idx_app_tenant_subscription_anchor ON app.app_tenant_subscription USING btree (app_tenant_id, is_anchor_subscription, inactive) WHERE ((is_anchor_subscription = true) AND (inactive = false));


--
-- Name: idx_app_tenant_subscription_subcription; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_app_tenant_subscription_subcription ON app.app_tenant_subscription USING btree (license_pack_id);


--
-- Name: idx_app_tenant_subscription_tenant; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_app_tenant_subscription_tenant ON app.app_tenant_subscription USING btree (app_tenant_id);


--
-- Name: idx_app_user_app_tenant; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_app_user_app_tenant ON app.app_user USING btree (app_tenant_id);


--
-- Name: idx_contact_app_tenant; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_contact_app_tenant ON app.contact USING btree (app_tenant_id);


--
-- Name: idx_contact_location; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_contact_location ON app.contact USING btree (location_id);


--
-- Name: idx_contact_organization; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_contact_organization ON app.contact USING btree (organization_id);


--
-- Name: idx_facility_app_tenant; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_facility_app_tenant ON app.facility USING btree (app_tenant_id);


--
-- Name: idx_facility_location; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_facility_location ON app.facility USING btree (location_id);


--
-- Name: idx_facility_organization; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_facility_organization ON app.facility USING btree (organization_id);


--
-- Name: idx_license_app_tenant; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_license_app_tenant ON app.license USING btree (app_tenant_id);


--
-- Name: idx_license_app_user; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_license_app_user ON app.license USING btree (assigned_to_app_user_id);


--
-- Name: idx_license_license_type; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_license_license_type ON app.license USING btree (license_type_key);


--
-- Name: idx_license_permission_app_tenant; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_license_permission_app_tenant ON app.license_permission USING btree (app_tenant_id);


--
-- Name: idx_license_permission_permission_key; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_license_permission_permission_key ON app.license_permission USING btree (permission_key);


--
-- Name: idx_license_subscription; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_license_subscription ON app.license USING btree (subscription_id);


--
-- Name: idx_license_type_permission_permission_key; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_license_type_permission_permission_key ON app.license_type_permission USING btree (permission_key);


--
-- Name: idx_location_app_tenant; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_location_app_tenant ON app.location USING btree (app_tenant_id);


--
-- Name: idx_lpl_license_pack; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_lpl_license_pack ON app.license_pack_license_type USING btree (license_pack_id);


--
-- Name: idx_lpl_license_type; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_lpl_license_type ON app.license_pack_license_type USING btree (license_type_key);


--
-- Name: idx_note_app_tenant_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_note_app_tenant_id ON app.note USING btree (app_tenant_id);


--
-- Name: idx_note_created_by_app_user_id; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_note_created_by_app_user_id ON app.note USING btree (created_by_app_user_id);


--
-- Name: idx_organization_app_tenant; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_organization_app_tenant ON app.organization USING btree (app_tenant_id);


--
-- Name: idx_organization_location; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_organization_location ON app.organization USING btree (location_id);


--
-- Name: idx_organization_primary_contact; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_organization_primary_contact ON app.organization USING btree (primary_contact_id);


--
-- Name: idx_uq_eula_active; Type: INDEX; Schema: app; Owner: postgres
--

CREATE UNIQUE INDEX idx_uq_eula_active ON app.eula USING btree (id) WHERE (is_inactive = false);


--
-- Name: idx_message_app_tenant_id; Type: INDEX; Schema: msg; Owner: postgres
--

CREATE INDEX idx_message_app_tenant_id ON msg.message USING btree (app_tenant_id);


--
-- Name: idx_message_posted_by_contact_id; Type: INDEX; Schema: msg; Owner: postgres
--

CREATE INDEX idx_message_posted_by_contact_id ON msg.message USING btree (posted_by_contact_id);


--
-- Name: idx_msg_email_request_app_tenant_id; Type: INDEX; Schema: msg; Owner: postgres
--

CREATE INDEX idx_msg_email_request_app_tenant_id ON msg.email_request USING btree (app_tenant_id);


--
-- Name: idx_msg_email_request_sent_by_app_user_id; Type: INDEX; Schema: msg; Owner: postgres
--

CREATE INDEX idx_msg_email_request_sent_by_app_user_id ON msg.email_request USING btree (sent_by_app_user_id);


--
-- Name: idx_msg_message_topic; Type: INDEX; Schema: msg; Owner: postgres
--

CREATE INDEX idx_msg_message_topic ON msg.message USING btree (topic_id);


--
-- Name: idx_subscription_app_tenant_id; Type: INDEX; Schema: msg; Owner: postgres
--

CREATE INDEX idx_subscription_app_tenant_id ON msg.subscription USING btree (app_tenant_id);


--
-- Name: idx_subscription_subscriber_contact_id; Type: INDEX; Schema: msg; Owner: postgres
--

CREATE INDEX idx_subscription_subscriber_contact_id ON msg.subscription USING btree (subscriber_contact_id);


--
-- Name: idx_topic_app_tenant; Type: INDEX; Schema: msg; Owner: postgres
--

CREATE INDEX idx_topic_app_tenant ON msg.topic USING btree (app_tenant_id);


--
-- Name: idx_topic_app_tenant_identifier; Type: INDEX; Schema: msg; Owner: postgres
--

CREATE UNIQUE INDEX idx_topic_app_tenant_identifier ON msg.topic USING btree (app_tenant_id, identifier);


--
-- Name: application application_no_delete; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER application_no_delete BEFORE DELETE ON app.application FOR EACH ROW EXECUTE FUNCTION app.application_no_delete();


--
-- Name: eula tg_before_update_eula; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER tg_before_update_eula BEFORE UPDATE ON app.eula FOR EACH ROW EXECUTE FUNCTION app.fn_update_eula_trigger();


--
-- Name: license tg_calculate_license_status; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER tg_calculate_license_status BEFORE INSERT OR UPDATE ON app.license FOR EACH ROW EXECUTE FUNCTION app.fn_ensure_license_status();


--
-- Name: app_route fk_app_route_application; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_route
    ADD CONSTRAINT fk_app_route_application FOREIGN KEY (application_key) REFERENCES app.application(key);


--
-- Name: app_route fk_app_route_menu_parent; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_route
    ADD CONSTRAINT fk_app_route_menu_parent FOREIGN KEY (menu_parent_name) REFERENCES app.app_route(name);


--
-- Name: app_tenant fk_app_tenant_anchor_subscription; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_tenant
    ADD CONSTRAINT fk_app_tenant_anchor_subscription FOREIGN KEY (anchor_subscription_id) REFERENCES app.app_tenant_subscription(id);


--
-- Name: app_tenant fk_app_tenant_billing_topic; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_tenant
    ADD CONSTRAINT fk_app_tenant_billing_topic FOREIGN KEY (billing_topic_id) REFERENCES msg.topic(id);


--
-- Name: app_tenant_group_admin fk_app_tenant_group_admin_app_user; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_tenant_group_admin
    ADD CONSTRAINT fk_app_tenant_group_admin_app_user FOREIGN KEY (app_user_id) REFERENCES app.app_user(id);


--
-- Name: app_tenant_group_admin fk_app_tenant_group_admin_group; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_tenant_group_admin
    ADD CONSTRAINT fk_app_tenant_group_admin_group FOREIGN KEY (app_tenant_group_id) REFERENCES app.app_tenant_group(id);


--
-- Name: app_tenant_group_member fk_app_tenant_group_member_app_tenant; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_tenant_group_member
    ADD CONSTRAINT fk_app_tenant_group_member_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: app_tenant_group_member fk_app_tenant_group_member_group; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_tenant_group_member
    ADD CONSTRAINT fk_app_tenant_group_member_group FOREIGN KEY (app_tenant_group_id) REFERENCES app.app_tenant_group(id);


--
-- Name: app_tenant fk_app_tenant_organization; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_tenant
    ADD CONSTRAINT fk_app_tenant_organization FOREIGN KEY (organization_id) REFERENCES app.organization(id);


--
-- Name: app_tenant fk_app_tenant_parent; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_tenant
    ADD CONSTRAINT fk_app_tenant_parent FOREIGN KEY (parent_app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: app_tenant_subscription fk_app_tenant_subscription_license_pack; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_tenant_subscription
    ADD CONSTRAINT fk_app_tenant_subscription_license_pack FOREIGN KEY (license_pack_id) REFERENCES app.license_pack(id);


--
-- Name: app_tenant_subscription fk_app_tenant_subscription_parent; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_tenant_subscription
    ADD CONSTRAINT fk_app_tenant_subscription_parent FOREIGN KEY (parent_app_tenant_subscription_id) REFERENCES app.app_tenant_subscription(id);


--
-- Name: app_tenant_subscription fk_app_tenant_subscription_tenant; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_tenant_subscription
    ADD CONSTRAINT fk_app_tenant_subscription_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: app_user fk_app_user_app_tenant; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_user
    ADD CONSTRAINT fk_app_user_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: app_user fk_app_user_contact; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_user
    ADD CONSTRAINT fk_app_user_contact FOREIGN KEY (contact_id) REFERENCES app.contact(id);


--
-- Name: app_user fk_app_user_language; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.app_user
    ADD CONSTRAINT fk_app_user_language FOREIGN KEY (language_id) REFERENCES app.supported_language(id);


--
-- Name: contact fk_contact_app_tenant; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.contact
    ADD CONSTRAINT fk_contact_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: contact fk_contact_location; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.contact
    ADD CONSTRAINT fk_contact_location FOREIGN KEY (location_id) REFERENCES app.location(id);


--
-- Name: contact fk_contact_organization; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.contact
    ADD CONSTRAINT fk_contact_organization FOREIGN KEY (organization_id) REFERENCES app.organization(id);


--
-- Name: error_report fk_error_report_reported_as_app_user; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.error_report
    ADD CONSTRAINT fk_error_report_reported_as_app_user FOREIGN KEY (reported_as_app_user_id) REFERENCES app.app_user(id);


--
-- Name: error_report fk_error_report_reported_by_app_user; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.error_report
    ADD CONSTRAINT fk_error_report_reported_by_app_user FOREIGN KEY (reported_by_app_user_id) REFERENCES app.app_user(id);


--
-- Name: facility fk_facility_app_tenant; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.facility
    ADD CONSTRAINT fk_facility_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: facility fk_facility_location; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.facility
    ADD CONSTRAINT fk_facility_location FOREIGN KEY (location_id) REFERENCES app.location(id);


--
-- Name: facility fk_facility_organization; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.facility
    ADD CONSTRAINT fk_facility_organization FOREIGN KEY (organization_id) REFERENCES app.organization(id);


--
-- Name: license fk_license_app_tenant; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license
    ADD CONSTRAINT fk_license_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: license fk_license_assigned_to_app_user; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license
    ADD CONSTRAINT fk_license_assigned_to_app_user FOREIGN KEY (assigned_to_app_user_id) REFERENCES app.app_user(id);


--
-- Name: license fk_license_license_type; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license
    ADD CONSTRAINT fk_license_license_type FOREIGN KEY (license_type_key) REFERENCES app.license_type(key);


--
-- Name: license_permission fk_license_permission_app_tenant; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_permission
    ADD CONSTRAINT fk_license_permission_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: license_permission fk_license_permission_license; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_permission
    ADD CONSTRAINT fk_license_permission_license FOREIGN KEY (license_id) REFERENCES app.license(id);


--
-- Name: license_permission fk_license_permission_permission; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_permission
    ADD CONSTRAINT fk_license_permission_permission FOREIGN KEY (permission_key) REFERENCES app.permission(key);


--
-- Name: license fk_license_subscription; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license
    ADD CONSTRAINT fk_license_subscription FOREIGN KEY (subscription_id) REFERENCES app.app_tenant_subscription(id);


--
-- Name: license_type fk_license_type_application; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_type
    ADD CONSTRAINT fk_license_type_application FOREIGN KEY (application_key) REFERENCES app.application(key);


--
-- Name: license_type_permission fk_license_type_permission_license_type; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_type_permission
    ADD CONSTRAINT fk_license_type_permission_license_type FOREIGN KEY (license_type_key) REFERENCES app.license_type(key);


--
-- Name: license_type_permission fk_license_type_permission_permission; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_type_permission
    ADD CONSTRAINT fk_license_type_permission_permission FOREIGN KEY (permission_key) REFERENCES app.permission(key);


--
-- Name: location fk_location_app_tenant; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.location
    ADD CONSTRAINT fk_location_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: license_pack_license_type fk_lpl_license_pack; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_pack_license_type
    ADD CONSTRAINT fk_lpl_license_pack FOREIGN KEY (license_pack_id) REFERENCES app.license_pack(id);


--
-- Name: license_pack_license_type fk_lpl_license_type; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_pack_license_type
    ADD CONSTRAINT fk_lpl_license_type FOREIGN KEY (license_type_key) REFERENCES app.license_type(key);


--
-- Name: module fk_module_application; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.module
    ADD CONSTRAINT fk_module_application FOREIGN KEY (application_key) REFERENCES app.application(key);


--
-- Name: module fk_module_permission_key; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.module
    ADD CONSTRAINT fk_module_permission_key FOREIGN KEY (permission_key) REFERENCES app.permission(key);


--
-- Name: note fk_note_app_tenant; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.note
    ADD CONSTRAINT fk_note_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: note fk_note_app_user; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.note
    ADD CONSTRAINT fk_note_app_user FOREIGN KEY (created_by_app_user_id) REFERENCES app.app_user(id);


--
-- Name: organization fk_organization_app_tenant; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.organization
    ADD CONSTRAINT fk_organization_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: organization fk_organization_location; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.organization
    ADD CONSTRAINT fk_organization_location FOREIGN KEY (location_id) REFERENCES app.location(id);


--
-- Name: organization fk_organization_primary_contact; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.organization
    ADD CONSTRAINT fk_organization_primary_contact FOREIGN KEY (primary_contact_id) REFERENCES app.contact(id);


--
-- Name: signed_eula fk_signed_eula_app_tenant; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.signed_eula
    ADD CONSTRAINT fk_signed_eula_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: signed_eula fk_signed_eula_eula; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.signed_eula
    ADD CONSTRAINT fk_signed_eula_eula FOREIGN KEY (eula_id) REFERENCES app.eula(id);


--
-- Name: signed_eula fk_signed_eula_signed_by_app_user; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.signed_eula
    ADD CONSTRAINT fk_signed_eula_signed_by_app_user FOREIGN KEY (signed_by_app_user_id) REFERENCES app.app_user(id);


--
-- Name: sub_module fk_sub_module_module; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.sub_module
    ADD CONSTRAINT fk_sub_module_module FOREIGN KEY (module_id) REFERENCES app.module(id);


--
-- Name: sub_module fk_sub_module_permission_key; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.sub_module
    ADD CONSTRAINT fk_sub_module_permission_key FOREIGN KEY (permission_key) REFERENCES app.permission(key);


--
-- Name: email_request fk_email_request_app_tenant; Type: FK CONSTRAINT; Schema: msg; Owner: postgres
--

ALTER TABLE ONLY msg.email_request
    ADD CONSTRAINT fk_email_request_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: email_request fk_email_request_app_user; Type: FK CONSTRAINT; Schema: msg; Owner: postgres
--

ALTER TABLE ONLY msg.email_request
    ADD CONSTRAINT fk_email_request_app_user FOREIGN KEY (sent_by_app_user_id) REFERENCES app.app_user(id);


--
-- Name: message fk_message_app_tenant; Type: FK CONSTRAINT; Schema: msg; Owner: postgres
--

ALTER TABLE ONLY msg.message
    ADD CONSTRAINT fk_message_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: message fk_message_posted_by; Type: FK CONSTRAINT; Schema: msg; Owner: postgres
--

ALTER TABLE ONLY msg.message
    ADD CONSTRAINT fk_message_posted_by FOREIGN KEY (posted_by_contact_id) REFERENCES app.contact(id);


--
-- Name: message fk_message_topic; Type: FK CONSTRAINT; Schema: msg; Owner: postgres
--

ALTER TABLE ONLY msg.message
    ADD CONSTRAINT fk_message_topic FOREIGN KEY (topic_id) REFERENCES msg.topic(id);


--
-- Name: subscription fk_subscription_app_tenant; Type: FK CONSTRAINT; Schema: msg; Owner: postgres
--

ALTER TABLE ONLY msg.subscription
    ADD CONSTRAINT fk_subscription_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: subscription fk_subscription_subscriber_contact; Type: FK CONSTRAINT; Schema: msg; Owner: postgres
--

ALTER TABLE ONLY msg.subscription
    ADD CONSTRAINT fk_subscription_subscriber_contact FOREIGN KEY (subscriber_contact_id) REFERENCES app.contact(id);


--
-- Name: subscription fk_subscription_topic; Type: FK CONSTRAINT; Schema: msg; Owner: postgres
--

ALTER TABLE ONLY msg.subscription
    ADD CONSTRAINT fk_subscription_topic FOREIGN KEY (topic_id) REFERENCES msg.topic(id);


--
-- Name: app_exception; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.app_exception ENABLE ROW LEVEL SECURITY;

--
-- Name: app_route; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.app_route ENABLE ROW LEVEL SECURITY;

--
-- Name: app_tenant; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.app_tenant ENABLE ROW LEVEL SECURITY;

--
-- Name: app_tenant_group; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.app_tenant_group ENABLE ROW LEVEL SECURITY;

--
-- Name: app_tenant_group_admin; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.app_tenant_group_admin ENABLE ROW LEVEL SECURITY;

--
-- Name: app_tenant_group_member; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.app_tenant_group_member ENABLE ROW LEVEL SECURITY;

--
-- Name: app_tenant_subscription; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.app_tenant_subscription ENABLE ROW LEVEL SECURITY;

--
-- Name: app_user; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.app_user ENABLE ROW LEVEL SECURITY;

--
-- Name: application; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.application ENABLE ROW LEVEL SECURITY;

--
-- Name: contact; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.contact ENABLE ROW LEVEL SECURITY;

--
-- Name: error_report; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.error_report ENABLE ROW LEVEL SECURITY;

--
-- Name: eula; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.eula ENABLE ROW LEVEL SECURITY;

--
-- Name: facility; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.facility ENABLE ROW LEVEL SECURITY;

--
-- Name: license; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.license ENABLE ROW LEVEL SECURITY;

--
-- Name: license_pack; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.license_pack ENABLE ROW LEVEL SECURITY;

--
-- Name: license_pack_license_type; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.license_pack_license_type ENABLE ROW LEVEL SECURITY;

--
-- Name: license_permission; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.license_permission ENABLE ROW LEVEL SECURITY;

--
-- Name: license_type; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.license_type ENABLE ROW LEVEL SECURITY;

--
-- Name: license_type_permission; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.license_type_permission ENABLE ROW LEVEL SECURITY;

--
-- Name: location; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.location ENABLE ROW LEVEL SECURITY;

--
-- Name: note; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.note ENABLE ROW LEVEL SECURITY;

--
-- Name: organization; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.organization ENABLE ROW LEVEL SECURITY;

--
-- Name: permission; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.permission ENABLE ROW LEVEL SECURITY;

--
-- Name: registration; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.registration ENABLE ROW LEVEL SECURITY;

--
-- Name: signed_eula; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.signed_eula ENABLE ROW LEVEL SECURITY;

--
-- Name: supported_language; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.supported_language ENABLE ROW LEVEL SECURITY;

--
-- Name: app_exception tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.app_exception FOR DELETE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: app_route tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.app_route FOR DELETE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: app_tenant tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.app_tenant FOR DELETE TO app_usr USING (auth_fn.app_user_has_access(id));


--
-- Name: app_tenant_group tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.app_tenant_group FOR DELETE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: app_tenant_group_admin tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.app_tenant_group_admin FOR DELETE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: app_tenant_group_member tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.app_tenant_group_member FOR DELETE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: app_tenant_subscription tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.app_tenant_subscription FOR DELETE TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: app_user tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.app_user FOR DELETE TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: application tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.application FOR DELETE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: contact tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.contact FOR DELETE TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: error_report tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.error_report FOR DELETE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: eula tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.eula FOR DELETE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: facility tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.facility FOR DELETE TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: license tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.license FOR DELETE TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: license_pack tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.license_pack FOR DELETE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: license_pack_license_type tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.license_pack_license_type FOR DELETE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: license_permission tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.license_permission FOR DELETE TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: license_type tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.license_type FOR DELETE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: license_type_permission tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.license_type_permission FOR DELETE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: location tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.location FOR DELETE TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: note tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.note FOR DELETE TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: organization tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.organization FOR DELETE TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: permission tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.permission FOR DELETE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: registration tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.registration FOR DELETE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: signed_eula tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.signed_eula FOR DELETE TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: supported_language tenant_delete; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_delete ON app.supported_language FOR DELETE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: app_exception tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.app_exception FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: app_route tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.app_route FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: app_tenant tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.app_tenant FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_access(id));


--
-- Name: app_tenant_group tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.app_tenant_group FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: app_tenant_group_admin tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.app_tenant_group_admin FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: app_tenant_group_member tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.app_tenant_group_member FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: app_tenant_subscription tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.app_tenant_subscription FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: app_user tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.app_user FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: application tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.application FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: contact tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.contact FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: error_report tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.error_report FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: eula tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.eula FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: facility tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.facility FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: license tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.license FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: license_pack tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.license_pack FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: license_pack_license_type tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.license_pack_license_type FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: license_permission tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.license_permission FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: license_type tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.license_type FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: license_type_permission tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.license_type_permission FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: location tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.location FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: note tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.note FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: organization tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.organization FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: permission tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.permission FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: registration tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.registration FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: signed_eula tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.signed_eula FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: supported_language tenant_insert; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_insert ON app.supported_language FOR INSERT TO app_usr WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: app_exception tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.app_exception FOR SELECT TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: app_route tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.app_route FOR SELECT TO app_usr USING ((1 = 1));


--
-- Name: app_tenant tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.app_tenant FOR SELECT TO app_usr USING (auth_fn.app_user_has_access(id));


--
-- Name: app_tenant_group tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.app_tenant_group FOR SELECT TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: app_tenant_group_admin tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.app_tenant_group_admin FOR SELECT TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: app_tenant_group_member tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.app_tenant_group_member FOR SELECT TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: app_tenant_subscription tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.app_tenant_subscription FOR SELECT TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: app_user tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.app_user FOR SELECT TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: application tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.application FOR SELECT TO app_usr USING ((1 = 1));


--
-- Name: contact tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.contact FOR SELECT TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: error_report tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.error_report FOR SELECT TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: eula tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.eula FOR SELECT TO app_usr USING ((1 = 1));


--
-- Name: facility tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.facility FOR SELECT TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: license tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.license FOR SELECT TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: license_pack tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.license_pack FOR SELECT TO app_usr USING ((1 = 1));


--
-- Name: license_pack_license_type tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.license_pack_license_type FOR SELECT TO app_usr USING ((1 = 1));


--
-- Name: license_permission tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.license_permission FOR SELECT TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: license_type tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.license_type FOR SELECT TO app_usr USING ((1 = 1));


--
-- Name: license_type_permission tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.license_type_permission FOR SELECT TO app_usr USING ((1 = 1));


--
-- Name: location tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.location FOR SELECT TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: note tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.note FOR SELECT TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: organization tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.organization FOR SELECT TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: permission tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.permission FOR SELECT TO app_usr USING ((1 = 1));


--
-- Name: registration tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.registration FOR SELECT TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: signed_eula tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.signed_eula FOR SELECT TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: supported_language tenant_select; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_select ON app.supported_language FOR SELECT TO app_usr USING ((1 = 1));


--
-- Name: app_exception tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.app_exception FOR UPDATE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text)) WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: app_route tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.app_route FOR UPDATE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text)) WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: app_tenant tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.app_tenant FOR UPDATE TO app_usr USING (auth_fn.app_user_has_access(id)) WITH CHECK (auth_fn.app_user_has_access(id));


--
-- Name: app_tenant_group tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.app_tenant_group FOR UPDATE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text)) WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: app_tenant_group_admin tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.app_tenant_group_admin FOR UPDATE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text)) WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: app_tenant_group_member tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.app_tenant_group_member FOR UPDATE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text)) WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: app_tenant_subscription tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.app_tenant_subscription FOR UPDATE TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id)) WITH CHECK (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: app_user tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.app_user FOR UPDATE TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id)) WITH CHECK (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: application tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.application FOR UPDATE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text)) WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: contact tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.contact FOR UPDATE TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id)) WITH CHECK (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: error_report tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.error_report FOR UPDATE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text)) WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: eula tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.eula FOR UPDATE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text)) WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: facility tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.facility FOR UPDATE TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id)) WITH CHECK (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: license tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.license FOR UPDATE TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id)) WITH CHECK (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: license_pack tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.license_pack FOR UPDATE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text)) WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: license_pack_license_type tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.license_pack_license_type FOR UPDATE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text)) WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: license_permission tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.license_permission FOR UPDATE TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id)) WITH CHECK (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: license_type tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.license_type FOR UPDATE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text)) WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: license_type_permission tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.license_type_permission FOR UPDATE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text)) WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: location tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.location FOR UPDATE TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id)) WITH CHECK (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: note tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.note FOR UPDATE TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id)) WITH CHECK (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: organization tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.organization FOR UPDATE TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id)) WITH CHECK (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: permission tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.permission FOR UPDATE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text)) WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: registration tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.registration FOR UPDATE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text)) WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: signed_eula tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.signed_eula FOR UPDATE TO app_usr USING (auth_fn.app_user_has_access(app_tenant_id)) WITH CHECK (auth_fn.app_user_has_access(app_tenant_id));


--
-- Name: supported_language tenant_update; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY tenant_update ON app.supported_language FOR UPDATE TO app_usr USING (auth_fn.app_user_has_permission('p:super-admin'::text)) WITH CHECK (auth_fn.app_user_has_permission('p:super-admin'::text));


--
-- Name: SCHEMA app; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA app TO app_usr;


--
-- Name: SCHEMA app_fn; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA app_fn TO app_usr;


--
-- Name: SCHEMA app_fn_private; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA app_fn_private TO app_usr;


--
-- Name: SCHEMA auth_bootstrap; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA auth_bootstrap TO app_anon;
GRANT USAGE ON SCHEMA auth_bootstrap TO app_usr;


--
-- Name: SCHEMA auth_fn; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA auth_fn TO app_usr;


--
-- Name: SCHEMA auth_fn_private; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA auth_fn_private TO app_usr;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO app_auth;


--
-- Name: SCHEMA shard_1; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA shard_1 TO app_usr;


--
-- Name: FUNCTION id_generator(shard_id integer); Type: ACL; Schema: shard_1; Owner: postgres
--

REVOKE ALL ON FUNCTION shard_1.id_generator(shard_id integer) FROM PUBLIC;
GRANT ALL ON FUNCTION shard_1.id_generator(shard_id integer) TO app_usr;


--
-- Name: TABLE license_pack; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.license_pack TO app_usr;


--
-- Name: TABLE license_pack_license_type; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.license_pack_license_type TO app_usr;


--
-- Name: TABLE contact; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.contact TO app_usr;


--
-- Name: TABLE app_tenant; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.app_tenant TO app_usr;


--
-- Name: TABLE app_user; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.app_user TO app_usr;


--
-- Name: FUNCTION app_tenant_active_guest_users(_app_tenant app.app_tenant); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.app_tenant_active_guest_users(_app_tenant app.app_tenant) FROM PUBLIC;
GRANT ALL ON FUNCTION app.app_tenant_active_guest_users(_app_tenant app.app_tenant) TO app_usr;


--
-- Name: TABLE app_tenant_subscription; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.app_tenant_subscription TO app_usr;


--
-- Name: FUNCTION app_tenant_active_subscriptions(_app_tenant app.app_tenant); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.app_tenant_active_subscriptions(_app_tenant app.app_tenant) FROM PUBLIC;
GRANT ALL ON FUNCTION app.app_tenant_active_subscriptions(_app_tenant app.app_tenant) TO app_usr;


--
-- Name: FUNCTION app_tenant_active_users(_app_tenant app.app_tenant); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.app_tenant_active_users(_app_tenant app.app_tenant) FROM PUBLIC;
GRANT ALL ON FUNCTION app.app_tenant_active_users(_app_tenant app.app_tenant) TO app_usr;


--
-- Name: FUNCTION app_tenant_available_licenses(_app_tenant app.app_tenant); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.app_tenant_available_licenses(_app_tenant app.app_tenant) FROM PUBLIC;
GRANT ALL ON FUNCTION app.app_tenant_available_licenses(_app_tenant app.app_tenant) TO app_usr;


--
-- Name: FUNCTION app_tenant_flags(_app_tenant app.app_tenant); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.app_tenant_flags(_app_tenant app.app_tenant) FROM PUBLIC;
GRANT ALL ON FUNCTION app.app_tenant_flags(_app_tenant app.app_tenant) TO app_usr;


--
-- Name: FUNCTION app_tenant_inactive_guest_users(_app_tenant app.app_tenant); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.app_tenant_inactive_guest_users(_app_tenant app.app_tenant) FROM PUBLIC;
GRANT ALL ON FUNCTION app.app_tenant_inactive_guest_users(_app_tenant app.app_tenant) TO app_usr;


--
-- Name: FUNCTION app_tenant_inactive_users(_app_tenant app.app_tenant); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.app_tenant_inactive_users(_app_tenant app.app_tenant) FROM PUBLIC;
GRANT ALL ON FUNCTION app.app_tenant_inactive_users(_app_tenant app.app_tenant) TO app_usr;


--
-- Name: FUNCTION app_tenant_license_type_is_available(_app_tenant_id text, _license_type_key text); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.app_tenant_license_type_is_available(_app_tenant_id text, _license_type_key text) FROM PUBLIC;
GRANT ALL ON FUNCTION app.app_tenant_license_type_is_available(_app_tenant_id text, _license_type_key text) TO app_usr;


--
-- Name: FUNCTION app_tenant_payment_status_summary(_app_tenant app.app_tenant); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.app_tenant_payment_status_summary(_app_tenant app.app_tenant) FROM PUBLIC;
GRANT ALL ON FUNCTION app.app_tenant_payment_status_summary(_app_tenant app.app_tenant) TO app_usr;


--
-- Name: FUNCTION app_tenant_subscription_available_add_ons(_app_tenant_subscription app.app_tenant_subscription); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.app_tenant_subscription_available_add_ons(_app_tenant_subscription app.app_tenant_subscription) FROM PUBLIC;
GRANT ALL ON FUNCTION app.app_tenant_subscription_available_add_ons(_app_tenant_subscription app.app_tenant_subscription) TO app_usr;


--
-- Name: FUNCTION app_tenant_subscription_available_licenses(_app_tenant_subscription app.app_tenant_subscription); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.app_tenant_subscription_available_licenses(_app_tenant_subscription app.app_tenant_subscription) FROM PUBLIC;
GRANT ALL ON FUNCTION app.app_tenant_subscription_available_licenses(_app_tenant_subscription app.app_tenant_subscription) TO app_usr;


--
-- Name: FUNCTION app_tenant_subscription_available_upgrade_paths(_app_tenant_subscription app.app_tenant_subscription); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.app_tenant_subscription_available_upgrade_paths(_app_tenant_subscription app.app_tenant_subscription) FROM PUBLIC;
GRANT ALL ON FUNCTION app.app_tenant_subscription_available_upgrade_paths(_app_tenant_subscription app.app_tenant_subscription) TO app_usr;


--
-- Name: TABLE license; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.license TO app_usr;


--
-- Name: FUNCTION app_user_active_licenses(_app_user app.app_user); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.app_user_active_licenses(_app_user app.app_user) FROM PUBLIC;
GRANT ALL ON FUNCTION app.app_user_active_licenses(_app_user app.app_user) TO app_usr;


--
-- Name: FUNCTION app_user_home_path(_app_user app.app_user); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.app_user_home_path(_app_user app.app_user) FROM PUBLIC;
GRANT ALL ON FUNCTION app.app_user_home_path(_app_user app.app_user) TO app_usr;


--
-- Name: FUNCTION app_user_licensing_status(_app_user app.app_user); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.app_user_licensing_status(_app_user app.app_user) FROM PUBLIC;
GRANT ALL ON FUNCTION app.app_user_licensing_status(_app_user app.app_user) TO app_usr;


--
-- Name: FUNCTION app_user_permissions(_app_user app.app_user, _current_app_tenant_id text); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.app_user_permissions(_app_user app.app_user, _current_app_tenant_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app.app_user_permissions(_app_user app.app_user, _current_app_tenant_id text) TO app_usr;


--
-- Name: FUNCTION app_user_primary_license(_app_user app.app_user); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.app_user_primary_license(_app_user app.app_user) FROM PUBLIC;
GRANT ALL ON FUNCTION app.app_user_primary_license(_app_user app.app_user) TO app_usr;


--
-- Name: FUNCTION application_no_delete(); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.application_no_delete() FROM PUBLIC;
GRANT ALL ON FUNCTION app.application_no_delete() TO app_usr;


--
-- Name: FUNCTION calculate_license_status(_license app.license); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.calculate_license_status(_license app.license) FROM PUBLIC;
GRANT ALL ON FUNCTION app.calculate_license_status(_license app.license) TO app_usr;


--
-- Name: FUNCTION contact_full_name(_contact app.contact); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.contact_full_name(_contact app.contact) FROM PUBLIC;
GRANT ALL ON FUNCTION app.contact_full_name(_contact app.contact) TO app_usr;


--
-- Name: FUNCTION contact_has_unanswered_messages(_contact app.contact); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.contact_has_unanswered_messages(_contact app.contact) FROM PUBLIC;
GRANT ALL ON FUNCTION app.contact_has_unanswered_messages(_contact app.contact) TO app_usr;


--
-- Name: FUNCTION create_contact(_contact_info app_fn.create_contact_input, _app_tenant_id text); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.create_contact(_contact_info app_fn.create_contact_input, _app_tenant_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app.create_contact(_contact_info app_fn.create_contact_input, _app_tenant_id text) TO app_usr;


--
-- Name: FUNCTION fn_ensure_license_status(); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.fn_ensure_license_status() FROM PUBLIC;
GRANT ALL ON FUNCTION app.fn_ensure_license_status() TO app_usr;


--
-- Name: FUNCTION fn_update_eula_trigger(); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.fn_update_eula_trigger() FROM PUBLIC;
GRANT ALL ON FUNCTION app.fn_update_eula_trigger() TO app_usr;


--
-- Name: FUNCTION license_can_activate(_license app.license); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.license_can_activate(_license app.license) FROM PUBLIC;
GRANT ALL ON FUNCTION app.license_can_activate(_license app.license) TO app_usr;


--
-- Name: FUNCTION license_pack_allowed_actions(_license_pack app.license_pack); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.license_pack_allowed_actions(_license_pack app.license_pack) FROM PUBLIC;
GRANT ALL ON FUNCTION app.license_pack_allowed_actions(_license_pack app.license_pack) TO app_usr;


--
-- Name: FUNCTION license_pack_candidate_add_on_keys(_license_pack app.license_pack); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.license_pack_candidate_add_on_keys(_license_pack app.license_pack) FROM PUBLIC;
GRANT ALL ON FUNCTION app.license_pack_candidate_add_on_keys(_license_pack app.license_pack) TO app_usr;


--
-- Name: FUNCTION license_pack_candidate_license_type_keys(_license_pack app.license_pack); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.license_pack_candidate_license_type_keys(_license_pack app.license_pack) FROM PUBLIC;
GRANT ALL ON FUNCTION app.license_pack_candidate_license_type_keys(_license_pack app.license_pack) TO app_usr;


--
-- Name: FUNCTION license_pack_candidate_upgrade_path_keys(_license_pack app.license_pack); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.license_pack_candidate_upgrade_path_keys(_license_pack app.license_pack) FROM PUBLIC;
GRANT ALL ON FUNCTION app.license_pack_candidate_upgrade_path_keys(_license_pack app.license_pack) TO app_usr;


--
-- Name: FUNCTION license_pack_discontinued_add_ons(_license_pack app.license_pack); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.license_pack_discontinued_add_ons(_license_pack app.license_pack) FROM PUBLIC;
GRANT ALL ON FUNCTION app.license_pack_discontinued_add_ons(_license_pack app.license_pack) TO app_usr;


--
-- Name: FUNCTION license_pack_draft_add_ons(_license_pack app.license_pack); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.license_pack_draft_add_ons(_license_pack app.license_pack) FROM PUBLIC;
GRANT ALL ON FUNCTION app.license_pack_draft_add_ons(_license_pack app.license_pack) TO app_usr;


--
-- Name: FUNCTION license_pack_published_add_ons(_license_pack app.license_pack); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.license_pack_published_add_ons(_license_pack app.license_pack) FROM PUBLIC;
GRANT ALL ON FUNCTION app.license_pack_published_add_ons(_license_pack app.license_pack) TO app_usr;


--
-- Name: FUNCTION license_pack_published_implicit_add_ons(_license_pack app.license_pack); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.license_pack_published_implicit_add_ons(_license_pack app.license_pack) FROM PUBLIC;
GRANT ALL ON FUNCTION app.license_pack_published_implicit_add_ons(_license_pack app.license_pack) TO app_usr;


--
-- Name: FUNCTION license_pack_siblings(_license_pack app.license_pack); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.license_pack_siblings(_license_pack app.license_pack) FROM PUBLIC;
GRANT ALL ON FUNCTION app.license_pack_siblings(_license_pack app.license_pack) TO app_usr;


--
-- Name: FUNCTION set_app_tenant_setting_to_default(_app_tenant_id text); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.set_app_tenant_setting_to_default(_app_tenant_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app.set_app_tenant_setting_to_default(_app_tenant_id text) TO app_usr;


--
-- Name: FUNCTION activate_app_tenant_subscription(_app_tenant_subscription_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.activate_app_tenant_subscription(_app_tenant_subscription_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.activate_app_tenant_subscription(_app_tenant_subscription_id text) TO app_usr;


--
-- Name: FUNCTION activate_license(_license_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.activate_license(_license_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.activate_license(_license_id text) TO app_usr;


--
-- Name: TABLE supported_language; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.supported_language TO app_usr;


--
-- Name: FUNCTION activate_supported_language(_language_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.activate_supported_language(_language_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.activate_supported_language(_language_id text) TO app_usr;


--
-- Name: TABLE app_tenant_group_member; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.app_tenant_group_member TO app_usr;


--
-- Name: FUNCTION add_app_tenant_group_member(_app_tenant_group_id text, _app_tenant_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.add_app_tenant_group_member(_app_tenant_group_id text, _app_tenant_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.add_app_tenant_group_member(_app_tenant_group_id text, _app_tenant_id text) TO app_usr;


--
-- Name: TABLE error_report; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.error_report TO app_usr;


--
-- Name: FUNCTION address_error_report(_error_report_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.address_error_report(_error_report_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.address_error_report(_error_report_id text) TO app_usr;


--
-- Name: FUNCTION after_user_license_assigned(_license_type_key text, _assigned_to_app_user_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.after_user_license_assigned(_license_type_key text, _assigned_to_app_user_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.after_user_license_assigned(_license_type_key text, _assigned_to_app_user_id text) TO app_usr;


--
-- Name: FUNCTION app_tenant_search(_options app_fn.app_tenant_search_options); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.app_tenant_search(_options app_fn.app_tenant_search_options) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.app_tenant_search(_options app_fn.app_tenant_search_options) TO app_usr;


--
-- Name: FUNCTION app_tenant_subsidiaries(); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.app_tenant_subsidiaries() FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.app_tenant_subsidiaries() TO app_usr;


--
-- Name: FUNCTION assign_license_to_user(_license_id text, _app_user_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.assign_license_to_user(_license_id text, _app_user_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.assign_license_to_user(_license_id text, _app_user_id text) TO app_usr;


--
-- Name: FUNCTION calculate_upgrade_config(_license_pack app.license_pack); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.calculate_upgrade_config(_license_pack app.license_pack) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.calculate_upgrade_config(_license_pack app.license_pack) TO app_usr;


--
-- Name: FUNCTION change_app_tenant_type(_app_tenant_id text, _app_tenant_type app.app_tenant_type); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.change_app_tenant_type(_app_tenant_id text, _app_tenant_type app.app_tenant_type) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.change_app_tenant_type(_app_tenant_id text, _app_tenant_type app.app_tenant_type) TO app_usr;


--
-- Name: FUNCTION change_app_user_email(_app_user_id text, _email text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.change_app_user_email(_app_user_id text, _email text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.change_app_user_email(_app_user_id text, _email text) TO app_usr;


--
-- Name: FUNCTION change_license_type(_license_ids text[], _license_type_key text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.change_license_type(_license_ids text[], _license_type_key text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.change_license_type(_license_ids text[], _license_type_key text) TO app_usr;


--
-- Name: FUNCTION check_subscription_for_license_availability(_license_type_key text, _app_tenant_subscription app.app_tenant_subscription); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.check_subscription_for_license_availability(_license_type_key text, _app_tenant_subscription app.app_tenant_subscription) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.check_subscription_for_license_availability(_license_type_key text, _app_tenant_subscription app.app_tenant_subscription) TO app_usr;


--
-- Name: FUNCTION clone_license_pack(_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.clone_license_pack(_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.clone_license_pack(_id text) TO app_usr;


--
-- Name: FUNCTION create_app_tenant(_new_tenant_info app_fn.new_app_tenant_info); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.create_app_tenant(_new_tenant_info app_fn.new_app_tenant_info) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.create_app_tenant(_new_tenant_info app_fn.new_app_tenant_info) TO app_usr;


--
-- Name: FUNCTION create_app_user(_user_info app_fn.new_app_user_info); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.create_app_user(_user_info app_fn.new_app_user_info) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.create_app_user(_user_info app_fn.new_app_user_info) TO app_usr;


--
-- Name: TABLE application; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.application TO app_usr;


--
-- Name: FUNCTION create_application(_application_info app_fn.application_info); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.create_application(_application_info app_fn.application_info) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.create_application(_application_info app_fn.application_info) TO app_usr;


--
-- Name: FUNCTION create_demo_app_tenant(_license_pack_key text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.create_demo_app_tenant(_license_pack_key text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.create_demo_app_tenant(_license_pack_key text) TO app_usr;


--
-- Name: TABLE license_type; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.license_type TO app_usr;


--
-- Name: FUNCTION create_license_type(_license_type_info app_fn.license_type_info); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.create_license_type(_license_type_info app_fn.license_type_info) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.create_license_type(_license_type_info app_fn.license_type_info) TO app_usr;


--
-- Name: FUNCTION create_new_licensed_app_user(_license_type_key text, _subscription_id text, _user_info app_fn.new_app_user_info); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.create_new_licensed_app_user(_license_type_key text, _subscription_id text, _user_info app_fn.new_app_user_info) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.create_new_licensed_app_user(_license_type_key text, _subscription_id text, _user_info app_fn.new_app_user_info) TO app_usr;


--
-- Name: TABLE permission; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.permission TO app_usr;


--
-- Name: FUNCTION create_permission(_permission_key text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.create_permission(_permission_key text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.create_permission(_permission_key text) TO app_usr;


--
-- Name: FUNCTION create_subsidiary(_parent_app_tenant_id text, _subsidiary_name text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.create_subsidiary(_parent_app_tenant_id text, _subsidiary_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.create_subsidiary(_parent_app_tenant_id text, _subsidiary_name text) TO app_usr;


--
-- Name: FUNCTION create_tutorial_tenant(_license_pack_key text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.create_tutorial_tenant(_license_pack_key text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.create_tutorial_tenant(_license_pack_key text) TO app_usr;


--
-- Name: FUNCTION current_app_tenant(); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.current_app_tenant() FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.current_app_tenant() TO app_usr;


--
-- Name: FUNCTION current_app_tenant_active_subscriptions(); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.current_app_tenant_active_subscriptions() FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.current_app_tenant_active_subscriptions() TO app_usr;


--
-- Name: FUNCTION current_app_tenant_inactive_subscriptions(); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.current_app_tenant_inactive_subscriptions() FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.current_app_tenant_inactive_subscriptions() TO app_usr;


--
-- Name: FUNCTION current_user_licensing_status(); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.current_user_licensing_status() FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.current_user_licensing_status() TO app_usr;


--
-- Name: FUNCTION deactivate_app_tenant_subscription(_app_tenant_subscription_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.deactivate_app_tenant_subscription(_app_tenant_subscription_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.deactivate_app_tenant_subscription(_app_tenant_subscription_id text) TO app_usr;


--
-- Name: FUNCTION deactivate_app_tenant_subscriptions(_app_tenant_subscription_ids text[]); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.deactivate_app_tenant_subscriptions(_app_tenant_subscription_ids text[]) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.deactivate_app_tenant_subscriptions(_app_tenant_subscription_ids text[]) TO app_usr;


--
-- Name: FUNCTION deactivate_app_user(_app_user_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.deactivate_app_user(_app_user_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.deactivate_app_user(_app_user_id text) TO app_usr;


--
-- Name: FUNCTION deactivate_license(_license_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.deactivate_license(_license_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.deactivate_license(_license_id text) TO app_usr;


--
-- Name: FUNCTION deactivate_supported_language(_language_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.deactivate_supported_language(_language_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.deactivate_supported_language(_language_id text) TO app_usr;


--
-- Name: FUNCTION delete_app_errors(_error_report_ids text[]); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.delete_app_errors(_error_report_ids text[]) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.delete_app_errors(_error_report_ids text[]) TO app_usr;


--
-- Name: FUNCTION delete_app_tenant_group(_app_tenant_group_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.delete_app_tenant_group(_app_tenant_group_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.delete_app_tenant_group(_app_tenant_group_id text) TO app_usr;


--
-- Name: FUNCTION delete_license(_license_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.delete_license(_license_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.delete_license(_license_id text) TO app_usr;


--
-- Name: FUNCTION demo_admin_users(); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.demo_admin_users() FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.demo_admin_users() TO app_usr;


--
-- Name: FUNCTION demo_user_infos(_app_tenant app.app_tenant); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.demo_user_infos(_app_tenant app.app_tenant) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.demo_user_infos(_app_tenant app.app_tenant) TO app_usr;


--
-- Name: FUNCTION demoable_license_packs(); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.demoable_license_packs() FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.demoable_license_packs() TO app_usr;


--
-- Name: FUNCTION demote_user_from_admin(_app_user_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.demote_user_from_admin(_app_user_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.demote_user_from_admin(_app_user_id text) TO app_usr;


--
-- Name: FUNCTION demote_user_from_app_tenant_group_admin(_app_user_id text, _app_tenant_group_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.demote_user_from_app_tenant_group_admin(_app_user_id text, _app_tenant_group_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.demote_user_from_app_tenant_group_admin(_app_user_id text, _app_tenant_group_id text) TO app_usr;


--
-- Name: FUNCTION demote_user_from_demo_admin(_app_user_id text, _language_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.demote_user_from_demo_admin(_app_user_id text, _language_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.demote_user_from_demo_admin(_app_user_id text, _language_id text) TO app_usr;


--
-- Name: FUNCTION discard_license_pack(_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.discard_license_pack(_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.discard_license_pack(_id text) TO app_usr;


--
-- Name: FUNCTION discontinue_license_pack(_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.discontinue_license_pack(_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.discontinue_license_pack(_id text) TO app_usr;


--
-- Name: FUNCTION eligible_app_tenant_group_admin_candidates(); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.eligible_app_tenant_group_admin_candidates() FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.eligible_app_tenant_group_admin_candidates() TO app_usr;


--
-- Name: FUNCTION eligible_demo_admin_candidates(); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.eligible_demo_admin_candidates() FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.eligible_demo_admin_candidates() TO app_usr;


--
-- Name: FUNCTION error_report_search(_options app_fn.error_report_search_options); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.error_report_search(_options app_fn.error_report_search_options) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.error_report_search(_options app_fn.error_report_search_options) TO app_usr;


--
-- Name: FUNCTION expired_licenses(_app_tenant_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.expired_licenses(_app_tenant_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.expired_licenses(_app_tenant_id text) TO app_usr;


--
-- Name: FUNCTION find_available_license_subscription(_license_type_key text, _app_tenant_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.find_available_license_subscription(_license_type_key text, _app_tenant_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.find_available_license_subscription(_license_type_key text, _app_tenant_id text) TO app_usr;


--
-- Name: FUNCTION force_provision_tenant_license(_license_type_key text, _app_tenant_id text, _assigned_to_app_user_id text, _subscription_id text, _expiration_date date); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.force_provision_tenant_license(_license_type_key text, _app_tenant_id text, _assigned_to_app_user_id text, _subscription_id text, _expiration_date date) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.force_provision_tenant_license(_license_type_key text, _app_tenant_id text, _assigned_to_app_user_id text, _subscription_id text, _expiration_date date) TO app_usr;


--
-- Name: FUNCTION grant_admin(_app_user_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.grant_admin(_app_user_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.grant_admin(_app_user_id text) TO app_usr;


--
-- Name: TABLE license_type_permission; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.license_type_permission TO app_usr;


--
-- Name: FUNCTION grant_license_type_permission(_license_type_key text, _permission_key text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.grant_license_type_permission(_license_type_key text, _permission_key text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.grant_license_type_permission(_license_type_key text, _permission_key text) TO app_usr;


--
-- Name: FUNCTION grant_super_admin(_app_user_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.grant_super_admin(_app_user_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.grant_super_admin(_app_user_id text) TO app_usr;


--
-- Name: FUNCTION grant_user(_app_user_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.grant_user(_app_user_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.grant_user(_app_user_id text) TO app_usr;


--
-- Name: FUNCTION housekeeping_tasks(); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.housekeeping_tasks() FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.housekeeping_tasks() TO app_usr;


--
-- Name: FUNCTION issue_license_to_existing_app_user(_license_type_key text, _subscription_id text, _app_user_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.issue_license_to_existing_app_user(_license_type_key text, _subscription_id text, _app_user_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.issue_license_to_existing_app_user(_license_type_key text, _subscription_id text, _app_user_id text) TO app_usr;


--
-- Name: FUNCTION license_packs_by_key_version(_license_pack_key text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.license_packs_by_key_version(_license_pack_key text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.license_packs_by_key_version(_license_pack_key text) TO app_usr;


--
-- Name: FUNCTION move_licenses_to_subscription(_license_ids text[], _app_tenant_subscription_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.move_licenses_to_subscription(_license_ids text[], _app_tenant_subscription_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.move_licenses_to_subscription(_license_ids text[], _app_tenant_subscription_id text) TO app_usr;


--
-- Name: FUNCTION promote_user_to_admin(_app_user_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.promote_user_to_admin(_app_user_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.promote_user_to_admin(_app_user_id text) TO app_usr;


--
-- Name: FUNCTION promote_user_to_app_tenant_group_admin(_app_user_id text, _app_tenant_group_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.promote_user_to_app_tenant_group_admin(_app_user_id text, _app_tenant_group_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.promote_user_to_app_tenant_group_admin(_app_user_id text, _app_tenant_group_id text) TO app_usr;


--
-- Name: FUNCTION promote_user_to_demo_admin(_app_user_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.promote_user_to_demo_admin(_app_user_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.promote_user_to_demo_admin(_app_user_id text) TO app_usr;


--
-- Name: FUNCTION provision_tenant_license(_license_type_key text, _app_tenant_id text, _assigned_to_app_user_id text, _subscription_id text, _expiration_date date); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.provision_tenant_license(_license_type_key text, _app_tenant_id text, _assigned_to_app_user_id text, _subscription_id text, _expiration_date date) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.provision_tenant_license(_license_type_key text, _app_tenant_id text, _assigned_to_app_user_id text, _subscription_id text, _expiration_date date) TO app_usr;


--
-- Name: FUNCTION publish_license_pack(_id text, _discontinue_existing boolean); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.publish_license_pack(_id text, _discontinue_existing boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.publish_license_pack(_id text, _discontinue_existing boolean) TO app_usr;


--
-- Name: FUNCTION purge_app_tenant_subscription(_app_tenant_subscription_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.purge_app_tenant_subscription(_app_tenant_subscription_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.purge_app_tenant_subscription(_app_tenant_subscription_id text) TO app_usr;


--
-- Name: FUNCTION raise_exception(_msg text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.raise_exception(_msg text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.raise_exception(_msg text) TO app_usr;


--
-- Name: FUNCTION rando(); Type: ACL; Schema: app_fn; Owner: postgres
--

GRANT ALL ON FUNCTION app_fn.rando() TO app_usr;


--
-- Name: FUNCTION reactivate_app_user(_app_user_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.reactivate_app_user(_app_user_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.reactivate_app_user(_app_user_id text) TO app_usr;


--
-- Name: FUNCTION remove_app_tenant(_app_tenant_id text, _confirmation_code text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.remove_app_tenant(_app_tenant_id text, _confirmation_code text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.remove_app_tenant(_app_tenant_id text, _confirmation_code text) TO app_usr;


--
-- Name: FUNCTION remove_app_tenant_group_member(_app_tenant_group_id text, _app_tenant_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.remove_app_tenant_group_member(_app_tenant_group_id text, _app_tenant_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.remove_app_tenant_group_member(_app_tenant_group_id text, _app_tenant_id text) TO app_usr;


--
-- Name: FUNCTION remove_app_user(_app_user_id text, _confirmation_code text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.remove_app_user(_app_user_id text, _confirmation_code text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.remove_app_user(_app_user_id text, _confirmation_code text) TO app_usr;


--
-- Name: FUNCTION remove_license_pack_license_type(_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.remove_license_pack_license_type(_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.remove_license_pack_license_type(_id text) TO app_usr;


--
-- Name: FUNCTION renew_app_user_license(_app_user_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.renew_app_user_license(_app_user_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.renew_app_user_license(_app_user_id text) TO app_usr;


--
-- Name: FUNCTION reset_demo_data(_app_tenant_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.reset_demo_data(_app_tenant_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.reset_demo_data(_app_tenant_id text) TO app_usr;


--
-- Name: TABLE eula; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.eula TO app_usr;


--
-- Name: FUNCTION set_app_eula(_content text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.set_app_eula(_content text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.set_app_eula(_content text) TO app_usr;


--
-- Name: FUNCTION set_user_ext_auth_id(_recovery_email text, _ext_auth_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.set_user_ext_auth_id(_recovery_email text, _ext_auth_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.set_user_ext_auth_id(_recovery_email text, _ext_auth_id text) TO app_usr;


--
-- Name: TABLE signed_eula; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.signed_eula TO app_usr;


--
-- Name: FUNCTION sign_current_eula(_eula_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.sign_current_eula(_eula_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.sign_current_eula(_eula_id text) TO app_usr;


--
-- Name: FUNCTION subscribe_to_license_pack_existing_tenant(_license_pack_key text, _existing_tenant_id text, _force_subscribe boolean); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.subscribe_to_license_pack_existing_tenant(_license_pack_key text, _existing_tenant_id text, _force_subscribe boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.subscribe_to_license_pack_existing_tenant(_license_pack_key text, _existing_tenant_id text, _force_subscribe boolean) TO app_usr;


--
-- Name: FUNCTION subscribe_to_license_pack_new_tenant(_license_pack_key text, _new_tenant_info app_fn.new_app_tenant_info, _allow_discontinued boolean); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.subscribe_to_license_pack_new_tenant(_license_pack_key text, _new_tenant_info app_fn.new_app_tenant_info, _allow_discontinued boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.subscribe_to_license_pack_new_tenant(_license_pack_key text, _new_tenant_info app_fn.new_app_tenant_info, _allow_discontinued boolean) TO app_usr;


--
-- Name: FUNCTION support_email(); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.support_email() FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.support_email() TO app_usr;


--
-- Name: FUNCTION supportable_app_tenants(_app_tenant_group_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.supportable_app_tenants(_app_tenant_group_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.supportable_app_tenants(_app_tenant_group_id text) TO app_usr;


--
-- Name: FUNCTION unvoid_licenses(_license_ids text[]); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.unvoid_licenses(_license_ids text[]) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.unvoid_licenses(_license_ids text[]) TO app_usr;


--
-- Name: FUNCTION update_app_tenant_name(_app_tenant_id text, _name text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.update_app_tenant_name(_app_tenant_id text, _name text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.update_app_tenant_name(_app_tenant_id text, _name text) TO app_usr;


--
-- Name: FUNCTION update_app_tenant_setting(_key text, _value text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.update_app_tenant_setting(_key text, _value text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.update_app_tenant_setting(_key text, _value text) TO app_usr;


--
-- Name: FUNCTION update_app_user_preferred_language(_app_user_id text, _language_id text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.update_app_user_preferred_language(_app_user_id text, _language_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.update_app_user_preferred_language(_app_user_id text, _language_id text) TO app_usr;


--
-- Name: FUNCTION update_contact_info(_contact_id text, _contact_info app_fn.update_contact_info_input); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.update_contact_info(_contact_id text, _contact_info app_fn.update_contact_info_input) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.update_contact_info(_contact_id text, _contact_info app_fn.update_contact_info_input) TO app_usr;


--
-- Name: FUNCTION update_license_expiration(_license_id text, _expiration_date date); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.update_license_expiration(_license_id text, _expiration_date date) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.update_license_expiration(_license_id text, _expiration_date date) TO app_usr;


--
-- Name: TABLE app_route; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.app_route TO app_usr;


--
-- Name: FUNCTION upsert_app_route(_app_route_info app_fn.app_route_info); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.upsert_app_route(_app_route_info app_fn.app_route_info) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.upsert_app_route(_app_route_info app_fn.app_route_info) TO app_usr;


--
-- Name: TABLE app_tenant_group; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.app_tenant_group TO app_usr;


--
-- Name: FUNCTION upsert_app_tenant_group(_app_tenant_group_info app_fn.app_tenant_group_info); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.upsert_app_tenant_group(_app_tenant_group_info app_fn.app_tenant_group_info) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.upsert_app_tenant_group(_app_tenant_group_info app_fn.app_tenant_group_info) TO app_usr;


--
-- Name: FUNCTION upsert_license_pack(_license_pack_info app_fn.license_pack_info); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.upsert_license_pack(_license_pack_info app_fn.license_pack_info) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.upsert_license_pack(_license_pack_info app_fn.license_pack_info) TO app_usr;


--
-- Name: FUNCTION void_licenses(_license_type_key text, _app_tenant_subscription_id text, _reason app.license_status_reason, _number_to_void integer); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.void_licenses(_license_type_key text, _app_tenant_subscription_id text, _reason app.license_status_reason, _number_to_void integer) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.void_licenses(_license_type_key text, _app_tenant_subscription_id text, _reason app.license_status_reason, _number_to_void integer) TO app_usr;


--
-- Name: FUNCTION do_housekeeping_tasks(_app_user_id text); Type: ACL; Schema: app_fn_private; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn_private.do_housekeeping_tasks(_app_user_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn_private.do_housekeeping_tasks(_app_user_id text) TO app_usr;


--
-- Name: FUNCTION do_sign_current_eula(_eula_id text, _app_tenant_id text, _app_user_id text); Type: ACL; Schema: app_fn_private; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn_private.do_sign_current_eula(_eula_id text, _app_tenant_id text, _app_user_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn_private.do_sign_current_eula(_eula_id text, _app_tenant_id text, _app_user_id text) TO app_usr;


--
-- Name: FUNCTION authenticate_bootstrap(_username text); Type: ACL; Schema: auth_bootstrap; Owner: postgres
--

GRANT ALL ON FUNCTION auth_bootstrap.authenticate_bootstrap(_username text) TO app_anon;


--
-- Name: FUNCTION app_user_has_access(_app_tenant_id text); Type: ACL; Schema: auth_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION auth_fn.app_user_has_access(_app_tenant_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.app_user_has_access(_app_tenant_id text) TO app_usr;


--
-- Name: FUNCTION app_user_has_game_library(_game_id text); Type: ACL; Schema: auth_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION auth_fn.app_user_has_game_library(_game_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.app_user_has_game_library(_game_id text) TO app_usr;


--
-- Name: FUNCTION app_user_has_library(_library_id text); Type: ACL; Schema: auth_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION auth_fn.app_user_has_library(_library_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.app_user_has_library(_library_id text) TO app_usr;


--
-- Name: FUNCTION app_user_has_licensing_scope(_app_tenant_id text); Type: ACL; Schema: auth_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION auth_fn.app_user_has_licensing_scope(_app_tenant_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.app_user_has_licensing_scope(_app_tenant_id text) TO app_usr;


--
-- Name: FUNCTION app_user_has_permission(_permission text); Type: ACL; Schema: auth_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION auth_fn.app_user_has_permission(_permission text) FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.app_user_has_permission(_permission text) TO app_usr;


--
-- Name: FUNCTION app_user_has_permission_key(_permission_key app.permission_key); Type: ACL; Schema: auth_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION auth_fn.app_user_has_permission_key(_permission_key app.permission_key) FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.app_user_has_permission_key(_permission_key app.permission_key) TO app_usr;


--
-- Name: FUNCTION auth_0_pre_registration(_email text); Type: ACL; Schema: auth_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION auth_fn.auth_0_pre_registration(_email text) FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.auth_0_pre_registration(_email text) TO app_usr;


--
-- Name: FUNCTION current_app_user(); Type: ACL; Schema: auth_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION auth_fn.current_app_user() FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.current_app_user() TO app_usr;


--
-- Name: FUNCTION current_app_user_id(); Type: ACL; Schema: auth_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION auth_fn.current_app_user_id() FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.current_app_user_id() TO app_usr;


--
-- Name: FUNCTION get_app_tenant_scope_permissions(_app_tenant_id text); Type: ACL; Schema: auth_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION auth_fn.get_app_tenant_scope_permissions(_app_tenant_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.get_app_tenant_scope_permissions(_app_tenant_id text) TO app_usr;


--
-- Name: FUNCTION get_app_user_info(_recovery_email_or_id_or_username text, _current_app_tenant_id text); Type: ACL; Schema: auth_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION auth_fn.get_app_user_info(_recovery_email_or_id_or_username text, _current_app_tenant_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.get_app_user_info(_recovery_email_or_id_or_username text, _current_app_tenant_id text) TO app_usr;


--
-- Name: FUNCTION init_app_tenant_support(_app_tenant_id text); Type: ACL; Schema: auth_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION auth_fn.init_app_tenant_support(_app_tenant_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.init_app_tenant_support(_app_tenant_id text) TO app_usr;


--
-- Name: FUNCTION init_demo(_license_pack_key text); Type: ACL; Schema: auth_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION auth_fn.init_demo(_license_pack_key text) FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.init_demo(_license_pack_key text) TO app_usr;


--
-- Name: FUNCTION init_subsidiary_admin(_subsidiary_app_tenant_id text); Type: ACL; Schema: auth_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION auth_fn.init_subsidiary_admin(_subsidiary_app_tenant_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.init_subsidiary_admin(_subsidiary_app_tenant_id text) TO app_usr;


--
-- Name: FUNCTION do_get_app_user_info(_recovery_email_or_id_or_username text, _current_app_tenant_id text); Type: ACL; Schema: auth_fn_private; Owner: postgres
--

REVOKE ALL ON FUNCTION auth_fn_private.do_get_app_user_info(_recovery_email_or_id_or_username text, _current_app_tenant_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn_private.do_get_app_user_info(_recovery_email_or_id_or_username text, _current_app_tenant_id text) TO app_usr;


--
-- Name: TABLE app_exception; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.app_exception TO app_usr;


--
-- Name: TABLE app_tenant_group_admin; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.app_tenant_group_admin TO app_usr;


--
-- Name: TABLE facility; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.facility TO app_usr;


--
-- Name: TABLE license_permission; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.license_permission TO app_usr;


--
-- Name: TABLE location; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.location TO app_usr;


--
-- Name: TABLE note; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.note TO app_usr;


--
-- Name: TABLE organization; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.organization TO app_usr;


--
-- Name: TABLE registration; Type: ACL; Schema: app; Owner: postgres
--

GRANT ALL ON TABLE app.registration TO app_usr;


--
-- Name: postgraphile_watch_ddl; Type: EVENT TRIGGER; Schema: -; Owner: postgres
--

CREATE EVENT TRIGGER postgraphile_watch_ddl ON ddl_command_end
         WHEN TAG IN ('ALTER AGGREGATE', 'ALTER DOMAIN', 'ALTER EXTENSION', 'ALTER FOREIGN TABLE', 'ALTER FUNCTION', 'ALTER POLICY', 'ALTER SCHEMA', 'ALTER TABLE', 'ALTER TYPE', 'ALTER VIEW', 'COMMENT', 'CREATE AGGREGATE', 'CREATE DOMAIN', 'CREATE EXTENSION', 'CREATE FOREIGN TABLE', 'CREATE FUNCTION', 'CREATE INDEX', 'CREATE POLICY', 'CREATE RULE', 'CREATE SCHEMA', 'CREATE TABLE', 'CREATE TABLE AS', 'CREATE VIEW', 'DROP AGGREGATE', 'DROP DOMAIN', 'DROP EXTENSION', 'DROP FOREIGN TABLE', 'DROP FUNCTION', 'DROP INDEX', 'DROP OWNED', 'DROP POLICY', 'DROP RULE', 'DROP SCHEMA', 'DROP TABLE', 'DROP TYPE', 'DROP VIEW', 'GRANT', 'REVOKE', 'SELECT INTO')
   EXECUTE FUNCTION postgraphile_watch.notify_watchers_ddl();


ALTER EVENT TRIGGER postgraphile_watch_ddl OWNER TO postgres;

--
-- Name: postgraphile_watch_drop; Type: EVENT TRIGGER; Schema: -; Owner: postgres
--

CREATE EVENT TRIGGER postgraphile_watch_drop ON sql_drop
   EXECUTE FUNCTION postgraphile_watch.notify_watchers_drop();


ALTER EVENT TRIGGER postgraphile_watch_drop OWNER TO postgres;

--
-- PostgreSQL database dump complete
--

