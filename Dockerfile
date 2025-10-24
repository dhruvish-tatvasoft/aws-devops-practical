FROM node:20

WORKDIR /app

# Copy package files first for caching
COPY app/package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY app/src ./src

# Expose port
EXPOSE 8080

# Start the app
CMD ["npm", "start"]
