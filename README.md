# chat-server

Chat server is a Ruby on Rails API server that has the ability to create, update, get applications and create chats and messages for them using some cool technologies `Ruby on Rails` `MySQL` `Redis` `Sidekiq` `Elasticsearch`.

## Running the app

The app is containerized so running the following command is sufficient to make all the services up and running

```bash
docker-compose up
```
## Running the tests

Rspec is used to cover 98.97% of the app. The following command is to run the implemented specs.

```bash
docker-compose run -e "RAILS_ENV=test" app bundle exec rspec
```
# REST API

The REST API to the chat server is described below.

## Application

Creating an app

### Request

`POST /api/v1/applications`

    curl --location --request POST 'http://localhost:3000/api/v1/applications' \
    --header 'Content-Type: application/json' \
    --data-raw '{
        "app": {
            "name": "test app"
        }
    }'

### Response

    {
       "data": {
            "name": "test app",
            "token": "7p9X27Uq1GtLSzm9F58KVg1o",
            "chats_count": 0
        }
    }

Get list of Applications

### Request

`GET /api/v1/applications`

    curl --location --request GET 'http://localhost:3000/api/v1/applications'

### Response

    {
        "data":[
            {
                "name":"test app",
                "token":"7p9X27Uq1GtLSzm9F58KVg1o",
                "chats_count":2
            },
            {
                "name":"fad",
                "token":"Mpai9yFwPATMiZbrJokdwF9w",
                "chats_count":1
            }
        ]
    }

Get Data of specific app

### Request

`GET /api/v1/applications/{token}`

    curl --location --request GET 'http://localhost:3000/api/v1/applications/7p9X27Uq1GtLSzm9F58KVg1o'

### Response

     {
       "data":{
            "name":"test app",
            "token":"7p9X27Uq1GtLSzm9F58KVg1o",
            "chats_count":2
        }
     }

Update Data of specific app

### Request

`PUT /api/v1/applications/{token}`

    curl --location --request PUT 'http://localhost:3000/api/v1/applications/7p9X27Uq1GtLSzm9F58KVg1o' \
    --header 'Content-Type: application/json' \
    --data-raw '{
        "app": {
            "name": "test"
        }
    }'

### Response

     {
       "data":{
            "name":"test",
            "token":"7p9X27Uq1GtLSzm9F58KVg1o",
            "chats_count":2
        }
     }

## Chat

Creating a chat

### Request

`POST /api/v1/applications/{token}/chats`

    curl --location --request POST 'http://localhost:3000/api/v1/applications/7p9X27Uq1GtLSzm9F58KVg1o/chats' \

### Response

    {
        "data": {
            "app_token": "7p9X27Uq1GtLSzm9F58KVg1o",
            "number": 1,
            "messages_count": 0
        }
    }

Get list of chats

### Request

`GET /api/v1/chats`

    curl --location --request GET 'http://localhost:3000/api/v1/applications'

### Response

    {
        "data": [
            {
                "app_token": "7p9X27Uq1GtLSzm9F58KVg1o",
                "number": 2,
                "messages_count": 0
            },
            {
                "app_token": "7p9X27Uq1GtLSzm9F58KVg1o",
                "number": 1,
                "messages_count": 0
            }
        ]
    }

Get chats of specific app

### Request

`GET /api/v1/applications/{token}/chats/{number}`

    curl --location --request GET 'http://localhost:3000/api/v1/applications/7p9X27Uq1GtLSzm9F58KVg1o/chats' \

### Response

    {
        "data": [
            {
                "app_token": "7p9X27Uq1GtLSzm9F58KVg1o",
                "number": 1,
                "messages_count": 0
            },
            {
                "app_token": "7p9X27Uq1GtLSzm9F58KVg1o",
                "number": 2,
                "messages_count": 0
            }
        ]
    }

## Message

Creating a Message

### Request

`POST /api/v1/applications/{token}/chats/{number}/messages`

    curl --location --request POST 'http://localhost:3000/api/v1/applications/7p9X27Uq1GtLSzm9F58KVg1o/chats/1/messages' \
    --header 'Content-Type: application/json' \
    --data-raw '{
        "message":{
            "body":"hey there"
        }
    }''

### Response

    {
        "data": {
            "number": 1,
            "body": "hey there"
        }
    }

Get list of messages

### Request

`GET /api/v1/messages`

    curl --location --request GET 'http://localhost:3000/api/v1/messages' \

### Response

    {
        "data": [
            {
                "number": 2,
                "body": "fady hey"
            },
            {
                "number": 1,
                "body": "hey there"
            }
        ]
    }

Get messages of specific chat

### Request

`GET /api/v1/applications/{token}/chats/{number}/messages`

    curl --location --request GET 'http://localhost:3000/api/v1/applications/7p9X27Uq1GtLSzm9F58KVg1o/chats/1/messages' \

### Response

    {
        "data": [
            {
                "number": 1,
                "body": "hey there"
            },
            {
                "number": 2,
                "body": "fady hey"
            }
        ]
    }

Search messages with specific query

### Request

`POST /api/v1/applications/{token}/chats/{number}/messages/search`

    curl --location --request POST 'http://localhost:3000/api/v1/applications/7p9X27Uq1GtLSzm9F58KVg1o/chats/1/messages/search' \
    --header 'Content-Type: application/json' \
    --data-raw '{
        "message":{
            "body":"hey"
        }
    }''

### Response

    {
        "data": [
            {
                "number": 1,
                "body": "hey there"
            },
            {
                "number": 2,
                "body": "fady hey"
            }
        ]
    }
