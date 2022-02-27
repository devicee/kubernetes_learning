# Pull the official base image
FROM python:3.9.1-alpine

# Set work directory
WORKDIR /usr/src/app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install the dependencies
RUN pip3 install --upgrade pip setuptools wheel
COPY ./requirements.txt /usr/src/app
RUN pip3 install -r requirements.txt

# Copy only project files
COPY kubernetes_learning /usr/src/app/kubernetes_learning
COPY manage.py /usr/src/app
COPY db.sqlite3 /usr/src/app

EXPOSE 8000

# Uncomment first if you want to test if everything is OK without gunicorn!
#CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
CMD ["gunicorn", "kubernetes_learning.wsgi:application", "--bind", "0.0.0.0:8000"]