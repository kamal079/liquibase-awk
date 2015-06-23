# liquibase-awk
Awk Script to generate changesets

Helps to create for triggers, tables from .sql file.

Script Usage

awk -f liquibaseChangeSets.awk -v _changeSetName=changeset- _authorName=author _liquibaseID=1 _endDelimiter=END database.sql
