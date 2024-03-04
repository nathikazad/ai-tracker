FROM hasura/graphql-engine:v2.37.1

# Enable the console
ENV HASURA_GRAPHQL_ENABLE_CONSOLE=true

# Enable debugging mode. It should be disabled in production.
ENV HASURA_GRAPHQL_DEV_MODE=true

# Heroku only allows to install extensions in the heroku_ext schema
ENV HASURA_GRAPHQL_METADATA_DATABASE_EXTENSIONS_SCHEMA=heroku_ext

ENV HASURA_GRAPHQL_PG_CONNECTIONS=20

ENV HASURA_GRAPHQL_UNAUTHORIZED_ROLE=anonymous

CMD HASURA_GRAPHQL_METADATA_DATABASE_URL=$DATABASE_URL graphql-engine \
    serve \
    --server-port $PORT