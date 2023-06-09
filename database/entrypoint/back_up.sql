PGDMP         &                z            transcendence    14.2 (Debian 14.2-1.pgdg110+1)    14.1                0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false                       0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false                       0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false                       1262    16384    transcendence    DATABASE     a   CREATE DATABASE transcendence WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.utf8';
    DROP DATABASE transcendence;
                ft_root    false            B           1247    24743    request_status_enum    TYPE     a   CREATE TYPE public.request_status_enum AS ENUM (
    'WAITING',
    'ACCEPTED',
    'BLOCKED'
);
 &   DROP TYPE public.request_status_enum;
       public          ft_root    false            �            1259    24588    request    TABLE     9  CREATE TABLE public.request (
    id integer NOT NULL,
    status public.request_status_enum DEFAULT 'WAITING'::public.request_status_enum NOT NULL,
    "creatorId" integer,
    "receiverId" integer,
    "blockedByCreator" boolean DEFAULT false NOT NULL,
    "blockedByReceiver" boolean DEFAULT false NOT NULL
);
    DROP TABLE public.request;
       public         heap    ft_root    false    834    834            �            1259    24587    request_id_seq    SEQUENCE     �   CREATE SEQUENCE public.request_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.request_id_seq;
       public          ft_root    false    211                       0    0    request_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.request_id_seq OWNED BY public.request.id;
          public          ft_root    false    210            �            1259    24576    typeorm_metadata    TABLE     �   CREATE TABLE public.typeorm_metadata (
    type character varying NOT NULL,
    database character varying,
    schema character varying,
    "table" character varying,
    name character varying,
    value text
);
 $   DROP TABLE public.typeorm_metadata;
       public         heap    ft_root    false            �            1259    24595    user_entity    TABLE     v  CREATE TABLE public.user_entity (
    id integer NOT NULL,
    username character varying NOT NULL,
    avatar character varying,
    secret character varying,
    "isOnline" boolean DEFAULT false NOT NULL,
    "isTwoFA" boolean DEFAULT false NOT NULL,
    played integer DEFAULT 0 NOT NULL,
    victory integer DEFAULT 0 NOT NULL,
    defeats integer DEFAULT 0 NOT NULL
);
    DROP TABLE public.user_entity;
       public         heap    ft_root    false            j           2604    24591 
   request id    DEFAULT     h   ALTER TABLE ONLY public.request ALTER COLUMN id SET DEFAULT nextval('public.request_id_seq'::regclass);
 9   ALTER TABLE public.request ALTER COLUMN id DROP DEFAULT;
       public          ft_root    false    210    211    211                      0    24588    request 
   TABLE DATA           q   COPY public.request (id, status, "creatorId", "receiverId", "blockedByCreator", "blockedByReceiver") FROM stdin;
    public          ft_root    false    211   {                 0    24576    typeorm_metadata 
   TABLE DATA           X   COPY public.typeorm_metadata (type, database, schema, "table", name, value) FROM stdin;
    public          ft_root    false    209   �       	          0    24595    user_entity 
   TABLE DATA           t   COPY public.user_entity (id, username, avatar, secret, "isOnline", "isTwoFA", played, victory, defeats) FROM stdin;
    public          ft_root    false    212   �                  0    0    request_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.request_id_seq', 6, true);
          public          ft_root    false    210            t           2606    24594 &   request PK_167d324701e6867f189aed52e18 
   CONSTRAINT     f   ALTER TABLE ONLY public.request
    ADD CONSTRAINT "PK_167d324701e6867f189aed52e18" PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.request DROP CONSTRAINT "PK_167d324701e6867f189aed52e18";
       public            ft_root    false    211            v           2606    24603 *   user_entity PK_b54f8ea623b17094db7667d8206 
   CONSTRAINT     j   ALTER TABLE ONLY public.user_entity
    ADD CONSTRAINT "PK_b54f8ea623b17094db7667d8206" PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.user_entity DROP CONSTRAINT "PK_b54f8ea623b17094db7667d8206";
       public            ft_root    false    212            x           2606    24605 *   user_entity UQ_9b998bada7cff93fcb953b0c37e 
   CONSTRAINT     k   ALTER TABLE ONLY public.user_entity
    ADD CONSTRAINT "UQ_9b998bada7cff93fcb953b0c37e" UNIQUE (username);
 V   ALTER TABLE ONLY public.user_entity DROP CONSTRAINT "UQ_9b998bada7cff93fcb953b0c37e";
       public            ft_root    false    212            y           2606    24606 &   request FK_714f665dcb7ea33a577de776481    FK CONSTRAINT     �   ALTER TABLE ONLY public.request
    ADD CONSTRAINT "FK_714f665dcb7ea33a577de776481" FOREIGN KEY ("creatorId") REFERENCES public.user_entity(id);
 R   ALTER TABLE ONLY public.request DROP CONSTRAINT "FK_714f665dcb7ea33a577de776481";
       public          ft_root    false    211    212    3190            z           2606    24611 &   request FK_e474c30f189e7757e3db67126a1    FK CONSTRAINT     �   ALTER TABLE ONLY public.request
    ADD CONSTRAINT "FK_e474c30f189e7757e3db67126a1" FOREIGN KEY ("receiverId") REFERENCES public.user_entity(id);
 R   ALTER TABLE ONLY public.request DROP CONSTRAINT "FK_e474c30f189e7757e3db67126a1";
       public          ft_root    false    3190    212    211               3   x�3�ttvvqu�47713�4�L�L�2�w���s��Z� X&F��� 6�
�            x������ � �      	   �   x�3�J-�-N-���4 4 A.C���K�*k�%���� gIFQ*vݖ �����pss3μ������Ό���b+}��<�̼��D=#��"�R��b}�2���tN_O�@?�� c'�cg$Cc���� \�=�     