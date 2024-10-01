### Set up profile

Add the following lines to you ~/.dbt/profiles.yml:

```yaml
test_project:
  outputs:
    dev:
      type: sqlite
      threads: 1
      database: "{{ env_var('DBT_PROJECT_PATH') }}/db/example.db" 
      schema: main 
      schemas_and_paths:
        main: "{{ env_var('DBT_PROJECT_PATH') }}/db/example.db" 
      schema_directory: "{{ env_var('DBT_PROJECT_PATH') }}/db"
  target: dev
```


To run use the following commands:

```bash
- export DBT_PROJECT_PATH={path to project folder}
- dbt compile
- dbt run
- dbt test
```

