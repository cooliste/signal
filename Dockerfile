# Dockerfile pour une application Next.js

# Étape 1: Installation des dépendances
# Utilise une image Node.js légère comme base. Alpine est un bon choix pour sa petite taille.
FROM node:20-alpine AS deps
WORKDIR /app

# Copie package.json et package-lock.json (s'il existe)
COPY package.json ./
# npm-shrinkwrap.json est également copié s'il est utilisé.

# Installe les dépendances. 'npm ci' est généralement plus rapide et plus sûr pour les builds.
RUN npm install

# Étape 2: Construction de l'application
# 'builder' hérite de l'étape précédente.
FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Exécute le script de construction de Next.js.
RUN npm run build

# Étape 3: Production
# C'est l'image finale qui sera exécutée.
FROM node:20-alpine AS runner
WORKDIR /app

# Configure l'environnement pour la production.
ENV NODE_ENV=production

# Copie uniquement les artefacts nécessaires depuis l'étape 'builder'.
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# Le port sur lequel l'application s'exécute.
# La commande de démarrage utilise le port 9002.
EXPOSE 9002

# Commande pour démarrer le serveur Next.js.
# Le port 9002 est spécifié ici.
CMD ["node", "server.js"]
