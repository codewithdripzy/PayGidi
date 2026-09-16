# Use an official Node.js Alpine image.
FROM node:24-alpine

# Set the working directory
WORKDIR /usr/src/app


# Install pnpm globally
RUN npm install -g pnpm

# Copy dependency files first for better caching
COPY package.json pnpm-lock.yaml* ./

# Install dependencies, including Prisma CLI for client generation and migrations.
RUN pnpm install

# Copy the rest of the source code
COPY . .

# Generate the Prisma client and compile the monolith.
RUN pnpm build

# Expose the port Express runs on
EXPOSE 3005

# Set NODE_ENV to production
ENV NODE_ENV=production

# Start the Express app
CMD ["pnpm", "start"]
