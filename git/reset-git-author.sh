#!/bin/bash
git filter-branch -f --env-filter "
    GIT_AUTHOR_NAME='new_name'
    GIT_AUTHOR_EMAIL='new_email'
    GIT_COMMITTER_NAME='new_name'
    GIT_COMMITTER_EMAIL='new_email'
  " HEAD
