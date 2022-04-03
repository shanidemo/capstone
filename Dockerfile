FROM python:3.7.3-stretch
 
## Step 1:
# Create a working directory
WORKDIR /app
 
# RUN pip install --upgrade pip && pip install -r requirements.txt
RUN pip install --no-cache-dir Click==7.0 \
Flask==1.0.2 \
itsdangerous==1.1.0 \
Jinja2==2.10.3 \
MarkupSafe==1.1.1 \
numpy==1.17.2 \
pandas==0.24.2 \
python-dateutil==2.8.0 \
pytz==2019.3 \
scikit-learn==0.20.3 \
scipy==1.3.1 \
six==1.12.0 \
Werkzeug==0.16.0 \
pylint==2.4.4

# hadolint ignore=DL3013
 COPY . /app

EXPOSE 80

CMD [ "python", "app.py" ]