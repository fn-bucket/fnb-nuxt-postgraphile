# Nuxt 3 Minimal Starter

Look at the [nuxt 3 documentation](https://v3.nuxtjs.org) to learn more.

## Docker Postgres Database Setup

create a directory in which to host your postgres docker volume.  mine here is $HOME/pg/data-14.  then create a .sh file with similar contents:
```
#!/usr/bin/env bash

docker run --rm --name pg14 --shm-size=1g -e POSTGRES_PASSWORD=1234 -d -p 5432:5432 -v $HOME/pg/data-14:/var/lib/postgresql/data  postgres
```

to make a new db:
```
psql -h 0.0.0.0 -U postgres -c 'create database fnb;'
psql -h 0.0.0.0 -U postgres -d fnb -f ./db/roles.sql
psql -h 0.0.0.0 -U postgres -d fnb -f ./db/fnb.sql
```

to replace the whole db
```
psql -h 0.0.0.0 -U postgres -c 'drop database fnb;'
psql -h 0.0.0.0 -U postgres -c 'create database fnb;'
psql -h 0.0.0.0 -U postgres -d fnb -f ./db/fnb.sql
```

## Setup

Make sure to install the dependencies:

```bash
# npm
npm install
```

## Development Server

Start the development server on http://localhost:3000

```bash
npm run dev
```

## Production

Build the application for production:

```bash
npm run build
```

Locally preview production build:

```bash
npm run preview
```

Checkout the [deployment documentation](https://v3.nuxtjs.org/guide/deploy/presets) for more information.

