# Use an official Python image as base
FROM python:3.13-slim

# Set environment variables to avoid interactive prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies including LaTeX and some fonts for xelatex
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    texlive-latex-base \
    texlive-latex-recommended \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-xetex \
    texlive-science \
    texlive-publishers \
    texlive-plain-generic \
    fonts-freefont-ttf \
    fonts-dejavu \
    fonts-noto \
    fonts-liberation \
    fonts-inconsolata \
    fonts-texgyre \
    build-essential \
    git \
    curl \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install the project into `/app`
WORKDIR /app

# Copy all the app code to the docker and install as root
COPY . /app

# Install the package
RUN pip install .

# Set up a new user named "user" with user ID 1000
RUN useradd -m -u 1000 user

# Change ownership of app directory to user
RUN chown -R user:user /app

# Switch to the "user" user for runtime
USER user

# Set home to the user's home directory
ENV HOME=/home/user \
	PATH=/home/user/.local/bin:$PATH

# This informs Docker that the container will listen on port 5000 at runtime.
EXPOSE 8501

# Touch a .env so it can be shared as a volume (being a single file instead of a folder requires this)
RUN touch .env

# Command to run the app
HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health

CMD ["streamlit", "run", "src/denario_app/app.py", "--server.port=8501", "--server.address=0.0.0.0"]
