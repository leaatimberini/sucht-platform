--
-- PostgreSQL database dump
--

-- Dumped from database version 14.18 (Ubuntu 14.18-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.18 (Ubuntu 14.18-0ubuntu0.22.04.1)

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
-- Name: ticket_tiers_producttype_enum; Type: TYPE; Schema: public; Owner: sucht_user
--

CREATE TYPE public.ticket_tiers_producttype_enum AS ENUM (
    'ticket',
    'vip_table',
    'voucher'
);


ALTER TYPE public.ticket_tiers_producttype_enum OWNER TO sucht_user;

--
-- Name: tickets_status_enum; Type: TYPE; Schema: public; Owner: sucht_user
--

CREATE TYPE public.tickets_status_enum AS ENUM (
    'valid',
    'used',
    'partially_used',
    'invalid',
    'partially_paid'
);


ALTER TYPE public.tickets_status_enum OWNER TO sucht_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: configurations; Type: TABLE; Schema: public; Owner: sucht_user
--

CREATE TABLE public.configurations (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    key character varying NOT NULL,
    value character varying NOT NULL
);


ALTER TABLE public.configurations OWNER TO sucht_user;

--
-- Name: events; Type: TABLE; Schema: public; Owner: sucht_user
--

CREATE TABLE public.events (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    title character varying NOT NULL,
    description text,
    location character varying NOT NULL,
    "startDate" timestamp without time zone NOT NULL,
    "endDate" timestamp without time zone NOT NULL,
    "flyerImageUrl" character varying,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "confirmationSentAt" timestamp without time zone
);


ALTER TABLE public.events OWNER TO sucht_user;

--
-- Name: migrations; Type: TABLE; Schema: public; Owner: sucht_user
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    "timestamp" bigint NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.migrations OWNER TO sucht_user;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: sucht_user
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.migrations_id_seq OWNER TO sucht_user;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sucht_user
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: push_subscriptions; Type: TABLE; Schema: public; Owner: sucht_user
--

CREATE TABLE public.push_subscriptions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    endpoint character varying NOT NULL,
    p256dh character varying NOT NULL,
    auth character varying NOT NULL,
    "userId" uuid
);


ALTER TABLE public.push_subscriptions OWNER TO sucht_user;

--
-- Name: ticket_tiers; Type: TABLE; Schema: public; Owner: sucht_user
--

CREATE TABLE public.ticket_tiers (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    price numeric(10,2) NOT NULL,
    quantity integer NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "eventId" uuid,
    "validUntil" timestamp without time zone,
    "productType" public.ticket_tiers_producttype_enum DEFAULT 'ticket'::public.ticket_tiers_producttype_enum NOT NULL,
    "allowPartialPayment" boolean DEFAULT false NOT NULL,
    "partialPaymentPrice" numeric(10,2)
);


ALTER TABLE public.ticket_tiers OWNER TO sucht_user;

--
-- Name: tickets; Type: TABLE; Schema: public; Owner: sucht_user
--

CREATE TABLE public.tickets (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    status public.tickets_status_enum DEFAULT 'valid'::public.tickets_status_enum NOT NULL,
    "validatedAt" timestamp without time zone,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "userId" uuid,
    "eventId" uuid,
    "tierId" uuid,
    quantity integer DEFAULT 1 NOT NULL,
    "redeemedCount" integer DEFAULT 0 NOT NULL,
    "confirmedAt" timestamp without time zone,
    "promoterId" uuid,
    "reminderSentAt" timestamp without time zone,
    "amountPaid" numeric(10,2) DEFAULT '0'::numeric NOT NULL
);


ALTER TABLE public.tickets OWNER TO sucht_user;

--
-- Name: users; Type: TABLE; Schema: public; Owner: sucht_user
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email character varying NOT NULL,
    password character varying,
    name character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "invitationToken" character varying,
    "profileImageUrl" character varying,
    "instagramHandle" character varying,
    "whatsappNumber" character varying,
    "dateOfBirth" date,
    username character varying,
    "mercadoPagoAccessToken" character varying,
    "rrppCommissionRate" numeric(5,2),
    roles text DEFAULT '["client"]'::text NOT NULL
);


ALTER TABLE public.users OWNER TO sucht_user;

--
-- Name: users_backup; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_backup (
    id uuid,
    email character varying,
    password character varying,
    name character varying,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone,
    "invitationToken" character varying,
    "profileImageUrl" character varying,
    "instagramHandle" character varying,
    "whatsappNumber" character varying,
    "dateOfBirth" date,
    username character varying,
    "mercadoPagoAccessToken" character varying,
    "rrppCommissionRate" numeric(5,2),
    roles text
);


ALTER TABLE public.users_backup OWNER TO postgres;

--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: sucht_user
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Data for Name: configurations; Type: TABLE DATA; Schema: public; Owner: sucht_user
--

COPY public.configurations (id, key, value) FROM stdin;
26efac0f-eb82-4399-a11c-e7b380919452	adminServiceFee	0
d1ee0463-db1d-4e3d-a550-8aa00e2183ef	paymentsEnabled	false
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: sucht_user
--

COPY public.events (id, title, description, location, "startDate", "endDate", "flyerImageUrl", "createdAt", "updatedAt", "confirmationSentAt") FROM stdin;
72e8d314-aa0f-4606-853c-1ee62fc5acec	02.08 ~ Sábado de SUCHT!	Te esperamos el Sábado a partir de las 02hs!\r\nIngreso FREE hasta las 02:30 hs sacando el QR.\r\n\r\nTe esperamos! +18	Gdor Inocencio Arias 2998, Castelar	2025-08-03 01:30:00	2025-08-03 06:30:00	https://res.cloudinary.com/di4ikaeke/image/upload/v1753799979/sucht/events/irf76xrsfnlv4bpvsler.jpg	2025-07-29 14:39:40.074163	2025-07-29 14:39:40.074163	\N
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: sucht_user
--

COPY public.migrations (id, "timestamp", name) FROM stdin;
1	1754005211469	AddAdvancedProducts1754005211469
\.


--
-- Data for Name: push_subscriptions; Type: TABLE DATA; Schema: public; Owner: sucht_user
--

COPY public.push_subscriptions (id, endpoint, p256dh, auth, "userId") FROM stdin;
\.


--
-- Data for Name: ticket_tiers; Type: TABLE DATA; Schema: public; Owner: sucht_user
--

COPY public.ticket_tiers (id, name, price, quantity, "createdAt", "updatedAt", "eventId", "validUntil", "productType", "allowPartialPayment", "partialPaymentPrice") FROM stdin;
53576570-7ecf-4d86-8a45-fad9221fa8ef	Ingreso FREE hasta las 02:30hs	0.00	31	2025-07-29 14:40:13.530051	2025-08-01 17:50:47.91184	72e8d314-aa0f-4606-853c-1ee62fc5acec	2025-08-03 03:00:00	ticket	f	\N
\.


--
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: sucht_user
--

COPY public.tickets (id, status, "validatedAt", "createdAt", "updatedAt", "userId", "eventId", "tierId", quantity, "redeemedCount", "confirmedAt", "promoterId", "reminderSentAt", "amountPaid") FROM stdin;
4f548d44-516d-49c0-a7de-7c5b19601505	valid	\N	2025-07-29 16:56:39.243131	2025-07-29 16:56:39.243131	b18508d6-daa6-4628-a62a-d72336f7b3a0	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	3	0	\N	21b23712-d0fe-49df-8162-8f29997a448f	\N	0.00
5f37c04a-b99e-4395-9d35-2265380a924a	valid	\N	2025-07-29 17:01:15.957665	2025-07-29 17:01:15.957665	4f52a0d7-2a74-420f-b19a-cf1e151b3bed	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	21b23712-d0fe-49df-8162-8f29997a448f	\N	0.00
f1d811cd-c801-470c-9997-585ae136fa04	valid	\N	2025-07-29 17:04:10.888082	2025-07-29 17:04:10.888082	2ec87a08-10aa-47c1-abe1-b7468b1a46fd	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	21b23712-d0fe-49df-8162-8f29997a448f	\N	0.00
e5783b41-771e-47b3-95ae-b46c108a008d	valid	\N	2025-07-29 17:05:53.45061	2025-07-29 17:05:53.45061	6c2b3ce5-e46f-4c7f-8cc2-46b2003cc0c2	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	2	0	\N	21b23712-d0fe-49df-8162-8f29997a448f	\N	0.00
8bbefaa1-3d58-43b5-9381-3c670fd8df44	valid	\N	2025-07-29 17:08:27.842834	2025-07-29 17:08:27.842834	d8211373-f3af-4b86-b577-fefd7cf6d483	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	2	0	\N	\N	\N	0.00
1bcbbe12-1975-4562-9424-bfbb2f4ab723	valid	\N	2025-07-29 17:17:59.228801	2025-07-29 17:17:59.228801	6c211e01-0d59-48c7-a487-50feb60e3275	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	5	0	\N	21b23712-d0fe-49df-8162-8f29997a448f	\N	0.00
dc24a305-b719-466a-8eb8-cd93ac81e1c8	valid	\N	2025-07-29 17:31:35.049989	2025-07-29 17:31:35.049989	a2d2a471-9c55-4e3f-b55e-f0953d189445	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	c4abb86d-5955-416d-aef5-332ca77b8cfa	\N	0.00
6ed5408d-c453-4680-bda1-d186a104b7ad	valid	\N	2025-07-29 17:37:13.406585	2025-07-29 17:37:13.406585	479c4cc1-812c-4de5-959e-ac1c306731f3	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	21b23712-d0fe-49df-8162-8f29997a448f	\N	0.00
e8dc121a-9097-44a1-9c9d-3f7cdec70dc3	valid	\N	2025-07-29 17:45:25.332704	2025-07-29 17:45:25.332704	ab0d635f-9b54-4119-acde-6d852fbedc2c	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
379ffcec-190d-422c-a7be-0a87aa613656	valid	\N	2025-07-29 17:52:11.916458	2025-07-29 17:52:11.916458	67aac44f-f0e1-46dc-9e84-14771202f1db	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	2	0	\N	21b23712-d0fe-49df-8162-8f29997a448f	\N	0.00
9049f656-553d-4c39-8533-6bfd6cfdcfbe	valid	\N	2025-07-29 18:39:32.301273	2025-07-29 18:39:32.301273	2bf149e0-04b5-4016-aa45-31eadb6a32ce	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	3	0	\N	\N	\N	0.00
0e2f88db-c45c-45da-b0f3-cd396a986d9e	valid	\N	2025-07-29 19:02:37.125073	2025-07-29 19:02:37.125073	6b3136ca-a0a5-463a-972c-60454405e706	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
0b7db4c6-1129-4011-8468-57d256f2dc88	valid	\N	2025-07-29 19:43:57.026255	2025-07-29 19:43:57.026255	40608417-6eeb-4e9e-bce4-cd95849c62d8	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	c4abb86d-5955-416d-aef5-332ca77b8cfa	\N	0.00
95a57ec2-2fa4-497f-a617-bd442d3b2562	valid	\N	2025-07-29 19:48:59.257192	2025-07-29 19:48:59.257192	c673a16b-4635-4d67-ae44-cc89a929d793	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	3	0	\N	\N	\N	0.00
8cf073b3-b4d2-4d02-8013-b9e0d2afaf08	valid	\N	2025-07-29 19:49:25.288277	2025-07-29 19:49:25.288277	c673a16b-4635-4d67-ae44-cc89a929d793	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	2	0	\N	\N	\N	0.00
a5057c68-efb8-494f-bb62-086db4e4c8b4	valid	\N	2025-07-29 20:17:04.786116	2025-07-29 20:17:04.786116	922cde8b-4f25-4782-8caa-3dc6af6306e8	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	8	0	\N	\N	\N	0.00
e7ffb249-b40e-4965-bad5-f49dc50cec1a	valid	\N	2025-07-29 21:43:39.126744	2025-07-29 21:43:39.126744	23838215-8ac2-403a-a3f7-f70ad6f0a57f	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	8aef3c74-f314-4649-9a24-84a2aa4b2ad5	\N	0.00
1115c517-827f-49cf-903f-ef98d696e6f6	valid	\N	2025-07-29 22:32:55.345675	2025-07-29 22:32:55.345675	5a25275d-2d69-434a-b9d9-534d72052e0b	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	3	0	\N	\N	\N	0.00
4dc03723-153f-48d3-97f9-1a6c64e3ebda	valid	\N	2025-07-29 23:28:30.740223	2025-07-29 23:28:30.740223	11835074-685a-4940-955b-840e1a499e5a	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	21b23712-d0fe-49df-8162-8f29997a448f	\N	0.00
1fe32972-02b4-4e43-a07a-1a577d87f8a5	valid	\N	2025-07-29 23:32:35.884319	2025-07-29 23:32:35.884319	53bb60b4-cb4d-4217-87f9-d779ae5dd58a	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	c4abb86d-5955-416d-aef5-332ca77b8cfa	\N	0.00
4799d637-0a31-40eb-a4ec-fc8e5cb46cb1	valid	\N	2025-07-30 00:08:00.867359	2025-07-30 00:08:00.867359	0d6b21a4-828a-4ecb-b436-bb91b03b3f76	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	2	0	\N	21b23712-d0fe-49df-8162-8f29997a448f	\N	0.00
77f9a757-37f7-4361-bf2b-db6589ed37fe	valid	\N	2025-07-30 00:48:11.541395	2025-07-30 00:48:11.541395	24a5a5f9-1646-434c-9fbb-b43c00029524	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	8aef3c74-f314-4649-9a24-84a2aa4b2ad5	\N	0.00
c1681ee8-0317-4aa9-9e39-d469e0a4daa4	valid	\N	2025-07-30 01:03:37.085093	2025-07-30 01:03:37.085093	708a3c9b-e9dc-47cc-a45d-29e1c9d834ea	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	2	0	\N	21b23712-d0fe-49df-8162-8f29997a448f	\N	0.00
5955779d-d34e-40e6-bbf7-b128fd1ece94	valid	\N	2025-07-30 01:05:29.530752	2025-07-30 01:05:29.530752	194478c4-4aaf-4b25-9355-e7c2c17d0d8f	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	c4abb86d-5955-416d-aef5-332ca77b8cfa	\N	0.00
b379a9c4-bcf3-45e7-8389-2e338746e54f	valid	\N	2025-07-30 01:12:28.503274	2025-07-30 01:12:28.503274	40608417-6eeb-4e9e-bce4-cd95849c62d8	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	3	0	\N	c4abb86d-5955-416d-aef5-332ca77b8cfa	\N	0.00
dd591a30-3fbf-4ec3-bc33-710f875491cd	valid	\N	2025-07-30 01:39:45.491652	2025-07-30 01:39:45.491652	d69d24da-2384-4334-af18-8d83070f2f2c	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	c4abb86d-5955-416d-aef5-332ca77b8cfa	\N	0.00
fbc78471-ed31-4a41-9353-8945bfe1767a	valid	\N	2025-07-30 02:52:55.798625	2025-07-30 02:52:55.798625	639bc0e8-2daf-4c06-8e42-b1adb433d243	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	2	0	\N	21b23712-d0fe-49df-8162-8f29997a448f	\N	0.00
0ab02cc1-d1a7-4c6c-a79c-a4d6d6e69802	valid	\N	2025-07-30 03:31:40.95855	2025-07-30 03:31:40.95855	6a3c4eff-f44a-4f1a-b289-efb22c6d6661	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	21b23712-d0fe-49df-8162-8f29997a448f	\N	0.00
c13e9b9f-84c8-453e-85f7-5f33373a6243	valid	\N	2025-07-30 04:30:43.272557	2025-07-30 04:30:43.272557	6c2b3ce5-e46f-4c7f-8cc2-46b2003cc0c2	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	2	0	\N	21b23712-d0fe-49df-8162-8f29997a448f	\N	0.00
67e67f9d-c530-4acb-b090-051a45e39bb6	valid	\N	2025-07-30 07:02:59.538816	2025-07-30 07:02:59.538816	ff1a34d7-d88e-46ea-8953-d77b46738453	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	4	0	\N	8aef3c74-f314-4649-9a24-84a2aa4b2ad5	\N	0.00
d1767c4a-60fe-46a3-ab4f-572127bda040	valid	\N	2025-07-30 12:57:37.210659	2025-07-30 12:57:37.210659	aa1df6bc-47de-475b-992b-f4255adfef2b	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	2	0	\N	\N	\N	0.00
97c39e00-5372-4cf0-9417-e9e22f293003	valid	\N	2025-07-30 14:31:20.88416	2025-07-30 14:31:20.88416	7cf04169-b4f1-4adf-8569-e1158977b93c	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	21b23712-d0fe-49df-8162-8f29997a448f	\N	0.00
ef79511f-854b-4b1c-a92e-4151646c00c3	valid	\N	2025-07-30 16:18:56.988357	2025-07-30 16:18:56.988357	d917671f-9113-4c6f-8124-507a30540217	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	4	0	\N	21b23712-d0fe-49df-8162-8f29997a448f	\N	0.00
3c7ca985-9d7b-4447-9097-60aba434c157	valid	\N	2025-07-30 16:59:00.576818	2025-07-30 16:59:00.576818	d383ad06-2595-412a-9482-2fe087340ee6	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	5	0	\N	c4abb86d-5955-416d-aef5-332ca77b8cfa	\N	0.00
9fa0ee11-1671-4d67-818f-4976b505be28	valid	\N	2025-07-30 17:06:36.764401	2025-07-30 17:06:36.764401	65f9d472-3af7-4af5-85f3-7a04f5705059	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	8aef3c74-f314-4649-9a24-84a2aa4b2ad5	\N	0.00
ebcd9bb9-602f-4f09-a216-849deaeeca9d	valid	\N	2025-07-30 17:06:54.764057	2025-07-30 17:06:54.764057	65f9d472-3af7-4af5-85f3-7a04f5705059	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
ebc22a9f-7ec7-41d5-bc77-58ca23023a7c	valid	\N	2025-07-30 17:21:16.291917	2025-07-30 17:21:16.291917	678c1c18-049c-4188-b064-6fd77981b679	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	13	0	\N	c4abb86d-5955-416d-aef5-332ca77b8cfa	\N	0.00
7d9c84f6-0408-43c3-930d-e6263b932cb4	valid	\N	2025-07-31 01:28:39.083302	2025-07-31 01:28:39.083302	c79bfe72-9f7c-456a-b934-4f1ccb9d53cf	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
caa529bf-e3b9-4497-9059-20d2a886952b	valid	\N	2025-07-31 01:30:57.715499	2025-07-31 01:30:57.715499	69581673-121f-4195-8648-ac726a61545f	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
c62e7f6e-9ff5-4d84-ba83-78984303f7f5	valid	\N	2025-07-31 01:33:08.77054	2025-07-31 01:33:08.77054	a4a4daa1-9960-41a2-ab4b-92fa7d1cc49e	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
1b6e32c1-2746-4347-ae11-e460323885da	valid	\N	2025-07-31 01:33:15.538975	2025-07-31 01:33:15.538975	a4a4daa1-9960-41a2-ab4b-92fa7d1cc49e	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
98649416-11fa-4f68-a20b-55a7f99e1fe8	valid	\N	2025-07-31 01:49:59.460747	2025-07-31 01:49:59.460747	6e8ea36d-288c-4942-8e93-eac7c85d20db	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
a06d3337-99c2-452e-b9dc-e723505caa5e	valid	\N	2025-07-31 02:55:14.825735	2025-07-31 02:55:14.825735	d41b4f5c-b6a0-4496-9e43-3c6f9c7c0fd5	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
1cf71df5-8ddb-4888-91c7-35125c4e645d	valid	\N	2025-07-31 03:08:29.365092	2025-07-31 03:08:29.365092	67aac44f-f0e1-46dc-9e84-14771202f1db	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
53dfd3b0-deec-4b93-94af-7a589a4cd396	valid	\N	2025-07-31 03:58:57.394995	2025-07-31 03:58:57.394995	506b8df7-6a22-4f1f-b495-663fe83a3b2c	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	4	0	\N	\N	\N	0.00
a6148bb3-7a20-400e-b0a6-73b981cbf2e1	valid	\N	2025-07-31 06:50:40.327633	2025-07-31 06:50:40.327633	19c3c8e2-6cda-4a62-92e7-3f478bfaad5a	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
f2198051-6909-47c7-b0c8-c44e27a94d6d	valid	\N	2025-07-31 16:15:07.841822	2025-07-31 16:15:07.841822	c79bfe72-9f7c-456a-b934-4f1ccb9d53cf	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
7a6a68c7-157f-47e5-b499-1882f1345ca1	valid	\N	2025-07-31 16:43:30.201366	2025-07-31 16:43:30.201366	87432028-a1f8-473d-b904-acbe36f6ffa1	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	15	0	\N	\N	\N	0.00
02dd574f-23dd-43df-9620-b4eb21442997	valid	\N	2025-07-31 17:02:58.532337	2025-07-31 17:02:58.532337	941ccd61-74b7-4fd2-bccf-7cd45f76930c	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	4	0	\N	\N	\N	0.00
80eb9bba-8ee6-4b62-bd9f-4be4545432f4	valid	\N	2025-07-31 17:04:05.055382	2025-07-31 17:04:05.055382	01419337-3088-472d-a0c4-d1c2e959ea16	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
79920943-87c3-41ec-acef-970ece70eeb0	valid	\N	2025-07-31 17:13:01.286468	2025-07-31 17:13:01.286468	5671600f-833f-4e69-9f38-3002b3de3a15	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	2	0	\N	\N	\N	0.00
f270a32c-005e-4c3a-b415-1aff1bae4168	valid	\N	2025-07-31 18:03:40.173425	2025-07-31 18:03:40.173425	8ac77628-afb6-4232-9e65-e75077f9f5a8	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	10	0	\N	\N	\N	0.00
2279876d-4e6c-4cc6-b4c8-b574ab931fec	valid	\N	2025-07-31 19:53:06.452625	2025-07-31 19:53:06.452625	506b8df7-6a22-4f1f-b495-663fe83a3b2c	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
c4492fc9-651a-4f37-8886-c40d0337c96e	valid	\N	2025-07-31 19:54:25.901977	2025-07-31 19:54:25.901977	c49c5f85-6561-4fde-8122-d484d0e25c82	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
66b4aaed-5892-4c6b-90a4-35f35770ab32	valid	\N	2025-07-31 20:11:28.161062	2025-07-31 20:11:28.161062	c2682ba9-efeb-4a65-b09c-226f774223ee	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
548ee7ad-d598-4c2c-a529-fb9c5d33a246	valid	\N	2025-07-31 20:35:43.602829	2025-07-31 20:35:43.602829	a80b6717-24db-4ac1-8e85-b01da3ceb648	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	c4abb86d-5955-416d-aef5-332ca77b8cfa	\N	0.00
a3c971ab-41b3-4180-a455-8b3513956af5	valid	\N	2025-07-31 21:05:15.780155	2025-07-31 21:05:15.780155	29074af4-cf1e-4be7-8f8c-dde7d4dcda49	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	5	0	\N	\N	\N	0.00
305d0ff0-4516-464c-acbf-64aae3729944	valid	\N	2025-07-31 21:05:39.82288	2025-07-31 21:05:39.82288	29074af4-cf1e-4be7-8f8c-dde7d4dcda49	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
09506ffa-e3ba-4db6-ae71-b22be2770051	valid	\N	2025-07-31 21:05:52.211002	2025-07-31 21:05:52.211002	29074af4-cf1e-4be7-8f8c-dde7d4dcda49	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
419f2f26-434c-48c4-926d-c3476ca45fc0	valid	\N	2025-08-01 00:06:41.997501	2025-08-01 00:06:41.997501	5ef32c23-91cd-4084-8a2e-22193db520ad	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
b60c1d31-d922-40cf-8159-6b512ee5ac2c	valid	\N	2025-08-01 00:09:13.112971	2025-08-01 00:09:13.112971	c3559e79-8177-4380-94fa-b6d4dbf8925b	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
f2ec2825-65bf-4288-b941-a397d54098d6	valid	\N	2025-08-01 00:22:08.811194	2025-08-01 00:22:08.811194	dd6b9eab-f81e-4672-8bd7-7ec38dc31f7d	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
4f3313fc-7b4b-4018-a131-f18f92dc6cce	valid	\N	2025-08-01 00:31:32.658217	2025-08-01 00:31:32.658217	64f02c83-1f5c-4344-96ef-b641fc5b2a8c	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	5	0	\N	\N	\N	0.00
a1de1f95-2d07-4a8c-be4d-3f38d2be11c5	valid	\N	2025-08-01 00:55:21.955107	2025-08-01 00:55:21.955107	db0e7e8b-80d7-4995-94c6-28d855f2ee60	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
4ae3cc2b-bc39-44b2-b185-a1d979011bd5	valid	\N	2025-08-01 01:36:56.336952	2025-08-01 01:36:56.336952	5273cbd7-ea62-450e-a5d2-ef5a81086c21	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	2	0	\N	\N	\N	0.00
6e522d44-bf3b-4601-a98f-f1089f31e308	valid	\N	2025-08-01 01:46:13.568035	2025-08-01 01:46:13.568035	856b56be-230d-424c-afbf-0ca2e857b210	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
d81fecb9-500d-45c8-a1a4-b78b9d53636b	valid	\N	2025-08-01 02:13:21.275118	2025-08-01 02:13:21.275118	a4a4daa1-9960-41a2-ab4b-92fa7d1cc49e	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
aab826d3-4911-483c-9018-c0a8813fe728	valid	\N	2025-08-01 02:28:39.544236	2025-08-01 02:28:39.544236	bfd2c06a-1352-4830-8b90-8078d00ba06d	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	5	0	\N	\N	\N	0.00
18f9e124-e4a4-4adc-9a07-b09c8def4a5e	valid	\N	2025-08-01 04:06:40.090562	2025-08-01 04:06:40.090562	c79bfe72-9f7c-456a-b934-4f1ccb9d53cf	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	\N	\N	0.00
f54f8b95-9e4c-4b30-a59b-1e83418c02cd	valid	\N	2025-08-01 04:20:54.585967	2025-08-01 04:20:54.585967	6e45c833-c10b-4ed5-85dc-0b311330e562	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	2	0	\N	\N	\N	0.00
890ea83b-1709-4635-b66c-e006870d5bed	valid	\N	2025-08-01 11:47:46.840658	2025-08-01 11:47:46.840658	0537e40e-ccd6-4386-b978-50dfea6d78e0	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	1	0	\N	21b23712-d0fe-49df-8162-8f29997a448f	\N	0.00
3af21ed1-f399-4f87-a271-ec63e89fc960	valid	\N	2025-08-01 17:50:47.91884	2025-08-01 17:50:47.91884	29915f90-0b3a-44b1-a987-29d610f2b8c1	72e8d314-aa0f-4606-853c-1ee62fc5acec	53576570-7ecf-4d86-8a45-fad9221fa8ef	2	0	\N	\N	\N	0.00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: sucht_user
--

COPY public.users (id, email, password, name, "createdAt", "updatedAt", "invitationToken", "profileImageUrl", "instagramHandle", "whatsappNumber", "dateOfBirth", username, "mercadoPagoAccessToken", "rrppCommissionRate", roles) FROM stdin;
6e45c833-c10b-4ed5-85dc-0b311330e562	jjuannivelasquez@gmail.com	$2b$10$ykpybTX1pMo7Wp71CSqBCunVvFatbGncAqeJat6BJalB0p7SmwJha	Juana Velasquez	2025-08-01 04:17:42.736741	2025-08-01 04:17:42.736741	\N	\N	\N	\N	2006-01-31	\N	\N	\N	client
c79bfe72-9f7c-456a-b934-4f1ccb9d53cf	leaa@sucht.com.ar	$2b$10$iez479V8Fgeq5AVdHL8Wgekw9WphogPhGKvr367gBKw5pHi6LCqGu	Leandro	2025-07-23 22:53:29.215082	2025-08-01 04:17:53.139011	\N	https://res.cloudinary.com/di4ikaeke/image/upload/v1753735496/sucht/profiles/orhqvdywoj7itnkk2cxf.jpg	leaa.emanuel	+5491126658293	1990-09-16	leaa	\N	\N	owner,admin,client,rrpp,verifier
49a01aa7-3e4b-4803-823c-4b91ae9dbd77	victoria.vivares007@gmail.com	$2b$10$lEgF5zn3uXJoHBQo1.05u.qbAZwNLdJ/sRYmkYs9y.kGTUo/l4kiG	Victoria Vivares	2025-08-01 17:24:03.54836	2025-08-01 17:24:03.54836	\N	\N	\N	\N	2007-02-20	\N	\N	\N	client
6c211e01-0d59-48c7-a487-50feb60e3275	camiloorzusa20@gmail.com	$2b$10$o03yzmNf9xvZftUCE5ZOIeA06MyKXb4NKK.7DSEaypGY24AWdzWDG	Diego 	2025-07-29 17:17:18.393388	2025-07-29 17:17:18.393388	\N	\N	\N	\N	2006-07-19	\N	\N	\N	client
a2d2a471-9c55-4e3f-b55e-f0953d189445	biancastorear@gmail.com	$2b$10$oSmycNDuik24EOPgIwIez.TgDZlBkr45OdIpYM2TvvRBQTUYW.RGS	leandro	2025-07-28 23:53:27.613373	2025-07-28 23:53:27.613373	\N	\N	\N	\N	1990-09-28	\N	\N	\N	client
29915f90-0b3a-44b1-a987-29d610f2b8c1	guille.mastrov@outlook.com	$2b$10$d8fztAHAoXVVlxK2nbVaK.d.4ilVm/JAeGF3xLq7MysDOoC/FMQL6	Guillermina Mastroverti	2025-08-01 17:49:27.197259	2025-08-01 17:49:27.197259	\N	\N	\N	\N	2003-01-06	\N	\N	\N	client
db0e7e8b-80d7-4995-94c6-28d855f2ee60	ayelenbarboza07@gmail.com	$2b$10$v43I8.lw/DPzOUmk/i119O06GGTE0kT/nm2nmyCVa4z1ONZZGHXa2	mayra barboza	2025-08-01 00:54:45.331511	2025-08-01 00:54:45.331511	\N	\N	\N	\N	2004-05-07	\N	\N	\N	client
21b23712-d0fe-49df-8162-8f29997a448f	sucht.castelar@gmail.com	$2b$10$V8cSsULZYM4ItEExFqR02OkbDBCvbt.7vPhOb0ScWNn3ApV6YhDiC	SUCHT	2025-07-25 01:13:11.365417	2025-08-01 04:18:21.04064	\N	https://res.cloudinary.com/di4ikaeke/image/upload/v1753807541/sucht/profiles/k7ovvf91mzmxtvietijg.png	sucht.oficial	+5491152738137	1990-09-28	suchtoficial	\N	\N	client,admin,verifier,rrpp
8aef3c74-f314-4649-9a24-84a2aa4b2ad5	Julianabruno3760@gmail.com	$2b$10$VwCPvIBXu.vvk.XZTU2JAeP2aHMZ9N9BiSDqRK6G03VX3IAZmBXwq	Juliana	2025-07-29 15:42:43.971033	2025-08-01 04:18:56.84463	\N	https://res.cloudinary.com/di4ikaeke/image/upload/v1753806942/sucht/profiles/kzxda2tlni3ulkizqb90.jpg	Juuli.bruno	1171287158	2003-10-14	Juu	\N	\N	client,rrpp
c4abb86d-5955-416d-aef5-332ca77b8cfa	samaradenot@gmail.com	$2b$10$lPkbUaUz/sgMUV7zue6YWeb2A9TO2/B.jatzc2XY40a.L5YmSnPlq	Samara Denot	2025-07-29 15:55:08.657342	2025-08-01 04:19:22.875435	\N	\N	sammel.denot	+541123944815	2006-02-15	sami	\N	\N	client,rrpp
9b9c6c76-8578-4b3f-818c-8497bdc43c39	timberinil@gmail.com	$2b$10$JSwJTRwrRf8M4uD5NEKVn.thaZtqk9lkSUFddUc.sANnKXrNC/Yk.	Leandro Timberini	2025-07-25 01:13:20.381285	2025-08-01 04:29:13.759572	\N	\N	leaa.emanuel	+5491126658293	1990-09-27	leaaemanuel	\N	\N	client,rrpp
91cc5d26-f8b0-4f0e-b3a6-a547ea21f50c	briannsuarez22@gmail.com	$2b$10$JLdCjLHhgT6xdkjCGxnMQ.U1YuXzPkoNKvUBqpzM/3zyaPKH0VQWK	Brian Suarez	2025-08-01 04:29:48.855762	2025-08-01 04:29:48.855762	\N	\N	\N	\N	2003-07-03	\N	\N	\N	client
5ef32c23-91cd-4084-8a2e-22193db520ad	ianvicencio246@gmail.com	$2b$10$4jy9oPUHZF/5UJ.xXlrcM.Tv3AWRTWrHjhytGz6.XSjkcShAjDWIy	Ian	2025-07-31 23:50:36.479103	2025-07-31 23:51:27.472175	\N	\N	Ian_vicenc	541128697282	2007-02-14	Sombreromagico1	\N	\N	client
c3559e79-8177-4380-94fa-b6d4dbf8925b	thomasbarcelo2006@gmail.com	$2b$10$5J2MIZ8.FrQcSoCNz99MIOINPv/MhzPMnH7Yh/gYXMOPiFjjJf9cu	Thomas barcelo	2025-08-01 00:08:13.718853	2025-08-01 00:08:13.718853	\N	\N	\N	\N	2006-07-17	\N	\N	\N	client
dd6b9eab-f81e-4672-8bd7-7ec38dc31f7d	pilarbazan2605@gmail.com	$2b$10$wrEDg.O.lBe50zgmxhBpr.8BHYAlY2R2XTMTvx1iKrHk3D4n.Xz/K	pily	2025-08-01 00:21:03.807484	2025-08-01 00:21:03.807484	\N	\N	\N	\N	2006-05-25	\N	\N	\N	client
64f02c83-1f5c-4344-96ef-b641fc5b2a8c	josuefmarchioli@gmail.com	$2b$10$zwjNW.t6abJ7PoXjKXpghOr0ANmOzg3GGt1TxneQKQ0kynvYoN3Le	Josue Marchioli 	2025-08-01 00:30:46.82002	2025-08-01 00:30:46.82002	\N	\N	\N	\N	2007-07-15	\N	\N	\N	client
718517f0-fbcf-40ee-bb1e-81198969ac9e	agustingomez.cuervo@gmail.com	$2b$10$UnEU4UZDN6nJ0y7zSE9EOOPoMpkcuBKTykE1NoCDlKbu.OSPBKzDW	Agustin Gomez	2025-08-01 18:01:57.217745	2025-08-01 18:05:54.327141	\N	\N	gmzagusss	+541128836140	2007-11-08	aguss	\N	\N	client
5273cbd7-ea62-450e-a5d2-ef5a81086c21	brisatatiana14@gmail.com	$2b$10$hIUHmRxUadr/zt39VBS1FurJfgg3YMxDRy2vvRqJXlOGH0bfRvRQO	brisa delgado	2025-08-01 01:36:27.332117	2025-08-01 01:39:17.224931	\N	\N	briisaa.t	1178973353	2007-02-12	briisaa.t	\N	\N	client
856b56be-230d-424c-afbf-0ca2e857b210	axeljazmin6@gmail.com	$2b$10$8MZ7Hrmb/Kud5z1O/GI0gevpyCULW.oKQ1DtkZWzkko1XooiEvtQS	Axel	2025-08-01 01:45:22.560915	2025-08-01 01:45:22.560915	\N	\N	\N	\N	2005-10-12	\N	\N	\N	client
bfd2c06a-1352-4830-8b90-8078d00ba06d	juligallo1806@gmail.com	$2b$10$DgVpTEpEx0hFqgvG7HokNOKgJpc/a1ejrTRsRxvBL87LTOAabEfcC	Julieta gallo	2025-08-01 02:27:27.282852	2025-08-01 02:27:27.282852	\N	\N	\N	\N	2004-06-17	\N	\N	\N	client
479c4cc1-812c-4de5-959e-ac1c306731f3	acarabajal676@gmail.com	$2b$10$peH/oMPSQzHsiC3kZp3ztecn1cbvynym6.TtyjoI0cRnY2swZikHK	lean carabajal	2025-07-29 17:36:36.727206	2025-07-29 17:36:36.727206	\N	\N	\N	\N	2006-08-18	\N	\N	\N	client
ab0d635f-9b54-4119-acde-6d852fbedc2c	danipdp26@gmail.com	$2b$10$0oj0s7ntAxVtu1KNDfHqkeuKMTaNownTcWAJ3oXwnX9WoPMCAc7EG	Pablo Daniel Pitocco	2025-07-29 17:44:30.049469	2025-07-29 17:44:30.049469	\N	\N	\N	\N	2007-08-24	\N	\N	\N	client
39750677-0b52-4d9f-93c3-efd2b09f840f	olivaresmatilda05@gmail.com	$2b$10$FVgRLyFkM4X86djsiFMuvOqaZNZnyFTdjt5.A/geXOTrr2wC/WpRa	matil	2025-07-29 17:44:29.158714	2025-07-29 17:45:15.807618	\N	\N			2006-04-22	matil23	\N	\N	client
b18508d6-daa6-4628-a62a-d72336f7b3a0	velencarrera@gmail.com	$2b$10$P2pQbPNEJaLL7XVI1WInwO.FSevU1CbJ6MTi7dlGIJ/L4sI1UA94i	Valentina carrera	2025-07-29 16:56:01.663626	2025-07-29 16:56:01.663626	\N	\N	\N	\N	2006-08-06	\N	\N	\N	client
4f52a0d7-2a74-420f-b19a-cf1e151b3bed	belu.fbm2005@gmail.com	$2b$10$Lclm10HIhNsZ1gF0cYeH8uoy1ULLygvRDZH30H3s6yMTa5OMeuZWe	belu	2025-07-29 17:00:35.521927	2025-07-29 17:00:35.521927	\N	\N	\N	\N	2005-08-02	\N	\N	\N	client
2ec87a08-10aa-47c1-abe1-b7468b1a46fd	vicychi.21@gmail.com	$2b$10$.PZuA/OHiJK7JYa2D496ferloO/Cu/0vXxgdHWixHFIkavQEPMfDS	Victoria Nikollek	2025-07-29 17:01:37.835626	2025-07-29 17:01:37.835626	\N	\N	\N	\N	2003-04-20	\N	\N	\N	client
e06debd4-c6df-48af-aefc-242bcac30b04	sharonbarbona2221@gmail.com	$2b$10$gfxJaPSzh1vuyk0tsmG3rODdRR0qmgJ72UH34TWai9TwAQy1c2rpy	Sharon Barbona	2025-07-29 17:01:46.752474	2025-07-29 17:01:46.752474	\N	\N	\N	\N	2003-12-21	\N	\N	\N	client
6c2b3ce5-e46f-4c7f-8cc2-46b2003cc0c2	criss.arce2009@gmail.com	$2b$10$HXxKtt/dHdEGORw0uONXcO5d15WAOE0UWxyI.yhyWmewoVsWN.sKy	Cris Arce	2025-07-29 17:05:12.141567	2025-07-29 17:05:12.141567	\N	\N	\N	\N	2004-11-13	\N	\N	\N	client
d8211373-f3af-4b86-b577-fefd7cf6d483	candelariotta1@gmail.com	$2b$10$x9BsOB0W9hVCyUx7pHrO3eYuUtSmg2zR.w2kWoIhUC7tlNBzPIi7i	Candela riotaa	2025-07-29 17:07:43.269732	2025-07-29 17:07:43.269732	\N	\N	\N	\N	2007-02-15	\N	\N	\N	client
34116a9e-7b82-439b-ad07-ea949cd1ba33	facugomezdj98@icloud.com	$2b$10$qy80ICxaA9xKTogyGqwSbuVrhjKSY/9sX5vpWHHJVpw/q/jAguoMe	Facundo Gomez	2025-07-25 07:47:26.95426	2025-07-25 07:47:26.95426	\N	\N	\N	\N	\N	\N	\N	\N	client
67aac44f-f0e1-46dc-9e84-14771202f1db	brendabalmaceda118@gmail.com	$2b$10$zvJE.eCPuFgRqq/a8zKtWOUze1M.KuoUBM91vNK/Ga.H7Vgdx9hl6	Brenda Airin Balmaceda	2025-07-29 17:48:21.028613	2025-07-29 17:48:21.028613	\N	\N	\N	\N	2003-10-14	\N	\N	\N	client
6b3136ca-a0a5-463a-972c-60454405e706	laaraa.fernandez.h@gmail.com	$2b$10$W7kqhapFqhB4RlQ6eqwBpOK/Kk7dd.LQBTjnE3oyL4srzVthXuO.O	lara	2025-07-29 19:01:44.205301	2025-07-29 19:01:44.205301	\N	\N	\N	\N	2006-07-06	\N	\N	\N	client
40608417-6eeb-4e9e-bce4-cd95849c62d8	schuckmanerika@gmail.com	$2b$10$WrsoSXcMna0H5IZljkmMveiS/TQxyMcA5cUVmRQrsoqBu3xkDseq6	Erika	2025-07-29 19:43:10.767047	2025-07-29 19:43:10.767047	\N	\N	\N	\N	2007-02-06	\N	\N	\N	client
a80b6717-24db-4ac1-8e85-b01da3ceb648	belenmelano3@gmail.com	$2b$10$bymcwRuDZCGP8Ia88Ktwe.0qzK0.gwGuJMDxoCP/THgXvd2QPuVe6	Belen melano 	2025-07-29 17:10:22.854612	2025-07-29 17:10:22.854612	\N	\N	\N	\N	2004-06-03	\N	\N	\N	client
2bf149e0-04b5-4016-aa45-31eadb6a32ce	giulianafranco604@gmail.com	$2b$10$NDl4yaS/cyr5f9Q2.7vdDumKOmFIXWn8v7yElvaKLygG2RM/wDn9m	Giuliana Franco	2025-07-29 17:13:39.325359	2025-07-29 17:13:39.325359	\N	\N	\N	\N	2006-09-02	\N	\N	\N	client
0db2361b-a9e6-47c7-b59b-853f55755d1b	barriosaabi@gmail.com	$2b$10$G2DI0tEsnQ8InNB88Uejt.YJyi/DOW3eUWOz/rtKF0kg2eo4lmFcq	Abi Barrios	2025-07-29 19:46:42.972811	2025-07-29 19:46:42.972811	\N	\N	\N	\N	2006-07-15	\N	\N	\N	client
c673a16b-4635-4d67-ae44-cc89a929d793	vero.aveen99@gmail.com	$2b$10$WihmmylRWdpesB0a870RHO7vd9TfJ0h.JhkqLAnmwEdiqeMQGjCYO	Verónica Chazarreta 	2025-07-29 19:47:44.849385	2025-07-29 19:47:44.849385	\N	\N	\N	\N	2002-07-08	\N	\N	\N	client
922cde8b-4f25-4782-8caa-3dc6af6306e8	altamiranojacqueline325@gmail.com	$2b$10$ODJa3Slz32qPkviSi.IAHen//QVp8T4LxlGEHChnzVVWIh/PwdGwC	jacqueline altamirano	2025-07-29 20:14:57.732024	2025-07-29 20:14:57.732024	\N	\N	\N	\N	2007-07-18	\N	\N	\N	client
3e0bc2e9-2836-42b5-bc47-be9245c0729e	angelestiberi76@gmail.com	$2b$10$33HDViWYiZHt45Wp8nQQc.Kn3YlRbgVW7V7bOqUff31uo5DqKD/P6	Angeles tiberi 	2025-07-29 21:58:22.499634	2025-07-29 21:58:22.499634	\N	\N	\N	\N	2005-10-06	\N	\N	\N	client
5ada1449-4878-464c-b8d4-4103d4c0ca0c	diegomateososa@gmail.com	$2b$10$qznrXKg6/MYYbipS3eYpneZwLmi.HAXlC5yWjbRYTZD7VmC9Ehko2	diego mateo sosa	2025-07-29 22:29:34.360359	2025-07-29 22:29:34.360359	\N	\N	\N	\N	2007-04-22	\N	\N	\N	client
5a25275d-2d69-434a-b9d9-534d72052e0b	diegomateososa23@gmail.com	$2b$10$ozUXDO7S4KmEu/22b89NGucnXOJ.pmn06hG3oMQnikm5x1XafNu/2	Diego mateo	2025-07-29 22:31:02.579345	2025-07-29 22:31:02.579345	\N	\N	\N	\N	2007-04-22	\N	\N	\N	client
11835074-685a-4940-955b-840e1a499e5a	sanchezchaveznicolas614@gmail.com	$2b$10$r9pr175HQV6sEiH/Poc85uwRNDy4N1Z83m72/OqlDdPNiRjYC8ya2	Augusto Sanchez	2025-07-29 23:27:33.359336	2025-07-29 23:27:33.359336	\N	\N	\N	\N	2006-12-10	\N	\N	\N	client
53bb60b4-cb4d-4217-87f9-d779ae5dd58a	cambbravo07@gmail.com	$2b$10$7VaszRS12mwOWW3DdpItfuM4S9xQTZoYaZ6hOywqNVAk017/MWe4G	Camila Bravo	2025-07-29 23:32:02.20837	2025-07-29 23:32:02.20837	\N	\N	\N	\N	2007-03-01	\N	\N	\N	client
0d6b21a4-828a-4ecb-b436-bb91b03b3f76	priscagianichini39@gmail.com	$2b$10$X3Ey7aYH4QAsMVuD/9fus.SfisImADGoMIXRSdDHe7imcT.4DIZrO	Prisca Gianichini	2025-07-30 00:06:25.489272	2025-07-30 00:07:34.667462	\N	\N	__priscaa__	91160347106	2007-03-07	Prisca	\N	\N	client
468c2ff1-1cee-4b70-a198-c72819366c48	isaanael08@gmail.com	$2b$10$tNqQxeaPQBQbfM4.vy9KF.1pB89BErdAcc1lZN3xIDxoGIDAa46wO	Anael Isa	2025-07-30 00:15:02.167452	2025-07-30 00:15:02.167452	\N	\N	\N	\N	2006-07-04	\N	\N	\N	client
24a5a5f9-1646-434c-9fbb-b43c00029524	luanacandelaria07@gmail.com	$2b$10$W/jHQiLikvONsJ.kW2P3cuqgJJauVd4mNeGsZ1TT1A4pIgFUIcuWq	luana marques	2025-07-30 00:45:55.430213	2025-07-30 00:45:55.430213	\N	\N	\N	\N	2007-05-01	\N	\N	\N	client
23838215-8ac2-403a-a3f7-f70ad6f0a57f	gadshopar@gmail.com	$2b$10$HMvHjTgyoLETK9wQXgkylunBFrKrtWcktUcVQlG4BYuPgb3bXz6H2	Leaa	2025-07-29 21:43:22.245471	2025-07-29 21:43:22.245471	\N	\N	\N	\N	1990-09-28	\N	\N	\N	client
708a3c9b-e9dc-47cc-a45d-29e1c9d834ea	brisa_b20@hotmail.com	$2b$10$RVxl7pTFcZ1NRYCDuyWpXuUDttr8uK9pyGGHgOETINKGUFVPBHcOm	brisa lagoria	2025-07-30 01:02:54.700288	2025-07-30 01:02:54.700288	\N	\N	\N	\N	2006-07-18	\N	\N	\N	client
194478c4-4aaf-4b25-9355-e7c2c17d0d8f	aimesofiafernandez2006@gmail.com	$2b$10$IXTafh0d/RBrs7gr5OkKlOHyAvWxqHMKUpJzq0ggMSOY1.5aOm39q	aime fernandez	2025-07-30 01:04:15.358866	2025-07-30 01:04:15.358866	\N	\N	\N	\N	2006-10-05	\N	\N	\N	client
adc1fecf-0cd2-4065-a941-6b53002389ee	loanaelisaven@gmail.com	$2b$10$pA7mpB/vCOHYBcwC/0ybEeUyhUlWBZtqOQ.L38sPxCZJEkDQn6bT.	Loana Avendaño	2025-07-30 01:14:09.22276	2025-07-30 01:15:11.075527	\N	\N	Loana_aven	+54 11 51480257	2006-09-12	Loana	\N	\N	client
d69d24da-2384-4334-af18-8d83070f2f2c	juaneliasagustin@gmail.com	$2b$10$x9HzjPHVQAnedTdhLUSBzOMCrzdZMb94Sy9Bmcvphrl9pcZl8tl0.	Elias Juan 	2025-07-30 01:38:27.421719	2025-07-30 01:38:27.421719	\N	\N	\N	\N	2005-12-20	\N	\N	\N	client
639bc0e8-2daf-4c06-8e42-b1adb433d243	francotacacho@gmail.com	$2b$10$dUS3wmu/U7HklHA/F0ePjeVkUusMk/GXUP6rJsVeprfG1BAO7oGAK	Leonel Tacacho 	2025-07-30 02:47:24.099988	2025-07-30 02:47:24.099988	\N	\N	\N	\N	2001-01-02	\N	\N	\N	client
6a3c4eff-f44a-4f1a-b289-efb22c6d6661	gabriel.leonel.perez.2006@gmail.com	$2b$10$/MFwPiHEDRpsOR5J.Y/Oeuq3m1fSjZk6SVIZtAasJHUl6TwP8EB6a	Gabriel Pérez 	2025-07-30 03:31:14.044308	2025-07-30 03:33:20.001774	\N	\N	_pereeeeezz 		2006-04-18	Pereez	\N	\N	client
ff1a34d7-d88e-46ea-8953-d77b46738453	agustina.agotegaray@estudiantes.unahur.edu.ar	$2b$10$C8hNb60Byczq6lK1iiUsdea1t2u/nNwYqjH1Y.lG4TKUqsVaQ7sHm	Agustina Agotegaray	2025-07-30 07:02:07.594741	2025-07-30 07:02:07.594741	\N	\N	\N	\N	2004-06-24	\N	\N	\N	client
aa1df6bc-47de-475b-992b-f4255adfef2b	narellaescobar3@gmail.com	$2b$10$CO56eK412C37fiwxecNQGO0Y.E1tmFg2N3U5d.SnF8reVAUkADWyO	narella escobar	2025-07-30 12:55:56.631844	2025-07-30 12:55:56.631844	\N	\N	\N	\N	2007-05-22	\N	\N	\N	client
7cf04169-b4f1-4adf-8569-e1158977b93c	miasajama19@gmail.com	$2b$10$HbkiU4Z20b.sQ.bOmvpqEOkJyQkNMVW1xSQ1/IrxhOXGdahrhNK5C	Mia Sajama	2025-07-30 14:30:33.903122	2025-07-30 14:30:33.903122	\N	\N	\N	\N	2005-01-18	\N	\N	\N	client
d917671f-9113-4c6f-8124-507a30540217	pettystylinson@gmail.com	$2b$10$Hd7OspoYX5u8P7VMumv2x.KIW.Uqehts7iFMe7C.Q0z5yqZzdGnCe	keila sobrile 	2025-07-30 16:18:24.806751	2025-07-30 16:18:24.806751	\N	\N	\N	\N	2002-04-22	\N	\N	\N	client
d383ad06-2595-412a-9482-2fe087340ee6	julietasuarez2301@gmail.com	$2b$10$eS/rZsaBXpc8GG2uLpjfqOoU6jKYnGyJiJvh5a1xDgEwCc./BVN36	julieta suarez villalba	2025-07-30 16:58:06.706813	2025-07-30 16:58:06.706813	\N	\N	\N	\N	2007-01-22	\N	\N	\N	client
65f9d472-3af7-4af5-85f3-7a04f5705059	lunatiseira@gmail.com	$2b$10$jURbMVKeyW3CE1Q0pl0BwuLH2B6ZWsxJJzP1QJhE2X3PwT1pD6elW	luna tiseira	2025-07-30 17:04:57.243034	2025-07-30 17:06:17.839127	\N	https://res.cloudinary.com/di4ikaeke/image/upload/v1753895177/sucht/profiles/vsbvfz4y3m8erl06k0jg.jpg	lunatdoll		2006-10-30	princessdoll	\N	\N	client
678c1c18-049c-4188-b064-6fd77981b679	mrxboxlb@gmail.com	$2b$10$MT.ftTaR9HsFe2RrhN8tJu0Ru51iDWhgyg.3DHBW601DVq0AU0twO	Alejo 	2025-07-30 17:20:20.169836	2025-07-30 17:22:30.753758	\N	https://res.cloudinary.com/di4ikaeke/image/upload/v1753896150/sucht/profiles/wukpicpaujerx5gp8pj4.jpg	alee_.199	1149132963	2005-04-28	Alejo199	\N	\N	client
a8f42fd3-8353-449a-88d8-40cf93df4bbb	matias2091@hotmail.com	$2b$10$xsDRtUnPx1pWzEX14iiGPedGDgwdPfR04TDz3zPcePRzgtMMXCAXW	Ariel Slobodiuk	2025-07-30 18:23:30.199664	2025-07-30 18:23:30.199664	\N	\N	\N	\N	1991-04-29	\N	\N	\N	client
c942b38f-9c12-41ea-aa1e-1908c0a2cf3b	alma.gimenez1609@gmail.com	$2b$10$JgUOcsFTIS.WWBDtYXQ/VuHRYYjPZ9Ut/PNBWMAU/1Avgq6AUMgzW	Alma Gimenez	2025-07-30 19:07:33.552416	2025-07-30 19:07:33.552416	\N	\N	\N	\N	2004-11-18	\N	\N	\N	client
8e9bf2e4-fc5d-47f4-9075-c9a80e5ef4b0	priscilaarivero1@gmail.com	$2b$10$L9caGXaxXFiUNdhBedrHYeJKCPRhXCNxeKeVRL4SjAxgyzAiajETm	Priscila Rivero	2025-07-30 19:41:38.902329	2025-07-30 19:41:38.902329	\N	\N	\N	\N	2006-03-02	\N	\N	\N	client
89d4e45c-1942-46a2-a2b9-d9da89d3e1be	sofiacn2009@gmail.com	$2b$10$YKesmjxAQORkyewGAO4CSOPp4hMJI1zz.vbJ38yr24O5Iy0V8DY5W	Sofia Noguer	2025-07-30 21:54:38.20082	2025-07-30 21:54:38.20082	\N	\N	\N	\N	2006-06-19	\N	\N	\N	client
67abba70-2b85-4f3b-ac5b-2f6c7f1da57d	nahuelmmaldo007@gmail.com	$2b$10$CBkAFFhmleiMPQc/Ubk7WuFv3FE.1cKi0Wak.ucmGQNrW4eYxDZkK	Nahuel Maldonado 	2025-07-30 22:37:32.596542	2025-07-30 22:37:32.596542	\N	\N	\N	\N	2007-02-26	\N	\N	\N	client
9ddb087c-7a86-4def-82e7-16b87a47c7ef	danteemiliano22@gmail.com	$2b$10$nd2sO4auA5YCMVhRY/OuIOs03m4c1diqRjumVAcPrPJGwytcSXaIa	Dante Bedros	2025-07-30 22:58:32.048264	2025-07-30 22:58:32.048264	\N	\N	\N	\N	2001-11-27	\N	\N	\N	client
6fdbb244-f487-44df-a18b-59a533501f34	maitecardozo2007@gmail.com	$2b$10$H7C5AhCEkQhGXoo8.AxMA.6oelJDlQ/KwDejKTNGA/PP5WwBZP7li	Maite Cardozo	2025-07-30 23:40:03.295945	2025-07-30 23:41:18.043301	\N	\N	Maii		2007-01-13	Maiteee	\N	\N	client
a4a4daa1-9960-41a2-ab4b-92fa7d1cc49e	denissepaez220607@icloud.com	$2b$10$8A4Ii2HA9nCTBQi/XY6wPOgXNVgc4WJQ6uT3TcvVxffNN0e23crUW	denisse paez	2025-07-31 00:15:38.481317	2025-07-31 00:15:38.481317	\N	\N	\N	\N	2007-06-21	\N	\N	\N	client
69581673-121f-4195-8648-ac726a61545f	varelanahiara94@gmail.com	$2b$10$D0J2tgwI1So6aCM7jKVE3eUqMXH.vOIEst9GZlmQVtUPMgozgztFa	Nahiara	2025-07-31 01:02:57.944712	2025-07-31 01:02:57.944712	\N	\N	\N	\N	2008-10-30	\N	\N	\N	client
92a7df8b-9049-4750-a57b-a6eee5fc5e19	valentinamurielflores@gmail.com	$2b$10$ORZeyAou3bhp29CX0CCZ6eCC7KvkFwFgb9gfiaKiDMOBOqyTUAyYS	Valentina Flores	2025-07-31 01:24:13.144219	2025-07-31 01:24:13.144219	\N	\N	\N	\N	2006-10-04	\N	\N	\N	client
6e8ea36d-288c-4942-8e93-eac7c85d20db	nonigirones2004@gmail.com	$2b$10$g31TPYEqwHfqcFowikREpuWNuzXDgSoCfSvZmn5XZzqssKJ/gG/Q2	Noelia 	2025-07-31 01:49:28.326504	2025-07-31 01:49:28.326504	\N	\N	\N	\N	2025-08-29	\N	\N	\N	client
d41b4f5c-b6a0-4496-9e43-3c6f9c7c0fd5	lunajazminkelezuki@gmail.com	$2b$10$KuxWFTCcnxpG7jvhBaKnyeQLXQ57c9HFHNwUgeS29DfHLSzFR0Ubi	Luna Kelezuki	2025-07-31 02:54:19.071052	2025-07-31 02:54:19.071052	\N	\N	\N	\N	2007-03-31	\N	\N	\N	client
506b8df7-6a22-4f1f-b495-663fe83a3b2c	mldelgado22@gmail.com	$2b$10$GNKkwVKYWfncLKiBNzyMVu/5ZEZ19X2eH8ioRlm1DfWX5b5bEPfFy	Marcos Delgado	2025-07-31 03:58:19.187538	2025-07-31 03:58:19.187538	\N	\N	\N	\N	2003-07-30	\N	\N	\N	client
19c3c8e2-6cda-4a62-92e7-3f478bfaad5a	gonzaah4@gmail.com	$2b$10$NTa1WUO.l1uBoTsL3ocI.u9Vti7CBgYmRVOgINY.f5lynzVBtJRlW	Gonzalo 	2025-07-31 06:50:19.588967	2025-07-31 06:50:19.588967	\N	\N	\N	\N	2006-12-28	\N	\N	\N	client
87432028-a1f8-473d-b904-acbe36f6ffa1	florledesma3107@gmail.com	$2b$10$vXvisS.9XzhqaBI9vxdi4O8o76ELNcmqvPAQIJJFMeEhCAWkGSaCi	Flor Ledesma	2025-07-31 16:42:55.199197	2025-07-31 16:42:55.199197	\N	\N	\N	\N	2007-07-30	\N	\N	\N	client
941ccd61-74b7-4fd2-bccf-7cd45f76930c	agustinnahuelrex@gmail.com	$2b$10$8daWfr8DrO.ZWFDsSMyeOuBuvWLjZQZCkGWzn6BV/DE35fH6veCU2	Agustín Bracalenti 	2025-07-31 17:02:03.895798	2025-07-31 17:02:03.895798	\N	\N	\N	\N	2005-09-26	\N	\N	\N	client
01419337-3088-472d-a0c4-d1c2e959ea16	sabrinamiras75@gmail.com	$2b$10$5wbo8k.o52lIEunmHVWzdOxwXDE0bh5YmONZbV1AzTdNtltfpoZlm	Sabrina Miras	2025-07-31 17:03:12.780473	2025-07-31 17:03:12.780473	\N	\N	\N	\N	2005-12-13	\N	\N	\N	client
5671600f-833f-4e69-9f38-3002b3de3a15	yissebarrionuevo3@gmail.com	$2b$10$iOG9UPfN59.bxPmq4aFiY.3r6VFqYQVU2PfwLbFo8t0Yud18Vskwa	Mirna Barrionuevo	2025-07-31 17:11:43.755803	2025-07-31 17:11:43.755803	\N	\N	\N	\N	2001-08-10	\N	\N	\N	client
8ac77628-afb6-4232-9e65-e75077f9f5a8	ssonnleintner@gmail.com	$2b$10$Zalq8nRmBxavmqXNYmUal.V4luqgbWlpNjqxpaQBaS70JluF1i5r2	Stefania Sonnleintner	2025-07-31 18:01:51.938701	2025-07-31 18:01:51.938701	\N	\N	\N	\N	2006-06-05	\N	\N	\N	client
c49c5f85-6561-4fde-8122-d484d0e25c82	eveayunta13@gmail.com	$2b$10$XKgm5McumPU.bS//ts6fGe45Kw2vegp3FyN/RpwMzRVAdnjiX462q	Evelyn Ayunta 	2025-07-31 19:53:56.309812	2025-07-31 19:53:56.309812	\N	\N	\N	\N	2003-01-16	\N	\N	\N	client
0537e40e-ccd6-4386-b978-50dfea6d78e0	valen.nadir@hotmail.es	$2b$10$oLl3VlRDldGlsPARcQ5UDOG6VwpAKSERt7c3UNgc0n7QtS3spicve	Valentin	2025-07-31 20:09:49.899932	2025-07-31 20:09:49.899932	\N	\N	\N	\N	2000-07-14	\N	\N	\N	client
c2682ba9-efeb-4a65-b09c-226f774223ee	nabilaailenarena@gmail.com	$2b$10$.cbWImCF4fxGAeoOzdPy7uLmpr5KE0PiBGffYAuEqa.E/v6BEAKtu	Nabila Arena	2025-07-31 20:10:59.971923	2025-07-31 20:10:59.971923	\N	\N	\N	\N	2004-02-12	\N	\N	\N	client
29074af4-cf1e-4be7-8f8c-dde7d4dcda49	quatrini2510@gmail.com	$2b$10$L62CAjA7d7hck8ae1D5p9.TDV3C8Y/QgJ92/Hl2rExF.XZhRJYa6q	Vito Quatrini	2025-07-31 21:03:46.582811	2025-07-31 21:03:46.582811	\N	\N	\N	\N	2006-10-24	\N	\N	\N	client
006ccff3-9b03-42ee-837b-9b8b58372877	josechaffardon@gmail.com	$2b$10$49Vh2EUJHxIqfDoOJ8K5zeuLnReHN5cxCcRc8NWKM9PVwz/fBC5r2	jossecff 	2025-08-01 04:40:20.383262	2025-08-01 04:40:20.383262	\N	\N	\N	\N	2008-09-30	\N	\N	\N	client
\.


--
-- Data for Name: users_backup; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_backup (id, email, password, name, "createdAt", "updatedAt", "invitationToken", "profileImageUrl", "instagramHandle", "whatsappNumber", "dateOfBirth", username, "mercadoPagoAccessToken", "rrppCommissionRate", roles) FROM stdin;
6c211e01-0d59-48c7-a487-50feb60e3275	camiloorzusa20@gmail.com	$2b$10$o03yzmNf9xvZftUCE5ZOIeA06MyKXb4NKK.7DSEaypGY24AWdzWDG	Diego 	2025-07-29 17:17:18.393388	2025-07-29 17:17:18.393388	\N	\N	\N	\N	2006-07-19	\N	\N	\N	["client"]
9b9c6c76-8578-4b3f-818c-8497bdc43c39	timberinil@gmail.com	$2b$10$JSwJTRwrRf8M4uD5NEKVn.thaZtqk9lkSUFddUc.sANnKXrNC/Yk.	Leandro Timberini	2025-07-25 01:13:20.381285	2025-07-28 22:02:29.518566	\N	\N	leaa.emanuel	+5491126658293	1990-09-27	leaaemanuel	\N	\N	["client"]
a2d2a471-9c55-4e3f-b55e-f0953d189445	biancastorear@gmail.com	$2b$10$oSmycNDuik24EOPgIwIez.TgDZlBkr45OdIpYM2TvvRBQTUYW.RGS	leandro	2025-07-28 23:53:27.613373	2025-07-28 23:53:27.613373	\N	\N	\N	\N	1990-09-28	\N	\N	\N	["client"]
479c4cc1-812c-4de5-959e-ac1c306731f3	acarabajal676@gmail.com	$2b$10$peH/oMPSQzHsiC3kZp3ztecn1cbvynym6.TtyjoI0cRnY2swZikHK	lean carabajal	2025-07-29 17:36:36.727206	2025-07-29 17:36:36.727206	\N	\N	\N	\N	2006-08-18	\N	\N	\N	["client"]
c4abb86d-5955-416d-aef5-332ca77b8cfa	samaradenot@gmail.com	$2b$10$lPkbUaUz/sgMUV7zue6YWeb2A9TO2/B.jatzc2XY40a.L5YmSnPlq	Samara Denot	2025-07-29 15:55:08.657342	2025-07-29 16:15:17.032959	\N	\N	sammel.denot	+541123944815	2006-02-15	sami	\N	\N	["client"]
ab0d635f-9b54-4119-acde-6d852fbedc2c	danipdp26@gmail.com	$2b$10$0oj0s7ntAxVtu1KNDfHqkeuKMTaNownTcWAJ3oXwnX9WoPMCAc7EG	Pablo Daniel Pitocco	2025-07-29 17:44:30.049469	2025-07-29 17:44:30.049469	\N	\N	\N	\N	2007-08-24	\N	\N	\N	["client"]
8aef3c74-f314-4649-9a24-84a2aa4b2ad5	Julianabruno3760@gmail.com	$2b$10$VwCPvIBXu.vvk.XZTU2JAeP2aHMZ9N9BiSDqRK6G03VX3IAZmBXwq	Juliana	2025-07-29 15:42:43.971033	2025-07-29 16:37:46.890852	\N	https://res.cloudinary.com/di4ikaeke/image/upload/v1753806942/sucht/profiles/kzxda2tlni3ulkizqb90.jpg	Juuli.bruno	1171287158	2003-10-14	Juu	\N	\N	["client"]
39750677-0b52-4d9f-93c3-efd2b09f840f	olivaresmatilda05@gmail.com	$2b$10$FVgRLyFkM4X86djsiFMuvOqaZNZnyFTdjt5.A/geXOTrr2wC/WpRa	matil	2025-07-29 17:44:29.158714	2025-07-29 17:45:15.807618	\N	\N			2006-04-22	matil23	\N	\N	["client"]
21b23712-d0fe-49df-8162-8f29997a448f	sucht.castelar@gmail.com	$2b$10$V8cSsULZYM4ItEExFqR02OkbDBCvbt.7vPhOb0ScWNn3ApV6YhDiC	SUCHT	2025-07-25 01:13:11.365417	2025-07-29 16:46:00.942649	\N	https://res.cloudinary.com/di4ikaeke/image/upload/v1753807541/sucht/profiles/k7ovvf91mzmxtvietijg.png	sucht.oficial	+5491152738137	1990-09-28	suchtoficial	\N	\N	["client"]
b18508d6-daa6-4628-a62a-d72336f7b3a0	velencarrera@gmail.com	$2b$10$P2pQbPNEJaLL7XVI1WInwO.FSevU1CbJ6MTi7dlGIJ/L4sI1UA94i	Valentina carrera	2025-07-29 16:56:01.663626	2025-07-29 16:56:01.663626	\N	\N	\N	\N	2006-08-06	\N	\N	\N	["client"]
4f52a0d7-2a74-420f-b19a-cf1e151b3bed	belu.fbm2005@gmail.com	$2b$10$Lclm10HIhNsZ1gF0cYeH8uoy1ULLygvRDZH30H3s6yMTa5OMeuZWe	belu	2025-07-29 17:00:35.521927	2025-07-29 17:00:35.521927	\N	\N	\N	\N	2005-08-02	\N	\N	\N	["client"]
2ec87a08-10aa-47c1-abe1-b7468b1a46fd	vicychi.21@gmail.com	$2b$10$.PZuA/OHiJK7JYa2D496ferloO/Cu/0vXxgdHWixHFIkavQEPMfDS	Victoria Nikollek	2025-07-29 17:01:37.835626	2025-07-29 17:01:37.835626	\N	\N	\N	\N	2003-04-20	\N	\N	\N	["client"]
e06debd4-c6df-48af-aefc-242bcac30b04	sharonbarbona2221@gmail.com	$2b$10$gfxJaPSzh1vuyk0tsmG3rODdRR0qmgJ72UH34TWai9TwAQy1c2rpy	Sharon Barbona	2025-07-29 17:01:46.752474	2025-07-29 17:01:46.752474	\N	\N	\N	\N	2003-12-21	\N	\N	\N	["client"]
6c2b3ce5-e46f-4c7f-8cc2-46b2003cc0c2	criss.arce2009@gmail.com	$2b$10$HXxKtt/dHdEGORw0uONXcO5d15WAOE0UWxyI.yhyWmewoVsWN.sKy	Cris Arce	2025-07-29 17:05:12.141567	2025-07-29 17:05:12.141567	\N	\N	\N	\N	2004-11-13	\N	\N	\N	["client"]
d8211373-f3af-4b86-b577-fefd7cf6d483	candelariotta1@gmail.com	$2b$10$x9BsOB0W9hVCyUx7pHrO3eYuUtSmg2zR.w2kWoIhUC7tlNBzPIi7i	Candela riotaa	2025-07-29 17:07:43.269732	2025-07-29 17:07:43.269732	\N	\N	\N	\N	2007-02-15	\N	\N	\N	["client"]
34116a9e-7b82-439b-ad07-ea949cd1ba33	facugomezdj98@icloud.com	$2b$10$qy80ICxaA9xKTogyGqwSbuVrhjKSY/9sX5vpWHHJVpw/q/jAguoMe	Facundo Gomez	2025-07-25 07:47:26.95426	2025-07-25 07:47:26.95426	\N	\N	\N	\N	\N	\N	\N	\N	["client"]
67aac44f-f0e1-46dc-9e84-14771202f1db	brendabalmaceda118@gmail.com	$2b$10$zvJE.eCPuFgRqq/a8zKtWOUze1M.KuoUBM91vNK/Ga.H7Vgdx9hl6	Brenda Airin Balmaceda	2025-07-29 17:48:21.028613	2025-07-29 17:48:21.028613	\N	\N	\N	\N	2003-10-14	\N	\N	\N	["client"]
6b3136ca-a0a5-463a-972c-60454405e706	laaraa.fernandez.h@gmail.com	$2b$10$W7kqhapFqhB4RlQ6eqwBpOK/Kk7dd.LQBTjnE3oyL4srzVthXuO.O	lara	2025-07-29 19:01:44.205301	2025-07-29 19:01:44.205301	\N	\N	\N	\N	2006-07-06	\N	\N	\N	["client"]
40608417-6eeb-4e9e-bce4-cd95849c62d8	schuckmanerika@gmail.com	$2b$10$WrsoSXcMna0H5IZljkmMveiS/TQxyMcA5cUVmRQrsoqBu3xkDseq6	Erika	2025-07-29 19:43:10.767047	2025-07-29 19:43:10.767047	\N	\N	\N	\N	2007-02-06	\N	\N	\N	["client"]
a80b6717-24db-4ac1-8e85-b01da3ceb648	belenmelano3@gmail.com	$2b$10$bymcwRuDZCGP8Ia88Ktwe.0qzK0.gwGuJMDxoCP/THgXvd2QPuVe6	Belen melano 	2025-07-29 17:10:22.854612	2025-07-29 17:10:22.854612	\N	\N	\N	\N	2004-06-03	\N	\N	\N	["client"]
2bf149e0-04b5-4016-aa45-31eadb6a32ce	giulianafranco604@gmail.com	$2b$10$NDl4yaS/cyr5f9Q2.7vdDumKOmFIXWn8v7yElvaKLygG2RM/wDn9m	Giuliana Franco	2025-07-29 17:13:39.325359	2025-07-29 17:13:39.325359	\N	\N	\N	\N	2006-09-02	\N	\N	\N	["client"]
0db2361b-a9e6-47c7-b59b-853f55755d1b	barriosaabi@gmail.com	$2b$10$G2DI0tEsnQ8InNB88Uejt.YJyi/DOW3eUWOz/rtKF0kg2eo4lmFcq	Abi Barrios	2025-07-29 19:46:42.972811	2025-07-29 19:46:42.972811	\N	\N	\N	\N	2006-07-15	\N	\N	\N	["client"]
c673a16b-4635-4d67-ae44-cc89a929d793	vero.aveen99@gmail.com	$2b$10$WihmmylRWdpesB0a870RHO7vd9TfJ0h.JhkqLAnmwEdiqeMQGjCYO	Verónica Chazarreta 	2025-07-29 19:47:44.849385	2025-07-29 19:47:44.849385	\N	\N	\N	\N	2002-07-08	\N	\N	\N	["client"]
922cde8b-4f25-4782-8caa-3dc6af6306e8	altamiranojacqueline325@gmail.com	$2b$10$ODJa3Slz32qPkviSi.IAHen//QVp8T4LxlGEHChnzVVWIh/PwdGwC	jacqueline altamirano	2025-07-29 20:14:57.732024	2025-07-29 20:14:57.732024	\N	\N	\N	\N	2007-07-18	\N	\N	\N	["client"]
3e0bc2e9-2836-42b5-bc47-be9245c0729e	angelestiberi76@gmail.com	$2b$10$33HDViWYiZHt45Wp8nQQc.Kn3YlRbgVW7V7bOqUff31uo5DqKD/P6	Angeles tiberi 	2025-07-29 21:58:22.499634	2025-07-29 21:58:22.499634	\N	\N	\N	\N	2005-10-06	\N	\N	\N	["client"]
5ada1449-4878-464c-b8d4-4103d4c0ca0c	diegomateososa@gmail.com	$2b$10$qznrXKg6/MYYbipS3eYpneZwLmi.HAXlC5yWjbRYTZD7VmC9Ehko2	diego mateo sosa	2025-07-29 22:29:34.360359	2025-07-29 22:29:34.360359	\N	\N	\N	\N	2007-04-22	\N	\N	\N	["client"]
5a25275d-2d69-434a-b9d9-534d72052e0b	diegomateososa23@gmail.com	$2b$10$ozUXDO7S4KmEu/22b89NGucnXOJ.pmn06hG3oMQnikm5x1XafNu/2	Diego mateo	2025-07-29 22:31:02.579345	2025-07-29 22:31:02.579345	\N	\N	\N	\N	2007-04-22	\N	\N	\N	["client"]
11835074-685a-4940-955b-840e1a499e5a	sanchezchaveznicolas614@gmail.com	$2b$10$r9pr175HQV6sEiH/Poc85uwRNDy4N1Z83m72/OqlDdPNiRjYC8ya2	Augusto Sanchez	2025-07-29 23:27:33.359336	2025-07-29 23:27:33.359336	\N	\N	\N	\N	2006-12-10	\N	\N	\N	["client"]
53bb60b4-cb4d-4217-87f9-d779ae5dd58a	cambbravo07@gmail.com	$2b$10$7VaszRS12mwOWW3DdpItfuM4S9xQTZoYaZ6hOywqNVAk017/MWe4G	Camila Bravo	2025-07-29 23:32:02.20837	2025-07-29 23:32:02.20837	\N	\N	\N	\N	2007-03-01	\N	\N	\N	["client"]
0d6b21a4-828a-4ecb-b436-bb91b03b3f76	priscagianichini39@gmail.com	$2b$10$X3Ey7aYH4QAsMVuD/9fus.SfisImADGoMIXRSdDHe7imcT.4DIZrO	Prisca Gianichini	2025-07-30 00:06:25.489272	2025-07-30 00:07:34.667462	\N	\N	__priscaa__	91160347106	2007-03-07	Prisca	\N	\N	["client"]
468c2ff1-1cee-4b70-a198-c72819366c48	isaanael08@gmail.com	$2b$10$tNqQxeaPQBQbfM4.vy9KF.1pB89BErdAcc1lZN3xIDxoGIDAa46wO	Anael Isa	2025-07-30 00:15:02.167452	2025-07-30 00:15:02.167452	\N	\N	\N	\N	2006-07-04	\N	\N	\N	["client"]
24a5a5f9-1646-434c-9fbb-b43c00029524	luanacandelaria07@gmail.com	$2b$10$W/jHQiLikvONsJ.kW2P3cuqgJJauVd4mNeGsZ1TT1A4pIgFUIcuWq	luana marques	2025-07-30 00:45:55.430213	2025-07-30 00:45:55.430213	\N	\N	\N	\N	2007-05-01	\N	\N	\N	["client"]
23838215-8ac2-403a-a3f7-f70ad6f0a57f	gadshopar@gmail.com	$2b$10$HMvHjTgyoLETK9wQXgkylunBFrKrtWcktUcVQlG4BYuPgb3bXz6H2	Leaa	2025-07-29 21:43:22.245471	2025-07-29 21:43:22.245471	\N	\N	\N	\N	1990-09-28	\N	\N	\N	["client"]
c79bfe72-9f7c-456a-b934-4f1ccb9d53cf	leaa@sucht.com.ar	$2b$10$iez479V8Fgeq5AVdHL8Wgekw9WphogPhGKvr367gBKw5pHi6LCqGu	Leandro	2025-07-23 22:53:29.215082	2025-07-28 22:03:55.859389	\N	https://res.cloudinary.com/di4ikaeke/image/upload/v1753735496/sucht/profiles/orhqvdywoj7itnkk2cxf.jpg	leaa.emanuel	+5491126658293	1990-09-16	leaa	\N	\N	owner,admin,client
708a3c9b-e9dc-47cc-a45d-29e1c9d834ea	brisa_b20@hotmail.com	$2b$10$RVxl7pTFcZ1NRYCDuyWpXuUDttr8uK9pyGGHgOETINKGUFVPBHcOm	brisa lagoria	2025-07-30 01:02:54.700288	2025-07-30 01:02:54.700288	\N	\N	\N	\N	2006-07-18	\N	\N	\N	["client"]
194478c4-4aaf-4b25-9355-e7c2c17d0d8f	aimesofiafernandez2006@gmail.com	$2b$10$IXTafh0d/RBrs7gr5OkKlOHyAvWxqHMKUpJzq0ggMSOY1.5aOm39q	aime fernandez	2025-07-30 01:04:15.358866	2025-07-30 01:04:15.358866	\N	\N	\N	\N	2006-10-05	\N	\N	\N	["client"]
adc1fecf-0cd2-4065-a941-6b53002389ee	loanaelisaven@gmail.com	$2b$10$pA7mpB/vCOHYBcwC/0ybEeUyhUlWBZtqOQ.L38sPxCZJEkDQn6bT.	Loana Avendaño	2025-07-30 01:14:09.22276	2025-07-30 01:15:11.075527	\N	\N	Loana_aven	+54 11 51480257	2006-09-12	Loana	\N	\N	["client"]
d69d24da-2384-4334-af18-8d83070f2f2c	juaneliasagustin@gmail.com	$2b$10$x9HzjPHVQAnedTdhLUSBzOMCrzdZMb94Sy9Bmcvphrl9pcZl8tl0.	Elias Juan 	2025-07-30 01:38:27.421719	2025-07-30 01:38:27.421719	\N	\N	\N	\N	2005-12-20	\N	\N	\N	["client"]
639bc0e8-2daf-4c06-8e42-b1adb433d243	francotacacho@gmail.com	$2b$10$dUS3wmu/U7HklHA/F0ePjeVkUusMk/GXUP6rJsVeprfG1BAO7oGAK	Leonel Tacacho 	2025-07-30 02:47:24.099988	2025-07-30 02:47:24.099988	\N	\N	\N	\N	2001-01-02	\N	\N	\N	["client"]
6a3c4eff-f44a-4f1a-b289-efb22c6d6661	gabriel.leonel.perez.2006@gmail.com	$2b$10$/MFwPiHEDRpsOR5J.Y/Oeuq3m1fSjZk6SVIZtAasJHUl6TwP8EB6a	Gabriel Pérez 	2025-07-30 03:31:14.044308	2025-07-30 03:33:20.001774	\N	\N	_pereeeeezz 		2006-04-18	Pereez	\N	\N	["client"]
ff1a34d7-d88e-46ea-8953-d77b46738453	agustina.agotegaray@estudiantes.unahur.edu.ar	$2b$10$C8hNb60Byczq6lK1iiUsdea1t2u/nNwYqjH1Y.lG4TKUqsVaQ7sHm	Agustina Agotegaray	2025-07-30 07:02:07.594741	2025-07-30 07:02:07.594741	\N	\N	\N	\N	2004-06-24	\N	\N	\N	["client"]
aa1df6bc-47de-475b-992b-f4255adfef2b	narellaescobar3@gmail.com	$2b$10$CO56eK412C37fiwxecNQGO0Y.E1tmFg2N3U5d.SnF8reVAUkADWyO	narella escobar	2025-07-30 12:55:56.631844	2025-07-30 12:55:56.631844	\N	\N	\N	\N	2007-05-22	\N	\N	\N	["client"]
7cf04169-b4f1-4adf-8569-e1158977b93c	miasajama19@gmail.com	$2b$10$HbkiU4Z20b.sQ.bOmvpqEOkJyQkNMVW1xSQ1/IrxhOXGdahrhNK5C	Mia Sajama	2025-07-30 14:30:33.903122	2025-07-30 14:30:33.903122	\N	\N	\N	\N	2005-01-18	\N	\N	\N	["client"]
d917671f-9113-4c6f-8124-507a30540217	pettystylinson@gmail.com	$2b$10$Hd7OspoYX5u8P7VMumv2x.KIW.Uqehts7iFMe7C.Q0z5yqZzdGnCe	keila sobrile 	2025-07-30 16:18:24.806751	2025-07-30 16:18:24.806751	\N	\N	\N	\N	2002-04-22	\N	\N	\N	["client"]
d383ad06-2595-412a-9482-2fe087340ee6	julietasuarez2301@gmail.com	$2b$10$eS/rZsaBXpc8GG2uLpjfqOoU6jKYnGyJiJvh5a1xDgEwCc./BVN36	julieta suarez villalba	2025-07-30 16:58:06.706813	2025-07-30 16:58:06.706813	\N	\N	\N	\N	2007-01-22	\N	\N	\N	["client"]
65f9d472-3af7-4af5-85f3-7a04f5705059	lunatiseira@gmail.com	$2b$10$jURbMVKeyW3CE1Q0pl0BwuLH2B6ZWsxJJzP1QJhE2X3PwT1pD6elW	luna tiseira	2025-07-30 17:04:57.243034	2025-07-30 17:06:17.839127	\N	https://res.cloudinary.com/di4ikaeke/image/upload/v1753895177/sucht/profiles/vsbvfz4y3m8erl06k0jg.jpg	lunatdoll		2006-10-30	princessdoll	\N	\N	["client"]
678c1c18-049c-4188-b064-6fd77981b679	mrxboxlb@gmail.com	$2b$10$MT.ftTaR9HsFe2RrhN8tJu0Ru51iDWhgyg.3DHBW601DVq0AU0twO	Alejo 	2025-07-30 17:20:20.169836	2025-07-30 17:22:30.753758	\N	https://res.cloudinary.com/di4ikaeke/image/upload/v1753896150/sucht/profiles/wukpicpaujerx5gp8pj4.jpg	alee_.199	1149132963	2005-04-28	Alejo199	\N	\N	["client"]
a8f42fd3-8353-449a-88d8-40cf93df4bbb	matias2091@hotmail.com	$2b$10$xsDRtUnPx1pWzEX14iiGPedGDgwdPfR04TDz3zPcePRzgtMMXCAXW	Ariel Slobodiuk	2025-07-30 18:23:30.199664	2025-07-30 18:23:30.199664	\N	\N	\N	\N	1991-04-29	\N	\N	\N	["client"]
c942b38f-9c12-41ea-aa1e-1908c0a2cf3b	alma.gimenez1609@gmail.com	$2b$10$JgUOcsFTIS.WWBDtYXQ/VuHRYYjPZ9Ut/PNBWMAU/1Avgq6AUMgzW	Alma Gimenez	2025-07-30 19:07:33.552416	2025-07-30 19:07:33.552416	\N	\N	\N	\N	2004-11-18	\N	\N	\N	["client"]
8e9bf2e4-fc5d-47f4-9075-c9a80e5ef4b0	priscilaarivero1@gmail.com	$2b$10$L9caGXaxXFiUNdhBedrHYeJKCPRhXCNxeKeVRL4SjAxgyzAiajETm	Priscila Rivero	2025-07-30 19:41:38.902329	2025-07-30 19:41:38.902329	\N	\N	\N	\N	2006-03-02	\N	\N	\N	["client"]
89d4e45c-1942-46a2-a2b9-d9da89d3e1be	sofiacn2009@gmail.com	$2b$10$YKesmjxAQORkyewGAO4CSOPp4hMJI1zz.vbJ38yr24O5Iy0V8DY5W	Sofia Noguer	2025-07-30 21:54:38.20082	2025-07-30 21:54:38.20082	\N	\N	\N	\N	2006-06-19	\N	\N	\N	["client"]
67abba70-2b85-4f3b-ac5b-2f6c7f1da57d	nahuelmmaldo007@gmail.com	$2b$10$CBkAFFhmleiMPQc/Ubk7WuFv3FE.1cKi0Wak.ucmGQNrW4eYxDZkK	Nahuel Maldonado 	2025-07-30 22:37:32.596542	2025-07-30 22:37:32.596542	\N	\N	\N	\N	2007-02-26	\N	\N	\N	["client"]
9ddb087c-7a86-4def-82e7-16b87a47c7ef	danteemiliano22@gmail.com	$2b$10$nd2sO4auA5YCMVhRY/OuIOs03m4c1diqRjumVAcPrPJGwytcSXaIa	Dante Bedros	2025-07-30 22:58:32.048264	2025-07-30 22:58:32.048264	\N	\N	\N	\N	2001-11-27	\N	\N	\N	["client"]
6fdbb244-f487-44df-a18b-59a533501f34	maitecardozo2007@gmail.com	$2b$10$H7C5AhCEkQhGXoo8.AxMA.6oelJDlQ/KwDejKTNGA/PP5WwBZP7li	Maite Cardozo	2025-07-30 23:40:03.295945	2025-07-30 23:41:18.043301	\N	\N	Maii		2007-01-13	Maiteee	\N	\N	["client"]
a4a4daa1-9960-41a2-ab4b-92fa7d1cc49e	denissepaez220607@icloud.com	$2b$10$8A4Ii2HA9nCTBQi/XY6wPOgXNVgc4WJQ6uT3TcvVxffNN0e23crUW	denisse paez	2025-07-31 00:15:38.481317	2025-07-31 00:15:38.481317	\N	\N	\N	\N	2007-06-21	\N	\N	\N	["client"]
69581673-121f-4195-8648-ac726a61545f	varelanahiara94@gmail.com	$2b$10$D0J2tgwI1So6aCM7jKVE3eUqMXH.vOIEst9GZlmQVtUPMgozgztFa	Nahiara	2025-07-31 01:02:57.944712	2025-07-31 01:02:57.944712	\N	\N	\N	\N	2008-10-30	\N	\N	\N	["client"]
92a7df8b-9049-4750-a57b-a6eee5fc5e19	valentinamurielflores@gmail.com	$2b$10$ORZeyAou3bhp29CX0CCZ6eCC7KvkFwFgb9gfiaKiDMOBOqyTUAyYS	Valentina Flores	2025-07-31 01:24:13.144219	2025-07-31 01:24:13.144219	\N	\N	\N	\N	2006-10-04	\N	\N	\N	["client"]
6e8ea36d-288c-4942-8e93-eac7c85d20db	nonigirones2004@gmail.com	$2b$10$g31TPYEqwHfqcFowikREpuWNuzXDgSoCfSvZmn5XZzqssKJ/gG/Q2	Noelia 	2025-07-31 01:49:28.326504	2025-07-31 01:49:28.326504	\N	\N	\N	\N	2025-08-29	\N	\N	\N	["client"]
d41b4f5c-b6a0-4496-9e43-3c6f9c7c0fd5	lunajazminkelezuki@gmail.com	$2b$10$KuxWFTCcnxpG7jvhBaKnyeQLXQ57c9HFHNwUgeS29DfHLSzFR0Ubi	Luna Kelezuki	2025-07-31 02:54:19.071052	2025-07-31 02:54:19.071052	\N	\N	\N	\N	2007-03-31	\N	\N	\N	["client"]
506b8df7-6a22-4f1f-b495-663fe83a3b2c	mldelgado22@gmail.com	$2b$10$GNKkwVKYWfncLKiBNzyMVu/5ZEZ19X2eH8ioRlm1DfWX5b5bEPfFy	Marcos Delgado	2025-07-31 03:58:19.187538	2025-07-31 03:58:19.187538	\N	\N	\N	\N	2003-07-30	\N	\N	\N	["client"]
19c3c8e2-6cda-4a62-92e7-3f478bfaad5a	gonzaah4@gmail.com	$2b$10$NTa1WUO.l1uBoTsL3ocI.u9Vti7CBgYmRVOgINY.f5lynzVBtJRlW	Gonzalo 	2025-07-31 06:50:19.588967	2025-07-31 06:50:19.588967	\N	\N	\N	\N	2006-12-28	\N	\N	\N	["client"]
87432028-a1f8-473d-b904-acbe36f6ffa1	florledesma3107@gmail.com	$2b$10$vXvisS.9XzhqaBI9vxdi4O8o76ELNcmqvPAQIJJFMeEhCAWkGSaCi	Flor Ledesma	2025-07-31 16:42:55.199197	2025-07-31 16:42:55.199197	\N	\N	\N	\N	2007-07-30	\N	\N	\N	["client"]
941ccd61-74b7-4fd2-bccf-7cd45f76930c	agustinnahuelrex@gmail.com	$2b$10$8daWfr8DrO.ZWFDsSMyeOuBuvWLjZQZCkGWzn6BV/DE35fH6veCU2	Agustín Bracalenti 	2025-07-31 17:02:03.895798	2025-07-31 17:02:03.895798	\N	\N	\N	\N	2005-09-26	\N	\N	\N	["client"]
01419337-3088-472d-a0c4-d1c2e959ea16	sabrinamiras75@gmail.com	$2b$10$5wbo8k.o52lIEunmHVWzdOxwXDE0bh5YmONZbV1AzTdNtltfpoZlm	Sabrina Miras	2025-07-31 17:03:12.780473	2025-07-31 17:03:12.780473	\N	\N	\N	\N	2005-12-13	\N	\N	\N	["client"]
5671600f-833f-4e69-9f38-3002b3de3a15	yissebarrionuevo3@gmail.com	$2b$10$iOG9UPfN59.bxPmq4aFiY.3r6VFqYQVU2PfwLbFo8t0Yud18Vskwa	Mirna Barrionuevo	2025-07-31 17:11:43.755803	2025-07-31 17:11:43.755803	\N	\N	\N	\N	2001-08-10	\N	\N	\N	["client"]
8ac77628-afb6-4232-9e65-e75077f9f5a8	ssonnleintner@gmail.com	$2b$10$Zalq8nRmBxavmqXNYmUal.V4luqgbWlpNjqxpaQBaS70JluF1i5r2	Stefania Sonnleintner	2025-07-31 18:01:51.938701	2025-07-31 18:01:51.938701	\N	\N	\N	\N	2006-06-05	\N	\N	\N	["client"]
c49c5f85-6561-4fde-8122-d484d0e25c82	eveayunta13@gmail.com	$2b$10$XKgm5McumPU.bS//ts6fGe45Kw2vegp3FyN/RpwMzRVAdnjiX462q	Evelyn Ayunta 	2025-07-31 19:53:56.309812	2025-07-31 19:53:56.309812	\N	\N	\N	\N	2003-01-16	\N	\N	\N	["client"]
0537e40e-ccd6-4386-b978-50dfea6d78e0	valen.nadir@hotmail.es	$2b$10$oLl3VlRDldGlsPARcQ5UDOG6VwpAKSERt7c3UNgc0n7QtS3spicve	Valentin	2025-07-31 20:09:49.899932	2025-07-31 20:09:49.899932	\N	\N	\N	\N	2000-07-14	\N	\N	\N	["client"]
c2682ba9-efeb-4a65-b09c-226f774223ee	nabilaailenarena@gmail.com	$2b$10$.cbWImCF4fxGAeoOzdPy7uLmpr5KE0PiBGffYAuEqa.E/v6BEAKtu	Nabila Arena	2025-07-31 20:10:59.971923	2025-07-31 20:10:59.971923	\N	\N	\N	\N	2004-02-12	\N	\N	\N	["client"]
29074af4-cf1e-4be7-8f8c-dde7d4dcda49	quatrini2510@gmail.com	$2b$10$L62CAjA7d7hck8ae1D5p9.TDV3C8Y/QgJ92/Hl2rExF.XZhRJYa6q	Vito Quatrini	2025-07-31 21:03:46.582811	2025-07-31 21:03:46.582811	\N	\N	\N	\N	2006-10-24	\N	\N	\N	["client"]
5ef32c23-91cd-4084-8a2e-22193db520ad	ianvicencio246@gmail.com	$2b$10$4jy9oPUHZF/5UJ.xXlrcM.Tv3AWRTWrHjhytGz6.XSjkcShAjDWIy	Ian	2025-07-31 23:50:36.479103	2025-07-31 23:51:27.472175	\N	\N	Ian_vicenc	541128697282	2007-02-14	Sombreromagico1	\N	\N	client
c3559e79-8177-4380-94fa-b6d4dbf8925b	thomasbarcelo2006@gmail.com	$2b$10$5J2MIZ8.FrQcSoCNz99MIOINPv/MhzPMnH7Yh/gYXMOPiFjjJf9cu	Thomas barcelo	2025-08-01 00:08:13.718853	2025-08-01 00:08:13.718853	\N	\N	\N	\N	2006-07-17	\N	\N	\N	client
dd6b9eab-f81e-4672-8bd7-7ec38dc31f7d	pilarbazan2605@gmail.com	$2b$10$wrEDg.O.lBe50zgmxhBpr.8BHYAlY2R2XTMTvx1iKrHk3D4n.Xz/K	pily	2025-08-01 00:21:03.807484	2025-08-01 00:21:03.807484	\N	\N	\N	\N	2006-05-25	\N	\N	\N	client
64f02c83-1f5c-4344-96ef-b641fc5b2a8c	josuefmarchioli@gmail.com	$2b$10$zwjNW.t6abJ7PoXjKXpghOr0ANmOzg3GGt1TxneQKQ0kynvYoN3Le	Josue Marchioli 	2025-08-01 00:30:46.82002	2025-08-01 00:30:46.82002	\N	\N	\N	\N	2007-07-15	\N	\N	\N	client
db0e7e8b-80d7-4995-94c6-28d855f2ee60	ayelenbarboza07@gmail.com	$2b$10$v43I8.lw/DPzOUmk/i119O06GGTE0kT/nm2nmyCVa4z1ONZZGHXa2	mayra barboza	2025-08-01 00:54:45.331511	2025-08-01 00:54:45.331511	\N	\N	\N	\N	2004-05-07	\N	\N	\N	CLIENT
5273cbd7-ea62-450e-a5d2-ef5a81086c21	brisatatiana14@gmail.com	$2b$10$hIUHmRxUadr/zt39VBS1FurJfgg3YMxDRy2vvRqJXlOGH0bfRvRQO	brisa delgado	2025-08-01 01:36:27.332117	2025-08-01 01:39:17.224931	\N	\N	briisaa.t	1178973353	2007-02-12	briisaa.t	\N	\N	client
856b56be-230d-424c-afbf-0ca2e857b210	axeljazmin6@gmail.com	$2b$10$8MZ7Hrmb/Kud5z1O/GI0gevpyCULW.oKQ1DtkZWzkko1XooiEvtQS	Axel	2025-08-01 01:45:22.560915	2025-08-01 01:45:22.560915	\N	\N	\N	\N	2005-10-12	\N	\N	\N	client
bfd2c06a-1352-4830-8b90-8078d00ba06d	juligallo1806@gmail.com	$2b$10$DgVpTEpEx0hFqgvG7HokNOKgJpc/a1ejrTRsRxvBL87LTOAabEfcC	Julieta gallo	2025-08-01 02:27:27.282852	2025-08-01 02:27:27.282852	\N	\N	\N	\N	2004-06-17	\N	\N	\N	client
\.


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sucht_user
--

SELECT pg_catalog.setval('public.migrations_id_seq', 1, true);


--
-- Name: tickets PK_343bc942ae261cf7a1377f48fd0; Type: CONSTRAINT; Schema: public; Owner: sucht_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT "PK_343bc942ae261cf7a1377f48fd0" PRIMARY KEY (id);


--
-- Name: events PK_40731c7151fe4be3116e45ddf73; Type: CONSTRAINT; Schema: public; Owner: sucht_user
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT "PK_40731c7151fe4be3116e45ddf73" PRIMARY KEY (id);


--
-- Name: push_subscriptions PK_757fc8f00c34f66832668dc2e53; Type: CONSTRAINT; Schema: public; Owner: sucht_user
--

ALTER TABLE ONLY public.push_subscriptions
    ADD CONSTRAINT "PK_757fc8f00c34f66832668dc2e53" PRIMARY KEY (id);


--
-- Name: migrations PK_8c82d7f526340ab734260ea46be; Type: CONSTRAINT; Schema: public; Owner: sucht_user
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT "PK_8c82d7f526340ab734260ea46be" PRIMARY KEY (id);


--
-- Name: ticket_tiers PK_917cfec124fa5e8ce04d1e7b865; Type: CONSTRAINT; Schema: public; Owner: sucht_user
--

ALTER TABLE ONLY public.ticket_tiers
    ADD CONSTRAINT "PK_917cfec124fa5e8ce04d1e7b865" PRIMARY KEY (id);


--
-- Name: users PK_a3ffb1c0c8416b9fc6f907b7433; Type: CONSTRAINT; Schema: public; Owner: sucht_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "PK_a3ffb1c0c8416b9fc6f907b7433" PRIMARY KEY (id);


--
-- Name: configurations PK_ef9fc29709cc5fc66610fc6a664; Type: CONSTRAINT; Schema: public; Owner: sucht_user
--

ALTER TABLE ONLY public.configurations
    ADD CONSTRAINT "PK_ef9fc29709cc5fc66610fc6a664" PRIMARY KEY (id);


--
-- Name: push_subscriptions UQ_0008bdfd174e533a3f98bf9af16; Type: CONSTRAINT; Schema: public; Owner: sucht_user
--

ALTER TABLE ONLY public.push_subscriptions
    ADD CONSTRAINT "UQ_0008bdfd174e533a3f98bf9af16" UNIQUE (endpoint);


--
-- Name: configurations UQ_3c658898252e3694655de8a07e7; Type: CONSTRAINT; Schema: public; Owner: sucht_user
--

ALTER TABLE ONLY public.configurations
    ADD CONSTRAINT "UQ_3c658898252e3694655de8a07e7" UNIQUE (key);


--
-- Name: users UQ_97672ac88f789774dd47f7c8be3; Type: CONSTRAINT; Schema: public; Owner: sucht_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_97672ac88f789774dd47f7c8be3" UNIQUE (email);


--
-- Name: users UQ_fe0bb3f6520ee0469504521e710; Type: CONSTRAINT; Schema: public; Owner: sucht_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_fe0bb3f6520ee0469504521e710" UNIQUE (username);


--
-- Name: tickets FK_4bb45e096f521845765f657f5c8; Type: FK CONSTRAINT; Schema: public; Owner: sucht_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT "FK_4bb45e096f521845765f657f5c8" FOREIGN KEY ("userId") REFERENCES public.users(id);


--
-- Name: push_subscriptions FK_4cc061875e9eecc311a94b3e431; Type: FK CONSTRAINT; Schema: public; Owner: sucht_user
--

ALTER TABLE ONLY public.push_subscriptions
    ADD CONSTRAINT "FK_4cc061875e9eecc311a94b3e431" FOREIGN KEY ("userId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: tickets FK_86bd1936907e4b8c05ed264ded4; Type: FK CONSTRAINT; Schema: public; Owner: sucht_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT "FK_86bd1936907e4b8c05ed264ded4" FOREIGN KEY ("promoterId") REFERENCES public.users(id);


--
-- Name: tickets FK_8a101375d173c39a7c1d02c9d7d; Type: FK CONSTRAINT; Schema: public; Owner: sucht_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT "FK_8a101375d173c39a7c1d02c9d7d" FOREIGN KEY ("eventId") REFERENCES public.events(id);


--
-- Name: ticket_tiers FK_a9059a9111a2206081a347d3b6e; Type: FK CONSTRAINT; Schema: public; Owner: sucht_user
--

ALTER TABLE ONLY public.ticket_tiers
    ADD CONSTRAINT "FK_a9059a9111a2206081a347d3b6e" FOREIGN KEY ("eventId") REFERENCES public.events(id) ON DELETE CASCADE;


--
-- Name: tickets FK_d4cdfe3a69b25527954b5957a59; Type: FK CONSTRAINT; Schema: public; Owner: sucht_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT "FK_d4cdfe3a69b25527954b5957a59" FOREIGN KEY ("tierId") REFERENCES public.ticket_tiers(id);


--
-- PostgreSQL database dump complete
--

