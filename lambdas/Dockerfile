FROM python:3.9-alpine

WORKDIR /lambdas

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
CMD ["pytest", "-s", "tests"]
