# Start from a Node.js 16 (LTS) image 
FROM node:16

# Specify the directory inside the image in which all commands will run 
WORKDIR /usr/src/app

# Copy package files and install dependencies 
COPY package*.json ./
RUN npm install
RUN npm install express

# Copy the rest of the application 
COPY . .

# Run the application 
CMD ["node", "server.js"]

