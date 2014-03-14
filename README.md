# Hubot Shipr

This is a [Hubot](https://github.com/github/hubot) script for [Shipr](https://github.com/remind101/shipr)

## Install

1. Add hubot-shipr to your package.json file:

   ```bash
   $ npm install hubot-shipr --save
   ```

2. Add `hubot-shipr` to external-scripts.json:

   ```json
   ["hubot-shipr"]
   ```

3. Set the the following environment variables on your instance of hubot:

   ```
   SHIPR_BASE=<base url for shipr>
   SHIPR_AUTH=:<api key>
   SHIPR_GITHUB_ORG=<your github organization>
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
