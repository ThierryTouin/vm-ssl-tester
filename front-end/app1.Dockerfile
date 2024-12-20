## Stage 1: Build Image
FROM node:22-alpine as build

ARG TITLE 

# Ajouter l'entrée au fichier /etc/hosts
#RUN echo "172.19.192.33 nexus.codep.inetum.world" >> /etc/hosts
# Copier votre fichier personnalisé dans l'image
COPY custom_hosts /tmp/custom_hosts
# Ajouter les entrées de /tmp/custom_hosts dans /etc/hosts
RUN cat /tmp/custom_hosts >> /etc/hosts



WORKDIR /app
COPY ./react-app/package*.json ./
RUN npm install
COPY ./react-app .
RUN REACT_APP_TITLE=${TITLE} \
    npm run build

## Stage 2, use the compiled app, ready for production with Nginx
FROM nginx:1.21.6-alpine
COPY --from=build /app/build /usr/share/nginx/html 
COPY ./nginx/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80 
CMD ["nginx", "-g", "daemon off;"]