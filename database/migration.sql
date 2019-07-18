ALTER TABLE carpoolear5.users add old_id bigint(20) not null;

# Query Migratoria de usuarios ----------------------------------------------------------
# Agregar PIN!!!!
INSERT IGNORE INTO carpoolear5.users (
    name,
    email,  
    password,  
    terms_and_conditions,  
    birthday,  
    gender,  
    nro_doc,  
    description,  
    mobile_phone,  
    image,  
    banned,  
    is_admin,  
    active,  
    activation_token , 
    emails_notifications,  
    remember_token,  
    created_at,  
    updated_at,  
    last_connection,
    has_pin,
    old_id 
) SELECT

    CASE WHEN name IS NOT NULL THEN name ELSE '' END,
    CASE WHEN email IS NOT NULL AND email <> '' THEN 
        email 
    ELSE  
        CONCAT(id, '@undefined') 
    END,
    null,
    terms_and_conditions,
    birthday,  
    gender,  
    CASE WHEN nro_doc IS NOT NULL THEN nro_doc ELSE '' END,  
    CASE WHEN descripcion IS NOT NULL THEN descripcion ELSE '' END,  
    CASE WHEN mobile_phone IS NOT NULL THEN mobile_phone ELSE '' END,
    '',
    0,
    es_admin,
    1,
    null,
    recibe_mail,
    null,
    created_at,
    updated_at,
    updated_at,
    has_pin,
    id

FROM carpool_ear.users; 


# Accounts de facebook ----------------------------------------------------------
INSERT IGNORE INTO carpoolear5.social_accounts (user_id, provider_user_id, provider, created_at, updated_at)
select id, old_id, 'facebook', created_at, updated_at  from carpoolear5.users;

# Migrations de cars -----------------------------------------------------------
INSERT IGNORE INTO carpoolear5.cars (patente, description, user_id, created_at, updated_at) 
select SUBSTRING(patente, 1, 10), '', 
    (select carpoolear5.users.id as id from carpoolear5.users where carpool_ear.users.id = carpoolear5.users.old_id limit 1),
    NOW(), NOW()
from carpool_ear.users where carpool_ear.users.patente is not null;


# Migrations de trips -----------------------------------------------------------
alter table carpoolear5.trips add old_id bigint(20) not null;
INSERT IGNORE INTO carpoolear5.trips (
  user_id,
  from_town,
  to_town, 
  trip_date,
  description, 
  total_seats, 
  friendship_type_id,
  distance,
  estimated_time, 
  co2, 
  es_recurrente, 
  is_passenger, 
  mail_send, 
  enc_path, 
  created_at, 
  updated_at, 
  deleted_at, 
  return_trip_id, 
  car_id,
  old_id
) select 
    (select carpoolear5.users.id as id from carpoolear5.users where carpool_ear.trips.user_id = carpoolear5.users.old_id limit 1) as uid,
    from_town,
    to_town,
    CASE WHEN DATE(trip_date) THEN trip_date  ELSE created_at END,
    description,
    total_seats,
    friendship_type_id,
    distance,
    estimated_time,
    co2,
    es_recurrente,
    CASE WHEN es_pasajero IS NOT NULL THEN es_pasajero ELSE false END ,
    CASE WHEN mail_send IS NOT NULL THEN mail_send ELSE true END ,
    '',
    CASE WHEN DATE(created_at) THEN created_at ELSE now() END,
    CASE WHEN DATE(updated_at) THEN updated_at ELSE now() END,
    null,
    null,
    (select carpoolear5.cars.id as car_id from carpoolear5.cars where carpoolear5.cars.user_id = uid limit 1),
    id
from carpool_ear.trips where trip_date is not null  ;


#migrtions de passageros ------------------------------------------------
INSERT IGNORE INTO carpoolear5.trip_passengers (
    user_id,
    trip_id,
    passenger_type,
    request_state,
    canceled_state,
    created_at,
    updated_at
) select 
    (select carpoolear5.users.id as id from carpoolear5.users where carpool_ear.trip_passengers.user_id = carpoolear5.users.old_id limit 1) as uid,
    (select carpoolear5.trips.id as tid from carpoolear5.trips where carpool_ear.trip_passengers.trip_id = carpoolear5.trips.old_id limit 1) as tid,
    passenger_type,
    request_state,
    0,
    CASE WHEN DATE(created_at) THEN created_at ELSE now() END,
    CASE WHEN DATE(updated_at) THEN updated_at ELSE now() END
from carpool_ear.trip_passengers where passenger_type = 1 ;

#migrtions de friends ---------------------------------

 insert into carpoolear5.friends (
     uid1,
     uid2,
     origin,
     state,
     created_at,
     updated_at
 ) select 
     u1.id,
     u2.id,
     'facebook',
     1,
     now(),
     now()
  from carpool_ear.friends 
 LEFT JOIN carpoolear5.users as u1 ON uid1 = u1.old_id
 LEFT JOIN carpoolear5.users as u2 ON uid2 = u2.old_id
 where u1.id is not null and u2.id is not null;


#migrtions de calificaciones ---------------------------------
INSERT IGNORE INTO carpoolear5.rating (
    trip_id,
    user_id_from,
    user_id_to,
    user_to_type,
    user_to_state,
    rating,
    comment,
    reply_comment,
    reply_comment_created_at,
    voted,
    rate_at,
    voted_hash,
    created_at,
    updated_at
) select
    t.id,
    u1.id,
    u2.id,
    t.user_id <> to_id,
    1,
    puntuacion,
    comentario,
    '',
    null,
    1,
    carpool_ear.calificaciones.updated_at,
    '',
    carpool_ear.calificaciones.created_at,
    carpool_ear.calificaciones.updated_at
from carpool_ear.calificaciones
LEFT JOIN carpoolear5.trips as t ON carpool_ear.calificaciones.trip_id = t.old_id 
LEFT JOIN carpoolear5.users as u2 on to_id = u2.old_id
LEFT JOIN carpoolear5.users as u1 on from_id = u1.old_id;

# Migrtions de mensajes ---------------------------------
alter table carpoolear5.conversations add old_id bigint(20) not null;

INSERT IGNORE INTO carpoolear5.conversations (
    type,
    title,
    trip_id,
    old_id
) select
    0,
    '',
    null,
    id
from carpool_ear.conversations;

# creo los users correspondiente a la conversacion
insert into carpoolear5.conversations_users (
    conversation_id,
    user_id,
    `read`
) select 
    c.id,
    u.id,
    1
from carpool_ear.conversations
LEFT JOIN carpoolear5.users as u on user_id = u.old_id
LEFT JOIN carpoolear5.conversations as c on carpool_ear.conversations.id = c.old_id
where u.id is not null;

# Migrations de mensajes
INSERT IGNORE INTO carpoolear5.messages (
    `text`,
    estado,
    user_id,
    conversation_id,
    created_at,
    updated_at
) select 
    mensaje,
    1,
    u.id,
    c.id,
    carpool_ear.messages.created_at,
    carpool_ear.messages.updated_at
from carpool_ear.messages
LEFT JOIN carpoolear5.users as u on user_id = u.old_id
LEFT JOIN carpoolear5.conversations as c on conversation_id = c.old_id
where u.id is not null;

INSERT IGNORE INTO carpoolear5.user_message_read (
    user_id,
    message_id,
    `read`,
    created_at,
    updated_at
) select 
    cu.user_id,
    m.id,
    1,
    now(),
    now()
from carpoolear5.messages as m
left join carpoolear5.conversations_users as cu on m.conversation_id = cu.conversation_id and m.user_id <> cu.user_id;


#alter table carpoolear5.trips drop old_id;
#alter table carpoolear5.users drop old_id;
#alter table carpoolear5.conversations drop old_id;

CREATE TEMPORARY TABLE IF NOT EXISTS table2
(
select min(id) as id from conversations 
inner join  (select min(updated_at) as fecha, old_id from conversations where old_id <> 0 group by old_id  order by fecha DESC) as data 
on conversations.old_id  = data.old_id and data.fecha = conversations.updated_at group by conversations.old_id 
) ;
delete from conversations where id in (select * from table2);



mysql> select * from conversations where old_id <> 0 order by updated_at DESC, old_id DESC  limit 100;
+-------+------+-------+---------+---------------------+---------------------+------------+--------+
| id    | type | title | trip_id | created_at          | updated_at          | deleted_at | old_id |
+-------+------+-------+---------+---------------------+---------------------+------------+--------+
| 86260 |    0 |       |    NULL | 2017-08-05 10:11:22 | 2017-08-10 04:47:01 | NULL       |  43193 |
| 83635 |    0 |       |    NULL | 2017-08-05 10:11:22 | 2017-08-09 13:36:43 | NULL       |  41880 |
| 34856 |    0 |       |    NULL | 2017-08-05 10:11:22 | 2017-08-09 04:42:44 | NULL       |  17462 |
| 55710 |    0 |       |    NULL | 2017-08-05 10:11:22 | 2017-08-08 20:48:57 | NULL       |  27916 |
| 86475 |    0 |       |    NULL | 2017-08-05 10:11:22 | 2017-08-08 11:11:59 | NULL       |  43300 |
| 88443 |    0 |       |    NULL | 2017-08-05 10:11:22 | 2017-08-07 20:07:20 | NULL       |  44284 |
| 84539 |    0 |       |    NULL | 2017-08-05 10:11:22 | 2017-08-07 17:51:57 | NULL       |  42332 |
| 88482 |    0 |       |    NULL | 2017-08-05 10:11:22 | 2017-08-07 14:03:33 | NULL       |  44304 |
| 88480 |    0 |       |    NULL | 2017-08-05 10:11:22 | 2017-08-07 07:44:33 | NULL       |  44303 |
| 88371 |    0 |       |    NULL | 2017-08-05 10:11:22 | 2017-08-06 17:13:40 | NULL       |  44248 |
| 61647 |    0 |       |    NULL | 2017-08-05 10:11:22 | 2017-08-06 14:08:38 | NULL       |  30884 |
| 85239 |    0 |       |    NULL | 2017-08-05 10:11:22 | 2017-08-06 10:01:21 | NULL       |  42682 |
| 46100 |    0 |       |    NULL | 2017-08-05 10:11:22 | 2017-08-06 09:19:51 | NULL       |  23111 |
| 88452 |    0 |       |    NULL | 2017-08-05 10:11:22 | 2017-08-06 06:31:05 | NULL       |  44289 |
| 88018 |    0 |       |    NULL | 2017-08-05 10:11:22 | 2017-08-06 06:30:28 | NULL       |  44072 |
