FROM python:3.8-slim-buster

WORKDIR /Lagrangian_caVAE-main

COPY requirements.txt ./

RUN pip install -r requirements.txt
COPY Lagrangian_caVAE-main/ ./Lagrangian_caVAE-main