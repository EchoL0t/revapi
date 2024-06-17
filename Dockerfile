FROM python:3.8-slim

# Install libpq-dev
RUN apt update && apt-get install -y libpq-dev gcc


WORKDIR /code

COPY ./requirements.txt /code/requirements.txt

RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# 
COPY ./sapi /code/sapi

# 
CMD ["fastapi", "run", "sapi/main.py", "--port", "80"]
