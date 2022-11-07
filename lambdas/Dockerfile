FROM python:3.9-alpine

WORKDIR /lambdas

COPY requirements.txt .
RUN pip install -r requirements.txt

RUN mkdir ~/.aws/
RUN echo -e "[default]\nregion=us-east-1\naws_access_key_id=test\naws_secret_access_key=test" > ~/.aws/credentials

COPY . .
CMD ["pytest", "-s", "tests"]
