# Aprendiz CRUD - Flutter + Supabase

Aplicación Flutter que inicia con autenticación, permite mostrar/ocultar contraseña y, después de iniciar sesión correctamente, presenta una HomePage para realizar CRUD sobre la tabla `aprendiz`.

## 1. Requisitos

- Flutter 3.x
- Dart 3.x
- Una aplicación/proyecto Supabase con la tabla `aprendiz`
- Autenticación por email y contraseña habilitada en Supabase

## 2. Tabla

La app espera esta estructura:

```sql
create table public.aprendiz (
    id              int         not null,
    nombre1         varchar(20) not null,
    nombre2         varchar(20),
    apellido1       varchar(20) not null,
    apellido2       varchar(20),
    genero          char(1)     not null,
    fecha_nacimiento date        not null,
    celular         varchar(10) not null,
    email           varchar(50) not null,
    constraint pk_aprendiz primary key(id)
);
```

## 3. Supabase

La URL y publishable key solicitadas ya están configuradas en `lib/main.dart`.

> La publishable key de Supabase está diseñada para ser usada desde clientes. La seguridad real debe implementarse con RLS/policies; nunca pongas una `service_role`/secret key en una app Flutter.

## 4. Crear un usuario para entrar

En Supabase:
1. Ve a Authentication > Users.
2. Crea un usuario con email y contraseña.
3. Usa esas credenciales en la pantalla de Login.

## 5. RLS

Si tienes RLS activado, crea policies para que el usuario autenticado pueda consultar/insertar/actualizar/eliminar. Por ejemplo:

```sql
alter table public.aprendiz enable row level security;

create policy "authenticated select aprendiz"
on public.aprendiz for select
to authenticated
using (true);

create policy "authenticated insert aprendiz"
on public.aprendiz for insert
to authenticated
with check (true);

create policy "authenticated update aprendiz"
on public.aprendiz for update
to authenticated
using (true)
with check (true);

create policy "authenticated delete aprendiz"
on public.aprendiz for delete
to authenticated
using (true);
```

Estas policies son un ejemplo para un ejercicio académico. En producción conviene restringir el acceso según el modelo de autorización de tu sistema.

## 6. Ejecutar

```bash
flutter pub get
flutter run
```

## Funcionalidades

- Login con Supabase Auth.
- Mostrar/ocultar contraseña.
- Validación de campos.
- HomePage después de autenticarse.
- Listar aprendices.
- Crear aprendiz.
- Editar aprendiz.
- Eliminar aprendiz con confirmación.
- Cerrar sesión.
- Selector de fecha.
- Validación básica de email, celular, género y longitudes.
- Manejo de errores de Supabase.
