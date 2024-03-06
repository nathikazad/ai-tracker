To push this folder to heroku (from root)
```
heroku git:remote -a <app-name> --remote heroku-server
git subtree push --prefix server heroku-server master
```


To generate hasura mappings from server
```
npm install -g graphql-zeus@2.8.6
npm run generate-hasura
```
