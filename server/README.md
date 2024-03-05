To push this folder to heroku (from root)
```
heroku git:remote -a <app-name> --remote heroku-server
git subtree push --prefix server heroku-server master
```