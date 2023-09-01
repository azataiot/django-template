
<p align="center">
  <a href="https://github.com/azataiot/django-template/">
    <img src="docs/docs/assets/img/docs-icon-teal-200.png" alt="django-template logo" width="200" height="200">
  </a>
</p>

<h3 align="center">Django Template</h3>

<div style="text-align: center;">
  Batteries included Django project template designed for practical, real-world applications
  <br>
  <a href="#"><strong>Explore Django Template docs »</strong></a>
  <br>
  <br>
</div>

## django-template

A streamlined Django template designed for practical, real-world applications, with essential configurations and best
practices integrated out of the box.

<a href="https://github.com/azataiot/django-template/generate"><img src="https://img.shields.io/badge/use%20this-template-blue?logo=github" alt="use-this-repo-badge"></a>
[![Keep Bootstrap Updated](https://github.com/azataiot/django-template/actions/workflows/bootstrap_update.yml/badge.svg)](https://github.com/azataiot/django-template/actions/workflows/bootstrap_update.yml) [![isort](https://img.shields.io/badge/%20linting-isort-%231674b1?style=flat&labelColor=ef8336)](https://pycqa.github.io/isort/)

## Features

- Highly Customizable and Configurable through [settings.toml](settings.toml) file.
- Uses [Django](https://www.djangoproject.com/) as backend.
- Uses [Django Ninja](https://django-ninja.rest-framework.com/) as API framework.
- Uses [Django Channels](https://channels.readthedocs.io/en/stable/) as websocket framework.
- Uses [Django Allauth](https://django-allauth.readthedocs.io/en/latest/) as authentication framework.
- Uses [TOML]() as configuration file format. see [settings.toml](settings.toml) | [Why TOML?]()
- Uses [Poetry](https://python-poetry.org/) as dependency manager FOR DEVELOPMENT.
- Uses [Docker](https://www.docker.com/) as containerization and deployment tool for PRODUCTION.
- Uses [PostgreSQL](https://www.postgresql.org/) as database. (Configurable to use other databases)
- Uses [Redis](https://redis.io/) as cache and message broker. (Configurable to use other message brokers)
- Uses [Celery](https://docs.celeryproject.org/en/stable/) as task queue.
- Uses [Sentry](https://sentry.io/) as error tracking tool.
- Uses [GitHub Actions]() as CI/CD tool.

## Quick Start

1. [Use this template](https://github.com/azataiot/django-template/generate) to create a new repository.
2. Install [Poetry](https://python-poetry.org/docs/#installation).
3. Install dependencies using `poetry install`.
4. Configure your settings in [settings.toml](settings.toml).
5. Run migrations
   using `make migrations`, [other options](https://docs.djangoproject.com/en/3.2/ref/django-admin/#django-admin-migrate).
6. Run server
   using `make runserver` ( using django's local server) or `make daphne` (using daphne server).
