# Hubot Deploy

This is a [Hubot](https://github.com/github/hubot) script for the [GitHub Deployments API](https://developer.github.com/v3/repos/deployments/).

## Install

1. Add hubot-deploy to your package.json file:

   ```bash
   $ npm install hubot-deploy --save
   ```

2. Add `hubot-deploy` to external-scripts.json:

   ```json
   ["hubot-deploy"]
   ```

3. Set the the following environment variables on your instance of hubot:

   ```
   GITHUB_TOKEN=:<api key>
   GITHUB_ORG=<your github organization>
   ```

## Usage

Deploy an app to production:

```
hubot deploy app
hubot deploy app to production
```

Deploy a topic branch to staging:

```
hubot deploy app#topic to staging
```

Force deploy a branch to staging:

```
hubot deploy app to staging!
```
