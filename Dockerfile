FROM node:22.12 AS builder

WORKDIR /app

COPY . .

RUN npm install && npm run build

# Stage 2 (Run)
FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html