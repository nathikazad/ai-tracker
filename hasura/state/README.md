```
hasura metadata export
hasura migrate create "migrations" --from-server
```


To create embeddings columns
ALTER TABLE event_types ADD COLUMN embedding vector(1536);
CREATE INDEX event_types_embedding_idx ON public.event_types USING hnsw (embedding public.vector_ip_ops);
