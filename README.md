
## Setup

1. Create and fill in `.env` using `.env.example` as an example.

2. Install required dependencies

```
bundle install
npm install
```

Install postgres:

```
brew install postgresql
```

3. Turn your PDF into embeddings for GPT-3:

Book used here is Show Your Work and can be replaced by any other book

```
ruby scripts/pdf_to_pages_embeddings.rb book.pdf
```

4. Set up database tables and collect static files:

```
rails db:migrate
```

5. Other things like book title, purchase url, cover photo, default/training questions can be changed in statis.json

### Run locally

```
bin/dev
```

### Deployed

This app is deployed on digital ocean : https://squid-app-fclrq.ondigitalocean.app/


### Tech Stack Used

Backend: Ruby on Rails
Frontend: React with Typescript
Database: Postgres
