##
## Multi-stage build using official Node image for compatibility
## Avoids Alpine musl/node-gyp issues with native modules like sqlite3
##

FROM node:22-slim AS builder
WORKDIR /app

# Install dependencies first for better layer caching
COPY package.json ./
# If a lockfile exists, use it for reproducible builds
# COPY package-lock.json ./

RUN npm install

# Copy the rest of the app
COPY . .

# Optional: compile CSS if needed (non-fatal if sources are already present)
RUN npm run compile-sass || true

# Prune devDependencies for smaller runtime image
ENV NODE_ENV=production
RUN npm prune --omit=dev


FROM node:22-slim AS runtime
WORKDIR /app

# Copy app and pruned node_modules from builder
COPY --from=builder /app /app

EXPOSE 3000
CMD ["npm","start"]
