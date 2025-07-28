# TitanOS Code challenge

Given the strict time constraints, I decided to concentrate on data modelling and performance.

## Content
The core model is `Content` where all media types are stored. 
- Seasons, episodes and channel programs have foreign keys that point to other content items.
- The normalization of the table means we can do fast lookups without joins (Although in reality, we would need to join to availabilities)
- My first option was to add availability information into the table, but i decided against it due to an exponential explosion of rows depending on markets and apps
- I decided to leverage single table inheritance to still get all the benefits of different domains for each content working as any rails model would.

## Users
`Users` model the user domain, with support tables for linking data across different functionality
- Favorite apps are stored in the `UserApp` table, with position to order by. The existence of a row in this table already means a favorite, but the model can change should new functionality arise
- `UserContent` will store the user watch habits including time watched

## Performance
- There are 3 main strategies used to ensure fast (sub-second) response times. Data normalization, caching and query optimization
- Data normalization means we don't need to perform 4 queries and can do with 1
- Query optimization allows to output JSON directly with a single query
- There is a test script for high load performance in named [requests_test.js](spec/load/requests_test.js). Be sure to disable user authentication first
- Also, the seeds file will generate fake data to load any number of records using the SAMPLE_DATA environment variable
- Use the Makefile for ease of setup and running. 