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
-- Name: appc; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA appc;


ALTER SCHEMA appc OWNER TO postgres;

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
-- Name: bill; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA bill;


ALTER SCHEMA bill OWNER TO postgres;

--
-- Name: bill_fn; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA bill_fn;


ALTER SCHEMA bill_fn OWNER TO postgres;

--
-- Name: bill_fn_private; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA bill_fn_private;


ALTER SCHEMA bill_fn_private OWNER TO postgres;

--
-- Name: dng; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA dng;


ALTER SCHEMA dng OWNER TO postgres;

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
-- Name: prj; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA prj;


ALTER SCHEMA prj OWNER TO postgres;

--
-- Name: prj_fn; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA prj_fn;


ALTER SCHEMA prj_fn OWNER TO postgres;

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
-- Name: payment_method_status; Type: TYPE; Schema: bill; Owner: postgres
--

CREATE TYPE bill.payment_method_status AS ENUM (
    'active',
    'inactive',
    'expired',
    'invalid'
);


ALTER TYPE bill.payment_method_status OWNER TO postgres;

--
-- Name: payment_status; Type: TYPE; Schema: bill; Owner: postgres
--

CREATE TYPE bill.payment_status AS ENUM (
    'scheduled',
    'received',
    'canceled',
    'pastdue',
    'rejected',
    'gifted',
    'refunded',
    'void'
);


ALTER TYPE bill.payment_status OWNER TO postgres;

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
-- Name: payment; Type: TABLE; Schema: bill; Owner: postgres
--

CREATE TABLE bill.payment (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    billing_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    payment_date date,
    canceled_date date,
    payment_method_id text,
    amount numeric(8,2) DEFAULT 0 NOT NULL,
    status bill.payment_status DEFAULT 'scheduled'::bill.payment_status NOT NULL,
    app_tenant_subscription_id text NOT NULL
);


ALTER TABLE bill.payment OWNER TO postgres;

--
-- Name: payment_method; Type: TABLE; Schema: bill; Owner: postgres
--

CREATE TABLE bill.payment_method (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    identifier text NOT NULL,
    name text,
    external_identifier text NOT NULL,
    status bill.payment_method_status DEFAULT 'active'::bill.payment_method_status NOT NULL,
    expiration_date date NOT NULL
);


ALTER TABLE bill.payment_method OWNER TO postgres;

--
-- Name: app_tenant_payment_status_summary_result; Type: TYPE; Schema: app; Owner: postgres
--

CREATE TYPE app.app_tenant_payment_status_summary_result AS (
	status app.app_tenant_payment_status,
	pastdue_payments bill.payment[],
	scheduled_payments bill.payment[],
	active_payment_method bill.payment_method
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
-- Name: content_entity_type; Type: TYPE; Schema: appc; Owner: postgres
--

CREATE TYPE appc.content_entity_type AS ENUM (
    'approute',
    'licensepack',
    'therapycategory',
    'library',
    'cognitivedomain',
    'game',
    'wemove',
    'worksheet'
);


ALTER TYPE appc.content_entity_type OWNER TO postgres;

--
-- Name: content_slug_type; Type: TYPE; Schema: appc; Owner: postgres
--

CREATE TYPE appc.content_slug_type AS ENUM (
    'slug',
    'image',
    'imageset',
    'attachment'
);


ALTER TYPE appc.content_slug_type OWNER TO postgres;

--
-- Name: content_slug_info; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.content_slug_info AS (
	entity_type appc.content_entity_type,
	entity_identifier text,
	key text,
	description text,
	content text,
	data jsonb,
	type appc.content_slug_type
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
-- Name: uow_status_type; Type: TYPE; Schema: prj; Owner: postgres
--

CREATE TYPE prj.uow_status_type AS ENUM (
    'incomplete',
    'paused',
    'waiting',
    'complete',
    'canceled',
    'deleted',
    'error',
    'template'
);


ALTER TYPE prj.uow_status_type OWNER TO postgres;

--
-- Name: uow_type; Type: TYPE; Schema: prj; Owner: postgres
--

CREATE TYPE prj.uow_type AS ENUM (
    'project',
    'milestone',
    'task',
    'issue'
);


ALTER TYPE prj.uow_type OWNER TO postgres;

--
-- Name: uow; Type: TABLE; Schema: prj; Owner: postgres
--

CREATE TABLE prj.uow (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    project_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    app_tenant_id text NOT NULL,
    identifier text,
    is_template boolean DEFAULT false NOT NULL,
    name text,
    description text,
    type prj.uow_type,
    data jsonb,
    parent_uow_id text,
    status prj.uow_status_type DEFAULT 'incomplete'::prj.uow_status_type NOT NULL,
    assigned_to_contact_project_role_id text,
    due_at timestamp with time zone,
    completed_at timestamp with time zone,
    workflow_handler_key text,
    use_worker boolean DEFAULT false NOT NULL,
    workflow_error jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE prj.uow OWNER TO postgres;

--
-- Name: auth0_workflow_request; Type: TYPE; Schema: app_fn; Owner: postgres
--

CREATE TYPE app_fn.auth0_workflow_request AS (
	uows_to_schedule prj.uow[],
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
-- Name: payment_method_type; Type: TYPE; Schema: bill; Owner: postgres
--

CREATE TYPE bill.payment_method_type AS ENUM (
    'credit_card'
);


ALTER TYPE bill.payment_method_type OWNER TO postgres;

--
-- Name: payment_method_info; Type: TYPE; Schema: bill_fn; Owner: postgres
--

CREATE TYPE bill_fn.payment_method_info AS (
	identifier text,
	external_identifier text,
	name text,
	expiration_date date,
	account_number text,
	security_code text,
	zip_code text
);


ALTER TYPE bill_fn.payment_method_info OWNER TO postgres;

--
-- Name: analysis_method; Type: TYPE; Schema: dng; Owner: postgres
--

CREATE TYPE dng.analysis_method AS ENUM (
    'sbuh_method',
    'fixed_flow',
    'rational'
);


ALTER TYPE dng.analysis_method OWNER TO postgres;

--
-- Name: flow_type; Type: TYPE; Schema: dng; Owner: postgres
--

CREATE TYPE dng.flow_type AS ENUM (
    'sheet',
    'shallow',
    'channel',
    'fixed'
);


ALTER TYPE dng.flow_type OWNER TO postgres;

--
-- Name: rainfall_type; Type: TYPE; Schema: dng; Owner: postgres
--

CREATE TYPE dng.rainfall_type AS ENUM (
    'type_1',
    'type_1_a',
    'type_2',
    'type_3'
);


ALTER TYPE dng.rainfall_type OWNER TO postgres;

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
-- Name: clone_project_template_options; Type: TYPE; Schema: prj_fn; Owner: postgres
--

CREATE TYPE prj_fn.clone_project_template_options AS (
	data jsonb
);


ALTER TYPE prj_fn.clone_project_template_options OWNER TO postgres;

--
-- Name: clone_uow_template_options; Type: TYPE; Schema: prj_fn; Owner: postgres
--

CREATE TYPE prj_fn.clone_uow_template_options AS (
	data json
);


ALTER TYPE prj_fn.clone_uow_template_options OWNER TO postgres;

--
-- Name: complete_uow_options; Type: TYPE; Schema: prj_fn; Owner: postgres
--

CREATE TYPE prj_fn.complete_uow_options AS (
	workflow_data jsonb,
	step_data jsonb
);


ALTER TYPE prj_fn.complete_uow_options OWNER TO postgres;

--
-- Name: complete_uow_result; Type: TYPE; Schema: prj_fn; Owner: postgres
--

CREATE TYPE prj_fn.complete_uow_result AS (
	uow prj.uow,
	uows_to_schedule prj.uow[]
);


ALTER TYPE prj_fn.complete_uow_result OWNER TO postgres;

--
-- Name: uow_dependency_info; Type: TYPE; Schema: prj_fn; Owner: postgres
--

CREATE TYPE prj_fn.uow_dependency_info AS (
	depender_identifier text,
	dependee_identifier text
);


ALTER TYPE prj_fn.uow_dependency_info OWNER TO postgres;

--
-- Name: uow_info; Type: TYPE; Schema: prj_fn; Owner: postgres
--

CREATE TYPE prj_fn.uow_info AS (
	id text,
	identifier text,
	name text,
	is_template boolean,
	description text,
	type prj.uow_type,
	data jsonb,
	project_id text,
	parent_uow_id text,
	due_at timestamp with time zone,
	workflow_handler_key text,
	use_worker boolean
);


ALTER TYPE prj_fn.uow_info OWNER TO postgres;

--
-- Name: project_info; Type: TYPE; Schema: prj_fn; Owner: postgres
--

CREATE TYPE prj_fn.project_info AS (
	id text,
	identifier text,
	type text,
	name text,
	is_template boolean,
	uows prj_fn.uow_info[],
	uow_dependencies prj_fn.uow_dependency_info[],
	on_completed_workflow_handler_key text,
	workflow_input_definition jsonb
);


ALTER TYPE prj_fn.project_info OWNER TO postgres;

--
-- Name: project; Type: TABLE; Schema: prj; Owner: postgres
--

CREATE TABLE prj.project (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    uow_id text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    identifier text,
    app_tenant_id text NOT NULL,
    name text,
    type text NOT NULL,
    is_template boolean DEFAULT false NOT NULL,
    managed_by_contact_project_role_id text,
    workflow_data jsonb DEFAULT '{}'::jsonb NOT NULL,
    workflow_input_definition jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE prj.project OWNER TO postgres;

--
-- Name: queue_workflow_result; Type: TYPE; Schema: prj_fn; Owner: postgres
--

CREATE TYPE prj_fn.queue_workflow_result AS (
	project prj.project,
	uows_to_schedule prj.uow[]
);


ALTER TYPE prj_fn.queue_workflow_result OWNER TO postgres;

--
-- Name: search_projects_options; Type: TYPE; Schema: prj_fn; Owner: postgres
--

CREATE TYPE prj_fn.search_projects_options AS (
	project_type text,
	is_template boolean,
	search_terms text[],
	date_range_start date,
	date_range_end date,
	app_user_id text,
	app_tenant_id text,
	project_uow_status prj.uow_status_type,
	result_limit integer
);


ALTER TYPE prj_fn.search_projects_options OWNER TO postgres;

--
-- Name: update_uow_status_options; Type: TYPE; Schema: prj_fn; Owner: postgres
--

CREATE TYPE prj_fn.update_uow_status_options AS (
	data jsonb,
	error_info jsonb
);


ALTER TYPE prj_fn.update_uow_status_options OWNER TO postgres;

--
-- Name: update_uow_status_result; Type: TYPE; Schema: prj_fn; Owner: postgres
--

CREATE TYPE prj_fn.update_uow_status_result AS (
	uow prj.uow,
	uows_to_schedule prj.uow[]
);


ALTER TYPE prj_fn.update_uow_status_result OWNER TO postgres;

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
-- Name: content_slug; Type: TABLE; Schema: appc; Owner: postgres
--

CREATE TABLE appc.content_slug (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    type appc.content_slug_type DEFAULT 'slug'::appc.content_slug_type NOT NULL,
    entity_type appc.content_entity_type NOT NULL,
    entity_identifier text NOT NULL,
    key text NOT NULL,
    description text,
    content text NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE appc.content_slug OWNER TO postgres;

--
-- Name: set_content_slug_current_version_set(text, text); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.set_content_slug_current_version_set(_content_slug_id text, _version_identifier text) RETURNS appc.content_slug
    LANGUAGE plpgsql
    AS $$
    DECLARE
      _content_slug appc.content_slug;
      _version_set jsonb;
      _current_version_set jsonb;
      _previous_version_sets jsonb[];
      _data jsonb;
      _err_context text;
    BEGIN

      select *
      into _content_slug
      from appc.content_slug
      where id = _content_slug_id
      ;

      if _content_slug.id is null then
        raise exception 'no content slug for id: %', _content_slug_id;
      end if;

      _data := _content_slug.data;
      if (_data->'currentVersionSet')->>'versionIdentifier' = _version_identifier then
        raise notice 'poop: %', _version_identifier;
        return _content_slug;
      end if;

      _current_version_set := null;
      _previous_version_sets := '{}'::jsonb[];
      _previous_version_sets := array_append(_previous_version_sets, _data->'currentVersionSet');
      for _version_set in (select jsonb_array_elements(_data->'previousVersionSets'))
      loop
          raise notice 'version set: %', _version_set->'versionIdentifier';
          if _version_set->>'versionIdentifier' = _version_identifier then
          -- _version_set is the new current
            _current_version_set := _version_set;
          else
          -- add _version_set to the new previous
            _previous_version_sets := array_append(_previous_version_sets, _version_set);
          end if;
      end loop;

      if _current_version_set is null then
        raise exception 'no version set for identifier: %', _version_identifier;
      end if;

      _data := _data || jsonb_build_object('currentVersionSet', _current_version_set);
      _data := _data || jsonb_build_object('previousVersionSets', _previous_version_sets);

      update appc.content_slug set
        data = _data
      where id = _content_slug_id
      returning *
      into _content_slug;


      return _content_slug;
      exception
        when others then
          GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
          if position('FB' in SQLSTATE::text) = 0 then
            _err_context := 'app_fn.set_content_slug_current_version_set:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
            raise exception '%', _err_context using errcode = 'FB500';
          end if;
          raise;
    end;
    $$;


ALTER FUNCTION app_fn.set_content_slug_current_version_set(_content_slug_id text, _version_identifier text) OWNER TO postgres;

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
-- Name: upsert_content_slug(app_fn.content_slug_info); Type: FUNCTION; Schema: app_fn; Owner: postgres
--

CREATE FUNCTION app_fn.upsert_content_slug(_content_slug_info app_fn.content_slug_info) RETURNS appc.content_slug
    LANGUAGE plpgsql
    AS $$
    DECLARE
      _content_slug appc.content_slug;
      _err_context text;
    BEGIN
      insert into appc.content_slug(
        entity_type
        ,entity_identifier
        ,key
        ,description
        ,content
        ,data
        ,type
      )
      select
        _content_slug_info.entity_type
        ,_content_slug_info.entity_identifier
        ,_content_slug_info.key
        ,_content_slug_info.description
        ,coalesce(_content_slug_info.content, 'DATA')
        ,coalesce(_content_slug_info.data, '{}')
        ,coalesce(_content_slug_info.type, 'slug')
      on conflict (entity_type, entity_identifier, key)
      do update set
        description = _content_slug_info.description
        ,content = coalesce(_content_slug_info.content, 'DATA')
        ,data = coalesce(_content_slug_info.data, '{}')
      returning *
      into _content_slug
      ;

      return _content_slug;
      exception
        when others then
          GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
          if position('FB' in SQLSTATE::text) = 0 then
            _err_context := 'app_fn.upsert_content_slug:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
            raise exception '%', _err_context using errcode = 'FB500';
          end if;
          raise;
    end;
    $$;


ALTER FUNCTION app_fn.upsert_content_slug(_content_slug_info app_fn.content_slug_info) OWNER TO postgres;

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
-- Name: create_payment_method(bill_fn.payment_method_info); Type: FUNCTION; Schema: bill_fn; Owner: postgres
--

CREATE FUNCTION bill_fn.create_payment_method(_payment_method_info bill_fn.payment_method_info) RETURNS bill.payment_method
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _payment_method bill.payment_method;
    _err_context text;
  BEGIN
    select * into _payment_method from bill.payment_method where id = _payment_method_info.identifier;

    if _payment_method.id is not null then
      return _payment_method;
    else
      insert into bill.payment_method(
        app_tenant_id
        ,name
        ,identifier
        ,external_identifier
        ,status
        ,expiration_date
      )
      select
        auth_fn.current_app_user()->>'app_tenant_id'
        ,_payment_method_info.name
        ,_payment_method_info.identifier
        ,_payment_method_info.external_identifier
        ,'active'
        ,_payment_method_info.expiration_date
      returning *
      into _payment_method
      ;
    end if;

    return _payment_method;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'bill_fn.create_payment_method:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION bill_fn.create_payment_method(_payment_method_info bill_fn.payment_method_info) OWNER TO postgres;

--
-- Name: deactivate_payment_method(text); Type: FUNCTION; Schema: bill_fn; Owner: postgres
--

CREATE FUNCTION bill_fn.deactivate_payment_method(_id text) RETURNS bill.payment_method
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _payment_method bill.payment_method;
    _err_context text;
  BEGIN
    update bill.payment_method set
      status = 'deactivated'
    where id = _id
    returning *
    into _payment_method
    ;

    return _payment_method;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'bill_fn.deactivate_payment_method:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION bill_fn.deactivate_payment_method(_id text) OWNER TO postgres;

--
-- Name: reconcile_all_tenant_billing_events(); Type: FUNCTION; Schema: bill_fn; Owner: postgres
--

CREATE FUNCTION bill_fn.reconcile_all_tenant_billing_events() RETURNS SETOF app.app_tenant
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _err_context text;
    _record record;
    _payment bill.payment;
  BEGIN

    -- perform bill_fn_private.reconcile_billing_events(id) from app.app_tenant;

    return query
    select apt.*
    from app.app_tenant apt
    join app.app_tenant_subscription ats on ats.id = apt.anchor_subscription_id
    where apt.type = 'customer'
    and ats.inactive = false
    order by apt.name
    ;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'bill_fn.reconcile_all_tenant_billing_events:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
    END
  $$;


ALTER FUNCTION bill_fn.reconcile_all_tenant_billing_events() OWNER TO postgres;

--
-- Name: reconcile_billing_events(); Type: FUNCTION; Schema: bill_fn; Owner: postgres
--

CREATE FUNCTION bill_fn.reconcile_billing_events() RETURNS SETOF bill.payment
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _err_context text;
    _record record;
    _payment bill.payment;
  BEGIN
    perform bill_fn_private.reconcile_billing_events(auth_fn.current_app_user()->>'app_tenant_id');

    return query
    select *
    from bill.payment
    where app_tenant_id = auth_fn.current_app_user()->>'app_tenant_id'
    order by billing_date
    ;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'bill_fn.reconcile_billing_events:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
    END
  $$;


ALTER FUNCTION bill_fn.reconcile_billing_events() OWNER TO postgres;

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
-- Name: send_billing_message(text, text[]); Type: FUNCTION; Schema: bill_fn; Owner: postgres
--

CREATE FUNCTION bill_fn.send_billing_message(_content text, _tags text[] DEFAULT '{}'::text[]) RETURNS msg.message
    LANGUAGE plpgsql
    AS $$
    DECLARE
      _topic msg.topic;
      _message msg.message;
      _err_context text;
    BEGIN
      select * into _topic from msg.topic where id = (select billing_topic_id from app.app_tenant where id = auth_fn.current_app_user()->>'app_tenant_id');
      if _topic.id is null then
        _topic := (select msg_fn.upsert_topic(
          row(
            null
            ,(select name || ' Billing' from app.app_tenant where id = auth_fn.current_app_user()->>'app_tenant_id')
            ,(select 'billing-' || id from app.app_tenant where id = auth_fn.current_app_user()->>'app_tenant_id')
          )
        ));
        update app.app_tenant set billing_topic_id = _topic.id where id = auth_fn.current_app_user()->>'app_tenant_id';
      end if;

      _message := msg_fn.upsert_message(
        row(
          null
          ,_topic.id::text
          ,_content::text
          ,coalesce(_tags, '{}'::text[])
        )
      );

      return _message;
      exception
        when others then
          GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
          if position('FB' in SQLSTATE::text) = 0 then
            _err_context := 'bill_fn.send_billing_message:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
            raise exception '%', _err_context using errcode = 'FB500';
          end if;
          raise;
    end;
    $$;


ALTER FUNCTION bill_fn.send_billing_message(_content text, _tags text[]) OWNER TO postgres;

--
-- Name: update_payment_status(text, bill.payment_status); Type: FUNCTION; Schema: bill_fn; Owner: postgres
--

CREATE FUNCTION bill_fn.update_payment_status(_payment_id text, _payment_status bill.payment_status) RETURNS bill.payment
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _err_context text;
    _payment bill.payment;
  BEGIN
    select * into _payment from bill.payment where id = _payment_id;

    if _payment.id is null then
      raise exception 'no payment for id: %', _payment;
    end if;
    update bill.payment set status = _payment_status where id = _payment_id returning * into _payment;

    return _payment;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'bill_fn.update_payment_status:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
    END
  $$;


ALTER FUNCTION bill_fn.update_payment_status(_payment_id text, _payment_status bill.payment_status) OWNER TO postgres;

--
-- Name: reconcile_billing_events(text); Type: FUNCTION; Schema: bill_fn_private; Owner: postgres
--

CREATE FUNCTION bill_fn_private.reconcile_billing_events(_app_tenant_id text) RETURNS SETOF bill.payment
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _err_context text;
    _record record;
    _payment bill.payment;
    _topic msg.topic;
  BEGIN

    for _record in
      with subscriptions as (
        select ats.*
        ,lp.renewal_frequency
        ,lp.price
        ,date_part('day', ats.created_date) created_day
        ,date_part('day', current_date) today_day
        ,date_trunc('month', current_date) today_month
        from app.app_tenant_subscription ats
        join app.license_pack lp on ats.license_pack_id = lp.id
        where ats.app_tenant_id = _app_tenant_id
        and ats.inactive = false
        and lp.price > 0
      )
      ,billing_intervals as (
        select
          s.*
          ,case
              when
                s.renewal_frequency = 'weekly' then '1 week':: interval
              when
                s.renewal_frequency = 'monthly' then '1 month':: interval
              when
                s.renewal_frequency = 'quarterly' then '3 months':: interval
              when
                s.renewal_frequency = 'yearly' then '1 year':: interval
              else
                '0 days'::interval
            end as billing_interval
          from subscriptions s
      )
      ,all_billing_dates as (
        select
          s.*
          ,generate_series(
            s.created_date
            ,(current_date + s.billing_interval)
            ,s.billing_interval
          ) billing_date
        from billing_intervals s
        order by billing_date
      )
      select
        abd.id::text app_tenant_subscription_id
        ,abd.*
      from all_billing_dates abd
    loop

      insert into bill.payment(
        app_tenant_id
        ,app_tenant_subscription_id
        ,billing_date
        ,payment_method_id
        ,status
        ,amount
      )
      select
        _app_tenant_id
        ,_record.app_tenant_subscription_id
        ,_record.billing_date::date
        ,(select id from bill.payment_method where app_tenant_id = _app_tenant_id and status = 'active')
        ,case when _record.billing_date >= current_date then 'scheduled'::bill.payment_status else 'pastdue'::bill.payment_status end
        ,_record.price
      on conflict (app_tenant_subscription_id, billing_date) do update set app_tenant_id = _app_tenant_id
      returning * into _payment
      ;

      return next _payment;
    end loop;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'bill_fn_private.reconcile_billing_events:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
    END
  $$;


ALTER FUNCTION bill_fn_private.reconcile_billing_events(_app_tenant_id text) OWNER TO postgres;

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
-- Name: create_email_request(msg_fn.email_request_info, text, text); Type: FUNCTION; Schema: msg_fn; Owner: postgres
--

CREATE FUNCTION msg_fn.create_email_request(_email_request_info msg_fn.email_request_info, _app_tenant_id text, _app_user_id text) RETURNS msg.email_request
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _email_request msg.email_request;
    _err_context text;
  BEGIN

    insert into msg.email_request(
      app_tenant_id
      ,sent_by_app_user_id
      ,status
      ,subject
      ,content
      ,from_address
      ,to_addresses
      ,cc_addresses
      ,bcc_addresses
    )
    select
      _app_tenant_id
      ,_app_user_id
      ,'requested'
      ,_email_request_info.subject
      ,_email_request_info.content
      ,_email_request_info.from_address
      ,_email_request_info.to_addresses
      ,_email_request_info.cc_addresses
      ,_email_request_info.bcc_addresses
    returning * into _email_request;

    return _email_request;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'msg_fn.create_email_request:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION msg_fn.create_email_request(_email_request_info msg_fn.email_request_info, _app_tenant_id text, _app_user_id text) OWNER TO postgres;

--
-- Name: FUNCTION create_email_request(_email_request_info msg_fn.email_request_info, _app_tenant_id text, _app_user_id text); Type: COMMENT; Schema: msg_fn; Owner: postgres
--

COMMENT ON FUNCTION msg_fn.create_email_request(_email_request_info msg_fn.email_request_info, _app_tenant_id text, _app_user_id text) IS '@OMIT';


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
-- Name: send_email(msg_fn.email_request_info); Type: FUNCTION; Schema: msg_fn; Owner: postgres
--

CREATE FUNCTION msg_fn.send_email(_email_request_info msg_fn.email_request_info) RETURNS msg.email_request
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _email_request msg.email_request;
    _err_context text;
  BEGIN
    -- create the email request
    _email_request := (select msg_fn.create_email_request(
      _email_request_info
      ,auth_fn.current_app_user()->>'app_tenant_id'
      ,auth_fn.current_app_user()->>'app_user_id'
    ));

    return _email_request;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'msg_fn.send_email:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION msg_fn.send_email(_email_request_info msg_fn.email_request_info) OWNER TO postgres;

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
-- Name: fn_before_update_project(); Type: FUNCTION; Schema: prj; Owner: postgres
--

CREATE FUNCTION prj.fn_before_update_project() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;


ALTER FUNCTION prj.fn_before_update_project() OWNER TO postgres;

--
-- Name: fn_before_update_uow(); Type: FUNCTION; Schema: prj; Owner: postgres
--

CREATE FUNCTION prj.fn_before_update_uow() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;


ALTER FUNCTION prj.fn_before_update_uow() OWNER TO postgres;

--
-- Name: fn_capture_hist_project(); Type: FUNCTION; Schema: prj; Owner: postgres
--

CREATE FUNCTION prj.fn_capture_hist_project() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    insert into prj.project_history select OLD.*;
    RETURN OLD;
  END; $$;


ALTER FUNCTION prj.fn_capture_hist_project() OWNER TO postgres;

--
-- Name: fn_capture_hist_uow(); Type: FUNCTION; Schema: prj; Owner: postgres
--

CREATE FUNCTION prj.fn_capture_hist_uow() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    insert into prj.uow_history select OLD.*;
    RETURN OLD;
  END; $$;


ALTER FUNCTION prj.fn_capture_hist_uow() OWNER TO postgres;

--
-- Name: project_template(prj.project); Type: FUNCTION; Schema: prj; Owner: postgres
--

CREATE FUNCTION prj.project_template(_project prj.project) RETURNS prj.project
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    _project_template prj.project;
    _err_context text;
  BEGIN
    select * into _project_template from prj.project where type = _project.type and is_template = true;

    return _project_template;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'prj.project_template:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION prj.project_template(_project prj.project) OWNER TO postgres;

--
-- Name: uow_dependees(prj.uow); Type: FUNCTION; Schema: prj; Owner: postgres
--

CREATE FUNCTION prj.uow_dependees(_uow prj.uow) RETURNS SETOF prj.uow
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    _err_context text;
  BEGIN

    return query
    select *
    from prj.uow
    where id in (
      select dependee_id from prj.uow_dependency where depender_id = _uow.id
    )
    ;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'prj.uow_dependees:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
    END
  $$;


ALTER FUNCTION prj.uow_dependees(_uow prj.uow) OWNER TO postgres;

--
-- Name: uow_dependers(prj.uow); Type: FUNCTION; Schema: prj; Owner: postgres
--

CREATE FUNCTION prj.uow_dependers(_uow prj.uow) RETURNS SETOF prj.uow
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    _err_context text;
  BEGIN

    return query
    select *
    from prj.uow
    where id in (
      select depender_id from prj.uow_dependency where dependee_id = _uow.id
    )
    ;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'prj.uow_dependers:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
    END
  $$;


ALTER FUNCTION prj.uow_dependers(_uow prj.uow) OWNER TO postgres;

--
-- Name: cancel_project(text); Type: FUNCTION; Schema: prj_fn; Owner: postgres
--

CREATE FUNCTION prj_fn.cancel_project(_project_id text) RETURNS prj.project
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _project prj.project;
    _err_context text;
  BEGIN
    select * into _project
    from prj.project 
    where id = _project_id;

    if _project.id is null then
      raise exception 'no project for id: %', _project_id;
    end if;

    update prj.uow set
      status = 'canceled'
    where project_id = _project_id
    and status != 'complete'
    ;

    return _project;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'prj_fn.cancel_project:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION prj_fn.cancel_project(_project_id text) OWNER TO postgres;

--
-- Name: clone_project_template(text, prj_fn.clone_project_template_options); Type: FUNCTION; Schema: prj_fn; Owner: postgres
--

CREATE FUNCTION prj_fn.clone_project_template(_identifier text, _options prj_fn.clone_project_template_options DEFAULT ROW('{}'::jsonb)::prj_fn.clone_project_template_options) RETURNS prj.project
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _project prj.project;
    _project_uow prj.uow;
    _err_context text;
  BEGIN
    _project := (
      select prj_fn.do_clone_project_template(
        _identifier
        ,auth_fn.current_app_user()->>'app_tenant_id'
        ,_options
      )
    );

    return _project;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'prj_fn.clone_project_template:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION prj_fn.clone_project_template(_identifier text, _options prj_fn.clone_project_template_options) OWNER TO postgres;

--
-- Name: clone_uow_template(text, prj.project, prj_fn.clone_uow_template_options); Type: FUNCTION; Schema: prj_fn; Owner: postgres
--

CREATE FUNCTION prj_fn.clone_uow_template(_uow_id text, _project prj.project, _options prj_fn.clone_uow_template_options DEFAULT ROW(('{}'::jsonb)::json)::prj_fn.clone_uow_template_options) RETURNS prj.uow
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _uow prj.uow;
    _err_context text;
  BEGIN
    select * into _uow from prj.uow where id = _uow_id and is_template = 'true';

    if _uow.id is null then
      raise exception 'no uow template for id: %', _uow_id;
    end if;

    insert into prj.uow(
      identifier
      ,app_tenant_id
      ,is_template
      ,name
      ,description
      ,type
      ,data
      ,project_id
      ,status
      ,workflow_handler_key
      ,use_worker
    )
    values (
      _uow.identifier
      ,_project.app_tenant_id
      ,false
      ,_uow.name
      ,_uow.description
      ,_uow.type
      ,_options.data
      ,_project.id
      ,'incomplete'
      ,_uow.workflow_handler_key
      ,_uow.use_worker
    )
    returning *
    into _uow;

    return _uow;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'prj_fn.clone_uow_template:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION prj_fn.clone_uow_template(_uow_id text, _project prj.project, _options prj_fn.clone_uow_template_options) OWNER TO postgres;

--
-- Name: complete_uow(text, prj_fn.complete_uow_options); Type: FUNCTION; Schema: prj_fn; Owner: postgres
--

CREATE FUNCTION prj_fn.complete_uow(_uow_id text, _options prj_fn.complete_uow_options DEFAULT ROW(NULL::jsonb, NULL::jsonb)) RETURNS prj_fn.complete_uow_result
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _uow prj.uow;
    _project_uow prj.uow;
    _data jsonb;
    _uows_to_schedule prj.uow[];
    _depender_uow prj.uow;
    _child_uow prj.uow;
    _depender_status prj.uow_status_type;
    _child_status prj.uow_status_type;
    _parent_status prj.uow_status_type;
    _result prj_fn.complete_uow_result;
    _err_context text;
  BEGIN
    select *
    into _uow
    from prj.uow
    where id = _uow_id
    ;

    if _uow.id is null then
      raise exception 'no uow for id: %', _uow_id;
    end if;

    if _uow.status not in ('incomplete', 'waiting') then
      raise exception 'can only complete an incomplete or waiting uow: % - %', _uow.identifier, _uow.status;
    end if;

    select * into _project_uow from prj.uow where id = (select uow_id from prj.project where id = _uow.project_id);
    if _project_uow.status in ('paused', 'error', 'canceled', 'deleted', 'template', 'complete') then
      raise exception 'cannot update a uow with project status: %', _project_uow.status;
    end if;

    if _uow.status != 'complete' then
      raise notice 'updating: %, %', _uow.identifier, 'complete';
      update prj.uow
      set 
        status = 'complete'
        ,data = data || coalesce(_options.step_data, '{}'::jsonb)
      where id = _uow.id
      returning *
      into _uow
      ;

      update prj.project set
        workflow_data = workflow_data || coalesce(_options.workflow_data, '{}'::jsonb)
      where id = _uow.project_id
      ;

    end if;

    -- compute dependers status
    for _depender_uow in
      select * from prj.uow where id in (select depender_id from prj.uow_dependency where dependee_id = _uow.id)
    loop
      -- raise notice 'depender: %', _depender_uow.identifier;
      _depender_status := (select prj_fn.compute_uow_status(_depender_uow.id));
      -- raise exception 'DEPENDER: %, %', _depender_uow.identifier, _depender_status;

      -- perform prj_fn.complete_uow(_depender_uow.id) from prj.uow where id = _depender_uow.id and status != _depender_status;
      if _depender_uow.type = 'task' then
        if _depender_status = 'incomplete' then
          perform prj_fn.incomplete_uow(_depender_uow.id);
        end if;
        if _depender_status = 'waiting' then
          perform prj_fn.waiting_uow(_depender_uow.id);
        end if;
      end if;

      if _depender_uow.type = 'milestone' and _depender_status = 'waiting' then
        for _child_uow in
          select * from prj.uow where parent_uow_id = _depender_uow.id
        loop
          _child_status := (select prj_fn.compute_uow_status(_child_uow.id));
          raise notice 'CHILD: % -- %', _child_uow.identifier, _child_status;
          if _child_status = 'complete' then
            perform prj_fn.complete_uow(_child_uow.id);
          end if;
          if _child_status = 'incomplete' then
            perform prj_fn.incomplete_uow(_child_uow.id);
          end if;
          if _child_status = 'waiting' then
            perform prj_fn.waiting_uow(_child_uow.id);
          end if;
        end loop;
      end if;
    end loop;

    -- compute parent status
    if _uow.parent_uow_id is not null then
      _parent_status := (select prj_fn.compute_uow_status(id)
      from prj.uow
      where id = _uow.parent_uow_id
      );
      -- recursion
      if _parent_status = 'complete' then
        perform prj_fn.complete_uow(_uow.parent_uow_id);
      end if;
      if _parent_status = 'incomplete' then
        perform prj_fn.incomplete_uow(_uow.parent_uow_id);
      end if;
      if _parent_status = 'waiting' then
        perform prj_fn.waiting_uow(_uow.parent_uow_id);
      end if;
    end if;

    with uows as (
      select *
      from prj.uow
      where project_id = _uow.project_id
      -- and type = 'task'
      and status = 'incomplete'
      and use_worker = true
    )
    select array_agg(u.*)
    into _uows_to_schedule
    from uows u
    ;
    -- select * into _project_uow from prj.uow where id = (select uow_id from prj.project where id = _uow.project_id);
    -- if _project_uow.status not in ('paused', 'error', 'canceled', 'deleted', 'template', 'complete') then
    --   with uows as (
    --     select *
    --     from prj.uow
    --     where project_id = _uow.project_id
    --     -- and type = 'task'
    --     and status = 'incomplete'
    --     and use_worker = true
    --   )
    --   select array_agg(u.*)
    --   into _uows_to_schedule
    --   from uows u
    --   ;
    -- else
    --   _uows_to_schedule := '{}'::prj.uow[];
    -- end if;

    _result.uow := _uow;
    _result.uows_to_schedule := coalesce(_uows_to_schedule, '{}');

    return _result;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'prj_fn.complete_uow:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION prj_fn.complete_uow(_uow_id text, _options prj_fn.complete_uow_options) OWNER TO postgres;

--
-- Name: compute_uow_status(text); Type: FUNCTION; Schema: prj_fn; Owner: postgres
--

CREATE FUNCTION prj_fn.compute_uow_status(_uow_id text) RETURNS prj.uow_status_type
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _uow prj.uow;
    _parent_uow prj.uow;
    _children_count integer;
    _dependency_count integer;
    _error_count integer;
    _status prj.uow_status_type;
    _err_context text;
  BEGIN
    -- this function calculates status for the specified uow based on status of relative uows
    -- 
    select * into _uow from prj.uow where id = _uow_id;
    select count(*) into _children_count
    from prj.uow
    where parent_uow_id = _uow_id
    and status in ('incomplete', 'waiting');

    select count(*) into _dependency_count
    from prj.uow_dependency d
    join prj.uow dee on d.dependee_id = dee.id
    where d.depender_id = _uow_id
    and dee.status in ('incomplete', 'waiting')
    ;

    if _uow.type = 'project' then
      select count(*) into _error_count
      from prj.uow
      where project_id = _uow.project_id
      and status in ('error')
      ;

      _status := (
        select case
          when _error_count > 0 then 'error'::prj.uow_status_type
          when _dependency_count > 0 then 'waiting'::prj.uow_status_type
          when _children_count > 0 then 'waiting'::prj.uow_status_type
          else 'incomplete'::prj.uow_status_type
        end
      );
    end if;

    if _uow.type = 'milestone' then
      _status := (
        select case
          when _dependency_count > 0 then 'waiting'::prj.uow_status_type
          when _children_count > 0 then 'waiting'::prj.uow_status_type
          else 'complete'::prj.uow_status_type
        end
      );
    end if;

    if _uow.type = 'task' then
      select * into _parent_uow
      from prj.uow where id = _uow.parent_uow_id
      ;

      if _children_count > 0 then
        raise exception 'workflow task cannot have children';
      end if;
      if _dependency_count > 0 then
        _status := 'waiting';
      else
        _status := (
          select case
            when _uow.status = 'complete' then 'complete'
            when _uow.status = 'paused' then 'paused'
            when _uow.status = 'canceled' then 'canceled'
            when _uow.status = 'deleted' then 'deleted'
            when _uow.status = 'error' then 'error'
            else 'incomplete'
          end
        );
      end if;
    end if;

    raise notice 'COMPUTING STATUS: % - % - % - % - %', _uow.type, _uow.identifier, _children_count, _dependency_count, _status;
    return _status;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'prj_fn.compute_uow_status:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION prj_fn.compute_uow_status(_uow_id text) OWNER TO postgres;

--
-- Name: delete_uow(text); Type: FUNCTION; Schema: prj_fn; Owner: postgres
--

CREATE FUNCTION prj_fn.delete_uow(_uow_id text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _uow prj.uow;
    _sibling_count integer;
    _err_context text;
  BEGIN

    select * into _uow from prj.uow where id = _uow_id;

    if _uow.id is null then
      raise exception 'no uow for id: %', _uow_id;
    end if;

    select count(*) into _sibling_count from prj.uow where parent_uow_id = _uow.parent_uow_id and id != _uow.id;

    if _sibling_count = 0 then
      update prj.uow set type = 'task' where id = _uow.parent_uow_id and type = 'milestone';
    end if;

    delete from uow where id = _uow_id;

    return true;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'prj_fn.delete_uow:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION prj_fn.delete_uow(_uow_id text) OWNER TO postgres;

--
-- Name: do_clone_project_template(text, text, prj_fn.clone_project_template_options); Type: FUNCTION; Schema: prj_fn; Owner: postgres
--

CREATE FUNCTION prj_fn.do_clone_project_template(_identifier text, _app_tenant_id text, _options prj_fn.clone_project_template_options DEFAULT ROW('{}'::jsonb)::prj_fn.clone_project_template_options) RETURNS prj.project
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _project_template prj.project;
    _project prj.project;
    _project_uow prj.uow;
    _err_context text;
  BEGIN

    select * 
    into _project_template 
    from prj.project 
    where 1=1
    -- app_tenant_id = _app_tenant_id
    and identifier = _identifier
    and is_template = true
    ;

    if _project_template.id is null then
      raise exception 'no project template for _identifier: %', _identifier;
    end if;

    insert into prj.project(
      identifier,
      app_tenant_id,
      name,
      type,
      is_template,
      workflow_data
    )
    values (
      _project_template.identifier
      ,_app_tenant_id
      ,_project_template.name
      ,_project_template.type
      ,false
      ,_options.data
    )
    returning *
    into _project;

    -- raise exception '_project: %', _project.id;

    perform prj_fn.clone_uow_template(
      id
      ,_project
    ) 
    from prj.uow 
    where project_id = _project_template.id
    ;


    select * into _project_uow from prj.uow where project_id = _project.id and type = 'project';

    update prj.project set
      uow_id = _project_uow.id
    where id = _project.id
    returning * into _project;

    -- calculate and apply task lineages
    with uow_map as (
      select
        pnt.identifier parent_identifier
        ,chd.identifier child_identifier
      from prj.project p
      join prj.uow pnt on pnt.project_id = p.id
      join prj.uow chd on pnt.id = chd.parent_uow_id
      where p.id = _project_template.id
    )
    ,np_uows as (
      select
        chd.id child_uow_id
        ,pnt.id parent_uow_id
      from prj.uow chd
      join uow_map um on chd.identifier = um.child_identifier
      join prj.uow pnt on pnt.identifier = um.parent_identifier
      where chd.project_id = _project.id
      and pnt.project_id = _project.id
    )
    update prj.uow c_uow set
      parent_uow_id = np_uows.parent_uow_id
    from np_uows
    where c_uow.id = np_uows.child_uow_id
    ;
    -- calculate and apply task dependencies
    with uow_map as (
      select
        dee.identifier dee_identifier
        ,der.identifier der_identifier
      from prj.uow_dependency d
      join prj.uow dee on dee.id = d.dependee_id
      join prj.uow der on der.id = d.depender_id
      where dee.project_id = _project_template.id
    )
    ,np_uows as (
      select
        dee.app_tenant_id
        ,dee.id dependee_uow_id
        ,der.id depender_uow_id
        ,dee.is_template
      from prj.uow dee
      join uow_map um on dee.identifier = um.dee_identifier
      join prj.uow der on der.identifier = um.der_identifier
      where dee.project_id = _project.id
      and der.project_id = _project.id
    )
    insert into prj.uow_dependency(
      app_tenant_id
      ,dependee_id
      ,depender_id
    )
    select
      np_uows.app_tenant_id
      ,np_uows.dependee_uow_id
      ,np_uows.depender_uow_id
    from np_uows
    ;

    -- WAITING: all uows that are dependers on other uows
    update prj.uow set status = 'waiting' where id
    in (select d.depender_id from prj.uow_dependency d join prj.uow u on d.depender_id = u.id where u.project_id = _project.id)
    ;

    -- WAITING: all uows that are parents of other uows
    update prj.uow set status = 'waiting' where id
    in (select parent_uow_id from prj.uow where project_id = _project.id)
    ;

    -- WAITNG: all uows that are children of dependers
    update prj.uow set status = 'waiting' where parent_uow_id
    in (select d.depender_id from prj.uow_dependency d join prj.uow u on d.depender_id = u.id where u.project_id = _project.id)
    ;

    -- remove the history records produced by these initial updates
    delete from prj.uow_history where project_id = _project.id;
    delete from prj.project_history where id = _project.id;

    return _project;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'prj_fn.do_clone_project_template:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION prj_fn.do_clone_project_template(_identifier text, _app_tenant_id text, _options prj_fn.clone_project_template_options) OWNER TO postgres;

--
-- Name: FUNCTION do_clone_project_template(_identifier text, _app_tenant_id text, _options prj_fn.clone_project_template_options); Type: COMMENT; Schema: prj_fn; Owner: postgres
--

COMMENT ON FUNCTION prj_fn.do_clone_project_template(_identifier text, _app_tenant_id text, _options prj_fn.clone_project_template_options) IS '@OMIT';


--
-- Name: do_queue_anon_workflow(text, jsonb, text); Type: FUNCTION; Schema: prj_fn; Owner: postgres
--

CREATE FUNCTION prj_fn.do_queue_anon_workflow(_identifier text, _workflow_input_data jsonb, _app_tenant_id text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _project prj.project;
    _uows_to_schedule prj.uow[];
    _result prj_fn.queue_workflow_result;
    _err_context text;
  BEGIN

    -- if _identifier not in (
    --   'brochure-contact'
    -- ) then
    --   raise exception 'cannot perform this workflow anonymously';
    -- end if;

    if _app_tenant_id is null then
      select id into _app_tenant_id
      from app.app_tenant where type = 'anchor';
    end if;

    _project := (
      select prj_fn.do_clone_project_template(
        _identifier
        ,_app_tenant_id
        ,row(_workflow_input_data)
      )
    );

    with uows as (
      select *
      from prj.uow
      where project_id = _project.id
      and type = 'task'
      and status = 'incomplete'
      and use_worker = true
    )
    select array_agg(u.*)
    into _uows_to_schedule
    from uows u
    ;

    _result.project := _project;
    _result.uows_to_schedule := _uows_to_schedule;

    return to_jsonb(_result);
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'prj_fn.do_queue_anon_workflow:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION prj_fn.do_queue_anon_workflow(_identifier text, _workflow_input_data jsonb, _app_tenant_id text) OWNER TO postgres;

--
-- Name: FUNCTION do_queue_anon_workflow(_identifier text, _workflow_input_data jsonb, _app_tenant_id text); Type: COMMENT; Schema: prj_fn; Owner: postgres
--

COMMENT ON FUNCTION prj_fn.do_queue_anon_workflow(_identifier text, _workflow_input_data jsonb, _app_tenant_id text) IS '@omit';


--
-- Name: do_queue_workflow(text, text, jsonb); Type: FUNCTION; Schema: prj_fn; Owner: postgres
--

CREATE FUNCTION prj_fn.do_queue_workflow(_identifier text, _app_tenant_id text, _workflow_input_data jsonb) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  DECLARE
    _project prj.project;
    _uows_to_schedule prj.uow[];
    _result prj_fn.queue_workflow_result;
    _err_context text;
  BEGIN

    _project := (
      select prj_fn.do_clone_project_template(
        _identifier
        ,_app_tenant_id
        ,row(_workflow_input_data)
      )
    );

    with uows as (
      select *
      from prj.uow
      where project_id = _project.id
      and type = 'task'
      and status = 'incomplete'
      and use_worker = true
    )
    select array_agg(u.*)
    into _uows_to_schedule
    from uows u
    ;

    _result.project := _project;
    _result.uows_to_schedule := _uows_to_schedule;

    return to_jsonb(_result);
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'prj_fn.do_queue_workflow:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION prj_fn.do_queue_workflow(_identifier text, _app_tenant_id text, _workflow_input_data jsonb) OWNER TO postgres;

--
-- Name: FUNCTION do_queue_workflow(_identifier text, _app_tenant_id text, _workflow_input_data jsonb); Type: COMMENT; Schema: prj_fn; Owner: postgres
--

COMMENT ON FUNCTION prj_fn.do_queue_workflow(_identifier text, _app_tenant_id text, _workflow_input_data jsonb) IS '@omit';


--
-- Name: do_upsert_project(prj_fn.project_info, text); Type: FUNCTION; Schema: prj_fn; Owner: postgres
--

CREATE FUNCTION prj_fn.do_upsert_project(_project_info prj_fn.project_info, _app_tenant_id text) RETURNS prj.project
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _project prj.project;
    _project_uow prj.uow;
    _uow_info prj_fn.uow_info;
    _uow_dependency_info prj_fn.uow_dependency_info;
    _uow_dependency prj.uow_dependency;
    _uow_dependee prj.uow;
    _uow_depender prj.uow;
    _err_context text;
  BEGIN
    if _project_info.is_template is null then
      raise exception 'is_template must be specified for project_info';
    end if;

    select *
    into _project
    from prj.project
    where app_tenant_id = _app_tenant_id
    and (
        (identifier = _project_info.identifier and is_template = true and _project_info.is_template = true)
      or 
        (id = _project_info.id and is_template = false and _project_info.is_template = false)
    )
    and is_template = _project_info.is_template
    ;

  -- raise exception '_project_info.workflow_input_definition: %', _project_info.workflow_input_definition;
    if _project.id is null then
      insert into prj.project_type(id)
      values (_project_info.type)
      on conflict(id) do nothing
      ;

      insert into prj.project(
        app_tenant_id
        ,name
        ,identifier
        ,type
        ,is_template
        ,workflow_input_definition
      )
      select
        _app_tenant_id
        ,_project_info.name
        ,_project_info.identifier
        ,_project_info.type
        ,coalesce(_project_info.is_template, false)
        ,coalesce(_project_info.workflow_input_definition, '{}'::jsonb)
      returning *
      into _project
      ;

      _project_uow := (select prj_fn.do_upsert_uow(
        row(
          null
          ,_project_info.identifier
          ,_project_info.name
          ,coalesce(_project_info.is_template, false)
          ,_project_info.name || ' root uow'
          ,'project'
          ,'{}'
          ,_project.id
          ,null
          ,null
          ,_project_info.on_completed_workflow_handler_key
          ,(_project_info.on_completed_workflow_handler_key is not null)
        )
        ,_app_tenant_id
      ));

      update prj.project set uow_id = _project_uow.id where id = _project.id returning * into _project;
    else
      update prj.project set
        updated_at = current_timestamp
        ,name = _project_info.name
        ,is_template = _project_info.is_template
        ,type = _project_info.type
        ,workflow_input_definition = coalesce(_project_info.workflow_input_definition, '{}'::jsonb)
      where id = _project.id
      returning * into _project
      ;

      _project_uow := (select prj_fn.do_upsert_uow(
        row(
          null
          ,_project_info.identifier
          ,_project_info.name
          ,coalesce(_project_info.is_template, false)
          ,_project_info.name || ' root uow'
          ,'project'
          ,'{}'
          ,_project.id
          ,null
          ,null
          ,_project_info.on_completed_workflow_handler_key
          ,(_project_info.on_completed_workflow_handler_key is not null)
        ),
        _app_tenant_id
      ));
    end if;

    foreach _uow_info in array(_project_info.uows)
    loop
      _uow_info.project_id := _project.id;
      perform prj_fn.do_upsert_uow(_uow_info, _app_tenant_id);
    end loop;

    update prj.uow set 
      parent_uow_id = _project_uow.id
    where project_id = _project.id
    and parent_uow_id is null
    and type != 'project'
    ;

    foreach _uow_dependency_info in array(_project_info.uow_dependencies)
    loop
      select *
      into _uow_dependee
      from prj.uow 
      where project_id = _project.id
      and identifier = _uow_dependency_info.dependee_identifier
      ;
      if _uow_dependee.id is null then
        raise exception 'no dependee for identifier: %', _uow_dependency_info.dependee_identifier;
      end if;

      select *
      into _uow_depender
      from prj.uow 
      where project_id = _project.id
      and identifier = _uow_dependency_info.depender_identifier
      ;
      if _uow_depender.id is null then
        raise exception 'no depender for identifier: %', _uow_dependency_info.depender_identifier;
      end if;


      select * 
      into _uow_dependency from prj.uow_dependency
      where dependee_id = _uow_dependee.id
      and depender_id = _uow_depender.id
      ;

      if _uow_dependency.id is null then
        insert into prj.uow_dependency(
          app_tenant_id
          ,dependee_id
          ,depender_id
          ,is_template
        )
        select
          _app_tenant_id
          ,_uow_dependee.id
          ,_uow_depender.id
          ,_project.is_template
        ;
      end if;
    end loop;

    perform prj_fn.compute_uow_status(id)
    from prj.uow
    where project_id = _project.id
    and type in ('milestone')
    ;

    return _project;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'prj_fn.upsert_project:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION prj_fn.do_upsert_project(_project_info prj_fn.project_info, _app_tenant_id text) OWNER TO postgres;

--
-- Name: FUNCTION do_upsert_project(_project_info prj_fn.project_info, _app_tenant_id text); Type: COMMENT; Schema: prj_fn; Owner: postgres
--

COMMENT ON FUNCTION prj_fn.do_upsert_project(_project_info prj_fn.project_info, _app_tenant_id text) IS '@OMIT';


--
-- Name: do_upsert_uow(prj_fn.uow_info, text); Type: FUNCTION; Schema: prj_fn; Owner: postgres
--

CREATE FUNCTION prj_fn.do_upsert_uow(_uow_info prj_fn.uow_info, _app_tenant_id text) RETURNS prj.uow
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _uow prj.uow;
    _err_context text;
  BEGIN
    if _uow_info.id is not null then
      select *
      into _uow
      from prj.uow
      where app_tenant_id = _app_tenant_id
      and id = _uow_info.id
      ;
      
      if _uow.id is null then
        raise exception 'uow id specified does not exist';
      end if;
    else 
      select *
      into _uow
      from prj.uow
      where app_tenant_id = _app_tenant_id
      and identifier = _uow_info.identifier
      and project_id = _uow_info.project_id
      ;
    end if;

    -- if _uow_info.identifier = 'send-welcome-email' then
    --   raise exception 'wtf: %', _uow.id;
    -- end if;

    if _uow.id is null then
      insert into prj.uow(
        id
        ,app_tenant_id
        ,identifier
        ,is_template
        ,name
        ,description
        ,type
        ,data
        ,project_id
        ,status
        ,due_at
        ,parent_uow_id
        ,workflow_handler_key
        ,use_worker
      )
      select
        coalesce(_uow_info.id, shard_1.id_generator())
        ,_app_tenant_id
        ,_uow_info.identifier
        ,_uow_info.is_template
        ,_uow_info.name
        ,_uow_info.description
        ,_uow_info.type
        ,_uow_info.data
        ,_uow_info.project_id
        ,case
          when _uow_info.is_template then
            'template'::prj.uow_status_type
          else
            'incomplete'::prj.uow_status_type
        end 
        ,_uow_info.due_at
        ,(
          select id from prj.uow
          where project_id = _uow_info.project_id
          and (id = _uow_info.parent_uow_id or identifier = _uow_info.parent_uow_id)
        )
        ,_uow_info.workflow_handler_key
        ,coalesce(_uow_info.use_worker, false)
      returning *
      into _uow
      ;

      -- promote any parent task to a milestone
      update prj.uow set type = 'milestone' where id = _uow.parent_uow_id and type = 'task';
    else
      update prj.uow set
        updated_at = current_timestamp
        ,name = _uow_info.name
        ,is_template = _uow_info.is_template
        ,type = _uow_info.type
        ,workflow_handler_key = _uow_info.workflow_handler_key
      where id = _uow.id
      ;
    end if;

    return _uow;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'prj_fn.do_upsert_uow:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION prj_fn.do_upsert_uow(_uow_info prj_fn.uow_info, _app_tenant_id text) OWNER TO postgres;

--
-- Name: FUNCTION do_upsert_uow(_uow_info prj_fn.uow_info, _app_tenant_id text); Type: COMMENT; Schema: prj_fn; Owner: postgres
--

COMMENT ON FUNCTION prj_fn.do_upsert_uow(_uow_info prj_fn.uow_info, _app_tenant_id text) IS '@OMIT';


--
-- Name: error_uow(text, text, text[]); Type: FUNCTION; Schema: prj_fn; Owner: postgres
--

CREATE FUNCTION prj_fn.error_uow(_uow_id text, _message text, _stack text[]) RETURNS prj.uow
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _uow prj.uow;
    _project_uow prj.uow;
    _err_context text;
  BEGIN
    select *
    into _uow
    from prj.uow
    where id = _uow_id
    ;

    if _uow.id is null then
      raise exception 'no uow for id: %', _uow_id;
    end if;

    select * into _project_uow from prj.uow where id = (select uow_id from prj.project where id = _uow.project_id);
    if _project_uow.status in ('paused', 'canceled', 'deleted', 'template', 'complete') then
      raise exception 'cannot update a uow with project status: %', _project_uow.status;
    end if;

    update prj.uow set
      status = 'error'
      ,data = data || jsonb_build_object(
        'error', jsonb_build_object(
          'message', _message
          ,'stack', _stack
        )
      )
    where id = _uow.id
    returning * into _uow
    ;

    update prj.uow set
      status = 'error'
      ,data = data || jsonb_build_object(
        'error', jsonb_build_object(
          'message', _message
          ,'stack', _stack
        )
      )
    where id = _project_uow.id
    ;

    update prj.project set
      workflow_data = workflow_data || jsonb_build_object(
        'error', jsonb_build_object(
          'message', _message
          ,'stack', _stack
        )
      )
    where id = _uow.project_id
    ;

    return _uow;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'prj_fn.waiting_uow:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION prj_fn.error_uow(_uow_id text, _message text, _stack text[]) OWNER TO postgres;

--
-- Name: incomplete_uow(text); Type: FUNCTION; Schema: prj_fn; Owner: postgres
--

CREATE FUNCTION prj_fn.incomplete_uow(_uow_id text) RETURNS prj.uow
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _uow prj.uow;
    _depender_uow prj.uow;
    _child_uow prj.uow;
    _project_uow prj.uow;
    _result prj_fn.complete_uow_result;
    _depender_status prj.uow_status_type;
    _child_status prj.uow_status_type;
    _parent_status prj.uow_status_type;
    _err_context text;
  BEGIN
    select *
    into _uow
    from prj.uow
    where id = _uow_id
    ;

    if _project_uow.status = 'error' then
      return _uow;
    end if;

    if _uow.id is null then
      raise exception 'no uow for id: %', _uow_id;
    end if;

    select * into _project_uow from prj.uow where id = (select uow_id from prj.project where id = _uow.project_id);
    if _project_uow.status in ('paused', 'error', 'canceled', 'deleted', 'template', 'complete') then
      raise exception 'cannot update a uow with project status: %', _project_uow.status;
    end if;

    update prj.uow
    set status = 'incomplete'
    where id = _uow.id
    returning * into _uow
    ;

    -- compute dependers status
    for _depender_uow in
      select * from prj.uow where id in (select depender_id from prj.uow_dependency where dependee_id = _uow.id)
    loop
      if _depender_uow.status = 'complete' then
        raise exception 'cannot incomplete a uow with completed dependencies';
      end if;
      -- raise notice 'depender: %', _depender_uow.identifier;
      _depender_status := (select prj_fn.compute_uow_status(_depender_uow.id));
      -- raise exception 'DEPENDER: %, %', _depender_uow.identifier, _depender_status;


      -- perform prj_fn.complete_uow(_depender_uow.id) from prj.uow where id = _depender_uow.id and status != _depender_status;
      if _depender_uow.type = 'task' then
        if _depender_status = 'incomplete' then
          perform prj_fn.waiting_uow(_depender_uow.id);
        end if;
      end if;

      if _depender_uow.type = 'milestone' and _depender_status = 'waiting' then
        for _child_uow in
          select * from prj.uow where parent_uow_id = _depender_uow.id
        loop
          _child_status := (select prj_fn.compute_uow_status(_child_uow.id));
          if _child_status = 'complete' then
            perform prj_fn.complete_uow(_child_uow.id);
          end if;
          if _child_status = 'incomplete' then
            perform prj_fn.incomplete_uow(_child_uow.id);
          end if;
          if _child_status = 'waiting' then
            perform prj_fn.waiting_uow(_child_uow.id);
          end if;
        end loop;
      end if;
    end loop;

    -- compute parent status
    if _uow.parent_uow_id is not null then
      _parent_status := (select prj_fn.compute_uow_status(id)
      from prj.uow
      where id = _uow.parent_uow_id
      );
      -- recursion
      if _parent_status = 'complete' then
        raise exception 'MAJOR ERROR: parent of incomplete uow cannot be complete';
      end if;
      if _parent_status = 'incomplete' then
        raise exception 'MAJOR ERROR: parent of incomplete uow cannot be incomplete';
      end if;
      if _parent_status = 'waiting' then
        perform prj_fn.waiting_uow(_uow.parent_uow_id);
      end if;
    end if;

    return _uow;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'prj_fn.incomplete_uow:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION prj_fn.incomplete_uow(_uow_id text) OWNER TO postgres;

--
-- Name: pause_uow(text); Type: FUNCTION; Schema: prj_fn; Owner: postgres
--

CREATE FUNCTION prj_fn.pause_uow(_uow_id text) RETURNS prj.uow
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _uow prj.uow;
    _project_uow prj.uow;
    _result prj_fn.complete_uow_result;
    _err_context text;
  BEGIN
    select *
    into _uow
    from prj.uow
    where id = _uow_id
    ;

    if _project_uow.status = 'error' then
      return _uow;
    end if;

    if _uow.id is null then
      raise exception 'no uow for id: %', _uow_id;
    end if;

    select * into _project_uow from prj.uow where id = (select uow_id from prj.project where id = _uow.project_id);
    if _project_uow.status in ('paused', 'error', 'canceled', 'deleted', 'template', 'complete') then
      raise exception 'cannot update a uow with project status: %', _project_uow.status;
    end if;

    update prj.uow
    set status = 'paused'
    where id = _uow.id
    returning * into _uow
    ;

    update prj.uow
    set status = 'paused'
    where id = _project_uow.id
    ;

    return _uow;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'prj_fn.waiting_uow:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION prj_fn.pause_uow(_uow_id text) OWNER TO postgres;

--
-- Name: queue_workflow(text, jsonb); Type: FUNCTION; Schema: prj_fn; Owner: postgres
--

CREATE FUNCTION prj_fn.queue_workflow(_identifier text, _workflow_input_data jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _app_tenant_id text;
    _result jsonb;
    _err_context text;
  BEGIN
    _app_tenant_id := auth_fn.current_app_user()->>'app_tenant_id';

    if (_workflow_input_data ? 'workflowInputData') = false then
      _workflow_input_data := jsonb_build_object(
        'workflowInputData', _workflow_input_data
      );
    end if;

    _result := (select prj_fn.do_queue_workflow(
      _identifier
      ,_app_tenant_id
      ,_workflow_input_data
    ));

    return _result;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'prj_fn.queue_workflow:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION prj_fn.queue_workflow(_identifier text, _workflow_input_data jsonb) OWNER TO postgres;

--
-- Name: search_projects(prj_fn.search_projects_options); Type: FUNCTION; Schema: prj_fn; Owner: postgres
--

CREATE FUNCTION prj_fn.search_projects(_options prj_fn.search_projects_options) RETURNS SETOF prj.project
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    _err_context text;
    _search_terms text[];
  BEGIN
    -- _search_terms :=
    if 
      _options.project_type is null and
      _options.is_template is null and
      _options.search_terms is null and
      _options.date_range_start is null and
      _options.date_range_end is null and
      _options.app_user_id is null and
      _options.app_tenant_id is null and
      _options.project_uow_status is null
    then
      raise exception 'must specify one or more options';
    end if;
    
    return query
    select *
    from prj.project p
    where is_template = false
    and (_options.project_type is null or p.type = _options.project_type)
    and (_options.app_user_id is null or p.workflow_data #>> '{workflowInputData,appUserId}' = _options.app_user_id)
    -- and (_options.app_user_id is null or p.workflow_data #>> '{workflowInputData,appUserId}' = _options.app_user_id)
    -- and (_options.app_user_id is null or p.workflow_data #>> '{workflowInputData,appUserId}' = _options.app_user_id)
    -- and (_options.app_user_id is null or p.workflow_data #>> '{workflowInputData,appUserId}' = _options.app_user_id)
    -- and (_options.app_user_id is null or p.workflow_data #>> '{workflowInputData,appUserId}' = _options.app_user_id)
    -- and (_options.app_user_id is null or p.workflow_data #>> '{workflowInputData,appUserId}' = _options.app_user_id)
    order by created_at desc
    limit _options.result_limit
    ;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'prj_fn.search_projects:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  END
  $$;


ALTER FUNCTION prj_fn.search_projects(_options prj_fn.search_projects_options) OWNER TO postgres;

--
-- Name: uow_by_project_and_identifier(text, text); Type: FUNCTION; Schema: prj_fn; Owner: postgres
--

CREATE FUNCTION prj_fn.uow_by_project_and_identifier(_project_id text, _identifier text) RETURNS prj.uow
    LANGUAGE plpgsql STABLE
    AS $$
  DECLARE
    _uow prj.uow;
  BEGIN

    select *
    into _uow
    from prj.uow
    where project_id = _project_id
    and identifier = _identifier
    ;

    return _uow;

  END
  $$;


ALTER FUNCTION prj_fn.uow_by_project_and_identifier(_project_id text, _identifier text) OWNER TO postgres;

--
-- Name: upsert_project(prj_fn.project_info); Type: FUNCTION; Schema: prj_fn; Owner: postgres
--

CREATE FUNCTION prj_fn.upsert_project(_project_info prj_fn.project_info) RETURNS prj.project
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _app_tenant_id text;
    _project prj.project;
    _err_context text;
  BEGIN
    _app_tenant_id := auth_fn.current_app_user()->>'app_tenant_id';
    _project := (select prj_fn.do_upsert_project(
      _project_info
      ,_app_tenant_id
    ));

    return _project;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'prj_fn.do_upsert_project:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION prj_fn.upsert_project(_project_info prj_fn.project_info) OWNER TO postgres;

--
-- Name: upsert_uow(prj_fn.uow_info); Type: FUNCTION; Schema: prj_fn; Owner: postgres
--

CREATE FUNCTION prj_fn.upsert_uow(_uow_info prj_fn.uow_info) RETURNS prj.uow
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _uow prj.uow;
    _err_context text;
  BEGIN

    select *
    into _uow
    from prj.uow
    where app_tenant_id = auth_fn.current_app_user()->>'app_tenant_id'
    and (identifier = _uow_info.identifier or id = _uow_info.id)
    ;

    if _uow.id is null then
      insert into prj.uow(
        id
        ,app_tenant_id
        ,identifier
        ,is_template
        ,name
        ,description
        ,type
        ,data
        ,project_id
        ,status
        ,due_at
        ,parent_uow_id
      )
      select
        coalesce(_uow_info.id, shard_1.id_generator())
        ,auth_fn.current_app_user()->>'app_tenant_id'
        ,_uow_info.identifier
        ,_uow_info.is_template
        ,_uow_info.name
        ,_uow_info.description
        ,_uow_info.type
        ,_uow_info.data
        ,_uow_info.project_id
        ,'incomplete'
        ,_uow_info.due_at
        ,(
          select id from prj.uow
          where project_id = _uow_info.project_id
          and (id = _uow_info.parent_uow_id or identifier = _uow_info.parent_uow_id)
        )
      returning *
      into _uow
      ;

      -- promote any parent task to a milestone
      update prj.uow set type = 'milestone' where id = _uow.parent_uow_id and type = 'task';
    else
      update prj.uow set
        updated_at = current_timestamp
        ,name = _uow_info.name
        ,is_template = _uow_info.is_template
        ,type = _uow_info.type
      where id = _uow.id
      ;
    end if;

    return _uow;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'prj_fn.upsert_uow:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION prj_fn.upsert_uow(_uow_info prj_fn.uow_info) OWNER TO postgres;

--
-- Name: upsert_uow(prj_fn.uow_info, text); Type: FUNCTION; Schema: prj_fn; Owner: postgres
--

CREATE FUNCTION prj_fn.upsert_uow(_uow_info prj_fn.uow_info, _app_tenant_id text) RETURNS prj.uow
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _uow prj.uow;
    _app_tenant_id text;
    _err_context text;
  BEGIN
    _app_tenant_id := auth_fn.current_app_user()->>'app_tenant_id';
    _uow := (select prj_fn.do_upsert_uow(
      _uow_info
      ,_app_tenant_id
    ));

    return _uow;
    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'prj_fn.upsert_uow:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION prj_fn.upsert_uow(_uow_info prj_fn.uow_info, _app_tenant_id text) OWNER TO postgres;

--
-- Name: waiting_uow(text); Type: FUNCTION; Schema: prj_fn; Owner: postgres
--

CREATE FUNCTION prj_fn.waiting_uow(_uow_id text) RETURNS prj.uow
    LANGUAGE plpgsql
    AS $$
  DECLARE
    _uow prj.uow;
    _project_uow prj.uow;
    _result prj_fn.complete_uow_result;
    _err_context text;
  BEGIN
    select *
    into _uow
    from prj.uow
    where id = _uow_id
    ;

    if _project_uow.status = 'error' then
      return _uow;
    end if;

    if _uow.id is null then
      raise exception 'no uow for id: %', _uow_id;
    end if;

    select * into _project_uow from prj.uow where id = (select uow_id from prj.project where id = _uow.project_id);
    if _project_uow.status in ('paused', 'error', 'canceled', 'deleted', 'template', 'complete') then
      raise exception 'cannot update a uow with project status: %', _project_uow.status;
    end if;

    update prj.uow
    set status = 'waiting'
    where id = _uow.id
    returning * into _uow
    ;

    return _uow;

    exception
      when others then
        GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        if position('FB' in SQLSTATE::text) = 0 then
          _err_context := 'prj_fn.waiting_uow:::' || SQLSTATE::text || ':::' || SQLERRM::text || ':::' || _err_context;
          raise exception '%', _err_context using errcode = 'FB500';
        end if;
        raise;
  end;
  $$;


ALTER FUNCTION prj_fn.waiting_uow(_uow_id text) OWNER TO postgres;

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
-- Name: basin; Type: TABLE; Schema: dng; Owner: postgres
--

CREATE TABLE dng.basin (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    dng_project_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name text NOT NULL,
    analysis_method dng.analysis_method
);


ALTER TABLE dng.basin OWNER TO postgres;

--
-- Name: basin_travel_time; Type: TABLE; Schema: dng; Owner: postgres
--

CREATE TABLE dng.basin_travel_time (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    basin_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name text NOT NULL,
    length numeric(6,2),
    slope numeric(6,2),
    travel_time numeric(6,2)
);


ALTER TABLE dng.basin_travel_time OWNER TO postgres;

--
-- Name: TABLE basin_travel_time; Type: COMMENT; Schema: dng; Owner: postgres
--

COMMENT ON TABLE dng.basin_travel_time IS 'basin_travel_time represents the longest flow with the basin the node.';


--
-- Name: dng_node; Type: TABLE; Schema: dng; Owner: postgres
--

CREATE TABLE dng.dng_node (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    basin_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name text NOT NULL,
    northing text,
    easting text
);


ALTER TABLE dng.dng_node OWNER TO postgres;

--
-- Name: TABLE dng_node; Type: COMMENT; Schema: dng; Owner: postgres
--

COMMENT ON TABLE dng.dng_node IS 'every basin has one node. this is where drainage enters the system.';


--
-- Name: dng_project; Type: TABLE; Schema: dng; Owner: postgres
--

CREATE TABLE dng.dng_project (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name text NOT NULL
);


ALTER TABLE dng.dng_project OWNER TO postgres;

--
-- Name: flow; Type: TABLE; Schema: dng; Owner: postgres
--

CREATE TABLE dng.flow (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    travel_time_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    travel_time_material_id text NOT NULL
);


ALTER TABLE dng.flow OWNER TO postgres;

--
-- Name: TABLE flow; Type: COMMENT; Schema: dng; Owner: postgres
--

COMMENT ON TABLE dng.flow IS 'multiple flows contribute to the travel time.';


--
-- Name: hydrualic_constraint; Type: TABLE; Schema: dng; Owner: postgres
--

CREATE TABLE dng.hydrualic_constraint (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    dng_node_id text NOT NULL,
    storm_event_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    max_hgl numeric(6,2),
    tailwater numeric(6,2)
);


ALTER TABLE dng.hydrualic_constraint OWNER TO postgres;

--
-- Name: land_cover; Type: TABLE; Schema: dng; Owner: postgres
--

CREATE TABLE dng.land_cover (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    basin_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name text NOT NULL,
    area numeric(6,2),
    curve_number integer
);


ALTER TABLE dng.land_cover OWNER TO postgres;

--
-- Name: reach; Type: TABLE; Schema: dng; Owner: postgres
--

CREATE TABLE dng.reach (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name text NOT NULL,
    reach_type_id text NOT NULL,
    upstream_dng_node_id text,
    upstream_invert_elevation numeric(6,2),
    downstream_dng_node_id text,
    downstream_invert_elevation numeric(6,2),
    length numeric(6,2)
);


ALTER TABLE dng.reach OWNER TO postgres;

--
-- Name: TABLE reach; Type: COMMENT; Schema: dng; Owner: postgres
--

COMMENT ON TABLE dng.reach IS 'a reach connects two nodes.';


--
-- Name: reach_geometry; Type: TABLE; Schema: dng; Owner: postgres
--

CREATE TABLE dng.reach_geometry (
    id text NOT NULL,
    name text NOT NULL
);


ALTER TABLE dng.reach_geometry OWNER TO postgres;

--
-- Name: TABLE reach_geometry; Type: COMMENT; Schema: dng; Owner: postgres
--

COMMENT ON TABLE dng.reach_geometry IS 'reach_geometry_dimension describes the one dimension of a reach geometry.';


--
-- Name: reach_geometry_dimension; Type: TABLE; Schema: dng; Owner: postgres
--

CREATE TABLE dng.reach_geometry_dimension (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    reach_geometry_id text NOT NULL,
    reach_type_id text,
    name text NOT NULL,
    abbreviation text NOT NULL,
    value numeric(10,4),
    units text,
    is_template boolean GENERATED ALWAYS AS ((reach_type_id IS NULL)) STORED
);


ALTER TABLE dng.reach_geometry_dimension OWNER TO postgres;

--
-- Name: reach_material; Type: TABLE; Schema: dng; Owner: postgres
--

CREATE TABLE dng.reach_material (
    id text NOT NULL,
    name text NOT NULL
);


ALTER TABLE dng.reach_material OWNER TO postgres;

--
-- Name: TABLE reach_material; Type: COMMENT; Schema: dng; Owner: postgres
--

COMMENT ON TABLE dng.reach_material IS 'reach_material describes the material of a reach.';


--
-- Name: reach_type; Type: TABLE; Schema: dng; Owner: postgres
--

CREATE TABLE dng.reach_type (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    geometry_id text NOT NULL,
    material_id text NOT NULL,
    inlet_edge_description text NOT NULL,
    ke numeric(6,2),
    eq_form integer,
    k_unsubmerged numeric(6,4),
    m_unsubmerged numeric(6,4),
    c_submerged numeric(6,4),
    y_submerged numeric(6,4)
);


ALTER TABLE dng.reach_type OWNER TO postgres;

--
-- Name: TABLE reach_type; Type: COMMENT; Schema: dng; Owner: postgres
--

COMMENT ON TABLE dng.reach_type IS 'reach_type describes the construction and coefficients of a reach.';


--
-- Name: storm_event; Type: TABLE; Schema: dng; Owner: postgres
--

CREATE TABLE dng.storm_event (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    dng_project_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name text NOT NULL,
    precipitation numeric(6,2),
    rainfall_type dng.rainfall_type
);


ALTER TABLE dng.storm_event OWNER TO postgres;

--
-- Name: TABLE storm_event; Type: COMMENT; Schema: dng; Owner: postgres
--

COMMENT ON TABLE dng.storm_event IS 'travel_time_material is a part of a flow.';


--
-- Name: travel_time_material; Type: TABLE; Schema: dng; Owner: postgres
--

CREATE TABLE dng.travel_time_material (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    flow_type dng.flow_type,
    name text NOT NULL
);


ALTER TABLE dng.travel_time_material OWNER TO postgres;

--
-- Name: contact_project_role; Type: TABLE; Schema: prj; Owner: postgres
--

CREATE TABLE prj.contact_project_role (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    name text,
    project_id text NOT NULL,
    contact_id text NOT NULL,
    project_role_id text NOT NULL,
    assignment_timestampz timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    un_assignment_timestampz timestamp with time zone,
    is_template boolean DEFAULT false NOT NULL
);


ALTER TABLE prj.contact_project_role OWNER TO postgres;

--
-- Name: project_history; Type: TABLE; Schema: prj; Owner: postgres
--

CREATE TABLE prj.project_history (
    id text NOT NULL,
    uow_id text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    identifier text,
    app_tenant_id text NOT NULL,
    name text,
    type text NOT NULL,
    is_template boolean NOT NULL,
    managed_by_contact_project_role_id text,
    workflow_data jsonb DEFAULT '{}'::jsonb NOT NULL,
    workflow_input_definition jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE prj.project_history OWNER TO postgres;

--
-- Name: project_role; Type: TABLE; Schema: prj; Owner: postgres
--

CREATE TABLE prj.project_role (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    name text,
    key text,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT project_role_key_check CHECK (((key IS NOT NULL) AND (key <> ''::text))),
    CONSTRAINT project_role_name_check CHECK (((name IS NOT NULL) AND (name <> ''::text)))
);


ALTER TABLE prj.project_role OWNER TO postgres;

--
-- Name: project_type; Type: TABLE; Schema: prj; Owner: postgres
--

CREATE TABLE prj.project_type (
    id text NOT NULL
);


ALTER TABLE prj.project_type OWNER TO postgres;

--
-- Name: uow_dependency; Type: TABLE; Schema: prj; Owner: postgres
--

CREATE TABLE prj.uow_dependency (
    id text DEFAULT shard_1.id_generator() NOT NULL,
    app_tenant_id text NOT NULL,
    depender_id text NOT NULL,
    dependee_id text NOT NULL,
    is_template boolean DEFAULT false NOT NULL
);


ALTER TABLE prj.uow_dependency OWNER TO postgres;

--
-- Name: uow_history; Type: TABLE; Schema: prj; Owner: postgres
--

CREATE TABLE prj.uow_history (
    id text NOT NULL,
    project_id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    app_tenant_id text NOT NULL,
    identifier text,
    is_template boolean NOT NULL,
    name text,
    description text,
    type prj.uow_type,
    data jsonb,
    parent_uow_id text,
    status prj.uow_status_type NOT NULL,
    assigned_to_contact_project_role_id text,
    due_at timestamp with time zone,
    completed_at timestamp with time zone,
    workflow_handler_key text,
    use_worker boolean,
    workflow_error jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE prj.uow_history OWNER TO postgres;

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
2976553601335297515	2022-11-21 17:47:41.833674+00	Anchor Tenant	anchor	2976553601352074733	2976553601335297516	f	{}	anchor	\N	2976553601444349422	\N
2976553612349539835	2022-11-21 17:47:43.083409+00	Drainage Tenant	dng	2976553612366317053	2976553612349539836	f	{}	customer	2976553601335297515	2976553612433425918	\N
2976553621073692170	2022-11-21 17:47:44.190158+00	Address Book Tenant	address-book	2976553621073692172	2976553621073692171	f	{}	customer	2976553601335297515	2976553621073692173	\N
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
2976553601444349422	2022-11-21	\N	ask_admin	t	f	2976553601335297515	2976553600202835424	{}	\N
2976553612433425918	2022-11-21	\N	ask_admin	t	f	2976553612349539835	2976553600798426600	{}	\N
2976553621073692173	2022-11-21	\N	ask_admin	t	f	2976553621073692170	2976553600571934181	{}	\N
\.


--
-- Data for Name: app_user; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.app_user (id, app_tenant_id, ext_auth_id, ext_crm_id, contact_id, created_at, username, recovery_email, inactive, password_reset_required, permission_key, is_support, preferred_timezone, settings, ext_auth_blocked, language_id) FROM stdin;
2976553601654064624	2976553601335297515	\N	\N	2976553601645676015	2022-11-21 17:47:41.833674+00	appsuperadmin	stlbucket+function-bucket@gmail.com	f	f	SuperAdmin	f	PST8PDT	{}	f	en
2976553601863779828	2976553601335297515	\N	\N	2976553601863779827	2022-11-21 17:47:41.833674+00	fnb-support	help@function-bucket.com	f	f	Support	f	PST8PDT	{}	f	en
2976553601905722872	2976553601335297515	\N	\N	2976553601897334263	2022-11-21 17:47:41.833674+00	fnb-demo	demo@function-bucket.com	f	f	Demo	f	PST8PDT	{}	f	en
2976553616594175488	2976553612349539835	\N	\N	2976553616577398271	2022-11-21 17:47:43.593281+00	dng-admin	kevin+dng-admin@ourvisualbrain.com	f	f	User	f	PST8PDT	{}	f	en
2976553620863976966	2976553612349539835	\N	\N	2976553620847199749	2022-11-21 17:47:44.105483+00	dng-user	kevin+dng-user@ourvisualbrain.com	f	f	User	f	PST8PDT	{}	f	en
2976553624680793615	2976553621073692170	\N	\N	2976553624664016398	2022-11-21 17:47:44.569023+00	address-book-admin	kevin+address-book-admin@ourvisualbrain.com	f	f	User	f	PST8PDT	{}	f	en
2976553628497610261	2976553621073692170	\N	\N	2976553628480833044	2022-11-21 17:47:45.016312+00	address-book-user	kevin+address-book-user@ourvisualbrain.com	f	f	User	f	PST8PDT	{}	f	en
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
2976553601645676015	2976553601335297515	2022-11-21 17:47:41.833674+00	active	individual	\N	\N	kevin	Kevin	Burkett	stlbucket+function-bucket@gmail.com	\N	\N	\N	\N
2976553601863779827	2976553601335297515	2022-11-21 17:47:41.833674+00	active	individual	\N	\N	fnb-support	FNB	Support	help@function-bucket.com	\N	\N	\N	\N
2976553601897334263	2976553601335297515	2022-11-21 17:47:41.833674+00	active	individual	\N	\N	fnb-demo	FNB	Demo	demo@function-bucket.com	\N	\N	\N	\N
2976553616577398271	2976553612349539835	2022-11-21 17:47:43.593281+00	active	individual	\N	\N	\N	Drainage	Admin	kevin+dng-admin@ourvisualbrain.com	\N	\N	\N	\N
2976553620847199749	2976553612349539835	2022-11-21 17:47:44.105483+00	active	individual	\N	\N	\N	Drainage	User	kevin+dng-user@ourvisualbrain.com	\N	\N	\N	\N
2976553624664016398	2976553621073692170	2022-11-21 17:47:44.569023+00	active	individual	\N	\N	\N	Drainage	Admin	kevin+address-book-admin@ourvisualbrain.com	\N	\N	\N	\N
2976553628480833044	2976553621073692170	2022-11-21 17:47:45.016312+00	active	individual	\N	\N	\N	Drainage	User	kevin+address-book-user@ourvisualbrain.com	\N	\N	\N	\N
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
2976553601670841841	2976553601335297515	2976553601444349422	2022-11-21 17:47:41.833674+00	\N	Anchor Super Admin	anchor-super-admin	2976553601654064624	f	\N	active	initial	\N
2976553601872168437	2976553601335297515	2976553601444349422	2022-11-21 17:47:41.833674+00	\N	Anchor Support	anchor-support	2976553601863779828	f	\N	active	initial	\N
2976553601905722873	2976553601335297515	2976553601444349422	2022-11-21 17:47:41.833674+00	\N	Anchor Demo	anchor-demo	2976553601905722872	f	\N	active	initial	\N
2976553616627729921	2976553612349539835	2976553612433425918	2022-11-21 17:47:43.593281+00	\N	Address Book Admin	dng-admin	2976553616594175488	f	\N	active	initial	\N
2976553620889142791	2976553612349539835	2976553612433425918	2022-11-21 17:47:44.105483+00	\N	Address Book User	dng-user	2976553620863976966	f	2023-11-21	active	initial	\N
2976553624714348048	2976553621073692170	2976553621073692173	2022-11-21 17:47:44.569023+00	\N	Address Book Admin	address-book-admin	2976553624680793615	f	\N	active	initial	\N
2976553628531164694	2976553621073692170	2976553621073692173	2022-11-21 17:47:45.016312+00	\N	Address Book User	address-book-user	2976553628497610261	f	2023-11-21	active	initial	\N
\.


--
-- Data for Name: license_pack; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.license_pack (id, key, name, availability, created_at, published_at, discontinued_at, type, renewal_frequency, expiration_interval, expiration_interval_multiplier, explicit_expiration_date, price, upgrade_config, available_add_on_keys, coupon_code, is_public_offering, application_settings, implicit_add_on_keys) FROM stdin;
2976553600202835424	anchor	Anchor	published	2022-11-21 17:47:41.683768+00	2022-11-21 17:47:41.73634+00	\N	anchor	never	none	1	\N	0.00	({})	{}	\N	f	{}	{}
2976553600571934181	address-book	Address Book	published	2022-11-21 17:47:41.749826+00	2022-11-21 17:47:41.762811+00	\N	anchor	never	none	1	\N	0.00	({})	{}	\N	f	{}	{}
2976553600798426600	dng	Drainage	published	2022-11-21 17:47:41.77356+00	2022-11-21 17:47:41.788648+00	\N	anchor	never	none	1	\N	0.00	({})	{}	\N	f	{}	{}
\.


--
-- Data for Name: license_pack_license_type; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.license_pack_license_type (id, license_type_key, license_pack_id, license_count, assign_upon_subscription, unlimited_provision, expiration_interval, expiration_interval_multiplier, explicit_expiration_date) FROM stdin;
2976553600219612641	anchor-super-admin	2976553600202835424	0	f	t	none	1	\N
2976553600278332898	anchor-user	2976553600202835424	0	f	t	none	1	\N
2976553600286721507	anchor-support	2976553600202835424	0	f	t	none	1	\N
2976553600286721508	anchor-demo	2976553600202835424	0	f	t	none	1	\N
2976553600571934182	address-book-admin	2976553600571934181	0	t	t	none	1	\N
2976553600580322791	address-book-user	2976553600571934181	0	f	t	year	1	\N
2976553600798426601	dng-admin	2976553600798426600	0	t	t	none	1	\N
2976553600798426602	dng-user	2976553600798426600	0	f	t	year	1	\N
\.


--
-- Data for Name: license_permission; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.license_permission (id, app_tenant_id, created_at, license_id, permission_key) FROM stdin;
2976553601763116530	2976553601335297515	2022-11-21 17:47:41.833674+00	2976553601670841841	p:super-admin
2976553601872168438	2976553601335297515	2022-11-21 17:47:41.833674+00	2976553601872168437	p:support
2976553601905722874	2976553601335297515	2022-11-21 17:47:41.833674+00	2976553601905722873	p:demo
2976553616636118530	2976553612349539835	2022-11-21 17:47:43.593281+00	2976553616627729921	m:dng
2976553616644507139	2976553612349539835	2022-11-21 17:47:43.593281+00	2976553616627729921	m:dng-admin
2976553616644507140	2976553612349539835	2022-11-21 17:47:43.593281+00	2976553616627729921	p:dng-admin
2976553620905920008	2976553612349539835	2022-11-21 17:47:44.105483+00	2976553620889142791	m:dng
2976553620914308617	2976553612349539835	2022-11-21 17:47:44.105483+00	2976553620889142791	p:dng-user
2976553624722736657	2976553621073692170	2022-11-21 17:47:44.569023+00	2976553624714348048	m:address-book
2976553624731125266	2976553621073692170	2022-11-21 17:47:44.569023+00	2976553624714348048	m:address-book-admin
2976553624731125267	2976553621073692170	2022-11-21 17:47:44.569023+00	2976553624714348048	p:address-book-admin
2976553628547941911	2976553621073692170	2022-11-21 17:47:45.016312+00	2976553628531164694	m:address-book
2976553628547941912	2976553621073692170	2022-11-21 17:47:45.016312+00	2976553628531164694	p:address-book-user
\.


--
-- Data for Name: license_type; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.license_type (key, created_at, external_id, name, application_key, permission_key, sync_user_on_assignment) FROM stdin;
anchor-super-admin	2022-11-21 17:47:40.44423+00	\N	Anchor Super Admin	anchor	SuperAdmin	t
anchor-user	2022-11-21 17:47:40.44423+00	\N	Anchor User	anchor	User	t
anchor-support	2022-11-21 17:47:40.44423+00	\N	Anchor Support	anchor	User	t
anchor-demo	2022-11-21 17:47:40.44423+00	\N	Anchor Demo	anchor	User	t
address-book-admin	2022-11-21 17:47:40.490593+00	\N	Address Book Admin	address-book	User	t
address-book-user	2022-11-21 17:47:40.490593+00	\N	Address Book User	address-book	User	t
dng-admin	2022-11-21 17:47:40.502781+00	\N	Address Book Admin	dng	User	t
dng-user	2022-11-21 17:47:40.502781+00	\N	Address Book User	dng	User	t
\.


--
-- Data for Name: license_type_permission; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.license_type_permission (id, created_at, license_type_key, permission_key) FROM stdin;
2976553589826127314	2022-11-21 17:47:40.44423+00	anchor-super-admin	p:super-admin
2976553589884847571	2022-11-21 17:47:40.44423+00	anchor-user	p:anchor-user
2976553589893236180	2022-11-21 17:47:40.44423+00	anchor-support	p:support
2976553589893236181	2022-11-21 17:47:40.44423+00	anchor-demo	p:demo
2976553590002288086	2022-11-21 17:47:40.490593+00	address-book-admin	p:address-book-admin
2976553590010676695	2022-11-21 17:47:40.490593+00	address-book-admin	m:address-book-admin
2976553590010676696	2022-11-21 17:47:40.490593+00	address-book-admin	m:address-book
2976553590010676697	2022-11-21 17:47:40.490593+00	address-book-user	p:address-book-user
2976553590010676698	2022-11-21 17:47:40.490593+00	address-book-user	m:address-book
2976553590102951387	2022-11-21 17:47:40.502781+00	dng-admin	p:dng-admin
2976553590102951388	2022-11-21 17:47:40.502781+00	dng-admin	m:dng-admin
2976553590102951389	2022-11-21 17:47:40.502781+00	dng-admin	m:dng
2976553590102951390	2022-11-21 17:47:40.502781+00	dng-user	p:dng-user
2976553590111339999	2022-11-21 17:47:40.502781+00	dng-user	m:dng
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
2976553601352074733	2976553601335297515	2022-11-21 17:47:41.833674+00	anchor	Anchor Tenant	\N	\N
2976553612366317053	2976553612349539835	2022-11-21 17:47:43.083409+00	dng	Drainage Tenant	\N	\N
2976553621073692172	2976553621073692170	2022-11-21 17:47:44.190158+00	address-book	Address Book Tenant	\N	\N
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
-- Data for Name: content_slug; Type: TABLE DATA; Schema: appc; Owner: postgres
--

COPY appc.content_slug (id, type, entity_type, entity_identifier, key, description, content, data, created_at) FROM stdin;
\.


--
-- Data for Name: payment; Type: TABLE DATA; Schema: bill; Owner: postgres
--

COPY bill.payment (id, app_tenant_id, created_at, billing_date, payment_date, canceled_date, payment_method_id, amount, status, app_tenant_subscription_id) FROM stdin;
\.


--
-- Data for Name: payment_method; Type: TABLE DATA; Schema: bill; Owner: postgres
--

COPY bill.payment_method (id, app_tenant_id, created_at, identifier, name, external_identifier, status, expiration_date) FROM stdin;
\.


--
-- Data for Name: basin; Type: TABLE DATA; Schema: dng; Owner: postgres
--

COPY dng.basin (id, app_tenant_id, dng_project_id, created_at, name, analysis_method) FROM stdin;
\.


--
-- Data for Name: basin_travel_time; Type: TABLE DATA; Schema: dng; Owner: postgres
--

COPY dng.basin_travel_time (id, app_tenant_id, basin_id, created_at, name, length, slope, travel_time) FROM stdin;
\.


--
-- Data for Name: dng_node; Type: TABLE DATA; Schema: dng; Owner: postgres
--

COPY dng.dng_node (id, app_tenant_id, basin_id, created_at, name, northing, easting) FROM stdin;
\.


--
-- Data for Name: dng_project; Type: TABLE DATA; Schema: dng; Owner: postgres
--

COPY dng.dng_project (id, app_tenant_id, created_at, name) FROM stdin;
\.


--
-- Data for Name: flow; Type: TABLE DATA; Schema: dng; Owner: postgres
--

COPY dng.flow (id, app_tenant_id, travel_time_id, created_at, travel_time_material_id) FROM stdin;
\.


--
-- Data for Name: hydrualic_constraint; Type: TABLE DATA; Schema: dng; Owner: postgres
--

COPY dng.hydrualic_constraint (id, app_tenant_id, dng_node_id, storm_event_id, created_at, max_hgl, tailwater) FROM stdin;
\.


--
-- Data for Name: land_cover; Type: TABLE DATA; Schema: dng; Owner: postgres
--

COPY dng.land_cover (id, app_tenant_id, basin_id, created_at, name, area, curve_number) FROM stdin;
\.


--
-- Data for Name: reach; Type: TABLE DATA; Schema: dng; Owner: postgres
--

COPY dng.reach (id, app_tenant_id, created_at, name, reach_type_id, upstream_dng_node_id, upstream_invert_elevation, downstream_dng_node_id, downstream_invert_elevation, length) FROM stdin;
\.


--
-- Data for Name: reach_geometry; Type: TABLE DATA; Schema: dng; Owner: postgres
--

COPY dng.reach_geometry (id, name) FROM stdin;
circular	Circular Pipe
box	Box Pipe
ditch	Ditch
triangular	Gutter
\.


--
-- Data for Name: reach_geometry_dimension; Type: TABLE DATA; Schema: dng; Owner: postgres
--

COPY dng.reach_geometry_dimension (id, reach_geometry_id, reach_type_id, name, abbreviation, value, units) FROM stdin;
2976553636265461273	circular	\N	diameter	d	\N	cm
2976553636307404314	box	\N	length	l	\N	cm
2976553636307404315	box	\N	width	w	\N	cm
2976553636307404316	ditch	\N	bottom width	bw	\N	cm
2976553636307404317	ditch	\N	left slope	ls	\N	cm
2976553636307404318	ditch	\N	right slope	rs	\N	cm
\.


--
-- Data for Name: reach_material; Type: TABLE DATA; Schema: dng; Owner: postgres
--

COPY dng.reach_material (id, name) FROM stdin;
concrete	Concrete
cmp	CMP
pvc	PVC
cpep	CPEP
hdpe	Smooth HDPE
other	Other
\.


--
-- Data for Name: reach_type; Type: TABLE DATA; Schema: dng; Owner: postgres
--

COPY dng.reach_type (id, geometry_id, material_id, inlet_edge_description, ke, eq_form, k_unsubmerged, m_unsubmerged, c_submerged, y_submerged) FROM stdin;
2976553636408067615	circular	concrete	Square edge w/headwall	0.50	1	0.0098	2.0000	0.0398	0.6700
2976553636450010656	circular	concrete	Groove end w/headwall	0.20	1	0.0018	2.0000	0.0292	0.7400
2976553636450010657	circular	concrete	Groove end projecting	0.20	1	0.0045	2.0000	0.0317	0.6900
2976553636450010658	circular	cmp	Headwall	0.50	1	0.0078	2.0000	0.0379	0.6900
2976553636450010659	circular	cmp	Mitered to slope	0.70	1	0.0210	1.3300	0.0463	0.7500
2976553636450010660	circular	cmp	Projecting (no headwall)	0.90	1	0.0340	1.5000	0.0553	0.5400
2976553636450010661	circular	other	Beveled ring, 45... bevels	0.20	1	0.0018	2.5000	0.0300	0.7400
2976553636450010662	circular	other	Beveled ring, 33.7... bevels	0.20	1	0.0018	2.5000	0.0243	0.8300
2976553636450010663	box	concrete	30... to 70... wingwall flares	0.40	1	0.0260	1.0000	0.0347	0.8100
2976553636450010664	box	concrete	90... and 15... wingwall flares	0.50	1	0.0610	0.7500	0.0400	0.8000
2976553636450010665	box	concrete	0... wingwall flares	0.70	1	0.0610	0.7500	0.0423	0.8200
2976553636450010666	box	concrete	45... wingwall flare	0.40	2	0.5100	0.6670	0.0309	0.8000
2976553636450010667	box	concrete	18... and 25... wingwall flare	0.50	2	0.4860	0.6670	0.0249	0.8300
2976553636450010668	box	concrete	25... and 33.7... wingwall flare	0.40	2	0.4860	0.6670	0.0249	0.8300
2976553636450010669	box	concrete	90... headwall with 3/4" chamfers	0.50	2	0.5150	0.6670	0.0375	0.7900
2976553636450010670	box	concrete	90... headwall with 45... bevels	0.50	2	0.4950	0.6670	0.0314	0.8200
2976553636450010671	box	concrete	90... headwall with 33.7... bevels	0.50	2	0.4860	0.6670	0.0252	0.8650
\.


--
-- Data for Name: storm_event; Type: TABLE DATA; Schema: dng; Owner: postgres
--

COPY dng.storm_event (id, app_tenant_id, dng_project_id, created_at, name, precipitation, rainfall_type) FROM stdin;
\.


--
-- Data for Name: travel_time_material; Type: TABLE DATA; Schema: dng; Owner: postgres
--

COPY dng.travel_time_material (id, flow_type, name) FROM stdin;
2976553636483565104	sheet	Concrete, asphalt, gravel
2976553636533896753	sheet	Short grass and lawns
2976553636533896754	sheet	Dense grasses
2976553636533896755	sheet	Bermuda grass
2976553636533896756	sheet	Range (natural)
2976553636533896757	sheet	Woods or forest with light underbrush
2976553636533896758	sheet	Woods or forest with dense underbrush
2976553636533896759	shallow	Forest with heavy ground litter and meadows (n=0.10)
2976553636533896760	shallow	Brushy ground with some trees (n=0.06)
2976553636533896761	shallow	High grass (n=0.035)
2976553636533896762	shallow	Short grass, pasture or lawn (0.03)
2976553636533896763	shallow	Bare ground (n=0.25)
2976553636533896764	shallow	Paved or gravel (n=0.012)
2976553636533896765	channel	Forested swale with heavy ground litter (n=0.10)
2976553636533896766	channel	Forested drainage course with defined channel bed (n=0.05)
2976553636533896767	channel	Rock-lined waterway (n=0.035)
2976553636533896768	channel	Grassed waterway (n=0.03)
2976553636533896769	channel	Earth-lined waterway (n=0.025)
2976553636533896770	channel	CMP pipe (n=0.024)
2976553636533896771	channel	Concrete pipe (n=0.012)
2976553636533896772	channel	Meandering stream with some pools (n=0.04)
2976553636533896773	channel	Rock-lined stream (n=0.035)
2976553636533896774	channel	Grass-lined stream (n=0.03)
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
-- Data for Name: contact_project_role; Type: TABLE DATA; Schema: prj; Owner: postgres
--

COPY prj.contact_project_role (id, app_tenant_id, name, project_id, contact_id, project_role_id, assignment_timestampz, un_assignment_timestampz, is_template) FROM stdin;
\.


--
-- Data for Name: project; Type: TABLE DATA; Schema: prj; Owner: postgres
--

COPY prj.project (id, uow_id, created_at, updated_at, identifier, app_tenant_id, name, type, is_template, managed_by_contact_project_role_id, workflow_data, workflow_input_definition) FROM stdin;
\.


--
-- Data for Name: project_history; Type: TABLE DATA; Schema: prj; Owner: postgres
--

COPY prj.project_history (id, uow_id, created_at, updated_at, identifier, app_tenant_id, name, type, is_template, managed_by_contact_project_role_id, workflow_data, workflow_input_definition) FROM stdin;
\.


--
-- Data for Name: project_role; Type: TABLE DATA; Schema: prj; Owner: postgres
--

COPY prj.project_role (id, name, key, config) FROM stdin;
\.


--
-- Data for Name: project_type; Type: TABLE DATA; Schema: prj; Owner: postgres
--

COPY prj.project_type (id) FROM stdin;
\.


--
-- Data for Name: uow; Type: TABLE DATA; Schema: prj; Owner: postgres
--

COPY prj.uow (id, project_id, created_at, updated_at, app_tenant_id, identifier, is_template, name, description, type, data, parent_uow_id, status, assigned_to_contact_project_role_id, due_at, completed_at, workflow_handler_key, use_worker, workflow_error) FROM stdin;
\.


--
-- Data for Name: uow_dependency; Type: TABLE DATA; Schema: prj; Owner: postgres
--

COPY prj.uow_dependency (id, app_tenant_id, depender_id, dependee_id, is_template) FROM stdin;
\.


--
-- Data for Name: uow_history; Type: TABLE DATA; Schema: prj; Owner: postgres
--

COPY prj.uow_history (id, project_id, created_at, updated_at, app_tenant_id, identifier, is_template, name, description, type, data, parent_uow_id, status, assigned_to_contact_project_role_id, due_at, completed_at, workflow_handler_key, use_worker, workflow_error) FROM stdin;
\.


--
-- Name: global_id_sequence; Type: SEQUENCE SET; Schema: shard_1; Owner: postgres
--

SELECT pg_catalog.setval('shard_1.global_id_sequence', 2631, true);


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
-- Name: content_slug pk_content_slug; Type: CONSTRAINT; Schema: appc; Owner: postgres
--

ALTER TABLE ONLY appc.content_slug
    ADD CONSTRAINT pk_content_slug PRIMARY KEY (id);


--
-- Name: content_slug uq_content_slug; Type: CONSTRAINT; Schema: appc; Owner: postgres
--

ALTER TABLE ONLY appc.content_slug
    ADD CONSTRAINT uq_content_slug UNIQUE (entity_type, entity_identifier, key);


--
-- Name: payment pk_payment; Type: CONSTRAINT; Schema: bill; Owner: postgres
--

ALTER TABLE ONLY bill.payment
    ADD CONSTRAINT pk_payment PRIMARY KEY (id);


--
-- Name: payment_method pk_payment_method; Type: CONSTRAINT; Schema: bill; Owner: postgres
--

ALTER TABLE ONLY bill.payment_method
    ADD CONSTRAINT pk_payment_method PRIMARY KEY (id);


--
-- Name: payment uq_payment; Type: CONSTRAINT; Schema: bill; Owner: postgres
--

ALTER TABLE ONLY bill.payment
    ADD CONSTRAINT uq_payment UNIQUE (app_tenant_subscription_id, billing_date);


--
-- Name: dng_node dng_node_basin_id_key; Type: CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.dng_node
    ADD CONSTRAINT dng_node_basin_id_key UNIQUE (basin_id);


--
-- Name: basin pk_basin; Type: CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.basin
    ADD CONSTRAINT pk_basin PRIMARY KEY (id);


--
-- Name: dng_node pk_dng_node; Type: CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.dng_node
    ADD CONSTRAINT pk_dng_node PRIMARY KEY (id);


--
-- Name: dng_project pk_dng_project; Type: CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.dng_project
    ADD CONSTRAINT pk_dng_project PRIMARY KEY (id);


--
-- Name: flow pk_flow; Type: CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.flow
    ADD CONSTRAINT pk_flow PRIMARY KEY (id);


--
-- Name: hydrualic_constraint pk_hydrualic_constraint; Type: CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.hydrualic_constraint
    ADD CONSTRAINT pk_hydrualic_constraint PRIMARY KEY (id);


--
-- Name: land_cover pk_land_cover; Type: CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.land_cover
    ADD CONSTRAINT pk_land_cover PRIMARY KEY (id);


--
-- Name: reach pk_reach; Type: CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.reach
    ADD CONSTRAINT pk_reach PRIMARY KEY (id);


--
-- Name: reach_geometry pk_reach_geometry; Type: CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.reach_geometry
    ADD CONSTRAINT pk_reach_geometry PRIMARY KEY (id);


--
-- Name: reach_geometry_dimension pk_reach_geometry_dimension; Type: CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.reach_geometry_dimension
    ADD CONSTRAINT pk_reach_geometry_dimension PRIMARY KEY (id);


--
-- Name: reach_material pk_reach_material; Type: CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.reach_material
    ADD CONSTRAINT pk_reach_material PRIMARY KEY (id);


--
-- Name: reach_type pk_reach_type; Type: CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.reach_type
    ADD CONSTRAINT pk_reach_type PRIMARY KEY (id);


--
-- Name: storm_event pk_storm_event; Type: CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.storm_event
    ADD CONSTRAINT pk_storm_event PRIMARY KEY (id);


--
-- Name: basin_travel_time pk_travel_time; Type: CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.basin_travel_time
    ADD CONSTRAINT pk_travel_time PRIMARY KEY (id);


--
-- Name: travel_time_material pk_travel_time_material; Type: CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.travel_time_material
    ADD CONSTRAINT pk_travel_time_material PRIMARY KEY (id);


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
-- Name: contact_project_role pk_contact_project_role; Type: CONSTRAINT; Schema: prj; Owner: postgres
--

ALTER TABLE ONLY prj.contact_project_role
    ADD CONSTRAINT pk_contact_project_role PRIMARY KEY (id);


--
-- Name: project pk_project; Type: CONSTRAINT; Schema: prj; Owner: postgres
--

ALTER TABLE ONLY prj.project
    ADD CONSTRAINT pk_project PRIMARY KEY (id);


--
-- Name: project_role pk_project_role; Type: CONSTRAINT; Schema: prj; Owner: postgres
--

ALTER TABLE ONLY prj.project_role
    ADD CONSTRAINT pk_project_role PRIMARY KEY (id);


--
-- Name: project_type pk_project_type; Type: CONSTRAINT; Schema: prj; Owner: postgres
--

ALTER TABLE ONLY prj.project_type
    ADD CONSTRAINT pk_project_type PRIMARY KEY (id);


--
-- Name: uow pk_uow; Type: CONSTRAINT; Schema: prj; Owner: postgres
--

ALTER TABLE ONLY prj.uow
    ADD CONSTRAINT pk_uow PRIMARY KEY (id);


--
-- Name: uow_dependency pk_uow_dependency; Type: CONSTRAINT; Schema: prj; Owner: postgres
--

ALTER TABLE ONLY prj.uow_dependency
    ADD CONSTRAINT pk_uow_dependency PRIMARY KEY (id);


--
-- Name: project_role project_role_key_key; Type: CONSTRAINT; Schema: prj; Owner: postgres
--

ALTER TABLE ONLY prj.project_role
    ADD CONSTRAINT project_role_key_key UNIQUE (key);


--
-- Name: project uq_project_uow; Type: CONSTRAINT; Schema: prj; Owner: postgres
--

ALTER TABLE ONLY prj.project
    ADD CONSTRAINT uq_project_uow UNIQUE (uow_id);


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
-- Name: idx_content_slug_entity; Type: INDEX; Schema: appc; Owner: postgres
--

CREATE INDEX idx_content_slug_entity ON appc.content_slug USING btree (entity_identifier);


--
-- Name: idx_bill_payment_payment_method; Type: INDEX; Schema: bill; Owner: postgres
--

CREATE INDEX idx_bill_payment_payment_method ON bill.payment USING btree (payment_method_id);


--
-- Name: idx_payment_app_tenant_id; Type: INDEX; Schema: bill; Owner: postgres
--

CREATE INDEX idx_payment_app_tenant_id ON bill.payment USING btree (app_tenant_id);


--
-- Name: idx_payment_method_active; Type: INDEX; Schema: bill; Owner: postgres
--

CREATE UNIQUE INDEX idx_payment_method_active ON bill.payment_method USING btree (app_tenant_id, status) WHERE (status = 'active'::bill.payment_method_status);


--
-- Name: idx_payment_method_app_tenant; Type: INDEX; Schema: bill; Owner: postgres
--

CREATE INDEX idx_payment_method_app_tenant ON bill.payment_method USING btree (app_tenant_id);


--
-- Name: idx_uq_geometry_dimension_template; Type: INDEX; Schema: dng; Owner: postgres
--

CREATE UNIQUE INDEX idx_uq_geometry_dimension_template ON dng.reach_geometry_dimension USING btree (reach_geometry_id, name) WHERE (reach_type_id IS NULL);


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
-- Name: idx_contact_project_role_app_tenant; Type: INDEX; Schema: prj; Owner: postgres
--

CREATE INDEX idx_contact_project_role_app_tenant ON prj.contact_project_role USING btree (app_tenant_id);


--
-- Name: idx_contact_project_role_contact; Type: INDEX; Schema: prj; Owner: postgres
--

CREATE INDEX idx_contact_project_role_contact ON prj.contact_project_role USING btree (contact_id);


--
-- Name: idx_contact_project_role_project; Type: INDEX; Schema: prj; Owner: postgres
--

CREATE INDEX idx_contact_project_role_project ON prj.contact_project_role USING btree (project_id);


--
-- Name: idx_contact_project_role_role; Type: INDEX; Schema: prj; Owner: postgres
--

CREATE INDEX idx_contact_project_role_role ON prj.contact_project_role USING btree (project_role_id);


--
-- Name: idx_prj_project_managed_by_contact_project_role_id; Type: INDEX; Schema: prj; Owner: postgres
--

CREATE INDEX idx_prj_project_managed_by_contact_project_role_id ON prj.project USING btree (managed_by_contact_project_role_id);


--
-- Name: idx_prj_project_type; Type: INDEX; Schema: prj; Owner: postgres
--

CREATE INDEX idx_prj_project_type ON prj.project USING btree (type);


--
-- Name: idx_project_app_tenant; Type: INDEX; Schema: prj; Owner: postgres
--

CREATE INDEX idx_project_app_tenant ON prj.project USING btree (app_tenant_id);


--
-- Name: idx_project_uow; Type: INDEX; Schema: prj; Owner: postgres
--

CREATE INDEX idx_project_uow ON prj.project USING btree (uow_id);


--
-- Name: idx_unique_project_template; Type: INDEX; Schema: prj; Owner: postgres
--

CREATE UNIQUE INDEX idx_unique_project_template ON prj.project USING btree (app_tenant_id, identifier) WHERE (is_template = true);


--
-- Name: idx_uow_app_tenant; Type: INDEX; Schema: prj; Owner: postgres
--

CREATE INDEX idx_uow_app_tenant ON prj.uow USING btree (app_tenant_id);


--
-- Name: idx_uow_assigned_to_contact_role; Type: INDEX; Schema: prj; Owner: postgres
--

CREATE INDEX idx_uow_assigned_to_contact_role ON prj.uow USING btree (assigned_to_contact_project_role_id);


--
-- Name: idx_uow_dependency_app_tenant; Type: INDEX; Schema: prj; Owner: postgres
--

CREATE INDEX idx_uow_dependency_app_tenant ON prj.uow_dependency USING btree (app_tenant_id);


--
-- Name: idx_uow_dependency_dependee; Type: INDEX; Schema: prj; Owner: postgres
--

CREATE INDEX idx_uow_dependency_dependee ON prj.uow_dependency USING btree (dependee_id);


--
-- Name: idx_uow_dependency_depender; Type: INDEX; Schema: prj; Owner: postgres
--

CREATE INDEX idx_uow_dependency_depender ON prj.uow_dependency USING btree (depender_id);


--
-- Name: idx_uow_parent_uow; Type: INDEX; Schema: prj; Owner: postgres
--

CREATE INDEX idx_uow_parent_uow ON prj.uow USING btree (parent_uow_id);


--
-- Name: idx_uow_project; Type: INDEX; Schema: prj; Owner: postgres
--

CREATE INDEX idx_uow_project ON prj.uow USING btree (project_id);


--
-- Name: idx_uow_project_project; Type: INDEX; Schema: prj; Owner: postgres
--

CREATE UNIQUE INDEX idx_uow_project_project ON prj.uow USING btree (project_id) WHERE (type = 'project'::prj.uow_type);


--
-- Name: idx_wf_app_user_id; Type: INDEX; Schema: prj; Owner: postgres
--

CREATE INDEX idx_wf_app_user_id ON prj.project USING gin (((workflow_data #> '{workflowInputData,appUserId}'::text[])));


--
-- Name: idx_wf_input_data; Type: INDEX; Schema: prj; Owner: postgres
--

CREATE INDEX idx_wf_input_data ON prj.project USING gin (((workflow_data #> '{workflowInputData}'::text[])));


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
-- Name: project tg_before_update_project; Type: TRIGGER; Schema: prj; Owner: postgres
--

CREATE TRIGGER tg_before_update_project BEFORE UPDATE ON prj.project FOR EACH ROW EXECUTE FUNCTION prj.fn_before_update_project();


--
-- Name: uow tg_before_update_uow; Type: TRIGGER; Schema: prj; Owner: postgres
--

CREATE TRIGGER tg_before_update_uow BEFORE UPDATE ON prj.uow FOR EACH ROW EXECUTE FUNCTION prj.fn_before_update_uow();


--
-- Name: project tg_capture_hist_project; Type: TRIGGER; Schema: prj; Owner: postgres
--

CREATE TRIGGER tg_capture_hist_project AFTER UPDATE ON prj.project FOR EACH ROW EXECUTE FUNCTION prj.fn_capture_hist_project();


--
-- Name: uow tg_capture_hist_uow; Type: TRIGGER; Schema: prj; Owner: postgres
--

CREATE TRIGGER tg_capture_hist_uow AFTER UPDATE ON prj.uow FOR EACH ROW EXECUTE FUNCTION prj.fn_capture_hist_uow();


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
-- Name: payment fk_payment_app_tenant; Type: FK CONSTRAINT; Schema: bill; Owner: postgres
--

ALTER TABLE ONLY bill.payment
    ADD CONSTRAINT fk_payment_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: payment fk_payment_payment_method_id; Type: FK CONSTRAINT; Schema: bill; Owner: postgres
--

ALTER TABLE ONLY bill.payment
    ADD CONSTRAINT fk_payment_payment_method_id FOREIGN KEY (payment_method_id) REFERENCES bill.payment_method(id);


--
-- Name: payment fk_payment_subscription; Type: FK CONSTRAINT; Schema: bill; Owner: postgres
--

ALTER TABLE ONLY bill.payment
    ADD CONSTRAINT fk_payment_subscription FOREIGN KEY (app_tenant_subscription_id) REFERENCES app.app_tenant_subscription(id);


--
-- Name: basin fk_basin_app_tenant; Type: FK CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.basin
    ADD CONSTRAINT fk_basin_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: basin fk_basin_dng_project; Type: FK CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.basin
    ADD CONSTRAINT fk_basin_dng_project FOREIGN KEY (dng_project_id) REFERENCES dng.dng_project(id);


--
-- Name: dng_node fk_dng_node_basin; Type: FK CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.dng_node
    ADD CONSTRAINT fk_dng_node_basin FOREIGN KEY (basin_id) REFERENCES dng.basin(id);


--
-- Name: dng_project fk_dng_project_app_tenant; Type: FK CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.dng_project
    ADD CONSTRAINT fk_dng_project_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: flow fk_flow_app_tenant; Type: FK CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.flow
    ADD CONSTRAINT fk_flow_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: flow fk_flow_travel_time; Type: FK CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.flow
    ADD CONSTRAINT fk_flow_travel_time FOREIGN KEY (travel_time_id) REFERENCES dng.basin_travel_time(id);


--
-- Name: flow fk_flow_travel_time_material; Type: FK CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.flow
    ADD CONSTRAINT fk_flow_travel_time_material FOREIGN KEY (travel_time_material_id) REFERENCES dng.travel_time_material(id);


--
-- Name: hydrualic_constraint fk_hydrualic_constraint_dng_node; Type: FK CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.hydrualic_constraint
    ADD CONSTRAINT fk_hydrualic_constraint_dng_node FOREIGN KEY (dng_node_id) REFERENCES dng.dng_node(id);


--
-- Name: hydrualic_constraint fk_hydrualic_constraint_storm_event; Type: FK CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.hydrualic_constraint
    ADD CONSTRAINT fk_hydrualic_constraint_storm_event FOREIGN KEY (storm_event_id) REFERENCES dng.storm_event(id);


--
-- Name: land_cover fk_land_cover_app_tenant; Type: FK CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.land_cover
    ADD CONSTRAINT fk_land_cover_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: land_cover fk_land_cover_basin; Type: FK CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.land_cover
    ADD CONSTRAINT fk_land_cover_basin FOREIGN KEY (basin_id) REFERENCES dng.basin(id);


--
-- Name: reach fk_reach_downstream_dng_node; Type: FK CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.reach
    ADD CONSTRAINT fk_reach_downstream_dng_node FOREIGN KEY (downstream_dng_node_id) REFERENCES dng.dng_node(id);


--
-- Name: reach_geometry_dimension fk_reach_geometry_dimension_geometry; Type: FK CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.reach_geometry_dimension
    ADD CONSTRAINT fk_reach_geometry_dimension_geometry FOREIGN KEY (reach_geometry_id) REFERENCES dng.reach_geometry(id);


--
-- Name: reach_geometry_dimension fk_reach_geometry_dimension_reach_type; Type: FK CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.reach_geometry_dimension
    ADD CONSTRAINT fk_reach_geometry_dimension_reach_type FOREIGN KEY (reach_type_id) REFERENCES dng.reach_type(id);


--
-- Name: reach fk_reach_reach_type; Type: FK CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.reach
    ADD CONSTRAINT fk_reach_reach_type FOREIGN KEY (reach_type_id) REFERENCES dng.reach_type(id);


--
-- Name: reach_type fk_reach_type_geometry; Type: FK CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.reach_type
    ADD CONSTRAINT fk_reach_type_geometry FOREIGN KEY (geometry_id) REFERENCES dng.reach_geometry(id);


--
-- Name: reach_type fk_reach_type_material; Type: FK CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.reach_type
    ADD CONSTRAINT fk_reach_type_material FOREIGN KEY (material_id) REFERENCES dng.reach_material(id);


--
-- Name: reach fk_reach_upstream_dng_node; Type: FK CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.reach
    ADD CONSTRAINT fk_reach_upstream_dng_node FOREIGN KEY (upstream_dng_node_id) REFERENCES dng.dng_node(id);


--
-- Name: storm_event fk_storm_event_app_tenant; Type: FK CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.storm_event
    ADD CONSTRAINT fk_storm_event_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: storm_event fk_storm_event_dng_project; Type: FK CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.storm_event
    ADD CONSTRAINT fk_storm_event_dng_project FOREIGN KEY (dng_project_id) REFERENCES dng.dng_project(id);


--
-- Name: basin_travel_time fk_travel_time_app_tenant; Type: FK CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.basin_travel_time
    ADD CONSTRAINT fk_travel_time_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: basin_travel_time fk_travel_time_basin; Type: FK CONSTRAINT; Schema: dng; Owner: postgres
--

ALTER TABLE ONLY dng.basin_travel_time
    ADD CONSTRAINT fk_travel_time_basin FOREIGN KEY (basin_id) REFERENCES dng.basin(id);


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
-- Name: contact_project_role fk_contact_project_role_app_tenant; Type: FK CONSTRAINT; Schema: prj; Owner: postgres
--

ALTER TABLE ONLY prj.contact_project_role
    ADD CONSTRAINT fk_contact_project_role_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: contact_project_role fk_contact_project_role_contact; Type: FK CONSTRAINT; Schema: prj; Owner: postgres
--

ALTER TABLE ONLY prj.contact_project_role
    ADD CONSTRAINT fk_contact_project_role_contact FOREIGN KEY (contact_id) REFERENCES app.contact(id);


--
-- Name: contact_project_role fk_contact_project_role_project; Type: FK CONSTRAINT; Schema: prj; Owner: postgres
--

ALTER TABLE ONLY prj.contact_project_role
    ADD CONSTRAINT fk_contact_project_role_project FOREIGN KEY (project_id) REFERENCES prj.project(id);


--
-- Name: contact_project_role fk_contact_project_role_role; Type: FK CONSTRAINT; Schema: prj; Owner: postgres
--

ALTER TABLE ONLY prj.contact_project_role
    ADD CONSTRAINT fk_contact_project_role_role FOREIGN KEY (project_role_id) REFERENCES prj.project_role(id);


--
-- Name: project fk_project_app_tenant; Type: FK CONSTRAINT; Schema: prj; Owner: postgres
--

ALTER TABLE ONLY prj.project
    ADD CONSTRAINT fk_project_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: project fk_project_managed_by_contact_project_role; Type: FK CONSTRAINT; Schema: prj; Owner: postgres
--

ALTER TABLE ONLY prj.project
    ADD CONSTRAINT fk_project_managed_by_contact_project_role FOREIGN KEY (managed_by_contact_project_role_id) REFERENCES prj.contact_project_role(id);


--
-- Name: project fk_project_type; Type: FK CONSTRAINT; Schema: prj; Owner: postgres
--

ALTER TABLE ONLY prj.project
    ADD CONSTRAINT fk_project_type FOREIGN KEY (type) REFERENCES prj.project_type(id);


--
-- Name: project fk_project_uow; Type: FK CONSTRAINT; Schema: prj; Owner: postgres
--

ALTER TABLE ONLY prj.project
    ADD CONSTRAINT fk_project_uow FOREIGN KEY (uow_id) REFERENCES prj.uow(id);


--
-- Name: uow fk_uow_app_tenant; Type: FK CONSTRAINT; Schema: prj; Owner: postgres
--

ALTER TABLE ONLY prj.uow
    ADD CONSTRAINT fk_uow_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES app.app_tenant(id);


--
-- Name: uow fk_uow_assigned_to_contact_project_role; Type: FK CONSTRAINT; Schema: prj; Owner: postgres
--

ALTER TABLE ONLY prj.uow
    ADD CONSTRAINT fk_uow_assigned_to_contact_project_role FOREIGN KEY (assigned_to_contact_project_role_id) REFERENCES prj.contact_project_role(id);


--
-- Name: uow_dependency fk_uow_dependency_dependee; Type: FK CONSTRAINT; Schema: prj; Owner: postgres
--

ALTER TABLE ONLY prj.uow_dependency
    ADD CONSTRAINT fk_uow_dependency_dependee FOREIGN KEY (dependee_id) REFERENCES prj.uow(id);


--
-- Name: uow_dependency fk_uow_dependency_depender; Type: FK CONSTRAINT; Schema: prj; Owner: postgres
--

ALTER TABLE ONLY prj.uow_dependency
    ADD CONSTRAINT fk_uow_dependency_depender FOREIGN KEY (depender_id) REFERENCES prj.uow(id);


--
-- Name: uow fk_uow_parent; Type: FK CONSTRAINT; Schema: prj; Owner: postgres
--

ALTER TABLE ONLY prj.uow
    ADD CONSTRAINT fk_uow_parent FOREIGN KEY (parent_uow_id) REFERENCES prj.uow(id);


--
-- Name: uow fk_uow_project; Type: FK CONSTRAINT; Schema: prj; Owner: postgres
--

ALTER TABLE ONLY prj.uow
    ADD CONSTRAINT fk_uow_project FOREIGN KEY (project_id) REFERENCES prj.project(id);


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
-- Name: FUNCTION set_content_slug_current_version_set(_content_slug_id text, _version_identifier text); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.set_content_slug_current_version_set(_content_slug_id text, _version_identifier text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.set_content_slug_current_version_set(_content_slug_id text, _version_identifier text) TO app_usr;


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
-- Name: FUNCTION upsert_content_slug(_content_slug_info app_fn.content_slug_info); Type: ACL; Schema: app_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION app_fn.upsert_content_slug(_content_slug_info app_fn.content_slug_info) FROM PUBLIC;
GRANT ALL ON FUNCTION app_fn.upsert_content_slug(_content_slug_info app_fn.content_slug_info) TO app_usr;


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

