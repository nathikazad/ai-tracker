To push this folder to heroku (from root)
```
heroku git:remote -a <app-name> --remote heroku-server
git subtree push --prefix server heroku-server master
```

If there is overwrite issue
```
git subtree split --prefix=server -b temp-branch
git push heroku-server temp-branch:main --force
```

To generate hasura mappings from server
```
npm install -g graphql-zeus@2.8.6
npm run generate-hasura
```

To get logs

heroku logs --tail --app ai-tracker-server