For POSTGRES Connection use this:
`docker run --name local-postgres -e POSTGRES_USER=myuser \
  -e POSTGRES_PASSWORD=mypassword -e POSTGRES_DB=mydb \
  -p 5432:5432 -d postgres:latest
`
For Dropping this Database use this:
`docker exec local-postgres \
  psql -U myuser -d postgres \
  -c "SELECT pg_terminate_backend(pid) \
        FROM pg_stat_activity \
       WHERE datname='mydb' AND pid<>pg_backend_pid(); \
      DROP DATABASE IF EXISTS mydb;"
'