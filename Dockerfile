FROM python:3.7.3-stretch
 
WORKDIR /app
 
RUN pip install --upgrade pip && pip install -r requirements.txt

# hadolint ignore=DL3013
 COPY . /app

EXPOSE 80

CMD [ "python", "app.py" ]