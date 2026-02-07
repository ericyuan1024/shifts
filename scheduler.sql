--
-- PostgreSQL database dump
--

\restrict WBaon81hrzF1Ze1bVgajGFYHBjqMy0GyWDpS7qP12HNI1UnthbfkY4D7rrXefqD

-- Dumped from database version 18.1 (Postgres.app)
-- Dumped by pg_dump version 18.1 (Postgres.app)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: AssignmentSource; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."AssignmentSource" AS ENUM (
    'AUTO',
    'MANUAL'
);


ALTER TYPE public."AssignmentSource" OWNER TO postgres;

--
-- Name: PreferenceChoice; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."PreferenceChoice" AS ENUM (
    'WANT',
    'CAN',
    'CANT'
);


ALTER TYPE public."PreferenceChoice" OWNER TO postgres;

--
-- Name: ScheduleStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."ScheduleStatus" AS ENUM (
    'DRAFT',
    'FINALIZED'
);


ALTER TYPE public."ScheduleStatus" OWNER TO postgres;

--
-- Name: UserRole; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."UserRole" AS ENUM (
    'EMPLOYEE',
    'ADMIN'
);


ALTER TYPE public."UserRole" OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Assignment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Assignment" (
    id text NOT NULL,
    "scheduleId" text NOT NULL,
    "shiftSlotId" text NOT NULL,
    "userId" text NOT NULL,
    source public."AssignmentSource" NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Assignment" OWNER TO postgres;

--
-- Name: AvailabilityTemplate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."AvailabilityTemplate" (
    id text NOT NULL,
    "userId" text NOT NULL,
    "roleTypeId" text NOT NULL,
    "dayOfWeek" integer NOT NULL,
    "startTime" text NOT NULL,
    "endTime" text NOT NULL,
    hours double precision NOT NULL,
    choice public."PreferenceChoice" NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."AvailabilityTemplate" OWNER TO postgres;

--
-- Name: Preference; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Preference" (
    id text NOT NULL,
    "userId" text NOT NULL,
    "shiftSlotId" text NOT NULL,
    choice public."PreferenceChoice" NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Preference" OWNER TO postgres;

--
-- Name: RoleType; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."RoleType" (
    id text NOT NULL,
    name text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."RoleType" OWNER TO postgres;

--
-- Name: Schedule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Schedule" (
    id text NOT NULL,
    "weekId" text NOT NULL,
    status public."ScheduleStatus" DEFAULT 'DRAFT'::public."ScheduleStatus" NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    "generatedAt" timestamp(3) without time zone,
    "finalizedAt" timestamp(3) without time zone
);


ALTER TABLE public."Schedule" OWNER TO postgres;

--
-- Name: Session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Session" (
    id text NOT NULL,
    "userId" text NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Session" OWNER TO postgres;

--
-- Name: ShiftSlot; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ShiftSlot" (
    id text NOT NULL,
    "weekId" text NOT NULL,
    "roleTypeId" text NOT NULL,
    date timestamp(3) without time zone NOT NULL,
    "startAt" timestamp(3) without time zone NOT NULL,
    "endAt" timestamp(3) without time zone NOT NULL,
    hours double precision NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."ShiftSlot" OWNER TO postgres;

--
-- Name: ShiftTemplate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ShiftTemplate" (
    id text NOT NULL,
    "roleTypeId" text NOT NULL,
    "dayOfWeek" integer NOT NULL,
    "startTime" text NOT NULL,
    "endTime" text NOT NULL,
    hours double precision NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ShiftTemplate" OWNER TO postgres;

--
-- Name: User; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."User" (
    id text NOT NULL,
    name text NOT NULL,
    role public."UserRole" DEFAULT 'EMPLOYEE'::public."UserRole" NOT NULL,
    "passcodeHash" text NOT NULL,
    weight integer DEFAULT 1 NOT NULL,
    "maxHoursWeek" integer DEFAULT 24 NOT NULL,
    "roleTypeId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."User" OWNER TO postgres;

--
-- Name: Week; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Week" (
    id text NOT NULL,
    "startDate" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Week" OWNER TO postgres;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO postgres;

--
-- Data for Name: Assignment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Assignment" (id, "scheduleId", "shiftSlotId", "userId", source, "createdAt") FROM stdin;
cmlaku09900ouitl0kz6gpj72	cmlaku09000otitl0w7zd0znm	cmlaktzc000nxitl0ezrrifhc	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:41:33.261
cmlaku09900ovitl0ap31qazf	cmlaku09000otitl0w7zd0znm	cmlaktzc000nyitl0awpboxpv	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:41:33.261
cmlaku09900owitl0f7xcgez7	cmlaku09000otitl0w7zd0znm	cmlaktzc000nzitl0vwolzqdf	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:41:33.261
cmlaku09900oxitl047efgshh	cmlaku09000otitl0w7zd0znm	cmlaktzc000o0itl0xlep75m2	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:41:33.261
cmlaku09900oyitl0jkxlqntg	cmlaku09000otitl0w7zd0znm	cmlaktzc000o1itl0e75ftw3u	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:41:33.261
cmlaku09900ozitl003mqiqeo	cmlaku09000otitl0w7zd0znm	cmlaktzc000o2itl0u7x7geim	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:41:33.261
cmlaku09900p0itl07i9z653e	cmlaku09000otitl0w7zd0znm	cmlaktzc000o3itl08bt40fpa	cmlajsige0097itl0gjo69mf7	AUTO	2026-02-06 07:41:33.261
cmlaku09900p1itl0yqt5h6dp	cmlaku09000otitl0w7zd0znm	cmlaktzc000o4itl057hi34il	cmlajt3lw009hitl0avtd37yg	AUTO	2026-02-06 07:41:33.261
cmlaku09900p2itl0vwwfgkz0	cmlaku09000otitl0w7zd0znm	cmlaktzc000o5itl0wp23kl9t	cmlajqxb9008nitl0vy9fe2ob	AUTO	2026-02-06 07:41:33.261
cmlaku09900p3itl0zmtivjci	cmlaku09000otitl0w7zd0znm	cmlaktzc000o6itl0086d6i6o	cmlajqxb9008nitl0vy9fe2ob	AUTO	2026-02-06 07:41:33.261
cmlaku09900p4itl0u9akwa5j	cmlaku09000otitl0w7zd0znm	cmlaktzc000o7itl06kvzq2yt	cmlajqxb9008nitl0vy9fe2ob	AUTO	2026-02-06 07:41:33.261
cmlaku09900p5itl0eykdomvp	cmlaku09000otitl0w7zd0znm	cmlaktzc000o8itl0jmx2xg6l	cmlajsige0097itl0gjo69mf7	AUTO	2026-02-06 07:41:33.261
cmlaku09900p6itl0f0cgliad	cmlaku09000otitl0w7zd0znm	cmlaktzc000nvitl0ias90bdv	cml7r4x0a007sitl0t1judo7d	AUTO	2026-02-06 07:41:33.261
cmlaku09900p7itl09f5qkixb	cmlaku09000otitl0w7zd0znm	cmlaktzc000nwitl0oajbvm4i	cmlajqn7r008iitl0mjd6k2hp	AUTO	2026-02-06 07:41:33.261
cmlaku09900p8itl04glcghce	cmlaku09000otitl0w7zd0znm	cmlaktzc000o9itl0ur6hujgz	cml7r4x0a007sitl0t1judo7d	AUTO	2026-02-06 07:41:33.261
cmlaku09900p9itl0bq4414de	cmlaku09000otitl0w7zd0znm	cmlaktzc000oaitl08z4c5b83	cml7r4x0a007sitl0t1judo7d	AUTO	2026-02-06 07:41:33.261
cmlaku09900paitl0l9jqez2t	cmlaku09000otitl0w7zd0znm	cmlaktzc000obitl0lppckk0c	cml7r4x0a007sitl0t1judo7d	AUTO	2026-02-06 07:41:33.261
cmlaku09900pbitl0hnwdg106	cmlaku09000otitl0w7zd0znm	cmlaktzc000ocitl080kia957	cml7r4x0a007sitl0t1judo7d	AUTO	2026-02-06 07:41:33.261
cmlaku09900pcitl0z3dbbdbm	cmlaku09000otitl0w7zd0znm	cmlaktzc000oditl0az6sq303	cml7r4x0a007sitl0t1judo7d	AUTO	2026-02-06 07:41:33.261
cmlaku09900pditl0b5lkio7o	cmlaku09000otitl0w7zd0znm	cmlaktzc000oeitl0qsshgjsr	cmlajsv86009citl0zdv2yfmo	AUTO	2026-02-06 07:41:33.261
cmlaku09900peitl0vssy7zm3	cmlaku09000otitl0w7zd0znm	cmlaktzc000ofitl05y89yoig	cmlajs7py0092itl0jrdovags	AUTO	2026-02-06 07:41:33.261
cmlak80sy00fritl0t3832kea	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k005qitl0bq79eh80	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:24:27.539
cmlak80sy00fsitl0uokzbts1	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k005ritl0rr6pm63b	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:24:27.539
cmlak80sy00ftitl0ztmmc0yx	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k005sitl0geawexie	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:24:27.539
cmlak80sy00fuitl0unz3ojnc	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k005titl0z0n6jk4z	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:24:27.539
cmlak80sy00fvitl0rg504oxm	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k005uitl0j15w8m7d	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:24:27.539
cmlak80sy00fwitl085z0hpsm	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k005vitl0z2r7dcoi	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:24:27.539
cmlak80sy00fxitl0rsujrrk4	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k005witl0j1qsszbr	cmlajqxb9008nitl0vy9fe2ob	AUTO	2026-02-06 07:24:27.539
cmlak80sy00fyitl02zjjn2uq	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k005xitl08fzf9bzr	cmlajqxb9008nitl0vy9fe2ob	AUTO	2026-02-06 07:24:27.539
cmlak80sy00fzitl01yj82nt8	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k005yitl0k7dfmuir	cmlajsige0097itl0gjo69mf7	AUTO	2026-02-06 07:24:27.539
cmlak80sy00g0itl021d7tzkc	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k005zitl0sm7o02od	cmlajtpbl009ritl06ykc1ihg	AUTO	2026-02-06 07:24:27.539
cmlak80sy00g1itl0ikc4qnuf	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k0060itl0i57tl8v9	cmlajqxb9008nitl0vy9fe2ob	AUTO	2026-02-06 07:24:27.539
cmlak80sy00g2itl0j2qx6at5	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k0061itl0oaggms8y	cmlajqxb9008nitl0vy9fe2ob	AUTO	2026-02-06 07:24:27.539
cmlak80sy00g3itl047k3rnfr	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k005oitl0do7bk9y0	cml7r4x0a007sitl0t1judo7d	AUTO	2026-02-06 07:24:27.539
cmlak80sy00g4itl081mmmldk	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k005pitl067cq0ygt	cmlajtb0g009mitl0j271zrn2	AUTO	2026-02-06 07:24:27.539
cmlak80sy00g5itl0dk5e9aiu	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k0062itl05ojupph1	cml7r4x0a007sitl0t1judo7d	AUTO	2026-02-06 07:24:27.539
cmlak80sy00g6itl0r1su5yfg	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k0063itl0ihil390t	cml7r4x0a007sitl0t1judo7d	AUTO	2026-02-06 07:24:27.539
cmlak80sy00g7itl0y691myap	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k0064itl0fnhmm4bc	cml7r4x0a007sitl0t1judo7d	AUTO	2026-02-06 07:24:27.539
cmlak80sy00g8itl0zrz5jea7	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k0065itl0jcz5zc6y	cml7r4x0a007sitl0t1judo7d	AUTO	2026-02-06 07:24:27.539
cmlak80sy00g9itl0uyb90ygs	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k0066itl047h4r42e	cml7r4x0a007sitl0t1judo7d	AUTO	2026-02-06 07:24:27.539
cmlak80sy00gaitl0aj61qo9t	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k0067itl0t4at04nr	cmlajtb0g009mitl0j271zrn2	AUTO	2026-02-06 07:24:27.539
cmlak80sy00gbitl06n8wplbu	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k0068itl0xa7iz8ea	cmlajqn7r008iitl0mjd6k2hp	AUTO	2026-02-06 07:24:27.539
cmlak80sy00gcitl0axki8afq	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k0069itl0vymbie0b	cmlajqn7r008iitl0mjd6k2hp	AUTO	2026-02-06 07:24:27.539
cmlak80sy00gditl05ofdiw79	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k006aitl090fh6my4	cmlajtb0g009mitl0j271zrn2	AUTO	2026-02-06 07:24:27.539
cmlak80sy00geitl0zofzakxo	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k006bitl0rao7edyi	cmlajrzeu008xitl0e7b8xyuq	AUTO	2026-02-06 07:24:27.539
cmlak80sy00gfitl05xpyufv6	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k006citl0l8zg7emc	cmlajsv86009citl0zdv2yfmo	AUTO	2026-02-06 07:24:27.539
cmlak80sy00ggitl0tbk0zrl9	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k006ditl0yxxrzjj9	cmlajqn7r008iitl0mjd6k2hp	AUTO	2026-02-06 07:24:27.539
cmlak80sy00ghitl0utj6djt1	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k006eitl08ehstqsm	cmlajqn7r008iitl0mjd6k2hp	AUTO	2026-02-06 07:24:27.539
cmlak80sy00giitl0sy9gh2xx	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k006fitl0bzx9yh15	cmlajtb0g009mitl0j271zrn2	AUTO	2026-02-06 07:24:27.539
cmlak80sy00gjitl08bafbil8	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k006gitl0qcrjgcrx	cmlajsv86009citl0zdv2yfmo	AUTO	2026-02-06 07:24:27.539
cmlak80sy00gkitl0hhvwumfu	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k006hitl0gizxblsm	cmlajsv86009citl0zdv2yfmo	AUTO	2026-02-06 07:24:27.539
cmlak80sy00glitl07ewndlwy	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k006iitl0s0st5yed	cmlajrzeu008xitl0e7b8xyuq	AUTO	2026-02-06 07:24:27.539
cmlak80sy00gmitl0d0kac8zy	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k006jitl0anl17nlg	cmlajrzeu008xitl0e7b8xyuq	AUTO	2026-02-06 07:24:27.539
cmlak80sy00gnitl0k2xld71a	cmlaj4hbd0089itl04wq9ic2f	cml7qlb4k006kitl08qrnel43	cmlajrzeu008xitl0e7b8xyuq	AUTO	2026-02-06 07:24:27.539
cmlaku09900pfitl0jaxtotx7	cmlaku09000otitl0w7zd0znm	cmlaktzc000ogitl04otwcd3m	cmlajtb0g009mitl0j271zrn2	AUTO	2026-02-06 07:41:33.261
cmlaku09900pgitl09u4hsg2m	cmlaku09000otitl0w7zd0znm	cmlaktzc000ohitl0vb1cpigv	cmlajtb0g009mitl0j271zrn2	AUTO	2026-02-06 07:41:33.261
cmlaku09900phitl07mvcq05a	cmlaku09000otitl0w7zd0znm	cmlaktzc000oiitl0i496guw0	cmlajqn7r008iitl0mjd6k2hp	AUTO	2026-02-06 07:41:33.261
cmlaku09900piitl0ejid7nn2	cmlaku09000otitl0w7zd0znm	cmlaktzc000ojitl0d7slf8y3	cmlajrzeu008xitl0e7b8xyuq	AUTO	2026-02-06 07:41:33.261
cmlaku09900pjitl0qyu1jpv6	cmlaku09000otitl0w7zd0znm	cmlaktzc000okitl0svvsl15e	cmlajsv86009citl0zdv2yfmo	AUTO	2026-02-06 07:41:33.261
cmlaku09900pkitl06ro8tfv7	cmlaku09000otitl0w7zd0znm	cmlaktzc000olitl0p57dpy93	cmlajrzeu008xitl0e7b8xyuq	AUTO	2026-02-06 07:41:33.261
cmlaku09900plitl0rhjm3s1q	cmlaku09000otitl0w7zd0znm	cmlaktzc000omitl04rkqw2f4	cmlajs7py0092itl0jrdovags	AUTO	2026-02-06 07:41:33.261
cmlaku09900pmitl03mtez0z0	cmlaku09000otitl0w7zd0znm	cmlaktzc000onitl0qt48gwwm	cmlajtb0g009mitl0j271zrn2	AUTO	2026-02-06 07:41:33.261
cmlaku09900pnitl0e95tuksc	cmlaku09000otitl0w7zd0znm	cmlaktzc000ooitl0up17kya2	cmlajqn7r008iitl0mjd6k2hp	AUTO	2026-02-06 07:41:33.261
cmlaku09900poitl0n1uklnb6	cmlaku09000otitl0w7zd0znm	cmlaktzc000opitl0lg0czbj7	cmlajs7py0092itl0jrdovags	AUTO	2026-02-06 07:41:33.261
cmlaku09900ppitl0k34p0pph	cmlaku09000otitl0w7zd0znm	cmlaktzc000oqitl0zvj5leso	cmlajtb0g009mitl0j271zrn2	AUTO	2026-02-06 07:41:33.261
cmlaku09900pqitl0kx0oqoj6	cmlaku09000otitl0w7zd0znm	cmlaktzc000oritl08n2w3st6	cmlajqn7r008iitl0mjd6k2hp	AUTO	2026-02-06 07:41:33.261
cmlalb82j002xitowilk6vzwg	cmlakki6o00jlitl0146db1nz	cmlakdn1i00ilitl0ctl015rh	cml7q301e000fitl0xaqs8kp9	MANUAL	2026-02-06 07:54:56.539
cmlalb5yu0020itow6bfhcv6w	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5g00hqitl0dwbx8tta	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:54:53.814
cmlalb5yu0021itowiz40514p	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5f00guitl0k9clxw46	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:54:53.814
cmlalb5yu0022itowlrnxs497	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5g00hsitl0vz10lmti	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:54:53.814
cmlalb5yu0023itowd6nxevuf	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5f00gxitl0ggdh03fi	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:54:53.814
cmlalb5yu0024itowqojwrxr6	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5f00h1itl0ewm4r4ck	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:54:53.814
cmlalb5yu0025itowigx4x7lf	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5g00htitl0m9i36yzf	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:54:53.814
cmlalb5yu0026itowwhgnxdo4	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5g00hvitl08nb11pgb	cmlajqxb9008nitl0vy9fe2ob	AUTO	2026-02-06 07:54:53.814
cmlalb5yu0027itoweikfhaw5	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5g00hwitl02oka8cex	cmlajt3lw009hitl0avtd37yg	AUTO	2026-02-06 07:54:53.814
cmlalb5yu0028itowbpy5e7nj	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5g00hxitl0lban9l2q	cmlajsige0097itl0gjo69mf7	AUTO	2026-02-06 07:54:53.814
cmlalb5yu0029itownsxfkvfy	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5g00hzitl0e0qgxyaj	cmlajt3lw009hitl0avtd37yg	AUTO	2026-02-06 07:54:53.814
cmlalb5yu002aitowl0y7g1cb	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5g00i0itl0sf0snubg	cmlajqxb9008nitl0vy9fe2ob	AUTO	2026-02-06 07:54:53.814
cmlalb5yu002bitow6bjrnzc7	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5g00i1itl02t6tl9f9	cmlajt3lw009hitl0avtd37yg	AUTO	2026-02-06 07:54:53.814
cmlalb5yu002citowyfs06ohz	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5g00hoitl0po6yh0d2	cml7r4x0a007sitl0t1judo7d	AUTO	2026-02-06 07:54:53.814
cmlalb5yu002ditow0sdf87gk	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5f00gsitl0rsw9xmb2	cmlajqn7r008iitl0mjd6k2hp	AUTO	2026-02-06 07:54:53.814
cmlalb5yu002eitowt51vlaoj	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5f00h5itl040g4bboi	cml7r4x0a007sitl0t1judo7d	AUTO	2026-02-06 07:54:53.814
cmlalb5yu002fitowxakioe0v	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5f00h8itl0pv7sp9js	cml7r4x0a007sitl0t1judo7d	AUTO	2026-02-06 07:54:53.814
cmlalb5yu002gitowq49i6dxh	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5f00haitl0o1xv9tjo	cml7r4x0a007sitl0t1judo7d	AUTO	2026-02-06 07:54:53.814
cmlalb5yu002hitowhnolxckq	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5f00hcitl00ookx8sm	cmlajsv86009citl0zdv2yfmo	AUTO	2026-02-06 07:54:53.814
cmlalb5yu002iitowoa1lz70l	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5f00heitl0qtoawv33	cmlajs7py0092itl0jrdovags	AUTO	2026-02-06 07:54:53.814
cmlalb5yu002jitow13cy7rcz	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5f00hfitl0hfs4hb30	cmlajrzeu008xitl0e7b8xyuq	AUTO	2026-02-06 07:54:53.814
cmlalb5yu002kitowccofbjc9	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5f00hiitl0vvt1gil6	cml7r4x0a007sitl0t1judo7d	AUTO	2026-02-06 07:54:53.814
cmlalb5yu002litow7wrey9pk	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5f00hjitl0wk5u6cl9	cmlajsv86009citl0zdv2yfmo	AUTO	2026-02-06 07:54:53.814
cmlalb5yu002mitowri3cah4t	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5f00hlitl0x7ro88wq	cmlajtb0g009mitl0j271zrn2	AUTO	2026-02-06 07:54:53.814
cmlalb5yu002nitowvmdxx0m9	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5g00i3itl0tlqwn4la	cmlajsv86009citl0zdv2yfmo	AUTO	2026-02-06 07:54:53.814
cmlalb5yu002oitowvdclznnj	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5g00i4itl0p5oyum99	cmlajs7py0092itl0jrdovags	AUTO	2026-02-06 07:54:53.814
cmlalb5yu002pitowlknpaa5q	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5g00i6itl03vpralk6	cmlajqn7r008iitl0mjd6k2hp	AUTO	2026-02-06 07:54:53.814
cmlalb5yu002qitowse3va41h	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5g00i8itl0r6gd3nao	cmlajsv86009citl0zdv2yfmo	AUTO	2026-02-06 07:54:53.814
cmlalb5yu002ritowa4lx8kpa	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5g00iaitl0r16gqinw	cmlajtb0g009mitl0j271zrn2	AUTO	2026-02-06 07:54:53.814
cmlalb5yu002sitowy4fodjqd	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5g00iditl00vsriq6z	cmlajtb0g009mitl0j271zrn2	AUTO	2026-02-06 07:54:53.814
cmlalb5yu002titowvh1kbn1h	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5g00ieitl0dehcdm1e	cmlajs7py0092itl0jrdovags	AUTO	2026-02-06 07:54:53.814
cmlalb5yu002uitowmzxchllo	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5g00ihitl00xzml57w	cmlajs7py0092itl0jrdovags	AUTO	2026-02-06 07:54:53.814
cmlalb5yu002vitow0nka84hr	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5g00ijitl01slncp6d	cmlajqn7r008iitl0mjd6k2hp	AUTO	2026-02-06 07:54:53.814
cmlalb5yu002witowk71exv87	cmlake2qp00jjitl0uxgf3bzp	cmlakcg5g00ikitl0kqpmep0u	cmlajtb0g009mitl0j271zrn2	AUTO	2026-02-06 07:54:53.814
cmlalb82j002yitowls3sd3nb	cmlakki6o00jlitl0146db1nz	cmlakdn1i00imitl0kkxqioh0	cml7r4x0a007sitl0t1judo7d	AUTO	2026-02-06 07:54:56.539
cmlalb82j002zitowgsilxdu3	cmlakki6o00jlitl0146db1nz	cmlakdn1i00initl04dny6egm	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:54:56.539
cmlalb82j0030itowf7koknh1	cmlakki6o00jlitl0146db1nz	cmlakdn1i00ioitl0w17wmn6l	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:54:56.539
cmlalb82j0031itowdkbpa1fh	cmlakki6o00jlitl0146db1nz	cmlakdn1i00ipitl0znpy0p7f	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:54:56.539
cmlalb82j0032itow25o777fb	cmlakki6o00jlitl0146db1nz	cmlakdn1i00iqitl05m56afxm	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:54:56.539
cmlalb82j0033itow22q6n6gm	cmlakki6o00jlitl0146db1nz	cmlakdn1i00iritl02h66gv78	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:54:56.539
cmlalb82j0034itowux5eujrx	cmlakki6o00jlitl0146db1nz	cmlakdn1i00isitl0zxfaylga	cmlajt3lw009hitl0avtd37yg	AUTO	2026-02-06 07:54:56.539
cmlalb82j0035itowrhnqeq1u	cmlakki6o00jlitl0146db1nz	cmlakdn1i00ititl0v8cl9xtr	cmlajqxb9008nitl0vy9fe2ob	AUTO	2026-02-06 07:54:56.539
cmlalb82j0036itowg1qbwas6	cmlakki6o00jlitl0146db1nz	cmlakdn1i00iuitl0uraxsocn	cmlajsige0097itl0gjo69mf7	AUTO	2026-02-06 07:54:56.539
cmlalb82j0037itownrlcdsvx	cmlakki6o00jlitl0146db1nz	cmlakdn1i00ivitl0embbtois	cmlajsige0097itl0gjo69mf7	AUTO	2026-02-06 07:54:56.539
cmlalb82j0038itow580xk1hy	cmlakki6o00jlitl0146db1nz	cmlakdn1i00iwitl082e4kwwk	cmlajtpbl009ritl06ykc1ihg	AUTO	2026-02-06 07:54:56.539
cmlalb82j0039itowlqhqgr2a	cmlakki6o00jlitl0146db1nz	cmlakdn1i00ixitl0wxjdft91	cmlajqxb9008nitl0vy9fe2ob	AUTO	2026-02-06 07:54:56.539
cmlalb82j003aitowdnllsngq	cmlakki6o00jlitl0146db1nz	cmlakdn1i00iyitl00j9qiu92	cmlajr9h7008sitl0mlb5x9f3	AUTO	2026-02-06 07:54:56.539
cmlalb82j003bitowweywjo7c	cmlakki6o00jlitl0146db1nz	cmlakdn1i00izitl034bxb0ac	cml7q301e000fitl0xaqs8kp9	AUTO	2026-02-06 07:54:56.539
cmlalb82j003citowrulrvuq3	cmlakki6o00jlitl0146db1nz	cmlakdn1i00j0itl0yevd04dr	cml7r4x0a007sitl0t1judo7d	AUTO	2026-02-06 07:54:56.539
cmlalb82j003ditow9vdwr9j9	cmlakki6o00jlitl0146db1nz	cmlakdn1i00j1itl0psmqwpim	cml7r4x0a007sitl0t1judo7d	AUTO	2026-02-06 07:54:56.539
cmlalb82j003eitowt8gsh3yq	cmlakki6o00jlitl0146db1nz	cmlakdn1i00j2itl0oxdz3uvb	cml7r4x0a007sitl0t1judo7d	AUTO	2026-02-06 07:54:56.539
cmlalb82j003fitow43njd1we	cmlakki6o00jlitl0146db1nz	cmlakdn1i00j6itl0jr8cnws0	cml7r4x0a007sitl0t1judo7d	AUTO	2026-02-06 07:54:56.539
cmlalb82j003gitowey23d6gf	cmlakki6o00jlitl0146db1nz	cmlakdn1i00j7itl0qacxnkgt	cmlajtb0g009mitl0j271zrn2	AUTO	2026-02-06 07:54:56.539
cmlalb82j003hitowofymfjh0	cmlakki6o00jlitl0146db1nz	cmlakdn1i00j8itl0bq8ot5ay	cmlajs7py0092itl0jrdovags	AUTO	2026-02-06 07:54:56.539
cmlalb82j003iitowf8g6dw1a	cmlakki6o00jlitl0146db1nz	cmlakdn1i00j9itl074xs6use	cmlajrzeu008xitl0e7b8xyuq	AUTO	2026-02-06 07:54:56.539
cmlalb82j003jitow9zj61gzm	cmlakki6o00jlitl0146db1nz	cmlakdn1i00jaitl0v2l43tta	cmlajtb0g009mitl0j271zrn2	AUTO	2026-02-06 07:54:56.539
cmlalb82j003kitows8htlccf	cmlakki6o00jlitl0146db1nz	cmlakdn1i00jbitl09x2anl6n	cmlajtb0g009mitl0j271zrn2	AUTO	2026-02-06 07:54:56.539
cmlalb82j003litowl69flh02	cmlakki6o00jlitl0146db1nz	cmlakdn1i00jcitl01pyye3ez	cmlajrzeu008xitl0e7b8xyuq	AUTO	2026-02-06 07:54:56.539
cmlalb82j003mitownzii9ide	cmlakki6o00jlitl0146db1nz	cmlakdn1i00jditl0d4aofhns	cmlajrzeu008xitl0e7b8xyuq	AUTO	2026-02-06 07:54:56.539
cmlalb82j003nitowq1oidyos	cmlakki6o00jlitl0146db1nz	cmlakdn1i00jeitl0v3afezob	cmlajrzeu008xitl0e7b8xyuq	AUTO	2026-02-06 07:54:56.539
cmlalb82j003oitowuy12ore9	cmlakki6o00jlitl0146db1nz	cmlakdn1i00jfitl0jazx8arj	cmlajsv86009citl0zdv2yfmo	AUTO	2026-02-06 07:54:56.539
cmlalb82j003pitowq9ohdpmq	cmlakki6o00jlitl0146db1nz	cmlakdn1i00jgitl0b1ncf9q0	cmlajs7py0092itl0jrdovags	AUTO	2026-02-06 07:54:56.539
cmlalb82j003qitow1ktakdu7	cmlakki6o00jlitl0146db1nz	cmlakdn1i00jhitl0re2phbww	cmlajtb0g009mitl0j271zrn2	AUTO	2026-02-06 07:54:56.539
cmlalb82j003ritown6qlqch2	cmlakki6o00jlitl0146db1nz	cmlakdn1i00j3itl0l1z0mefv	cmlajqn7r008iitl0mjd6k2hp	AUTO	2026-02-06 07:54:56.539
cmlalb82j003sitowbhaz69h8	cmlakki6o00jlitl0146db1nz	cmlakdn1i00j4itl01xm58ld6	cmlajqn7r008iitl0mjd6k2hp	AUTO	2026-02-06 07:54:56.539
cmlalb82j003titoww0xaa1gi	cmlakki6o00jlitl0146db1nz	cmlakdn1i00j5itl09fhrr9ef	cmlajsv86009citl0zdv2yfmo	AUTO	2026-02-06 07:54:56.539
\.


--
-- Data for Name: AvailabilityTemplate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."AvailabilityTemplate" (id, "userId", "roleTypeId", "dayOfWeek", "startTime", "endTime", hours, choice, "createdAt", "updatedAt") FROM stdin;
cmlc1lr8s000ritvnbxrmhimr	cml7q301e000fitl0xaqs8kp9	cml7pyfy90004itl0agfmc575	0	17:00	21:30	4.5	CAN	2026-02-07 08:18:47.981	2026-02-07 08:18:47.981
cmlc1lsy1000titvndvr19sue	cml7q301e000fitl0xaqs8kp9	cml7pyfy90004itl0agfmc575	1	10:30	14:15	3.75	CAN	2026-02-07 08:18:50.186	2026-02-07 08:18:50.186
cmlc1hbxe0007itvnl2yq4jso	cml7q301e000fitl0xaqs8kp9	cml7pyfy90004itl0agfmc575	0	15:30	21:30	6	CAN	2026-02-07 08:15:21.507	2026-02-07 08:20:41.02
cmlc1h5wu0001itvnfbnmnu33	cml7q301e000fitl0xaqs8kp9	cml7pyfy90004itl0agfmc575	0	10:30	14:15	3.75	CAN	2026-02-07 08:15:13.71	2026-02-07 08:21:45.637
cmlc1haim0005itvnkho696uz	cml7q301e000fitl0xaqs8kp9	cml7pyfy90003itl0wzs82ss5	0	10:45	14:00	3.25	CAN	2026-02-07 08:15:19.679	2026-02-07 08:21:55.68
cmlc1hcaj0009itvn6eg7rf4r	cml7q301e000fitl0xaqs8kp9	cml7pyfy90003itl0wzs82ss5	0	16:00	21:00	5	CAN	2026-02-07 08:15:21.98	2026-02-07 08:21:57.919
\.


--
-- Data for Name: Preference; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Preference" (id, "userId", "shiftSlotId", choice, "updatedAt", "createdAt") FROM stdin;
cml7r9rw2007zitl0mixmglm2	cml7r4x0a007sitl0t1judo7d	cml7qlb4k005oitl0do7bk9y0	WANT	2026-02-04 08:18:40.187	2026-02-04 08:18:28.082
cmlajwi8h00avitl0olukix29	cmlajqn7r008iitl0mjd6k2hp	cml7qlb650074itl07s50m8lb	WANT	2026-02-06 07:15:30.258	2026-02-06 07:15:30.258
cmlajwjgh00axitl0i66lw4ps	cmlajqn7r008iitl0mjd6k2hp	cml7qlb650076itl0l8y27ma9	CANT	2026-02-06 07:15:31.841	2026-02-06 07:15:31.841
cmlajwk4100azitl0wr8cvsyt	cmlajqn7r008iitl0mjd6k2hp	cml7qlb650078itl0ronfuvi7	CANT	2026-02-06 07:15:32.689	2026-02-06 07:15:32.689
cmlajwl1e00b1itl0k02h39b1	cmlajqn7r008iitl0mjd6k2hp	cml7qlb650077itl0ieoi1yfl	CANT	2026-02-06 07:15:33.891	2026-02-06 07:15:33.891
cmlajwlea00b3itl0a31tawoj	cmlajqn7r008iitl0mjd6k2hp	cml7qlb650075itl0bten8l19	CANT	2026-02-06 07:15:34.354	2026-02-06 07:15:34.354
cmlajwm0q00b5itl05q16zbe6	cmlajqn7r008iitl0mjd6k2hp	cml7qlb650073itl0useqlm8p	WANT	2026-02-06 07:15:35.162	2026-02-06 07:15:35.162
cmlajwn3600b7itl0v9v04q5d	cmlajqn7r008iitl0mjd6k2hp	cml7qlb65007ditl0orme5njy	CANT	2026-02-06 07:15:36.546	2026-02-06 07:15:36.546
cmlajwnff00b9itl0jq91oh0v	cmlajqn7r008iitl0mjd6k2hp	cml7qlb65007hitl0kykpg197	CANT	2026-02-06 07:15:36.988	2026-02-06 07:15:36.988
cmlajwof500bbitl0hilxau65	cmlajqn7r008iitl0mjd6k2hp	cml7qlb650072itl0q1n6w2hi	CANT	2026-02-06 07:15:38.274	2026-02-06 07:15:38.274
cmlajwpg200bditl0o1c2de4f	cmlajqn7r008iitl0mjd6k2hp	cml7qlb65007citl02jh2e9sq	CANT	2026-02-06 07:15:39.603	2026-02-06 07:15:39.603
cmlajwpp800bfitl0bvaylbk9	cmlajqn7r008iitl0mjd6k2hp	cml7qlb65007gitl048tv4iqy	CANT	2026-02-06 07:15:39.933	2026-02-06 07:15:39.933
cmlajwq6c00bhitl0fss051o7	cmlajqn7r008iitl0mjd6k2hp	cml7qlb650071itl03zm5xmb2	CANT	2026-02-06 07:15:40.548	2026-02-06 07:15:40.548
cmlajwrq700bjitl0yb12qda4	cmlajqn7r008iitl0mjd6k2hp	cml7qlb65007bitl0q5xaq2gp	CANT	2026-02-06 07:15:42.56	2026-02-06 07:15:42.56
cmlajwrzt00blitl0z06xpbnq	cmlajqn7r008iitl0mjd6k2hp	cml7qlb65007fitl08x4213kh	CANT	2026-02-06 07:15:42.905	2026-02-06 07:15:42.905
cmlajwsif00bnitl0ty7e9a73	cmlajqn7r008iitl0mjd6k2hp	cml7qlb650070itl070dky0ch	CANT	2026-02-06 07:15:43.575	2026-02-06 07:15:43.575
cmlajwuei00bpitl0hq8abyag	cmlajqn7r008iitl0mjd6k2hp	cml7qlb65007aitl0sd10imf7	CANT	2026-02-06 07:15:46.026	2026-02-06 07:15:46.026
cmlajwuqc00britl0ubud2h89	cmlajqn7r008iitl0mjd6k2hp	cml7qlb65007eitl0z0vfus7v	CANT	2026-02-06 07:15:46.452	2026-02-06 07:15:46.452
cmlajwv6v00btitl0tvj0afho	cmlajqn7r008iitl0mjd6k2hp	cml7qlb65006zitl081zml599	CANT	2026-02-06 07:15:47.047	2026-02-06 07:15:47.047
cmlajwwoa00bvitl0fvtcmulw	cmlajqn7r008iitl0mjd6k2hp	cml7qlb650079itl0i3gsfz7f	CANT	2026-02-06 07:15:48.97	2026-02-06 07:15:48.97
cmlajwwtd00bxitl070l6h6ho	cmlajqn7r008iitl0mjd6k2hp	cml7qlb65006mitl0w7sr00iq	CANT	2026-02-06 07:15:49.153	2026-02-06 07:15:49.153
cmlajwxfv00bzitl0cx6q4u51	cmlajqn7r008iitl0mjd6k2hp	cml7qlb65006litl0w0u4e5wp	CANT	2026-02-06 07:15:49.964	2026-02-06 07:15:49.964
cmlakqzkv00lnitl0rwieznpr	cmlajqn7r008iitl0mjd6k2hp	cmlakdn1i00j8itl0bq8ot5ay	CANT	2026-02-06 07:39:12.415	2026-02-06 07:39:12.415
cmlakqzwn00lpitl0l5khtvf7	cmlajqn7r008iitl0mjd6k2hp	cmlakdn1i00j6itl0jr8cnws0	CANT	2026-02-06 07:39:12.839	2026-02-06 07:39:12.839
cmlakr0dz00lritl0yg1xr4w2	cmlajqn7r008iitl0mjd6k2hp	cmlakdn1i00j4itl01xm58ld6	WANT	2026-02-06 07:39:13.463	2026-02-06 07:39:13.463
cmlakr1e000ltitl06n2pmej2	cmlajqn7r008iitl0mjd6k2hp	cmlakdn1i00j7itl0qacxnkgt	CANT	2026-02-06 07:39:14.76	2026-02-06 07:39:14.76
cmlakr1rg00lvitl03yapgjn6	cmlajqn7r008iitl0mjd6k2hp	cmlakdn1i00j5itl09fhrr9ef	CAN	2026-02-06 07:39:15.986	2026-02-06 07:39:15.244
cmlakr2oh00lzitl03fmk746m	cmlajqn7r008iitl0mjd6k2hp	cmlakdn1i00j3itl0l1z0mefv	WANT	2026-02-06 07:39:16.433	2026-02-06 07:39:16.433
cmlakr87u00m1itl0zdmr221a	cmlajqn7r008iitl0mjd6k2hp	cmlakdn1i00j2itl0oxdz3uvb	CANT	2026-02-06 07:39:23.611	2026-02-06 07:39:23.611
cmlakr8fp00m3itl0o3sksmmp	cmlajqn7r008iitl0mjd6k2hp	cmlakdn1i00jhitl0re2phbww	CANT	2026-02-06 07:39:23.894	2026-02-06 07:39:23.894
cmlakr8s700m5itl0xcx8u3za	cmlajqn7r008iitl0mjd6k2hp	cmlakdn1i00jditl0d4aofhns	CANT	2026-02-06 07:39:24.343	2026-02-06 07:39:24.343
cmlakrcik00m7itl05fwksdn7	cmlajqn7r008iitl0mjd6k2hp	cmlakdn1i00j1itl0psmqwpim	CANT	2026-02-06 07:39:29.181	2026-02-06 07:39:29.181
cmlakrct100m9itl0qmdyyu4u	cmlajqn7r008iitl0mjd6k2hp	cmlakdn1i00jgitl0b1ncf9q0	CANT	2026-02-06 07:39:29.557	2026-02-06 07:39:29.557
cmlakrd3800mbitl0mu3huyef	cmlajqn7r008iitl0mjd6k2hp	cmlakdn1i00jcitl01pyye3ez	CANT	2026-02-06 07:39:29.925	2026-02-06 07:39:29.925
cmlakrhs900mditl0pohltg0u	cmlajqn7r008iitl0mjd6k2hp	cmlakdn1i00j0itl0yevd04dr	CANT	2026-02-06 07:39:36.009	2026-02-06 07:39:36.009
cmlakri3300mfitl06i3od9pq	cmlajqn7r008iitl0mjd6k2hp	cmlakdn1i00jfitl0jazx8arj	CANT	2026-02-06 07:39:36.4	2026-02-06 07:39:36.4
cmlakrihq00mhitl0ehpvrvqw	cmlajqn7r008iitl0mjd6k2hp	cmlakdn1i00jbitl09x2anl6n	CANT	2026-02-06 07:39:36.927	2026-02-06 07:39:36.927
cmlakro9q00mjitl01tgrf4xx	cmlajqn7r008iitl0mjd6k2hp	cmlakdn1i00jaitl0v2l43tta	CANT	2026-02-06 07:39:44.414	2026-02-06 07:39:44.414
cmlakrohc00mlitl07s5wzdtd	cmlajqn7r008iitl0mjd6k2hp	cmlakdn1i00jeitl0v3afezob	CANT	2026-02-06 07:39:44.688	2026-02-06 07:39:44.688
cmlakroya00mnitl0ew8bj2s6	cmlajqn7r008iitl0mjd6k2hp	cmlakdn1i00izitl034bxb0ac	CANT	2026-02-06 07:39:45.298	2026-02-06 07:39:45.298
cmlakrtyj00mritl01c01ofi6	cmlajqn7r008iitl0mjd6k2hp	cmlakdn1i00imitl0kkxqioh0	CANT	2026-02-06 07:39:51.787	2026-02-06 07:39:51.787
cmlakruho00mtitl0s9csi955	cmlajqn7r008iitl0mjd6k2hp	cmlakdn1i00j9itl074xs6use	CANT	2026-02-06 07:39:52.477	2026-02-06 07:39:52.477
cmlakrtok00mpitl0i1hfow4l	cmlajqn7r008iitl0mjd6k2hp	cmlakdn1i00ilitl0ctl015rh	CANT	2026-02-06 07:54:39.281	2026-02-06 07:39:51.428
\.


--
-- Data for Name: RoleType; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."RoleType" (id, name, "createdAt", "updatedAt") FROM stdin;
cml7pyfy90003itl0wzs82ss5	Server	2026-02-04 07:41:39.778	2026-02-04 07:41:39.778
cml7pyfy90004itl0agfmc575	Kitchen	2026-02-04 07:41:39.778	2026-02-04 07:41:39.778
cml7q11vz0007itl0ibvejpf9	Manager	2026-02-04 07:43:41.52	2026-02-04 07:43:41.52
\.


--
-- Data for Name: Schedule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Schedule" (id, "weekId", status, version, "generatedAt", "finalizedAt") FROM stdin;
cmlaj4hbd0089itl04wq9ic2f	cml7q52fz000oitl0z7m4udo7	DRAFT	7	2026-02-06 07:24:27.543	\N
cmlaku09000otitl0w7zd0znm	cmlakcg4e00gqitl0u47y2mhf	DRAFT	1	2026-02-06 07:41:33.265	\N
cmlake2qp00jjitl0uxgf3bzp	cmlakcg4e00goitl0tzv15frx	DRAFT	8	2026-02-06 07:54:53.818	\N
cmlakki6o00jlitl0146db1nz	cmlakcg4e00gpitl01ndt8ihq	FINALIZED	5	2026-02-06 07:54:56.546	2026-02-07 08:46:48.511
\.


--
-- Data for Name: Session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Session" (id, "userId", "expiresAt", "createdAt") FROM stdin;
cml7r3yh1007nitl07ocnt9za	cml7ptotx0000itl036r0orfn	2026-03-06 08:13:56.676	2026-02-04 08:13:56.677
cmlalc6zm003xitowbi6v5hel	cml7q301e000fitl0xaqs8kp9	2026-03-08 07:55:41.792	2026-02-06 07:55:41.794
cmlc282qk002uitvn3r5np81x	cml7ptotx0000itl036r0orfn	2026-03-09 08:36:09.308	2026-02-07 08:36:09.309
\.


--
-- Data for Name: ShiftSlot; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ShiftSlot" (id, "weekId", "roleTypeId", date, "startAt", "endAt", hours, "createdAt") FROM stdin;
cml7qlb4k005oitl0do7bk9y0	cml7q52fz000oitl0z7m4udo7	cml7pyfy90004itl0agfmc575	2026-02-02 08:00:00	2026-02-02 18:30:00	2026-02-02 22:15:00	3.75	2026-02-04 07:59:26.612
cml7qlb4k005pitl067cq0ygt	cml7q52fz000oitl0z7m4udo7	cml7pyfy90004itl0agfmc575	2026-02-02 08:00:00	2026-02-02 23:30:00	2026-02-03 05:30:00	6	2026-02-04 07:59:26.612
cml7qlb4k005qitl0bq79eh80	cml7q52fz000oitl0z7m4udo7	cml7pyfy90003itl0wzs82ss5	2026-02-02 08:00:00	2026-02-02 18:45:00	2026-02-02 22:00:00	3.25	2026-02-04 07:59:26.612
cml7qlb4k005ritl0rr6pm63b	cml7q52fz000oitl0z7m4udo7	cml7pyfy90003itl0wzs82ss5	2026-02-03 08:00:00	2026-02-03 18:45:00	2026-02-03 22:00:00	3.25	2026-02-04 07:59:26.612
cml7qlb4k005sitl0geawexie	cml7q52fz000oitl0z7m4udo7	cml7pyfy90003itl0wzs82ss5	2026-02-04 08:00:00	2026-02-04 18:45:00	2026-02-04 22:00:00	3.25	2026-02-04 07:59:26.612
cml7qlb4k005titl0z0n6jk4z	cml7q52fz000oitl0z7m4udo7	cml7pyfy90003itl0wzs82ss5	2026-02-05 08:00:00	2026-02-05 18:45:00	2026-02-05 22:00:00	3.25	2026-02-04 07:59:26.612
cml7qlb4k005uitl0j15w8m7d	cml7q52fz000oitl0z7m4udo7	cml7pyfy90003itl0wzs82ss5	2026-02-06 08:00:00	2026-02-06 18:45:00	2026-02-06 22:00:00	3.25	2026-02-04 07:59:26.612
cml7qlb4k005vitl0z2r7dcoi	cml7q52fz000oitl0z7m4udo7	cml7pyfy90003itl0wzs82ss5	2026-02-02 08:00:00	2026-02-03 00:00:00	2026-02-03 05:00:00	5	2026-02-04 07:59:26.612
cml7qlb4k005witl0j1qsszbr	cml7q52fz000oitl0z7m4udo7	cml7pyfy90003itl0wzs82ss5	2026-02-03 08:00:00	2026-02-04 00:00:00	2026-02-04 05:00:00	5	2026-02-04 07:59:26.612
cml7qlb4k005xitl08fzf9bzr	cml7q52fz000oitl0z7m4udo7	cml7pyfy90003itl0wzs82ss5	2026-02-04 08:00:00	2026-02-05 00:00:00	2026-02-05 05:00:00	5	2026-02-04 07:59:26.612
cml7qlb4k005yitl0k7dfmuir	cml7q52fz000oitl0z7m4udo7	cml7pyfy90003itl0wzs82ss5	2026-02-05 08:00:00	2026-02-06 00:00:00	2026-02-06 05:00:00	5	2026-02-04 07:59:26.612
cml7qlb4k005zitl0sm7o02od	cml7q52fz000oitl0z7m4udo7	cml7pyfy90003itl0wzs82ss5	2026-02-06 08:00:00	2026-02-07 00:00:00	2026-02-07 05:00:00	5	2026-02-04 07:59:26.612
cml7qlb4k0060itl0i57tl8v9	cml7q52fz000oitl0z7m4udo7	cml7pyfy90003itl0wzs82ss5	2026-02-07 08:00:00	2026-02-07 18:15:00	2026-02-07 23:30:00	5.25	2026-02-04 07:59:26.612
cml7qlb4k0061itl0oaggms8y	cml7q52fz000oitl0z7m4udo7	cml7pyfy90003itl0wzs82ss5	2026-02-08 08:00:00	2026-02-08 18:15:00	2026-02-08 23:30:00	5.25	2026-02-04 07:59:26.612
cml7qlb4k0062itl05ojupph1	cml7q52fz000oitl0z7m4udo7	cml7pyfy90004itl0agfmc575	2026-02-03 08:00:00	2026-02-03 18:30:00	2026-02-03 22:15:00	3.75	2026-02-04 07:59:26.612
cml7qlb4k0063itl0ihil390t	cml7q52fz000oitl0z7m4udo7	cml7pyfy90004itl0agfmc575	2026-02-04 08:00:00	2026-02-04 18:30:00	2026-02-04 22:15:00	3.75	2026-02-04 07:59:26.612
cml7qlb4k0064itl0fnhmm4bc	cml7q52fz000oitl0z7m4udo7	cml7pyfy90004itl0agfmc575	2026-02-05 08:00:00	2026-02-05 18:30:00	2026-02-05 22:15:00	3.75	2026-02-04 07:59:26.612
cml7qlb4k0065itl0jcz5zc6y	cml7q52fz000oitl0z7m4udo7	cml7pyfy90004itl0agfmc575	2026-02-06 08:00:00	2026-02-06 18:30:00	2026-02-06 22:15:00	3.75	2026-02-04 07:59:26.612
cml7qlb4k0066itl047h4r42e	cml7q52fz000oitl0z7m4udo7	cml7pyfy90004itl0agfmc575	2026-02-07 08:00:00	2026-02-07 18:00:00	2026-02-07 23:00:00	5	2026-02-04 07:59:26.612
cml7qlb4k0067itl0t4at04nr	cml7q52fz000oitl0z7m4udo7	cml7pyfy90004itl0agfmc575	2026-02-08 08:00:00	2026-02-08 18:00:00	2026-02-08 23:00:00	5	2026-02-04 07:59:26.612
cml7qlb4k0068itl0xa7iz8ea	cml7q52fz000oitl0z7m4udo7	cml7pyfy90004itl0agfmc575	2026-02-07 08:00:00	2026-02-07 23:00:00	2026-02-08 05:30:00	6.5	2026-02-04 07:59:26.612
cml7qlb4k0069itl0vymbie0b	cml7q52fz000oitl0z7m4udo7	cml7pyfy90004itl0agfmc575	2026-02-08 08:00:00	2026-02-08 23:00:00	2026-02-09 05:30:00	6.5	2026-02-04 07:59:26.612
cml7qlb4k006aitl090fh6my4	cml7q52fz000oitl0z7m4udo7	cml7pyfy90004itl0agfmc575	2026-02-07 08:00:00	2026-02-08 00:00:00	2026-02-08 05:30:00	5.5	2026-02-04 07:59:26.612
cml7qlb4k006bitl0rao7edyi	cml7q52fz000oitl0z7m4udo7	cml7pyfy90004itl0agfmc575	2026-02-08 08:00:00	2026-02-09 00:00:00	2026-02-09 05:30:00	5.5	2026-02-04 07:59:26.612
cml7qlb4k006citl0l8zg7emc	cml7q52fz000oitl0z7m4udo7	cml7pyfy90004itl0agfmc575	2026-02-02 08:00:00	2026-02-03 01:00:00	2026-02-03 05:30:00	4.5	2026-02-04 07:59:26.612
cml7qlb4k006ditl0yxxrzjj9	cml7q52fz000oitl0z7m4udo7	cml7pyfy90004itl0agfmc575	2026-02-03 08:00:00	2026-02-04 01:00:00	2026-02-04 05:30:00	4.5	2026-02-04 07:59:26.612
cml7qlb4k006eitl08ehstqsm	cml7q52fz000oitl0z7m4udo7	cml7pyfy90004itl0agfmc575	2026-02-04 08:00:00	2026-02-05 01:00:00	2026-02-05 05:30:00	4.5	2026-02-04 07:59:26.612
cml7qlb4k006fitl0bzx9yh15	cml7q52fz000oitl0z7m4udo7	cml7pyfy90004itl0agfmc575	2026-02-05 08:00:00	2026-02-06 01:00:00	2026-02-06 05:30:00	4.5	2026-02-04 07:59:26.612
cml7qlb4k006gitl0qcrjgcrx	cml7q52fz000oitl0z7m4udo7	cml7pyfy90004itl0agfmc575	2026-02-06 08:00:00	2026-02-07 01:00:00	2026-02-07 05:30:00	4.5	2026-02-04 07:59:26.612
cml7qlb4k006hitl0gizxblsm	cml7q52fz000oitl0z7m4udo7	cml7pyfy90004itl0agfmc575	2026-02-03 08:00:00	2026-02-03 23:30:00	2026-02-04 05:30:00	6	2026-02-04 07:59:26.612
cml7qlb4k006iitl0s0st5yed	cml7q52fz000oitl0z7m4udo7	cml7pyfy90004itl0agfmc575	2026-02-04 08:00:00	2026-02-04 23:30:00	2026-02-05 05:30:00	6	2026-02-04 07:59:26.612
cml7qlb4k006jitl0anl17nlg	cml7q52fz000oitl0z7m4udo7	cml7pyfy90004itl0agfmc575	2026-02-05 08:00:00	2026-02-05 23:30:00	2026-02-06 05:30:00	6	2026-02-04 07:59:26.612
cml7qlb4k006kitl08qrnel43	cml7q52fz000oitl0z7m4udo7	cml7pyfy90004itl0agfmc575	2026-02-06 08:00:00	2026-02-06 23:30:00	2026-02-07 05:30:00	6	2026-02-04 07:59:26.612
cml7qlb65006litl0w0u4e5wp	cml7q52fz000pitl0tg62n6zj	cml7pyfy90004itl0agfmc575	2026-02-09 08:00:00	2026-02-09 18:30:00	2026-02-09 22:15:00	3.75	2026-02-04 07:59:26.669
cml7qlb65006mitl0w7sr00iq	cml7q52fz000pitl0tg62n6zj	cml7pyfy90004itl0agfmc575	2026-02-09 08:00:00	2026-02-09 23:30:00	2026-02-10 05:30:00	6	2026-02-04 07:59:26.669
cml7qlb65006nitl0o07n0xsn	cml7q52fz000pitl0tg62n6zj	cml7pyfy90003itl0wzs82ss5	2026-02-09 08:00:00	2026-02-09 18:45:00	2026-02-09 22:00:00	3.25	2026-02-04 07:59:26.669
cml7qlb65006oitl0d8mhi3cs	cml7q52fz000pitl0tg62n6zj	cml7pyfy90003itl0wzs82ss5	2026-02-10 08:00:00	2026-02-10 18:45:00	2026-02-10 22:00:00	3.25	2026-02-04 07:59:26.669
cml7qlb65006pitl0lnlb8h8l	cml7q52fz000pitl0tg62n6zj	cml7pyfy90003itl0wzs82ss5	2026-02-11 08:00:00	2026-02-11 18:45:00	2026-02-11 22:00:00	3.25	2026-02-04 07:59:26.669
cml7qlb65006qitl0cd92d7dm	cml7q52fz000pitl0tg62n6zj	cml7pyfy90003itl0wzs82ss5	2026-02-12 08:00:00	2026-02-12 18:45:00	2026-02-12 22:00:00	3.25	2026-02-04 07:59:26.669
cml7qlb65006ritl0f0bjhynl	cml7q52fz000pitl0tg62n6zj	cml7pyfy90003itl0wzs82ss5	2026-02-13 08:00:00	2026-02-13 18:45:00	2026-02-13 22:00:00	3.25	2026-02-04 07:59:26.669
cml7qlb65006sitl0c3wxogxr	cml7q52fz000pitl0tg62n6zj	cml7pyfy90003itl0wzs82ss5	2026-02-09 08:00:00	2026-02-10 00:00:00	2026-02-10 05:00:00	5	2026-02-04 07:59:26.669
cml7qlb65006titl0clwjv7dx	cml7q52fz000pitl0tg62n6zj	cml7pyfy90003itl0wzs82ss5	2026-02-10 08:00:00	2026-02-11 00:00:00	2026-02-11 05:00:00	5	2026-02-04 07:59:26.669
cml7qlb65006uitl0ehvqx31e	cml7q52fz000pitl0tg62n6zj	cml7pyfy90003itl0wzs82ss5	2026-02-11 08:00:00	2026-02-12 00:00:00	2026-02-12 05:00:00	5	2026-02-04 07:59:26.669
cml7qlb65006vitl0x0pc3ql2	cml7q52fz000pitl0tg62n6zj	cml7pyfy90003itl0wzs82ss5	2026-02-12 08:00:00	2026-02-13 00:00:00	2026-02-13 05:00:00	5	2026-02-04 07:59:26.669
cml7qlb65006witl0h7yuev9z	cml7q52fz000pitl0tg62n6zj	cml7pyfy90003itl0wzs82ss5	2026-02-13 08:00:00	2026-02-14 00:00:00	2026-02-14 05:00:00	5	2026-02-04 07:59:26.669
cml7qlb65006xitl0vqgvbgfe	cml7q52fz000pitl0tg62n6zj	cml7pyfy90003itl0wzs82ss5	2026-02-14 08:00:00	2026-02-14 18:15:00	2026-02-14 23:30:00	5.25	2026-02-04 07:59:26.669
cml7qlb65006yitl0cqpmfvt4	cml7q52fz000pitl0tg62n6zj	cml7pyfy90003itl0wzs82ss5	2026-02-15 08:00:00	2026-02-15 18:15:00	2026-02-15 23:30:00	5.25	2026-02-04 07:59:26.669
cml7qlb65006zitl081zml599	cml7q52fz000pitl0tg62n6zj	cml7pyfy90004itl0agfmc575	2026-02-10 08:00:00	2026-02-10 18:30:00	2026-02-10 22:15:00	3.75	2026-02-04 07:59:26.669
cml7qlb650070itl070dky0ch	cml7q52fz000pitl0tg62n6zj	cml7pyfy90004itl0agfmc575	2026-02-11 08:00:00	2026-02-11 18:30:00	2026-02-11 22:15:00	3.75	2026-02-04 07:59:26.669
cml7qlb650071itl03zm5xmb2	cml7q52fz000pitl0tg62n6zj	cml7pyfy90004itl0agfmc575	2026-02-12 08:00:00	2026-02-12 18:30:00	2026-02-12 22:15:00	3.75	2026-02-04 07:59:26.669
cml7qlb650072itl0q1n6w2hi	cml7q52fz000pitl0tg62n6zj	cml7pyfy90004itl0agfmc575	2026-02-13 08:00:00	2026-02-13 18:30:00	2026-02-13 22:15:00	3.75	2026-02-04 07:59:26.669
cml7qlb650073itl0useqlm8p	cml7q52fz000pitl0tg62n6zj	cml7pyfy90004itl0agfmc575	2026-02-14 08:00:00	2026-02-14 18:00:00	2026-02-14 23:00:00	5	2026-02-04 07:59:26.669
cml7qlb650074itl07s50m8lb	cml7q52fz000pitl0tg62n6zj	cml7pyfy90004itl0agfmc575	2026-02-15 08:00:00	2026-02-15 18:00:00	2026-02-15 23:00:00	5	2026-02-04 07:59:26.669
cml7qlb650075itl0bten8l19	cml7q52fz000pitl0tg62n6zj	cml7pyfy90004itl0agfmc575	2026-02-14 08:00:00	2026-02-14 23:00:00	2026-02-15 05:30:00	6.5	2026-02-04 07:59:26.669
cml7qlb650076itl0l8y27ma9	cml7q52fz000pitl0tg62n6zj	cml7pyfy90004itl0agfmc575	2026-02-15 08:00:00	2026-02-15 23:00:00	2026-02-16 05:30:00	6.5	2026-02-04 07:59:26.669
cml7qlb650077itl0ieoi1yfl	cml7q52fz000pitl0tg62n6zj	cml7pyfy90004itl0agfmc575	2026-02-14 08:00:00	2026-02-15 00:00:00	2026-02-15 05:30:00	5.5	2026-02-04 07:59:26.669
cml7qlb650078itl0ronfuvi7	cml7q52fz000pitl0tg62n6zj	cml7pyfy90004itl0agfmc575	2026-02-15 08:00:00	2026-02-16 00:00:00	2026-02-16 05:30:00	5.5	2026-02-04 07:59:26.669
cml7qlb650079itl0i3gsfz7f	cml7q52fz000pitl0tg62n6zj	cml7pyfy90004itl0agfmc575	2026-02-09 08:00:00	2026-02-10 01:00:00	2026-02-10 05:30:00	4.5	2026-02-04 07:59:26.669
cml7qlb65007aitl0sd10imf7	cml7q52fz000pitl0tg62n6zj	cml7pyfy90004itl0agfmc575	2026-02-10 08:00:00	2026-02-11 01:00:00	2026-02-11 05:30:00	4.5	2026-02-04 07:59:26.669
cml7qlb65007bitl0q5xaq2gp	cml7q52fz000pitl0tg62n6zj	cml7pyfy90004itl0agfmc575	2026-02-11 08:00:00	2026-02-12 01:00:00	2026-02-12 05:30:00	4.5	2026-02-04 07:59:26.669
cml7qlb65007citl02jh2e9sq	cml7q52fz000pitl0tg62n6zj	cml7pyfy90004itl0agfmc575	2026-02-12 08:00:00	2026-02-13 01:00:00	2026-02-13 05:30:00	4.5	2026-02-04 07:59:26.669
cml7qlb65007ditl0orme5njy	cml7q52fz000pitl0tg62n6zj	cml7pyfy90004itl0agfmc575	2026-02-13 08:00:00	2026-02-14 01:00:00	2026-02-14 05:30:00	4.5	2026-02-04 07:59:26.669
cml7qlb65007eitl0z0vfus7v	cml7q52fz000pitl0tg62n6zj	cml7pyfy90004itl0agfmc575	2026-02-10 08:00:00	2026-02-10 23:30:00	2026-02-11 05:30:00	6	2026-02-04 07:59:26.669
cml7qlb65007fitl08x4213kh	cml7q52fz000pitl0tg62n6zj	cml7pyfy90004itl0agfmc575	2026-02-11 08:00:00	2026-02-11 23:30:00	2026-02-12 05:30:00	6	2026-02-04 07:59:26.669
cml7qlb65007gitl048tv4iqy	cml7q52fz000pitl0tg62n6zj	cml7pyfy90004itl0agfmc575	2026-02-12 08:00:00	2026-02-12 23:30:00	2026-02-13 05:30:00	6	2026-02-04 07:59:26.669
cml7qlb65007hitl0kykpg197	cml7q52fz000pitl0tg62n6zj	cml7pyfy90004itl0agfmc575	2026-02-13 08:00:00	2026-02-13 23:30:00	2026-02-14 05:30:00	6	2026-02-04 07:59:26.669
cmlakcg5g00hoitl0po6yh0d2	cmlakcg4e00goitl0tzv15frx	cml7pyfy90004itl0agfmc575	2026-02-02 12:00:00	2026-02-02 18:30:00	2026-02-02 22:15:00	3.75	2026-02-06 07:27:54.052
cmlakcg5f00gsitl0rsw9xmb2	cmlakcg4e00goitl0tzv15frx	cml7pyfy90004itl0agfmc575	2026-02-02 12:00:00	2026-02-02 23:30:00	2026-02-03 05:30:00	6	2026-02-06 07:27:54.052
cmlakcg5g00hqitl0dwbx8tta	cmlakcg4e00goitl0tzv15frx	cml7pyfy90003itl0wzs82ss5	2026-02-02 12:00:00	2026-02-02 18:45:00	2026-02-02 22:00:00	3.25	2026-02-06 07:27:54.052
cmlakcg5f00guitl0k9clxw46	cmlakcg4e00goitl0tzv15frx	cml7pyfy90003itl0wzs82ss5	2026-02-03 12:00:00	2026-02-03 18:45:00	2026-02-03 22:00:00	3.25	2026-02-06 07:27:54.052
cmlakcg5g00hsitl0vz10lmti	cmlakcg4e00goitl0tzv15frx	cml7pyfy90003itl0wzs82ss5	2026-02-04 12:00:00	2026-02-04 18:45:00	2026-02-04 22:00:00	3.25	2026-02-06 07:27:54.052
cmlakcg5f00gxitl0ggdh03fi	cmlakcg4e00goitl0tzv15frx	cml7pyfy90003itl0wzs82ss5	2026-02-06 12:00:00	2026-02-06 18:45:00	2026-02-06 22:00:00	3.25	2026-02-06 07:27:54.052
cmlakcg5f00h1itl0ewm4r4ck	cmlakcg4e00goitl0tzv15frx	cml7pyfy90003itl0wzs82ss5	2026-02-05 12:00:00	2026-02-06 00:00:00	2026-02-06 05:00:00	5	2026-02-06 07:27:54.052
cmlakcg5f00h5itl040g4bboi	cmlakcg4e00goitl0tzv15frx	cml7pyfy90004itl0agfmc575	2026-02-03 12:00:00	2026-02-03 18:30:00	2026-02-03 22:15:00	3.75	2026-02-06 07:27:54.052
cmlakcg5f00h8itl0pv7sp9js	cmlakcg4e00goitl0tzv15frx	cml7pyfy90004itl0agfmc575	2026-02-06 12:00:00	2026-02-06 18:30:00	2026-02-06 22:15:00	3.75	2026-02-06 07:27:54.052
cmlakcg5f00haitl0o1xv9tjo	cmlakcg4e00goitl0tzv15frx	cml7pyfy90004itl0agfmc575	2026-02-08 12:00:00	2026-02-08 18:00:00	2026-02-08 23:00:00	5	2026-02-06 07:27:54.052
cmlakcg5f00hcitl00ookx8sm	cmlakcg4e00goitl0tzv15frx	cml7pyfy90004itl0agfmc575	2026-02-08 12:00:00	2026-02-08 23:00:00	2026-02-09 05:30:00	6.5	2026-02-06 07:27:54.052
cmlakcg5f00heitl0qtoawv33	cmlakcg4e00goitl0tzv15frx	cml7pyfy90004itl0agfmc575	2026-02-08 12:00:00	2026-02-09 00:00:00	2026-02-09 05:30:00	5.5	2026-02-06 07:27:54.052
cmlakcg5f00hfitl0hfs4hb30	cmlakcg4e00goitl0tzv15frx	cml7pyfy90004itl0agfmc575	2026-02-02 12:00:00	2026-02-03 01:00:00	2026-02-03 05:30:00	4.5	2026-02-06 07:27:54.052
cmlakcg5f00hiitl0vvt1gil6	cmlakcg4e00goitl0tzv15frx	cml7pyfy90004itl0agfmc575	2026-02-05 12:00:00	2026-02-06 01:00:00	2026-02-06 05:30:00	4.5	2026-02-06 07:27:54.052
cmlakcg5f00hjitl0wk5u6cl9	cmlakcg4e00goitl0tzv15frx	cml7pyfy90004itl0agfmc575	2026-02-06 12:00:00	2026-02-07 01:00:00	2026-02-07 05:30:00	4.5	2026-02-06 07:27:54.052
cmlakcg5f00hlitl0x7ro88wq	cmlakcg4e00goitl0tzv15frx	cml7pyfy90004itl0agfmc575	2026-02-04 12:00:00	2026-02-04 23:30:00	2026-02-05 05:30:00	6	2026-02-06 07:27:54.052
cmlakcg5g00htitl0m9i36yzf	cmlakcg4e00goitl0tzv15frx	cml7pyfy90003itl0wzs82ss5	2026-02-05 12:00:00	2026-02-05 18:45:00	2026-02-05 22:00:00	3.25	2026-02-06 07:27:54.052
cmlakcg5g00hvitl08nb11pgb	cmlakcg4e00goitl0tzv15frx	cml7pyfy90003itl0wzs82ss5	2026-02-02 12:00:00	2026-02-03 00:00:00	2026-02-03 05:00:00	5	2026-02-06 07:27:54.052
cmlakcg5g00hwitl02oka8cex	cmlakcg4e00goitl0tzv15frx	cml7pyfy90003itl0wzs82ss5	2026-02-03 12:00:00	2026-02-04 00:00:00	2026-02-04 05:00:00	5	2026-02-06 07:27:54.052
cmlakcg5g00hxitl0lban9l2q	cmlakcg4e00goitl0tzv15frx	cml7pyfy90003itl0wzs82ss5	2026-02-04 12:00:00	2026-02-05 00:00:00	2026-02-05 05:00:00	5	2026-02-06 07:27:54.052
cmlakcg5g00hzitl0e0qgxyaj	cmlakcg4e00goitl0tzv15frx	cml7pyfy90003itl0wzs82ss5	2026-02-06 12:00:00	2026-02-07 00:00:00	2026-02-07 05:00:00	5	2026-02-06 07:27:54.052
cmlakcg5g00i0itl0sf0snubg	cmlakcg4e00goitl0tzv15frx	cml7pyfy90003itl0wzs82ss5	2026-02-07 12:00:00	2026-02-07 18:15:00	2026-02-07 23:30:00	5.25	2026-02-06 07:27:54.052
cmlakcg5g00i1itl02t6tl9f9	cmlakcg4e00goitl0tzv15frx	cml7pyfy90003itl0wzs82ss5	2026-02-08 12:00:00	2026-02-08 18:15:00	2026-02-08 23:30:00	5.25	2026-02-06 07:27:54.052
cmlakcg5g00i3itl0tlqwn4la	cmlakcg4e00goitl0tzv15frx	cml7pyfy90004itl0agfmc575	2026-02-04 12:00:00	2026-02-04 18:30:00	2026-02-04 22:15:00	3.75	2026-02-06 07:27:54.052
cmlakcg5g00i4itl0p5oyum99	cmlakcg4e00goitl0tzv15frx	cml7pyfy90004itl0agfmc575	2026-02-05 12:00:00	2026-02-05 18:30:00	2026-02-05 22:15:00	3.75	2026-02-06 07:27:54.052
cmlakcg5g00i6itl03vpralk6	cmlakcg4e00goitl0tzv15frx	cml7pyfy90004itl0agfmc575	2026-02-07 12:00:00	2026-02-07 18:00:00	2026-02-07 23:00:00	5	2026-02-06 07:27:54.052
cmlakcg5g00i8itl0r6gd3nao	cmlakcg4e00goitl0tzv15frx	cml7pyfy90004itl0agfmc575	2026-02-07 12:00:00	2026-02-07 23:00:00	2026-02-08 05:30:00	6.5	2026-02-06 07:27:54.052
cmlakcg5g00iaitl0r16gqinw	cmlakcg4e00goitl0tzv15frx	cml7pyfy90004itl0agfmc575	2026-02-07 12:00:00	2026-02-08 00:00:00	2026-02-08 05:30:00	5.5	2026-02-06 07:27:54.052
cmlakcg5g00iditl00vsriq6z	cmlakcg4e00goitl0tzv15frx	cml7pyfy90004itl0agfmc575	2026-02-03 12:00:00	2026-02-04 01:00:00	2026-02-04 05:30:00	4.5	2026-02-06 07:27:54.052
cmlakcg5g00ieitl0dehcdm1e	cmlakcg4e00goitl0tzv15frx	cml7pyfy90004itl0agfmc575	2026-02-04 12:00:00	2026-02-05 01:00:00	2026-02-05 05:30:00	4.5	2026-02-06 07:27:54.052
cmlakcg5g00ihitl00xzml57w	cmlakcg4e00goitl0tzv15frx	cml7pyfy90004itl0agfmc575	2026-02-03 12:00:00	2026-02-03 23:30:00	2026-02-04 05:30:00	6	2026-02-06 07:27:54.052
cmlakcg5g00ijitl01slncp6d	cmlakcg4e00goitl0tzv15frx	cml7pyfy90004itl0agfmc575	2026-02-05 12:00:00	2026-02-05 23:30:00	2026-02-06 05:30:00	6	2026-02-06 07:27:54.052
cmlakcg5g00ikitl0kqpmep0u	cmlakcg4e00goitl0tzv15frx	cml7pyfy90004itl0agfmc575	2026-02-06 12:00:00	2026-02-06 23:30:00	2026-02-07 05:30:00	6	2026-02-06 07:27:54.052
cmlakdn1i00ilitl0ctl015rh	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90004itl0agfmc575	2026-02-09 12:00:00	2026-02-09 18:30:00	2026-02-09 22:15:00	3.75	2026-02-06 07:28:49.638
cmlakdn1i00imitl0kkxqioh0	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90004itl0agfmc575	2026-02-09 12:00:00	2026-02-09 23:30:00	2026-02-10 05:30:00	6	2026-02-06 07:28:49.638
cmlakdn1i00initl04dny6egm	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90003itl0wzs82ss5	2026-02-09 12:00:00	2026-02-09 18:45:00	2026-02-09 22:00:00	3.25	2026-02-06 07:28:49.638
cmlakdn1i00ioitl0w17wmn6l	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90003itl0wzs82ss5	2026-02-10 12:00:00	2026-02-10 18:45:00	2026-02-10 22:00:00	3.25	2026-02-06 07:28:49.638
cmlakdn1i00ipitl0znpy0p7f	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90003itl0wzs82ss5	2026-02-11 12:00:00	2026-02-11 18:45:00	2026-02-11 22:00:00	3.25	2026-02-06 07:28:49.638
cmlakdn1i00iqitl05m56afxm	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90003itl0wzs82ss5	2026-02-12 12:00:00	2026-02-12 18:45:00	2026-02-12 22:00:00	3.25	2026-02-06 07:28:49.638
cmlakdn1i00iritl02h66gv78	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90003itl0wzs82ss5	2026-02-13 12:00:00	2026-02-13 18:45:00	2026-02-13 22:00:00	3.25	2026-02-06 07:28:49.638
cmlakdn1i00isitl0zxfaylga	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90003itl0wzs82ss5	2026-02-09 12:00:00	2026-02-10 00:00:00	2026-02-10 05:00:00	5	2026-02-06 07:28:49.638
cmlakdn1i00ititl0v8cl9xtr	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90003itl0wzs82ss5	2026-02-10 12:00:00	2026-02-11 00:00:00	2026-02-11 05:00:00	5	2026-02-06 07:28:49.638
cmlakdn1i00iuitl0uraxsocn	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90003itl0wzs82ss5	2026-02-11 12:00:00	2026-02-12 00:00:00	2026-02-12 05:00:00	5	2026-02-06 07:28:49.638
cmlakdn1i00ivitl0embbtois	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90003itl0wzs82ss5	2026-02-12 12:00:00	2026-02-13 00:00:00	2026-02-13 05:00:00	5	2026-02-06 07:28:49.638
cmlakdn1i00iwitl082e4kwwk	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90003itl0wzs82ss5	2026-02-13 12:00:00	2026-02-14 00:00:00	2026-02-14 05:00:00	5	2026-02-06 07:28:49.638
cmlakdn1i00ixitl0wxjdft91	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90003itl0wzs82ss5	2026-02-14 12:00:00	2026-02-14 18:15:00	2026-02-14 23:30:00	5.25	2026-02-06 07:28:49.638
cmlakdn1i00iyitl00j9qiu92	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90003itl0wzs82ss5	2026-02-15 12:00:00	2026-02-15 18:15:00	2026-02-15 23:30:00	5.25	2026-02-06 07:28:49.638
cmlakdn1i00izitl034bxb0ac	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90004itl0agfmc575	2026-02-10 12:00:00	2026-02-10 18:30:00	2026-02-10 22:15:00	3.75	2026-02-06 07:28:49.638
cmlakdn1i00j0itl0yevd04dr	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90004itl0agfmc575	2026-02-11 12:00:00	2026-02-11 18:30:00	2026-02-11 22:15:00	3.75	2026-02-06 07:28:49.638
cmlakdn1i00j1itl0psmqwpim	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90004itl0agfmc575	2026-02-12 12:00:00	2026-02-12 18:30:00	2026-02-12 22:15:00	3.75	2026-02-06 07:28:49.638
cmlakdn1i00j2itl0oxdz3uvb	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90004itl0agfmc575	2026-02-13 12:00:00	2026-02-13 18:30:00	2026-02-13 22:15:00	3.75	2026-02-06 07:28:49.638
cmlakdn1i00j3itl0l1z0mefv	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90004itl0agfmc575	2026-02-14 12:00:00	2026-02-14 18:00:00	2026-02-14 23:00:00	5	2026-02-06 07:28:49.638
cmlakdn1i00j4itl01xm58ld6	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90004itl0agfmc575	2026-02-15 12:00:00	2026-02-15 18:00:00	2026-02-15 23:00:00	5	2026-02-06 07:28:49.638
cmlakdn1i00j5itl09fhrr9ef	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90004itl0agfmc575	2026-02-14 12:00:00	2026-02-14 23:00:00	2026-02-15 05:30:00	6.5	2026-02-06 07:28:49.638
cmlakdn1i00j6itl0jr8cnws0	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90004itl0agfmc575	2026-02-15 12:00:00	2026-02-15 23:00:00	2026-02-16 05:30:00	6.5	2026-02-06 07:28:49.638
cmlakdn1i00j7itl0qacxnkgt	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90004itl0agfmc575	2026-02-14 12:00:00	2026-02-15 00:00:00	2026-02-15 05:30:00	5.5	2026-02-06 07:28:49.638
cmlakdn1i00j8itl0bq8ot5ay	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90004itl0agfmc575	2026-02-15 12:00:00	2026-02-16 00:00:00	2026-02-16 05:30:00	5.5	2026-02-06 07:28:49.638
cmlakdn1i00j9itl074xs6use	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90004itl0agfmc575	2026-02-09 12:00:00	2026-02-10 01:00:00	2026-02-10 05:30:00	4.5	2026-02-06 07:28:49.638
cmlakdn1i00jaitl0v2l43tta	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90004itl0agfmc575	2026-02-10 12:00:00	2026-02-11 01:00:00	2026-02-11 05:30:00	4.5	2026-02-06 07:28:49.638
cmlakdn1i00jbitl09x2anl6n	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90004itl0agfmc575	2026-02-11 12:00:00	2026-02-12 01:00:00	2026-02-12 05:30:00	4.5	2026-02-06 07:28:49.638
cmlakdn1i00jcitl01pyye3ez	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90004itl0agfmc575	2026-02-12 12:00:00	2026-02-13 01:00:00	2026-02-13 05:30:00	4.5	2026-02-06 07:28:49.638
cmlakdn1i00jditl0d4aofhns	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90004itl0agfmc575	2026-02-13 12:00:00	2026-02-14 01:00:00	2026-02-14 05:30:00	4.5	2026-02-06 07:28:49.638
cmlakdn1i00jeitl0v3afezob	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90004itl0agfmc575	2026-02-10 12:00:00	2026-02-10 23:30:00	2026-02-11 05:30:00	6	2026-02-06 07:28:49.638
cmlakdn1i00jfitl0jazx8arj	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90004itl0agfmc575	2026-02-11 12:00:00	2026-02-11 23:30:00	2026-02-12 05:30:00	6	2026-02-06 07:28:49.638
cmlakdn1i00jgitl0b1ncf9q0	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90004itl0agfmc575	2026-02-12 12:00:00	2026-02-12 23:30:00	2026-02-13 05:30:00	6	2026-02-06 07:28:49.638
cmlakdn1i00jhitl0re2phbww	cmlakcg4e00gpitl01ndt8ihq	cml7pyfy90004itl0agfmc575	2026-02-13 12:00:00	2026-02-13 23:30:00	2026-02-14 05:30:00	6	2026-02-06 07:28:49.638
cmlaktzc000nvitl0ias90bdv	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90004itl0agfmc575	2026-02-16 12:00:00	2026-02-16 18:30:00	2026-02-16 22:15:00	3.75	2026-02-06 07:41:32.065
cmlaktzc000nwitl0oajbvm4i	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90004itl0agfmc575	2026-02-16 12:00:00	2026-02-16 23:30:00	2026-02-17 05:30:00	6	2026-02-06 07:41:32.065
cmlaktzc000nxitl0ezrrifhc	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90003itl0wzs82ss5	2026-02-16 12:00:00	2026-02-16 18:45:00	2026-02-16 22:00:00	3.25	2026-02-06 07:41:32.065
cmlaktzc000nyitl0awpboxpv	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90003itl0wzs82ss5	2026-02-17 12:00:00	2026-02-17 18:45:00	2026-02-17 22:00:00	3.25	2026-02-06 07:41:32.065
cmlaktzc000nzitl0vwolzqdf	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90003itl0wzs82ss5	2026-02-18 12:00:00	2026-02-18 18:45:00	2026-02-18 22:00:00	3.25	2026-02-06 07:41:32.065
cmlaktzc000o0itl0xlep75m2	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90003itl0wzs82ss5	2026-02-19 12:00:00	2026-02-19 18:45:00	2026-02-19 22:00:00	3.25	2026-02-06 07:41:32.065
cmlaktzc000o1itl0e75ftw3u	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90003itl0wzs82ss5	2026-02-20 12:00:00	2026-02-20 18:45:00	2026-02-20 22:00:00	3.25	2026-02-06 07:41:32.065
cmlaktzc000o2itl0u7x7geim	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90003itl0wzs82ss5	2026-02-16 12:00:00	2026-02-17 00:00:00	2026-02-17 05:00:00	5	2026-02-06 07:41:32.065
cmlaktzc000o3itl08bt40fpa	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90003itl0wzs82ss5	2026-02-17 12:00:00	2026-02-18 00:00:00	2026-02-18 05:00:00	5	2026-02-06 07:41:32.065
cmlaktzc000o4itl057hi34il	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90003itl0wzs82ss5	2026-02-18 12:00:00	2026-02-19 00:00:00	2026-02-19 05:00:00	5	2026-02-06 07:41:32.065
cmlaktzc000o5itl0wp23kl9t	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90003itl0wzs82ss5	2026-02-19 12:00:00	2026-02-20 00:00:00	2026-02-20 05:00:00	5	2026-02-06 07:41:32.065
cmlaktzc000o6itl0086d6i6o	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90003itl0wzs82ss5	2026-02-20 12:00:00	2026-02-21 00:00:00	2026-02-21 05:00:00	5	2026-02-06 07:41:32.065
cmlaktzc000o7itl06kvzq2yt	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90003itl0wzs82ss5	2026-02-21 12:00:00	2026-02-21 18:15:00	2026-02-21 23:30:00	5.25	2026-02-06 07:41:32.065
cmlaktzc000o8itl0jmx2xg6l	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90003itl0wzs82ss5	2026-02-22 12:00:00	2026-02-22 18:15:00	2026-02-22 23:30:00	5.25	2026-02-06 07:41:32.065
cmlaktzc000o9itl0ur6hujgz	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90004itl0agfmc575	2026-02-17 12:00:00	2026-02-17 18:30:00	2026-02-17 22:15:00	3.75	2026-02-06 07:41:32.065
cmlaktzc000oaitl08z4c5b83	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90004itl0agfmc575	2026-02-18 12:00:00	2026-02-18 18:30:00	2026-02-18 22:15:00	3.75	2026-02-06 07:41:32.065
cmlaktzc000obitl0lppckk0c	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90004itl0agfmc575	2026-02-19 12:00:00	2026-02-19 18:30:00	2026-02-19 22:15:00	3.75	2026-02-06 07:41:32.065
cmlaktzc000ocitl080kia957	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90004itl0agfmc575	2026-02-20 12:00:00	2026-02-20 18:30:00	2026-02-20 22:15:00	3.75	2026-02-06 07:41:32.065
cmlaktzc000oditl0az6sq303	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90004itl0agfmc575	2026-02-21 12:00:00	2026-02-21 18:00:00	2026-02-21 23:00:00	5	2026-02-06 07:41:32.065
cmlaktzc000oeitl0qsshgjsr	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90004itl0agfmc575	2026-02-22 12:00:00	2026-02-22 18:00:00	2026-02-22 23:00:00	5	2026-02-06 07:41:32.065
cmlaktzc000ofitl05y89yoig	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90004itl0agfmc575	2026-02-21 12:00:00	2026-02-21 23:00:00	2026-02-22 05:30:00	6.5	2026-02-06 07:41:32.065
cmlaktzc000ogitl04otwcd3m	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90004itl0agfmc575	2026-02-22 12:00:00	2026-02-22 23:00:00	2026-02-23 05:30:00	6.5	2026-02-06 07:41:32.065
cmlaktzc000ohitl0vb1cpigv	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90004itl0agfmc575	2026-02-21 12:00:00	2026-02-22 00:00:00	2026-02-22 05:30:00	5.5	2026-02-06 07:41:32.065
cmlaktzc000oiitl0i496guw0	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90004itl0agfmc575	2026-02-22 12:00:00	2026-02-23 00:00:00	2026-02-23 05:30:00	5.5	2026-02-06 07:41:32.065
cmlaktzc000ojitl0d7slf8y3	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90004itl0agfmc575	2026-02-16 12:00:00	2026-02-17 01:00:00	2026-02-17 05:30:00	4.5	2026-02-06 07:41:32.065
cmlaktzc000okitl0svvsl15e	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90004itl0agfmc575	2026-02-17 12:00:00	2026-02-18 01:00:00	2026-02-18 05:30:00	4.5	2026-02-06 07:41:32.065
cmlaktzc000olitl0p57dpy93	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90004itl0agfmc575	2026-02-18 12:00:00	2026-02-19 01:00:00	2026-02-19 05:30:00	4.5	2026-02-06 07:41:32.065
cmlaktzc000omitl04rkqw2f4	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90004itl0agfmc575	2026-02-19 12:00:00	2026-02-20 01:00:00	2026-02-20 05:30:00	4.5	2026-02-06 07:41:32.065
cmlaktzc000onitl0qt48gwwm	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90004itl0agfmc575	2026-02-20 12:00:00	2026-02-21 01:00:00	2026-02-21 05:30:00	4.5	2026-02-06 07:41:32.065
cmlaktzc000ooitl0up17kya2	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90004itl0agfmc575	2026-02-17 12:00:00	2026-02-17 23:30:00	2026-02-18 05:30:00	6	2026-02-06 07:41:32.065
cmlaktzc000opitl0lg0czbj7	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90004itl0agfmc575	2026-02-18 12:00:00	2026-02-18 23:30:00	2026-02-19 05:30:00	6	2026-02-06 07:41:32.065
cmlaktzc000oqitl0zvj5leso	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90004itl0agfmc575	2026-02-19 12:00:00	2026-02-19 23:30:00	2026-02-20 05:30:00	6	2026-02-06 07:41:32.065
cmlaktzc000oritl08n2w3st6	cmlakcg4e00gqitl0u47y2mhf	cml7pyfy90004itl0agfmc575	2026-02-20 12:00:00	2026-02-20 23:30:00	2026-02-21 05:30:00	6	2026-02-06 07:41:32.065
\.


--
-- Data for Name: ShiftTemplate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ShiftTemplate" (id, "roleTypeId", "dayOfWeek", "startTime", "endTime", hours, "isActive", "createdAt", "updatedAt") FROM stdin;
cml7q91k90012itl0oe4rde76	cml7pyfy90004itl0agfmc575	0	10:30	14:15	3.75	t	2026-02-04 07:49:54.345	2026-02-04 07:49:54.345
cml7q9n080017itl0pxt33dpq	cml7pyfy90004itl0agfmc575	0	15:30	21:30	6	t	2026-02-04 07:50:22.136	2026-02-04 07:50:22.136
cml7qaeqn001citl00s65fjna	cml7pyfy90003itl0wzs82ss5	0	10:45	14:00	3.25	t	2026-02-04 07:50:58.079	2026-02-04 07:50:58.079
cml7qbi8f001hitl04clhe49l	cml7pyfy90003itl0wzs82ss5	1	10:45	14:00	3.25	t	2026-02-04 07:51:49.264	2026-02-04 07:51:49.264
cml7qbloj001mitl0yusixsvy	cml7pyfy90003itl0wzs82ss5	2	10:45	14:00	3.25	t	2026-02-04 07:51:53.732	2026-02-04 07:51:53.732
cml7qboh6001ritl02zyy6b3k	cml7pyfy90003itl0wzs82ss5	3	10:45	14:00	3.25	t	2026-02-04 07:51:57.354	2026-02-04 07:51:57.354
cml7qbrg0001witl0gawy6p6j	cml7pyfy90003itl0wzs82ss5	4	10:45	14:00	3.25	t	2026-02-04 07:52:01.2	2026-02-04 07:52:01.2
cml7qccna0021itl0apfviqvu	cml7pyfy90003itl0wzs82ss5	0	16:00	21:00	5	t	2026-02-04 07:52:28.679	2026-02-04 07:52:28.679
cml7qcf9p0026itl0fuiaecer	cml7pyfy90003itl0wzs82ss5	1	16:00	21:00	5	t	2026-02-04 07:52:32.078	2026-02-04 07:52:32.078
cml7qcied002bitl06ftz7w5u	cml7pyfy90003itl0wzs82ss5	2	16:00	21:00	5	t	2026-02-04 07:52:36.133	2026-02-04 07:52:36.133
cml7qcl08002gitl0iv1dzhxv	cml7pyfy90003itl0wzs82ss5	3	16:00	21:00	5	t	2026-02-04 07:52:39.512	2026-02-04 07:52:39.512
cml7qcnli002litl081uomzpc	cml7pyfy90003itl0wzs82ss5	4	16:00	21:00	5	t	2026-02-04 07:52:42.871	2026-02-04 07:52:42.871
cml7qdxae002qitl033eyxoin	cml7pyfy90003itl0wzs82ss5	5	10:15	15:30	5.25	t	2026-02-04 07:53:42.087	2026-02-04 07:53:42.087
cml7qe2ic002vitl01nl4oxwv	cml7pyfy90003itl0wzs82ss5	6	10:15	15:30	5.25	t	2026-02-04 07:53:48.853	2026-02-04 07:53:48.853
cml7qeshx0030itl0x9vop96q	cml7pyfy90004itl0agfmc575	1	10:30	14:15	3.75	t	2026-02-04 07:54:22.533	2026-02-04 07:54:22.533
cml7qew3s0035itl05si1tr63	cml7pyfy90004itl0agfmc575	2	10:30	14:15	3.75	t	2026-02-04 07:54:27.209	2026-02-04 07:54:27.209
cml7qeywk003aitl0nu7h242b	cml7pyfy90004itl0agfmc575	3	10:30	14:15	3.75	t	2026-02-04 07:54:30.836	2026-02-04 07:54:30.836
cml7qf2eg003fitl0vawgw4kd	cml7pyfy90004itl0agfmc575	4	10:30	14:15	3.75	t	2026-02-04 07:54:35.368	2026-02-04 07:54:35.368
cml7qg5bq003kitl0efjzysty	cml7pyfy90004itl0agfmc575	5	10:00	15:00	5	t	2026-02-04 07:55:25.815	2026-02-04 07:55:25.815
cml7qg8ib003pitl0pdl2zmxx	cml7pyfy90004itl0agfmc575	6	10:00	15:00	5	t	2026-02-04 07:55:29.939	2026-02-04 07:55:29.939
cml7qguud003uitl0fgw3ridk	cml7pyfy90004itl0agfmc575	5	15:00	21:30	6.5	t	2026-02-04 07:55:58.886	2026-02-04 07:55:58.886
cml7qgyqx003zitl00d5pldbi	cml7pyfy90004itl0agfmc575	6	15:00	21:30	6.5	t	2026-02-04 07:56:03.945	2026-02-04 07:56:03.945
cml7qhvng0044itl0qg3wvo5x	cml7pyfy90004itl0agfmc575	5	16:00	21:30	5.5	t	2026-02-04 07:56:46.588	2026-02-04 07:56:46.588
cml7qhztw0049itl0ve7t1nm6	cml7pyfy90004itl0agfmc575	6	16:00	21:30	5.5	t	2026-02-04 07:56:52.005	2026-02-04 07:56:52.005
cml7qiaom004eitl0u95we63a	cml7pyfy90004itl0agfmc575	0	17:00	21:30	4.5	t	2026-02-04 07:57:06.07	2026-02-04 07:57:06.07
cml7qidux004jitl0idwmg7ql	cml7pyfy90004itl0agfmc575	1	17:00	21:30	4.5	t	2026-02-04 07:57:10.185	2026-02-04 07:57:10.185
cml7qjqjx004oitl0kemm4cqp	cml7pyfy90004itl0agfmc575	2	17:00	21:30	4.5	t	2026-02-04 07:58:13.293	2026-02-04 07:58:13.293
cml7qjtes004titl0getret8g	cml7pyfy90004itl0agfmc575	3	17:00	21:30	4.5	t	2026-02-04 07:58:16.996	2026-02-04 07:58:16.996
cml7qjwg9004yitl0cbyiae2c	cml7pyfy90004itl0agfmc575	4	17:00	21:30	4.5	t	2026-02-04 07:58:20.938	2026-02-04 07:58:20.938
cml7qkalh0053itl0rprd0p0y	cml7pyfy90004itl0agfmc575	1	15:30	21:30	6	t	2026-02-04 07:58:39.269	2026-02-04 07:58:39.269
cml7qkdcs0058itl0n4uhwdui	cml7pyfy90004itl0agfmc575	2	15:30	21:30	6	t	2026-02-04 07:58:42.845	2026-02-04 07:58:42.845
cml7qkgv8005ditl08vbeuh8r	cml7pyfy90004itl0agfmc575	3	15:30	21:30	6	t	2026-02-04 07:58:47.396	2026-02-04 07:58:47.396
cml7qkk9a005iitl0rj6sjwwe	cml7pyfy90004itl0agfmc575	4	15:30	21:30	6	t	2026-02-04 07:58:51.791	2026-02-04 07:58:51.791
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."User" (id, name, role, "passcodeHash", weight, "maxHoursWeek", "roleTypeId", "createdAt", "updatedAt") FROM stdin;
cml7ptotx0000itl036r0orfn	ericyuan	ADMIN	d9a5223b761c375d1263e6e57ebec42d3e0fe3f6f283488d2eb204fb6ff17ee5	1	24	\N	2026-02-04 07:37:58.006	2026-02-04 07:37:58.006
cml7q301e000fitl0xaqs8kp9	Eric Yuan	EMPLOYEE	03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4	9	24	cml7q11vz0007itl0ibvejpf9	2026-02-04 07:45:12.434	2026-02-04 07:45:12.434
cml7r4x0a007sitl0t1judo7d	JT	EMPLOYEE	888b19a43b151683c87895f6211d9f8640f97bdc8ef32f03dbe057c8f5e56d32	9	24	cml7pyfy90004itl0agfmc575	2026-02-04 08:14:41.435	2026-02-04 08:14:41.435
cmlajqn7r008iitl0mjd6k2hp	Eric Abu	EMPLOYEE	fe675fe7aaee830b6fed09b64e034f84dcbdaeb429d9cccd4ebb90e15af8dd71	1	24	cml7pyfy90004itl0agfmc575	2026-02-06 07:10:56.774	2026-02-06 07:10:56.774
cmlajqxb9008nitl0vy9fe2ob	Jasmine	EMPLOYEE	b281bc2c616cb3c3a097215fdc9397ae87e6e06b156cc34e656be7a1a9ce8839	1	24	cml7pyfy90003itl0wzs82ss5	2026-02-06 07:11:09.862	2026-02-06 07:11:09.862
cmlajr9h7008sitl0mlb5x9f3	Wei	EMPLOYEE	8c9a013ab70c0434313e3e881c310b9ff24aff1075255ceede3f2c239c231623	1	24	cml7pyfy90003itl0wzs82ss5	2026-02-06 07:11:25.627	2026-02-06 07:11:25.627
cmlajrzeu008xitl0e7b8xyuq	Mark	EMPLOYEE	75992a5ac67ff644d3063976c2effd10bdd93fcc109798e3d5c1acf2e530d01a	1	24	cml7pyfy90004itl0agfmc575	2026-02-06 07:11:59.238	2026-02-06 07:11:59.238
cmlajs7py0092itl0jrdovags	Liam	EMPLOYEE	7f861bcee185de001377d79e08af62e94b1e7718e2470e08520c917f8d953602	1	24	cml7pyfy90004itl0agfmc575	2026-02-06 07:12:10.007	2026-02-06 07:12:10.007
cmlajsige0097itl0gjo69mf7	Saniya	EMPLOYEE	478c4ffb1cbcea37956a748e6c19d8eadd0a47e86f5e308d26cad39453b5d1ab	1	24	cml7pyfy90003itl0wzs82ss5	2026-02-06 07:12:23.918	2026-02-06 07:12:23.918
cmlajsv86009citl0zdv2yfmo	Billy	EMPLOYEE	9aaf689fbcdfe9f64a071f9cbe28ae44193fa218e72af24456f44bed64583b4d	1	24	cml7pyfy90004itl0agfmc575	2026-02-06 07:12:40.471	2026-02-06 07:12:40.471
cmlajt3lw009hitl0avtd37yg	Rachel	EMPLOYEE	6ad4a6b1e5ea5569795e516d71909e0ce4809d9dc983d2c219144f684f816e12	1	24	cml7pyfy90003itl0wzs82ss5	2026-02-06 07:12:51.332	2026-02-06 07:12:51.332
cmlajtb0g009mitl0j271zrn2	Steven	EMPLOYEE	7a5df5ffa0dec2228d90b8d0a0f1b0767b748b0a41314c123075b8289e4e053f	1	24	cml7pyfy90004itl0agfmc575	2026-02-06 07:13:00.928	2026-02-06 07:13:00.928
cmlajtpbl009ritl06ykc1ihg	Vivian	EMPLOYEE	165940940a02a187e4463ff467090930038c5af8fc26107bf301e714f599a1da	1	24	cml7pyfy90003itl0wzs82ss5	2026-02-06 07:13:19.474	2026-02-06 07:13:19.474
\.


--
-- Data for Name: Week; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Week" (id, "startDate", "createdAt") FROM stdin;
cml7q52fz000oitl0z7m4udo7	2026-02-02 08:00:00	2026-02-04 07:46:48.863
cml7q52fz000pitl0tg62n6zj	2026-02-09 08:00:00	2026-02-04 07:46:48.863
cmlak4dd800etitl0m4jj4695	2026-02-16 08:00:00	2026-02-06 07:21:37.197
cmlakcg4e00goitl0tzv15frx	2026-02-02 12:00:00	2026-02-06 07:27:54.015
cmlakcg4e00gpitl01ndt8ihq	2026-02-09 12:00:00	2026-02-06 07:27:54.015
cmlakcg4e00gqitl0u47y2mhf	2026-02-16 12:00:00	2026-02-06 07:27:54.015
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
9c371212-750b-450b-b4e2-99dfe6de0005	b805d138ccbcb688884b0242a512076d803d37059c7a82ae8872e3b585259150	2026-02-03 23:35:19.545913-08	20260204073519_kongfucat	\N	\N	2026-02-03 23:35:19.475846-08	1
0550eb94-d6b6-4be4-af5f-f287a34bfa0c	dc791bdff5b55741e6a68a3f6c6890a2fe25bdc4bccf513272d64e260aa92c14	\N	20260206074754_kongfucat	A migration failed to apply. New migrations cannot be applied before the error is recovered from. Read more about how to resolve migration issues in a production database: https://pris.ly/d/migrate-resolve\n\nMigration name: 20260206074754_kongfucat\n\nDatabase error code: 23505\n\nDatabase error:\nERROR: could not create unique index "ShiftSlot_weekId_roleTypeId_startAt_endAt_key"\nDETAIL: Key ("weekId", "roleTypeId", "startAt", "endAt")=(cmlakcg4e00goitl0tzv15frx, cml7pyfy90004itl0agfmc575, 2026-02-03 01:00:00, 2026-02-03 05:30:00) is duplicated.\n\nDbError { severity: "ERROR", parsed_severity: Some(Error), code: SqlState(E23505), message: "could not create unique index \\"ShiftSlot_weekId_roleTypeId_startAt_endAt_key\\"", detail: Some("Key (\\"weekId\\", \\"roleTypeId\\", \\"startAt\\", \\"endAt\\")=(cmlakcg4e00goitl0tzv15frx, cml7pyfy90004itl0agfmc575, 2026-02-03 01:00:00, 2026-02-03 05:30:00) is duplicated."), hint: None, position: None, where_: None, schema: Some("public"), table: Some("ShiftSlot"), column: None, datatype: None, constraint: Some("ShiftSlot_weekId_roleTypeId_startAt_endAt_key"), file: Some("tuplesortvariants.c"), line: Some(1676), routine: Some("comparetup_index_btree_tiebreak") }\n\n   0: sql_schema_connector::apply_migration::apply_script\n           with migration_name="20260206074754_kongfucat"\n             at schema-engine/connectors/sql-schema-connector/src/apply_migration.rs:113\n   1: schema_commands::commands::apply_migrations::Applying migration\n           with migration_name="20260206074754_kongfucat"\n             at schema-engine/commands/src/commands/apply_migrations.rs:95\n   2: schema_core::state::ApplyMigrations\n             at schema-engine/core/src/state.rs:260	2026-02-05 23:52:04.039341-08	2026-02-05 23:47:54.02773-08	0
9d37f89a-c762-4af8-b4c7-047487114192	dc791bdff5b55741e6a68a3f6c6890a2fe25bdc4bccf513272d64e260aa92c14	\N	20260206074754_kongfucat	A migration failed to apply. New migrations cannot be applied before the error is recovered from. Read more about how to resolve migration issues in a production database: https://pris.ly/d/migrate-resolve\n\nMigration name: 20260206074754_kongfucat\n\nDatabase error code: 23505\n\nDatabase error:\nERROR: could not create unique index "ShiftSlot_weekId_roleTypeId_startAt_endAt_key"\nDETAIL: Key ("weekId", "roleTypeId", "startAt", "endAt")=(cmlakcg4e00goitl0tzv15frx, cml7pyfy90004itl0agfmc575, 2026-02-06 01:00:00, 2026-02-06 05:30:00) is duplicated.\n\nDbError { severity: "ERROR", parsed_severity: Some(Error), code: SqlState(E23505), message: "could not create unique index \\"ShiftSlot_weekId_roleTypeId_startAt_endAt_key\\"", detail: Some("Key (\\"weekId\\", \\"roleTypeId\\", \\"startAt\\", \\"endAt\\")=(cmlakcg4e00goitl0tzv15frx, cml7pyfy90004itl0agfmc575, 2026-02-06 01:00:00, 2026-02-06 05:30:00) is duplicated."), hint: None, position: None, where_: None, schema: Some("public"), table: Some("ShiftSlot"), column: None, datatype: None, constraint: Some("ShiftSlot_weekId_roleTypeId_startAt_endAt_key"), file: Some("tuplesortvariants.c"), line: Some(1676), routine: Some("comparetup_index_btree_tiebreak") }\n\n   0: sql_schema_connector::apply_migration::apply_script\n           with migration_name="20260206074754_kongfucat"\n             at schema-engine/connectors/sql-schema-connector/src/apply_migration.rs:113\n   1: schema_commands::commands::apply_migrations::Applying migration\n           with migration_name="20260206074754_kongfucat"\n             at schema-engine/commands/src/commands/apply_migrations.rs:95\n   2: schema_core::state::ApplyMigrations\n             at schema-engine/core/src/state.rs:260	2026-02-05 23:53:11.943764-08	2026-02-05 23:52:10.837888-08	0
09e98ef3-6dd2-4630-ae84-517173399a41	dc791bdff5b55741e6a68a3f6c6890a2fe25bdc4bccf513272d64e260aa92c14	2026-02-05 23:53:19.577758-08	20260206074754_kongfucat	\N	\N	2026-02-05 23:53:19.575584-08	1
56d69840-e326-4067-8623-7b35bfabd75b	a64d9fd497823bebd213106c96f074ddd94b778c7164884dc0febacd9ba55517	2026-02-07 00:14:39.350449-08	20260207081439_kongfucat	\N	\N	2026-02-07 00:14:39.331586-08	1
\.


--
-- Name: Assignment Assignment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Assignment"
    ADD CONSTRAINT "Assignment_pkey" PRIMARY KEY (id);


--
-- Name: AvailabilityTemplate AvailabilityTemplate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AvailabilityTemplate"
    ADD CONSTRAINT "AvailabilityTemplate_pkey" PRIMARY KEY (id);


--
-- Name: Preference Preference_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Preference"
    ADD CONSTRAINT "Preference_pkey" PRIMARY KEY (id);


--
-- Name: RoleType RoleType_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."RoleType"
    ADD CONSTRAINT "RoleType_pkey" PRIMARY KEY (id);


--
-- Name: Schedule Schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Schedule"
    ADD CONSTRAINT "Schedule_pkey" PRIMARY KEY (id);


--
-- Name: Session Session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Session"
    ADD CONSTRAINT "Session_pkey" PRIMARY KEY (id);


--
-- Name: ShiftSlot ShiftSlot_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShiftSlot"
    ADD CONSTRAINT "ShiftSlot_pkey" PRIMARY KEY (id);


--
-- Name: ShiftTemplate ShiftTemplate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShiftTemplate"
    ADD CONSTRAINT "ShiftTemplate_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: Week Week_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Week"
    ADD CONSTRAINT "Week_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: Assignment_scheduleId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Assignment_scheduleId_idx" ON public."Assignment" USING btree ("scheduleId");


--
-- Name: Assignment_shiftSlotId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Assignment_shiftSlotId_key" ON public."Assignment" USING btree ("shiftSlotId");


--
-- Name: Assignment_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Assignment_userId_idx" ON public."Assignment" USING btree ("userId");


--
-- Name: AvailabilityTemplate_roleTypeId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "AvailabilityTemplate_roleTypeId_idx" ON public."AvailabilityTemplate" USING btree ("roleTypeId");


--
-- Name: AvailabilityTemplate_userId_roleTypeId_dayOfWeek_startTime__key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "AvailabilityTemplate_userId_roleTypeId_dayOfWeek_startTime__key" ON public."AvailabilityTemplate" USING btree ("userId", "roleTypeId", "dayOfWeek", "startTime", "endTime");


--
-- Name: Preference_shiftSlotId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Preference_shiftSlotId_idx" ON public."Preference" USING btree ("shiftSlotId");


--
-- Name: Preference_userId_shiftSlotId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Preference_userId_shiftSlotId_key" ON public."Preference" USING btree ("userId", "shiftSlotId");


--
-- Name: RoleType_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "RoleType_name_key" ON public."RoleType" USING btree (name);


--
-- Name: Schedule_weekId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Schedule_weekId_key" ON public."Schedule" USING btree ("weekId");


--
-- Name: Session_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Session_userId_idx" ON public."Session" USING btree ("userId");


--
-- Name: ShiftSlot_roleTypeId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ShiftSlot_roleTypeId_idx" ON public."ShiftSlot" USING btree ("roleTypeId");


--
-- Name: ShiftSlot_weekId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ShiftSlot_weekId_idx" ON public."ShiftSlot" USING btree ("weekId");


--
-- Name: ShiftSlot_weekId_roleTypeId_startAt_endAt_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ShiftSlot_weekId_roleTypeId_startAt_endAt_key" ON public."ShiftSlot" USING btree ("weekId", "roleTypeId", "startAt", "endAt");


--
-- Name: ShiftTemplate_dayOfWeek_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ShiftTemplate_dayOfWeek_idx" ON public."ShiftTemplate" USING btree ("dayOfWeek");


--
-- Name: User_passcodeHash_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "User_passcodeHash_key" ON public."User" USING btree ("passcodeHash");


--
-- Name: Week_startDate_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Week_startDate_key" ON public."Week" USING btree ("startDate");


--
-- Name: Assignment Assignment_scheduleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Assignment"
    ADD CONSTRAINT "Assignment_scheduleId_fkey" FOREIGN KEY ("scheduleId") REFERENCES public."Schedule"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Assignment Assignment_shiftSlotId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Assignment"
    ADD CONSTRAINT "Assignment_shiftSlotId_fkey" FOREIGN KEY ("shiftSlotId") REFERENCES public."ShiftSlot"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Assignment Assignment_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Assignment"
    ADD CONSTRAINT "Assignment_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: AvailabilityTemplate AvailabilityTemplate_roleTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AvailabilityTemplate"
    ADD CONSTRAINT "AvailabilityTemplate_roleTypeId_fkey" FOREIGN KEY ("roleTypeId") REFERENCES public."RoleType"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: AvailabilityTemplate AvailabilityTemplate_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AvailabilityTemplate"
    ADD CONSTRAINT "AvailabilityTemplate_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Preference Preference_shiftSlotId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Preference"
    ADD CONSTRAINT "Preference_shiftSlotId_fkey" FOREIGN KEY ("shiftSlotId") REFERENCES public."ShiftSlot"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Preference Preference_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Preference"
    ADD CONSTRAINT "Preference_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Schedule Schedule_weekId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Schedule"
    ADD CONSTRAINT "Schedule_weekId_fkey" FOREIGN KEY ("weekId") REFERENCES public."Week"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Session Session_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Session"
    ADD CONSTRAINT "Session_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ShiftSlot ShiftSlot_roleTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShiftSlot"
    ADD CONSTRAINT "ShiftSlot_roleTypeId_fkey" FOREIGN KEY ("roleTypeId") REFERENCES public."RoleType"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ShiftSlot ShiftSlot_weekId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShiftSlot"
    ADD CONSTRAINT "ShiftSlot_weekId_fkey" FOREIGN KEY ("weekId") REFERENCES public."Week"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ShiftTemplate ShiftTemplate_roleTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShiftTemplate"
    ADD CONSTRAINT "ShiftTemplate_roleTypeId_fkey" FOREIGN KEY ("roleTypeId") REFERENCES public."RoleType"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: User User_roleTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_roleTypeId_fkey" FOREIGN KEY ("roleTypeId") REFERENCES public."RoleType"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict WBaon81hrzF1Ze1bVgajGFYHBjqMy0GyWDpS7qP12HNI1UnthbfkY4D7rrXefqD

