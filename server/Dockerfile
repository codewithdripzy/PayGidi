# Use official Node.js 18 LTS Alpine image
FROM node:24-alpine

# Set the working directory
WORKDIR /usr/src/app


# Install pnpm globally
RUN npm install -g pnpm

# Copy dependency files first for better caching
COPY package.json pnpm-lock.yaml* ./

# Install production dependencies
RUN pnpm install --prod

# Copy the rest of the source code
COPY . .

# Expose the port Express runs on
EXPOSE 3000

# Set NODE_ENV to production
ENV NODE_ENV=production

# Start the Express app
CMD ["pnpm", "start"]
