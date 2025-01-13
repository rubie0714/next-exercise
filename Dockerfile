# 1. 使用官方 Node.js 映像檔作為基礎映像 (建置階段)
FROM node:18-alpine AS builder

# 2. 設定工作目錄
WORKDIR /app

# 3. 複製 package.json 和 package-lock.json / yarn.lock
COPY package*.json ./
# 如果使用的是 Yarn，可以改成：
# COPY yarn.lock ./

# 4. 安裝依賴 (為了更小的映像檔建議安裝生產依賴)
RUN npm install

# 5. 複製專案所有檔案
COPY . .

# 6. 建置 Next.js 專案
RUN npm run build

# 7. 使用更輕量的 Node.js 映像檔 (運行階段)
FROM node:18-alpine AS runner

# 8. 設定環境變數 (可選)
ENV NODE_ENV=production

# 9. 設定工作目錄
WORKDIR /app

# 10. 安裝 PM2 (可選，提升生產環境管理)
RUN npm install -g pm2

# 11. 複製必要檔案到運行階段映像
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# 12. 開放 3000 port
EXPOSE 3000

# 13. 啟動 Next.js (使用 PM2 或直接啟動)
CMD ["npm", "start"]
# 或者使用 PM2：
# CMD ["pm2-runtime", "start", "npm", "--", "start"]