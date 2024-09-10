FROM hasura/graphql-engine:v2.37.1

# Enable the console
ENV HASURA_GRAPHQL_ENABLE_CONSOLE=true

# Enable debugging mode. It should be disabled in production.
ENV HASURA_GRAPHQL_DEV_MODE=true

# Heroku only allows to install extensions in the heroku_ext schema
ENV HASURA_GRAPHQL_METADATA_DATABASE_EXTENSIONS_SCHEMA=heroku_ext

# Limit the number of connections. Adjust based on your Heroku plan and database limits
ENV HASURA_GRAPHQL_PG_CONNECTIONS=20

# Set unauthorized role
ENV HASURA_GRAPHQL_UNAUTHORIZED_ROLE=anonymous

# JWT configuration
ENV HASURA_GRAPHQL_JWT_SECRET={"type":"RS256","key":"-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4EyxRBtXaLCs2WfM+UW8\nRgmF36Q1am3iOXWLPhA5FNrCme2Cbto55mgSp8VP0Ca1TEElH2MVvLq0RqfJm/fm\nb1bPtOkWzmPYTfOSsZ/ILdmRtdaRz0dvRgDE6tZiUPh3rYR7e81UFFHKS2rdy4dQ\nRTdbsUAcBLFdv5u/D90JOtqFJ6G09QPZbsQt5olBln35wV0WsUn/DKiZ5vnYHym2\nLgcqTy9Z9zQ5ExVTdtkj3GsZ9yWV1/wHS/IRbTZY7mID3aR/za8XZcchb5E+l1fE\n2YJRVMBAULmV49YDCjUCqi67GBdEKiMq0xYLPeVq3qvtnF861Meu2p7zDq7B1CmD\nQQIDAQAB\n-----END PUBLIC KEY-----"}

# Use environment variables for database connection
CMD HASURA_GRAPHQL_METADATA_DATABASE_URL=$DATABASE_URL \
    graphql-engine serve --server-port $PORT

# Add health check
HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q --spider http://localhost:$PORT/healthz || exit 1